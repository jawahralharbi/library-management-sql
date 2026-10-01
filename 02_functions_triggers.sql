
-- Library Management System — Functions & Triggers



-- FUNCTION: fn_calculate_fine
-- Returns the fine owed for a loan based on days overdue.
-- Rate: 5 SAR per day late.

CREATE OR REPLACE FUNCTION fn_calculate_fine(p_loan_id INT)
RETURNS NUMERIC AS $$
DECLARE
    v_due_date   DATE;
    v_return_date DATE;
    v_days_late  INT;
    v_rate       NUMERIC := 5.00;
BEGIN
    SELECT due_date, COALESCE(return_date, CURRENT_DATE)
      INTO v_due_date, v_return_date
    FROM loans WHERE loan_id = p_loan_id;

    v_days_late := GREATEST(v_return_date - v_due_date, 0);
    RETURN v_days_late * v_rate;
END;
$$ LANGUAGE plpgsql;



-- FUNCTION: fn_borrow_book
-- Handles the full "borrow" business flow with validation:
--   - member must be active
--   - member must have no unpaid fines
--   - member cannot hold more than 5 active loans
--   - the copy must currently be available
-- Returns the new loan_id.

CREATE OR REPLACE FUNCTION fn_borrow_book(
    p_member_id INT,
    p_copy_id   INT,
    p_staff_id  INT,
    p_loan_days INT DEFAULT 14
) RETURNS INT AS $$
DECLARE
    v_member_status   VARCHAR(20);
    v_copy_status     VARCHAR(20);
    v_unpaid_fines    INT;
    v_active_loans    INT;
    v_loan_id         INT;
BEGIN
    SELECT status INTO v_member_status FROM members WHERE member_id = p_member_id;
    IF v_member_status IS NULL THEN
        RAISE EXCEPTION 'Member % does not exist', p_member_id;
    ELSIF v_member_status <> 'active' THEN
        RAISE EXCEPTION 'Member % is not active (status: %)', p_member_id, v_member_status;
    END IF;

    SELECT COUNT(*) INTO v_unpaid_fines FROM fines WHERE member_id = p_member_id AND paid = FALSE;
    IF v_unpaid_fines > 0 THEN
        RAISE EXCEPTION 'Member % has % unpaid fine(s) — settle before borrowing', p_member_id, v_unpaid_fines;
    END IF;

    SELECT COUNT(*) INTO v_active_loans FROM loans WHERE member_id = p_member_id AND status IN ('active','overdue');
    IF v_active_loans >= 5 THEN
        RAISE EXCEPTION 'Member % already has % active loans (limit is 5)', p_member_id, v_active_loans;
    END IF;

    SELECT status INTO v_copy_status FROM book_copies WHERE copy_id = p_copy_id;
    IF v_copy_status IS NULL THEN
        RAISE EXCEPTION 'Copy % does not exist', p_copy_id;
    ELSIF v_copy_status <> 'available' THEN
        RAISE EXCEPTION 'Copy % is not available (status: %)', p_copy_id, v_copy_status;
    END IF;

    INSERT INTO loans (copy_id, member_id, staff_id, loan_date, due_date, status)
    VALUES (p_copy_id, p_member_id, p_staff_id, CURRENT_DATE, CURRENT_DATE + p_loan_days, 'active')
    RETURNING loan_id INTO v_loan_id;

    RETURN v_loan_id;
END;
$$ LANGUAGE plpgsql;



-- FUNCTION: fn_return_book
-- Marks a loan as returned, frees the copy, and automatically
-- issues a fine if the book came back late.

CREATE OR REPLACE FUNCTION fn_return_book(p_loan_id INT)
RETURNS VOID AS $$
DECLARE
    v_due_date  DATE;
    v_member_id INT;
    v_fine      NUMERIC;
BEGIN
    SELECT due_date, member_id INTO v_due_date, v_member_id
    FROM loans WHERE loan_id = p_loan_id AND return_date IS NULL;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Loan % not found or already returned', p_loan_id;
    END IF;

    UPDATE loans
       SET return_date = CURRENT_DATE,
           status = 'returned'
     WHERE loan_id = p_loan_id;

    IF CURRENT_DATE > v_due_date THEN
        v_fine := fn_calculate_fine(p_loan_id);
        INSERT INTO fines (loan_id, member_id, amount, reason, issued_date)
        VALUES (p_loan_id, v_member_id, v_fine,
                'overdue return (' || (CURRENT_DATE - v_due_date) || ' days)', CURRENT_DATE);
    END IF;
END;
$$ LANGUAGE plpgsql;



-- FUNCTION: fn_reserve_book
-- Creates a reservation only if no copy is currently available.

CREATE OR REPLACE FUNCTION fn_reserve_book(p_member_id INT, p_book_id INT)
RETURNS INT AS $$
DECLARE
    v_available INT;
    v_reservation_id INT;
BEGIN
    SELECT COUNT(*) INTO v_available
    FROM book_copies WHERE book_id = p_book_id AND status = 'available';

    IF v_available > 0 THEN
        RAISE EXCEPTION 'Book % has % available copies — borrow it directly instead of reserving', p_book_id, v_available;
    END IF;

    INSERT INTO reservations (book_id, member_id, reservation_date, expiry_date, status)
    VALUES (p_book_id, p_member_id, CURRENT_DATE, CURRENT_DATE + 7, 'pending')
    RETURNING reservation_id INTO v_reservation_id;

    RETURN v_reservation_id;
END;
$$ LANGUAGE plpgsql;



-- TRIGGERS



-- TRIGGER: after a loan is inserted, flip the copy to 'borrowed'

CREATE OR REPLACE FUNCTION trg_fn_copy_borrowed()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE book_copies SET status = 'borrowed' WHERE copy_id = NEW.copy_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_after_loan_insert
AFTER INSERT ON loans
FOR EACH ROW
EXECUTE FUNCTION trg_fn_copy_borrowed();


-- TRIGGER: when a loan gets a return_date, free the copy again

CREATE OR REPLACE FUNCTION trg_fn_copy_returned()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.return_date IS NOT NULL AND OLD.return_date IS NULL THEN
        UPDATE book_copies SET status = 'available' WHERE copy_id = NEW.copy_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_after_loan_return
AFTER UPDATE ON loans
FOR EACH ROW
EXECUTE FUNCTION trg_fn_copy_returned();


-- TRIGGER: prevent negative/invalid fine payments
-- (paid_date must be set when a fine is marked paid, and vice versa)

CREATE OR REPLACE FUNCTION trg_fn_validate_fine_payment()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.paid = TRUE AND NEW.paid_date IS NULL THEN
        NEW.paid_date := CURRENT_DATE;
    ELSIF NEW.paid = FALSE THEN
        NEW.paid_date := NULL;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_before_fine_update
BEFORE INSERT OR UPDATE ON fines
FOR EACH ROW
EXECUTE FUNCTION trg_fn_validate_fine_payment();


-- TRIGGER: auto-suspend a member once they hit 3+ unpaid fines

CREATE OR REPLACE FUNCTION trg_fn_auto_suspend_member()
RETURNS TRIGGER AS $$
DECLARE
    v_unpaid_count INT;
BEGIN
    SELECT COUNT(*) INTO v_unpaid_count
    FROM fines WHERE member_id = NEW.member_id AND paid = FALSE;

    IF v_unpaid_count >= 3 THEN
        UPDATE members SET status = 'suspended' WHERE member_id = NEW.member_id;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_after_fine_insert
AFTER INSERT ON fines
FOR EACH ROW
EXECUTE FUNCTION trg_fn_auto_suspend_member();


-- MAINTENANCE PROCEDURE: mark loans overdue (run daily via cron/job scheduler)

CREATE OR REPLACE PROCEDURE sp_mark_overdue_loans()
LANGUAGE plpgsql AS $$
BEGIN
    UPDATE loans
       SET status = 'overdue'
     WHERE status = 'active'
       AND due_date < CURRENT_DATE
       AND return_date IS NULL;
END;
$$;