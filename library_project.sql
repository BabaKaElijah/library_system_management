--Library Management System Project

--creating branch table
CREATE DATABASE library_db;

-- Drop and create "branch"
DROP TABLE IF EXISTS branch;
CREATE TABLE branch (
    branch_id VARCHAR(10) PRIMARY KEY,
    manager_id VARCHAR(10),
    branch_address VARCHAR(30),
    contact_no VARCHAR(15)
);

-- Drop and create "employees"
DROP TABLE IF EXISTS employees;
CREATE TABLE employees (
    emp_id VARCHAR(10) PRIMARY KEY,
    emp_name VARCHAR(30),
    position VARCHAR(30),
    salary DECIMAL(10,2),
    branch_id VARCHAR(10),
    FOREIGN KEY (branch_id) REFERENCES branch(branch_id)
);

-- Drop and create "members"
DROP TABLE IF EXISTS members;
CREATE TABLE members (
    member_id VARCHAR(30) PRIMARY KEY,
    member_name VARCHAR(30),
    member_address VARCHAR(30),
    reg_date DATE
);

-- Drop and create "books"
DROP TABLE IF EXISTS books;
CREATE TABLE books (
    isbn VARCHAR(50) PRIMARY KEY,
    book_title VARCHAR(80),
    category VARCHAR(30),
    rental_price DECIMAL(10,2),
    status VARCHAR(10),
    author VARCHAR(30),
    publisher VARCHAR(30)
);

-- Drop and create "issued_status"
DROP TABLE IF EXISTS issued_status;
CREATE TABLE issued_status (
    issued_id VARCHAR(10) PRIMARY KEY,
    issued_member_id VARCHAR(30),
    issued_book_name VARCHAR(80),
    issued_date DATE,
    issued_book_isbn VARCHAR(50),
    issued_emp_id VARCHAR(10),
    FOREIGN KEY (issued_member_id) REFERENCES members(member_id),
    FOREIGN KEY (issued_book_isbn) REFERENCES books(isbn),
    FOREIGN KEY (issued_emp_id) REFERENCES employees(emp_id)
);

-- Drop and create "return_status"
DROP TABLE IF EXISTS return_status;
CREATE TABLE return_status (
    return_id VARCHAR(10) PRIMARY KEY,
    issued_id VARCHAR(10),
    return_book_name VARCHAR(80),
    return_date DATE,
    return_book_isbn VARCHAR(50),
    FOREIGN KEY (issued_id) REFERENCES issued_status(issued_id),
    FOREIGN KEY (return_book_isbn) REFERENCES books(isbn)
);
SELECT * FROM books
SELECT * FROM branch
SELECT * FROM employees
SELECT * FROM issued_status
SELECT * FROM members
SELECT * FROM return_status

ALTER TABLE branch
ALTER COLUMN contatct_no TYPE VARCHAR(50);