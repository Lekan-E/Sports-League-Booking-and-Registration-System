-- Testing new league registration process

/*
-- 1. Senior Manager creates an Upcoming Leagues for the Fall/Winter Season
Input Parameters: 
- League Type
- Assigned On Call Manager
- League Cordinator
- Field
- Start Date
- Weekly Start and End Time
- Number of Teams
- Number of Games
- Price

*/
CALL new_league('Coed', 2, 10, 4, '2025-02-24', '18:00:00', '00:00:00', 10, 10, 2100, @output_message);
SELECT @output_message;
CALL new_league('Mens', 5, 7, 11, '2025-02-11', '20:00:00', '23:00:00', 9, 8, 1700, @output_message);
SELECT @output_message;

select * from leagues order by startdate desc;
-- Both leagues have now been created.

/*
Step 2. We will demonstrate the users process registering for a league.
Once we call the procedure, it then triggers the update and
This will then be used to populate the 'leaguesignup' table AND
Update the leagues table 'TotalRegisterdTeams column'
)
*/
CALL league_signup('k.harry@gmail.com', 'kanebayern', 101, 'Coed', 'Monday', 'Full Payment', @output_message);
CALL league_signup('john.doe@gmail.com', 'iambeau17', 102, 'Coed', 'Monday', 'Deposit', @output_message);
CALL league_signup('jane.smith@gmail.com', 'whocares31', 103, 'Coed', 'Monday', 'Full Payment', @output_message);
CALL league_signup('michael.johnson@yahoo.com', 'mikejeda12', 104, 'Coed', 'Monday', 'Deposit', @output_message);
CALL league_signup('emily.davis@gmail.com', '18Oct1976', 105, 'Coed', 'Monday', 'Full Payment', @output_message);
CALL league_signup('david.wilson@gmail.com', 'reallycool#1', 106, 'Coed', 'Monday', 'Full Payment', @output_message);
CALL league_signup('sophia.martinez@yahoo.com', 'sophia111', 107, 'Coed', 'Monday', 'Full Payment', @output_message);
CALL league_signup('james.garcia@yahoo.com', 'feil1988', 108, 'Coed', 'Monday', 'Full Payment', @output_message);
CALL league_signup('olivia.anderson@gmail.com', 'pland23', 109, 'Coed', 'Monday', 'Full Payment', @output_message);
CALL league_signup('robert.thomas@yahoo.com', 'thom9025', 110, 'Coed', 'Monday', 'Full Payment', @output_message);
CALL league_signup('isabella.moore@gmail.com', 'if0909mar', 111, 'Coed', 'Monday', 'Deposit', @output_message); -- if this user tries to signup, it returns a 'sold out' error
SELECT @output_message;

SELECT * FROM leaguesignup;
select * from leagues order by startdate desc;
