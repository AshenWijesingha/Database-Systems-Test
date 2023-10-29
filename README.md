# Database-Systems-Test
Database Systems Test Practice Quiz

## Basic SQL Commands

```sql
-- creaste tables with foriegn keys
-- CREATE PARTIAL TYPE 
CREATE TYPE dept_t
/

CREATE TYPE emp_t AS object (
    eno NUMBER(4),
    ename VARCHAR2(15),
    edept REF dept_t,
    salary NUMBER(8,2)
)
/

CREATE TYPE dept_t AS OBJECT(
    dno NUMBER(4),
    dname VARCHAR2(15),
    mgr REF emp_t
)
/

-- CRAEATE TABLE 

CREATE TABLE emp_table OF emp_t(
    eno PRIMARY KEY
)

CREATE TABLE dept_table OF dept_t(
    dno PRIMARY KEY,
    CONSTRAINT dept_table_mgr_fk FOREIGN KEY (mgr) REFERENCES emp_table   
)
/

ALTER TABLE emp_table ADD CONSTRAINT emp_table_edept_fk FOREIGN KEY (edept) REFERENCES dept_table;

-- INSERT DATA

INSERT INTO dept_table VALUES(
    dept_t(10, 'ACCOUNTING', NULL)
)

INSERT INTO emp_table VALUES(
    emp_t(1001, 'SMITH',
        (SELECT REF(d) FROM dept_table d WHERE d.dno = 10)
    , 1000)
)

UPDATE dept_table SET mgr = (SELECT REF(e) FROM emp_table e WHERE e.eno = 1001) WHERE dno = 10;

-- SELECT DATA
SELECT e.eno, e.ename, e.edept.dname, e.salary
FROM emp_table e

SELECT d.mgr.ename, d.mgr.salary, d.dname FROM dept_table d;
```

## Inheritance

```sql
-- CREATE SUPPER CLASS
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
```

## Member Function

```sql
CREATE TYPE sales_t AS OBJECT(
    id CHAR(3),
    name VARCHAR(20),
    units NUMBER(3),
    MEMBER FUNCTION totalSales(unit_price IN FLOAT)
    RETURN FLOAT
)
/

CREATE TYPE BODY sales_t AS
    MEMBER FUNCTION totalSales(unit_price IN FLOAT)
    RETURN FLOAT 
    IS
    BEGIN
        RETURN SELF.units * unit_price;
    END;
END;

CREATE TABLE sales_table OF sales_t;


-- ADD ANOTHER 

ALTER TYPE sales_t
ADD MEMBER FUNCTION offer(rate IN FLOAT)
RETURN FLOAT
CASCADE;

CREATE OR REPLACE TYPE BODY sales_t AS
MEMBER FUNCTION totalSales(unit_price IN FLOAT)
    RETURN FLOAT 
    IS
    BEGIN
        RETURN SELF.units * unit_price;
    END totalSales;
MEMBER FUNCTION offer(rate IN FLOAT)
    RETURN FLOAT 
    IS
    BEGIN
        RETURN rate * SELF.units;
    END offer;
END;
/

-- RETRIVE DATA 
SELECT s.name, s.totalSales(130) AS total_sales
FROM sales s 
WHERE s.id = '001'

-- COMARISON 

CREATE TYPE rect_type AS OBJECT(
    width NUMBER(3),
    height NUMBER(3),
    MAP MEMBER FUNCTION area RETURN FLOAT
);

CREATE TYPE BODY rect_type AS
    MAP MEMBER FUNCTION area RETURN FLOAT
    IS 
        BEGIN
            RETURN SELF.width * SELF.height;
        END area;
    END;
    /

CREATE TABLE rect OF rect_type;

INSERT INTO rect VALUES(
    rect_type(10, 20)
);

INSERT INTO rect VALUES(
    rect_type(20, 10)
);

INSERT INTO rect VALUES(
    rect_type(10, 10)
);

SELECT r.width, r.height, r.area() AS area
FROM rect r;

-- GET MAX AREA

SELECT MAX(r.area()) AS max_area
FROM rect r;

-- ORDER METHODS

CREATE TYPE cus_type AS OBJECT(
    id NUMBER,
    name VARCHAR(20),
    address VARCHAR(20),
    ORDER MEMBER FUNCTION match (c cus_type) RETURN NUMBER
);

CREATE TYPE BODY cus_type AS
ORDER MEMBER FUNCTION match (c cus_type) RETURN NUMBER
IS
    BEGIN
        IF SELF.id < c.id THEN RETURN -1;
        ELSIF SELF.id > c.id THEN RETURN 1;
        ELSE RETURN 0;
        END IF;
    END match;
END;
```
