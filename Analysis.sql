--Enhanced User Profile Analysis with Authentic Demographics--
SELECT 
    user_id,
    name,
    age,
    gender,
    height_cm,
    email,
    created_at,
    CASE 
        WHEN age BETWEEN 18 AND 30 THEN 'Young Adult'
        WHEN age BETWEEN 31 AND 45 THEN 'Adult'
        WHEN age BETWEEN 46 AND 60 THEN 'Middle Age'
        ELSE 'Senior'
    END AS age_group
FROM Users
ORDER BY user_id
FETCH FIRST 5 ROWS ONLY;

--Authentic Gender Distribution with Age Insights--
SELECT 
    gender,
    COUNT(*) AS total_users,
    ROUND(AVG(age), 1) AS avg_age,
    ROUND(AVG(height_cm), 1) AS avg_height_cm,
    MIN(age) AS youngest,
    MAX(age) AS oldest
FROM Users
GROUP BY gender
ORDER BY total_users DESC;

--Comprehensive BMI Analysis with Health Risk Categories--
SELECT 
    u.user_id,
    u.name,
    u.age,
    h.weight_kg,
    h.height_cm,
    h.bmi,
    CASE 
        WHEN h.bmi < 18.5 THEN 'Underweight'
        WHEN h.bmi BETWEEN 18.5 AND 24.9 THEN 'Normal'
        WHEN h.bmi BETWEEN 25.0 AND 29.9 THEN 'Overweight'
        ELSE 'Obese'
    END AS bmi_category,
    h.check_date,
    h.heart_rate,
    h.systolic_bp,
    h.diastolic_bp
FROM Users u
JOIN Health_Metrics h ON u.user_id = h.user_id
WHERE h.check_date = (
    SELECT MAX(check_date) 
    FROM Health_Metrics h2 
    WHERE h2.user_id = h.user_id
)
ORDER BY h.bmi DESC;

--Authentic Activity Patterns with Weekly Variations--
SELECT 
    u.name,
    u.user_id,
    ROUND(AVG(d.steps), 0) AS avg_daily_steps,
    ROUND(STDDEV(d.steps), 0) AS steps_variation,
    MIN(d.steps) AS min_steps,
    MAX(d.steps) AS max_steps,
    COUNT(DISTINCT d.activity_date) AS active_days,
    ROUND(AVG(d.workout_minutes), 1) AS avg_workout_minutes,
    ROUND(AVG(d.water_litres), 1) AS avg_water_intake
FROM Users u
JOIN Daily_Activity_Log d ON u.user_id = d.user_id
WHERE d.activity_date >= SYSDATE - 30
GROUP BY u.user_id, u.name
HAVING COUNT(DISTINCT d.activity_date) >= 20
ORDER BY avg_daily_steps DESC
FETCH FIRST 5 ROWS ONLY;

--Top 5 Users with Most Steps in One Day--
SELECT *
FROM (
    SELECT u.name, d.activity_date, d.steps
    FROM Users u
    JOIN Daily_Activity_Log d ON u.user_id = d.user_id
    ORDER BY d.steps DESC
)
WHERE ROWNUM <= 5;

--Users who slept less than 6 hours on any day--
SELECT DISTINCT user_id, activity_date, sleep_hours
FROM Daily_Activity_Log
WHERE sleep_hours < 6;

 --Realistic Nutritional Analysis with Meal Quality Insights--
WITH daily_nutrition AS (
    SELECT 
        user_id,
        meal_date,
        SUM(calories) AS total_calories,
        SUM(protein_g) AS total_protein,
        SUM(carbs_g) AS total_carbs,
        SUM(fat_g) AS total_fat,
        COUNT(DISTINCT meal_type) AS meal_variety,
        COUNT(*) AS total_meals
    FROM Meal_Log
    GROUP BY user_id, meal_date
)
SELECT 
    u.name,
    dn.user_id,
    dn.meal_date,
    dn.total_calories,
    dn.total_protein,
    dn.total_carbs,
    dn.total_fat,
    ROUND(dn.total_protein * 4 / dn.total_calories * 100, 1) AS protein_ratio_pct,
    ROUND(dn.total_carbs * 4 / dn.total_calories * 100, 1) AS carbs_ratio_pct,
    ROUND(dn.total_fat * 9 / dn.total_calories * 100, 1) AS fat_ratio_pct,
    dn.meal_variety,
    CASE 
        WHEN dn.total_calories BETWEEN 1800 AND 2200 THEN 'Balanced'
        WHEN dn.total_calories < 1800 THEN 'Low Intake'
        ELSE 'High Intake'
    END AS calorie_category
FROM daily_nutrition dn
JOIN Users u ON dn.user_id = u.user_id
WHERE dn.meal_date >= SYSDATE - 7
ORDER BY dn.total_calories DESC;

--Users who consumed more than 2000 calories in a day--
select user_id,meal_date,sum(calories) as total_calories from meal_log
group by user_id, meal_date
having sum(calories)>=2000;

--Average protein, carbs, fat per user--
select user_id,round(avg(protein_g),2) as protein_avg,
round(avg(carbs_g),2) as carbs_avg,
round(avg(fat_g),2) as fat_avg
from meal_log
group by user_id;

/*Health Metrics Insights
 Users with high blood pressure (e.g., systolic > 130)*/
 select user_id,health_metrics.check_date,health_metrics.diastolic_bp,health_metrics.systolic_bp from health_metrics
 where health_metrics.systolic_bp >130;
 
 --Average BMI and weight per user--
 select user_id,
 round(avg(weight_kg),2) as weight_avg,
 round(avg(bmi),2) as bmi_avg
 from health_metrics
 GROUP BY user_id;

/*Progress Tracking
 BMI trend for a specific user*/
 
 select check_date,bmi from health_metrics
 where user_id =12
 order by check_date;


-- Daily water intake vs. sleep pattern--
select user_id,activity_date,workout_minutes,sleep_hours,water_litres
from daily_activity_log
order by sleep_hours,water_litres;

 --Top 5 Users by Average Steps in Last 7 Days--

 
 select * from
 (select u.name, round(AVG(d.steps)) as steps_avg
 from users u
 join daily_activity_log d on u.user_id=d.user_id
 where d.activity_date>= sysdate -7
 group by u.name
 order by steps_avg desc)
 where rownum>=5;
 
 --Users Who Burned > 6000 Calories in 3 Days (Approx)--
 SELECT user_id,meal_date,sum(calories) as total_calories
 from meal_log
 group by user_id,meal_date
  HAVING sum(calories)>6000
 order by total_calories DESC

--Average Sleep Hours Per User--
select u.name,d.activity_date,round(avg(d.sleep_hours),2) as avg_sleep
from Users u
join Daily_Activity_Log d on u.user_id = d.user_id
group by u.name,d.activity_date
order by avg_sleep desc;

--Comprehensive Health Risk Assessment--
WITH health_risk_analysis AS (
    SELECT 
        u.user_id,
        u.name,
        u.age,
        h.check_date,
        h.weight_kg,
        h.bmi,
        h.systolic_bp,
        h.diastolic_bp,
        h.heart_rate,
        CASE 
            WHEN h.systolic_bp >= 140 OR h.diastolic_bp >= 90 THEN 'High Risk'
            WHEN h.systolic_bp >= 130 OR h.diastolic_bp >= 85 THEN 'Moderate Risk'
            WHEN h.systolic_bp >= 120 OR h.diastolic_bp >= 80 THEN 'Elevated'
            ELSE 'Normal'
        END AS bp_risk,
        CASE 
            WHEN h.bmi >= 30 THEN 'Obese'
            WHEN h.bmi >= 25 THEN 'Overweight'
            WHEN h.bmi < 18.5 THEN 'Underweight'
            ELSE 'Normal'
        END AS bmi_category,
        CASE 
            WHEN h.heart_rate > 100 THEN 'High'
            WHEN h.heart_rate < 60 THEN 'Low'
            ELSE 'Normal'
        END AS heart_rate_status
    FROM Users u
    JOIN Health_Metrics h ON u.user_id = h.user_id
    WHERE h.check_date = (
        SELECT MAX(check_date) 
        FROM Health_Metrics h2 
        WHERE h2.user_id = h.user_id
    )
)
SELECT 
    name,
    age,
    bmi,
    systolic_bp,
    diastolic_bp,
    heart_rate,
    bp_risk,
    bmi_category,
    heart_rate_status,
    CASE 
        WHEN bp_risk = 'High Risk' OR bmi_category = 'Obese' THEN 'Critical'
        WHEN bp_risk = 'Moderate Risk' OR bmi_category = 'Overweight' THEN 'Needs Attention'
        ELSE 'Healthy'
    END AS overall_risk_level
FROM health_risk_analysis
ORDER BY 
    CASE overall_risk_level 
        WHEN 'Critical' THEN 1 
        WHEN 'Needs Attention' THEN 2 
        ELSE 3 
    END;

-- Users with BMI Out of Healthy Range (18.5 � 24.9)--
select u.name,h.check_date,h.weight_kg,h.bmi
from users u
join health_metrics h on u.user_id = h.user_id
where h.bmi >18.5 or h.bmi>24.9
order by h.bmi desc;

--Users Drinking Less Than 2 Litres Water on Any Day--
select u.name,d.activity_date,d.water_litres
from Users u
join daily_activity_log d on u.user_id = u.user_id
where d.water_litres <2
order by d.water_litres desc;

--Users Who Did Workouts More Than 45 Min in a Day--
select u.name, d.activity_date,d.workout_minutes
from Users u
join daily_activity_log d on u.user_id = d.user_id
where d.workout_minutes >=45
order by d.workout_minutes desc;

--Day-wise Total Steps by All Users--
select u.name,d.activity_date,sum(d.steps)as total_steps
from users u
join daily_activity_log d on u.user_id = d.user_id
group by u.name,d.activity_date
order by d.activity_date;

--Rank Users by Average Steps (Last 7 Days)--
select u.name,d.activity_date,round(avg(d.steps),0) as avg_steps,
dense_rank() over(order by avg(d.steps)desc)as step_rank
from users u
join daily_activity_log d on u.user_id = d.user_id
where d.activity_date >= sysdate-7
group by u.name,d.activity_date;

--Moving Average of Water Intake for Each User (Last 3 Days Window)--
SELECT 
    user_id,
    activity_date,
    water_litres,
    ROUND(AVG(water_litres) OVER (
        PARTITION BY user_id ORDER BY activity_date 
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ), 2) AS moving_avg_water
FROM Daily_Activity_Log
ORDER BY user_id, activity_date;

--Join Users + Daily_Activity + Health_Metrics on Same Day--
select u.name,
d.activity_date,
d.steps,d.sleep_hours,
h.weight_kg,
h.bmi,
h.systolic_bp,
h.diastolic_bp
from users u 
join daily_activity_log d on u.user_id = d.user_id
join health_metrics h on u.user_id = h.user_id and d.activity_date = h.check_date
 order by d.activity_date;
 
 -- Find Calorie Intake Trend and Difference from Previous Day--
 SELECT 
    user_id,
    meal_date,
    SUM(calories) AS total_calories,
    SUM(calories) - LAG(SUM(calories)) OVER (
        PARTITION BY user_id ORDER BY meal_date
    ) AS calorie_diff
FROM Meal_Log
GROUP BY user_id, meal_date
ORDER BY user_id, meal_date;

--Cumulative Steps Over Time per User--
SELECT 
    user_id,
    activity_date,
    steps,
    SUM(steps) OVER (
        PARTITION BY user_id ORDER BY activity_date
    ) AS cumulative_steps
FROM Daily_Activity_Log
ORDER BY user_id, activity_date;

--Realistic Health Progression Tracking--
WITH health_progression AS (
    SELECT 
        u.user_id,
        u.name,
        h.check_date,
        h.weight_kg,
        h.bmi,
        h.systolic_bp,
        h.diastolic_bp,
        h.heart_rate,
        ROW_NUMBER() OVER (PARTITION BY u.user_id ORDER BY h.check_date) AS measurement_order,
        LAG(h.weight_kg) OVER (PARTITION BY u.user_id ORDER BY h.check_date) AS prev_weight,
        LAG(h.bmi) OVER (PARTITION BY u.user_id ORDER BY h.check_date) AS prev_bmi
    FROM Users u
    JOIN Health_Metrics h ON u.user_id = h.user_id
)
SELECT 
    name,
    check_date,
    weight_kg,
    bmi,
    systolic_bp,
    diastolic_bp,
    heart_rate,
    CASE 
        WHEN prev_weight IS NOT NULL THEN 
            CASE 
                WHEN weight_kg < prev_weight - 0.5 THEN 'Weight Loss'
                WHEN weight_kg > prev_weight + 0.5 THEN 'Weight Gain'
                ELSE 'Stable'
            END
        ELSE 'Initial'
    END AS weight_trend,
    CASE 
        WHEN prev_bmi IS NOT NULL THEN 
            ROUND(bmi - prev_bmi, 2)
        ELSE 0
    END AS bmi_change
FROM health_progression
WHERE measurement_order <= 5
ORDER BY user_id, check_date;

--Advanced Lifestyle Correlation Analysis--
WITH lifestyle_correlations AS (
    SELECT 
        u.user_id,
        u.name,
        AVG(d.steps) AS avg_steps,
        AVG(d.workout_minutes) AS avg_workout,
        AVG(d.sleep_hours) AS avg_sleep,
        AVG(d.water_litres) AS avg_water,
        AVG(m.total_calories) AS avg_calories,
        AVG(h.bmi) AS avg_bmi,
        AVG(h.systolic_bp) AS avg_systolic
    FROM Users u
    JOIN Daily_Activity_Log d ON u.user_id = d.user_id
    JOIN (
        SELECT user_id, meal_date, SUM(calories) AS total_calories
        FROM Meal_Log
        GROUP BY user_id, meal_date
    ) m ON u.user_id = m.user_id AND d.activity_date = m.meal_date
    JOIN Health_Metrics h ON u.user_id = h.user_id
    WHERE d.activity_date >= SYSDATE - 14
    GROUP BY u.user_id, u.name
)
SELECT 
    name,
    ROUND(avg_steps, 0) AS avg_daily_steps,
    ROUND(avg_workout, 1) AS avg_workout_minutes,
    ROUND(avg_sleep, 1) AS avg_sleep_hours,
    ROUND(avg_water, 1) AS avg_water_litres,
    ROUND(avg_calories, 0) AS avg_daily_calories,
    ROUND(avg_bmi, 1) AS avg_bmi,
    ROUND(avg_systolic, 0) AS avg_systolic_bp,
    CASE 
        WHEN avg_steps > 8000 AND avg_workout > 30 AND avg_sleep >= 7 THEN 'Healthy Lifestyle'
        WHEN avg_steps < 5000 OR avg_workout < 15 THEN 'Needs More Activity'
        WHEN avg_sleep < 6 THEN 'Poor Sleep Pattern'
        WHEN avg_bmi > 25 THEN 'Weight Management Needed'
        ELSE 'Moderate Health'
    END AS lifestyle_category
FROM lifestyle_correlations
ORDER BY avg_bmi;




