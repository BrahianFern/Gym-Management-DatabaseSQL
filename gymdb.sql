create database if not exists gymdb;

use gymdb;

create table member(
memberID varchar(100) PRIMARY KEY,
phone varchar(100) NOT NULL,
email varchar(100) NOT NULL,
membername varchar(100) NOT NULL,
date_ofbirth varchar(100) NOT NULL);

Alter table member
change date_ofbirth dateofbirth varchar(100);

select * from member;
drop table member;

insert into member(memberID, phone, email, membername, date_ofbirth)
values(1000, '401-896-7312', 'marcelg@gmail.com', 'Marcel Guzman', '1999-03-31'),
(2000, '401-342-0670', 'andreah@gmail.com', 'Andrea Hernandez', '2003-08-15'),
(1001, '401-908-1924', 'colew@gmail.com', 'Cole Winter', '2004-06-04'),
(1002, '401-878-6172', 'jakep@gmail.com', 'Jake Pope', '1989-01-01'),
(2001, '401-590-0343', 'allisona@gmail.com', 'Allison Arth', '2001-02-19');

Alter table member
add column gender varchar(100);
set SQL_SAFE_UPDATES = 0;

update member
set gender = 'Male' where SUBSTRING(memberID, 1, 1) = 1;

update member
set gender = 'Female' where SUBSTRING(memberID, 1, 1) = 2;

select * from member;
drop table member;

create table trainer(
trainerID varchar(100) PRIMARY KEY,
name varchar(100) NOT NULL,
phone varchar(100) NOT NULL);

Alter table trainer
change name trainername varchar(100);

insert into trainer(trainerID, trainername, phone)
values(100, 'Jackson Hunt', '401-811-1906'),
(200, 'Misty Thor', '856-909-1586'),
(101, 'Hector Ramirez', '919-340-2421'),
(201, 'Berenice Morth', '717-841-9098');

select * from trainer;
drop table trainer;

create table class(
classID varchar(100) PRIMARY KEY,
trainerID varchar(100), FOREIGN KEY(trainerID) references trainer(trainerID),
capacity varchar(100) NOT NULL,
classname varchar(100) NOT NULL,
scheduletime varchar(100) NOT NULL);

insert into class(classID, trainerID, capacity, classname, scheduletime)
values(1, 100, 20, 'Yoga', '8:30 A.M.'),
(2, 200, 15, 'Zumba', '9:00 A.M.'),
(3, 101, 8, 'Heavy Lifting', '12:00 A.M.'),
(4, 201, 13, 'Cardio', '10:00 A.M.');

select * from class;
drop table class;

create table payment(
paymentID varchar(100) PRIMARY KEY,
memberID varchar(100), FOREIGN KEY(memberID) references member(memberID),
amount varchar(100) NOT NULL,
paymentdate varchar(100) NOT NULL,
paymentmethod varchar(100) NOT NULL);

insert into payment(paymentID, memberID, amount, paymentdate, paymentmethod)
values('P8019', 1001, 35, '2025-08-01', 'Credit Card'),
('P1296', 2000, 15, '2025-07-29', 'Debit Card'),
('P4820', 1000, 10, '2025-03-15', 'Gift Card'),
('P9712', 2001, 30, '2025-08-06', 'Cash');

select * from payment;
drop table payment;

create table package(
packageID varchar(100) PRIMARY KEY,
price varchar(100) NOT NULL,
duration varchar(100) NOT NULL,
packagename varchar(100) NOT NULL);

insert into package(packageID, price, duration, packagename)
values('K1', '10', '6 months', 'Sweat Membership'),
('K2', '20', '2 years', 'Fit Membership'),
('K3', '35', 'Until Canceled', 'Monster Membership');

select * from package;
drop table package;

create table membership(
membershipID INT AUTO_INCREMENT PRIMARY KEY,
memberID varchar(100), FOREIGN KEY(memberID) references member(memberID),
packageID varchar(100), FOREIGN KEY(packageID) references package(packageID),
startdate varchar(100) NOT NULL,
enddate varchar(100) NOT NULL);

insert into membership(memberID, packageID, startdate, enddate)
values(1000, 'K1', '2025-03-15', '2025-09-15'),
(1001, 'K3', '2022-01-08', 'Until Canceled'),
(1002, 'K1', '2021-07-09', '2022-01-09'),
(2000, 'K3', '2024-09-10', 'Until Canceled'),
(2001, 'K2', '2023-12-09', '2025-12-09');

select * from membership;
drop table membership;

create table workoutplan(
planID varchar(100) PRIMARY KEY,
trainerID varchar(100), FOREIGN KEY(trainerID) references trainer(trainerID),
duration varchar(100) NOT NULL,
planname varchar(100) NOT NULL);

insert into workoutplan(planID, trainerID, duration, planname)
values('PLAN001', '100', '6 Weeks', 'Flexibility'),
('PLAN209', '200', '12 Weeks', 'Cutting'),
('PLAN800', '101', '10 Weeks', 'Bulking'),
('PLAN302', '201', '2 Weeks', 'Mind Muscle Connection');

select * from workoutplan;
drop table workoutplan;

create table attendance(
attendanceID varchar(100) PRIMARY KEY,
memberID varchar(100), FOREIGN KEY(memberID) references member(memberID),
trainerID varchar(100), FOREIGN KEY(trainerID) references trainer(trainerID),
classID varchar(100), FOREIGN KEY(classID) references class(classID));

insert into attendance(attendanceID, memberID, trainerID, classID)
values('511', 1000, 101, 1),
('520', 2000, 200, 3);

select a.attendanceID, a.memberID, m.membername
from attendance a
join member m
where m.memberID = a.memberID;

select * from attendance;
drop table attendance;

create view memberduration
as
select m.startdate, m.memberID, o.membername,
curdate() as today,
datediff(curdate(), startdate) as days_asmember
from membership m
join
member o
on o.memberID = m.memberID
where enddate like 'U%' or enddate > curdate();

drop view memberduration;

select * from memberduration;

Delimiter //

create procedure memberpackage(IN package_input varchar(100))
Begin
select m.memberID, m.packageID, p.packagename, o.membername
from membership m
join member o ON m.memberID = o.memberID
join package p ON m.packageID = p.packageID
where m.packageID = package_input;
End //

drop procedure memberpackage;

Call memberpackage('K1');

create view memberpackages
as 
select m.packageID, p.packagename, o.membername
from membership m
join member o ON m.memberID = o.memberID
join package p ON m.packageID = p.packageID;

select * from memberpackages;

create view male_members
as
select membername, gender
from member
where memberID like '1%';

select * from male_members;
drop view male_members;

create view female_members
as
select membername, gender
from member
where memberID like '2%';

select * from female_members;
drop view female_members;

create view memberage
as
select date_ofbirth, membername,
floor(datediff(curdate(), date_ofbirth) / 365) as age
from member;

select * from memberage;
drop view memberage;

select * from memberage
where age > 21;

select * from member;
select * from membership;
select * from package;
select * from class;
select * from trainer;
select * from attendance;
select * from workoutplan;
select * from payment;


create user 'gymstaff'@'localhost' identified by 'securepass';


grant select on member to 'gymstaff'@'localhost';

show grants for 'gymstaff@localhost';





