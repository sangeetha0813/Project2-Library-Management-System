## **Task 15: Branch Performance Report**  
-- Create a query that generates a performance report for each branch, 
-- showing the number of books issued, the number of books returned, and the total revenue generated from book rentals.
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
## ********************************************************************************** ##
-- **Task 16: CTAS: Create a Table of Active Members**  
-- Use the CREATE TABLE AS (CTAS) statement to create a new table active_members 
-- containing members who have issued at least one book in the last 2 months.
create table active_members as
select * from members 
where member_id in 
(select distinct issued_member_id from issued_status 
		where issued_date >= curdate() - Interval 2 month) ;
        
    --    select * from active_members;
  --  ------------------------------------------------------------------------------------------
-- **Task 17: Find Employees with the Most Book Issues Processed**  
-- Write a query to find the top 3 employees who have processed the most book issues. Display the employee name, 
-- number of books processed, and their branch.
with cte as
(select e. emp_id , e.emp_name, b.branch_id, count(ist.issued_book_isbn) as Books_processesed,  
dense_rank() over (order by count(ist.issued_book_isbn) desc) as dns_rnk
from issued_status as ist
join employees as e on e.emp_id = ist.issued_emp_id 
join branch as b on e.branch_id = b.branch_id group by 1,2,3 )
select * from cte where dns_rnk <=3  ;
-- ----------------------------------------------------------------------------------------------------------------
-- **Task 18: Stored Procedure**
-- Objective:
-- Create a stored procedure to manage the status of books in a library system.
-- Description:
-- Write a stored procedure that updates the status of a book in the library based on its issuance. The procedure should function as follows:
-- The stored procedure should take the book_id as an input parameter.
-- The procedure should first check if the book is available (status = 'yes').
-- If the book is available, it should be issued, and the status in the books table should be updated to 'no'.
-- If the book is not available (status = 'no'), the procedure should return an error message indicating that the book is currently not available.
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
-- ------------------------------------------------------------------------------
-- **Task 19: Create Table As Select (CTAS)**
-- Objective: Create a CTAS (Create Table As Select) query to identify overdue books and calculate fines.

-- Description: Write a CTAS query to create a new table that lists each member and 
--  the books they have issued but not returned within 30 days. The table should include:
--     The number of overdue books.
--     The total fines, with each day's fine calculated at $0.50.
--     The number of books issued by each member.
--     The resulting table should show:
--     Member ID
--     Number of overdue books
--     Total fines
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






