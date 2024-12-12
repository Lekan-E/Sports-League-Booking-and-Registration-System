# Database Design: Sports-League-Booking-and-Registration-System
## Project Background
The OttawaFooty7s is Ottawa’s largest recreational sports league that offers daily leagues and field rentals across multiple facilities in the Ottawa-Gatineau region. During my time as a league referee, I identified the need to build a database system for the company to automate league operations. Collaborating with the senior manager and league facilitators, I undertook the design of a comprehensive database to store important data such as user signup data as well as staff information.
Additionally, the database aims to automate various processes including creating new leagues, handling team signups, managing field rentals and payments, updating user records, processing cancellations, and providing a seamless experience for both new and registered users and teams.

Through this project, I aim to demonstrate my ability to handle end-to-end database development, including requirements gathering, table creation, data relationships, automation, and user privilege management. 

## Key Features
- **Daily Leagues and Field Rentals**: The company operates across five facilities, each divided into three smaller fields. Fields can be booked individually or as a whole.
- **Field Rentals**: Select facilities allow rentals for a minimum duration of one hour, with pricing depending on the season (indoor or outdoor).
- **User Authorization**: Only registered users can sign up for leagues or book fields.
- **Cancellations**: Rentals can be cancelled up to two days prior, and league signups 14 days before the start date.
- **Unique Registrations**: Team members cannot register the same team for a league.

## Project Breakdown
After reviewing the project overview and understanding the needs of the league, I broke down the project into the following stages:
1. Database Setup and Creation
2. Table Creation and Inserting Data
3. Creating Views and Setting up EER Diagram
4. Automate Database Activity, Stored Procedures, Functions and Triggers
5. User Management and Privileges
6. Backup and Recovery

## Database Setup and Creation
Before setting up a database, I ensured the following:
- Defined the purpose of the database and gathered the required data (e.g., membership, bookings, facilities).
- Designed major entities and their relationships, including Membership, Bookings, and Facilities.
- Identified primary keys for each table and established relationships between them.
- Looked at each table and decided how the data in one table is related to the data in other tables. Added fields to tables or create new tables to clarify the relationships, as necessary.


## Table Creation and Inserting Data
After coming up with a blueprint for the database, the next step was to create the tables, add table constraints and establish a relationship between the tables.

The tables to be used in the database were divided into the following:
- Users - This table stores details of all registered members, including personal information like names, gender, date of birth, email, and contact details. 
- Facilitators - The table stores details of staff members managing or supervising activities, such as referees, managers, and coordinators.
- Facilities - This stores information about available facilities, such as their names, indoor/outdoor availability, and locations.
- Fields - Maps specific fields 1-3 to their respective facilities and tracks their operational status (Open/Closed).
- Prices - Defines pricing for various booking types (leagues, rentals) and field configurations (e.g., full-field or one-third).
- Leagues - Manages league information, including schedules, team requirements, pricing, and facilitator details.
- League Signups - Handles team registrations for leagues, including deposit and payment statuses.
- Field Rentals - Records rental bookings for fields, including user details, booking dates, times, and facilitators.
- Cancellation - This table holds records of bookings that were cancelled with information on the refund status of each cancellation along with the booking ID.

The script below contains the SQL scripts used to build the users and leagues table only


## Data Hashing and Encryption
Hashing is a one-way cryptographic function that transforms the original password into a fixed-length string of characters, making it computationally infeasible to reverse the process and obtain the original password.

The password column on the membership table was hashed in order to protect the information of every member on the table.

Check my GitHub Repository to see how it done.

## Creating Views
Now that I have created the tables and inserted some data, the next step is to create views.

Specifically, I created views that show all the booking details of each upcoming field rental and all leagues taking place in the current week. This would give the management and admin an easy view to all the booking details in the current week so that proper preparations can be made and assign free spots for field rentals.

You can find the script in my GitHub Repository.

## Automating Database Activity
The goal of automating database activity is to streamline, optimize, and schedule routine or repetitive tasks, improving efficiency, accuracy, and overall management of the database environment.

To begin this, I initially studied all repetitive booking and payment activities that would be done on the database and automated them to save time and improve efficiency. These automations were done using Stored Procedures and Database Triggers in MySQL.

Here is the list of activities I automated:
- Inserting new members into the users’ table
- Deleting members from the users’ table
- Updating data in the users' credentials on the users' table. Credentials such as email and password.
- Updating data in the facilitator's tables such as custom email changes when an employee is promoted to a manager and changes in employee wages. As well as updating personal information.
- Creating an upcoming league, handling league status (open/sold out) and assigning facilitators to leagues.
- Make a booking and insert it on the bookings table (you must be a confirmed member and you have to pick a facility at a time it is not booked)
- Checking for available slots before making a booking
- Handling team registration to accept deposit and full payments, updating registration status once full payment has been confirmed and cancelling registration if payment isn’t confirmed 14 days before the start of the league.
- Cancelling a field rental based on the condition that it’s within two days before the start time of the booking. 

These are most of the automations I implemented on the database and the scripts used to create the automation can be found in my GitHub Repository.


## User Management & Privileges
User management is important because it plays a vital role in ensuring the security, integrity, and efficiency of a database system. They enforce access control, limiting database interactions to authorized individuals and preventing unauthorized access.

For this database, I would be creating 3 users, the details are below

- **Admin**: The user should be able to perform all actions on the database from creating, querying, changing and deleting instructors, members, bookings, facilities etc.
-**Facilitator**: The facilitator should be able to check and query the facilitator and facilities tables and should be able to update their personal details on the facilitator table. They should also be able to view booking details and bookings for the week
-**Users**: Users should be able to check and update their details on the membership table. Members should be able to view available bookings should be able to make bookings.
	
The script used to carry out this process is documented in my repository.

## Backup and Recovery
We use Backups to make sure our database is protected and recoverable in the event of loss. There are different types of backup but the backup I performed is a Logical backup.

In a logical backup, you are able to store the SQL statements needed to recreate the database and populate it. In MySQL, this is done using mysqldump.

The backed-up file is also present in my GitHub Repository. So you can recreate the database on your local device.

## Conclusion
The successful implementation of the OttawaFooty7s Database System highlights the importance of well-structured database solutions in managing repetitive and complex operations. 

By automating routine tasks, such as league creation, team registration, and field rental management, the database has significantly reduced manual effort and improved overall efficiency. The integration of user management features, views, and secure data handling ensures a seamless experience for all stakeholders, from league facilitators to registered users.

This project demonstrates my expertise in database design and management, as well as my ability to translate organizational needs into functional and efficient systems. Moving forward, the system can be extended with additional features such as a real-time booking calendar in Tableau or PowerBI.

The outcome of this project demonstrates solving real-world problems through practical technical solutions.
