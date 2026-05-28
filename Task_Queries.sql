select * from books ;
select * from branch;
select * from employees;
select * from issued_status;
select * from members;
select * from return_status;
				
-- ***CRUD OPERATION ON library_project database tables***---
-- ****Task 1. Create a New Book Record****
-- "978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.')"
Insert into books (isbn,book_title,category,rental_price,status,author,publisher) values 
('978-1-60129-456-2', 'To Kill a Mockingbird', 'Classic', 6.00, 'yes', 'Harper Lee', 'J.B. Lippincott & Co.');
select * from books where isbn='978-1-60129-456-2';

-- ****Task 2: Update an Existing Member's Address****
update members set member_address = '244 center st' where member_id= 'C101';
select * from members where member_id = 'C101';

-- ****Task 3: Delete a Record from the Issued Status Table****
-- Objective: Delete the record with issued_id = 'IS121' from the issued_status table.
delete from issued_status where issued_id='IS121';
select * from issued_status where issued_id='IS121';

-- ****Task 4: Retrieve All Books Issued by a Specific Employee****
-- Objective: Select all books issued by the employee with emp_id = 'E101'.
select * from books join issued_status on books.isbn = issued_status.issued_book_isbn 
					join employees on employees.emp_id = issued_status.issued_emp_id where employees.emp_id='E101';
                    
-- ****Task 5: List members Who Have Issued More Than One Book****
-- Objective: Use GROUP BY to find members who have issued more than one book.
select member_id,member_name, count(issued_book_isbn) as books_issued from issued_status 
                    join members on  members.member_id = issued_status.issued_member_id
                        group by member_id,member_name having count(issued_book_isbn) >1;
                        
                        


