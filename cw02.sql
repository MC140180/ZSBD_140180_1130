
-- Usuń wszystkie tabele ze swojej bazy
DROP TABLE JOB_HISTORY;
DROP TABLE DEPARTMENTS;
DROP TABLE LOCATIONS;
DROP TABLE EMPLOYEES;
DROP TABLE COUNTRIES;
DROP TABLE REGIONS;
DROP TABLE JOBS;



-- II. Przekopiuj wszystkie tabele wraz z danymi od użytkownika HR.
-- Poustawiaj klucze główne i obce
create table COUNTRIES as select * from hr.COUNTRIES;
create table DEPARTMENTS as select * from hr.DEPARTMENTS;
create table EMPLOYEES as select * from hr.EMPLOYEES;
create table JOB_GRADES as select * from hr.JOB_GRADES;
create table JOB_HISTORY as select * from hr.JOB_HISTORY;
create table JOBS as select * from hr.JOBS;
create table LOCATIONS as select * from hr.LOCATIONS;
create table CPRODUCTS as select * from hr.PRODUCTS;
create table REGIONS as select * from hr.REGIONS;
create table SALES as select * from hr.SALES;

ALTER TABLE regions
ADD CONSTRAINT pk_region_id PRIMARY KEY (region_id);

ALTER TABLE countries
ADD CONSTRAINT pk_country_id PRIMARY KEY (country_id);

ALTER TABLE countries
ADD CONSTRAINT fk_region_id FOREIGN KEY (region_id) REFERENCES regions(region_id);

ALTER TABLE locations
ADD CONSTRAINT pk_location_id PRIMARY KEY (location_id);

ALTER TABLE locations
ADD CONSTRAINT fk_country_id FOREIGN KEY (country_id) REFERENCES countries(country_id);

ALTER TABLE cproducts
ADD CONSTRAINT pk_cproducts_id PRIMARY KEY (product_id);

ALTER TABLE jobs
ADD CONSTRAINT pk_job_id PRIMARY KEY (job_id);

ALTER TABLE job_grades
ADD CONSTRAINT pk_grade_id PRIMARY KEY (grade);

ALTER TABLE departments
ADD CONSTRAINT pk_deparment_id PRIMARY KEY (department_id);

ALTER TABLE employees
ADD CONSTRAINT pk_employee_id PRIMARY KEY (employee_id);

ALTER TABLE employees
ADD CONSTRAINT fk_department_id FOREIGN KEY (department_id) REFERENCES departments(department_id);

ALTER TABLE employees
ADD CONSTRAINT fk_employee_manager FOREIGN KEY (manager_id) REFERENCES employees(employee_id);

ALTER TABLE job_history
ADD CONSTRAINT pk_employee_start_date PRIMARY KEY (employee_id, start_date);

ALTER TABLE job_history
ADD CONSTRAINT fk_job_id 
    FOREIGN KEY (job_id) 
    REFERENCES jobs (job_id);

ALTER TABLE job_history
ADD CONSTRAINT fk_department_job 
    FOREIGN KEY (department_id) 
    REFERENCES departments (department_id);

ALTER TABLE job_history
ADD CONSTRAINT fk_jhistory_employee
    FOREIGN KEY (employee_id) 
    REFERENCES employees (employee_id);

ALTER TABLE departments
ADD CONSTRAINT fk_department_manager FOREIGN KEY (manager_id) REFERENCES employees(employee_id);

ALTER TABLE departments
ADD CONSTRAINT fk_department_location FOREIGN KEY (location_id) REFERENCES locations(location_id);

ALTER TABLE sales
ADD CONSTRAINT pk_sale_id PRIMARY KEY (sale_id);

ALTER TABLE sales
ADD CONSTRAINT fk_sale_employee FOREIGN KEY (employee_id) REFERENCES employees(employee_id);

ALTER TABLE sales
ADD CONSTRAINT fk_sale_product FOREIGN KEY (product_id) REFERENCES cproducts(product_id);

-- III. Stwórz następujące perspektywy lub zapytania, dodaj wszystko do
-- swojego repozytorium:
--1. Z tabeli employees wypisz w jednej kolumnie nazwisko i zarobki – nazwij
--kolumnę wynagrodzenie, dla osób z departamentów 20 i 50 z zarobkami
--pomiędzy 2000 a 7000, uporządkuj kolumny według nazwiska
SELECT last_name || ' ' || salary AS wynagrodzenie
FROM employees
WHERE department_id IN (20, 50)
  AND salary BETWEEN 2000 AND 7000
ORDER BY last_name;




-- 2. Z tabeli employees wyciągnąć informację data zatrudnienia, nazwisko oraz
-- kolumnę podaną przez użytkownika dla osób mających menadżera
-- zatrudnionych w roku 2005. Uporządkować według kolumny podanej przez
-- użytkownika  

SELECT hire_date, last_name, &your_column 
FROM employees
WHERE manager_id IS NOT NULL
  AND EXTRACT(YEAR FROM hire_date) = 2005
ORDER BY &your_column;



-- 3. Wypisać imiona i nazwiska razem, zarobki oraz numer telefonu porządkując
-- dane według pierwszej kolumny malejąco a następnie drugiej rosnąco (użyć
-- numerów do porządkowania) dla osób z trzecią literą nazwiska ‘e’ oraz częścią
-- imienia podaną przez użytkownika
SELECT first_name || ' ' || last_name AS full_name, salary, phone_number
FROM employees
WHERE SUBSTR(last_name, 3, 1) = 'e' 
  AND first_name LIKE '%' || 'a' || '%'  -- zakładamy, że użytkownik przekazuje a
ORDER BY full_name DESC, salary ASC;



-- 4. Wypisać imię i nazwisko, liczbę miesięcy przepracowanych – funkcje
-- months_between oraz round oraz kolumnę wysokość_dodatku jako (użyć CASE
-- lub DECODE):
-- ● 10% wynagrodzenia dla liczby miesięcy do 150
-- ● 20% wynagrodzenia dla liczby miesięcy od 150 do 200
-- ● 30% wynagrodzenia dla liczby miesięcy od 200
-- ● uporządkować według liczby miesięcy
SELECT 
    first_name || ' ' || last_name AS full_name,
    months_between(SYSDATE, hire_date) AS job_months,
    salary,
    CASE 
        WHEN months_between(SYSDATE, hire_date) <= 150 THEN ROUND(salary * 0.1, 2)
        WHEN months_between(SYSDATE, hire_date) BETWEEN 151 AND 200 THEN ROUND(salary * 0.2, 2)
        WHEN round(months_between(SYSDATE, hire_date), 0) > 200 THEN ROUND(salary * 0.3, 2)
    END AS wysokosc_dodatku
FROM employees
ORDER BY job_months;



--5. Dla każdego działów w których minimalna płaca jest wyższa niż 5000 wypisz
--sumę oraz średnią zarobków zaokrągloną do całości nazwij odpowiednio
--kolumny
SELECT
    DEPARTMENTS.DEPARTMENT_NAME AS dział,
    SUM(EMPLOYEES.SALARY) AS suma_zarobków,
    ROUND(AVG(EMPLOYEES.SALARY)) AS średnia_zarobków
FROM 
    EMPLOYEES 
JOIN 
    DEPARTMENTS ON EMPLOYEES.DEPARTMENT_ID = DEPARTMENTS.DEPARTMENT_ID
JOIN 
    JOBS ON EMPLOYEES.JOB_ID = JOBS.JOB_ID
WHERE 
    JOBS.MIN_SALARY > 5000
GROUP BY 
    DEPARTMENTS.DEPARTMENT_NAME;


--6. Wypisać nazwisko, numer departamentu, nazwę departamentu, id pracy, dla
--osób z pracujących Toronto
SELECT 
    EMPLOYEES.LAST_NAME, EMPLOYEES.DEPARTMENT_ID,
    DEPARTMENTS.DEPARTMENT_NAME, EMPLOYEES.JOB_ID
FROM 
    EMPLOYEES 
JOIN 
    DEPARTMENTS ON EMPLOYEES.DEPARTMENT_ID = DEPARTMENTS.DEPARTMENT_ID
JOIN 
    LOCATIONS ON LOCATIONS.LOCATION_ID = DEPARTMENTS.LOCATION_ID
    JOIN 
    LOCATIONS ON LOCATIONS.LOCATION_ID = DEPARTMENTS.LOCATION_ID
WHERE 
    LOCATIONS.CITY = 'Toronto'
    -- poprawka?
--7. Dla pracowników o imieniu „Jennifer” wypisz imię i nazwisko tego pracownika
--oraz osoby które z nim współpracują
SELECT 
    E.FIRST_NAME || ' ' || E.LAST_NAME AS Pracownik,
    W.FIRST_NAME || ' ' || W.LAST_NAME AS Współpracownik
FROM 
    EMPLOYEES E
LEFT JOIN 
    EMPLOYEES W ON (E.EMPLOYEE_ID = W.MANAGER_ID OR E.MANAGER_ID = W.EMPLOYEE_ID)
                OR E.DEPARTMENT_ID = W.DEPARTMENT_ID
WHERE 
    E.FIRST_NAME = 'Jennifer';



-- 8. Wypisać wszystkie departamenty w których nie ma pracowników
SELECT 
    D.DEPARTMENT_ID,
    D.DEPARTMENT_NAME
FROM 
    DEPARTMENTS D
LEFT JOIN 
    EMPLOYEES E ON D.DEPARTMENT_ID = E.DEPARTMENT_ID
WHERE 
    E.EMPLOYEE_ID IS NULL;



--9. Wypisz imię i nazwisko, id pracy, nazwę departamentu, zarobki, oraz
--odpowiedni grade dla każdego pracownika
SELECT 
    E.FIRST_NAME || ' ' || E.LAST_NAME AS Imie_Nazwisko,
    E.JOB_ID,
    D.DEPARTMENT_NAME AS Departament,
    E.SALARY AS Zarobki,
    JG.GRADE AS Grade
FROM 
    EMPLOYEES E
JOIN 
    DEPARTMENTS D ON E.DEPARTMENT_ID = D.DEPARTMENT_ID
JOIN 
    JOBS J ON E.JOB_ID = J.JOB_ID
JOIN 
    job_grades JG ON E.SALARY BETWEEN JG.MIN_SALARY AND JG.MAX_SALARY;



--10.Wypisz imię nazwisko oraz zarobki dla osób które zarabiają więcej niż średnia
--wszystkich, uporządkuj malejąco według zarobków
SELECT 
    FIRST_NAME || ' ' || LAST_NAME AS Imie_Nazwisko,
    SALARY AS Zarobki
FROM 
    EMPLOYEES
WHERE 
    SALARY > (SELECT AVG(SALARY) FROM EMPLOYEES)
ORDER BY 
    SALARY DESC;



--11.Wypisz id imię i nazwisko osób, które pracują w departamencie z osobami
--mającymi w nazwisku „u”
select employees.first_name, employees.last_name
from employees
join departments on departments.department_id = employees.department_id
WHERE 
   departments.department_id IN (
        SELECT DISTINCT employees2.department_id
        FROM EMPLOYEES employees2
        WHERE employees2.last_name LIKE '%u%'
    );



--12.Znajdź pracowników, którzy pracują dłużej niż średnia długość zatrudnienia w
--firmie.
SELECT 
    EMPLOYEE_ID, 
    FIRST_NAME || ' ' || LAST_NAME AS Imie_Nazwisko,
    HIRE_DATE,
    ROUND(MONTHS_BETWEEN(SYSDATE, HIRE_DATE) / 12, 2) AS Zatrudnienie_w_latach -- dl.zatrudnienia w latach
FROM 
    EMPLOYEES
WHERE 
    MONTHS_BETWEEN(SYSDATE, HIRE_DATE) / 12 > (
        SELECT AVG(MONTHS_BETWEEN(SYSDATE, HIRE_DATE) / 12) 
        FROM EMPLOYEES
    )
ORDER BY 
    Zatrudnienie_w_latach DESC;



--13.Wypisz nazwę departamentu, liczbę pracowników oraz średnie wynagrodzenie
--w każdym departamencie. Sortuj według liczby pracowników malejąco.
SELECT 
    D.DEPARTMENT_NAME AS Departament_Nazwa,
    COUNT(E.EMPLOYEE_ID) AS Liczba_Pracownikow,
    ROUND(AVG(E.SALARY), 2) AS Srednie_Wynagrodzenie
FROM 
    DEPARTMENTS D
JOIN 
    EMPLOYEES E ON D.DEPARTMENT_ID = E.DEPARTMENT_ID
GROUP BY 
    D.DEPARTMENT_NAME
ORDER BY 
    Liczba_Pracownikow DESC;



--14.Wypisz imiona i nazwiska pracowników, którzy zarabiają mniej niż jakikolwiek
--pracownik w departamencie „IT”.
SELECT 
    E.FIRST_NAME || ' ' || E.LAST_NAME AS Imie_Nazwisko
FROM 
    EMPLOYEES E
WHERE 
    E.SALARY < (
        SELECT MIN(E2.SALARY) 
        FROM EMPLOYEES E2
        JOIN DEPARTMENTS D ON E2.DEPARTMENT_ID = D.DEPARTMENT_ID
        WHERE D.DEPARTMENT_NAME = 'IT'
    );




--15.Znajdź departamenty, w których pracuje co najmniej jeden pracownik
--zarabiający więcej niż średnia pensja w całej firmie.
SELECT DISTINCT 
    D.DEPARTMENT_NAME AS Departament_Nazwa
FROM 
    DEPARTMENTS D
JOIN 
    EMPLOYEES E ON D.DEPARTMENT_ID = E.DEPARTMENT_ID
WHERE 
    E.SALARY > (
        SELECT AVG(E2.SALARY)
        FROM EMPLOYEES E2
    );




--16.Wypisz pięć najlepiej opłacanych stanowisk pracy wraz ze średnimi zarobkami.
SELECT 
    J.JOB_TITLE AS Stanowisko,
    ROUND(AVG(E.SALARY), 2) AS Srednie_Zarobki
FROM 
    JOBS J
JOIN 
    EMPLOYEES E ON J.JOB_ID = E.JOB_ID
GROUP BY 
    J.JOB_TITLE
ORDER BY 
    Srednie_Zarobki DESC
FETCH FIRST 5 ROWS ONLY;




--17.Dla każdego regionu, wypisz nazwę regionu, liczbę krajów oraz liczbę
--pracowników, którzy tam pracują.
SELECT 
    R.REGION_NAME AS Nazwa_Regionu,
    COUNT(DISTINCT C.COUNTRY_ID) AS Liczba_Krajow,
    COUNT(E.EMPLOYEE_ID) AS Liczba_Pracownikow
FROM 
    REGIONS R
left join 
    COUNTRIES C ON R.REGION_ID = C.REGION_ID
left join
    LOCATIONS L ON C.COUNTRY_ID = L.COUNTRY_ID
left join DEPARTMENTS D ON d.location_id = l.location_id     
left join
    EMPLOYEES E ON d.department_id = E.department_ID
GROUP BY 
    R.REGION_NAME
ORDER BY 
    R.REGION_NAME;




--18.Podaj imiona i nazwiska pracowników, którzy zarabiają więcej niż ich
--menedżerowie.
SELECT 
    E.FIRST_NAME || ' ' || E.LAST_NAME AS Imie_Nazwisko
FROM 
    EMPLOYEES E
JOIN 
    EMPLOYEES M ON E.MANAGER_ID = M.EMPLOYEE_ID
WHERE 
    E.SALARY > M.SALARY;



--19.Policz, ilu pracowników zaczęło pracę w każdym miesiącu (bez względu na rok).
SELECT 
    TO_CHAR(HIRE_DATE, 'MM') AS Miesiac,
    COUNT(EMPLOYEE_ID) AS Liczba_Pracownikow
FROM 
    EMPLOYEES
GROUP BY 
    TO_CHAR(HIRE_DATE, 'MM')
ORDER BY 
    Miesiac;




--20.Znajdź trzy departamenty z najwyższą średnią pensją i wypisz ich nazwę oraz
--średnie wynagrodzenie.
SELECT 
    D.DEPARTMENT_NAME AS Departament_Nazwa,
    ROUND(AVG(E.SALARY), 2) AS Srednia_Pensja
FROM 
    DEPARTMENTS D
JOIN 
    EMPLOYEES E ON D.DEPARTMENT_ID = E.DEPARTMENT_ID
GROUP BY 
    D.DEPARTMENT_NAME
ORDER BY 
    Srednia_Pensja DESC
FETCH FIRST 3 ROWS ONLY;
