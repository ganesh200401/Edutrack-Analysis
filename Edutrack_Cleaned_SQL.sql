Create database edutrack;
use edutrack;
CREATE TABLE students (
    Student_ID VARCHAR(20),
    Student_Name VARCHAR(100),
    Gender VARCHAR(20),
    Age INT,
    City VARCHAR(100),
    State VARCHAR(100),
    Education_Level VARCHAR(100),
    Admission_Year INT,
    Admission_Channel VARCHAR(100),
    Scholarship_Status VARCHAR(50),
    Student_Status VARCHAR(50)
);
CREATE TABLE courses (
    Course_ID VARCHAR(20),
    Course_Name VARCHAR(150),
    Department VARCHAR(100),
    Duration_Months INT,
    Course_Fee DECIMAL(12,2),
    Delivery_Mode VARCHAR(50),
    Course_Status VARCHAR(50)
);
CREATE TABLE teachers (
    Teacher_ID VARCHAR(20),
    Teacher_Name VARCHAR(100),
    Department VARCHAR(100),
    Experience_Years INT,
    Employment_Type VARCHAR(50),
    City VARCHAR(100)
);
CREATE TABLE performance (
    Performance_ID VARCHAR(20),
    Student_ID VARCHAR(20),
    Course_ID VARCHAR(20),
    Subject VARCHAR(100),
    Exam_Type VARCHAR(50),
    Exam_Date DATE,
    Max_Marks INT,
    Marks_Obtained DECIMAL(6,2)
);
CREATE TABLE attendance (
    Attendance_ID VARCHAR(20),
    Student_ID VARCHAR(20),
    Course_ID VARCHAR(20),
    Attendance_Date DATE,
    Classes_Held INT,
    Classes_Attended INT,
    Attendance_Status VARCHAR(50)
);
CREATE TABLE fees (
    Payment_ID VARCHAR(20),
    Student_ID VARCHAR(20),
    Course_ID VARCHAR(20),
    Fee_Type VARCHAR(50),
    Amount DECIMAL(12,2),
    Paid_Amount DECIMAL(12,2),
    Payment_Date DATE,
    Payment_Method VARCHAR(50),
    Payment_Status VARCHAR(50)
);
CREATE TABLE dropouts (
    Dropout_ID VARCHAR(20),
    Student_ID VARCHAR(20),
    Dropout_Date DATE,
    Dropout_Reason VARCHAR(150),
    Refund_Amount DECIMAL(12,2),
    Exit_Type VARCHAR(50)
);
show tables;
USE edutrack;

SELECT 'students' AS table_name, COUNT(*) AS row_count FROM students
UNION ALL
SELECT 'courses', COUNT(*) FROM courses
UNION ALL
SELECT 'teachers', COUNT(*) FROM teachers
UNION ALL
SELECT 'performance', COUNT(*) FROM performance
UNION ALL
SELECT 'attendance', COUNT(*) FROM attendance
UNION ALL
SELECT 'fees', COUNT(*) FROM fees
UNION ALL
SELECT 'dropouts', COUNT(*) FROM dropouts;

SELECT
    COUNT(*) AS total_rows,
    SUM(Student_ID IS NULL) AS null_student_id,
    SUM(Student_Name IS NULL) AS null_student_name,
    SUM(Gender IS NULL) AS null_gender,
    SUM(Age IS NULL) AS null_age,
    SUM(City IS NULL) AS null_city,
    SUM(State IS NULL) AS null_state,
    SUM(Education_Level IS NULL) AS null_education_level,
    SUM(Admission_Year IS NULL) AS null_admission_year,
    SUM(Admission_Channel IS NULL) AS null_admission_channel,
    SUM(Scholarship_Status IS NULL) AS null_scholarship,
    SUM(Student_Status IS NULL) AS null_student_status
FROM students;

set sql_safe_updates=0;
UPDATE students
SET Age = (
    SELECT avg_age
    FROM (
        SELECT ROUND(AVG(Age)) AS avg_age
        FROM students
        WHERE Age IS NOT NULL
    ) AS temp
)
WHERE Age IS NULL;

SELECT
    Student_ID,
    COUNT(*) AS duplicate_count
FROM students
GROUP BY Student_ID
HAVING COUNT(*) > 1;

SELECT *
FROM students
WHERE Student_ID IN (
    SELECT Student_ID
    FROM (
        SELECT Student_ID
        FROM students
        GROUP BY Student_ID
        HAVING COUNT(*) > 1
    ) AS d
);

DELETE FROM students
WHERE Student_ID IN (
    SELECT Student_ID
    FROM (
        SELECT Student_ID
        FROM students
        GROUP BY Student_ID
        HAVING COUNT(*) > 1
    ) AS d
)
AND Student_ID = 'S00100';

SELECT
    Gender,
    COUNT(*) AS cnt
FROM students
GROUP BY Gender;

UPDATE students
SET Age = (
    SELECT avg_age
    FROM (
        SELECT ROUND(AVG(Age)) AS avg_age
        FROM students
        WHERE Age IS NOT NULL
    ) x
)
WHERE Age IS NULL;

UPDATE students
SET Gender = 'Male'
WHERE Gender = 'M';

UPDATE students
SET Gender = 'Unknown'
WHERE Gender IS NULL;

SELECT DISTINCT City
FROM students;

UPDATE students
SET City = TRIM(City);

SELECT DISTINCT City
FROM students;

SELECT *
FROM students
WHERE Age < 15
   OR Age > 100;
   
UPDATE students
SET Age = NULL
WHERE Age < 15
   OR Age > 100;
   
UPDATE students
SET Age = (
    SELECT avg_age
    FROM (
        SELECT ROUND(AVG(Age)) AS avg_age
        FROM students
        WHERE Age IS NOT NULL
    ) AS x
)
WHERE Age IS NULL;

SELECT MIN(Age), MAX(Age), AVG(Age)
FROM students;

SELECT
    Admission_Year,
    COUNT(*) AS cnt
FROM students
GROUP BY Admission_Year
ORDER BY Admission_Year;

SELECT *
FROM students
WHERE Admission_Year < 2000
   OR Admission_Year > YEAR(CURDATE());
   
UPDATE students
SET Admission_Year = NULL
WHERE Admission_Year < 2000
   OR Admission_Year > YEAR(CURDATE());

SELECT MIN(Admission_Year),
       MAX(Admission_Year)
FROM students;

SELECT *
FROM students
WHERE Student_ID IN (
    SELECT Student_ID
    FROM (
        SELECT Student_ID
        FROM students
        GROUP BY Student_ID
        HAVING COUNT(*) > 1
    ) d
)
ORDER BY Student_ID;

USE edutrack;


-- =========================================================
-- 1. COURSES
-- =========================================================

-- CHECK: Duplicate Course_ID
SELECT Course_ID, COUNT(*) AS duplicate_count
FROM courses
GROUP BY Course_ID
HAVING COUNT(*) > 1;

-- SOLUTION: Remove duplicate Course_ID rows
DELETE c1
FROM courses c1
JOIN courses c2
  ON c1.Course_ID = c2.Course_ID
 AND c1.Course_ID IS NOT NULL
 AND c1.Course_ID > c2.Course_ID;

-- VERIFY
SELECT Course_ID, COUNT(*) AS duplicate_count
FROM courses
GROUP BY Course_ID
HAVING COUNT(*) > 1;


-- CHECK: NULL values
SELECT
    SUM(Course_ID IS NULL) AS null_course_id,
    SUM(Course_Name IS NULL) AS null_course_name,
    SUM(Department IS NULL) AS null_department,
    SUM(Duration_Months IS NULL) AS null_duration,
    SUM(Course_Fee IS NULL) AS null_course_fee,
    SUM(Delivery_Mode IS NULL) AS null_delivery_mode,
    SUM(Course_Status IS NULL) AS null_course_status
FROM courses;

-- SOLUTION
UPDATE courses
SET Course_Name = 'Unknown'
WHERE Course_Name IS NULL;

UPDATE courses
SET Department = 'Unknown'
WHERE Department IS NULL;

UPDATE courses
SET Delivery_Mode = 'Unknown'
WHERE Delivery_Mode IS NULL;

UPDATE courses
SET Course_Status = 'Unknown'
WHERE Course_Status IS NULL;

-- VERIFY
SELECT
    SUM(Course_Name IS NULL) AS null_course_name,
    SUM(Department IS NULL) AS null_department,
    SUM(Delivery_Mode IS NULL) AS null_delivery_mode,
    SUM(Course_Status IS NULL) AS null_course_status
FROM courses;


-- CHECK: Invalid Duration
SELECT *
FROM courses
WHERE Duration_Months <= 0
   OR Duration_Months > 60;

-- SOLUTION
UPDATE courses
SET Duration_Months = NULL
WHERE Duration_Months <= 0
   OR Duration_Months > 60;

-- VERIFY
SELECT *
FROM courses
WHERE Duration_Months <= 0
   OR Duration_Months > 60;



-- =========================================================
-- 2. TEACHERS
-- =========================================================

-- CHECK: Duplicate Teacher_ID
SELECT Teacher_ID, COUNT(*) AS duplicate_count
FROM teachers
GROUP BY Teacher_ID
HAVING COUNT(*) > 1;

-- SOLUTION
DELETE t1
FROM teachers t1
JOIN teachers t2
  ON t1.Teacher_ID = t2.Teacher_ID
 AND t1.Teacher_ID IS NOT NULL
 AND t1.Teacher_ID > t2.Teacher_ID;

-- VERIFY
SELECT Teacher_ID, COUNT(*) AS duplicate_count
FROM teachers
GROUP BY Teacher_ID
HAVING COUNT(*) > 1;


-- CHECK: NULL values
SELECT
    SUM(Teacher_ID IS NULL) AS null_teacher_id,
    SUM(Teacher_Name IS NULL) AS null_teacher_name,
    SUM(Department IS NULL) AS null_department,
    SUM(Experience_Years IS NULL) AS null_experience,
    SUM(Employment_Type IS NULL) AS null_employment,
    SUM(City IS NULL) AS null_city
FROM teachers;

-- SOLUTION
UPDATE teachers
SET Teacher_Name = 'Unknown'
WHERE Teacher_Name IS NULL;

UPDATE teachers
SET Department = 'Unknown'
WHERE Department IS NULL;

UPDATE teachers
SET Employment_Type = 'Unknown'
WHERE Employment_Type IS NULL;

UPDATE teachers
SET City = 'Unknown'
WHERE City IS NULL;

-- VERIFY
SELECT
    SUM(Teacher_Name IS NULL) AS null_teacher_name,
    SUM(Department IS NULL) AS null_department,
    SUM(Employment_Type IS NULL) AS null_employment,
    SUM(City IS NULL) AS null_city
FROM teachers;


-- SOLUTION: Remove extra spaces
UPDATE teachers
SET City = TRIM(City);

-- VERIFY
SELECT DISTINCT City
FROM teachers
ORDER BY City;


-- CHECK: Invalid Experience
SELECT *
FROM teachers
WHERE Experience_Years < 0
   OR Experience_Years > 50;

-- SOLUTION
UPDATE teachers
SET Experience_Years = NULL
WHERE Experience_Years < 0
   OR Experience_Years > 50;

-- VERIFY
SELECT MIN(Experience_Years) AS min_experience,
       MAX(Experience_Years) AS max_experience
FROM teachers;



-- =========================================================
-- 3. PERFORMANCE
-- =========================================================

-- CHECK: Duplicate Performance_ID
SELECT Performance_ID, COUNT(*) AS duplicate_count
FROM performance
GROUP BY Performance_ID
HAVING COUNT(*) > 1;

-- SOLUTION
DELETE p1
FROM performance p1
JOIN performance p2
  ON p1.Performance_ID = p2.Performance_ID
 AND p1.Performance_ID IS NOT NULL
 AND p1.Performance_ID > p2.Performance_ID;

-- VERIFY
SELECT Performance_ID, COUNT(*) AS duplicate_count
FROM performance
GROUP BY Performance_ID
HAVING COUNT(*) > 1;

CREATE TEMPORARY TABLE performance_dedup AS
SELECT DISTINCT *
FROM performance;

TRUNCATE TABLE performance;

INSERT INTO performance
SELECT *
FROM performance_dedup;

DROP TEMPORARY TABLE performance_dedup;


-- CHECK: NULL values
SELECT
    SUM(Performance_ID IS NULL) AS null_performance_id,
    SUM(Student_ID IS NULL) AS null_student_id,
    SUM(Course_ID IS NULL) AS null_course_id,
    SUM(Subject IS NULL) AS null_subject,
    SUM(Exam_Type IS NULL) AS null_exam_type,
    SUM(Exam_Date IS NULL) AS null_exam_date,
    SUM(Max_Marks IS NULL) AS null_max_marks,
    SUM(Marks_Obtained IS NULL) AS null_marks
FROM performance;

-- SOLUTION
UPDATE performance
SET Subject = 'Unknown'
WHERE Subject IS NULL;

UPDATE performance
SET Exam_Type = 'Unknown'
WHERE Exam_Type IS NULL;

-- VERIFY
SELECT
    SUM(Subject IS NULL) AS null_subject,
    SUM(Exam_Type IS NULL) AS null_exam_type
FROM performance;


-- CHECK: Exam Type inconsistency
SELECT Exam_Type, COUNT(*) AS cnt
FROM performance
GROUP BY Exam_Type;

-- SOLUTION
UPDATE performance
SET Exam_Type = 'Final'
WHERE LOWER(TRIM(Exam_Type)) = 'final';

UPDATE performance
SET Exam_Type = 'Midterm'
WHERE LOWER(TRIM(Exam_Type)) = 'midterm';

-- VERIFY
SELECT Exam_Type, COUNT(*) AS cnt
FROM performance
GROUP BY Exam_Type;


-- CHECK: Invalid Marks
SELECT *
FROM performance
WHERE Marks_Obtained < 0
   OR Marks_Obtained > Max_Marks;

-- SOLUTION
UPDATE performance
SET Marks_Obtained = NULL
WHERE Marks_Obtained < 0
   OR Marks_Obtained > Max_Marks;

-- VERIFY
SELECT *
FROM performance
WHERE Marks_Obtained < 0
   OR Marks_Obtained > Max_Marks;


-- CHECK: Invalid Max Marks
SELECT *
FROM performance
WHERE Max_Marks <= 0;

-- SOLUTION
UPDATE performance
SET Max_Marks = NULL
WHERE Max_Marks <= 0;

-- VERIFY
SELECT *
FROM performance
WHERE Max_Marks <= 0;



-- =========================================================
-- 4. ATTENDANCE
-- =========================================================

-- CHECK: Duplicate Attendance_ID
SELECT Attendance_ID, COUNT(*) AS duplicate_count
FROM attendance
GROUP BY Attendance_ID
HAVING COUNT(*) > 1;

-- SOLUTION
DELETE a1
FROM attendance a1
JOIN attendance a2
  ON a1.Attendance_ID = a2.Attendance_ID
 AND a1.Attendance_ID IS NOT NULL
 AND a1.Attendance_ID > a2.Attendance_ID;

-- VERIFY
SELECT Attendance_ID, COUNT(*) AS duplicate_count
FROM attendance
GROUP BY Attendance_ID
HAVING COUNT(*) > 1;


-- CHECK: NULL Attendance Status
SELECT COUNT(*) AS null_status
FROM attendance
WHERE Attendance_Status IS NULL;

-- SOLUTION
UPDATE attendance
SET Attendance_Status =
    CASE
        WHEN Classes_Held = 0 THEN 'Unknown'
        WHEN (Classes_Attended / Classes_Held) * 100 >= 75
            THEN 'Present'
        ELSE 'Absent'
    END
WHERE Attendance_Status IS NULL;

-- VERIFY
SELECT Attendance_Status, COUNT(*) AS cnt
FROM attendance
GROUP BY Attendance_Status;


-- CHECK: Invalid attendance numbers
SELECT *
FROM attendance
WHERE Classes_Held < 0
   OR Classes_Attended < 0
   OR Classes_Attended > Classes_Held;

-- SOLUTION
UPDATE attendance
SET Classes_Attended = NULL
WHERE Classes_Attended < 0
   OR Classes_Attended > Classes_Held;

UPDATE attendance
SET Classes_Held = NULL
WHERE Classes_Held < 0;

-- VERIFY
SELECT *
FROM attendance
WHERE Classes_Held < 0
   OR Classes_Attended < 0
   OR Classes_Attended > Classes_Held;



-- =========================================================
-- 5. FEES
-- =========================================================

-- CHECK: Duplicate Payment_ID
SELECT Payment_ID, COUNT(*) AS duplicate_count
FROM fees
GROUP BY Payment_ID
HAVING COUNT(*) > 1;

-- SOLUTION
DELETE f1
FROM fees f1
JOIN fees f2
  ON f1.Payment_ID = f2.Payment_ID
 AND f1.Payment_ID IS NOT NULL
 AND f1.Payment_ID > f2.Payment_ID;

-- VERIFY
SELECT Payment_ID, COUNT(*) AS duplicate_count
FROM fees
GROUP BY Payment_ID
HAVING COUNT(*) > 1;


-- CHECK: NULL values
SELECT
    SUM(Payment_ID IS NULL) AS null_payment_id,
    SUM(Student_ID IS NULL) AS null_student_id,
    SUM(Course_ID IS NULL) AS null_course_id,
    SUM(Fee_Type IS NULL) AS null_fee_type,
    SUM(Amount IS NULL) AS null_amount,
    SUM(Paid_Amount IS NULL) AS null_paid_amount,
    SUM(Payment_Date IS NULL) AS null_payment_date,
    SUM(Payment_Method IS NULL) AS null_payment_method,
    SUM(Payment_Status IS NULL) AS null_payment_status
FROM fees;

-- SOLUTION
UPDATE fees
SET Fee_Type = 'Unknown'
WHERE Fee_Type IS NULL;

UPDATE fees
SET Payment_Method = 'Unknown'
WHERE Payment_Method IS NULL;

UPDATE fees
SET Payment_Status = 'Unknown'
WHERE Payment_Status IS NULL;

-- VERIFY
SELECT
    SUM(Fee_Type IS NULL) AS null_fee_type,
    SUM(Payment_Method IS NULL) AS null_payment_method,
    SUM(Payment_Status IS NULL) AS null_payment_status
FROM fees;


-- CHECK: Invalid amounts
SELECT *
FROM fees
WHERE Amount < 0
   OR Paid_Amount < 0
   OR Paid_Amount > Amount;

-- SOLUTION
UPDATE fees
SET Paid_Amount = NULL
WHERE Paid_Amount < 0
   OR Paid_Amount > Amount;

UPDATE fees
SET Amount = NULL
WHERE Amount < 0;

-- VERIFY
SELECT *
FROM fees
WHERE Amount < 0
   OR Paid_Amount < 0
   OR Paid_Amount > Amount;


-- SOLUTION: Remove spaces from Payment Method
UPDATE fees
SET Payment_Method = TRIM(Payment_Method);

-- VERIFY
SELECT Payment_Method, COUNT(*) AS cnt
FROM fees
GROUP BY Payment_Method;



-- =========================================================
-- 6. DROPOUTS
-- =========================================================

-- CHECK: Duplicate Dropout_ID
SELECT Dropout_ID, COUNT(*) AS duplicate_count
FROM dropouts
GROUP BY Dropout_ID
HAVING COUNT(*) > 1;

-- SOLUTION
DELETE d1
FROM dropouts d1
JOIN dropouts d2
  ON d1.Dropout_ID = d2.Dropout_ID
 AND d1.Dropout_ID IS NOT NULL
 AND d1.Dropout_ID > d2.Dropout_ID;

-- VERIFY
SELECT Dropout_ID, COUNT(*) AS duplicate_count
FROM dropouts
GROUP BY Dropout_ID
HAVING COUNT(*) > 1;


-- CHECK: NULL values
SELECT
    SUM(Dropout_ID IS NULL) AS null_dropout_id,
    SUM(Student_ID IS NULL) AS null_student_id,
    SUM(Dropout_Date IS NULL) AS null_dropout_date,
    SUM(Dropout_Reason IS NULL) AS null_reason,
    SUM(Refund_Amount IS NULL) AS null_refund,
    SUM(Exit_Type IS NULL) AS null_exit_type
FROM dropouts;

-- SOLUTION
UPDATE dropouts
SET Dropout_Reason = 'Unknown'
WHERE Dropout_Reason IS NULL;

UPDATE dropouts
SET Exit_Type = 'Unknown'
WHERE Exit_Type IS NULL;

UPDATE dropouts
SET Refund_Amount = 0
WHERE Refund_Amount IS NULL;

-- VERIFY
SELECT
    SUM(Dropout_Reason IS NULL) AS null_reason,
    SUM(Exit_Type IS NULL) AS null_exit_type,
    SUM(Refund_Amount IS NULL) AS null_refund
FROM dropouts;


-- CHECK: Invalid Refund
SELECT *
FROM dropouts
WHERE Refund_Amount < 0;

-- SOLUTION
UPDATE dropouts
SET Refund_Amount = NULL
WHERE Refund_Amount < 0;

-- VERIFY
SELECT *
FROM dropouts
WHERE Refund_Amount < 0;



-- =========================================================
-- 7. FINAL ROW COUNT CHECK
-- =========================================================

SELECT 'students' AS table_name, COUNT(*) AS row_count
FROM students

UNION ALL

SELECT 'courses', COUNT(*)
FROM courses

UNION ALL

SELECT 'teachers', COUNT(*)
FROM teachers

UNION ALL

SELECT 'performance', COUNT(*)
FROM performance

UNION ALL

SELECT 'attendance', COUNT(*)
FROM attendance

UNION ALL

SELECT 'fees', COUNT(*)
FROM fees

UNION ALL

SELECT 'dropouts', COUNT(*)
FROM dropouts;


-- =========================================================
-- 8. FINAL DUPLICATE CHECK
-- =========================================================

SELECT Student_ID, COUNT(*) AS cnt
FROM students
GROUP BY Student_ID
HAVING COUNT(*) > 1;

SELECT Course_ID, COUNT(*) AS cnt
FROM courses
GROUP BY Course_ID
HAVING COUNT(*) > 1;

SELECT Teacher_ID, COUNT(*) AS cnt
FROM teachers
GROUP BY Teacher_ID
HAVING COUNT(*) > 1;

SELECT Performance_ID, COUNT(*) AS cnt
FROM performance
GROUP BY Performance_ID
HAVING COUNT(*) > 1;

SELECT Attendance_ID, COUNT(*) AS cnt
FROM attendance
GROUP BY Attendance_ID
HAVING COUNT(*) > 1;

SELECT Payment_ID, COUNT(*) AS cnt
FROM fees
GROUP BY Payment_ID
HAVING COUNT(*) > 1;

CREATE TEMPORARY TABLE fees_dedup AS
SELECT DISTINCT *
FROM fees;

TRUNCATE TABLE fees;

INSERT INTO fees
SELECT *
FROM fees_dedup;

DROP TEMPORARY TABLE fees_dedup;

SELECT Dropout_ID, COUNT(*) AS cnt
FROM dropouts
GROUP BY Dropout_ID
HAVING COUNT(*) > 1;