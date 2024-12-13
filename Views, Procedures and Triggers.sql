-- CREATING VIEWS, PROCEDURES AND TRIGGERS

/*
Now that the tables have been created and data has been inserted into the tables, we are ready to
select data from our tables.
*/

-- VIEW 1: A VIEW OF ALL UPCOMING FIELD RENTALS
/* 
The sports facility manager wants to be able to view all the upcoming booking details of all field rentals. 
*/

DROP VIEW IF EXISTS rental_vw;

CREATE VIEW rental_vw AS 
SELECT BookingID, 
	fr.StartTime, 
	u.UserID, 
	CONCAT(
	CASE 
		WHEN u.Gender = 'M' THEN 'Mr.' 
		ELSE 'Mrs.'
	END,
	'', u.FirstName,' ', u.LastName) as FullName, 
	u.Email,
	TIMESTAMPDIFF(MINUTE, fr.StartTime, fr.EndTime) as Duration_mins, 
	FieldType, 
	CONCAT(f.FirstName, ' ', F.LastName) as Facilitator, 
	f.Role, 
	fr.BookingStatus
FROM fieldrentals fr
JOIN users u ON fr.UserID = u.UserID
JOIN facilitator f ON fr.FacilitatorID = f.FacilitatorID
ORDER BY StartTime;

-- To view all the rental details, they are in the rental_vw which makes it easy for the Sport Facility Manager
-- To test if the view works

SELECT * FROM rental_vw;


-- VIEW 2: A VIEW OF ALL UPCOMING LEAGUE GAMES
/* 
A view would be also be created to show all the league games for the current week. This could help the Sports Facility
Manager and the facilitators know the current week's schedule so that they can plan ahead.
*/
DROP VIEW IF EXISTS leagues_this_week_vw;

CREATE OR REPLACE VIEW leagues_this_week_vw AS
SELECT 
    LeagueID,
    LeagueType,
    OnCallManager,
    FacilitatorID,
    FieldID,
    DaysOfWeek,
    WeeklyStartTime,
    WeeklyEndTime
FROM 
    leagues
WHERE 
    StartDate <= CURDATE() 
    AND EndDate >= CURDATE()
ORDER BY DaysOfWeek;


-- To test if the view works

SELECT * FROM leagues_this_week_vw;


-- VIEW 3: A VIEW OF ALL PENDING LEAGUE SIGNUPS
-- These are pending signups status with less than 2 weeks before league start date.
DROP VIEW IF EXISTS due_signups;

CREATE OR REPLACE VIEW due_signups AS
select ls.* 
FROM leaguesignup ls
JOIN leagues l ON ls.LeagueID = l.LeagueID
WHERE SignupStatus = 'Pending' 
AND DATEDIFF(DATE(NOW()), l.StartDate) <= 14;

-- To test if the view works

SELECT * FROM due_signups;



-------------------------------------------------------------------------------------

-- CREATING STORED PROCEDURES

-- STORED PROCEDURE 1: Stored Procedure to insert new user

/*
The first procedure would be used to insert new members to the users table. To achieve this, this would be done
using a stored procedure that takes the new members detail and adds it to the membership table
*/
DROP PROCEDURE IF EXISTS insert_new_user;

-- Create the procedure
DELIMITER $$
CREATE PROCEDURE insert_new_user(
	IN p_first_name VARCHAR(50), IN p_last_name VARCHAR(50), IN p_gender ENUM('M','F'), IN p_birth_date DATE,
    IN p_email VARCHAR(120), IN p_phone_number VARCHAR(15), IN p_password VARCHAR(50), IN p_skill_level ENUM('1','2','3','4','5'),
    IN p_emergency_contact VARCHAR(15))
BEGIN
	INSERT INTO users (FirstName, LastName, Gender, BirthDate, Email, PhoneNumber, Password, SkillLevel, EmergencyContact)
    VALUES (p_first_name, p_last_name, p_gender, p_birth_date, p_email, p_phone_number, MD5(p_password), p_skill_level, p_emergency_contact);
END $$
DELIMITER ;

-- Test/Call procedure
-- Now we insert Harry Kane's information to the database
CALL insert_new_user('Harry','Kane','M','1993-07-28', 'k.harry@gmail.com', '1478987415', 'kanebayern', '5', 3698523658); 

-- Check if 'Harry Kane' exists in the 'users' tables
SELECT * FROM users
WHERE firstname = 'Harry' AND lastname ='Kane';


-- STORED PROCEDURE 2: Stored Procedure to delete existing user per request

/*
This procedure would be used to delete records from the users table. The procedure would be supplied the email of the member
which would be deleted from the users table
*/

-- To create the procedure
DROP PROCEDURE IF EXISTS delete_user;

-- Create the procedure
DELIMITER $$
CREATE PROCEDURE delete_user(
IN p_email VARCHAR(120), 
IN p_password VARCHAR(50),
OUT p_message VARCHAR(50))
BEGIN
DECLARE p_userid INT;

    -- get the userid from the login details
	SELECT UserID
    INTO p_userid 
    FROM users
    WHERE Email = p_email AND Password = MD5(p_password);
    
    IF p_userid IS NOT NULL THEN
		DELETE FROM users
		WHERE userid = p_userid;
        SET p_message = 'User Deleted.';
	ELSE 
        SET p_message = 'User Not In Database.';
	END IF;
    
END $$
DELIMITER ;

-- Test procedure
-- First is to put off the autocommit feature
SET @@autocommit = FALSE;

SELECT @@autocommit; -- to check if it turned off 

-- 'Jane Smith' sent an unsubscribe email request, so we delete her information from the table
CALL delete_user('jane.smith@gmail.com','feil1988', @output_message);
SELECT @output_message;

-- Check if data has been removed from the 'users' tables
SELECT * FROM users
WHERE email = 'jane.smith@gmail.com';

ROLLBACK;


-- STORED PROCEDURE 3: Stored Procedure to update data in the User and Facilitators table

/*
The next procedure would be used to update the password and email of the users on the membership and the 
facilitator details on the facilitators table. The procedure would need the user email of the member and the
facilitator email of the facilitator then use that to update their details.
*/

-- UPDATE Users INFO

DROP PROCEDURE IF EXISTS update_user_info;

-- Create the procedure
DELIMITER $$
CREATE PROCEDURE update_user_info(
IN p_old_email VARCHAR(120), p_new_email VARCHAR(120), IN p_password VARCHAR(50), IN p_number VARCHAR(15),
OUT p_message VARCHAR(50) )

BEGIN
DECLARE p_old_password VARCHAR(50);

	-- get the existing password
	SELECT password
    INTO p_old_password
    FROM users
    WHERE email = p_old_email;
    
    IF p_old_email IS NULL THEN
		SET p_message = 'User email not in database';
	ELSE
		-- Ensure new email and passwords are different from exisiting
		IF p_old_email = p_new_email OR p_old_password = MD5(p_password) THEN
			SET p_message = 'Update Failed: No changes detected';
		ELSE
			UPDATE users 
			SET email = p_new_email, password = MD5(p_password), phonenumber = p_number
			WHERE email = p_old_email;
			
			SET p_message =  'Successful Update';
		END IF;
	END IF;
END $$
DELIMITER ;


-- Test updating user 'Michael Johnson' information change
CALL update_user_info('michael.johnson@gmail.com', 'michael.johnson@gmail.com','mikenewpassword','1542987154', @output_message); -- test with the same email
CALL update_user_info('michael.johnson@gmail.com', 'mike.johnson@gmail.com','mikenewpassword','1542987154', @output_message); -- test with the new email
select @output_message;

-- Since autocommit is off, the changes made are temporary, so I can rollback
ROLLBACK;



-- UPDATE Faciliator Emails and Information
/*
In this case, a senior manager wants to promote a referee, cordinator or manager
THEN also increase wage
*/
DROP PROCEDURE IF EXISTS update_facilitator;

-- create procedure
DELIMITER $$
CREATE PROCEDURE update_facilitator(
IN p_id INT, IN p_new_role ENUM('Senior Manager','Manager','Coordinator','Referee'), IN p_new_wage DECIMAL(4,2),
OUT p_message VARCHAR(50) )

BEGIN
DECLARE existing_role ENUM('Senior Manager','Manager','Coordinator','Referee');
DECLARE p_first_name VARCHAR(50);
DECLARE p_last_name VARCHAR(50);
DECLARE existing_email VARCHAR(120);
DECLARE facilitator_exists INT;
	
    -- check if the entered id exists in the database
    SELECT COUNT(*)
    INTO facilitator_exists
    FROM facilitator
    WHERE FacilitatorID = p_id;
    
    IF facilitator_exists = 0 THEN
        SET p_message = 'Error: FacilitatorID not found';
    ELSE
		-- get the role of the desired facilitator
		SELECT Role, FirstName, LastName, Email
		INTO existing_role, p_first_name, p_last_name, existing_email
		FROM facilitator
		WHERE FacilitatorID = p_id;
		
		-- if a manager then assign a new email
		IF p_new_role IN ('Senior Manager','Manager') THEN
			UPDATE facilitator
			SET role = p_new_role, 
				email = CONCAT(LOWER(p_first_name),'.', SUBSTRING(lower(p_last_name),1,1), p_id,'@ottawafootysevens.com'), 
				wage = p_new_wage
			WHERE FacilitatorID = p_id;
			SET p_message = CONCAT('Successful Promoted To ', p_new_role);
		ELSE -- assign the new role
			UPDATE facilitator
			SET role = p_new_role,
				email = existing_email,
				wage = p_new_wage
			WHERE FacilitatorID = p_id;
			SET p_message = CONCAT('Successful Promoted To ', p_new_role);
		END IF;
	END IF;
END $$
DELIMITER ;

SELECT *
FROM facilitator
WHERE FacilitatorID = 10;

-- Test updating facilitator promoting 'Olivia Rodrigo - 10' information change
CALL update_facilitator(10, 'Manager', 35.25, @output_message); # Olivia to manager
CALL update_facilitator(12, 'Coordinator', 25, @output_message);  # Using an invalid FacilitatorID - Returns a custom error message
select @output_message;

ROLLBACK;



-- STORED PROCEDURE 4: Stored Procedure to ADD OR CREATE A NEW LEAGUE
/*
In this case, a manager wants to set up and add an upcoming league.
Below are the criterias for creating a new league:
1. No overlapping leagues on the same field at the same time.
2. The league facilitator is a coordinator and not scheduled at the same time on a different field.
3. The facilitator is not assigned to multiple fields in the same facility. (Each facility has 3 fields)
4. The On Call Manager is either a Senior Manager or Manager and only one OnCallManager is assigned for a day.

The input parameters are:
1. League Type - 'Mens','Womens','Coed','Mens OT35','Womens OT50'
2. On Call Manager and Cordinator
3. Start Date, Weekly Start and End Times
4. Required Number of Teams
5. Total Games and Price
*/

DROP PROCEDURE IF EXISTS new_league;

-- create procedure
DELIMITER $$
CREATE PROCEDURE new_league (
IN p_type ENUM('Mens','Womens','Coed','Mens OT35','Womens OT50'),
IN p_oncallmanager INT, IN p_coordinator INT,
IN p_field INT, IN p_startdate DATE,
IN p_weeklystarttime TIME, IN p_weeklyendtime TIME, 
IN p_numteams INT, IN p_total_games INT, IN p_price DECIMAL(7,2),
OUT p_message VARCHAR(50)
)
BEGIN
DECLARE p_day ENUM('Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday');
DECLARE p_enddate DATE;
DECLARE p_deposit DECIMAL(7,2);

	-- Get what day of the week the league runs
    SET p_day = DAYNAME(p_startdate);
    
    -- get the end dates for each league based on the number of games
    SET p_enddate = DATE_ADD(p_startdate, INTERVAL (p_total_games - 1) WEEK);
    
    -- assign a deposit
    IF p_numteams <= 8 THEN 
		SET p_deposit = 250.00;
	ELSE
		SET p_deposit = 500.00;
    END IF;
    
    -- ensure we have no overlapping leagues on the same field at the same time
    IF EXISTS (
		SELECT 1
        FROM leagues
        WHERE FieldID = p_field AND DaysOfWeek = p_day 
        AND NOT (WeeklyEndTime <= p_weeklystarttime OR WeeklyStartTime >= p_weeklyendtime)
        AND StartDate <= p_enddate AND EndDate >= p_startdate)
	THEN 
        SET p_message = 'Another league is already scheduled on this field at the same time.';
    END IF;
    
    -- Ensure the Facilitator is a Coordinator and not scheduled at the same time on a different field
    IF NOT EXISTS (
        SELECT 1
        FROM facilitator
        WHERE FacilitatorID = p_coordinator AND Role != 'Referee' 
    ) THEN
        SET p_message = 'The Facilitator must have the role of Coordinator.';
    END IF;
    
    -- Ensure the facilitator is not assigned to multiple fields in the same facility on the same day
	IF EXISTS (
		SELECT 1
		FROM leagues AS l
		JOIN fieldfacilities AS ff ON l.FieldID = ff.FieldID
		WHERE l.FacilitatorID = p_coordinator AND ff.FacilityID = (SELECT FacilityID FROM fieldfacilities WHERE FieldID = p_field)
		  AND l.DaysOfWeek = p_day AND NOT (l.WeeklyEndTime <= p_weeklystarttime OR l.WeeklyStartTime >= p_weeklyendtime)
		  AND l.StartDate <= p_enddate AND l.EndDate >= p_startdate
	) THEN
		SET p_message = 'Facilitator is already assigned to another field in the same facility on the same day.';
	END IF;
    
    -- Ensure the OnCallManager is either a Senior Manager or Manager
    IF NOT EXISTS (
        SELECT 1
        FROM facilitator
        WHERE FacilitatorID = p_oncallmanager AND Role IN ('Senior Manager', 'Manager')
    ) THEN
        SET p_message = 'The OnCallManager must be either a Senior Manager or a Manager.';
    END IF;
    
    -- Ensure only one OnCallManager is assigned on the same day
	IF EXISTS (
		SELECT 1
		FROM leagues
		WHERE OnCallManager = p_oncallmanager AND DaysOfWeek = p_day AND NOT (EndDate < p_startdate OR StartDate > p_enddate)
	) THEN
		SET p_message =  'An OnCallManager is already assigned for this given day.';
	END IF;
		
    INSERT INTO leagues (
    LeagueType, OnCallManager, FacilitatorID, FieldID, StartDate, EndDate, 
    DaysOfWeek, WeeklyStartTime, WeeklyEndTime, RequiredTeams, TotalGames, TeamPrice, TeamDeposit
    )
    VALUES (
    p_type, p_oncallmanager , p_coordinator, p_field, p_startdate, p_enddate, 
    p_day, p_weeklystarttime, p_weeklyendtime, p_numteams, p_total_games, p_price, p_deposit
    );
    
    SET p_message = 'League created successfully.';
END $$
DELIMITER ;

CALL new_league('Coed', 2, 10, 4, '2025-02-24', '18:00:00', '00:00:00', 10, 10, 2100, @output_message);
SELECT @output_message;

select * from leagues order by startdate desc;


-- STORED PROCEDURE 5: Stored Procedure for a USER SIGNUP FOR A LEAGUE
/*
To achive this we will need the following input parameters:
1. User Email and Password for Authentication
2. Team ID
3. League Information - Day of the Week and Type
4. If the user will be making a full payment or a deposit during registration.
 
Later on in thsi project we will setup triggers to update the signup and league status.
If fullPAYMENT then set status to complete, | if deposit, status = pending | if not full with less than 14 days to legue start date, = cancelled

*/
DROP PROCEDURE IF EXISTS league_signup;

DELIMITER $$
CREATE PROCEDURE league_signup(
IN p_email VARCHAR(120), IN p_password VARCHAR(50),
IN p_teamid INT,
IN p_league_type ENUM('Mens','Womens','Coed','Mens OT35','Womens OT50'), 
IN p_dayofweek ENUM('Sunday', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday'),
IN p_payment ENUM('Deposit','Full Payment'),
OUT p_message VARCHAR(50)
)
BEGIN
DECLARE p_userid INT;
DECLARE p_signupdate DATETIME;
DECLARE p_leagueid INT;
DECLARE p_deposit ENUM('True','False');
DECLARE p_fullpayment ENUM('True','False');
DECLARE p_league_startdate DATE;
DECLARE p_signupstatus ENUM('Pending','Completed');
DECLARE p_leaguestatus  ENUM('Open','Closed');
DECLARE existing_signup INT;
	
    -- get the userid from the login details
	SELECT UserID
    INTO p_userid 
    FROM users
    WHERE Email = p_email AND Password = MD5(p_password);
    
    IF p_userid IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Create an Account to Signup a Team';
    END IF;
    
    -- get the signupdate
    SET p_signupdate = NOW();
    
    -- get user desired league from the type, day of week
    SELECT leagueid, leaguestatus, startdate
    INTO p_leagueid, p_leaguestatus, p_league_startdate
	FROM leagues 
	WHERE leaguetype = p_league_type AND daysofweek = p_dayofweek
    and leaguestatus = 'open' -- make sure the league is still open for registration
    and startdate > p_signupdate; -- and the league startdate is after the current date
    
    -- if leagueid null set message of not meeting league requirement
    IF p_leagueid IS NULL THEN 
        SET p_message = 'No eligible league found.';
    END IF;
    
    -- Check if the team is already signed up for the league 
	SELECT COUNT(*)
    INTO existing_signup
    FROM leaguesignup
    WHERE LeagueID = p_leagueid AND TeamID = p_teamid;

    IF existing_signup > 0 THEN 
        SET p_message = 'This team is already signed up for the league.';
    END IF;
    
    -- if user chooses to pay the deposit first
    -- 1. set the signupstatus to pending
    -- 2. deposit = true, fullpayment = false
    IF p_payment = 'Deposit' THEN
    -- deposit can't be paid 14 days before the league start date  
        IF DATEDIFF(p_league_startdate, p_signupdate) < 14 THEN
            SET p_signupstatus = 'Cancelled';
        ELSE
            SET p_deposit = 'True';
            SET p_fullpayment = 'False';
            SET p_signupstatus = 'Pending';
        END IF;
    ELSEIF p_payment = 'Full Payment' THEN
        SET p_deposit = 'False';
        SET p_fullpayment = 'True';
        SET p_signupstatus = 'Completed';
    ELSE
        SET p_message = 'Invalid payment type.';
    END IF;
		
    -- insert into the table
    INSERT INTO leaguesignup(LeagueID, UserID, TeamID, SignUpDate, DepositPaid, FullPayment, SignupStatus)
	VALUES (p_leagueid, p_userid, p_teamid, p_signupdate, p_deposit, p_fullpayment, p_signupstatus);
	
    SET p_message = 'Registered successfully.';
    
END $$
DELIMITER ;

CALL league_signup('k.harry@gmail.com', 'kanebayern', 101, 'Coed', 'Monday', 'Full Payment', @output_message);
SELECT @output_message;

select * from leaguesignup;
ROLLBACK;

-- STORED PROCEDURE 6: Stored Procedure to make a FIELD RENTAL
/* Field rentals is only offered on facility 1 on field 1, 2, and 3.
We want to enusre that:
1. No league is running on that field  before confirming
2. Booking are a minimum of 60 minutes
3. The user has no other bookings on the same day
4. We assign the facilitator that is at the current facility to the booking.

The input parameters are needed:
1. User Email and Password for Authentication
2. Rental date and time
3. desired booking length (has to be more than an hour)
4. Field Size (Full or 1/3) 

*/
DROP PROCEDURE IF EXISTS make_fieldrental;

DELIMITER $$
CREATE PROCEDURE make_fieldrental (
IN p_email VARCHAR(120), IN p_password VARCHAR(50),
IN p_starttime DATETIME, IN p_duration INT,
IN p_fieldtype ENUM('Full','1/3'),
OUT p_price DECIMAL(8,2), OUT p_message VARCHAR(50)
)
BEGIN
DECLARE p_userid INT;
DECLARE p_booking_date DATETIME;
DECLARE p_bookingid VARCHAR(50);
DECLARE p_endtime DATETIME;
DECLARE p_location ENUM('Indoor','Outdoor');
DECLARE p_fieldprice DECIMAL(7,2);
DECLARE p_facilitatorid INT;

	-- get the userid from the login details
	SELECT UserID
    INTO p_userid
    FROM users
    WHERE Email = p_email AND Password = MD5(p_password);
    
    IF p_userid IS NULL THEN 
        SET p_message = 'User Not Found - Create an Account to Book';
    END IF;
    
    -- Ensure the user has no other bookings on the same day
    IF EXISTS (
        SELECT 1
        FROM fieldrentals
        WHERE UserID = p_userid AND DATE(StartTime) = DATE(p_starttime)
    ) THEN 
        SET p_message = 'User already has a booking on this day.';
    END IF;
    
    SET p_booking_date = NOW();
    
    -- Validate that the start time is not in the past
    IF p_starttime <= p_booking_date THEN 
        SET p_message = 'Start time must be a future date and time.';
    END IF;
    
    -- Create a booking id
    SELECT CONCAT(COUNT(*) + 1, 'R')
    INTO p_bookingid
    FROM fieldrentals;
    
    -- get the end time, with a minimum of 60 minutes
    IF p_duration < 60 THEN
		SET p_duration = 60;
	END IF;
    
    SET p_endtime = ADDTIME(p_starttime, SEC_TO_TIME(p_duration * 60));
    
    -- enusre the booking is not happening when a league is occuring and same field
    IF EXISTS (
		SELECT 1
        FROM leagues
        WHERE FieldID IN (1,2,3)
        AND NOT (WeeklyEndTime <= TIME(p_starttime) OR WeeklyStartTime >= TIME(p_endtime))
        AND DaysOfWeek = DAYNAME(p_starttime)
        AND StartDate <= DATE(p_starttime) AND EndDate >= DATE(p_endtime)
	) THEN  
        SET p_message = 'Another league is already scheduled on this field at the same time.';
    END IF;
    
    -- calculate the rental price based on the season (indoor/outdoor)
    IF MONTHNAME(p_starttime) IN ('November','December','January','February','March','April') THEN
		SET p_location = 'Indoor';
	ELSE SET p_location = 'Outdoor';
    END IF;
    
    SELECT Price
    INTO p_fieldprice
    FROM price
    WHERE facilityID = 1 AND BookingType = 'Rental'
    AND NumberOfRequiredFields = p_fieldtype AND IndoorOutdoor = p_location;
    
    SET p_price = p_fieldprice * (p_duration / 60);
    
    -- assign the facilitator that is at the current facility/field to facilitatorid
    SELECT FacilitatorID
    INTO p_facilitatorid
	FROM leagues
	where fieldid in ('1','2','3') AND DaysOfWeek = DAYNAME(p_starttime);
    
    
	INSERT INTO fieldrentals(BookingID, UserID, BookingDate, StartTime, EndTime, FieldType, FieldNumber, FacilitatorID)
	VALUES (p_bookingid, p_userid, p_booking_date, p_starttime, p_endtime, p_fieldtype, 1 ,p_facilitatorid);
	
    SET p_message = 'Booking created successfully.';
	

END $$
DELIMITER ;

-- TEST make a field rental for 'Harry Kane'
CALL make_fieldrental('k.harry@gmail.com', 'kanebayern', '2024-12-11 20:00:00', 120, 'Full', @out_price, @out_message);
select @out_price, @out_message; 

ROLLBACK;

-- STORED PROCEDURE 6: Stored Procedure to cancel a FIELD RENTAL
/*
This procedure would be used to cancel the bookings made on the bookings table. The conditions for cancelling the bookings 
are that the booking cannot be cancelled two days before date of the booking. 
*/

-- procedure to cancel a rental

DROP PROCEDURE IF EXISTS cancel_rental;

DELIMITER $$
CREATE PROCEDURE cancel_rental(
	IN p_email VARCHAR(50), IN p_password VARCHAR(50), IN p_bookingid VARCHAR(10),
    OUT p_message VARCHAR(100)
)
BEGIN
DECLARE p_userid INT;
DECLARE p_startdate DATETIME;

	-- verify user before cancelling
	SELECT UserID
    INTO p_userid 
    FROM users
    WHERE Email = p_email AND Password = MD5(p_password);
    
    # Retrive the booking information
    SELECT StartTime
    INTO p_startdate
    FROM fieldrentals
    WHERE bookingid = p_bookingid AND UserID = p_userid;
    
    IF p_userid IS NULL THEN 
        SET p_message = 'Invalid cancellation request. Booking not found.';
    END IF;
    
    
    -- bookings cannot be cancelled 2 days before date 
    IF DATEDIFF(p_startdate, NOW()) < 2 THEN
		SET p_message = 'Cancellation cannot be done two days before booking';
	ELSE
		-- Update bookingstatus on
        UPDATE fieldrentals
        SET BookingStatus = 'Cancelled'
        WHERE BookingID = p_bookingid;
        
        SET p_message = 'Your field rental booking has been cancelled.';
	END IF;
    
END $$
DELIMITER ;


CALL cancel_rental('k.harry@gmail.com', 'kanebayern', '6R', @out_message);
select @out_message; -- we get a booking error as booking cant be cancel 2 days before start date.



-- SETTING UP TRIGGERS

-- TRIGGER 1 : INITIATE A TRIGGER FOR LEAGUE REGISTRATION STATUS

/* 
In a case where a member signs up for a league, we want to update the leagues table to reflect this
by incrementing totalregisterdteams by 1 for each signup and when this meets the total required teams,
we set the league status to sold out.
This allows the manager to track the league status before the start date.
*/

-- DROP if exists
DROP TRIGGER IF EXISTS league_status_update;

-- Creating the trigger
DELIMITER $$
CREATE TRIGGER league_status_update
AFTER INSERT ON leaguesignup
FOR EACH ROW
BEGIN

	-- ADD 1 to the totalregistered team when we get a league signup
	UPDATE leagues
    SET TotalRegisterdTeams = TotalRegisterdTeams + 1
    WHERE LeagueID = NEW.LeagueID;
    
    -- Update the league status when full (TotalRegisterdTeams = RequiredTeams)
    UPDATE leagues
    SET LeagueStatus = 'Sold Out'
    WHERE LeagueID = NEW.LeagueID AND TotalRegisterdTeams = RequiredTeams;
    
END $$
DELIMITER ;

-- TRIGGER 2 : TRIGGER FOR LEAGUE SIGNUP CANCELLATIONS
-- DROP if exists
DROP TRIGGER IF EXISTS league_cancellation_trigger;

-- Creating the trigger
DELIMITER $$
CREATE TRIGGER league_cancellation_trigger
AFTER UPDATE ON leaguesignup
FOR EACH ROW
BEGIN
    -- once league signup status is cancelled then add to the cancellation table
    IF New.SignupStatus = 'Cancelled' THEN
		INSERT INTO cancellations (BookingID)
        -- create a unique bookingid for league signups
        VALUES (CONCAT(NEW.LeagueID, '-', NEW.UserID, '-', NEW.TeamID));
	END IF;
	
END $$
DELIMITER ;


-- TRIGGER 3 : TRIGGER FOR RENTAL CANCELLATIONS
-- DROP if exists
DROP TRIGGER IF EXISTS rental_cancellation_trigger;

-- Creating the trigger
DELIMITER $$
CREATE TRIGGER rental_cancellation_trigger
AFTER UPDATE ON fieldrentals
FOR EACH ROW
BEGIN
    -- once the rental bookingstatus is set to cancelled then insert into the cancellation table
    IF New.BookingStatus = 'Cancelled' THEN
		INSERT INTO cancellations (BookingID)
        VALUES (NEW.BookingID);
	END IF;
    
END $$
DELIMITER ;



