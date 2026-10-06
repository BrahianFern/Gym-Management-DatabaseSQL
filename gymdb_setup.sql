-- Gym Management Database: setup script
-- Safe to re-run: it rebuilds the whole database from scratch each time.
-- Usage: mysql -u root -p < gymdb_setup.sql

DROP DATABASE IF EXISTS gymdb;
CREATE DATABASE gymdb;
USE gymdb;

-- ---------- Tables ----------

CREATE TABLE member (
  memberID varchar(100) PRIMARY KEY,
  phone varchar(100) NOT NULL,
  email varchar(100) NOT NULL,
  membername varchar(100) NOT NULL,
  date_ofbirth varchar(100) NOT NULL,
  gender varchar(100)
);

CREATE TABLE trainer (
  trainerID varchar(100) PRIMARY KEY,
  trainername varchar(100) NOT NULL,
  phone varchar(100) NOT NULL
);

CREATE TABLE class (
  classID varchar(100) PRIMARY KEY,
  trainerID varchar(100),
  capacity varchar(100) NOT NULL,
  classname varchar(100) NOT NULL,
  scheduletime varchar(100) NOT NULL,
  FOREIGN KEY (trainerID) REFERENCES trainer(trainerID)
);

CREATE TABLE payment (
  paymentID varchar(100) PRIMARY KEY,
  memberID varchar(100),
  amount varchar(100) NOT NULL,
  paymentdate varchar(100) NOT NULL,
  paymentmethod varchar(100) NOT NULL,
  FOREIGN KEY (memberID) REFERENCES member(memberID)
);

CREATE TABLE package (
  packageID varchar(100) PRIMARY KEY,
  price varchar(100) NOT NULL,
  duration varchar(100) NOT NULL,
  packagename varchar(100) NOT NULL
);

CREATE TABLE membership (
  membershipID INT AUTO_INCREMENT PRIMARY KEY,
  memberID varchar(100),
  packageID varchar(100),
  startdate varchar(100) NOT NULL,
  enddate varchar(100) NOT NULL,
  FOREIGN KEY (memberID) REFERENCES member(memberID),
  FOREIGN KEY (packageID) REFERENCES package(packageID)
);

CREATE TABLE workoutplan (
  planID varchar(100) PRIMARY KEY,
  trainerID varchar(100),
  duration varchar(100) NOT NULL,
  planname varchar(100) NOT NULL,
  FOREIGN KEY (trainerID) REFERENCES trainer(trainerID)
);

CREATE TABLE attendance (
  attendanceID varchar(100) PRIMARY KEY,
  memberID varchar(100),
  trainerID varchar(100),
  classID varchar(100),
  FOREIGN KEY (memberID) REFERENCES member(memberID),
  FOREIGN KEY (trainerID) REFERENCES trainer(trainerID),
  FOREIGN KEY (classID) REFERENCES class(classID)
);

-- ---------- Sample data ----------

INSERT INTO member (memberID, phone, email, membername, date_ofbirth) VALUES
(1000, '401-896-7312', 'marcelg@gmail.com', 'Marcel Guzman', '1999-03-31'),
(2000, '401-342-0670', 'andreah@gmail.com', 'Andrea Hernandez', '2003-08-15'),
(1001, '401-908-1924', 'colew@gmail.com', 'Cole Winter', '2004-06-04'),
(1002, '401-878-6172', 'jakep@gmail.com', 'Jake Pope', '1989-01-01'),
(2001, '401-590-0343', 'allisona@gmail.com', 'Allison Arth', '2001-02-19');

-- Gender is derived from the first digit of memberID (1 = Male, 2 = Female)
UPDATE member SET gender = 'Male'   WHERE SUBSTRING(memberID, 1, 1) = '1';
UPDATE member SET gender = 'Female' WHERE SUBSTRING(memberID, 1, 1) = '2';

INSERT INTO trainer (trainerID, trainername, phone) VALUES
(100, 'Jackson Hunt', '401-811-1906'),
(200, 'Misty Thor', '856-909-1586'),
(101, 'Hector Ramirez', '919-340-2421'),
(201, 'Berenice Morth', '717-841-9098');

INSERT INTO class (classID, trainerID, capacity, classname, scheduletime) VALUES
(1, 100, 20, 'Yoga', '8:30 A.M.'),
(2, 200, 15, 'Zumba', '9:00 A.M.'),
(3, 101, 8, 'Heavy Lifting', '12:00 P.M.'),
(4, 201, 13, 'Cardio', '10:00 A.M.');

INSERT INTO payment (paymentID, memberID, amount, paymentdate, paymentmethod) VALUES
('P8019', 1001, 35, '2025-08-01', 'Credit Card'),
('P1296', 2000, 15, '2025-07-29', 'Debit Card'),
('P4820', 1000, 10, '2025-03-15', 'Gift Card'),
('P9712', 2001, 30, '2025-08-06', 'Cash');

INSERT INTO package (packageID, price, duration, packagename) VALUES
('K1', '10', '6 months', 'Sweat Membership'),
('K2', '20', '2 years', 'Fit Membership'),
('K3', '35', 'Until Canceled', 'Monster Membership');

INSERT INTO membership (memberID, packageID, startdate, enddate) VALUES
(1000, 'K1', '2025-03-15', '2025-09-15'),
(1001, 'K3', '2022-01-08', 'Until Canceled'),
(1002, 'K1', '2021-07-09', '2022-01-09'),
(2000, 'K3', '2024-09-10', 'Until Canceled'),
(2001, 'K2', '2023-12-09', '2025-12-09');

INSERT INTO workoutplan (planID, trainerID, duration, planname) VALUES
('PLAN001', '100', '6 Weeks', 'Flexibility'),
('PLAN209', '200', '12 Weeks', 'Cutting'),
('PLAN800', '101', '10 Weeks', 'Bulking'),
('PLAN302', '201', '2 Weeks', 'Mind Muscle Connection');

-- Trainer matches the trainer who teaches each class
INSERT INTO attendance (attendanceID, memberID, trainerID, classID) VALUES
('511', 1000, 100, 1),
('520', 2000, 101, 3);

-- ---------- Views ----------

-- Active members (membership not ended, or "Until Canceled") and days as a member
CREATE VIEW memberduration AS
SELECT m.startdate, m.memberID, o.membername,
       CURDATE() AS today,
       DATEDIFF(CURDATE(), m.startdate) AS days_asmember
FROM membership m
JOIN member o ON o.memberID = m.memberID
WHERE m.enddate LIKE 'U%' OR m.enddate > CURDATE();

CREATE VIEW memberpackages AS
SELECT m.packageID, p.packagename, o.membername
FROM membership m
JOIN member o ON m.memberID = o.memberID
JOIN package p ON m.packageID = p.packageID;

CREATE VIEW male_members AS
SELECT membername, gender FROM member WHERE memberID LIKE '1%';

CREATE VIEW female_members AS
SELECT membername, gender FROM member WHERE memberID LIKE '2%';

CREATE VIEW memberage AS
SELECT date_ofbirth, membername,
       TIMESTAMPDIFF(YEAR, date_ofbirth, CURDATE()) AS age
FROM member;

-- ---------- Stored procedure ----------

DELIMITER //
CREATE PROCEDURE memberpackage(IN package_input varchar(100))
BEGIN
  SELECT m.memberID, m.packageID, p.packagename, o.membername
  FROM membership m
  JOIN member o ON m.memberID = o.memberID
  JOIN package p ON m.packageID = p.packageID
  WHERE m.packageID = package_input;
END //
DELIMITER ;

-- ---------- Access control ----------
-- Replace 'change_me' with a real password before using this outside a demo.

CREATE USER IF NOT EXISTS 'gymstaff'@'localhost' IDENTIFIED BY 'change_me';
GRANT SELECT ON gymdb.member TO 'gymstaff'@'localhost';
