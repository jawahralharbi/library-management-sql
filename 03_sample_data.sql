
-- Library Management System — Sample Data
-- Custom-built interactively: authors, books, members and staff
-- reflect real decisions made while building this project.
-- (Member/staff names, emails & phone numbers are anonymized
--  placeholders — no real personal data.)



-- AUTHORS (4 modern Arabic authors + 5 classical/heritage figures)

INSERT INTO authors (first_name, last_name, birth_date) VALUES
('نجيب', 'محفوظ', '1911-12-11'),
('غازي', 'القصيبي', '1940-03-02'),
('طه', 'حسين', '1889-11-14'),
('عبدالرحمن', 'منيف', '1933-05-29'),
('ميخائيل', 'نعيمة', '1889-10-17'),
('أحمد بن الحسين', 'المتنبي', '0915-01-01'),
('علي بن أحمد', 'ابن حزم', '0994-11-07'),
('قيس بن الملوح', 'مجنون ليلى', NULL),
('جميل بن معمر', 'جميل بثينة', NULL);


-- PUBLISHERS

INSERT INTO publishers (name, address, phone, email) VALUES
('دار الشروق', 'القاهرة، مصر', '0225785000', 'info@shorouk.com'),
('دار الساقي', 'بيروت، لبنان', '0961145000', 'info@saqibooks.com'),
('مكتبة جرير', 'الرياض، السعودية', '0114000000', 'info@jarir.com'),
('دار الآداب', 'بيروت، لبنان', '0961365000', 'info@aladabbooks.com'),
('Penguin Random House', 'New York, USA', '2125550000', 'contact@penguin.com'),
('دار صادر', 'بيروت، لبنان', '0961920420', 'info@daralsader.com');


-- CATEGORIES

INSERT INTO categories (category_name, description) VALUES
('رواية', 'أعمال أدبية قصصية'),
('تاريخ', 'كتب تتناول الأحداث والحضارات التاريخية'),
('علوم', 'كتب علمية وتقنية'),
('فلسفة', 'كتب في الفكر والفلسفة'),
('سيرة ذاتية', 'قصص حياة شخصيات حقيقية'),
('شعر', 'دواوين ومجموعات شعرية');


-- BOOKS (20 titles, verified authorship — see README)
-- publication_year is NULL where no reliably documented date exists.

INSERT INTO books (isbn, title, publisher_id, category_id, publication_year, language, pages, price) VALUES
('9789953801001', 'دنسكو',
    (SELECT publisher_id FROM publishers WHERE name = 'دار الساقي'),
    (SELECT category_id FROM categories WHERE category_name = 'رواية'), 1987, 'Arabic', 200, 45.00),
('9789953801002', 'سعادة السفير',
    (SELECT publisher_id FROM publishers WHERE name = 'دار الساقي'),
    (SELECT category_id FROM categories WHERE category_name = 'رواية'), NULL, 'Arabic', 240, 45.00),
('9789960555001', 'حياة في الإدارة',
    (SELECT publisher_id FROM publishers WHERE name = 'مكتبة جرير'),
    (SELECT category_id FROM categories WHERE category_name = 'سيرة ذاتية'), 1989, 'Arabic', 310, 55.00),
('9789953801003', 'الجنية',
    (SELECT publisher_id FROM publishers WHERE name = 'دار الساقي'),
    (SELECT category_id FROM categories WHERE category_name = 'رواية'), NULL, 'Arabic', 260, 48.00),
('9789953802001', 'الأسطورة',
    (SELECT publisher_id FROM publishers WHERE name = 'دار الآداب'),
    (SELECT category_id FROM categories WHERE category_name = 'سيرة ذاتية'), 1998, 'Arabic', 180, 38.00),
('9789953801004', 'سلمى',
    (SELECT publisher_id FROM publishers WHERE name = 'دار الساقي'),
    (SELECT category_id FROM categories WHERE category_name = 'رواية'), NULL, 'Arabic', 230, 45.00),
('9789953802002', 'مع ناجي ومعها',
    (SELECT publisher_id FROM publishers WHERE name = 'دار الآداب'),
    (SELECT category_id FROM categories WHERE category_name = 'شعر'), 1999, 'Arabic', 80, 30.00),
('9789960555002', 'الوزير المرافق',
    (SELECT publisher_id FROM publishers WHERE name = 'مكتبة جرير'),
    (SELECT category_id FROM categories WHERE category_name = 'سيرة ذاتية'), 2010, 'Arabic', 220, 42.00),
('9789953801005', 'أبو شلاخ البرمائي',
    (SELECT publisher_id FROM publishers WHERE name = 'دار الساقي'),
    (SELECT category_id FROM categories WHERE category_name = 'رواية'), NULL, 'Arabic', 210, 42.00),
('9789953802003', 'هما',
    (SELECT publisher_id FROM publishers WHERE name = 'دار الآداب'),
    (SELECT category_id FROM categories WHERE category_name = 'رواية'), NULL, 'Arabic', 190, 40.00),
('9789953802004', 'حديقة الغروب',
    (SELECT publisher_id FROM publishers WHERE name = 'دار الآداب'),
    (SELECT category_id FROM categories WHERE category_name = 'شعر'), 2010, 'Arabic', 60, 25.00),
('9789953801006', 'شقة الحرية',
    (SELECT publisher_id FROM publishers WHERE name = 'دار الساقي'),
    (SELECT category_id FROM categories WHERE category_name = 'رواية'), NULL, 'Arabic', 340, 52.00),
('9789960100001', 'الأيام',
    (SELECT publisher_id FROM publishers WHERE name = 'دار صادر'),
    (SELECT category_id FROM categories WHERE category_name = 'سيرة ذاتية'), 1929, 'Arabic', 300, 48.00),
('9789960100002', 'مذكرات الأرقش',
    (SELECT publisher_id FROM publishers WHERE name = 'دار صادر'),
    (SELECT category_id FROM categories WHERE category_name = 'رواية'), 1949, 'Arabic', 139, 35.00),
('9789953802005', 'قصة حب مجوسية',
    (SELECT publisher_id FROM publishers WHERE name = 'دار الآداب'),
    (SELECT category_id FROM categories WHERE category_name = 'رواية'), 1974, 'Arabic', 129, 35.00),
('9789953802006', 'الأشجار واغتيال مرزوق',
    (SELECT publisher_id FROM publishers WHERE name = 'دار الآداب'),
    (SELECT category_id FROM categories WHERE category_name = 'رواية'), 1973, 'Arabic', 350, 55.00),
('9789960100003', 'ديوان المتنبي',
    (SELECT publisher_id FROM publishers WHERE name = 'دار صادر'),
    (SELECT category_id FROM categories WHERE category_name = 'شعر'), NULL, 'Arabic', 450, 60.00),
('9789960100004', 'ديوان مجنون ليلى',
    (SELECT publisher_id FROM publishers WHERE name = 'دار صادر'),
    (SELECT category_id FROM categories WHERE category_name = 'شعر'), NULL, 'Arabic', 180, 40.00),
('9789960100005', 'ديوان جميل بثينة',
    (SELECT publisher_id FROM publishers WHERE name = 'دار صادر'),
    (SELECT category_id FROM categories WHERE category_name = 'شعر'), NULL, 'Arabic', 150, 38.00),
('9789960100006', 'طوق الحمامة',
    (SELECT publisher_id FROM publishers WHERE name = 'دار صادر'),
    (SELECT category_id FROM categories WHERE category_name = 'فلسفة'), 1022, 'Arabic', 260, 45.00);


-- BOOK_AUTHORS (many-to-many, resolved by name — order-independent)

INSERT INTO book_authors (book_id, author_id)
SELECT
    (SELECT book_id FROM books WHERE title = book_title),
    (SELECT author_id FROM authors WHERE first_name = a_first AND last_name = a_last)
FROM (VALUES
    ('دنسكو', 'غازي', 'القصيبي'),
    ('سعادة السفير', 'غازي', 'القصيبي'),
    ('حياة في الإدارة', 'غازي', 'القصيبي'),
    ('الجنية', 'غازي', 'القصيبي'),
    ('الأسطورة', 'غازي', 'القصيبي'),
    ('سلمى', 'غازي', 'القصيبي'),
    ('مع ناجي ومعها', 'غازي', 'القصيبي'),
    ('الوزير المرافق', 'غازي', 'القصيبي'),
    ('أبو شلاخ البرمائي', 'غازي', 'القصيبي'),
    ('هما', 'غازي', 'القصيبي'),
    ('حديقة الغروب', 'غازي', 'القصيبي'),
    ('شقة الحرية', 'غازي', 'القصيبي'),
    ('الأيام', 'طه', 'حسين'),
    ('مذكرات الأرقش', 'ميخائيل', 'نعيمة'),
    ('قصة حب مجوسية', 'عبدالرحمن', 'منيف'),
    ('الأشجار واغتيال مرزوق', 'عبدالرحمن', 'منيف'),
    ('ديوان المتنبي', 'أحمد بن الحسين', 'المتنبي'),
    ('ديوان مجنون ليلى', 'قيس بن الملوح', 'مجنون ليلى'),
    ('ديوان جميل بثينة', 'جميل بن معمر', 'جميل بثينة'),
    ('طوق الحمامة', 'علي بن أحمد', 'ابن حزم')
) AS t(book_title, a_first, a_last);


-- BOOK_COPIES — 3 physical copies generated per book automatically

INSERT INTO book_copies (book_id, copy_number, status, shelf_location, acquisition_date)
SELECT b.book_id, gs, 'available',
       'A' || b.category_id || '-' || LPAD(b.book_id::text,3,'0') || '-' || gs,
       CURRENT_DATE - (RANDOM()*700)::INT
FROM books b, generate_series(1,3) gs;


-- MEMBERS (anonymized demo data)

INSERT INTO members (first_name, last_name, email, phone, address, membership_date, membership_type, status) VALUES
('Noura', 'Alsalem', 'member1.demo@example.com', '0500000002', 'الرياض', CURRENT_DATE - 150, 'premium', 'active'),
('Haya', 'Alqarni', 'member2.demo@example.com', '0500000003', 'جدة', CURRENT_DATE - 90, 'regular', 'active'),
('Dana', 'Alanazi', 'member3.demo@example.com', '0500000004', 'المدينة المنورة', CURRENT_DATE - 60, 'student', 'active'),
('Rayan', 'Almutairi', 'member4.demo@example.com', '0500000005', 'المدينة المنورة', CURRENT_DATE - 200, 'regular', 'active');


-- STAFF (anonymized demo data)

INSERT INTO staff (first_name, last_name, email, phone, role, hire_date) VALUES
('Jawaher', 'H', 'librarian.demo@example.com', '0500000001', 'admin', CURRENT_DATE - 800);


-- LOANS — resolved by book title / copy number / member email,
-- so it stays correct even if IDs shift.

INSERT INTO loans (copy_id, member_id, staff_id, loan_date, due_date, return_date, status)
SELECT
    (SELECT copy_id FROM book_copies bc JOIN books b ON b.book_id = bc.book_id
        WHERE b.title = book_title AND bc.copy_number = cn),
    (SELECT member_id FROM members WHERE email = member_email),
    (SELECT staff_id FROM staff WHERE email = 'librarian.demo@example.com'),
    loan_dt, due_dt, ret_dt, loan_status
FROM (VALUES
    ('دنسكو', 1, 'member1.demo@example.com', CURRENT_DATE - 30, CURRENT_DATE - 16, CURRENT_DATE - 17, 'returned'),
    ('سعادة السفير', 1, 'member2.demo@example.com', CURRENT_DATE - 25, CURRENT_DATE - 11, CURRENT_DATE - 10, 'returned'),
    ('الأيام', 1, 'member3.demo@example.com', CURRENT_DATE - 20, CURRENT_DATE - 6, NULL, 'overdue'),
    ('طوق الحمامة', 1, 'member4.demo@example.com', CURRENT_DATE - 18, CURRENT_DATE - 4, NULL, 'overdue'),
    ('حياة في الإدارة', 1, 'member1.demo@example.com', CURRENT_DATE - 5, CURRENT_DATE + 9, NULL, 'active'),
    ('قصة حب مجوسية', 1, 'member2.demo@example.com', CURRENT_DATE - 3, CURRENT_DATE + 11, NULL, 'active'),
    ('الأشجار واغتيال مرزوق', 1, 'member3.demo@example.com', CURRENT_DATE - 1, CURRENT_DATE + 13, NULL, 'active')
) AS t(book_title, cn, member_email, loan_dt, due_dt, ret_dt, loan_status);

-- Sync copy status for loans that were inserted as already returned
UPDATE book_copies SET status = 'available'
WHERE status = 'borrowed'
  AND copy_id IN (SELECT copy_id FROM loans WHERE return_date IS NOT NULL)
  AND copy_id NOT IN (SELECT copy_id FROM loans WHERE return_date IS NULL);


-- OPTIONAL BONUS DATA — reservations, fines & reviews
-- (Not part of the guided build; add these separately if you want
--  a fuller demo for screenshots / the advanced queries in 05.)

-- INSERT INTO reservations (book_id, member_id, reservation_date, expiry_date, status)
-- SELECT (SELECT book_id FROM books WHERE title = 'سلمى'),
--        (SELECT member_id FROM members WHERE email = 'member2.demo@example.com'),
--        CURRENT_DATE - 2, CURRENT_DATE + 5, 'pending';