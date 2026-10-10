# School Database Design

## 1. Overview

This database manages students, courses and student enrolments.
It stores student details, course information and the grades students
receive in their courses.

The database uses SQLite and a relational design to maintain data
consistency and reduce unnecessary duplication.

## 2. Tables

### Students

The `students` table stores each student's unique ID, full name and
email address. The student ID is the primary key, while the email is
required and unique to prevent duplicate student email addresses.

### Courses

The `courses` table stores course IDs, course names and course codes.
The course ID is the primary key, and each course code must be unique.

### Enrolments

The `enrolments` table records which students take which courses.
It contains a unique enrolment ID, foreign keys referencing the student
and course, and a grade for the student's performance in that course.

The combination of `student_id` and `course_id` is unique. This prevents
a student from being enrolled in the same course more than once.

## 3. Relationships

### One-to-Many Relationships

A student can have many enrolments, but each enrolment belongs to one
student. This creates a one-to-many relationship between `students`
and `enrolments`.

Similarly, a course can have many enrolments, but each enrolment refers
to one course. This creates a one-to-many relationship between `courses`
and `enrolments`.

### Many-to-Many Relationship

Students and courses have a many-to-many relationship. A student can
take several courses, and each course can have several students.

The `enrolments` table resolves this many-to-many relationship by
creating a separate record for each student-course combination.
It also stores the grade associated with that particular enrolment.

Without this join table, storing multiple courses directly in a student
record would make the database harder to query and maintain.

## 4. Index Recommendation

I would add an index on `enrolments(course_id)` to improve queries that
retrieve students enrolled in a particular course and help with grouping
enrolments by course.

The unique constraint on `(student_id, course_id)` already creates an
index in SQLite that can help with lookups beginning with `student_id`.
A separate index on `course_id` is useful because it supports queries
that search by course instead.

Example:

```sql
CREATE INDEX idx_enrolments_course_id
ON enrolments(course_id);
