-- UNIVERSITY DATABASE
-- ===================
-- SCHEMA
-- ===================

create type student_typ as object
(
    regNo char(10),
    name  varchar2(50),
    gpa   float,
    year  int
);
/

create type Member_typ as object
(
    team_member ref student_typ,
    grade       char
);
/

create type member_t_ty as table of member_typ;
/


create type project_typ as object
(
    id        char(3),
    title     varchar2(50),
    team_lead ref student_typ,
    members   member_t_ty
);
/


create table students_tbl of student_typ
(
    regNo primary key
);

create table projects_tbl of project_typ
(
    id primary key
) nested table members store as ntlb_members;


-- LOADING DATA
-- ============
insert into students_tbl values ('DIT/M/0001', 'Sampath W.', 2.98, 1);
insert into students_tbl values ('DIT/M/0002', 'Dulani F.', 3.22, 2);
insert into students_tbl values ('DIT/M/0012', 'Sajith P.', 3.72, 1);
insert into students_tbl values ('DIT/M/0023', 'Amali W.', 2.99, 2);


insert into projects_tbl
values (project_typ(
        'M11',
        'Bank of Ceylon',
        (select ref(s) from students_tbl s where s.regNo = 'DIT/M/0001'),
        member_t_ty(
                member_typ((select ref(s) from students_tbl s where regNo = 'DIT/M/0001'), 'B'),
                member_typ((select ref(s) from students_tbl s where regNo = 'DIT/M/0012'), 'A')
            )
    ));

insert into projects_tbl
values ('M21',
        'Virtusa',
        (select ref(s) from students_tbl s where regNo = 'DIT/M/0002'),
        member_t_ty());

insert into table (select p.members from projects_tbl p where p.id = 'M21') values ((select ref(s) from students_tbl s where regNo = 'DIT/M/0002'), 'B');
insert into table (select p.members from projects_tbl p where p.id = 'M21') values ((select ref(s) from students_tbl s where regNo = 'DIT/M/0023'), 'C');

-- LAB EXAM --
-- ======== --

select p.ID, p.team_lead.NAME, m.grade
from projects_tbl p,
     table ( p.MEMBERS ) m
where p.TEAM_LEAD.GPA > 3.0

alter type project_typ add member function maxGPA
    return float
    cascade
/

create or replace type body project_typ as
    member function maxGPA return float is
    result integer;
    begin
        select max(t.TEAM_LEAD.GPA) into result
        from projects_tbl t;
        return result;
    end;
end;
/

select t.TITLE, t.maxGPA()
from projects_tbl t
order by t.maxGPA() desc;
/
