--1. Stwórz ranking pracowników oparty na wysokości pensji. Jeśli dwie osoby mają tę samą
--pensję, powinny otrzymać ten sam numer.
SELECT employee_id, first_name, last_name, salary,  
       DENSE_RANK() OVER (ORDER BY salary DESC) AS salary_rank  
FROM employees;

--2. Dodaj kolumnę, która pokazuje całkowitą sumę pensji wszystkich pracowników, ale bez
--grupowania ich.
SELECT employee_id, first_name, last_name, salary,  
       DENSE_RANK() OVER (ORDER BY salary DESC) AS salary_rank,  
       SUM(salary) OVER () AS total_salary  
FROM employees;



--3. Dla każdego pracownika wypisz: nazwisko, nazwę produktu, skumulowaną wartość
--sprzedaży dla pracownika, ranking wartości sprzedaży względem wszystkich
--zamówień.
SELECT 
    e.last_name AS employee, 
    p.product_name AS product, 
    SUM(s.quantity * s.price) AS total_sales, 
    RANK() OVER (ORDER BY SUM(s.quantity * s.price) DESC) AS "ranking"
FROM employees e
JOIN sales s ON e.employee_id = s.employee_id
JOIN cproducts p ON s.product_id = p.product_id
GROUP BY e.last_name, p.product_name
ORDER BY total_sales DESC;



--4. Dla każdego wiersza z tabeli sales wypisać nazwisko pracownika, nazwę produktu, cenę
--produktu, liczbę transakcji dla danego produktu tego dnia, sumę zapłaconą danego dnia
--za produkt, poprzednią cenę oraz kolejną cenę danego produktu.
SELECT 
    e.last_name AS employee, 
    p.product_name AS product, 
    s.price AS price, 
    COUNT(s.sale_id) AS transaction_count, 
    SUM(s.quantity * s.price) AS total_paid,  -- suma zapłacona za produkt
    LAG(s.price) OVER (PARTITION BY s.product_id ORDER BY s.sale_date) AS previous_price,  -- poprzednia cena
    LEAD(s.price) OVER (PARTITION BY s.product_id ORDER BY s.sale_date) AS next_price  -- kolejna cena
FROM 
    sales s
JOIN 
    employees e ON s.employee_id = e.employee_id
JOIN 
    cproducts p ON s.product_id = p.product_id
GROUP BY 
    e.last_name, p.product_name, s.price, s.sale_date, s.product_id  -- korzystamy z s.price
ORDER BY 
    s.sale_date, e.last_name, p.product_name;



--5. Dla każdego wiersza wypisać nazwę produktu, cenę produktu, sumę całkowitą
--zapłaconą w danym miesiącu oraz sumę rosnącą zapłaconą w danym miesiącu za
--konkretny produkt
SELECT 
    p.product_name, 
    s.price, 
    TO_CHAR(s.sale_date, 'YYYY-MM') AS sale_month,
    SUM(s.quantity * s.price) AS total_paid_this_month,
    SUM(SUM(s.quantity * s.price)) OVER (PARTITION BY p.product_name ORDER BY TO_CHAR(s.sale_date, 'YYYY-MM')) 
    AS running_total
FROM 
    sales s
JOIN 
    cproducts p ON s.product_id = p.product_id
GROUP BY 
    p.product_name, s.price, TO_CHAR(s.sale_date, 'YYYY-MM')
ORDER BY 
    p.product_name, sale_month;



--6. Wypisać obok siebie cenę produktu z roku 2022 i roku 2023 z tego samego dnia oraz
--dodatkowo różnicę pomiędzy cenami tych produktów oraz dodatkowo nazwę produktu
--i jego kategorię
SELECT 
    p.product_name as product, 
    p.product_category as category,
    TO_CHAR(s1.sale_date, 'DD-MM') AS sale_day, 
    s1.price AS price_2022, 
    s2.price AS price_2023, 
    (s2.price - s1.price) AS price_diff
FROM 
    sales s1
JOIN 
    sales s2 
    ON s1.product_id = s2.product_id 
    AND TO_CHAR(s1.sale_date, 'MM-DD') = TO_CHAR(s2.sale_date, 'MM-DD') 
    AND TO_CHAR(s1.sale_date, 'YYYY') = '2022' 
    AND TO_CHAR(s2.sale_date, 'YYYY') = '2023'
JOIN 
    cproducts p ON s1.product_id = p.product_id
ORDER BY 
    p.product_name, sale_day;



--7. Dla każdego wiersza wypisać nazwę kategorii produktu, nazwę produktu, jego cenę,
--minimalną cenę w danej kategorii, maksymalną cenę w danej kategorii, różnicę między
--maksymalną a minimalną ceną.
SELECT 
    p.product_name as product, 
    p.product_category as category, 
    s.price, 
    MIN(s.price) OVER (PARTITION BY p.product_category) AS min_price_in_category,
    MAX(s.price) OVER (PARTITION BY p.product_category) AS max_price_in_category,
    (MAX(s.price) OVER (PARTITION BY p.product_category) - MIN(s.price) OVER (PARTITION BY p.product_category)) 
    AS price_difference
FROM 
    sales s
JOIN 
    cproducts p ON s.product_id = p.product_id
ORDER BY 
    p.product_category, p.product_name, s.price;



--8. Dla każdego wiersza wypisz nazwę produktu i średnią kroczącą ceny (biorącą pod
--uwagę poprzednią, bieżącą i następną cenę) tego produktu według kolejnych dat
SELECT 
    p.product_name, 
    s.sale_date, 
    s.price, 
    AVG(s.price) OVER (
        PARTITION BY s.product_id 
        ORDER BY s.sale_date 
        ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING
    ) AS moving_avg_price
FROM 
    sales s
JOIN 
    cproducts p ON s.product_id = p.product_id
ORDER BY 
    p.product_name, s.sale_date;



--9. Dla każdego wiersza nazwę produktu, kategorię oraz ranking cen wewnątrz kategorii,
--ponumerowane wiersze wewnątrz kategorii w zależności od ceny oraz ranking gęsty
--(dense) cen wewnątrz kategorii
SELECT 
    p.product_name as product, 
    p.product_category as category, 
    s.price, 
    RANK() OVER (PARTITION BY p.product_category ORDER BY s.price DESC) AS price_rank,
    ROW_NUMBER() OVER (PARTITION BY p.product_category ORDER BY s.price DESC) AS row_number,
    DENSE_RANK() OVER (PARTITION BY p.product_category ORDER BY s.price DESC) AS dense_price_rank
FROM 
    sales s
JOIN 
    cproducts p ON s.product_id = p.product_id
ORDER BY 
    p.product_category, s.price DESC;




--10. Dla każdego wiersza tabeli sales nazwisko pracownika, nazwa produktu, wartość
--rosnąca jego sprzedaży według dat (cena produktu * ilość) dla danego pracownika oraz
--ranking wartości sprzedaży dla kolejnych wierszy globalnie według wartości
--zamówienia
SELECT 
    e.last_name AS employee, 
    p.product_name AS product, 
    (s.price * s.quantity) AS sales_value,
    SUM(s.price * s.quantity) OVER (
        PARTITION BY s.employee_id 
        ORDER BY s.sale_date
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS cumulative_sales_value,
    RANK() OVER (
        ORDER BY (s.price * s.quantity) DESC
    ) AS sales_value_rank
FROM 
    sales s
JOIN 
    employees e ON s.employee_id = e.employee_id
JOIN 
    cproducts p ON s.product_id = p.product_id
ORDER BY 
    e.last_name, sales_value_rank;



--11. Nie używając funkcji okienkowych wyświetl: Imiona i nazwiska pracowników oraz ich
--stanowisko, którzy uczestniczyli w sprzedaży
SELECT 
    e.first_name || ' ' || e.last_name AS employee_name, 
    e.job_id AS job_title
FROM 
    employees e
WHERE 
    e.employee_id IN (SELECT DISTINCT employee_id FROM sales)
ORDER BY 
    e.first_name, e.last_name;