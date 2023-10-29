
CREATE TYPE dept_t;

CREATE TYPE emp_t AS OBJECT(
    empno char(6),
    firstname varchar(12),
    lastname varchar(15),
    workdept REF dept_t,
    sex char(1),
    birthdate date,
    salary number(8,2)
)
/

CREATE TYPE dept_t AS OBJECT(
    deptno char(3),
    deptname varchar(36),
    mgrno REF emp_t,
    admrdept REF dept_t
)
/

CREATE TABLE oremp OF emp_t(
    empno PRIMARY KEY,
    firstname NOT NULL,
    lastname NOT NULL
)

CREATE TABLE ordept OF dept_t(
    deptno PRIMARY KEY,
    deptname NOT NULL,
    mgrno REFERENCES oremp,
    admrdept REFERENCES ordept
)

ALTER TABLE oremp 
ADD CONSTRAINT oremp_workdept_fk FOREIGN KEY (workdept) REFERENCES ordept;

-- ADD NOT NULL CONSTRAINT
ALTER TABLE oremp
MODIFY (workdept NOT NULL);

-- EMP:
-- EMPNO FIRSTNAME LASTNAME WORKDEPT SEX BIRTHDATE SALARY
-- ------------------------------------------------------------------
-- 000010 CHRISTINE HAAS A00 F 14/AUG/53 72750 
-- 000020 MICHAEL THOMPSON B01 M 02/FEB/68 61250 
-- 000030 SALLY KWAN C01 F 11/MAY/71 58250 
-- 000060 IRVING STERN D01 M 07/JUL/65 55555 
-- 000070 EVA PULASKI D01 F 26/MAY/73 56170 
-- 000050 JOHN GEYER C01 M 15/SEP/55 60175 
-- 000090 EILEEN HENDERSON B01 F 15/MAY/61 49750 
-- 000100 THEODORE SPENSER B01 M 18/DEC/76 46150

-- DEPT:
-- DEPTNO DEPTNAME MGRNO ADMRDEPT 
-- -------------------------------------------------------------- 
-- A00 SPIFFY COMPUTER SERVICE DIV. 000010 A00 
-- B01 PLANNING 000020 A00 
-- C01 INFORMATION CENTRE 000030 A00 
-- D01 DEVELOPMENT CENTRE 000060 C01 

INSERT INTO oremp VALUES(
    emp_t('000010','CHRISTINE', 'HAAS' ,NULL, 'F' ,'14/AUG/53','72750'));

INSERT INTO oremp VALUES(
    emp_t('000020', 'MICHAEL', 'THOMPSON', NULL,'M' ,'02/FEB/68' ,'61250'));
/

INSERT INTO oremp VALUES(
    emp_t('000030', 'SALLY', 'KWAN', NULL, 'F', '11/MAY/71' ,'58250'));
/

INSERT INTO oremp VALUES(
    emp_t('000060' ,'IRVING' ,'STERN', NULL, 'M', '07/JUL/65' ,'55555'));
/

INSERT INTO oremp VALUES(
    emp_t('000070' ,'EVA', 'PULASKI', NULL, 'F' ,'26/MAY/73', '56170'));
/

INSERT INTO oremp VALUES(
    emp_t('000050', 'JOHN', 'GEYER', NULL, 'M', '15/SEP/55', '60175'));
/

INSERT INTO oremp VALUES(
    emp_t('000090' ,'EILEEN' ,'HENDERSON', NULL, 'F', '15/MAY/61', '49750'));
/

INSERT INTO oremp VALUES(
    emp_t('000100' ,'THEODORE', 'SPENSER' ,NULL, 'M', '18/DEC/76', '46150'));
/

INSERT INTO ordept VALUES(
    dept_t('A00','SPIFFY COMPUTER SERVICE DIV.',
   ( SELECT REF(e) FROM oremp e WHERE e.empno='000010'),
    NULL));

UPDATE ordept 
SET admrdept = (SELECT REF(d) FROM ordept d WHERE d.deptno='A00')
WHERE deptno='A00';

INSERT INTO ordept VALUES(
    dept_t(
        'B01','PLANNING',
        (SELECT REF(e) FROM oremp e WHERE e.empno='000020'),
        (SELECT REF(d) FROM ordept d WHERE d.deptno='A00')
    )
)

INSERT INTO ordept VALUES(
    dept_t(
        'C01','INFORMATION CENTRE',
        (SELECT REF(e) FROM oremp e WHERE e.empno='000030'),
        (SELECT REF(d) FROM ordept d WHERE d.deptno='A00')
    )
)

INSERT INTO ordept VALUES(
    dept_t(
        'D01','DEVELOPMENT CENTRE',
        (SELECT REF(e) FROM oremp e WHERE e.empno='000060'),
        (SELECT REF(d) FROM ordept d WHERE d.deptno='C01')
    )
)

UPDATE oremp e
SET e.workdept = (SELECT REF(d) FROM ordept d WHERE d.deptno='A00')
WHERE e.empno='000010';

UPDATE oremp e 
SET e.workdept = (SELECT REF(d) FROM ordept d WHERE d.deptno='B01')
WHERE e.empno='000020'
/

UPDATE oremp e
SET e.workdept = (SELECT REF(d) FROM ordept d WHERE d.deptno='C01')
WHERE e.empno='000030'
/

UPDATE oremp 
SET workdept = (SELECT REF(d) FROM ordept d WHERE d.deptno='D01')
WHERE empno='000060'
/

UPDATE oremp
SET workdept = (SELECT REF(d) FROM ordept d WHERE d.deptno='D01')
WHERE empno='000070'
/

UPDATE oremp
SET workdept = (SELECT REF(d) FROM ordept d WHERE d.deptno='C01')
WHERE empno='000050'
/

UPDATE oremp
SET workdept = (SELECT REF(d) FROM ordept d WHERE d.deptno='B01')
WHERE empno='000090'
/

UPDATE oremp
SET workdept = (SELECT REF(d) FROM ordept d WHERE d.deptno='B01')
WHERE empno='000100'
/


-- 2. Answer the following queries using OREMP and ORDEPT tables:
-- (a) Get the department name and manager’s lastname for all departments.

SELECT d.deptname, d>mgrno.lastname
FROM ordept d;

-- (b) Get the employee number, lastname and the department name of every employee.

SELECT e.empno, e.lastname, e.workdept.deptname
FROM oremp e;

-- (c) For each department, display the department number, department name, and name of the administrative
-- department.

SELECT d.deptname, d.deptno, d.admrdept.deptname FROM ordept d;

-- (d) For each department, display the department number, department name, the name of the administrative
-- department and the last name of the manager of the administrative department.

SELECT d.deptname, d.deptno, d.admrdept.deptname, d.admrdept.mgrno.lastname FROM ordept d;

-- (e) Display the employee number, firstname, lastname and salary of every employee, along with lastname and
-- salary of the manager of the employee’s work department.

SELECT e.empno, e.firstname, e.lastname, e.salary, e.workdept.mgrno.lastname, e.workdept.mgrno.salary
FROM oremp e;
-- (f) Show the average salary for men and the average salary for women for each department. Identify the
-- department by both department number and name. 

SELECT
    e.workdept.deptno AS department_number,
    e.workdept.deptname AS department_name,
    e.sex,
    AVG(e.salary) AS avg_salary
FROM
    oremp e
GROUP BY
    e.workdept.deptno,
    e.workdept.deptname,
    e.sex
ORDER BY
    e.workdept.deptno,
    e.workdept.deptname,
    e.sex;

