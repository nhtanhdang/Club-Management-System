CREATE TABLE Archer(
    Archer_ID int(20) AUTO_INCREMENT,
    First_Name varchar(20) NOT NULL,
    Last_Name varchar(20) NOT NULL,
    Gender ENUM('Male', 'Female') NOT NULL,
    Age int(2) NOT NULL,
    Email varchar(255) UNIQUE NOT NULL,
    Pass_word varchar(255) NOT NULL,
    PRIMARY KEY (Archer_ID),
    CONSTRAINT valid_email CHECK (Email LIKE '%_@__%.__%')
);

CREATE TABLE Class(
    Class_ID int(2) AUTO_INCREMENT,
    Class_Age varchar(5) NOT NULL,
    Min_Max ENUM('Min', 'Max') DEFAULT 'Min',
    Class_Gender ENUM('Male', 'Female') NOT NULL,
    PRIMARY KEY (Class_ID),
    #Added Unique Constraint to prevent input of the already existed class
    CONSTRAINT UC_Class UNIQUE (Class_Age, Min_Max, Class_Gender)
);

CREATE TABLE Championship(
    Championship_ID int(3) AUTO_INCREMENT,
    Championship_Name TEXT,
    Championship_Desc TEXT,
    Championship_Start_Date date,
    Championship_End_Date date,
    PRIMARY KEY (Championship_ID),
    #Added Unique Constraint to prevent input of the already existed champion
    CONSTRAINT UC_Championship UNIQUE (Championship_Name(255), Championship_Start_Date, Championship_End_Date)
);
 
CREATE TABLE Equipment(
    Equipment_ID int(2) AUTO_INCREMENT,
    Equipment_Desc TEXT,
    PRIMARY KEY (Equipment_ID),
    #Added Unique Constraint to prevent input of the already existed equipment
    CONSTRAINT UC_Equipment UNIQUE (Equipment_Desc(255))
);


CREATE TABLE Rounds(
    Round_ID varchar(20) NOT NULL,
    Class_ID int(2),
    Equipment_ID int(2),
    PRIMARY KEY (Round_ID),
    #Added Unique Constraint to prevent input of the already existed round
    CONSTRAINT UC_Rounds UNIQUE (Round_ID, Class_ID, Equipment_ID),
    CONSTRAINT FK_Class FOREIGN KEY (Class_ID) REFERENCES Class(Class_ID),
    CONSTRAINT FK_Equipment FOREIGN KEY (Equipment_ID) REFERENCES Equipment(Equipment_ID)
);

CREATE TABLE Ranges(
    Range_ID varchar(20) NOT NULL,
    Range_Distance ENUM('10', '20', '30', '40', '50', '60', '70', '90') NOT NULL,
    Face_Size ENUM('80', '122') DEFAULT '80',
    Number_Of_Ends int(1) NOT NULL,
    PRIMARY KEY (Range_ID),
    #Added Unique Constraint to prevent input of the already existed range
    CONSTRAINT UC_Range UNIQUE (Range_Distance, Face_Size, Number_Of_Ends)
);

CREATE TABLE Competition(
    Competition_ID int(3) AUTO_INCREMENT,
    Competition_Date date NOT NULL,
    Competition_Name TEXT,
    Round_ID varchar(20),
    Championship_ID int(3),
    PRIMARY KEY (Competition_ID),
    #Added Unique Constraint to prevent input of the already existed competition
    CONSTRAINT UC_Competition UNIQUE (Competition_Date, Competition_Name(255), Round_ID, Championship_ID),
    CONSTRAINT FK_RoundComp FOREIGN KEY (Round_ID) REFERENCES Rounds(Round_ID),
    CONSTRAINT FK_Championship FOREIGN KEY (Championship_ID) REFERENCES Championship(Championship_ID)
);

CREATE TABLE RangeRoundCompetition(
    Score_ID int(20) AUTO_INCREMENT,
    Competition_ID int(3),
    Range_Count varchar(2) NOT NULL,
    Round_ID varchar(20),
    Range_ID varchar(20),
    PRIMARY KEY (Score_ID),
    CONSTRAINT UC_Competition_Range UNIQUE (Competition_ID, Range_Count),
    CONSTRAINT FK_Competition_ID FOREIGN KEY (Competition_ID) REFERENCES Competition(Competition_ID),
    CONSTRAINT FK_Round FOREIGN KEY (Round_ID) REFERENCES Competition(Round_ID),
    CONSTRAINT FK_Range FOREIGN KEY (Range_ID) REFERENCES Ranges(Range_ID)
);


CREATE TRIGGER auto_insert_round_id
BEFORE INSERT ON RangeRoundCompetition
FOR EACH ROW
BEGIN
    DECLARE roundIdValue VARCHAR(20);
    
    -- Retrieve the Round_ID associated with the Competition_ID being inserted
    SELECT Round_ID INTO roundIdValue
    FROM Competition
    WHERE Competition_ID = NEW.Competition_ID;

    -- Set the Round_ID for the new row being inserted
    SET NEW.Round_ID = roundIdValue;
END;



CREATE TABLE ArcherScore (
    Archer_ID int(20),
    Score_ID int(20),
    End_No int(1),
    Arrow_No_1 ENUM('1', '2', '3', '4', '5', '6', '7', '8', '9', '10', 'X', 'M'),
    Arrow_No_2 ENUM('1', '2', '3', '4', '5', '6', '7', '8', '9', '10', 'X', 'M'),
    Arrow_No_3 ENUM('1', '2', '3', '4', '5', '6', '7', '8', '9', '10', 'X', 'M'),
    Arrow_No_4 ENUM('1', '2', '3', '4', '5', '6', '7', '8', '9', '10', 'X', 'M'),
    Arrow_No_5 ENUM('1', '2', '3', '4', '5', '6', '7', '8', '9', '10', 'X', 'M'),
    Arrow_No_6 ENUM('1', '2', '3', '4', '5', '6', '7', '8', '9', '10', 'X', 'M'),
    End_Score int(2) AS (
        CASE Arrow_No_1
            WHEN 'X' THEN 10
            WHEN 'M' THEN 0
            ELSE CAST(Arrow_No_1 AS SIGNED) 
            #Index value of ENUM starts from 1, so '0' will be treated as '1'
        END +
        CASE Arrow_No_2
            WHEN 'X' THEN 10
            WHEN 'M' THEN 0
            ELSE CAST(Arrow_No_2 AS SIGNED) 
        END +
        CASE Arrow_No_3
            WHEN 'X' THEN 10
            WHEN 'M' THEN 0
            ELSE CAST(Arrow_No_3 AS SIGNED) 
        END +
        CASE Arrow_No_4
            WHEN 'X' THEN 10
            WHEN 'M' THEN 0
            ELSE CAST(Arrow_No_4 AS SIGNED) 
        END +
        CASE Arrow_No_5
            WHEN 'X' THEN 10
            WHEN 'M' THEN 0
            ELSE CAST(Arrow_No_5 AS SIGNED) 
        END +
        CASE Arrow_No_6
            WHEN 'X' THEN 10
            WHEN 'M' THEN 0
            ELSE CAST(Arrow_No_6 AS SIGNED) 
        END
    ),
    Verified BOOLEAN NOT NULL DEFAULT FALSE,
    PRIMARY KEY (Archer_ID, Score_ID, End_No),
    CONSTRAINT FK_ArcherScore FOREIGN KEY (Archer_ID) REFERENCES Archer(Archer_ID),
    CONSTRAINT FK_Score FOREIGN KEY (Score_ID) REFERENCES RangeRoundCompetition(Score_ID)
);

--Retrieve the results of the National Archery Championship (2020) to identify the winner and his/her scores in each competition regarding to other participants' performance. This information provides a benchmark for future participants to strive towards and can serve as a point of reference for comparing and analysing individual performances.

SELECT a.Archer_ID, CONCAT(a.First_Name, ' ', a.Last_Name) AS Archer_Name, c.Championship_ID, c.Championship_Name, c.Championship_Start_Date, c.Championship_End_Date, comp.Competition_ID, comp.Competition_Date, rrc.Round_ID,
    comp_scores.Competition_Score, champ_scores.Championship_Score
FROM Archer a
JOIN ArcherScore rs ON a.Archer_ID = rs.Archer_ID
JOIN RangeRoundCompetition rrc ON rs.Score_ID = rrc.Score_ID
JOIN Rounds r ON rrc.Round_ID = r.Round_ID
JOIN Competition comp ON rrc.Competition_ID = comp.Competition_ID 
JOIN Championship c ON comp.Championship_ID = c.Championship_ID
JOIN (
    SELECT comp.Competition_ID, a.Archer_ID, SUM(rs.End_Score) AS Competition_Score,
        SUM(CASE WHEN rs.Arrow_No_1 = 'X' THEN 1 ELSE 0 END +
        CASE WHEN rs.Arrow_No_2 = 'X' THEN 1 ELSE 0 END +
        CASE WHEN rs.Arrow_No_3 = 'X' THEN 1 ELSE 0 END +
        CASE WHEN rs.Arrow_No_4 = 'X' THEN 1 ELSE 0 END +
        CASE WHEN rs.Arrow_No_5 = 'X' THEN 1 ELSE 0 END +
        CASE WHEN rs.Arrow_No_6 = 'X' THEN 1 ELSE 0 END) AS X_Count
    FROM Archer a
    JOIN ArcherScore rs ON a.Archer_ID = rs.Archer_ID
    JOIN RangeRoundCompetition rrc ON rs.Score_ID = rrc.Score_ID
    JOIN Competition comp ON rrc.Competition_ID = comp.Competition_ID
    GROUP BY comp.Competition_ID, a.Archer_ID
) AS comp_scores ON comp.Competition_ID = comp_scores.Competition_ID AND a.Archer_ID = comp_scores.Archer_ID
JOIN (
    SELECT c.Championship_ID, a.Archer_ID, SUM(rs.End_Score) AS Championship_Score
    FROM Archer a
    JOIN ArcherScore rs ON a.Archer_ID = rs.Archer_ID
    JOIN RangeRoundCompetition rrc ON rs.Score_ID = rrc.Score_ID
    JOIN Competition comp ON rrc.Competition_ID = comp.Competition_ID
    JOIN Championship c ON comp.Championship_ID = c.Championship_ID
    GROUP BY c.Championship_ID, a.Archer_ID
) AS champ_scores ON c.Championship_ID = champ_scores.Championship_ID AND a.Archer_ID = champ_scores.Archer_ID
WHERE c.Championship_ID = '1' AND comp.Competition_Date BETWEEN c.Championship_Start_Date AND c.Championship_End_Date
GROUP BY a.Archer_ID, a.First_Name, a.Last_Name, c.Championship_ID, c.Championship_Name, c.Championship_Desc, c.Championship_Start_Date, c.Championship_End_Date, comp.Competition_ID, comp.Competition_Date, rrc.Round_ID, r.Class_ID, r.Equipment_ID
ORDER BY champ_scores.Championship_Score DESC, comp_scores.X_Count DESC;

--Retrieve the highest recorded score in each competition. By this, participants can set realistic and challenging goals for themselves in each competition. The best recorded score also serves as a reference point for participants to evaluate the level of challenge in a competition. It might be interpreted that if the best score is exceptionally low, the competition is more likely to be difficult, requiring participants to bring their best skills and strategies. Moreover, comparing the best recorded scores across different competitions allows participants to identify rounds of similar difficulty levels, helping them make informed decisions based on their skill level and preferences.

SELECT outerquery.Competition_ID, outerquery.Competition_Date, outerquery.Competition_Name, outerquery.Round_ID, outerquery.Class_ID, outerquery.Equipment, outerquery.Archer_ID, outerquery.Archer_Name, outerquery.Round_Score
FROM (
  SELECT subquery.*, ROW_NUMBER() OVER (PARTITION BY subquery.Competition_ID ORDER BY subquery.Round_Score DESC, subquery.X_Count DESC) AS rn
  FROM (
    SELECT comp.Competition_ID, comp.Competition_Date, comp.Competition_Name, rrc.Round_ID, r.Class_ID, e.Equipment_Desc AS Equipment, a.Archer_ID,
      CONCAT(a.First_Name, ' ', a.Last_Name) AS Archer_Name, innerquery.Round_Score, innerquery.X_Count
    FROM (
      SELECT rrc.Competition_ID, a.Archer_ID, 
        SUM(rs.End_Score) AS Round_Score,
        SUM(CASE WHEN rs.Arrow_No_1 = 'X' THEN 1 ELSE 0 END +
            CASE WHEN rs.Arrow_No_2 = 'X' THEN 1 ELSE 0 END +
            CASE WHEN rs.Arrow_No_3 = 'X' THEN 1 ELSE 0 END +
            CASE WHEN rs.Arrow_No_4 = 'X' THEN 1 ELSE 0 END +
            CASE WHEN rs.Arrow_No_5 = 'X' THEN 1 ELSE 0 END +
            CASE WHEN rs.Arrow_No_6 = 'X' THEN 1 ELSE 0 END) AS X_Count
      FROM Archer a
      JOIN ArcherScore rs ON a.Archer_ID = rs.Archer_ID
      JOIN RangeRoundCompetition rrc ON rs.Score_ID = rrc.Score_ID
      GROUP BY rrc.Competition_ID, a.Archer_ID
    ) AS innerquery
    JOIN Competition comp ON innerquery.Competition_ID = comp.Competition_ID
    JOIN RangeRoundCompetition rrc ON innerquery.Competition_ID = rrc.Competition_ID
    JOIN Rounds r ON rrc.Round_ID = r.Round_ID 
    JOIN Equipment e ON r.Equipment_ID = e.Equipment_ID
    JOIN Archer a ON innerquery.Archer_ID = a.Archer_ID
  ) AS subquery
) AS outerquery
WHERE rn = 1;

--Retrieve the list of archers who attend in Brisbane competition on February 14, 2020 and their individual competition score from highest to lowest.  By reviewing the individual competition scores, the club coaches and archers can assess their performance, identify areas for improvement, and track their progress over time. The list can also provide valuable statistical insights into the average performance between all participants in the 2020 Brisbane competition. 

SELECT Archer_ID, Archer_Name, Competition_ID, Round_ID, Class_ID, Equipment_ID, Round_Score
FROM (
    SELECT a.Archer_ID, CONCAT(a.First_Name, ' ', a.Last_Name) AS Archer_Name, rrc.Competition_ID, rrc.Round_ID, r.Class_ID, r.Equipment_ID,
        SUM(rs.End_Score) AS Round_Score,
        SUM(CASE WHEN rs.Arrow_No_1 = 'X' THEN 1 ELSE 0 END +
            CASE WHEN rs.Arrow_No_2 = 'X' THEN 1 ELSE 0 END +
            CASE WHEN rs.Arrow_No_3 = 'X' THEN 1 ELSE 0 END +
            CASE WHEN rs.Arrow_No_4 = 'X' THEN 1 ELSE 0 END +
            CASE WHEN rs.Arrow_No_5 = 'X' THEN 1 ELSE 0 END +
            CASE WHEN rs.Arrow_No_6 = 'X' THEN 1 ELSE 0 END) AS X_Count
    FROM Archer a
    JOIN ArcherScore rs ON a.Archer_ID = rs.Archer_ID
    JOIN RangeRoundCompetition rrc ON rs.Score_ID = rrc.Score_ID
    JOIN Rounds r ON rrc.Round_ID = r.Round_ID
    JOIN Competition c ON rrc.Competition_ID = c.Competition_ID
    WHERE c.Competition_Name = 'Brisbane' AND c.Competition_Date = '2020-02-14'
    GROUP BY a.Archer_ID, rrc.Competition_ID, rrc.Round_ID, r.Class_ID, r.Equipment_ID
) AS subquery
ORDER BY Round_Score DESC, X_Count DESC;

--Retrieve the list all archers who are eligible to participate in all rounds for "50+ Male”. This information can be useful for event organisers, coaches, or participants themselves to ensure that only eligible archers are allowed to compete in rounds specifically designed for the "50+ Male" category. 

SELECT a.Archer_ID, CONCAT(a.First_Name, ' ', a.Last_Name) AS Archer_Name, a.Age, a.Gender, c.Class_Gender, c.Class_Age AS Limit_Age
FROM Archer a
JOIN Class c ON a.Gender = c.Class_Gender
WHERE c.Class_Gender = 'Male' AND c.Class_Age = '50' AND
    CASE
        WHEN Min_Max = 'Min' THEN a.Age > c.Class_Age
        WHEN Min_Max = 'Max' THEN a.Age < c.Class_Age
    END
ORDER BY a.Age ASC;

--Recorders can verify the score that has been staged by archers. This is to enhance the data accuracy and credibility of the staged score. Below is the example of verifying the end score of archer Florence Last Kiara (ID: 26).

SELECT rs.Archer_ID, CONCAT(a.First_Name, ' ', a.Last_Name) AS Archer_Name, rrc.Score_ID, rrc.Round_ID, rrc.Range_Count, rs.End_No, rs.End_Score, rs.Verified  
FROM ArcherScore rs
JOIN Archer a ON a.Archer_ID = rs.Archer_ID
JOIN RangeRoundCompetition rrc ON rrc.Score_ID = rs.Score_ID
WHERE rs.Archer_ID = '26' AND Verified = FALSE;

UPDATE ArcherScore
SET Verified = TRUE
WHERE Archer_ID = '26' AND Score_ID = '20' AND End_No = '4';

SELECT * FROM ArcherScore WHERE Archer_ID = '26' AND Score_ID = '20' AND End_No = '4';

--Retrieve list of competitions including both championship’s and independent competitions. Having a consolidated list of competitions helps in organising events or tournaments for better plan and management, identifying and avoiding clashes or overlaps between championships and independent competitions. Thus, the club can allocate resources effectively, and schedule events strategically.

SELECT c.Competition_ID, c.Competition_Date, c.Competition_Name, c.Round_ID, 
CASE 
    WHEN ch.Championship_Name IS NULL THEN 'None'
    ELSE ch.Championship_Name
END AS Championship_Name
FROM Competition c
LEFT JOIN Championship ch ON ch.Championship_ID = c.Championship_ID;

--Archer Jerry Sims (ID: 1) look up their scores sorted by the competition date and score in descending order. This helps in evaluating his performance over time and assessing his progress, identifying any patterns or trends, and understanding his strengths and weaknesses in different competitions.

 SELECT DISTINCT c.Competition_ID, c.Competition_Date, rrc.Round_ID, rrc.Range_ID, rrc.Range_Count, rs.Score_ID, rs.End_No,
  CONCAT(
    rs.Arrow_No_1, ',', rs.Arrow_No_2, ',', rs.Arrow_No_3, ',',
    rs.Arrow_No_4, ',', rs.Arrow_No_5, ',', rs.Arrow_No_6
  ) AS Arrows_Scores, rs.End_Score,
  SUM(rs.End_Score) OVER (PARTITION BY rs.Score_ID) AS Range_Score,
  SUM(rs.End_Score) OVER (PARTITION BY rrc.Competition_ID) AS Round_Score
FROM ArcherScore rs
JOIN RangeRoundCompetition rrc ON rs.Score_ID = rrc.Score_ID
JOIN Competition c ON rrc.Competition_ID = c.Competition_ID 
WHERE rs.Archer_ID = '1' AND rs.Verified = TRUE
ORDER BY c.Competition_Date DESC, Round_Score DESC;

--Archer Jerry Sims’s scores are restricted by date range and round ID. By limiting scores by date range, it becomes possible to analyse Jerry's performance within a particular timeframe. This can help in tracking his progress and identifying any trends or improvements in his scores during that time. On the other hand, restricting the scores by round ID allows for focusing on a specific type of round. This helps in evaluating Jerry's performance in a particular type of competition or round format, enabling a more targeted analysis to identify specific strengths or weaknesses in that particular round and make adjustments accordingly.

SELECT DISTINCT c.Competition_ID, c.Competition_Date, rrc.Round_ID, rrc.Range_ID, rrc.Range_Count, rs.Score_ID, rs.End_No,
  CONCAT(
    rs.Arrow_No_1, ',', rs.Arrow_No_2, ',', rs.Arrow_No_3, ',',
    rs.Arrow_No_4, ',', rs.Arrow_No_5, ',', rs.Arrow_No_6
  ) AS Arrows_Scores, rs.End_Score,
  SUM(rs.End_Score) OVER (PARTITION BY rs.Score_ID) AS Range_Score,
  SUM(rs.End_Score) OVER (PARTITION BY rrc.Competition_ID) AS Round_Score
FROM ArcherScore rs
JOIN RangeRoundCompetition rrc ON rs.Score_ID = rrc.Score_ID
JOIN Competition c ON rrc.Competition_ID = c.Competition_ID 
WHERE  rs.Archer_ID = '1'
  AND c.Competition_Date >= '2020-01-01'
  AND c.Competition_Date <= '2020-06-01'
  AND rrc.Round_ID = 'Perth' 
  AND rs.Verified = TRUE
ORDER BY c.Competition_Date DESC, Round_Score DESC;

--Jerry can enter each of his arrow score and the system will auto-aggregate the list of arrow scores to return the total end score. Unless the recorder has verified Jerry’s staged score, the “Verified” attribute will be set to False (“0”).  

SELECT Round_ID, c.Class_Age, c.Class_Gender, e.Equipment_Desc 
FROM Rounds
JOIN Class c ON c.Class_ID = Rounds.Class_ID
JOIN Equipment e ON e.Equipment_ID = Rounds.Equipment_ID;

--For more detailed information of every round, archers can also retrieve the ranges that are held within a round. 

SELECT DISTINCT r.Round_ID, cl.Class_Age, cl.Min_Max, cl.Class_Gender, e.Equipment_Desc, rrc.Range_ID, c.Range_Distance, c.Number_Of_Ends, c.Face_Size,
       SUM(c.Number_Of_Ends) OVER (PARTITION BY r.Round_ID) AS Total_Number_Of_Ends
FROM Rounds r
JOIN Class cl ON r.Class_ID = cl.Class_ID
JOIN Equipment e ON r.Equipment_ID = e.Equipment_ID
JOIN RangeRoundCompetition rrc ON r.Round_ID = rrc.Round_ID
JOIN Ranges c ON rrc.Range_ID = c.Range_ID;

--Archers can also find out equivalent rounds (i.e rounds with similar class). Hence, they can assess the transferability of their skills and performance across different rounds. They can determine if their performance in one round can be a reference point to assess the performance in another round with similar characteristics, thus, make informed decisions about participating in different rounds to maximise their performance. 

SELECT r1.Round_ID AS Round_ID1, r2.Round_ID AS Round_ID2, c.Class_Gender, c.Class_Age, c.Min_Max
FROM Rounds r1
JOIN Rounds r2 ON r1.Class_ID = r2.Class_ID 
JOIN Class c ON c.Class_ID = r1.Class_ID
WHERE r1.Round_ID < r2.Round_ID; -- to return only one pair of rounds, excluding duplicates & reversing the order pairs

--Archer Jerry Sim can look up for his best personal score among the rounds held at different times. This way Jerry can assess his strengths and weaknesses, understand what led to his highest performance, and determine strategies to replicate or surpass that performance in future rounds.

SELECT subquery.*, MAX(Round_Score) AS Personal_Best_Score
FROM (
     SELECT comp.Competition_ID, comp.Competition_Date, comp.Competition_Name, rrc.Round_ID, r.Class_ID, e.Equipment_Desc AS Equipment,
        SUM(rs.End_Score) OVER (PARTITION BY rrc.Competition_ID) AS Round_Score
    FROM ArcherScore rs 
    JOIN RangeRoundCompetition rrc ON rs.Score_ID = rrc.Score_ID
    JOIN Competition comp ON rrc.Competition_ID = comp.Competition_ID
    JOIN Rounds r ON rrc.Round_ID = r.Round_ID 
    JOIN Equipment e ON r.Equipment_ID = e.Equipment_ID
    WHERE rs.Archer_ID = '1'
) AS subquery
GROUP BY Competition_ID, Round_ID, Round_Score
ORDER BY Personal_Best_Score DESC;

--Jerry can also look for his best performance among all rounds he has participated in. It allows him to understand his capabilities and achievements in a broader context, beyond individual rounds. This information helps him self-estimate his proficiency level and compare his performance against other archers.

SELECT subquery.*
FROM (
    SELECT comp.Competition_ID, comp.Competition_Date, comp.Competition_Name, rrc.Round_ID, r.Class_ID, e.Equipment_Desc AS Equipment,
        SUM(rs.End_Score) OVER (PARTITION BY rrc.Competition_ID) AS Round_Score
    FROM ArcherScore rs 
    JOIN RangeRoundCompetition rrc ON rs.Score_ID = rrc.Score_ID
    JOIN Competition comp ON rrc.Competition_ID = comp.Competition_ID
    JOIN Rounds r ON rrc.Round_ID = r.Round_ID 
    JOIN Equipment e ON r.Equipment_ID = e.Equipment_ID
    WHERE rs.Archer_ID = '1'
) AS subquery
ORDER BY Round_Score DESC
LIMIT 1;

