-- USER MANAGEMENT AND PRIVILEGES
/* 
The next step is to create users, manage them and grant privileges to the users. User management is important because they play a 
vital role in ensuring the security, integrity, and efficiency of a database system. They enforce access control, limiting database 
interactions to authorized individuals and preventing unauthorized access.

The following users and access would be given
- Admin: The user should be able to perform all actions on the datadase from creating, querying, changing and deleting instructors, 
		 members, bookings, facilities etc.
- Facilitator: The facilitator should be able to check and query the facilitator and facilities tables and should be able to 
	     update their personal details on the facilitator table. They should also be able to view bookings details and 
         bookings for the week
- Users: Users should be able to check and update their details on the membership table. Members should be able to view available 
	     bookings, should be able to make bookings and can view their own weekly bookings.
	 
*/

-- TO create the users 

-- For admin
CREATE USER IF NOT EXISTS "sports_admin"@'localhost'
IDENTIFIED BY "senior_admin";

-- For Facilitator
CREATE USER IF NOT EXISTS "sports_facilitator"@'localhost'
IDENTIFIED BY "facilitator";

-- For Member
CREATE USER IF NOT EXISTS "sports_member"@'localhost'
IDENTIFIED BY "Member";


-- GRANTING USER ACCESS AND PRIVILEGES

-- For Admin
GRANT ALL PRIVILEGES 
ON league_db.*
TO "sports_admin"@'localhost';

-- For Facilitator
GRANT SELECT ON league_db.rental_vw -- to be able to query the field rentals table
TO "sports_facilitator"@'localhost';

GRANT EXECUTE ON PROCEDURE league_db.leagues_this_week_vw -- to be able to see leagues
TO "sports_facilitator"@'localhost';

GRANT SELECT ON league_db.cancellations -- to be able to query the cancellations table
TO "sports_facilitator"@'localhost';


-- For members
GRANT SELECT ON league_db.delete_user -- to be able to deregister from database
TO "sports_member"@'localhost';

GRANT EXECUTE ON PROCEDURE league_db.update_user_info -- to be able to update member info
TO "sports_member"@'localhost';

GRANT EXECUTE ON PROCEDURE league_db.cancel_rental -- to be able to cancel rental booking
TO "sports_member"@'localhost';

GRANT EXECUTE ON PROCEDURE league_db.rental_vw -- to be able to view available bookings
TO "sports_member"@'localhost';

GRANT EXECUTE ON PROCEDURE league_db.make_fieldrental -- to be able to make bookings
TO "sports_member"@'localhost';

GRANT EXECUTE ON PROCEDURE league_db.league_signup-- to be able to signup for a league
TO "sports_member"@'localhost';

GRANT EXECUTE ON PROCEDURE league_db.leagues -- to be able to view upcoming leagues
TO "sports_member"@'localhost';

-- To be sure the privileges are accurately given
SHOW GRANTS FOR "sports_admin"@'localhost';
SHOW GRANTS FOR "sports_facilitator"@'localhost';
SHOW GRANTS FOR "sports_member"@'localhost';


-- DATABASE BACKUP AND RECOVERY

/*
Database backups are crucial for data recovery and continuity, providing a safeguard against data loss due to accidental
deletion, corruption, or system failures, ensuring the ability to restore databases to a previous state and minimizing 
downtime in the event of unexpected incidents.

The database for the sports complex has been exported using mysqldump, database backup method we can use to make sure
we can restore data if we lose it.
*/

-- BACKUP: mysqldump -u root -p League_db > League_DB_backup.sql
-- RESTORE : mysql -u root -p League_db < League_DB_backup.sql

