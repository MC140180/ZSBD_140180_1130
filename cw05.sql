SET SERVEROUTPUT on;


--1. Stworzyć blok anonimowy wypisujący zmienną max_number równą
--maksymalnemu numerowi Departamentu i dodaj do tabeli departamenty –
--departament z numerem o 10 wiekszym, typ pola dla zmiennej z nazwą nowego
--departamentu (zainicjować na EDUCATION) ustawić taki jak dla pola
--department_name w tabeli (%TYPE)


DECLARE
  max_number departments.department_id%TYPE;
BEGIN
  SELECT MAX(department_id) INTO max_number FROM departments;

  DBMS_OUTPUT.PUT_LINE('Maksymalny numer departamentu: ' || max_number);

  INSERT INTO departments (department_id, department_name)
  VALUES (max_number + 10, 'EDUCATION');

  COMMIT;
END;



--2. Do poprzedniego skryptu dodaj instrukcje zmieniającą location_id (3000) dla
--dodanego departamentu
DECLARE
  max_number departments.department_id%TYPE;
  nowy_departament_id departments.department_id%TYPE; 
BEGIN
  SELECT MAX(department_id) INTO max_number FROM departments;

  nowy_departament_id := max_number + 10;

  DBMS_OUTPUT.PUT_LINE('Największy numer departamentu: ' || max_number);

  INSERT INTO departments (department_id, department_name)
  VALUES (nowy_departament_id, 'TECHNICIANS');

  UPDATE departments
  SET location_id = 3000
  WHERE department_id = nowy_departament_id;

  COMMIT;
END;



--3. Stwórz tabelę nowa z jednym polem typu varchar a następnie wpisz do niej za
--pomocą pętli liczby od 1 do 10 bez liczb 4 i 6
CREATE TABLE nowa (
  liczba VARCHAR2(10)
);

DECLARE
  v_liczba VARCHAR2(10); 
BEGIN
  FOR i IN 1..10 LOOP
    IF i != 4 AND i != 6 THEN
      v_liczba := TO_CHAR(i); 
      INSERT INTO nowa (liczba) VALUES (v_liczba);
    END IF;
  END LOOP;
  
  COMMIT;
  
END;



--4. Wyciągnąć informacje z tabeli countries do jednej zmiennej (%ROWTYPE) dla
--kraju o identyfikatorze ‘CA’. Wypisać nazwę i region_id na ekran
DECLARE
  v_country countries%ROWTYPE; --zmienna na dane z countries
BEGIN
  SELECT * INTO v_country FROM countries WHERE country_id = 'CA';

  DBMS_OUTPUT.PUT_LINE('Nazwa kraju: ' || v_country.country_name);
  DBMS_OUTPUT.PUT_LINE('Region ID: ' || v_country.region_id);
END;



--5. Stworzyć blok anonimowy, który zwiększy min_salary o 5% dla stanowisk z
--job_title zawierającego słowo "Manager". Użyj zmiennej typu jobs%ROWTYPE.
--Wyświetl liczbę zaktualizowanych rekordów.
DECLARE
  v_job jobs%ROWTYPE;
  update_count NUMBER := 0;   
BEGIN
  FOR v_job IN (SELECT * FROM jobs WHERE job_title LIKE '%Manager%') LOOP
    UPDATE jobs
    SET min_salary = min_salary * 1.05
    WHERE job_id = v_job.job_id;

    update_count := update_count + 1;
  END LOOP;

  COMMIT;
  DBMS_OUTPUT.PUT_LINE('Zaktualizowanych rekordów: ' || update_count);
END;


DECLARE
  update_count NUMBER := 0;  
BEGIN
  UPDATE jobs
  SET min_salary = min_salary / 1.05
  WHERE job_title LIKE '%Manager%';

  update_count := SQL%ROWCOUNT;

  COMMIT;

  DBMS_OUTPUT.PUT_LINE('Przywróconych rekordów: ' || update_count);
END;



--6. Zadeklaruj zmienną przechowującą dane z tabeli JOBS. Znajdź i wypisz na ekran
--informacje o stanowisku o najwyższej maksymalnej pensji (max_salary).
DECLARE
  v_job jobs%ROWTYPE;
BEGIN
  SELECT * INTO v_job FROM jobs
  WHERE max_salary = (SELECT MAX(max_salary) FROM jobs);

  DBMS_OUTPUT.PUT_LINE('Stanowisko o najwyższej maksymalnej pensji:');
  DBMS_OUTPUT.PUT_LINE('Job ID: ' || v_job.job_id);
  DBMS_OUTPUT.PUT_LINE('Job Title: ' || v_job.job_title);
  DBMS_OUTPUT.PUT_LINE('Min Salary: ' || v_job.min_salary);
  DBMS_OUTPUT.PUT_LINE('Max Salary: ' || v_job.max_salary);
END;



--7. Zadeklaruj kursor z parametrem dla region_id. Dla regionu Europe (ID=1)
--wypisz wszystkie kraje i ich liczbę pracowników wykorzystując podzapytanie
DECLARE
  v_region_id NUMBER;  --zmienna do przechowywania region_id

  CURSOR c_countries IS
    SELECT country_name, 
           (SELECT COUNT(*) 
            FROM employees 
            WHERE country_id = countries.country_id) AS employee_count
    FROM countries
    WHERE region_id = v_region_id;  

BEGIN
  SELECT region_id INTO v_region_id
  FROM regions WHERE region_name = 'Europe'; 

  FOR v_country IN c_countries LOOP
    DBMS_OUTPUT.PUT_LINE('Kraj: ' || v_country.country_name || 
                         ', Liczba pracowników: ' || v_country.employee_count);
  END LOOP;
END;



--8. Zadeklaruj kursor jako wynagrodzenie, nazwisko dla departamentu o numerze
--50. Dla elementów kursora wypisać na ekran, jeśli wynagrodzenie jest wyższe
--niż 3100: nazwisko osoby i tekst ‘nie dawać podwyżki’ w przeciwnym
--przypadku: nazwisko + ‘dać podwyżkę’
DECLARE
  CURSOR c_salary IS
    SELECT salary, last_name FROM employees WHERE department_id = 50; 

BEGIN
  FOR v_employee IN c_salary LOOP
    IF v_employee.salary > 3100 THEN
      DBMS_OUTPUT.PUT_LINE(v_employee.last_name || ' brak podwyżki');
    ELSE
      DBMS_OUTPUT.PUT_LINE(v_employee.last_name || ' podwyzka');
    END IF;
  END LOOP;
END;




--9. Zadeklarować kursor zwracający zarobki imię i nazwisko pracownika z
--parametrami, gdzie pierwsze dwa parametry określają widełki zarobków a
--trzeci część imienia pracownika. Wypisać na ekran pracowników:
--a. z widełkami 1000- 5000 z częścią imienia a (może być również A)
DECLARE
  v_min_salary NUMBER := 1000;
  v_max_salary NUMBER := 5000;
  v_name_part  VARCHAR2(20) := 'a';

  CURSOR emp_cursor (min_sal NUMBER, max_sal NUMBER, name_part VARCHAR2) IS
    SELECT first_name, last_name, salary
    FROM employees
    WHERE salary BETWEEN min_sal AND max_sal
      AND UPPER(first_name) LIKE '%' || UPPER(name_part) || '%';

  v_first_name employees.first_name%TYPE;
  v_last_name employees.last_name%TYPE;
  v_salary employees.salary%TYPE;

BEGIN
  OPEN emp_cursor(p_min_salary, v_max_salary, v_name_part);
  LOOP
    FETCH emp_cursor INTO v_first_name, v_last_name, v_salary;
    EXIT WHEN emp_cursor%NOTFOUND;
    DBMS_OUTPUT.PUT_LINE('Imię: ' || v_first_name || ', Nazwisko: ' || v_last_name || ', Zarobki: ' || v_salary);
  END LOOP;
  CLOSE emp_cursor;
END;
DECLARE
  p_min_salary NUMBER := 5000;
  v_max_salary NUMBER := 20000;
  v_name_part  VARCHAR2(20) := 'u';

  CURSOR emp_cursor (min_sal NUMBER, max_sal NUMBER, name_part VARCHAR2) IS
    SELECT first_name, last_name, salary
    FROM employees
    WHERE salary BETWEEN min_sal AND max_sal
      AND UPPER(first_name) LIKE '%' || UPPER(name_part) || '%';

  v_first_name employees.first_name%TYPE;
  v_last_name employees.last_name%TYPE;
  v_salary employees.salary%TYPE;

BEGIN
  OPEN emp_cursor(p_min_salary, v_max_salary, v_name_part);
  LOOP
    FETCH emp_cursor INTO v_first_name, v_last_name, v_salary;
    EXIT WHEN emp_cursor%NOTFOUND;
    DBMS_OUTPUT.PUT_LINE('Imię: ' || v_first_name || ', Nazwisko: ' || v_last_name || ', Zarobki: ' || v_salary);
  END LOOP;
  CLOSE emp_cursor;
END;



--10.Stwórz blok anonimowy, który dla każdego menedżera (manager_id) obliczy:
--a. liczbę podwładnych
--b. różnicę między najwyższą i najniższą pensją w zespole
--c. Wyniki zapisz do nowej tabeli STATYSTYKI_MENEDZEROW
CREATE TABLE STATYSTYKI_MENEDZEROW (
  MANAGER_ID         NUMBER(6),
  LICZBA_PRACOWNIKOW NUMBER,
  ROZNICA_PENSJI     NUMBER(8,2)
);

DECLARE
  CURSOR manager_cursor IS
    SELECT manager_id
    FROM employees
    WHERE manager_id IS NOT NULL
    GROUP BY manager_id;

  v_manager_id         employees.manager_id%TYPE;
  v_subordinate_count  NUMBER;
  v_max_salary         NUMBER(8,2);
  v_min_salary         NUMBER(8,2);
  v_salary_difference  NUMBER(8,2);

BEGIN
  FOR manager_record IN manager_cursor LOOP
    v_manager_id := manager_record.manager_id;

    SELECT COUNT(*)
    INTO v_subordinate_count
    FROM employees
    WHERE manager_id = v_manager_id;

    SELECT MAX(salary), MIN(salary)
    INTO v_max_salary, v_min_salary
    FROM employees
    WHERE manager_id = v_manager_id;

    v_salary_difference := v_max_salary - v_min_salary;

    INSERT INTO STATYSTYKI_MENEDZEROW (
      MANAGER_ID, LICZBA_PRACOWNIKOW, ROZNICA_PENSJI
    ) VALUES (
      v_manager_id, v_subordinate_count, v_salary_difference
    );
  END LOOP;

  COMMIT;
END;
/