-- UNIVERSITY DATABASE
-- ===================
-- SCHEMA
-- ======

create type student_typ as object (
 regNo char(10),
 name varchar2(50),
 gpa float,
 year int
);
/

create type Member_typ as object (
 team_member ref student_typ,
 grade char
);
/

create type member_t_ty as table of member_typ;
/

create type project_typ as object (
 id char(3),
 title varchar2(50),
 team_lead ref student_typ,
 members member_t_ty
);
/

create table students_tbl of student_typ (
regNo primary key);

create table projects_tbl of project_typ(id primary key)
 nested table members store as ntlb_members;


-- LOADING DATA
-- ============
insert into students_tbl values ('DIT/M/0001', 'Sampath W.', 2.98, 1);
insert into students_tbl values ('DIT/M/0002', 'Dulani F.', 3.22, 2);
insert into students_tbl values ('DIT/M/0012', 'Sajith P.', 3.72, 1);
insert into students_tbl values ('DIT/M/0023', 'Amali W.', 2.99, 2);


insert into projects_tbl values ( 
 project_typ(
  'M11',
  'Bank of Ceylon',
  (select ref(s) from students_tbl s where s.regNo = 'DIT/M/0001'),
  member_t_ty(
   member_typ((select ref(s) from students_tbl s where regNo = 'DIT/M/0001'), 'B'),
   member_typ((select ref(s) from students_tbl s where regNo = 'DIT/M/0012'), 'A')
  )
 )
);

insert into projects_tbl values (
 'M21',
 'Virtusa',
 (select ref(s) from students_tbl s where regNo = 'DIT/M/0002'),
 member_t_ty()
);

insert into table (select p.members from projects_tbl p where p.id = 'M21')
values ((select ref(s) from students_tbl s where regNo = 'DIT/M/0002'), 'B'); 

insert into table (select p.members from projects_tbl p where p.id = 'M21')
values ((select ref(s) from students_tbl s where regNo = 'DIT/M/0023'), 'C');

-- ChatGPT
-- It looks like you've provided a SQL script that defines a database schema for a university database and inserts some data into it. The schema includes the definition of object types like student_typ, Member_typ, and project_typ, as well as tables students_tbl and projects_tbl to store information about students and projects, respectively. The data includes student information and project details with their members.
-- Here's a breakdown of what the script does:
-- It defines several object types, including student_typ, Member_typ, member_t_ty, and project_typ. These object types are used to structure the data within the database.
-- It creates two tables: students_tbl and projects_tbl to store information about students and projects. The projects_tbl table also has a nested table called members to store the members of each project.
-- Data for students is inserted into the students_tbl table.
-- Data for projects is inserted into the projects_tbl table. This includes project information such as ID, title, team lead (a reference to a student), and project members (a table of Member_typ).
-- It inserts members into the members nested table of the 'Virtusa' project ('M21'). These members are associated with the project by selecting their references from the students_tbl table.
-- It inserts additional members into the same 'Virtusa' project ('M21').
-- Overall, this script sets up a basic database structure for storing information about students and their involvement in various projects. The projects_tbl table has a nested table to manage project members using the Member_typ type.

-- User
-- Print the project id, student name and member’s grade in the project ,whose gpa greater than 3.0
-- ChatGPT
-- To retrieve the project ID, student name, and member's grade for projects where the GPA of the student is greater than 3.0, you can use SQL queries. You'll need to join the necessary tables and add a condition to filter students with a GPA greater than 3.0. Here's the SQL query to achieve this:

SELECT
    p.id AS project_id,
    s.name AS student_name,
    m.grade AS member_grade
FROM
    projects_tbl p
JOIN
    students_tbl s ON DEREF(p.team_lead).regNo = s.regNo
JOIN
    TABLE(p.members) m ON DEREF(m.team_member).gpa > 3.0;

-- This SQL query performs the following:

-- It selects the project ID (p.id), student name (s.name), and member's grade (m.grade).

-- It joins the projects_tbl table (p) with the students_tbl table (s) using the team_lead reference.

-- It joins the nested table members (p.members) with the Member_typ object (m) using the team_member reference.

-- It adds a condition DEREF(m.team_member).gpa > 3.0 to filter students with a GPA greater than 3.0.

-- This query will return the desired information for projects where at least one member has a GPA greater than 3.


-- User
-- Create a member function (called maxGPA) that returns the maximum gpa of the project members.
-- ChatGPT
-- To create a member function called maxGPA that returns the maximum GPA of the project members for the project_typ object type, you can define the member function within the object type definition. Here's how you can modify the project_typ definition to include the maxGPA member function:

CREATE TYPE project_typ AS OBJECT (
    id CHAR(3),
    title VARCHAR2(50),
    team_lead REF student_typ,
    members member_t_ty,

    MEMBER FUNCTION maxGPA RETURN FLOAT
) NOT FINAL;
/

-- In the modified project_typ definition, we've added a member function called maxGPA that returns a FLOAT. Now, you need to define the implementation of this member function using the MEMBER FUNCTION clause. Here's how you can define the maxGPA member function:

CREATE OR REPLACE TYPE BODY project_typ AS
    MEMBER FUNCTION maxGPA RETURN FLOAT IS
        max_value FLOAT := 0.0; -- Initialize max_value to a lower value
    BEGIN
        -- Loop through project members to find the maximum GPA
        FOR i IN 1..self.members.COUNT LOOP
            IF DEREF(self.members(i).team_member).gpa > max_value THEN
                max_value := DEREF(self.members(i).team_member).gpa;
            END IF;
        END LOOP;

        RETURN max_value;
    END maxGPA;
END;
/
-- In the member function implementation:
-- We initialize max_value to a lower value (0.0) to start with.
-- We use a loop to iterate through the project members.
-- For each member, we use DEREF to access the GPA of the member and compare it with the current max_value. If the GPA is greater, we update max_value with the new maximum GPA.
-- Finally, we return the max_value as the result of the maxGPA member function.
-- Now, the maxGPA member function is defined for the project_typ object type, and you can use it to retrieve the maximum GPA of the project members for a specific project instance.

-- User
-- Display the title of each project and the maximum GPA of team members (using the function created), in descending order of maximum gpa.
-- ChatGPT
-- To display the title of each project and the maximum GPA of team members in descending order of maximum GPA, you can use the maxGPA member function that you've created for the project_typ object type. Here's an SQL query to achieve this:

SELECT
    p.title AS project_title,
    p.maxGPA() AS max_team_gpa
FROM
    projects_tbl p
ORDER BY
    max_team_gpa DESC;

-- In this SQL query:
-- We select the project title (p.title) and the result of the maxGPA member function (p.maxGPA()) for each project.
-- We use the ORDER BY clause to sort the results in descending order of the maximum GPA (max_team_gpa).
-- This query will give you a list of project titles along with the maximum GPA of their team members, sorted in descending order of maximum GPA.


SELECT
    p.id AS project_id,
    s.name AS student_name,
    m.grade AS member_grade
FROM

    projects_tbl p
JOIN
    students_tbl s ON DEREF(p.team_lead).regNo = s.regNo
JOIN
    TABLE(p.members) m ON DEREF(m.team_member).gpa > 3.0;

-- any varius type for this
-- It seems you want to modify the query to use different variable names or aliases for the columns. You can certainly do that. Here's the same query with different variable names for the columns:

SELECT
    p.id AS project_id,
    s.name AS lead_student_name,
    m.grade AS member_grade
FROM
    projects_tbl p
JOIN
    students_tbl s ON DEREF(p.team_lead).regNo = s.regNo
JOIN
    TABLE(p.members) m ON DEREF(m.team_member).gpa > 3.0;

-- In this modified query:

-- p.id is given the alias project_id.
-- s.name is given the alias lead_student_name.
-- m.grade is given the alias member_grade.
-- The result will be the same as the original query, but the column names in the result set will have different aliases.

-- Display the title of each project and the maximum GPA of team members (using the function created), in descending order of maximum gpa.
-- To display the title of each project and the maximum GPA of team members (using the maxGPA function you've created) in descending order of maximum GPA, you can use the following SQL query:

SELECT
    p.title AS project_title,
    p.maxGPA() AS max_team_gpa
FROM
    projects_tbl p
ORDER BY
    max_team_gpa DESC;

-- This query selects the project title (p.title) and calculates the maximum GPA for each project using the maxGPA() member function of the project_typ. It then orders the result in descending order of the maximum GPA (max_team_gpa).
-- This will give you a list of project titles along with the maximum GPA of their team members, sorted in descending order of maximum GPA.

SELECT
    p.id AS project_id,
    s.name AS student_name,
    m.grade AS member_grade
FROM
    projects_tbl p
JOIN
    students_tbl s ON DEREF(p.team_lead).regNo = s.regNo
JOIN
    TABLE(p.members) m ON DEREF(m.team_member).gpa > 3.0;

-- Certainly! You can rewrite the query without using the DEREF function by directly referencing the attributes of the referenced objects. Here's the query without DEREF:

SELECT
    p.id AS project_id,
    s.name AS student_name,
    m.grade AS member_grade
FROM
    projects_tbl p
JOIN
    students_tbl s ON p.team_lead.regNo = s.regNo
JOIN
    TABLE(p.members) m ON m.team_member.gpa > 3.0;

-- In this version of the query:

-- We directly access the regNo attribute of the team_lead attribute within the projects_tbl table.
-- We also directly access the gpa attribute of the team_member attribute within the members nested table.

CREATE TYPE project_typ AS OBJECT (
    id CHAR(3),
    title VARCHAR2(50),
    team_lead REF student_typ,
    members member_t_ty,
    MEMBER FUNCTION maxGPA RETURN FLOAT
) NOT FINAL;
/

CREATE OR REPLACE TYPE BODY project_typ AS
    MEMBER FUNCTION maxGPA RETURN FLOAT IS
    max_value FLOAT := 0.0;
BEGIN
    FOR i IN 1..self.members.COUNT LOOP
    IF DEREF(self.members(i).team_member).gpa > max_value THEN
        max_value := DEREF(self.members(i).team_member).gpa;
        END IF;
        END LOOP;
        RETURN max_value;
    END maxGPA;
END;

-- If you want to avoid using DEREF in your maxGPA member function, you can achieve that by modifying your schema to store the GPA directly in the project_typ object. Here's an example of how you can do that:

CREATE TYPE project_typ AS OBJECT (
    id CHAR(3),
    title VARCHAR2(50),
    team_lead REF student_typ,
    members member_t_ty,
    max_gpa FLOAT, -- Add a direct attribute for max GPA
    MEMBER FUNCTION maxGPA RETURN FLOAT
) NOT FINAL;
/
-- Update the member function implementation to set the max_gpa attribute when inserting or updating project members:

CREATE OR REPLACE TYPE BODY project_typ AS
    MEMBER FUNCTION maxGPA RETURN FLOAT IS
        BEGIN
            RETURN self.max_gpa;
        END maxGPA;

    CONSTRUCTOR FUNCTION project_typ(
        id CHAR,
        title VARCHAR2,
        team_lead REF student_typ,
        members member_t_ty
    ) RETURN SELF AS RESULT IS
        max_value FLOAT := 0.0;
    BEGIN
        -- Loop through project members to find the maximum GPA
        FOR i IN 1..members.COUNT LOOP
            IF members(i).team_member.gpa > max_value THEN
                max_value := members(i).team_member.gpa;
            END IF;
        END LOOP;
        
        -- Set the max_gpa attribute
        SELF.id := id;
        SELF.title := title;
        SELF.team_lead := team_lead;
        SELF.members := members;
        SELF.max_gpa := max_value;
        
        RETURN;
    END project_typ;
END;
/
-- In this modified approach:

-- We added a direct attribute max_gpa to the project_typ object to store the maximum GPA.
-- In the constructor function, we calculate the maximum GPA while creating a new project instance and set the max_gpa attribute accordingly.
-- The maxGPA member function simply returns the value of the max_gpa attribute.
-- With this approach, you can retrieve the maximum GPA without the need for the DEREF function.