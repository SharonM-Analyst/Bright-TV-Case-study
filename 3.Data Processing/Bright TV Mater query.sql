-- Databricks notebook source

--==============================================================================================
-- Table Preview
--==============================================================================================
SELECT (*) FROM `workspace`.`default`.`tv_viewship`;


--=============================================================================================
---Understanding The Data set
--=============================================================================================

-- FROM VIEWER TABLE

--- Date Range
SELECT 
     MIN(from_utc_timestamp(v.RecordDate2, 'Africa/Johannesburg')) AS Earliest,
     MAX(from_utc_timestamp(v.RecordDate2, 'Africa/Johannesburg')) AS Latest
FROM `workspace`.`default`.`tv_viewship` AS v
LEFT JOIN `workspace`.`default`.`TV_UserProfile` AS u
ON v.UserID0 = u.UserID;
-- 2016-01-01 TO 2016-04-01

-- Different Channels
SELECT DISTINCT Channel2 FROM `workspace`.`default`.`tv_viewship`;
-- 21 Different Channels.


--Total Viewers OR Active Users
SELECT COUNT(DISTINCT UserID0) FROM `workspace`.`default`.`tv_viewship`;



-- FROM USER_PROFILE TABLE

--- Gender
SELECT DISTINCT Gender FROM `workspace`.`default`.`TV_UserProfile`;

--- Race
SELECT DISTINCT Race 
FROM `workspace`.`default`.`TV_UserProfile`;
-- We have white,black,coloured,other,None,indian_asian


---  Check the youngest Age and oldest
SELECT
MAX(Age) OLDEST,
MIN(Age) YOUNGEST
FROM `workspace`.`default`.`TV_UserProfile`;
--- Youngest 0 and oldest 114


--- Check Diiferent Types of Province Province
SELECT DISTINCT Province FROM `workspace`.`default`.`TV_UserProfile`;
--we have 9 south African Provinces and 1 Unknown



--==============================================================================================
-- Data Cleaning & Joining(Viewship Left joined to User_profile )
--==============================================================================================


-- 1. Converting Nones to Unknowns Good for PowerBI  
SELECT 
    v.UserID0,

    -- Cleaned Columns (Replace 'None' as Unkwown properly)
    CASE 
        WHEN u.Gender = 'None' OR u.Gender IS NULL THEN 'Unknown'
        ELSE u.Gender
    END AS Gender,

    CASE 
        WHEN u.Race = 'None' OR u.Race IS NULL THEN 'Unknown'
        ELSE u.Race
    END AS Race,

    CASE 
        WHEN u.Province = 'None' OR u.Province IS NULL THEN 'Unknown'
        ELSE u.Province
    END AS Province,

    CASE 
        WHEN v.Channel2 = 'None' OR v.Channel2 IS NULL THEN 'Unknown'
        ELSE v.Channel2
    END AS Channel,


    v.RecordDate2,
    v.`Duration 2`

FROM `workspace`.`default`.`tv_viewship` v
LEFT JOIN `workspace`.`default`.`TV_UserProfile` u 
ON v.UserID0 = u.UserID;


--- 2. CHECK FOR NULLS 
SELECT 
          v.UserID0,
          u.Race,
          u.Gender,
          u.Age,
          u.Province,
          v.Channel2 AS Channel

FROM          `workspace`.`default`.`tv_viewship` v
LEFT JOIN    `workspace`.`default`.`TV_UserProfile` u 
ON            v.UserID0 = u.UserID
WHERE Gender IS NULL OR 
      Race IS NULL OR 
      Age IS NULL OR 
      Province IS NULL OR 
      Channel2 IS NULL OR 
      `Duration 2` IS NULL OR
      RecordDate2 IS NULL OR
      v.UserID0 IS NULL;





 --- 3. Check For Duplicates
SELECT 
    v.UserID0,
    from_utc_timestamp(v.RecordDate2, 'Africa/Johannesburg') AS RecordDate_SA,
    v.Channel2,
    date_format(v.`Duration 2`, 'HH:mm:ss') as Duration,
    u.Race,
    u.Gender,
    u.Age,
    u.Province,
    COUNT(*) AS duplicate_count

FROM `workspace`.`default`.`tv_viewship` v
LEFT JOIN `workspace`.`default`.`TV_UserProfile` u 
    ON v.UserID0 = u.UserID
GROUP BY ALL
HAVING COUNT(*) > 1;
-- There are 10 duplicates

SELECT *
FROM (
    SELECT 
        v.UserID0,
        from_utc_timestamp(v.RecordDate2, 'Africa/Johannesburg') AS RecordDate_SA,
        v.Channel2,
        date_format(v.`Duration 2`, 'HH:mm:ss') as Duration,
        u.Race,
        u.Gender,
        u.Age,
        u.Province,
        
        --WINDOW FUNCTION
        COUNT(*) OVER (
            PARTITION BY 
                v.UserID0,
                v.RecordDate2,
                v.Channel2,
                v.`Duration 2`,
                u.Race,
                u.Gender,
                u.Age,
                u.Province
        ) AS dup_count

    FROM `workspace`.`default`.`tv_viewship` v
    LEFT JOIN `workspace`.`default`.`TV_UserProfile` u 
        ON v.UserID0 = u.UserID
) t
WHERE dup_count > 1;


-- Calculate total and average watch minutes per user, then get max/min across users
WITH user_watch AS (
    SELECT
        v.UserID0,
        ROUND(
            AVG(
                (EXTRACT(HOUR FROM v.`Duration 2`) * 60) +
                EXTRACT(MINUTE FROM v.`Duration 2`)
            ), 2
        ) AS Avg_Watch_Minutes,
        SUM(
            (EXTRACT(HOUR FROM v.`Duration 2`) * 60) +
            EXTRACT(MINUTE FROM v.`Duration 2`)
        ) AS Total_Watch_Minutes
    FROM `workspace`.`default`.`tv_viewship` v
    LEFT JOIN `workspace`.`default`.`TV_UserProfile` u
        ON v.UserID0 = u.UserID
    GROUP BY v.UserID0
)
SELECT
    COUNT(*) AS View_Count,
    ROUND(AVG(Avg_Watch_Minutes), 2) AS Avg_Watch_Minutes,
    MAX(Total_Watch_Minutes) AS Max_Watch_Minutes,
    MIN(Total_Watch_Minutes) AS Min_Watch_Minutes
FROM user_watch;


--======================================================================================================================
-- Data CLeaning, Feature Engineering & Exploratory Analysis (Master Query)
--======================================================================================================================

--- Multiple Standalone CTE (COMMON TABLE EXPRESSION) Definnition
WITH brighttv AS (
    SELECT DISTINCT
        v.UserID0,
        from_utc_timestamp(v.RecordDate2, 'Africa/Johannesburg') AS RecordDate_SA,
        v.`Duration 2`,

        -- CLEAN DURATION
        CASE 
            WHEN v.`Duration 2` IS NULL 
                 OR TRIM(v.`Duration 2`) = '' 
                 
            THEN 0

            ELSE ABS(
                HOUR(v.`Duration 2`) * 3600 +
                MINUTE(v.`Duration 2`) * 60 +
                SECOND(v.`Duration 2`)
            )
        END AS duration_seconds,
        
        CASE 
            WHEN v.Channel2 IS NULL OR TRIM(v.Channel2) = '' OR v.Channel2 = 'None' THEN 'Unknown'
            ELSE v.Channel2
        END AS channel,
        
        CASE 
            WHEN u.Age BETWEEN 0 AND 114 THEN u.Age
            ELSE NULL
        END AS age,
        
        CASE 
            WHEN u.Gender IS NULL OR TRIM(u.Gender) = '' OR u.Gender = 'None' THEN 'Unknown'
            ELSE INITCAP(TRIM(u.Gender))
        END AS gender,

        CASE 
            WHEN u.Race IS NULL OR TRIM(u.Race) = '' OR u.Race = 'None' OR u.Race = 'other/none comined' THEN 'Unknown'
            ELSE INITCAP(TRIM(u.Race))
        END AS race,

        CASE 
            WHEN u.Province IS NULL OR TRIM(u.Province) = '' OR u.Province = 'None' THEN 'Unknown'
            WHEN LOWER(REPLACE(TRIM(u.Province), ' ', '')) = 'kwazulunatal' THEN 'KwaZulu-Natal'
            ELSE INITCAP(TRIM(u.Province))
        END AS province

    FROM `workspace`.`default`.`tv_viewship` v
    LEFT JOIN `workspace`.`default`.`TV_UserProfile` u 
        ON v.UserID0 = u.UserID

),

-- USER ACTIVITY (NESTED CTE DEPENDING ON BRIGHTTV CTE)
user_activity AS (
    SELECT 
        UserID0,
        COUNT(*) AS total_sessions,
        COUNT(DISTINCT DATE(RecordDate_SA)) AS active_days
    FROM brighttv
    GROUP BY UserID0
    
),

-- RETENTION CTE (NESTED CTE DEPENDING ON USER_ACTIVITY CTE)
retention_calc AS (
    SELECT 
        COUNT(DISTINCT CASE WHEN active_days > 1 THEN UserID0 END) * 1.0
        / COUNT(DISTINCT UserID0) AS retention_rate
    FROM user_activity
),

-- CHURN INDICATOR CTE (NESTED CTE DEPENDING ON USER_ACTIVITY CTE)
churn_calc AS (
    SELECT 
        COUNT(*) AS churn_users
    FROM user_activity
    WHERE total_sessions <= 2
),

-- SESSIONS PER USER CTE (NESTED CTE DEPENDING ON BRIGHTTV CTE)
sessions_per_user_calc AS (
    SELECT 
        COUNT(*) * 1.0 / COUNT(DISTINCT UserID0) AS sessions_per_user
    FROM brighttv
),

-- DAILY USERS CTE (NESTED CTE DEPENDING ON BRIGHTTV CTE)
daily_users AS (
    SELECT 
        DATE(RecordDate_SA) AS date,
        COUNT(DISTINCT UserID0) AS DAU
    FROM brighttv
    GROUP BY DATE(RecordDate_SA)
),

-- MONTHLY USERS CTE (NESTED CTE DEPENDING ON BRIGHTTV CTE)
monthly_users AS (
    SELECT 
        MONTH(RecordDate_SA) AS month,
        COUNT(DISTINCT UserID0) AS MAU
    FROM brighttv
    GROUP BY MONTH(RecordDate_SA)
),

-- STICKINESS RATIO CTE (NESTED CTE DEPENDING ON DAILY_USERS CTE)
stickiness_calc AS (
    SELECT 
        AVG(d.DAU) * 1.0 / AVG(m.MAU) AS stickiness_ratio
    FROM daily_users d
    JOIN monthly_users m
    ON MONTH(d.date) = m.month
),

-- GROWTH RATE CTE NESTED CTE DEPENDING ON DAILY_USERS CTE)
growth_calc AS (
    SELECT 
        date,
        DAU,
        LAG(DAU) OVER (ORDER BY date) AS prev_DAU,
        (DAU - LAG(DAU) OVER (ORDER BY date)) * 1.0
        / LAG(DAU) OVER (ORDER BY date) AS growth_rate
    FROM daily_users
),
--AVG GROWTH RATE CTE NESTED CTE DEPENDING ON GROWTH_CALC CTE)
avg_growth AS (
    SELECT AVG(growth_rate) AS avg_growth_rate
    FROM growth_calc
)

-- FINAL MAIN QUERY
SELECT 

-- IDENTIFIERS
    b.UserID0,

-- DATE FEATURES
    date_format(b.RecordDate_SA, 'yyyy-MM-dd') AS User_Engagement_date,
    date_format(b.RecordDate_SA, 'EEEE') AS Day_Of_Week,

    CASE
        WHEN date_format(b.RecordDate_SA, 'EEEE') IN ('Sunday', 'Saturday') THEN 'Weekend'
        ELSE 'Weekday'
    END AS day_category,

    date_format(b.RecordDate_SA, 'HH:mm:ss') AS Time,

    CASE
        WHEN date_format(b.RecordDate_SA, 'HH:mm:ss') BETWEEN '00:00:00' AND '11:59:00' THEN 'Morning'
        WHEN date_format(b.RecordDate_SA, 'HH:mm:ss') BETWEEN '12:00:00' AND '16:59:00' THEN 'Afternoon'
        WHEN date_format(b.RecordDate_SA, 'HH:mm:ss') BETWEEN '17:00:00' AND '21:59:00' THEN 'Evening'
        ELSE 'Night'
    END AS Time_group,

    date_format(b.RecordDate_SA, 'MMMM') AS Month_name,

    CASE
        WHEN day(b.RecordDate_SA) BETWEEN 1 AND 10 THEN 'Beginning of Month'
        WHEN day(b.RecordDate_SA) BETWEEN 11 AND 20 THEN 'Mid of Month'
        ELSE 'End of Month'
    END AS month_pattern,

-- DURATION METRICS

    date_format(b.`Duration 2`, 'HH:mm:ss') AS Duration_time,
    ROUND(SUM(b.duration_seconds) / 3600, 2) AS Total_Watch_Hours,
    ROUND(AVG(b.duration_seconds) / 3600, 2) AS Avg_Watch_Hours,

-- CHANNEL
    b.channel,
    COUNT(b.channel) AS Total_Channel_Views,
    COUNT(DISTINCT b.channel) AS Total_Channels,

-- DEMOGRAPHICS
    b.age,
    CASE
        WHEN b.age BETWEEN 0 AND 12 THEN 'Children_0-12'
        WHEN b.age BETWEEN 13 AND 19 THEN 'Teen_13-19'
        WHEN b.age BETWEEN 20 AND 39 THEN 'Young_Adults_20-39'
        WHEN b.age BETWEEN 40 AND 59 THEN 'Middle_Aged_Adults_40-59'
        WHEN b.age >= 60 THEN 'Seniors_60+'
        ELSE 'Unknown'
    END AS Age_Basket,

    ROUND(AVG(b.age), 0) AS Average_Age,
    b.gender,
    b.race,
    b.province,

-- VIEWERSHIP
    COUNT(b.UserID0) AS Total_Viewership,
    COUNT(DISTINCT b.UserID0) AS Total_Customers,

-- KPIs
    r.retention_rate,
    s.stickiness_ratio,
    spu.sessions_per_user,
    c.churn_users,
    g.avg_growth_rate,

-- WATCH CATEGORY
    CASE
        WHEN SUM(b.duration_seconds) / 3600 <= 4 THEN 'Light Viewer (0-4 hours)'
        WHEN SUM(b.duration_seconds) / 3600 <= 8 THEN 'Moderate Viewer (5-8 hours)'
        WHEN SUM(b.duration_seconds) / 3600 <= 12 THEN 'Active Viewer (9-12 hours)'
        WHEN SUM(b.duration_seconds) / 3600 <= 16 THEN 'Heavy Viewer (13-16 hours)'
        ELSE 'Super Viewer (17+ hours)'
    END AS Watch_Category

FROM brighttv b

-- CROSS JOIN THE NESTED METRICS ON CTE
CROSS JOIN retention_calc r
CROSS JOIN stickiness_calc s
CROSS JOIN sessions_per_user_calc spu
CROSS JOIN churn_calc c
CROSS JOIN avg_growth g

GROUP BY ALL;





   
