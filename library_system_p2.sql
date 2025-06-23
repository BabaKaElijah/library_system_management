-- ADVANCED TASK
  
/*
### Advanced SQL Operations

Task 13: Identify Members with Overdue Books
Write a query to identify members who have overdue books (assume a 30-day return period). Display the member's name, book title, issue date, and days overdue.


Task 14: Update Book Status on Return
Write a query to update the status of books in the books table to "available" when they are returned (based on entries in the return_status table).



Task 15: Branch Performance Report
Create a query that generates a performance report for each branch, showing the number of books issued, the number of books returned, and the total revenue generated from book rentals.


Task 16: CTAS: Create a Table of Active Members
Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members who have issued at least one book in the last 6 months.



Task 17: Find Employees with the Most Book Issues Processed
Write a query to find the top 3 employees who have processed the most book issues. Display the employee name, number of books processed, and their branch.


Task 18: Identify Members Issuing High-Risk Books
Write a query to identify members who have issued books more than twice with the status "damaged" in the books table. Display the member name, book title, and the number of times they've issued damaged books.    


Task 19: Stored Procedure
Objective: Create a stored procedure to manage the status of books in a library system.
    Description: Write a stored procedure that updates the status of a book based on its issuance or return. Specifically:
    If a book is issued, the status should change to 'no'.
    If a book is returned, the status should change to 'yes'.

Task 20: Create Table As Select (CTAS)
Objective: Create a CTAS (Create Table As Select) query to identify overdue books and calculate fines.

Description: Write a CTAS query to create a new table that lists each member and the books they have issued but not returned within 30 days. The table should include:
    The number of overdue books.
    The total fines, with each day's fine calculated at $0.50.
    The number of books issued by each member.
    The resulting table should show:
    Member ID
    Number of overdue books
    Total fines
*/

SELECT * FROM books
SELECT * FROM branch
SELECT * FROM employees
SELECT * FROM issued_status
SELECT * FROM members
SELECT * FROM return_status

--Task 13: Identify Members with Overdue Books
--Write a query to identify members who have overdue books (assume a 30-day return period). Display the member's name, book title, issue date, and days overdue.

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

--Task 14: Update Book Status on Return
--Write a query to update the status of books in the books table to "available" when they are returned (based on entries in the return_status table).

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

--Task 15: Branch Performance Report
--Create a query that generates a performance report for each branch,
--showing the number of books issued, the number of books returned, 
--and the total revenue generated from book rentals.

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


--Task 16: CTAS: Create a Table of Active Members
--Use the CREATE TABLE AS (CTAS) statement to create 
--a new table active_members containing members who have issued
--at least one book in the last 2 months.

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

--Task 17: Find Employees with the Most Book Issues Processed
--Write a query to find the top 3 employees who have processed 
--the most book issues. Display the employee name, 
--number of books processed, and their branch.

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

--Task 18: Identify Members Issuing High-Risk Books
--Write a query to identify members who have issued 
--books with more than 2 where the status "damaged" in the books table. 
--Display the member name, book title, and the number of times they've issued damaged books.

SELECT * FROM members
SELECT * FROM books
SELECT * FROM issued_status
SELECT * FROM return_status

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

--Task 19: Stored Procedure Objective: Create a stored procedure to
--manage the status of books in a library system. Description: 
--Write a stored procedure that updates the status of a book in the library based on its issuance. 

ALTER PROCEDURE sp_IssueBook
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