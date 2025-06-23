SELECT * FROM books;
SELECT * FROM branch;
SELECT * FROM employees;
SELECT * FROM issued_status;
SELECT * FROM members;
SELECT * FROM return_status;

--Project Task

--Task 1. Create a New Book Record -- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"

INSERT INTO books(isbn, book_title, category, rental_price, status, author, publisher)
VALUES('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');
SELECT * FROM books;

--Task 2: Update an Existing Member's Address

UPDATE members
SET member_address = '122 Main St' WHERE member_id = 'C101'
SELECT * FROM members

--Task 3: Delete a Record from the Issued Status Table -- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.

DELETE FROM issued_status
WHERE issued_id = 'IS121'
SELECT * FROM issued_status

--Task 4: Retrieve All Books Issued by a Specific Employee -- Objective: Select all books issued by the employee with emp_id = 'E101'.

SELECT * FROM issued_status
WHERE issued_emp_id = 'E101'

--Task 5: List Members Who Have Issued More Than One Book -- Objective: Use GROUP BY to find members who have issued more than one book.

SELECT
    issued_emp_id,
    COUNT(*)
FROM issued_status
GROUP BY issued_emp_id
HAVING COUNT(*) > 1

--Task 6: Create Summary Tables: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt**

SELECT * FROM books;
SELECT * FROM issued_status;

CREATE TABLE book_counts AS
SELECT 
	b.isbn,
	b.book_title,
	COUNT(ist.issued_id) as no_issued
FROM books as b
JOIN issued_status as ist
ON ist.issued_book_isbn = b.isbn
GROUP BY b.isbn, b.book_title

--Task7: Retrive the employee name and their position together with the issued_book_name and issued_date 

SELECT 
	e.emp_name,
	e.position,
	ist.issued_book_name,
	ist.issued_date
FROM employees as e
JOIN issued_status as ist
ON ist.issued_emp_id = e.emp_id


--Task 8. Retrieve All Books in a Specific Category:

SELECT * FROM books
WHERE category = 'Classic'

--Task 9: Find Total Rental Income by Category:

SELECT 
	b.category,
	SUM(b.rental_price) AS total_income,
	COUNT(*) AS count_number
FROM books as b
JOIN issued_status as ist
ON ist.issued_book_isbn = b.isbn
GROUP BY category

--TASK 10 List Members Who Registered in the Last 1800 Days:

SELECT *
FROM members
WHERE DATEDIFF(DAY, reg_date, GETDATE()) <= 1800

--Task 11 List Employees with Their Branch Manager's Name and their branch details:

SELECT  
	e1.emp_id,
	e1.emp_name,
	e1.position,
	e1.salary,
	e2.emp_name as manager
FROM employees AS e1
JOIN branch AS b1
ON b1.branch_id = e1.branch_id
JOIN employees AS e2
ON b1.manager_id = e2.emp_id

--Task 11. Create a Table of Books with Rental Price Above a Certain Threshold:

CREATE TABLE expensive_books AS
SELECT * FROM books
WHERE rental_price > 7.00;

--Task 12: Retrieve the List of Books Not Yet Returned

SELECT * 
FROM issued_status AS ist
LEFT JOIN
return_status AS rs
ON rs.issued_id = ist.issued_id
WHERE rs.return_id IS NULL

--