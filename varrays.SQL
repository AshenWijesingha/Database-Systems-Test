-- CREATE V ARRAY

CREATE TYPE address_arr AS VARRAY(3)
OF VARCHAR2(30);

CREATE TYPE personal_t AS OBJECT(
    id CHAR(3),
    name VARCHAR2(20),
    address address_arr
)

CREATE TABLE personal OF personal_t(
    id PRIMARY KEY
)
/

INSERT INTO personal VALUES(
   personal_t( '002', 'John', address_arr('123 Main St', 'New York', 'NY'))
)

-- SELECT ID AND ARRAY VALE 
SELECT p.id, t.column_value address
FROM personal p, TABLE(p.address) t

-- NESTED TABLES :::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

-- PODI TABLE EKA 

CREATE TYPE sales_t AS OBJECT(
    id INTEGER,
    unit_price NUMBER(4,2),
    sales_date DATE,
    qty NUMBER(5)
)

-- LIST EKAK HADANAWA 

CREATE TYPE sales_list AS TABLE OF sales_t;

-- LOKU TABLE EKAK HADANAWA

CREATE TYPE individual AS OBJECT(
    id CHAR(3),
    name VARCHAR2(20),
    sales sales_list
)

CREATE TABLE individual_table OF individual(
    id PRIMARY KEY
)
NESTED TABLE sales STORE AS sales_table;

-- INSERT DATA
INSERT INTO individual_table VALUES(
    individual(
        '001', 'John',
        sales_list(
            sales_t(1, 10.00, SYSDATE, 100),
            sales_t(2, 20.00, SYSDATE, 200)
        )
    )
)

-- SELECT DATA
SELECT * FROM TABLE(
    SELECT i.sales FROM individual_table i WHERE i.id = '001'
)

-- UNNESTING TABLES
SELECT i.id, s.* FROM individual_table i, TABLE(i.sales) s WHERE i.id = '001'

--INSERT DATA TO NESTED TABLE 
INSERT INTO TABLE(SELECT a.sales FROM individual_table a WHERE a.id = '001')
VALUES(3,10.00,'20-DEC-22', 70)
/

-- UPDATE 
UPDATE TABLE(SELECT i.sales FROM individual_table i WHERE i.id = '001') s 
SET s.qty = 50;

-- DELETE 
DELETE TABLE(SELECT i.sales FROM individual_table i WHERE i.id = '001') s 
WHERE s.id = 3;

UPDATE individual_table i 
SET i.sales = NULL
WHERE i.id = '001';

-- AYE ADD AKRANWA 

UPDATE individual_table i 
SET i.sales = sales_list(sales_t(3, 10.00, SYSDATE, 70))
WHERE i.id = '001';

INSERT INTO TABLE(SELECT i.sales FROM individual_table i WHERE i.id = '001') 
VALUES(sales_t(4, 10.00, SYSDATE, 70))

INSERT INTO individual_table VALUES(
    individual(
        '002', 'SUNERA',
        sales_list(
            sales_t(1, 10.00, SYSDATE, 100),
            sales_t(2, 20.00, SYSDATE, 200)
        )
    )
)