-- Scratch queries for the Gym Management Database.
-- Run gymdb_setup.sql first. Nothing here changes the data unless you
-- uncomment a DROP line at the bottom.

USE gymdb;

-- Look at every table
SELECT * FROM member;
SELECT * FROM membership;
SELECT * FROM package;
SELECT * FROM class;
SELECT * FROM trainer;
SELECT * FROM attendance;
SELECT * FROM workoutplan;
SELECT * FROM payment;

-- Who attended which class
SELECT a.attendanceID, a.memberID, m.membername
FROM attendance a
JOIN member m ON m.memberID = a.memberID;

-- Views
SELECT * FROM memberduration;
SELECT * FROM memberpackages;
SELECT * FROM male_members;
SELECT * FROM female_members;
SELECT * FROM memberage;
SELECT * FROM memberage WHERE age > 21;

-- Stored procedure
CALL memberpackage('K1');

-- Check the staff user's permissions
SHOW GRANTS FOR 'gymstaff'@'localhost';

-- Cleanup (uncomment only what you want to remove)
-- DROP VIEW memberduration;
-- DROP VIEW memberpackages;
-- DROP VIEW male_members;
-- DROP VIEW female_members;
-- DROP VIEW memberage;
-- DROP PROCEDURE memberpackage;
-- DROP USER 'gymstaff'@'localhost';
