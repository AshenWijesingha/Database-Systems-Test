-- a) A method to compute the yield of stocks: Yield is the dividend expressed as a percentage of the current 
-- price (yield = (dividend/current price) *100). Assume that all dividends are for a period of one year.

ALTER TYPE stock_type
ADD MEMBER FUNCTION yield 
RETURN FLOAT CASCADE;

CREATE OR REPLACE TYPE BODY stock_type AS
    MEMBER FUNCTION yield RETURN FLOAT IS
    BEGIN
        RETURN ((SELF.lastDivident/self.currentPrice)*100);
    END yield;
END;

-- (b) A method to compute the current price of stocks in US dollars, taking the current exchange rate of AUD to 
-- USD as an input parameter (assuming that the prices in the STOCKS table are in AUD).

ALTER TYPE stock_type 
ADD MEMBER FUNCTION  AUDtoUSD(rate FLOAT)
RETURN FLOAT
CASCADE;

CREATE OR REPLACE TYPE BODY stock_type AS
    MEMBER FUNCTION  AUDtoUSD(rate FLOAT) RETURN FLOAT
    IS
    BEGIN
        RETURN SELF.currentPrice*rate;
    END AUDtoUSD;

    MEMBER FUNCTION yield RETURN FLOAT 
    IS
    BEGIN
        RETURN ((SELF.lastDivident/self.currentPrice)*100);
    END yield;
END;

-- (c) A method to count the number of exchanges where a given stock is traded.

ALTER TYPE stock_type
ADD MEMBER FUNCTION no_of_trades 
RETURN INTEGER 
CASCADE;

CREATE OR REPLACE TYPE BODY stock_type AS
    MEMBER FUNCTION no_of_trades RETURN INTEGER IS
        countt INTEGER;
    BEGIN
        SELECT COUNT(e.column_value) INTO countt
        FROM TABLE(self.exchanges) e;
        RETURN countt;
    END no_of_trades;

    MEMBER FUNCTION AUDtoUSD(rate FLOAT) RETURN FLOAT
    IS
    BEGIN
        RETURN SELF.currentPrice*rate;
    END AUDtoUSD;

    MEMBER FUNCTION yield RETURN FLOAT 
    IS
    BEGIN
        RETURN ((SELF.lastDivident/self.currentPrice)*100);
    END yield;
END;

-- (d) A method to compute the purchase value of all the shares of a client (for each share purchased, purchase 

ALTER TYPE client_type
ADD 
MEMBER FUNCTION purchase_value 
RETURN FLOAT
CASCADE;

CREATE OR REPLACE TYPE BODY client_type AS
    MEMBER FUNCTION purchase_value RETURN FLOAT IS
        total_purchase_value FLOAT;
    BEGIN
        SELECT SUM(i.quantity * i.purchasePrice) INTO total_purchase_value
        FROM TABLE(self.investment) i;
        RETURN total_purchase_value;
    END purchase_value;
END;

CREATE OR REPLACE TYPE BODY client_type AS
    MEMBER FUNCTION purchase_value RETURN FLOAT IS
        total_purchase_value FLOAT;
    BEGIN
        SELECT SUM(i.quantity * i.purchasePrice) INTO total_purchase_value
        FROM TABLE(SELF.investment) i;
        RETURN total_purchase_value;
    END purchase_value;
END;

-- value = purchase price * qty).
-- (e) A method to compute the total profit on all the shares of a client (for each share purchase, profit = 
-- (current price - purchase price) * qty).

ALTER TYPE client_type 
ADD 
MEMBER FUNCTION calcProfits 
RETURN FLOAT 
CASCADE;

CREATE OR REPLACE TYPE BODY client_type AS 
    MEMBER FUNCTION purchase_value RETURN FLOAT IS
        total_purchase_value FLOAT;
    BEGIN
        SELECT SUM(i.quantity * i.purchasePrice) INTO total_purchase_value
        FROM TABLE(SELF.investment) i;
        RETURN total_purchase_value;
    END purchase_value;
    MEMBER FUNCTION calcProfits RETURN FLOAT IS
    profitt FLOAT;
    BEGIN
        SELECT SUM(i.company.currentPrice - i.purchasePrice * i.qty) INTO profitt
        FROM TABLE(SELF.investment) i;
        RETURN profitt;
    END calcProfits;
END;