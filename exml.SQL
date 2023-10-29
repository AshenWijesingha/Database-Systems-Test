CREATE TABLE demo(
id INTEGER PRIMARY KEY,
exml XML
);

INSERT INTO demo VALUES
( 1, '
<Students>
    <Student>
        <Name>John</Name>
        <Age>20</Age>
        <Address>
            <Street>123 Main St</Street>
            <City>Anytown</City>
            <State>WA</State>
            <Zip>12345</Zip>
        </Address>
    </Student>
</Students>');

-- JHONATHON 

INSERT INTO demo VALUES
( 2, '
<Students>
    <Student>
        <Name>Johnathon</Name>
        <Age>20</Age>
        <Address>
            <Street>123 Main St</Street>
            <City>Anytown</City>
            <State>WA</State>
            <Zip>12345</Zip>
        </Address>
    </Student>
</Students>');

SELECT id, exml.query('//Student[Age >11 ]')
FROM demo;

SELECT id, exml.query('//Student/Age[. gt 11 ]')
FROM demo;

SELECT exml.query('
for $std in /Students/Student
return $std
')
FROM demo;

SELECT exml.query('
for $std in /Students/Student
where $std/Age gt 11
return $std
')
FROM demo;

SELECT exml.query('
let $avge := 0
for $std in /Students/Student
$avge := $avge + $std/Age
return $avge div count(/Students/Student)
')
FROM demo;

UPDATE demo
SET exml.modify('
insert <Student>
    <Name>Sunera</Name>
    <Age>22</Age>
    <Address>
        <Street>123 Main St</Street>
        <City>Anytown</City>
        <State>WA</State>
        <Zip>12345</Zip>
    </Address>
</Student>
into (/Students)[1]
')
WHERE id = 1;

SELECT id, exml
FROM demo;

UPDATE demo
SET exml.modify('
delete /Students/Student[Name="Johnathon"]
')
WHERE id = 2;