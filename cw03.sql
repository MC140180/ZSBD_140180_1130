--1. Utwórz widok v_wysokie_pensje, dla tabeli employees który pokaże wszystkich
--pracowników zarabiających więcej niż 6000.
create view v_wysokie_pensje as 
select first_name, last_name, salary from employees 
where salary > 6000;
--2. Zmień definicję widoku v_wysokie_pensje aby pokazywał tylko pracowników
--zarabiających powyżej 12000.
create or replace view v_wysokie_pensje as 
select first_name, last_name, salary from employees 
where salary > 12000;
--3. Usuń widok v_wysokie_pensje.
drop view v_wysokie_pensje;
--4. Stwórz widok dla tabeli employees zawierający: employee_id, last_name, first_name, dla
--pracowników z departamentu o nazwie Finance
create view employees_finance as
select e.employee_id, e.last_name, e.first_name 
from employees e 
inner join departments on departments.department_id = e.department_id
where departments.department_name = 'Finance';
--5. Stwórz widok dla tabeli employees zawierający: employee_id, last_name, first_name,
--salary, job_id, email, hire_date dla pracowników mających zarobki pomiędzy 5000 a
--12000.
create view employees_5 as
select e.employee_id, e.last_name, e.first_name, e.salary, e.job_id, 
e.email, e.hire_date
from employees e 
where e.salary between 5000 and 12000;
--6. Poprzez utworzone widoki sprawdź czy możesz:
--a. dodać nowego pracownika
insert into employees_5 (employee_id, first_name, last_name, salary, job_id, email, hire_date)
values (7799, 'Andrzej', 'Andrzejewicz', 7799, 'AnD_And', 'endrju@example.com', '2025-04-24');
--b. edytować pracownika
update employees_5
set salary = 7777
where employee_id = 7799;
--c. usunąć pracownika
delete from employees_5
where employee_id = 7799;
--7. Stwórz widok, który dla każdego działu który zatrudnia przynajmniej 4 pracowników
--wyświetli: identyfikator działu, nazwę działu, liczbę pracowników w dziale, średnią
--pensja w dziale i najwyższa pensja w dziale.
create view departments_7 as
select
    d.department_id, 
    d.department_name, 
    count(e.employee_id) as liczba_pracownikow, 
    avg(e.salary) as srednia_pensja, 
    max(e.salary) as najwyzsza_pensja
from departments d
join employees e on e.department_id = d.department_id
group by d.department_id, d.department_name
having count(e.employee_id) >= 4;
--a. Sprawdź czy możesz dodać dane do tego widoku.
-- Nie można
insert into departments_7 (department_id, department_name, liczba_pracownikow, srednia_pensja, najwyzsza_pensja)
values (7200, 'Testowy', 50, 7700, 12200);

--8. Stwórz analogiczny widok zadania 5 z dodaniem warunku ‘WITH CHECK OPTION’.
create view employees_5_check as
select e.employee_id, e.last_name, e.first_name, e.salary, e.job_id, 
e.email, e.hire_date
from employees e 
where e.salary between 5000 and 12000;
with check option;
--a. Sprawdź czy możesz:
--i. dodać pracownika z zarobkami pomiędzy 5000 a 12000.
-- TAK
insert into employees_5_check (employee_id, last_name, first_name, salary, job_id, email, hire_date)
values (1123, 'Wiktorowicz', 'Jan', 6000, 'IT_PROG', 'jan.Wiktorowicz@example.com', '2025-04-24');
--ii. dodać pracownika z zarobkami powyżej 12000.
-- NIE
insert into employees_5_check (employee_id, last_name, first_name, salary, job_id, email, hire_date)
values (1123, 'Wiktorowicz', 'Jan', 20000, 'IT_PROG', 'jan.Wiktorowicz@example.com', '2025-04-24');
--9. Utwórz widok zmaterializowany v_managerowie, który pokaże tylko menedżerów w raz
--z nazwami ich działów.
create MATERIALIZED VIEW v_managerowie AS
select e.employee_id, e.first_name, e.last_name, e.job_id, e.salary, d.department_name
from employees e
join departments d on e.department_id = d.department_id
where E e.employee_id in (select distinct manager_id from employees where E manager_id is not null);
--10. Stwórz widok v_najlepiej_oplacani, który zawiera tylko 10 najlepiej opłacanych
--pracowników
create view v_najlepiej_oplacani as 
select * from employees
order by salary desc
fetch first 10 rows only;
