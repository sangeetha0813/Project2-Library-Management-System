# Project2-Library-Management-System-Mysql
## Project Overview
This project demonstrates the implementation of a Library Management System using SQL. It includes creating and managing tables, performing CRUD operations, and executing advanced SQL queries.
## Objectives

1. **Set up the Library Management System Database**: Create and populate the database with tables for branches, employees, members, books, issued status, and return status.
2. **CRUD Operations**: Perform Create, Read, Update, and Delete operations on the data.
3. **CTAS (Create Table As Select)**: Utilize CTAS to create new tables based on query results.
4. **Advanced SQL Queries**: Develop complex queries to analyze and retrieve specific data.
5. **Stored Procedures** : Created stored procedures to automate common library operations such as issuing books, returning books, and calculating overdue fines and branch performance report.

## Project Structure

### 1. Database Setup
- **Database Creation**: Created a database named `library_project`.
- **Table Creation**: Created tables for branches, employees, members, books, issued status, and return status. Each table includes relevant columns and relationships.
```sql
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

****Task 1. Create a New Book Record****
```sql
Insert into books (isbn,book_title,category,rental_price,status,author,publisher) values 
('978-0-7432-7356-5', 'The Secret', 'Self-Help', 4 , 'yes', 'Rhonda Byrne', 'Atria Books');
select * from books where isbn='978-0-7432-7356-5';
```
****Task 2: Update an Existing Member's Address****
```sql
update members set member_address = '244 center st' where member_id= 'C101';
select * from members where member_id = 'C101';
```
****Task 3: Delete a Record from the Issued Status Table****

    Objective: Delete the record with issued_id = 'IS121' from the issued_status table
```sql
delete from issued_status where issued_id='IS121';
select * from issued_status where issued_id='IS121';
```
****Task 4: Retrieve All Books Issued by a Specific Employee****

    Objective: Select all books issued by the employee with emp_id = 'E101'
```sql
select * from books join issued_status on books.isbn = issued_status.issued_book_isbn 
        join employees on employees.emp_id = issued_status.issued_emp_id where employees.emp_id='E101';
  ```             
****Task 5: List members Who Have Issued More Than One Book****

    Objective: Use GROUP BY to find members who have issued more than one book
```sql
select member_id,member_name, count(issued_book_isbn) as books_issued from issued_status 
                    join members on  members.member_id = issued_status.issued_member_id
                        group by member_id,member_name having count(issued_book_isbn) >1;
```
                      ###3. CTAS (Create Table As Select)
****Task 6: Create Summary Tables** 

    Objective: Use CTAS to generate new tables based on query results - each book and total book issued count
```sql   
 select * from books ;
 create table book_issue_summary as
 select books.isbn,books.book_title, count(issued_status.issued_book_isbn) as issued_book_COunt from books 
 join issued_status on books.isbn=issued_status.issued_book_isbn
 group by books.isbn,books.book_title;
 ```
                     ### 4. Data Analysis & Findings
****Task 7. **Retrieve All Books in a Specific Category****

    Objective:The following SQL queries were used to address specific questions
```sql
select * from books where category='Classic';
```                        
****Task 8: Find revenue generated from issued/rented books by category****
```sql
select b.category , sum(rental_price) as Total_Rental,count(*) as total_books_issued from issued_status as iss_st
join books as b on b.isbn = iss_st.issued_book_isbn
group by category;                                            
```
****Task 9. List Members Who Registered in the Last 180 Days****
```sql
select * from members where reg_date < current_date()- interval 180 day;
```
****Task 10. List Employees with Their Branch Manager's Name and their branch details****
```sql
select emp.emp_id, emp.emp_name,emp.position,emp.salary,branch.branch_id,
branch.branch_address,branch.manager_id,m.emp_name as manager_name from branch 
join employees as emp on emp.branch_id = branch.branch_id
join employees as m on m.emp_id = branch.manager_id;
```
***Task 11. Create a Table of Books with Rental Price Above a Certain Threshold****
```sql  
create table books_threshold as
select * from books where rental_price > 5 ;
```
****Task 12: Retrieve the List of Books Not Yet Returned****
```sql
select * from issued_status left join return_status on issued_status.issued_id= return_status.issued_id
where return_status.return_id is null;

                ### 5. Advanced SQL Operations
```  
****Task 13: Identify Members with Overdue Books****

Objective: Write a query to identify members who have overdue books (assume a 30-day return period) & 
Display the member's_id, member's name, book title, issue date, and days overdue
```sql
select i.issued_member_id, m.member_name,bk.book_title,i.issued_date,
curdate()-i.issued_date as overduedays 
from issued_status as i
join members as m
on i.issued_member_id = m.member_id
join books as bk
on bk.isbn = i.issued_book_isbn
left join return_status as r 
on r.issued_id = i.issued_id
where r.return_date is null and
    i.issued_date < curdate() - interval 30 day
order by 1
```
****Task 14: Update Book Status on Return****

    Objective: Write a query to update the status of books in the books table to "Yes" 
	           when they are returned (based on entries in the return_status table)
    Create Stored Procedure: Task of this stored procedure is, as soon as someone enters a record in the return_status table,
	                         it should reflect in the book table with the status changing to 'yes'
 ```sql    
delimiter $$
create procedure add_return_records
(
 in p_issued_id varchar(10)
 )

begin
  Declare v_isbn varchar (50);
  Declare v_book_name varchar (80);
  Declare v_return_id varchar(10);
  Declare v_max_id int;
      
         -- Step 1: Get ISBN from issued table
    select issued_book_isbn
	into v_isbn
    from issued_status
    where issued_id=p_issued_id;
        -- Step 2: Get book name from books table
    select book_title
    into v_book_name
    from books
    where isbn = v_isbn;    
     -- Step 3: Generate numeric part of return ID dynamically
    select max(cast(substring(return_id,3) as unsigned))
    into v_max_id
    from return_status;
    -- Step 4: Handle NULL (first record case)
    IF v_max_id IS NULL THEN
        SET v_max_id = 120;
    END IF;
    -- Step 5: Create RS130 format ID
    SET v_return_id = CONCAT('RS', v_max_id + 1);

    -- insert record to return table 
        Insert into return_status 
         (return_id,issued_id,return_book_name,return_date, return_book_isbn)
        values
         (v_return_id,p_issued_id,v_book_name, current_date(), v_isbn);
     
     -- Update the book table status for the returned book
            update books
            set status = 'yes'
            where isbn=v_isbn;
     -- Acknowledgement note       
            select concat(" Thank you for returning the book: ", v_book_name) as message;
end  $$
delimiter ;

call add_return_records('IS107')
```
****Task 15: Branch Performance Report**** 

Create a query that generates a performance report for each branch,showing the number of books issued, the number of books returned, and the total revenue generated from book rentals.
```sql
create table Branch_Reports as
select 
b.branch_id, b.manager_id,
count(distinct ist.issued_id) 
as Total_books_issued,count(distinct rst.return_id) 
as Total_books_returned,sum(rental_price) 
as Total_revenue_generated
from issued_status as ist 
join employees as e
on e.emp_id = ist.issued_emp_id 
join branch as b
on e.branch_id = b.branch_id
left join return_status as rst 
on ist.issued_id =  rst.issued_id
join books as bk 
on ist.issued_book_isbn = bk.isbn 
group by b.branch_id, b.manager_id;
```
****Task 16: CTAS: Create a Table of Active Members**** 

    Objective: Use the CREATE TABLE AS (CTAS) statement to create a new table active_members containing members 
	           who have issued at least one book in the last 2 months.
```sql
create table active_members as
select * from members 
where member_id in 
(select distinct issued_member_id from issued_status 
		where issued_date >= curdate() - Interval 2 month) ;
        
   select * from active_members;
```   
****Task 17: Find Employees with the Most Book Issues Processed****

Write a query to find the top 3 employees who have processed the most book issues. Display the employee name,number of books processed, and their branch.
```sql
with cte as
(select e. emp_id , e.emp_name, b.branch_id, count(ist.issued_book_isbn) as Books_processesed,  
dense_rank() over (order by count(ist.issued_book_isbn) desc) as dns_rnk
from issued_status as ist
join employees as e on e.emp_id = ist.issued_emp_id 
join branch as b on e.branch_id = b.branch_id group by 1,2,3 )
select * from cte where dns_rnk <=3  ;
```
****Task 18: Book availability status****

   Objective: Create a stored procedure to manage the status of books in a library system.
   Description: Write a stored procedure that updates the status of a book in the library based on its issuance. 
            The procedure should function as follows:
			The stored procedure should take the book_id as an input parameter.
			The procedure should first check if the book is available (status = 'yes').
			If the book is available, it should be issued, and the status in the books table should be updated to 'no'.
			If the book is not available (status = 'no'), the procedure should return an error message indicating that the book is currently not available.
```sql
Delimiter $$
create procedure Book_availability
( 
   in p_issued_id varchar(10),
   in p_issued_member_id varchar(10),
   in p_issued_book_name varchar(80),
   in p_issued_book_isbn varchar(50),
   in p_issued_emp_id varchar(10)
   )

Begin
  declare v_status varchar(10);
  
   -- Get the particular book 
  select status into v_status from books
  where isbn = p_issued_book_isbn;
   -- check avaialbility status
   if v_status = 'yes' then 
   -- insert the book record issue into issued_status table
 Insert into issued_status
 (
   issued_id, 
   issued_member_id, 
   issued_book_name, 
   issued_date, 
   issued_book_isbn, 
   issued_emp_id)
values(
   p_issued_id,
   p_issued_member_id,
   p_issued_book_name,
   current_date(),
   p_issued_book_isbn,
   p_issued_emp_id);
 -- update book status
	  update books 
	  set status = 'No'
	  where isbn= p_issued_book_isbn ;
 
  select concat(p_issued_book_name, 'Book issued successfully') as message;
 
else 
  select concat(  'Sorry,',p_issued_book_name,' is currently not available') as message;
  
 end if; 
end $$

delimiter ;

CALL Book_availability
(
    'IS141',
    'C101',
    'Where the Wild Things Are',
    '978-0-06-025492-6',
    'E101'
);
```
****Task 19: Overdue books and fines****

    Objective: Create a CTAS (Create Table As Select) query to identify overdue books and calculate fines
    Description: Write a CTAS query to create a new table that lists each member and the books they have issued 
	             but not returned within 30 days. 
	Table structure: Number of overdue books, total fines with each day's fine calculated at $0.50 
	                 & number of books issued by each member.
    Table columns: Member ID,Number of overdue books,Total fines	
```sql
create table over_due_books 
select 
   m.member_id, 
   count(ist.issued_book_isbn) as overdue_books,
   sum(datediff (curdate(),issued_date))  as over_due_days,
   Round(sum(datediff (curdate(),issued_date) * 0.50),2) as total_fine  
from issued_status as ist
join members as m on ist.issued_member_id = m .member_id
left join return_status as rst on ist.issued_id = rst.issued_id
where rst.issued_id is null and ist.issued_date <= curdate() - interval 30 day 
group by m.member_id;
```


