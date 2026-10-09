
-- Library Management System — Advanced Analytical Queries
-- (CTEs, Window Functions, Subqueries, Aggregations)


-- 1) Top 3 most-borrowed books per category (window function: ROW_NUMBER + PARTITION BY)
WITH book_loan_counts AS (
    SELECT
        b.book_id,
        b.title,
        c.category_name,
        COUNT(l.loan_id) AS loan_count,
        ROW_NUMBER() OVER (PARTITION BY c.category_id ORDER BY COUNT(l.loan_id) DESC) AS rnk
    FROM books b
    JOIN categories c   ON c.category_id = b.category_id
    JOIN book_copies bc ON bc.book_id = b.book_id
    LEFT JOIN loans l   ON l.copy_id = bc.copy_id
    GROUP BY b.book_id, b.title, c.category_id, c.category_name
)
SELECT category_name, title, loan_count
FROM book_loan_counts
WHERE rnk <= 3
ORDER BY category_name, loan_count DESC;

-- 2) Monthly borrowing trend with running total (window function: SUM OVER)
SELECT
    TO_CHAR(loan_date, 'YYYY-MM') AS month,
    COUNT(*) AS loans_this_month,
    SUM(COUNT(*)) OVER (ORDER BY TO_CHAR(loan_date, 'YYYY-MM')) AS running_total
FROM loans
GROUP BY TO_CHAR(loan_date, 'YYYY-MM')
ORDER BY month;

-- 3) Members currently holding overdue books, with total amount owed (correlated subquery)
SELECT
    m.member_id,
    m.first_name || ' ' || m.last_name AS member_name,
    (SELECT COUNT(*) FROM loans l WHERE l.member_id = m.member_id AND l.status = 'overdue') AS overdue_books,
    COALESCE((SELECT SUM(f.amount) FROM fines f WHERE f.member_id = m.member_id AND f.paid = FALSE), 0) AS total_owed
FROM members m
WHERE EXISTS (SELECT 1 FROM loans l WHERE l.member_id = m.member_id AND l.status = 'overdue')
ORDER BY total_owed DESC;

-- 4) Books that have never been borrowed (NOT EXISTS: no copy of the book has any loan)
SELECT b.book_id, b.title, b.publication_year
FROM books b
WHERE NOT EXISTS (
    SELECT 1
    FROM book_copies bc
    JOIN loans l ON l.copy_id = bc.copy_id
    WHERE bc.book_id = b.book_id
)
ORDER BY b.title;

-- 5) Average loan duration (in days) by category, only counting returned loans
SELECT
    c.category_name,
    ROUND(AVG(l.return_date - l.loan_date), 1) AS avg_days_kept,
    COUNT(*) AS returned_loans
FROM loans l
JOIN book_copies bc ON bc.copy_id = l.copy_id
JOIN books b        ON b.book_id  = bc.book_id
JOIN categories c   ON c.category_id = b.category_id
WHERE l.return_date IS NOT NULL
GROUP BY c.category_name
ORDER BY avg_days_kept DESC;

-- 6) Top 5 most active members (by total historical loans), with membership tier
SELECT
    m.member_id,
    m.first_name || ' ' || m.last_name AS member_name,
    m.membership_type,
    COUNT(l.loan_id) AS total_loans,
    RANK() OVER (ORDER BY COUNT(l.loan_id) DESC) AS activity_rank
FROM members m
JOIN loans l ON l.member_id = m.member_id
GROUP BY m.member_id, m.first_name, m.last_name, m.membership_type
ORDER BY activity_rank
LIMIT 5;

-- 7) Category performance: total copies, currently available, utilisation %
SELECT
    c.category_name,
    COUNT(bc.copy_id) AS total_copies,
    COUNT(bc.copy_id) FILTER (WHERE bc.status = 'available') AS available_now,
    ROUND(
        100.0 * COUNT(bc.copy_id) FILTER (WHERE bc.status = 'borrowed') / NULLIF(COUNT(bc.copy_id), 0), 1
    ) AS utilisation_pct
FROM categories c
JOIN books b        ON b.category_id = c.category_id
JOIN book_copies bc ON bc.book_id    = b.book_id
GROUP BY c.category_name
ORDER BY utilisation_pct DESC;