create database library;
use library;

create table publisher(
PublisherName varchar(255) primary key,
PublisherAddress varchar(255),
PublisherPhone varchar(255));

create table borrower(
CardNo smallint primary key,
BorrowerName varchar(255),
BorrowerAddress varchar(255),
BorrowerPhone varchar(255));


create table library_branch(
branchid tinyint primary key auto_increment,
BranchName varchar(255) ,
BranchAddress varchar(255));


create table book(
BookID tinyint primary key,
Title varchar(255),
PublisherName varchar(255),
foreign key (PublisherName) references publisher(PublisherName) on update cascade on delete cascade);

create table book_loans(
loan_id tinyint unsigned primary key auto_increment,
BookID tinyint , 
BranchID tinyint,
CardNo smallint,
DateOut varchar(255),
DueDate varchar(255),
foreign key (bookid) references book(BookId) on update cascade on delete cascade,
foreign key (branchid) references library_branch(branchid) on update cascade on delete cascade,
foreign key (CardNo) references borrower(CardNo) on update cascade on delete cascade);


show tables;

create table authors(
authorid tinyint primary key auto_increment,
BookID tinyint ,
AuthorName varchar(255),
foreign key (bookid) references book(bookid) on update cascade on delete cascade);



create table book_copies(
copiesid tinyint primary key auto_increment,
BookID tinyint,
BranchID tinyint,
No_Of_Copies tinyint,
foreign key (bookid) references book(bookid) on update cascade on delete cascade,
foreign key (branchid) references library_branch(branchid) on update cascade on delete cascade);

show tables;

select * from authors;
select * from book;
select * from book_copies;
select * from Book_loans;
select * from borrower;
select * from library_branch;
select * from publisher;

-- task questions

-- 1) How many copies of the book titled "The Lost Tribe" are owned by the library branch whose name is "Sharpstown"?


with cte1 as (select * from book inner join book_copies using (bookid)),
cte2 as (select * from cte1 inner join library_branch using (branchid))
select title,no_of_copies, branchname from cte2 where title = 'The Lost Tribe' and branchname = 'sharpstown';


-- 2)  How many copies of the book titled "The Lost Tribe" are owned by each library branch?


select b.No_Of_Copies, a.title, c.branchname from book a inner join book_copies b using (bookid)
inner join library_branch c using (branchid)
where a.title like 'the lost tribe'
group by a.title, c.branchname, b.no_of_copies;

-- 3) Retrieve the names of all borrowers who do not have any books checked out.

select a.borrowername from borrower a
left join 
book_loans b
using (cardNo)
where DueDate is  null;

-- 4) For each book that is loaned out from the "Sharpstown" branch and whose DueDate is 2/3/18, 
-- retrieve the book title, the borrower's name, and the borrower's address. 

 with cte1 as (select * from book inner join book_loans using (bookid)),
cte2 as (select * from cte1 inner join library_branch using (branchid)),
cte3 as (select * from cte2 inner join borrower using (cardno))
select title, borrowername, borroweraddress from cte3 where  branchname = 'sharpstown' and duedate like '2/3/18';



-- 4) For each book that is loaned out from the "Sharpstown" branch and whose DueDate is 2/3/18, 
-- retrieve the book title, the borrower's name, and the borrower's address. 

select  a.title, d.BorrowerName, str_to_date(b.DueDate, "%m/%d/%y") as duedate, d.BorrowerAddress, c.branchname from book a left join book_loans b using (bookid)
inner join library_branch c using (branchid)
inner join borrower d using (cardno)
where str_to_date(b.DueDate, "%m/%d/%y") = '2018-02-03' and branchname = 'sharpstown';

-- 5) For each library branch, retrieve the branch name and the total number of books loaned out from that branch.

with cte1 as (
    select b.bookid, bl.branchid
    from book_loans bl
    inner join book b  on bl.bookid = b.bookid
)
select lb.branchname, count(cte1.bookid) AS total_books_loaned from cte1
inner join library_branch lb on cte1.branchid = lb.branchid
group by  lb.branchname;


-- 6) Retrieve the names, addresses, and number of books checked out for all 
-- borrowers who have more than five books checked out.


select count(b.bookid) as count , c.borrowername, c.borroweraddress  from book a left join book_loans b using (bookid)
left join borrower c using (cardno)
group by c.cardno, c.borrowername, c.borroweraddress
having count(b.bookid) > 5
order by count desc;


-- 7) For each book authored by "Stephen King", retrieve the 
-- title and the number of copies owned by the library branch whose name is "Central".

with cte1 as (select * from authors inner join book using (bookid)),
cte2 as (select * from cte1  inner join book_loans using (bookid)),
cte3 as (select * from cte2 inner join library_branch using (branchid))
select title,count(title) as copies_owned   from cte3
where authorname like 'stephen%' and branchname like '%central'
group by title;




   
