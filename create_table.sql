-- 1. USERS TABLE
CREATE TABLE Users (
    user_id NUMBER PRIMARY KEY,
    name VARCHAR2(100) NOT NULL,
    age NUMBER CHECK (age BETWEEN 18 AND 100),
    gender VARCHAR2(10) CHECK (gender IN ('Male', 'Female', 'Other')),
    height_cm NUMBER CHECK (height_cm BETWEEN 120 AND 220),
    weight_kg NUMBER CHECK (weight_kg BETWEEN 30 AND 200),
    email VARCHAR2(255) UNIQUE,
    created_at DATE DEFAULT SYSDATE,
    updated_at DATE DEFAULT SYSDATE
);

-- 2. DAILY ACTIVITY LOG
CREATE TABLE Daily_Activity_Log (
    activity_id NUMBER PRIMARY KEY,
    user_id NUMBER REFERENCES Users(user_id),
    activity_date DATE NOT NULL,
    steps NUMBER CHECK (steps BETWEEN 0 AND 50000),
    workout_minutes NUMBER CHECK (workout_minutes BETWEEN 0 AND 480),
    sleep_hours NUMBER CHECK (sleep_hours BETWEEN 0 AND 24),
    water_litres NUMBER CHECK (water_litres BETWEEN 0 AND 10),
    UNIQUE (user_id, activity_date)
);

-- 3. MEAL LOG
CREATE TABLE Meal_Log (
    meal_id NUMBER PRIMARY KEY,
    user_id NUMBER REFERENCES Users(user_id),
    meal_date DATE NOT NULL,
    meal_type VARCHAR2(20) CHECK (meal_type IN ('Breakfast', 'Lunch', 'Dinner', 'Snack')),
    calories NUMBER CHECK (calories BETWEEN 0 AND 2000),
    protein_g NUMBER CHECK (protein_g BETWEEN 0 AND 100),
    carbs_g NUMBER CHECK (carbs_g BETWEEN 0 AND 300),
    fat_g NUMBER CHECK (fat_g BETWEEN 0 AND 100),
    meal_description VARCHAR2(500),
    created_at DATE DEFAULT SYSDATE
);

-- 4. HEALTH METRICS
CREATE TABLE Health_Metrics (
    metric_id NUMBER PRIMARY KEY,
    user_id NUMBER REFERENCES Users(user_id),
    check_date DATE NOT NULL,
    weight_kg NUMBER CHECK (weight_kg BETWEEN 30 AND 200),
    bmi NUMBER CHECK (bmi BETWEEN 10 AND 50),
    systolic_bp NUMBER CHECK (systolic_bp BETWEEN 70 AND 250),
    diastolic_bp NUMBER CHECK (diastolic_bp BETWEEN 40 AND 150),
    heart_rate NUMBER CHECK (heart_rate BETWEEN 40 AND 200),
    notes VARCHAR2(1000),
    created_at DATE DEFAULT SYSDATE
);
