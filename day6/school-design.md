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

## 5. SQL or NoSQL?

I would choose a relational SQL database for this school system because students, courses and enrolments have clearly defined relationships. SQL supports primary keys, foreign keys and unique constraints, which help maintain data integrity and prevent invalid or duplicate enrolments.

SQL also makes it easier to retrieve related information using JOIN operations and to calculate the number of students enrolled in each course using GROUP BY. These features are important when generating school reports and managing student records.

A NoSQL document database could store student and course information in flexible documents, but it might require duplicating data or performing some relationships in application code. This can make data consistency and updates more difficult to manage.

Therefore, I would use a relational SQL database for this school system. SQLite is suitable for this assignment because it is lightweight and easy to use, while PostgreSQL would be a good option for a larger school system requiring support for many simultaneous users.
