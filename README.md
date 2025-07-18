# Library Management System using SQL Project --P2

## Project Overview

**Project Title**: Library Management System  
**Level**: Intermediate  
**Database**: `library_db`

This project demonstrates the implementation of a Library Management System using SQL. It includes creating and managing tables, performing CRUD operations, and executing advanced SQL queries. The goal is to showcase skills in database design, manipulation, and querying.

![Library_project](https://github.com/najirh/Library-System-Management---P2/blob/main/library.jpg)

## Objectives

1. **Set up the Library Management System Database**: Create and populate the database with tables for branches, employees, members, books, issued status, and return status.
2. **CRUD Operations**: Perform Create, Read, Update, and Delete operations on the data.
3. **CTAS (Create Table As Select)**: Utilize CTAS to create new tables based on query results.
4. **Advanced SQL Queries**: Develop complex queries to analyze and retrieve specific data.

## Project Structure

### 1. Database Setup
![ERD](https://github.com/najirh/Library-System-Management---P2/blob/main/library_erd.png)

- **Database Creation**: Created a database named `library_db`.
- **Table Creation**: Created tables for branches, employees, members, books, issued status, and return status. Each table includes relevant columns and relationships.

```sql
CREATE DATABASE library_db;

DROP TABLE IF EXISTS branch;
CREATE TABLE branch
(
            branch_id VARCHAR(10) PRIMARY KEY,
            manager_id VARCHAR(10),
            branch_address VARCHAR(30),
            contact_no VARCHAR(15)
);


-- Create table "Employee"
DROP TABLE IF EXISTS employees;
CREATE TABLE employees
(
            emp_id VARCHAR(10) PRIMARY KEY,
            emp_name VARCHAR(30),
            position VARCHAR(30),
            salary DECIMAL(10,2),
            branch_id VARCHAR(10),
            FOREIGN KEY (branch_id) REFERENCES  branch(branch_id)
);


-- Create table "Members"
DROP TABLE IF EXISTS members;
CREATE TABLE members
(
            member_id VARCHAR(10) PRIMARY KEY,
            member_name VARCHAR(30),
            member_address VARCHAR(30),
            reg_date DATE
);



-- Create table "Books"
DROP TABLE IF EXISTS books;
CREATE TABLE books
(
            isbn VARCHAR(50) PRIMARY KEY,
            book_title VARCHAR(80),
            category VARCHAR(30),
            rental_price DECIMAL(10,2),
            status VARCHAR(10),
            author VARCHAR(30),
            publisher VARCHAR(30)
);



-- Create table "IssueStatus"
DROP TABLE IF EXISTS issued_status;
CREATE TABLE issued_status
(
            issued_id VARCHAR(10) PRIMARY KEY,
            issued_member_id VARCHAR(30),
            issued_book_name VARCHAR(80),
            issued_date DATE,
            issued_book_isbn VARCHAR(50),
            issued_emp_id VARCHAR(10),
            FOREIGN KEY (issued_member_id) REFERENCES members(member_id),
            FOREIGN KEY (issued_emp_id) REFERENCES employees(emp_id),
            FOREIGN KEY (issued_book_isbn) REFERENCES books(isbn) 
);



-- Create table "ReturnStatus"
DROP TABLE IF EXISTS return_status;
CREATE TABLE return_status
(
            return_id VARCHAR(10) PRIMARY KEY,
            issued_id VARCHAR(30),
            return_book_name VARCHAR(80),
            return_date DATE,
            return_book_isbn VARCHAR(50),
            FOREIGN KEY (return_book_isbn) REFERENCES books(isbn)
);

```

### 2. CRUD Operations

- **Create**: Inserted sample records into the `books` table.
- **Read**: Retrieved and displayed data from various tables.
- **Update**: Updated records in the `employees` table.
- **Delete**: Removed records from the `members` table as needed.

**Task 1. Create a New Book Record**
-- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"

```sql
INSERT INTO books(isbn, book_title, category, rental_price, status, author, publisher)
VALUES('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');
SELECT * FROM books;
```
**Task 2: Update an Existing Member's Address**

```sql
UPDATE members
SET member_address = '125 Oak St'
WHERE member_id = 'C103';
```

**Task 3: Delete a Record from the Issued Status Table**
-- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.

```sql
DELETE FROM issued_status
WHERE   issued_id =   'IS121';
```

**Task 4: Retrieve All Books Issued by a Specific Employee**
-- Objective: Select all books issued by the employee with emp_id = 'E101'.
```sql
SELECT * FROM issued_status
WHERE issued_emp_id = 'E101'
```


**Task 5: List Members Who Have Issued More Than One Book**
-- Objective: Use GROUP BY to find members who have issued more than one book.

```sql
SELECT
    issued_emp_id,
    COUNT(*)
FROM issued_status
GROUP BY 1
HAVING COUNT(*) > 1
```

### 3. CTAS (Create Table As Select)

- **Task 6: Create Summary Tables**: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt**

```sql
CREATE TABLE book_issued_cnt AS
SELECT b.isbn, b.book_title, COUNT(ist.issued_id) AS issue_count
FROM issued_status as ist
JOIN books as b
ON ist.issued_book_isbn = b.isbn
GROUP BY b.isbn, b.book_title;
```


### 4. Data Analysis & Findings

The following SQL queries were used to address specific questions:

Task 7. **Retrieve All Books in a Specific Category**:

```sql
SELECT * FROM books
WHERE category = 'Classic';
```

8. **Task 8: Find Total Rental Income by Category**:

```sql
SELECT 
    b.category,
    SUM(b.rental_price),
    COUNT(*)
FROM 
issued_status as ist
JOIN
books as b
ON b.isbn = ist.issued_book_isbn
GROUP BY category
```

9. **List Members Who Registered in the Last 180 Days**:
```sql
SELECT *
FROM members
WHERE DATEDIFF(DAY, reg_date, GETDATE()) <= 180
```

10. **List Employees with Their Branch Manager's Name and their branch details**:

```sql
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
```

Task 11. **Create a Table of Books with Rental Price Above a Certain Threshold**:
```sql
CREATE TABLE expensive_books AS
SELECT * FROM books
WHERE rental_price > 7.00;
```

Task 12: **Retrieve the List of Books Not Yet Returned**
```sql
SELECT * FROM issued_status as ist
LEFT JOIN
return_status as rs
ON rs.issued_id = ist.issued_id
WHERE rs.return_id IS NULL;
```

## Advanced SQL Operations

**Task 13: Identify Members with Overdue Books**  
Write a query to identify members who have overdue books (assume a 30-day return period). Display the member's_id, member's name, book title, issue date, and days overdue.

```sql
SELECT 
	ist.issued_member_id,
	m.member_name,
	bk.book_title,
	ist.issued_date,
	rs.return_date,
    DATEDIFF(DAY, ist.issued_date, GETDATE()) AS overdue_days
FROM members as m
JOIN issued_status AS ist
ON ist.issued_member_id = m.member_id
JOIN books as bk
ON bk.isbn = ist.issued_book_isbn
LEFT JOIN return_status AS rs
ON rs.issued_id = ist.issued_id
WHERE rs.return_date is NULL
AND  DATEDIFF(DAY, ist.issued_date, GETDATE()) > 30;
```


**Task 14: Update Book Status on Return**  
Write a query to update the status of books in the books table to "Yes" when they are returned (based on entries in the return_status table).


```sql

SELECT * FROM issued_status
SELECT * FROM return_status

--Stored Procedure

ALTER PROCEDURE updateBookStatus
@IssuedId nvarchar(40)
AS
BEGIN
	-- Declare a variable to hold the ISBN of the returned book
	DECLARE @ReturnedISBN nvarchar(50);
	DECLARE @BookTitle nvarchar(100);

	-- Get the ISBN from issued_status based on the issued_id
	SELECT @ReturnedISBN = issued_book_isbn
	FROM issued_status
	WHERE issued_id = @IssuedId;

	--Get the book title using ISBN
	SELECT @BookTitle = book_title
	FROM books
	WHERE isbn = @ReturnedISBN

	+-- Now update the status of the book to 'available'
	UPDATE books
	SET status = 'available'
	WHERE isbn = @ReturnedISBN;

	PRINT 'Thank you for returning the book "' + @BookTitle + '".';
END

--Testing Function
EXEC UpdateBookStatus @IssuedID = 'IS136';

SELECT * FROM books
WHERE isbn = '978-0-7432-7357-1';

```

**Task 15: Branch Performance Report**  
Create a query that generates a performance report for each branch, showing the number of books issued, the number of books returned, and the total revenue generated from book rentals.

```sql
SELECT
	b.branch_id,
	b.branch_address,
	COUNT(DISTINCT ist.issued_id) AS books_issued,
	COUNT(DISTINCT rs.return_id) AS books_returned,
	SUM(bk.rental_price) AS total_revenue
FROM branch AS b
LEFT JOIN employees AS e
	ON e.branch_id = b.branch_id
LEFT JOIN issued_status AS ist
	ON ist.issued_emp_id = e.emp_id
LEFT JOIN return_status AS rs
	ON rs.issued_id = ist.issued_id
LEFT JOIN books AS bk
	ON bk.isbn = ist.issued_book_isbn
GROUP BY 
	b.branch_id,
	b.branch_address
ORDER BY 
	total_revenue DESC;
```

**Task 16: CTAS: Create a Table of Active Members**  
Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members who have issued at least one book in the last 2 months.

```sql

SELECT *
INTO active_members
FROM members
WHERE member_id	IN (SELECT
			DISTINCT issued_member_id
			FROM issued_status		
			WHERE
			issued_date >= DATEADD(MONTH, -2, GETDATE())
			);

SELECT * FROM active_members			

```

**Task 17: Find Employees with the Most Book Issues Processed**  
Write a query to find the top 3 employees who have processed the most book issues. Display the employee name, number of books processed, and their branch.

```sql
SELECT TOP 3
	e.emp_name AS employee_name,
	COUNT(ist.issued_id) AS books_processed,
	b.branch_address
FROM employees AS e
JOIN issued_status AS ist
	ON e.emp_id = ist.issued_emp_id
JOIN branch AS b
	ON e.branch_id = b.branch_id
GROUP BY e.emp_name, b.branch_address	
ORDER BY books_processed DESC
```

**Task 18: Identify Members Issuing High-Risk Books**  
Write a query to identify members who have issued books more than twice with the status "damaged" in the books table. Display the member name, book title, and the number of times they've issued damaged books.    

```sql
SELECT 
	m.member_name,
	--b.book_title,
	COUNT(*) AS damaged_status
FROM	
	issued_status ist
JOIN
	members m
ON ist.issued_member_id = m.member_id
JOIN
	books b
ON 	ist.issued_book_isbn = b.isbn
JOIN 
	return_status rs
ON ist.issued_id = rs.issued_id
WHERE book_quality = 'Damaged'
GROUP BY 
	m.member_name
HAVING
	COUNT(*) > 2;
```

**Task 19: Stored Procedure**
Objective:
Create a stored procedure to manage the status of books in a library system.
Description:
Write a stored procedure that updates the status of a book in the library based on its issuance. The procedure should function as follows:
The stored procedure should take the book_id as an input parameter.
The procedure should first check if the book is available (status = 'yes').
If the book is available, it should be issued, and the status in the books table should be updated to 'no'.
If the book is not available (status = 'no'), the procedure should return an error message indicating that the book is currently not available.

```sql

CREATE PROCEDURE sp_IssueBook
	@book_id nvarchar(40)
AS
BEGIN
	--Check if the book exists and is available
	IF EXISTS (
		SELECT 1
		FROM books
		WHERE isbn = @book_id AND status = 'yes'
	)
	BEGIN
		--Update book status to 'no'
		UPDATE books
		SET status = 'no'
		WHERE isbn = @book_id;
	END
	ELSE
	BEGIN
		--Book is not available
		 RAISERROR('Book is currently not available for issue.', 16, 1);
	END
END;

EXEC sp_IssueBook @book_id = '978-0-06-025492-6'

```

## Reports

- **Database Schema**: Detailed table structures and relationships.
- **Data Analysis**: Insights into book categories, employee salaries, member registration trends, and issued books.
- **Summary Reports**: Aggregated data on high-demand books and employee performance.

## Conclusion

This project demonstrates the application of SQL skills in creating and managing a library management system. It includes database setup, data manipulation, and advanced querying, providing a solid foundation for data management and analysis.

## How to Use

1. **Clone the Repository**: Clone this repository to your local machine.
   ```sh
   git clone https://github.com/BabaKaElijah/library_system_management
   ```

2. **Set Up the Database**: Execute the SQL scripts in the `database_setup.sql` file to create and populate the database.
3. **Run the Queries**: Use the SQL queries in the `analysis_queries.sql` file to perform the analysis.
4. **Explore and Modify**: Customize the queries as needed to explore different aspects of the data or answer additional questions.

## Author - Ellias Sithole

Thank you for your interest in this project!
