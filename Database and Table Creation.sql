-- SQL Project: DATABASE DESIGN FOR A SPORTS LEAGUE/ORGANIZATION

/* 
Project Overview
----------------

This project requires us to build a database to help us manage
the registration process for a sports league. The league offers 
a Recreational Daily Leagues and Field Rentals. These 
services are offered at various facilities, which can all be divided
into 3 small fields. The league owns and is responsible handling field rentals
in just one field. Here customers can reserve either 1/3 of the full field for a minimum duration of one hour.
The organization runs daily recreational leagues on Monday-Friday 6-12pm and 2-11pm during the weekends.
The goal is to create tables, procedures and triggers that allows the users and managers to interact with the database.
This involves managing creating bookings, inserting/modifying users and staff information and more.


INSTRUCTIONS
------------

The database should contain the following tables:
1. Users
2. Facilitators
3. Facilities
4. Fields
5. Prices
6. Leagues
7. League Signups
8. Field Rentals

TIME TO DESIGN THE DATABASE

*/

----------------------
-- DATABASE CREATION

-- Drop DB IF EXISTS
DROP DATABASE IF EXISTS league_DB;

-- Create the database for the league
CREATE DATABASE IF NOT EXISTS league_DB
DEFAULT CHARACTER SET utf8mb4;

-- Make database active
USE league_db;

------------------------

-- TABLE CREATION
/*
From the instruction given, there would be eight tables in the database. 
Here is a brief overview of each table and what each stores below:
1. Users - This table stores details of all registered members, including personal information like names, gender, date of birth, email, and contact details.
2. Facilitators - Table stores details of staff members managing or supervising activities, such as referees, managers, and coordinators.
3. Facilities - This stores information about available facilities, such as their names, indoor/outdoor availability, and locations.
4. Fields - Maps specific fields 1-3 to their respective facilities and tracks their operational status (Open/Closed).
5. Prices - Defines pricing for various booking types (leagues, rentals) and field configurations (e.g., full-field or one-third).
6. Leagues - Manages league information, including schedules, team requirements, pricing, and facilitator details.
7. League Signups - Handles team registrations for leagues, including deposit and payment statuses.
8. Field Rentals - Records rental bookings for fields, including user details, booking dates, times, and facilitators.

The next step is to create the table for the sport league database
*/


-- To create the USERS table

DROP TABLE IF EXISTS users;

CREATE TABLE users (
	UserID INT AUTO_INCREMENT,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50),
    Gender ENUM('M','F') NOT NULL,
    BirthDate DATE NOT NULL,
    Email VARCHAR(120) NOT NULL,
    PhoneNumber VARCHAR(15) NOT NULL,
    Password VARCHAR(50) NOT NULL,
    MemberDate DATETIME NOT NULL DEFAULT NOW(),
    SkillLevel ENUM('1','2','3','4','5'),
    EmergencyContact VARCHAR(15),
    
    PRIMARY KEY (UserID),
    UNIQUE KEY (Email),
    UNIQUE KEY (PhoneNumber)
)
ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- To create the FACILITATORS table

DROP TABLE IF EXISTS facilitator;

CREATE TABLE facilitator(
	FacilitatorID INT AUTO_INCREMENT,
    Role ENUM('Senior Manager','Manager','Coordinator','Referee') NOT NULL DEFAULT 'Referee',
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    PhoneNumber VARCHAR(15) NOT NULL,
    Email VARCHAR(120) NOT NULL,
    EmployementDate DATETIME NOT NULL DEFAULT NOW(),
    Wage DECIMAL(4,2) NOT NULL,
    
	PRIMARY KEY (FacilitatorID),
    UNIQUE KEY (Email)
)
ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- To create the FACILITIES table

DROP TABLE IF EXISTS facilities;

CREATE TABLE facilities (
    FacilityID INT AUTO_INCREMENT,
    FacilityName VARCHAR(255) NOT NULL,
    HasIndoor ENUM('Yes','No') NOT NULL DEFAULT 'YES',
    Location VARCHAR(100) NOT NULL,
    
	PRIMARY KEY (FacilityId),
    UNIQUE KEY (FacilityName)
)
ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- To create the FIELDS table

DROP TABLE IF EXISTS fieldfacilities;

CREATE TABLE fieldfacilities (
    FieldID INT AUTO_INCREMENT,
    FacilityID INT NOT NULL,
    FieldNumber INT NOT NULL,
    FieldStatus ENUM('Open','Closed') DEFAULT 'Open',
    
	PRIMARY KEY (FieldID),
    FOREIGN KEY (FacilityID) REFERENCES facilities(FacilityID)
)
ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- To create the PRICES table

DROP TABLE IF EXISTS price;

CREATE TABLE price(
	PriceID INT AUTO_INCREMENT,
    FacilityID INT NOT NULL,
    BookingType ENUM('League', 'Pickup', 'Rental') NOT NULL,
    NumberOfRequiredFields ENUM('1/3', 'Full') NOT NULL,
    IndoorOutdoor ENUM('Indoor', 'Outdoor') NOT NULL,
    Price DECIMAL(8, 2) NOT NULL,
    
	PRIMARY KEY (PriceID), 
    FOREIGN KEY (FacilityID) REFERENCES facilities(FacilityID)
)
ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- To create the LEAGUES table

DROP TABLE IF EXISTS leagues;

CREATE TABLE leagues(
	LeagueID INT AUTO_INCREMENT,
    LeagueType ENUM('Mens','Womens','Coed','Mens OT35','Womens OT50') NOT NULL,  
    OnCallManager INT NOT NULL,
    FacilitatorID INT NOT NULL,
    FieldID INT NOT NULL,
    StartDate DATE NOT NULL,
    EndDate DATE NOT NULL,
	DaysOfWeek ENUM('Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday') NOT NULL,
    WeeklyStartTime TIME NOT NULL,
    WeeklyEndTime TIME NOT NULL,
    RequiredTeams INT NOT NULL,
    TotalRegisterdTeams INT DEFAULT 0,
    TotalGames INT NOT NULL,
    TeamPrice DECIMAL(7,2) NOT NULL,
    TeamDeposit DECIMAL(7, 2) NOT NULL DEFAULT 250,
    LeagueStatus ENUM('Sold Out','Open') DEFAULT 'Open',
    
    PRIMARY KEY(LeagueID),
    FOREIGN KEY (FieldID) REFERENCES fieldfacilities(FieldID),
    FOREIGN KEY (OnCallManager) REFERENCES facilitator(FacilitatorID),
    FOREIGN KEY (FacilitatorID) REFERENCES facilitator(FacilitatorID),
    UNIQUE (FieldID, StartDate, EndDate, WeeklyStartTime, WeeklyEndTime, DaysOfWeek)
)
ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- To create the LEAGUE SIGNUPS table

DROP TABLE IF EXISTS leaguesignup;

CREATE TABLE leaguesignup(
    LeagueID INT NOT NULL,
    UserID INT NOT NULL,
    TeamID INT NOT NULL,
    SignupDate DATETIME NOT NULL,
    DepositPaid ENUM('True','False'),
    FullPayment ENUM('True','False'),
    SignupStatus ENUM('Completed','Pending','Cancelled'),
    
    FOREIGN KEY (LeagueID) REFERENCES leagues(LeagueID),
    FOREIGN KEY (UserID) REFERENCES users(UserID) ON DELETE CASCADE,
    UNIQUE (LeagueID, TeamID)
)
ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- To create the FIELD RENTALS table

DROP TABLE IF EXISTS fieldrentals;

CREATE TABLE fieldrentals(
	BookingID VARCHAR(20),
    UserID INT NOT NULL,
    BookingDate DATETIME NOT NULL,
    StartTime DATETIME NOT NULL,
    EndTime DATETIME NOT NULL,
    FieldType ENUM('Full','1/3') NOT NULL,
	FieldNumber ENUM('1','2','3') NULL,
    FacilitatorID INT NOT NULL,
    BookingStatus ENUM('Cancelled','Completed','No Show') DEFAULT 'Completed',
    
    PRIMARY KEY (BookingID),
    FOREIGN KEY (UserID) REFERENCES users(UserID) ON DELETE CASCADE,
    FOREIGN KEY (FacilitatorID) REFERENCES facilitator(FacilitatorID),
    UNIQUE (FieldNumber, BookingDate, EndTime)
)
ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


-- TO CREATE THE 'Cancellations' Table

DROP TABLE IF EXISTS cancellations;

CREATE TABLE cancellations(
	CancellationID INT AUTO_INCREMENT,
    BookingID VARCHAR(20) NOT NULL,
    CancelDate DATETIME NOT NULL DEFAULT NOW(),
    RefundStatus ENUM('Pending','Completed') DEFAULT 'Pending',
    
    PRIMARY KEY (CancellationID)
)
ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;



-- Check if the tables were created and constraints are properly placed
DESCRIBE users;
DESCRIBE facilities;
DESCRIBE fieldfacilities;
DESCRIBE facilitator;
DESCRIBE price;
DESCRIBE fieldrentals;
DESCRIBE leagues;
DESCRIBE leaguesignup;



--------------------------------------------------------
-- INSERTING DATA INTO THE TABLES
 /* 
 The tables are ready and the next step is to import values into the table with the data. 
 */
 
  -- INSERTING DATA INTO THE USERS TABLE 
INSERT INTO users (
    FirstName, LastName, Gender, BirthDate, Email, PhoneNumber, Password, SkillLevel, EmergencyContact
) 
VALUES
    ('John', 'Doe', 'M', '1990-05-15', 'john.doe@gmail.com', '1234567890', 'iambeau17', '3', '0987654321'),
    ('Jane', 'Smith', 'F', '1985-09-23', 'jane.smith@gmail.com', '1234567891', 'whocares31', '4', '0987654322'),
    ('Michael', 'Johnson', 'M', '1992-07-12', 'michael.johnson@yahoo.com', '1234567892', 'mikejeda12', '5', '0987654323'),
    ('Emily', 'Davis', 'F', '1995-03-30', 'emily.davis@gmail.com', '1234567893', '18Oct1976', '2', '0987654324'),
    ('David', 'Wilson', 'M', '1988-11-11', 'david.wilson@gmail.com', '1234567894', 'reallycool#1', '4', '0987654325'),
    ('Sophia', 'Martinez', 'F', '1999-01-20', 'sophia.martinez@yahoo.com', '1234567895', 'sophia111', '1', '0987654326'),
    ('James', 'Garcia', 'M', '1987-04-15', 'james.garcia@yahoo.com', '1234567896', 'feil1988', '3', '0987654327'),
    ('Olivia', 'Anderson', 'F', '1993-06-08', 'olivia.anderson@gmail.com', '1234567897', 'pland23', '5', '0987654328'),
    ('Robert', 'Thomas', 'M', '1990-02-25', 'robert.thomas@yahoo.com', '1234567898', 'thom9025', '2', '0987654329'),
    ('Isabella', 'Moore', 'F', '1998-08-17', 'isabella.moore@gmail.com', '1234567899', 'if0909mar', '4', '0987654330');


 -- INSERTING DATA INTO THE FACILITIES TABLE 
INSERT INTO facilities (
	FacilityName, HasIndoor, Location
)
VALUES
	('RA Centre','Yes','2451 Riverside Dr., Ottawa, ON K1H 7X7'),
    ('uOttawa Dome', 'Yes','200 Lees Avenue'),
    ('Ben Franklin Dome', 'Yes','191 Knoxdale Rd, Nepean, ON K2G 3J1'),
    ('Immaculata','No','140 Main St, Ottawa, ON K1S 1N3'),
    ('Hornets Nest','Yes','1662 Bearbrook Rd, Gloucester, ON K1B 1C4'),
    ('Louis Riel Dome','Yes','1659 Bearbrook Rd, Gloucester, ON K1B 4N3');
    

 -- INSERTING DATA INTO THE FACILITIES TABLE 
INSERT INTO fieldfacilities (
	FacilityID, FieldNumber
)
VALUES
	(1, 1),(1, 2),(1, 3),
    (2, 1),(2, 2),(2, 3),
    (3, 1),(3, 2),(3, 3),
    (4, 1),(4, 2),(4, 3),
    (5, 1);
    
 
 -- INSERTING DATA INTO THE FACILITIES TABLE 
INSERT INTO facilitator (
	Role, FirstName, LastName, PhoneNumber, Email, EmployementDate, Wage
)
 VALUES
	('Senior Manager', 'Sam', 'Larry', '123-456-7890', 'samlarry@ottawafootysevens.com', '2023-01-15 09:00:00', 45.00),
    ('Manager', 'Jack', 'Paul', '234-567-8901', 'jackpaul@ottawafootysevens.com', '2023-03-22 10:30:00', 35.50),
    ('Coordinator', 'Michael', 'Ben', '345-678-9012', 'mben@gmail.com', '2023-05-18 08:45:00', 25.75),
    ('Referee', 'Ella', 'Davis', '456-789-0123', 'edavis@yahoo.com', '2023-07-05 12:00:00', 20.00),
    ('Senior Manager', 'Tobi', 'Brown', '567-890-1234', 'tbrown@ottawafootysevens.com', '2023-09-10 11:15:00', 50.00),
    ('Manager', 'Emma', 'Frank', '678-901-2345', 'efrankn@ottawafootysevens.com', '2023-10-02 13:45:00', 37.00),
    ('Coordinator', 'Liam', 'Wilson', '789-012-3456', 'lwilson@yahoo.com', '2023-11-11 14:30:00', 28.00),
    ('Referee', 'Junior', 'Anderson', '890-123-4567', 'juinoranderson@yahoo.com', '2023-12-01 15:00:00', 22.50),
    ('Referee', 'James', 'Justin', '901-234-5678', 'jamesj@gmail.com', '2023-12-03 16:15:00', 22.00),
    ('Coordinator', 'Olivia', 'Rodrigo', '012-345-6789', 'oliviarodrigo@gmail.com', '2023-12-03 17:00:00', 27.50);
 

-- INSERTING DATA INTO THE PRICES TABLE 
INSERT INTO price (
	FacilityID, BookingType, NumberofRequiredFields, IndoorOutdoor, Price
)
 VALUES
	(1, 'Rental','1/3','Indoor','195'),
    (1, 'Rental','1/3','Outdoor','80'),
    (1, 'Rental','Full','Indoor','250'),
    (1, 'Rental','Full','Outdoor','180');


-- INSERTING DATA INTO THE FIELD RENTALS TABLE 
INSERT INTO fieldrentals (
    BookingID, UserID, BookingDate, StartTime, EndTime, FieldType, FieldNumber, FacilitatorID, BookingStatus
)
VALUES
    ('1R', 2, '2024-12-03 10:00:00','2024-12-03 10:00:00', '2024-12-03 12:00:00', 'Full', '1',3, 'Completed'),
    ('2R', 3,'2024-12-01 10:00:00','2024-12-03 12:30:00', '2024-12-03 14:30:00', '1/3', '2',4, 'Completed'),
    ('3R', 1,'2024-11-21 10:00:00','2024-12-03 15:00:00', '2024-12-03 17:00:00', 'Full', '3',2, 'Cancelled'),
    ('4R', 6,'2024-11-29 10:00:00','2024-12-03 09:00:00', '2024-12-03 11:00:00', '1/3', '1',1, 'Completed'),
    ('5R', 4,'2024-10-28 10:00:00','2024-12-03 18:00:00', '2024-12-03 20:00:00', 'Full', '2',5, 'No Show');



-- INSERTING DATA INTO THE LEAGUES TABLE
INSERT INTO leagues (
    LeagueType, OnCallManager, FacilitatorID, FieldID,
    StartDate, EndDate, DaysOfWeek, WeeklyStartTime, WeeklyEndTime, 
    RequiredTeams, TotalRegisterdTeams, TotalGames, TeamPrice, TeamDeposit, LeagueStatus
) VALUES
('Mens', 1, 2, 4, '2024-01-15', '2024-04-15', 'Sunday', '19:30:00', '23:30:00', 10, 8, 10, 1700.00, 250.00, 'Open'),
('Womens',3, 4, 2, '2024-01-18', '2024-05-01', 'Wednesday', '18:00:00', '23:30:00', 12, 12, 24, 1700.00, 350.00,'Sold Out'),
('Coed', 5, 6, 1, '2024-01-20', '2024-06-01', 'Friday', '18:30:00', '20:30:00', 8, 7, 16, 1300.00, 250.00,'Open'),
('Mens OT35', 2, 3,2, '2024-01-16', '2024-07-01', 'Monday', '20:00:00', '22:00:00', 6, 5, 12, 1100.00, 200.00, 'Open'),
('Womens OT50', 6, 5, 2, '2024-01-19', '2024-08-01', 'Thursday', '19:30:00', '21:30:00', 4, 4, 8, 900.00, 150.00, 'Sold Out'),
('Mens', 4, 2, 1,'2024-01-21', '2024-09-01', 'Saturday', '17:00:00', '19:00:00', 10, 7, 20, 1400.00, 280.00,  'Open'),
('Coed', 1, 6, 3,'2024-01-17', '2024-10-01', 'Tuesday', '18:00:00', '20:00:00', 12, 12, 24, 1600.00, 320.00, 'Sold Out');


-- INSERTING DATA INTO THE LEAGUE SIGNUP TABLE
INSERT INTO leaguesignup (
    LeagueID, UserID, TeamID, SignupDate, DepositPaid, FullPayment, SignupStatus
) 
VALUES
    (1, 1, 201, '2024-12-01 10:30:00','True', 'False', 'Pending'),
    (2, 2, 202, '2024-12-01 11:00:00','False', 'True', 'Completed'),
    (3, 5, 203, '2024-12-02 14:15:00','True', 'False', 'Pending'),
    (1, 4, 204, '2024-12-02 15:45:00','False', 'False', 'Cancelled'),
    (2, 3, 205, '2024-12-03 09:00:00','False', 'True', 'Completed'),
    (3, 7, 206, '2024-12-03 10:30:00','False', 'True', 'Completed'),
    (1, 8, 207, '2024-12-03 12:00:00','True', 'False', 'Pending');
    
-- TO BE SURE THE DATA WAS SUCCESSFULLY INSERTED INTO THE TABLES
SELECT * FROM facilities;
SELECT * FROM fieldfacilities;
SELECT * FROM facilitator;
SELECT * FROM users;
SELECT * FROM price;
SELECT * FROM leagues;
SELECT * FROM fieldrentals;
SELECT * FROM leaguesignup;


-- ENCRYPTING THE PASSWORD COLUMN
/* Ensure we encrypt password before inserting to tables
The password is a very sensitive information and it has to be protected so that anyone who has access to the table
will not have access to their password. I would be hashing the column for safety and security purposes.

Some of the hashing functions are 
- MD5
- SHA1
- SHA2
- password
*/

UPDATE users
SET password = MD5(password);

-- Check changed passwords
SELECT * FROM users;