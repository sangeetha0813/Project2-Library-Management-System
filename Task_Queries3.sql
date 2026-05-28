## Advanced SQL Operations
##**Task 13: Identify Members with Overdue Books**  
## Write a query to identify members who have overdue books (assume a 30-day return period). 
## & Display the member's_id, member's name, book title, issue date, and days overdue.
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
-- -------------------------------------------------------------
-- **Task 14: Update Book Status on Return**  
## Write a query to update the status of books in the books table to "Yes" when they are returned (based on entries in the return_status table)

-- Create Stored Procedure [Task of this stored procedure is as soon as someone enters a record in the return_status table , 
-- it should reflect in the book table with the status changing to 'yes']
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






