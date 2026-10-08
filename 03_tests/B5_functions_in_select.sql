-- =============================================================
-- B5 - Functions in SQL
-- Uses the stored functions directly inside SQL statements:
-- in the SELECT list, in WHERE, and in GROUP BY.
-- Tip: in SQL Developer run each query with Ctrl+Enter to see it
-- in the Query Result grid, or the whole file with F5.
-- =============================================================

-- 1) Functions in the SELECT list: full payroll report
--    (tax is only calculated for non-negative salaries, because
--     fn_calculate_tax raises an error for negative values)
SELECT e.emp_id,
       e.first_name || ' ' || e.last_name                  AS employee,
       fn_dept_name(e.dept_id)                             AS department,
       e.salary                                            AS monthly_salary,
       fn_annual_salary(e.emp_id)                          AS annual_salary,
       fn_years_of_service(e.emp_id)                       AS years_service,
       CASE WHEN e.salary >= 0 THEN fn_calculate_tax(e.salary) END            AS monthly_tax,
       CASE WHEN e.salary >= 0 THEN e.salary - fn_calculate_tax(e.salary) END AS net_salary
  FROM employees e
 ORDER BY e.emp_id;

-- 2) Function in the WHERE clause: employees with 5+ years of service
SELECT e.emp_id,
       e.first_name || ' ' || e.last_name AS employee,
       e.hire_date,
       fn_years_of_service(e.emp_id)      AS years_service
  FROM employees e
 WHERE fn_years_of_service(e.emp_id) >= 5
 ORDER BY years_service DESC;

-- 3) Function in GROUP BY: annual payroll cost per department
SELECT fn_dept_name(e.dept_id)          AS department,
       COUNT(*)                          AS employees,
       SUM(fn_annual_salary(e.emp_id))   AS total_annual_salary
  FROM employees e
 GROUP BY fn_dept_name(e.dept_id)
 ORDER BY total_annual_salary DESC NULLS LAST;

-- 4) Function called on a literal value (no table needed)
SELECT fn_calculate_tax(450000) AS tax_on_450000,
       fn_dept_name(10)         AS dept_10
  FROM dual;
