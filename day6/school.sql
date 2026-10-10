-- ============================================
-- DAY 6 ASSIGNMENT: SCHOOL DATABASE
-- Database: SQLite
-- ============================================

-- 1. CREATE TABLES
-- Drop existing tables first so the script can be rerun.

PRAGMA foreign_keys = ON;

DROP TABLE IF EXISTS enrolments;
DROP TABLE IF EXISTS courses;
DROP TABLE IF EXISTS students;


-- Students table
CREATE TABLE students (
    student_id INTEGER PRIMARY KEY,
    full_name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE
);


-- Courses table
CREATE TABLE courses (
    course_id INTEGER PRIMARY KEY,
    course_name TEXT NOT NULL,
    course_code TEXT NOT NULL UNIQUE
);


-- Enrolments table
-- Links students and courses and stores each student's grade.

CREATE TABLE enrolments (
    enrolment_id INTEGER PRIMARY KEY,
    student_id INTEGER NOT NULL,
    course_id INTEGER NOT NULL,
    grade TEXT,

    FOREIGN KEY (student_id)
        REFERENCES students(student_id),

    FOREIGN KEY (course_id)
        REFERENCES courses(course_id),

    UNIQUE (student_id, course_id)
);


-- ============================================
-- 2. INSERT SAMPLE DATA
-- ============================================

INSERT INTO students (student_id, full_name, email)
VALUES
    (1, 'John Mwangi', 'john@example.com'),
    (2, 'Mary Wanjiku', 'mary@example.com'),
    (3, 'Peter Kamau', 'peter@example.com'),
    (4, 'Grace Njeri', 'grace@example.com');


INSERT INTO courses (course_id, course_name, course_code)
VALUES
    (1, 'Database Systems', 'DB101'),
    (2, 'Web Development', 'WD102'),
    (3, 'Computer Networks', 'CN103');


INSERT INTO enrolments
    (enrolment_id, student_id, course_id, grade)
VALUES
    (1, 1, 1, 'A'),
    (2, 1, 2, 'B'),
    (3, 2, 1, 'A'),
    (4, 2, 3, 'B'),
    (5, 3, 2, 'A');


-- ============================================
-- 3. REQUIRED QUERIES
-- ============================================


-- QUERY 1:
-- Find all courses taken by a student using their name.
-- Example student: John Mwangi

SELECT
    students.full_name,
    courses.course_name,
    courses.course_code,
    enrolments.grade
FROM students
JOIN enrolments
    ON students.student_id = enrolments.student_id
JOIN courses
    ON enrolments.course_id = courses.course_id
WHERE students.full_name = 'John Mwangi';


-- QUERY 2:
-- Find all students enrolled in one course.
-- Example course: Database Systems

SELECT
    courses.course_name,
    students.full_name,
    students.email,
    enrolments.grade
FROM courses
JOIN enrolments
    ON courses.course_id = enrolments.course_id
JOIN students
    ON enrolments.student_id = students.student_id
WHERE courses.course_name = 'Database Systems';


-- QUERY 3:
-- Count the number of students enrolled in each course.
-- LEFT JOIN ensures courses with zero enrolments also appear.

SELECT
    courses.course_name,
    COUNT(enrolments.student_id) AS number_of_students
FROM courses
LEFT JOIN enrolments
    ON courses.course_id = enrolments.course_id
GROUP BY
    courses.course_id,
    courses.course_name
ORDER BY courses.course_name;


-- QUERY 4:
-- Find students who have no enrolments.

SELECT
    students.student_id,
    students.full_name,
    students.email
FROM students
LEFT JOIN enrolments
    ON students.student_id = enrolments.student_id
WHERE enrolments.enrolment_id IS NULL;


-- QUERY 5:
-- Update one enrolment's grade.
-- Change John Mwangi's Database Systems grade to A+.

UPDATE enrolments
SET grade = 'A+'
WHERE student_id = (
    SELECT student_id
    FROM students
    WHERE full_name = 'John Mwangi'
)
AND course_id = (
    SELECT course_id
    FROM courses
    WHERE course_name = 'Database Systems'
);


-- Verify the updated grade.

SELECT
    students.full_name,
    courses.course_name,
    enrolments.grade
FROM enrolments
JOIN students
    ON enrolments.student_id = students.student_id
JOIN courses
    ON enrolments.course_id = courses.course_id
WHERE students.full_name = 'John Mwangi'
  AND courses.course_name = 'Database Systems';
