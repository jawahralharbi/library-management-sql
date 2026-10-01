
-- Library Management System — Database Schema
-- Engine: PostgreSQL 14+ (built and tested on Supabase)


DROP SCHEMA IF EXISTS public CASCADE;
CREATE SCHEMA public;


-- 1. AUTHORS

CREATE TABLE authors (
    author_id       SERIAL PRIMARY KEY,
    first_name      VARCHAR(60)  NOT NULL,
    last_name       VARCHAR(60)  NOT NULL,
    birth_date      DATE,
    created_at      TIMESTAMP    NOT NULL DEFAULT NOW()
);


-- 2. PUBLISHERS

CREATE TABLE publishers (
    publisher_id    SERIAL PRIMARY KEY,
    name            VARCHAR(120) NOT NULL UNIQUE,
    address         VARCHAR(200),
    phone           VARCHAR(20),
    email           VARCHAR(120)
);


-- 3. CATEGORIES

CREATE TABLE categories (
    category_id     SERIAL PRIMARY KEY,
    category_name   VARCHAR(80) NOT NULL UNIQUE,
    description     TEXT
);


-- 4. BOOKS
-- Note: publication_year range widened to 500–2100 to allow
-- classical Arabic heritage works (poetry collections predating
-- the year 1000 CE).

CREATE TABLE books (
    book_id             SERIAL PRIMARY KEY,
    isbn                VARCHAR(13) NOT NULL UNIQUE,
    title               VARCHAR(250) NOT NULL,
    publisher_id        INT REFERENCES publishers(publisher_id) ON DELETE SET NULL,
    category_id         INT REFERENCES categories(category_id) ON DELETE SET NULL,
    publication_year    SMALLINT CHECK (publication_year BETWEEN 500 AND 2100),
    language            VARCHAR(30) DEFAULT 'Arabic',
    pages               SMALLINT CHECK (pages > 0),
    price               NUMERIC(8,2) CHECK (price >= 0),
    created_at          TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE book_authors (
    book_id     INT NOT NULL REFERENCES books(book_id)   ON DELETE CASCADE,
    author_id   INT NOT NULL REFERENCES authors(author_id) ON DELETE CASCADE,
    PRIMARY KEY (book_id, author_id)
);


-- 5. BOOK COPIES (physical inventory)

CREATE TABLE book_copies (
    copy_id          SERIAL PRIMARY KEY,
    book_id          INT NOT NULL REFERENCES books(book_id) ON DELETE CASCADE,
    copy_number      SMALLINT NOT NULL,
    status           VARCHAR(20) NOT NULL DEFAULT 'available'
                        CHECK (status IN ('available','borrowed','reserved','lost','maintenance')),
    shelf_location   VARCHAR(30),
    acquisition_date DATE NOT NULL DEFAULT CURRENT_DATE,
    UNIQUE (book_id, copy_number)
);


-- 6. MEMBERS

CREATE TABLE members (
    member_id        SERIAL PRIMARY KEY,
    first_name       VARCHAR(60) NOT NULL,
    last_name        VARCHAR(60) NOT NULL,
    email            VARCHAR(120) NOT NULL UNIQUE,
    phone            VARCHAR(20),
    address          VARCHAR(200),
    membership_date  DATE NOT NULL DEFAULT CURRENT_DATE,
    membership_type  VARCHAR(20) NOT NULL DEFAULT 'regular'
                        CHECK (membership_type IN ('regular','student','premium')),
    status           VARCHAR(20) NOT NULL DEFAULT 'active'
                        CHECK (status IN ('active','suspended','expired'))
);


-- 7. STAFF

CREATE TABLE staff (
    staff_id     SERIAL PRIMARY KEY,
    first_name   VARCHAR(60) NOT NULL,
    last_name    VARCHAR(60) NOT NULL,
    email        VARCHAR(120) NOT NULL UNIQUE,
    phone        VARCHAR(20),
    role         VARCHAR(20) NOT NULL DEFAULT 'librarian'
                    CHECK (role IN ('librarian','admin','assistant')),
    hire_date    DATE NOT NULL DEFAULT CURRENT_DATE
);


-- 8. LOANS (borrowing transactions)

CREATE TABLE loans (
    loan_id      SERIAL PRIMARY KEY,
    copy_id      INT NOT NULL REFERENCES book_copies(copy_id),
    member_id    INT NOT NULL REFERENCES members(member_id),
    staff_id     INT REFERENCES staff(staff_id),
    loan_date    DATE NOT NULL DEFAULT CURRENT_DATE,
    due_date     DATE NOT NULL,
    return_date  DATE,
    status       VARCHAR(20) NOT NULL DEFAULT 'active'
                    CHECK (status IN ('active','returned','overdue','lost')),
    CHECK (due_date >= loan_date),
    CHECK (return_date IS NULL OR return_date >= loan_date)
);


-- 9. RESERVATIONS

CREATE TABLE reservations (
    reservation_id    SERIAL PRIMARY KEY,
    book_id           INT NOT NULL REFERENCES books(book_id),
    member_id         INT NOT NULL REFERENCES members(member_id),
    reservation_date  DATE NOT NULL DEFAULT CURRENT_DATE,
    expiry_date       DATE NOT NULL,
    status            VARCHAR(20) NOT NULL DEFAULT 'pending'
                        CHECK (status IN ('pending','fulfilled','cancelled','expired'))
);


-- 10. FINES

CREATE TABLE fines (
    fine_id      SERIAL PRIMARY KEY,
    loan_id      INT NOT NULL REFERENCES loans(loan_id),
    member_id    INT NOT NULL REFERENCES members(member_id),
    amount       NUMERIC(8,2) NOT NULL CHECK (amount >= 0),
    reason       VARCHAR(100) NOT NULL DEFAULT 'overdue return',
    issued_date  DATE NOT NULL DEFAULT CURRENT_DATE,
    paid         BOOLEAN NOT NULL DEFAULT FALSE,
    paid_date    DATE
);


-- 11. REVIEWS

CREATE TABLE reviews (
    review_id     SERIAL PRIMARY KEY,
    book_id       INT NOT NULL REFERENCES books(book_id) ON DELETE CASCADE,
    member_id     INT NOT NULL REFERENCES members(member_id) ON DELETE CASCADE,
    rating        SMALLINT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    comment       TEXT,
    review_date   DATE NOT NULL DEFAULT CURRENT_DATE,
    UNIQUE (book_id, member_id)
);


-- INDEXES

CREATE INDEX idx_books_title            ON books(title);
CREATE INDEX idx_books_isbn             ON books(isbn);
CREATE INDEX idx_books_category         ON books(category_id);
CREATE INDEX idx_book_copies_status     ON book_copies(status);
CREATE INDEX idx_book_copies_book       ON book_copies(book_id);
CREATE INDEX idx_members_email          ON members(email);
CREATE INDEX idx_loans_member           ON loans(member_id);
CREATE INDEX idx_loans_due_date         ON loans(due_date) WHERE status = 'active';
CREATE INDEX idx_loans_status           ON loans(status);
CREATE INDEX idx_reservations_member    ON reservations(member_id);
CREATE INDEX idx_fines_member_unpaid    ON fines(member_id) WHERE paid = FALSE;