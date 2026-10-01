
-- Library Management System — Views


-- 1) Available books with live copy counts
CREATE OR REPLACE VIEW v_available_books AS
SELECT
    b.book_id,
    b.title,
    b.isbn,
    c.category_name,
    STRING_AGG(DISTINCT a.first_name || ' ' || a.last_name, ', ') AS authors,
    COUNT(bc.copy_id) FILTER (WHERE bc.status = 'available') AS available_copies,
    COUNT(bc.copy_id) AS total_copies
FROM books b
JOIN categories c        ON c.category_id = b.category_id
JOIN book_authors ba      ON ba.book_id = b.book_id
JOIN authors a            ON a.author_id = ba.author_id
JOIN book_copies bc       ON bc.book_id = b.book_id
GROUP BY b.book_id, b.title, b.isbn, c.category_name;

-- 2) Active loans with full context + days remaining
CREATE OR REPLACE VIEW v_active_loans AS
SELECT
    l.loan_id,
    m.first_name || ' ' || m.last_name AS member_name,
    b.title,
    l.loan_date,
    l.due_date,
    (l.due_date - CURRENT_DATE) AS days_remaining,
    l.status
FROM loans l
JOIN members m      ON m.member_id = l.member_id
JOIN book_copies bc ON bc.copy_id  = l.copy_id
JOIN books b        ON b.book_id   = bc.book_id
WHERE l.status IN ('active','overdue');

-- 3) Overdue loans (recomputed live off due_date, not just the status flag)
CREATE OR REPLACE VIEW v_overdue_loans AS
SELECT
    l.loan_id,
    m.member_id,
    m.first_name || ' ' || m.last_name AS member_name,
    m.email,
    b.title,
    l.due_date,
    (CURRENT_DATE - l.due_date) AS days_overdue,
    ROUND((CURRENT_DATE - l.due_date) * 5.0, 2) AS estimated_fine  -- 5 SAR/day
FROM loans l
JOIN members m      ON m.member_id = l.member_id
JOIN book_copies bc ON bc.copy_id  = l.copy_id
JOIN books b        ON b.book_id   = bc.book_id
WHERE l.return_date IS NULL
  AND l.due_date < CURRENT_DATE;

-- 4) Member borrowing history (lifetime)
CREATE OR REPLACE VIEW v_member_history AS
SELECT
    m.member_id,
    m.first_name || ' ' || m.last_name AS member_name,
    b.title,
    l.loan_date,
    l.due_date,
    l.return_date,
    l.status,
    CASE WHEN l.return_date IS NOT NULL AND l.return_date > l.due_date
         THEN l.return_date - l.due_date ELSE 0 END AS days_late
FROM loans l
JOIN members m      ON m.member_id = l.member_id
JOIN book_copies bc ON bc.copy_id  = l.copy_id
JOIN books b        ON b.book_id   = bc.book_id;

-- 5) Most popular books (ranked by total loans, using a window function)
CREATE OR REPLACE VIEW v_popular_books AS
SELECT
    b.book_id,
    b.title,
    COUNT(l.loan_id) AS total_loans,
    ROUND(AVG(r.rating)::NUMERIC, 2) AS avg_rating,
    RANK() OVER (ORDER BY COUNT(l.loan_id) DESC) AS popularity_rank
FROM books b
LEFT JOIN book_copies bc ON bc.book_id = b.book_id
LEFT JOIN loans l        ON l.copy_id  = bc.copy_id
LEFT JOIN reviews r      ON r.book_id  = b.book_id
GROUP BY b.book_id, b.title;

-- 6) Members with outstanding (unpaid) fines
CREATE OR REPLACE VIEW v_members_with_unpaid_fines AS
SELECT
    m.member_id,
    m.first_name || ' ' || m.last_name AS member_name,
    m.email,
    COUNT(f.fine_id) AS unpaid_fines_count,
    SUM(f.amount) AS total_owed
FROM fines f
JOIN members m ON m.member_id = f.member_id
WHERE f.paid = FALSE
GROUP BY m.member_id, m.first_name, m.last_name, m.email;