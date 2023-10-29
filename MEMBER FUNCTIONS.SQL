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

-- NESTED TABLE 


