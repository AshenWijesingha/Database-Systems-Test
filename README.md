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
