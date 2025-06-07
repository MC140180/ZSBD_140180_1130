--Stwórz funkcje: 
--1. Zwracającą nazwę pracy dla podanego parametru id, dodaj wyjątek, jeśli taka praca 
--nie istnieje 

CREATE OR REPLACE FUNCTION get_job_name(p_job_id IN VARCHAR2)
RETURN VARCHAR2 IS
    v_job_name jobs.job_title%TYPE;
BEGIN
    SELECT job_title INTO v_job_name
    FROM jobs
    WHERE job_id = p_job_id;

    RETURN v_job_name;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20001, 'Brak pracy o podanym ID: ' || p_job_id);
END;


--2. Zwracającą roczne zarobki (wynagrodzenie 12-to miesięczne plus premia jako 
--wynagrodzenie * commission_pct) dla pracownika o podanym id 

CREATE OR REPLACE FUNCTION get_annual_salary(p_employee_id IN NUMBER)
RETURN NUMBER IS
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
END;

/
--3. Biorąc w nawias numer kierunkowy z numeru telefonu podanego jako varchar 

CREATE OR REPLACE FUNCTION extract_country_code(p_phone IN VARCHAR2)
RETURN VARCHAR2 IS
    v_code VARCHAR2(20);
BEGIN
    SELECT REGEXP_SUBSTR(p_phone, '\+?\d+', 1, 1) INTO v_code FROM dual;
    RETURN v_code;
END;

--4. Dla podanego w parametrze ciągu znaków zmieniającą pierwszą i ostatnią literę na 
--wielką – pozostałe na małe 

CREATE OR REPLACE FUNCTION capitalize_ends(p_text IN VARCHAR2)
RETURN VARCHAR2 IS
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
END;


--5. Dla podanego peselu - przerabiającą pesel na datę urodzenia w formacie 
--‘yyyy-mm-dd’ 


CREATE OR REPLACE FUNCTION pesel_to_date(p_pesel IN VARCHAR2)
RETURN DATE IS
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

    v_date := TO_DATE(v_century + v_year || LPAD(v_month,2,'0') || LPAD(v_day,2,'0'), 'YYYYMMDD');
    RETURN v_date;
END;


--6. Zwracającą liczbę pracowników oraz liczbę departamentów które znajdują się w kraju 
--podanym jako parametr (nazwa kraju). W przypadku braku kraju - odpowiedni 
--wyjątek
CREATE OR REPLACE FUNCTION country_summary(p_country_name IN VARCHAR2,
                                           p_employee_count OUT NUMBER,
                                           p_department_count OUT NUMBER) RETURN NUMBER IS
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
END;

