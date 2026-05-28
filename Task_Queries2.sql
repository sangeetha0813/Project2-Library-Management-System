--  ### 3. CTAS (Create Table As Select)
--  **Task 6: Create Summary Tables**: Used CTAS to generate new tables based on query results - each book and total book_issued_cnt**    
select * from books ;
create table book_issue_summary as
select books.isbn,books.book_title, count(issued_status.issued_book_isbn) as issued_book_COunt from books 
join issued_status on books.isbn=issued_status.issued_book_isbn
group by books.isbn,books.book_title;
##*********************************************************
### 4. Data Analysis & Findings
##The following SQL queries were used to address specific questions:
##Task 7. **Retrieve All Books in a Specific Category**:
select * from books where category='Classic';

## **Task 8: Find revenue generated from issued/rented books by category
select b.category , sum(rental_price) as Total_Rental,count(*) as total_books_issued from issued_status as iss_st
join books as b on b.isbn = iss_st.issued_book_isbn
group by category;

-- 9. **List Members Who Registered in the Last 180 Days**:
select * from members where reg_date < current_date()- interval 180 day;

-- 10. **List Employees with Their Branch Manager's Name and their branch details**:
select emp.emp_id, emp.emp_name,emp.position, emp.salary,branch.branch_id,branch.branch_address,branch.manager_id,m.emp_name as manager_name from branch 
   join employees as emp on emp.branch_id = branch.branch_id
   join employees as m on m.emp_id = branch.manager_id;
  
-- Task 11. **Create a Table of Books with Rental Price Above a Certain Threshold**:  
create table books_threshold as
select * from books where rental_price > 5 ;

-- Task 12: **Retrieve the List of Books Not Yet Returned**
select * from issued_status left join return_status on issued_status.issued_id= return_status.issued_id
where return_status.return_id is null;
 
   