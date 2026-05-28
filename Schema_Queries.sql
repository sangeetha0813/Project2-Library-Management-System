create  database library_project;
use library_project;
create table branch
 ( 
   branch_id varchar(10) primary key,
   manager_id varchar(10),
   branch_address varchar(55),
   contact_no varchar(10)
  );
  
  alter table branch
  modify column contact_no varchar(20);
  
  ALTER TABLE issued_status
MODIFY issued_book_isbn VARCHAR(25);
  
  create table employees
  (
    emp_id varchar(10) primary key,
    emp_name varchar(25),
    position varchar(15),
    salary int,
    branch_id varchar(15) );
    
    create table books
    (
     isbn varchar(20) primary key,
     book_title varchar(75),
     category varchar(10),
     rental_price float,
     status varchar(15),
     author varchar(35),
     publisher varchar(55)
     );
     
     create table members
     (
      member_id varchar(10) primary key,
      member_name varchar(25),
      member_address varchar(75),
      reg_date date);
      
     create table issued_status
     (
      issued_id varchar(10) primary key,
      issued_member_id varchar(10),
      issued_book_name varchar(75),
      issued_date date,
      issued_book_isbn varchar(10),
      issued_emp_id varchar(10));
      
      create table return_status
      (
       return_id varchar(10) primary key,
       issued_id varchar(10),
       return_book_name varchar(75),
       return_date date,
       return_book_isbn varchar(20)
     );  
     
     alter table issued_status 
     add constraint fk_members
     foreign key (issued_member_id)
     references members(member_id);
     
     alter table issued_status
     add constraint fk_books
     foreign key(issued_book_isbn)
     references books(isbn);
     
     alter table issued_status
     add constraint fk_employees
     foreign key(issued_emp_id)
     references employees(emp_id);
     
     -- return_id	issued_id	return_book_name	return_date	return_book_isbn (return_status)
-- issued_id	issued_member_id	issued_book_name	issued_date	issued_book_isbn	issued_emp_id (issued_status)

     
     alter table return_status
     add constraint fk_issue
	 foreign key  (issued_id)
	 references issued_status(issued_id);
     
	alter table employees
	add constraint fk_branch
	foreign key  (branch_id)
	references branch(branch_id);