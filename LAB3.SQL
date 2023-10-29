CREATE TYPE exchanges_varray AS VARRAY(5) OF VARCHAR2(10);

CREATE TYPE stock_type AS OBJECT(
    company VARCHAR2(20),
    currentPrice NUMBER(6,2),
    exchanges exchanges_varray,
    lastDivident NUMBER(4,2),
    eps NUMBER(4,2)
);

CREATE TYPE address_type AS OBJECT(
    streetNo CHAR(10),
    streetName CHAR(30),
    suburb CHAR(20),
    state CHAR(15),
    pin CHAR(10)
);

CREATE TYPE investment_type AS OBJECT(
    company REF stock_type,
    purchasePrice NUMBER(6,2),
    purchaseDate DATE,
    quantity NUMBER(6)
);

CREATE TYPE investment_nestedtbl_type AS TABLE OF investment_type;

CREATE TYPE client_type AS OBJECT(
    id CHAR(3),
    name VARCHAR2(40),
    address address_type,
    investment investment_nestedtbl_type
)

CREATE TABLE stock_table OF stock_type(
    CONSTRAINT stock_pk PRIMARY KEY(company)
);

CREATE TABLE client_table OF client_type(
    CONSTRAINT client_pk PRIMARY KEY(id)
)NESTED TABLE investment STORE AS investment_table;

-- BHP
-- 10.50
-- Sydney
-- 1.50
-- 3.20

INSERT INTO stock_table VALUES(
    stock_type('BHP', 10.50, exchanges_varray('Sydney', 'New York'), 1.50, 3.20)
);

-- IBM
-- 70.00
-- New York
-- London
-- To 0
-- 4.25
-- 10.00

INSERT INTO stock_table VALUES(
    stock_type('IBM', 70.00, exchanges_varray('New York', 'London', 'Tokyo'), 4.25, 10.00)
);

-- INTEL
-- 76.50
-- New York
-- London
-- 5.00
-- 12.40

INSERT INTO stock_table VALUES(
    stock_type('INTEL', 76.50, exchanges_varray('New York', 'London'), 5.00, 12.40)
);

-- FORD 40.00 New York 2.00 8.50

INSERT INTO stock_table VALUES(
    stock_type('FORD', 40.00, exchanges_varray('New York'), 2.00, 8.50)
);

-- GM 60.00 New York 2.50 9.20

INSERT INTO stock_table VALUES(
    stock_type('GM', 60.00, exchanges_varray('New York'), 2.50, 9.20)
);

-- INFOSYS 45.00 New York 3.00 7.80

INSERT INTO stock_table VALUES(
    stock_type('INFOSYS', 45.00, exchanges_varray('New York'), 3.00, 7.80)
);

-- John Smith 3 East Av
-- Bentley
-- WA 6102
-- BHP 12.00 02/10/01 1000
-- BHP 10.50 08/06/02 2000
-- IBM 58.00 12/02/00 500
-- IBM 65.00 10/04/01 1200
-- INFOSYS 64.00 11/08/01 1000

INSERT INTO client_table VALUES(
    '001',
    'John Smith',
    address_type(
        '3',
        'East Av',
        'Bentley',
        'WA',
        '6102'
    ),
    investment_nestedtbl_type(
        investment_type(
            (SELECT REF(s) FROM stock_table s WHERE s.company = 'BHP'),
            12.00,
            '02-Oct-01',
            1000
        ),
        investment_type(
            (SELECT REF(s) FROM stock_table s WHERE s.company = 'BHP'),
            10.50,
            '08-Jun-02',
            2000
        ),
        investment_type(
            (SELECT REF(s) FROM stock_table s WHERE s.company = 'IBM'),
            58.00,
            '12-Feb-00',
            500
        ),
        investment_type(
            (SELECT REF(s) FROM stock_table s WHERE s.company = 'IBM'),
            65.00,
            '10-Apr-01',
            1200
        ),
        investment_type(
            (SELECT REF(s) FROM stock_table s WHERE s.company = 'INFOSYS'),
            64.00,
            '11-Aug-01',
            1000
        )
    )
)

-- Jill Brody 42 Bent St
-- Perth
-- WA 6001
-- INTEL 35.00 30/01/00 300
-- INTEL 54.00 30/01/01 400
-- INTEL 60.00 02/10/01 200
-- FORD 40.00 05/10/99 300
-- GM 55.50 12/12/00 500

INSERT INTO client_table VALUES(
    '002',
    'Jill Brody',
    address_type(
        '42',
        'Bent St',
        'Perth',
        'WA',
        '6001'
    ),
    investment_nestedtbl_type(
        investment_type(
            (SELECT REF(s) FROM stock_table s WHERE s.company = 'INTEL'),
            35.00,
            '30-Jan-00',
            300
        ),
        investment_type(
            (SELECT REF(s) FROM stock_table s WHERE s.company = 'INTEL'),
            54.00,
            '30-Jan-01',
            400
        ),
        investment_type(
            (SELECT REF(s) FROM stock_table s WHERE s.company = 'INTEL'),
            60.00,
            '02-Oct-01',
            200
        ),
        investment_type(
            (SELECT REF(s) FROM stock_table s WHERE s.company = 'FORD'),
            40.00,
            '05-Oct-99',
            300
        ),
        investment_type(
            (SELECT REF(s) FROM stock_table s WHERE s.company = 'GM'),
            55.50,
            '12-Dec-00',
            500
        )
    )
)

-- (a) For each client, get the client’s name, and the list of the client’s investments with stock name, 
-- current price, last dividend and earnings per share. 

SELECT c.name, i.company.company, i.company.currentPrice, i.company.lastDivident, i.company.eps
FROM client_table c, TABLE(c.investment) i;

-- (b) Get the list of all clients and their share investments, showing the client name, and for each 
-- stock held by the client, the name of the stock, total number of shares held, and the average 
-- purchase price paid by the client for the stock. Average price is the total purchase value paid 
-- by a client for a given stock (value=qty*price) divided by the total quantity held by the client.

SELECT c.name, i.company.company, SUM(i.quantity), AVG(i.purchasePrice)
FROM client_table c, TABLE(c.investment) i
GROUP BY c.name, i.company.company;

SELECT
    c.name AS client_name,
    i.company.company AS stock_name,
    SUM(i.quantity) AS total_shares,
    SUM(i.purchasePrice * i.quantity) / SUM(i.quantity) AS average_purchase_price
FROM
    client_table c,
    TABLE(c.investment) i
WHERE
    c.id IS NOT NULL
GROUP BY
    c.name,
    i.company.company
ORDER BY
    c.name,
    i.company.company;


-- (c) For each stock traded in New York, find the quantity held by each client, and its current value 
-- (value=qty*price). Display stock (company) name, client name, number of shares held, and the 
-- current value of the shares.

SELECT
    s.company AS stock_name,
    c.name AS client_name,
    SUM(i.quantity) AS total_shares_held,
    SUM(i.quantity * s.currentPrice) AS current_value
FROM
    stock_table s,
    client_table c,
    TABLE(c.investment) i
WHERE
    EXISTS (
        SELECT 1
        FROM TABLE(s.exchanges) ex
        WHERE ex.COLUMN_VALUE = 'New York'
    )
GROUP BY
    s.company,
    c.name
ORDER BY
    s.company,
    c.name;


-- (d) Find the total purchase value of investments for all clients. Display client name and total 
-- purchase value of the client’s portfolio. 

SELECT c.name, SUM(i.purchasePrice * i.quantity) AS TotalPurchaseValue
FROM client_table c, TABLE(c.investment) i
GROUP BY c.name;

-- (e) For each client, list the book profit (or loss) on the total share investment. Book profit is the 
-- total value of all stocks based on the current prices less the total amount paid for purchasing 
-- them.

SELECT
    c.name AS client_name,
    SUM(i.quantity * s.currentPrice) - SUM(i.purchasePrice * i.quantity) AS book_profit_or_loss
FROM
    client_table c,
    TABLE(c.investment) i,
    stock_table s
WHERE
    s.company = i.company.company
GROUP BY
    c.name
ORDER BY
    c.name;
