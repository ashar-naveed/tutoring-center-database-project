-- Analytical queries for tutoring center insights


-- 1. Analyze tutor performance using average student ratings
SELECT 
    t.TutorID,
    t.FirstName,
    t.LastName,
    AVG(f.Rating) AS AvgRating
FROM TUTOR t
JOIN TUTORING_SESSION ts ON t.TutorID = ts.TutorID
JOIN FEEDBACK f ON ts.SessionID = f.SessionID
GROUP BY t.TutorID, t.FirstName, t.LastName;


-- 2. Count number of tutoring sessions conducted by each tutor
SELECT 
    t.TutorID,
    t.FirstName,
    t.LastName,
    COUNT(ts.SessionID) AS TotalSessions
FROM TUTOR t
LEFT JOIN TUTORING_SESSION ts ON t.TutorID = ts.TutorID
GROUP BY t.TutorID, t.FirstName, t.LastName;


-- 3. Identify most active students based on session attendance
SELECT 
    s.StudentID,
    s.FirstName,
    s.LastName,
    COUNT(ts.SessionID) AS SessionsAttended
FROM STUDENT s
JOIN TUTORING_SESSION ts ON s.StudentID = ts.StudentID
GROUP BY s.StudentID, s.FirstName, s.LastName
ORDER BY SessionsAttended DESC;


-- 4. Analyze tutoring activity by course
SELECT 
    c.Code AS CourseCode,
    c.Title,
    COUNT(ts.SessionID) AS TotalSessions
FROM COURSE c
LEFT JOIN TUTORING_SESSION ts ON c.CourseID = ts.CourseID
GROUP BY c.Code, c.Title;


-- 5. Evaluate average feedback rating per course
SELECT 
    c.Code AS CourseCode,
    c.Title,
    AVG(f.Rating) AS AvgCourseRating
FROM COURSE c
JOIN TUTORING_SESSION ts ON c.CourseID = ts.CourseID
JOIN FEEDBACK f ON ts.SessionID = f.SessionID
GROUP BY c.Code, c.Title;


-- 6. Identify students who have never submitted feedback
SELECT 
    s.StudentID,
    s.FirstName,
    s.LastName
FROM STUDENT s
WHERE s.StudentID NOT IN (
    SELECT ts.StudentID
    FROM TUTORING_SESSION ts
    JOIN FEEDBACK f ON ts.SessionID = f.SessionID
);


-- 7. Track tutoring sessions by department
SELECT 
    d.DeptName,
    COUNT(ts.SessionID) AS TotalSessions
FROM DEPARTMENT d
JOIN COURSE c ON d.DeptID = c.DeptID
LEFT JOIN TUTORING_SESSION ts ON c.CourseID = ts.CourseID
GROUP BY d.DeptName;


-- 8. Find courses with no tutoring sessions
SELECT 
    c.Code,
    c.Title
FROM COURSE c
LEFT JOIN TUTORING_SESSION ts ON c.CourseID = ts.CourseID
WHERE ts.SessionID IS NULL;


-- 9. Identify underperforming sessions based on low feedback ratings
SELECT 
    ts.SessionID,
    ts.SessionDate,
    c.Code AS CourseCode,
    f.Rating
FROM TUTORING_SESSION ts
JOIN COURSE c ON ts.CourseID = c.CourseID
JOIN FEEDBACK f ON ts.SessionID = f.SessionID
WHERE f.Rating < 3;


-- 10. View: average tutor rating per course
CREATE OR REPLACE VIEW v_tutor_course_performance AS
SELECT 
    t.TutorID,
    t.FirstName AS TutorFirstName,
    t.LastName AS TutorLastName,
    c.Code AS CourseCode,
    AVG(f.Rating) AS AvgRating
FROM TUTOR t
JOIN COURSE c ON t.TutorID = c.TutorID
JOIN TUTORING_SESSION ts ON ts.TutorID = t.TutorID AND ts.CourseID = c.CourseID
JOIN FEEDBACK f ON ts.SessionID = f.SessionID
GROUP BY t.TutorID, t.FirstName, t.LastName, c.Code;
