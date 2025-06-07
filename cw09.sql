CREATE OR REPLACE PACKAGE zajecia_pkg IS
    FUNCTION capitalize_ends(p_text IN VARCHAR2) RETURN VARCHAR2;
    FUNCTION country_summary(
        p_country_name IN VARCHAR2,
        p_employee_count OUT NUMBER,
        p_department_count OUT NUMBER
    ) RETURN NUMBER;
    FUNCTION extract_country_code(p_phone IN VARCHAR2) RETURN VARCHAR2;
    FUNCTION generate_access_id(
        p_last_name IN VARCHAR2,
        p_phone IN VARCHAR2,
        p_first_name IN VARCHAR2
    ) RETURN VARCHAR2;
    FUNCTION get_annual_salary(p_employee_id IN NUMBER) RETURN NUMBER;    
    FUNCTION get_job_name(p_job_id IN VARCHAR2) RETURN VARCHAR2;
    FUNCTION pesel_to_date(p_pesel IN VARCHAR2) RETURN DATE;    
    
    PROCEDURE aktualizuj_wynagrodzenia(
        p_department_id IN EMPLOYEES.DEPARTMENT_ID%TYPE,
        p_procent_podwyzki IN NUMBER
    );
    PROCEDURE dodaj_job(
        p_job_id IN JOBS.JOB_ID%TYPE,
        p_job_title IN JOBS.JOB_TITLE%TYPE
    );    

    PROCEDURE dodaj_pracownika(
        p_first_name IN EMPLOYEES.FIRST_NAME%TYPE,
        p_last_name IN EMPLOYEES.LAST_NAME%TYPE,
        p_email IN EMPLOYEES.EMAIL%TYPE,
        p_phone_number IN EMPLOYEES.PHONE_NUMBER%TYPE,
        p_hire_date IN EMPLOYEES.HIRE_DATE%TYPE,
        p_job_id IN EMPLOYEES.JOB_ID%TYPE,
        p_salary IN EMPLOYEES.SALARY%TYPE
    );
    PROCEDURE modyfikuj_job_title(
        p_job_id IN JOBS.JOB_ID%TYPE,
        p_new_job_title IN JOBS.JOB_TITLE%TYPE
    );    
    PROCEDURE powitanie;
    PROCEDURE powitanie1(imie IN VARCHAR2); 
    PROCEDURE powitanie2(a IN NUMBER, b OUT NUMBER);
    PROCEDURE usun_job(p_job_id IN JOBS.JOB_ID%TYPE);    
END zajecia_pkg;
/

CREATE OR REPLACE PACKAGE BODY zajecia_pkg IS
    PROCEDURE usun_job(p_job_id IN JOBS.JOB_ID%TYPE) AS
    BEGIN
        -- Próbujemy usunąć rekord
        DELETE FROM JOBS
        WHERE JOB_ID = p_job_id;

        -- Sprawdzamy, ile wierszy zostało usuniętych
        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20002, 'No Jobs deleted');
        ELSE
            dbms_output.put_line('Usunięto JOB_ID: ' || p_job_id);
        END IF;

    EXCEPTION
        WHEN OTHERS THEN
            -- Wypisanie numeru błędu i komunikatu
            dbms_output.put_line('Wystąpił błąd: ' || SQLERRM);
    END usun_job;
    
    PROCEDURE powitanie2(a IN NUMBER, b OUT NUMBER) AS
    BEGIN   
        b := a * a;
    END powitanie2;
    
    PROCEDURE powitanie1(imie IN VARCHAR2) AS
    BEGIN   
        dbms_output.put_line('hello ' || imie || '!');
    END powitanie1;


    PROCEDURE powitanie AS
    BEGIN
        dbms_output.put_line('hello');
    END powitanie;

    PROCEDURE modyfikuj_job_title(
        p_job_id IN JOBS.JOB_ID%TYPE,
        p_new_job_title IN JOBS.JOB_TITLE%TYPE
    ) AS
    BEGIN
        -- Próbujemy zaktualizować rekord
        UPDATE JOBS
        SET JOB_TITLE = p_new_job_title
        WHERE JOB_ID = p_job_id;

        IF SQL%ROWCOUNT = 0 THEN
            -- Jeśli nie zaktualizowano żadnych wierszy, rzucamy wyjątek
            RAISE_APPLICATION_ERROR(-20001, 'No Jobs updated');
        ELSE
            dbms_output.put_line('Zaktualizowano JOB_ID: ' || p_job_id || ' na ' || p_new_job_title);
        END IF;

    EXCEPTION
        WHEN OTHERS THEN
            IF SQLCODE = -1403 THEN
                dbms_output.put_line('Nie ma takiego job_id');
            ELSE
                -- Wypisanie numeru błędu i komunikatu
                dbms_output.put_line('Wystąpił błąd: ' || SQLERRM);
            END IF;
    END modyfikuj_job_title;
    
    PROCEDURE dodaj_pracownika(
        p_first_name IN EMPLOYEES.FIRST_NAME%TYPE,
        p_last_name IN EMPLOYEES.LAST_NAME%TYPE,
        p_email IN EMPLOYEES.EMAIL%TYPE,
        p_phone_number IN EMPLOYEES.PHONE_NUMBER%TYPE,
        p_hire_date IN EMPLOYEES.HIRE_DATE%TYPE,
        p_job_id IN EMPLOYEES.JOB_ID%TYPE,
        p_salary IN EMPLOYEES.SALARY%TYPE
    ) AS
        v_employee_id EMPLOYEES.EMPLOYEE_ID%TYPE;
    BEGIN
        -- Sprawdzenie, czy wynagrodzenie nie jest wyższe niż 20000
        IF p_salary > 20000 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Wynagrodzenie nie może być wyższe niż 20000');
        END IF;

        -- Generowanie nowego ID pracownika za pomocą sekwencji
        SELECT EMPLOYEES_SEQ.NEXTVAL
        INTO v_employee_id
        FROM DUAL;

        -- Wstawienie nowego rekordu do tabeli EMPLOYEES
        INSERT INTO EMPLOYEES (
            EMPLOYEE_ID,
            FIRST_NAME,
            LAST_NAME,
            EMAIL,
            PHONE_NUMBER,
            HIRE_DATE,
            JOB_ID,
            SALARY
        ) VALUES (
            v_employee_id,  -- Wstawiamy wygenerowane ID
            p_first_name,
            p_last_name,
            p_email,
            p_phone_number,
            p_hire_date,
            p_job_id,
            p_salary
        );

        -- Komunikat o powodzeniu
        dbms_output.put_line('Dodano pracownika o ID: ' || v_employee_id);

    EXCEPTION
        WHEN OTHERS THEN
            -- Obsługuje wszystkie inne błędy
            dbms_output.put_line('Wystąpił błąd: ' || SQLERRM);

    END dodaj_pracownika;



    PROCEDURE dodaj_job(
        p_job_id IN JOBS.JOB_ID%TYPE,
        p_job_title IN JOBS.JOB_TITLE%TYPE
    ) AS
    BEGIN
        -- Wstawienie nowego rekordu do tabeli JOBS
        INSERT INTO JOBS (JOB_ID, JOB_TITLE)
        VALUES (p_job_id, p_job_title);

        dbms_output.put_line('Dodano nowy wpis: ' || p_job_id || ' - ' || p_job_title);

    EXCEPTION
        WHEN DUP_VAL_ON_INDEX THEN
            dbms_output.put_line('Błąd: Job_id już istnieje.');
        WHEN OTHERS THEN
            dbms_output.put_line('Nieoczekiwany błąd: ' || SQLERRM);
    END dodaj_job;

    PROCEDURE aktualizuj_wynagrodzenia(
        p_department_id IN EMPLOYEES.DEPARTMENT_ID%TYPE,
        p_procent_podwyzki IN NUMBER
    ) AS
        v_min_salary JOBS.MIN_SALARY%TYPE;
        v_max_salary JOBS.MAX_SALARY%TYPE;
        v_new_salary EMPLOYEES.SALARY%TYPE;
    BEGIN
        -- Sprawdzenie, czy departament istnieje i pobranie widełek płacowych
        SELECT MIN_SALARY, MAX_SALARY
        INTO v_min_salary, v_max_salary
        FROM JOBS
        WHERE JOB_ID = (
            SELECT JOB_ID
            FROM EMPLOYEES
            WHERE DEPARTMENT_ID = p_department_id AND ROWNUM = 1
        );

        -- Pętla aktualizująca wynagrodzenia pracowników
        FOR emp IN (
            SELECT EMPLOYEE_ID, SALARY, JOB_ID
            FROM EMPLOYEES
            WHERE DEPARTMENT_ID = p_department_id
        ) LOOP
            v_new_salary := emp.SALARY * (1 + p_procent_podwyzki / 100);

            IF v_new_salary < v_min_salary THEN
                v_new_salary := v_min_salary;
            ELSIF v_new_salary > v_max_salary THEN
                v_new_salary := v_max_salary;
            END IF;

            UPDATE EMPLOYEES
            SET SALARY = v_new_salary
            WHERE EMPLOYEE_ID = emp.EMPLOYEE_ID;
        END LOOP;

        dbms_output.put_line('Wynagrodzenia zostały zaktualizowane dla departamentu ' || p_department_id);

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            dbms_output.put_line('Nie ma takiego department_id: ' || p_department_id);
        WHEN OTHERS THEN
            dbms_output.put_line('Wystąpił błąd: ' || SQLERRM);
    END aktualizuj_wynagrodzenia;


    FUNCTION capitalize_ends(p_text IN VARCHAR2) RETURN VARCHAR2 IS
        v_first CHAR(1);
        v_last CHAR(1);
        v_middle VARCHAR2(4000);
        v_len PLS_INTEGER := LENGTH(p_text);
    BEGIN
        IF v_len = 0 THEN
            RETURN '';
        ELSIF v_len = 1 THEN
            RETURN UPPER(p_text);
        ELSE
            v_first := UPPER(SUBSTR(p_text, 1, 1));
            v_middle := LOWER(SUBSTR(p_text, 2, v_len - 2));
            v_last := UPPER(SUBSTR(p_text, v_len, 1));
            RETURN v_first || v_middle || v_last;
        END IF;
    END capitalize_ends;
    
    FUNCTION country_summary(
        p_country_name IN VARCHAR2,
        p_employee_count OUT NUMBER,
        p_department_count OUT NUMBER
    ) RETURN NUMBER IS
    BEGIN
        IF p_country_name IS NULL THEN
            RAISE_APPLICATION_ERROR(-20004, 'Nazwa kraju nie może być pusta.');
        END IF;

        SELECT COUNT(*)
        INTO p_employee_count
        FROM employees e
        JOIN departments d ON e.department_id = d.department_id
        JOIN locations l ON d.location_id = l.location_id
        JOIN countries c ON l.country_id = c.country_id
        WHERE c.country_name = p_country_name;

        SELECT COUNT(DISTINCT d.department_id)
        INTO p_department_count
        FROM departments d
        JOIN locations l ON d.location_id = l.location_id
        JOIN countries c ON l.country_id = c.country_id
        WHERE c.country_name = p_country_name;

        RETURN 1; -- sukces
    END country_summary;
    
    
    FUNCTION extract_country_code(p_phone IN VARCHAR2) RETURN VARCHAR2 IS
        v_code VARCHAR2(20);
    BEGIN
        SELECT REGEXP_SUBSTR(p_phone, '\+?\d+', 1, 1)
        INTO v_code
        FROM dual;
        RETURN v_code;
    END extract_country_code;

    FUNCTION generate_access_id(
        p_last_name IN VARCHAR2,
        p_phone IN VARCHAR2,
        p_first_name IN VARCHAR2
    ) RETURN VARCHAR2 IS
        v_last_name_part VARCHAR2(3);
        v_phone_part VARCHAR2(4);
        v_first_name_part VARCHAR2(1);
        v_access_id VARCHAR2(255);
    BEGIN
        -- Pierwsze 3 litery nazwiska
        v_last_name_part := UPPER(SUBSTR(p_last_name, 1, 3));

        -- Ostatnie 4 cyfry telefonu
        v_phone_part := SUBSTR(p_phone, -4);

        -- Inicjał imienia
        v_first_name_part := UPPER(SUBSTR(p_first_name, 1, 1));

        -- Generowanie identyfikatora
        v_access_id := v_last_name_part || v_phone_part || v_first_name_part;

        RETURN v_access_id;
    END generate_access_id;

    FUNCTION get_annual_salary(p_employee_id IN NUMBER) RETURN NUMBER IS
        v_salary employees.salary%TYPE;
        v_commission employees.commission_pct%TYPE := 0;
    BEGIN
        SELECT salary, NVL(commission_pct, 0)
        INTO v_salary, v_commission
        FROM employees
        WHERE employee_id = p_employee_id;

        RETURN (v_salary * 12) + (v_salary * v_commission);
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20002, 'Brak pracownika o ID: ' || p_employee_id);
    END get_annual_salary;


    FUNCTION get_job_name(p_job_id IN VARCHAR2) RETURN VARCHAR2 IS
        v_job_name jobs.job_title%TYPE;
    BEGIN
        SELECT job_title INTO v_job_name
        FROM jobs
        WHERE job_id = p_job_id;

        RETURN v_job_name;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20001, 'Brak pracy o podanym ID: ' || p_job_id);
    END get_job_name;

    FUNCTION pesel_to_date(p_pesel IN VARCHAR2) RETURN DATE IS
        v_year NUMBER;
        v_month NUMBER;
        v_day NUMBER;
        v_century NUMBER;
        v_date DATE;
    BEGIN
        v_year := TO_NUMBER(SUBSTR(p_pesel, 1, 2));
        v_month := TO_NUMBER(SUBSTR(p_pesel, 3, 2));
        v_day := TO_NUMBER(SUBSTR(p_pesel, 5, 2));

        IF v_month BETWEEN 1 AND 12 THEN
            v_century := 1900;
        ELSIF v_month BETWEEN 21 AND 32 THEN
            v_century := 2000;
            v_month := v_month - 20;
        ELSIF v_month BETWEEN 81 AND 92 THEN
            v_century := 1800;
            v_month := v_month - 80;
        ELSE
            RAISE_APPLICATION_ERROR(-20003, 'Nieprawidłowy miesiąc w PESEL: ' || v_month);
        END IF;

        v_date := TO_DATE(v_century + v_year || LPAD(v_month, 2, '0') || LPAD(v_day, 2, '0'), 'YYYYMMDD');
        RETURN v_date;
    END pesel_to_date;    

END zajecia_pkg;
/

CREATE OR REPLACE PACKAGE regions_pkg IS
    -- Procedury CRUD
    PROCEDURE add_region(p_region_id IN REGIONS.REGION_ID%TYPE, p_region_name IN REGIONS.REGION_NAME%TYPE);
    PROCEDURE update_region(p_region_id IN REGIONS.REGION_ID%TYPE, p_region_name IN REGIONS.REGION_NAME%TYPE);
    PROCEDURE delete_region(p_region_id IN REGIONS.REGION_ID%TYPE);

    -- Funkcje do odczytu
    FUNCTION get_region_by_id(p_region_id IN REGIONS.REGION_ID%TYPE) RETURN REGIONS%ROWTYPE;
    FUNCTION get_region_by_name(p_region_name IN REGIONS.REGION_NAME%TYPE) RETURN REGIONS%ROWTYPE;
    FUNCTION get_all_regions RETURN SYS_REFCURSOR;
END regions_pkg;
/

CREATE OR REPLACE PACKAGE BODY regions_pkg IS

    -- Procedura do dodawania nowego regionu
    PROCEDURE add_region(p_region_id IN REGIONS.REGION_ID%TYPE, p_region_name IN REGIONS.REGION_NAME%TYPE) AS
    BEGIN
        INSERT INTO REGIONS (REGION_ID, REGION_NAME)
        VALUES (p_region_id, p_region_name);
        COMMIT;
        dbms_output.put_line('Region dodany: ' || p_region_id || ' - ' || p_region_name);
    EXCEPTION
        WHEN OTHERS THEN
            dbms_output.put_line('Błąd przy dodawaniu regionu: ' || SQLERRM);
    END add_region;

    -- Procedura do aktualizowania nazwy regionu
    PROCEDURE update_region(p_region_id IN REGIONS.REGION_ID%TYPE, p_region_name IN REGIONS.REGION_NAME%TYPE) AS
    BEGIN
        UPDATE REGIONS
        SET REGION_NAME = p_region_name
        WHERE REGION_ID = p_region_id;

        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Region o ID ' || p_region_id || ' nie istnieje.');
        ELSE
            dbms_output.put_line('Region zaktualizowany: ' || p_region_id || ' - ' || p_region_name);
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            dbms_output.put_line('Błąd przy aktualizowaniu regionu: ' || SQLERRM);
    END update_region;

    -- Procedura do usuwania regionu
    PROCEDURE delete_region(p_region_id IN REGIONS.REGION_ID%TYPE) AS
    BEGIN
        DELETE FROM REGIONS
        WHERE REGION_ID = p_region_id;

        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20002, 'Region o ID ' || p_region_id || ' nie istnieje.');
        ELSE
            dbms_output.put_line('Region usunięty: ' || p_region_id);
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            dbms_output.put_line('Błąd przy usuwaniu regionu: ' || SQLERRM);
    END delete_region;

    -- Funkcja do pobierania regionu na podstawie ID
    FUNCTION get_region_by_id(p_region_id IN REGIONS.REGION_ID%TYPE) RETURN REGIONS%ROWTYPE AS
        v_region REGIONS%ROWTYPE;
    BEGIN
        SELECT * INTO v_region
        FROM REGIONS
        WHERE REGION_ID = p_region_id;

        RETURN v_region;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20003, 'Region o ID ' || p_region_id || ' nie istnieje.');
    END get_region_by_id;

    -- Funkcja do pobierania regionu na podstawie nazwy
    FUNCTION get_region_by_name(p_region_name IN REGIONS.REGION_NAME%TYPE) RETURN REGIONS%ROWTYPE AS
        v_region REGIONS%ROWTYPE;
    BEGIN
        SELECT * INTO v_region
        FROM REGIONS
        WHERE REGION_NAME = p_region_name;

        RETURN v_region;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20004, 'Region o nazwie ' || p_region_name || ' nie istnieje.');
    END get_region_by_name;

    -- Funkcja do pobierania wszystkich regionów
    FUNCTION get_all_regions RETURN SYS_REFCURSOR AS
        v_cursor SYS_REFCURSOR;
    BEGIN
        OPEN v_cursor FOR
            SELECT * FROM REGIONS;
        RETURN v_cursor;
    END get_all_regions;

END regions_pkg;
/



CREATE TABLE AUDIT_LOG (
    LOG_ID NUMBER PRIMARY KEY,
    ERROR_MESSAGE VARCHAR2(4000),
    ERROR_DATE DATE DEFAULT SYSDATE
);
/

CREATE OR REPLACE PACKAGE regions_pkg IS
    -- Niestandardowe wyjątki
    REGION_ALREADY_EXISTS EXCEPTION;
    REGION_HAS_COUNTRIES EXCEPTION;
    
    -- Procedury CRUD
    PROCEDURE add_region(p_region_id IN REGIONS.REGION_ID%TYPE, p_region_name IN REGIONS.REGION_NAME%TYPE);
    PROCEDURE update_region(p_region_id IN REGIONS.REGION_ID%TYPE, p_region_name IN REGIONS.REGION_NAME%TYPE);
    PROCEDURE delete_region(p_region_id IN REGIONS.REGION_ID%TYPE);

    -- Funkcje do odczytu
    FUNCTION get_region_by_id(p_region_id IN REGIONS.REGION_ID%TYPE) RETURN REGIONS%ROWTYPE;
    FUNCTION get_region_by_name(p_region_name IN REGIONS.REGION_NAME%TYPE) RETURN REGIONS%ROWTYPE;
    FUNCTION get_all_regions RETURN SYS_REFCURSOR;
    
    -- Procedura logująca błędy
    PROCEDURE log_error(p_error_message IN VARCHAR2);
END regions_pkg;
/


CREATE OR REPLACE PACKAGE BODY regions_pkg IS

    -- Procedura do dodawania nowego regionu
    PROCEDURE add_region(p_region_id IN REGIONS.REGION_ID%TYPE, p_region_name IN REGIONS.REGION_NAME%TYPE) AS
        dummy NUMBER;  -- Zmienna pomocnicza
    BEGIN
        -- Sprawdzamy, czy region o tej samej nazwie już istnieje
        BEGIN
            SELECT 1
            INTO   dummy
            FROM   REGIONS
            WHERE  REGION_NAME = p_region_name;
            RAISE REGION_ALREADY_EXISTS;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                NULL; -- region nie istnieje, kontynuujemy
        END;

        -- Dodajemy nowy region
        INSERT INTO REGIONS (REGION_ID, REGION_NAME)
        VALUES (p_region_id, p_region_name);

        COMMIT;
        dbms_output.put_line('Region dodany: ' || p_region_id || ' - ' || p_region_name);
    EXCEPTION
        WHEN REGION_ALREADY_EXISTS THEN
            dbms_output.put_line('Błąd: Region o nazwie ' || p_region_name || ' już istnieje.');
            log_error('Próba dodania regionu o istniejącej nazwie: ' || p_region_name);
        WHEN OTHERS THEN
            dbms_output.put_line('Błąd przy dodawaniu regionu: ' || SQLERRM);
            log_error('Błąd przy dodawaniu regionu: ' || SQLERRM);
    END add_region;

    -- Procedura do aktualizowania nazwy regionu
    PROCEDURE update_region(p_region_id IN REGIONS.REGION_ID%TYPE, p_region_name IN REGIONS.REGION_NAME%TYPE) AS
    BEGIN
        UPDATE REGIONS
        SET REGION_NAME = p_region_name
        WHERE REGION_ID = p_region_id;

        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Region o ID ' || p_region_id || ' nie istnieje.');
        ELSE
            dbms_output.put_line('Region zaktualizowany: ' || p_region_id || ' - ' || p_region_name);
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            dbms_output.put_line('Błąd przy aktualizowaniu regionu: ' || SQLERRM);
            log_error('Błąd przy aktualizowaniu regionu: ' || SQLERRM);
    END update_region;

    -- Procedura do usuwania regionu
    PROCEDURE delete_region(p_region_id IN REGIONS.REGION_ID%TYPE) AS
    BEGIN
        -- Sprawdzamy, czy region ma przypisane kraje
        DECLARE
            v_count NUMBER;
        BEGIN
            SELECT COUNT(*) INTO v_count
            FROM COUNTRIES
            WHERE REGION_ID = p_region_id;

            IF v_count > 0 THEN
                RAISE REGION_HAS_COUNTRIES;
            END IF;
        END;

        -- Usuwamy region
        DELETE FROM REGIONS
        WHERE REGION_ID = p_region_id;

        IF SQL%ROWCOUNT = 0 THEN
            RAISE_APPLICATION_ERROR(-20002, 'Region o ID ' || p_region_id || ' nie istnieje.');
        ELSE
            dbms_output.put_line('Region usunięty: ' || p_region_id);
        END IF;
    EXCEPTION
        WHEN REGION_HAS_COUNTRIES THEN
            dbms_output.put_line('Błąd: Region o ID ' || p_region_id || ' ma przypisane kraje i nie może być usunięty.');
            log_error('Próba usunięcia regionu z przypisanymi krajami: ' || p_region_id);
        WHEN OTHERS THEN
            dbms_output.put_line('Błąd przy usuwaniu regionu: ' || SQLERRM);
            log_error('Błąd przy usuwaniu regionu: ' || SQLERRM);
    END delete_region;

    -- Funkcja do pobierania regionu na podstawie ID
    FUNCTION get_region_by_id(p_region_id IN REGIONS.REGION_ID%TYPE) RETURN REGIONS%ROWTYPE AS
        v_region REGIONS%ROWTYPE;
    BEGIN
        SELECT * INTO v_region
        FROM REGIONS
        WHERE REGION_ID = p_region_id;

        RETURN v_region;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20003, 'Region o ID ' || p_region_id || ' nie istnieje.');
    END get_region_by_id;

    -- Funkcja do pobierania regionu na podstawie nazwy
    FUNCTION get_region_by_name(p_region_name IN REGIONS.REGION_NAME%TYPE) RETURN REGIONS%ROWTYPE AS
        v_region REGIONS%ROWTYPE;
    BEGIN
        SELECT * INTO v_region
        FROM REGIONS
        WHERE REGION_NAME = p_region_name;

        RETURN v_region;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20004, 'Region o nazwie ' || p_region_name || ' nie istnieje.');
    END get_region_by_name;

    -- Funkcja do pobierania wszystkich regionów
    FUNCTION get_all_regions RETURN SYS_REFCURSOR AS
        v_cursor SYS_REFCURSOR;
    BEGIN
        OPEN v_cursor FOR
            SELECT * FROM REGIONS;
        RETURN v_cursor;
    END get_all_regions;

    -- Procedura logująca błędy do tabeli audytowej
    PROCEDURE log_error(p_error_message IN VARCHAR2) AS
    BEGIN
        INSERT INTO AUDIT_LOG (ERROR_MESSAGE)
        VALUES (p_error_message);
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            dbms_output.put_line('Błąd przy logowaniu: ' || SQLERRM);
    END log_error;

END regions_pkg;
/


CREATE OR REPLACE PACKAGE dept_stats_pkg IS
    -- Funkcja do obliczania średniej pensji w departamencie
    FUNCTION get_average_salary(p_department_id IN EMPLOYEES.DEPARTMENT_ID%TYPE) RETURN NUMBER;

    -- Funkcja do obliczania minimalnej pensji w departamencie
    FUNCTION get_min_salary(p_department_id IN EMPLOYEES.DEPARTMENT_ID%TYPE) RETURN NUMBER;

    -- Funkcja do obliczania maksymalnej pensji w departamencie
    FUNCTION get_max_salary(p_department_id IN EMPLOYEES.DEPARTMENT_ID%TYPE) RETURN NUMBER;

    -- Procedura generująca raport
    PROCEDURE generate_report(p_department_id IN EMPLOYEES.DEPARTMENT_ID%TYPE);

END dept_stats_pkg;
/

CREATE OR REPLACE PACKAGE BODY dept_stats_pkg IS

    -- Funkcja do obliczania średniej pensji w departamencie
    FUNCTION get_average_salary(p_department_id IN EMPLOYEES.DEPARTMENT_ID%TYPE) RETURN NUMBER IS
        v_avg_salary NUMBER;
    BEGIN
        SELECT AVG(salary)
        INTO v_avg_salary
        FROM employees
        WHERE department_id = p_department_id;

        RETURN v_avg_salary;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN NULL;  -- Brak pracowników w departamencie
        WHEN OTHERS THEN
            RAISE;
    END get_average_salary;

    -- Funkcja do obliczania minimalnej pensji w departamencie
    FUNCTION get_min_salary(p_department_id IN EMPLOYEES.DEPARTMENT_ID%TYPE) RETURN NUMBER IS
        v_min_salary NUMBER;
    BEGIN
        SELECT MIN(salary)
        INTO v_min_salary
        FROM employees
        WHERE department_id = p_department_id;

        RETURN v_min_salary;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN NULL;  -- Brak pracowników w departamencie
        WHEN OTHERS THEN
            RAISE;
    END get_min_salary;

    -- Funkcja do obliczania maksymalnej pensji w departamencie
    FUNCTION get_max_salary(p_department_id IN EMPLOYEES.DEPARTMENT_ID%TYPE) RETURN NUMBER IS
        v_max_salary NUMBER;
    BEGIN
        SELECT MAX(salary)
        INTO v_max_salary
        FROM employees
        WHERE department_id = p_department_id;

        RETURN v_max_salary;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN NULL;  -- Brak pracowników w departamencie
        WHEN OTHERS THEN
            RAISE;
    END get_max_salary;

    -- Procedura generująca raport
    PROCEDURE generate_report(p_department_id IN EMPLOYEES.DEPARTMENT_ID%TYPE) IS
        v_avg_salary NUMBER;
        v_min_salary NUMBER;
        v_max_salary NUMBER;
        v_report VARCHAR2(4000);
    BEGIN
        -- Pobieranie danych statystycznych
        v_avg_salary := get_average_salary(p_department_id);
        v_min_salary := get_min_salary(p_department_id);
        v_max_salary := get_max_salary(p_department_id);

        -- Generowanie raportu
        v_report := 'Raport dla departamentu o ID ' || p_department_id || CHR(10);
        v_report := v_report || 'Średnia pensja: ' || NVL(v_avg_salary, 0) || CHR(10);
        v_report := v_report || 'Minimalna pensja: ' || NVL(v_min_salary, 0) || CHR(10);
        v_report := v_report || 'Maksymalna pensja: ' || NVL(v_max_salary, 0) || CHR(10);

        -- Wyświetlenie raportu
        dbms_output.put_line(v_report);

    EXCEPTION
        WHEN OTHERS THEN
            dbms_output.put_line('Błąd podczas generowania raportu: ' || SQLERRM);
    END generate_report;

END dept_stats_pkg;
/


CREATE OR REPLACE PACKAGE data_validation_pkg IS
    -- Funkcja do korekty formatu numeru telefonu
    FUNCTION correct_phone_format(p_phone IN VARCHAR2) RETURN VARCHAR2;

    -- Procedura do masowej aktualizacji pensji dla stanowisk
    PROCEDURE update_salaries_by_job(p_job_id IN EMPLOYEES.JOB_ID%TYPE, p_percentage IN NUMBER);
    
END data_validation_pkg;
/

CREATE OR REPLACE PACKAGE BODY data_validation_pkg IS

    -- Funkcja do korekty formatu numeru telefonu
    FUNCTION correct_phone_format(p_phone IN VARCHAR2) RETURN VARCHAR2 IS
        v_corrected_phone VARCHAR2(20);
    BEGIN
        -- Usuwamy wszystkie znaki, które nie są cyframi
        v_corrected_phone := REGEXP_REPLACE(p_phone, '[^0-9]', '');

        -- Sprawdzamy, czy numer telefonu ma odpowiednią długość (np. 9 cyfr)
        IF LENGTH(v_corrected_phone) = 9 THEN
            RETURN v_corrected_phone;
        ELSE
            RAISE_APPLICATION_ERROR(-20001, 'Nieprawidłowy numer telefonu: ' || p_phone);
        END IF;
    EXCEPTION
        WHEN OTHERS THEN
            RAISE;
    END correct_phone_format;

    -- Procedura do masowej aktualizacji pensji dla stanowisk
    PROCEDURE update_salaries_by_job(p_job_id IN EMPLOYEES.JOB_ID%TYPE, p_percentage IN NUMBER) IS
        v_new_salary EMPLOYEES.SALARY%TYPE;
    BEGIN
        -- Aktualizujemy pensje wszystkich pracowników w danym stanowisku
        FOR emp IN (SELECT EMPLOYEE_ID, SALARY FROM EMPLOYEES WHERE JOB_ID = p_job_id) LOOP
            -- Obliczamy nową pensję
            v_new_salary := emp.SALARY * (1 + p_percentage / 100);

            -- Aktualizujemy pensję pracownika
            UPDATE EMPLOYEES
            SET SALARY = v_new_salary
            WHERE EMPLOYEE_ID = emp.EMPLOYEE_ID;
        END LOOP;

        -- Komunikat o powodzeniu
        dbms_output.put_line('Wynagrodzenia zostały zaktualizowane dla stanowiska ' || p_job_id);
    EXCEPTION
        WHEN OTHERS THEN
            dbms_output.put_line('Wystąpił błąd podczas aktualizacji pensji: ' || SQLERRM);
    END update_salaries_by_job;

END data_validation_pkg;
/

