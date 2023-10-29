t-- CREATE SUPPER CLASS
CREATE TYPE person_nt AS OBJECT(
    id NUMBER(4),
    name VARCHAR2(20)
) NOT FINAL;

CREATE TYPE student_nt UNDER person_nt(
    dptNo NUMBER(4),
    school VARCHAR2(15)
) NOT FINAL
/

CREATE TYPE partTimestd_nt UNDER student_nt(
    noOfHours NUMBER(3)
)

CREATE TYPE emp_nt UNDER person_nt(
    empId NUMBER(4),
    mgrNo NUMBER(4)
)

CREATE TABLE person_n OF person_nt(
    id PRIMARY KEY
)

INSERT INTO person_n VALUES(
    person_nt(1, 'John')
)
/

INSERT INTO person_n VALUES(
    student_nt(2, 'Mary', 1, 'IT')
)
/
INSERT INTO person_n VALUES(
    partTimestd_nt(3, 'Peter', 1, 'IT', 20)
)
/
INSERT INTO person_n VALUES(
    emp_nt(4, 'Tom', 1, 1)
)
/

SELECT VALUE(p) FROM person_n p;

SELECT VALUE(p) FROM person_n p WHERE VALUE(p) IS OF (ONLY student_nt);

SELECT p.id, p.name, TREAT(VALUE(p) AS student_nt).school SCHOOL
FROM person_n p
WHERE VALUE(p) IS OF (ONLY student_nt);

SELECT p.id, p.name, TREAT(VALUE(p) AS student_nt).school SCHOOL
FROM person_n p
WHERE VALUE(p) IS OF (ONLY student_nt) AND TREAT(VALUE(p) AS student_nt).school = 'IT';

-- ABSTRACT - NOT INSTANTIABLE
CREATE TYPE person_nt AS OBJECT(
    id NUMBER(4),
    name VARCHAR2(20)
) NOT INSTANTIABLE NOT FINAL;

-- Cannot insert into abstract class

-- NOT INSTANTIABLE METHODS
CREATE TYPE person_nt AS OBJECT(
    id NUMBER(4),
    name VARCHAR2(20),
    NOT INSTANTIABLE FUNCTION person_nt(id NUMBER, name VARCHAR2) RETURN SELF AS RESULT
) NOT INSTANTIABLE NOT FINAL;