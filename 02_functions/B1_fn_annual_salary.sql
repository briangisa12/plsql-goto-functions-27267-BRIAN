-- =============================================================
-- B1 - fn_annual_salary
-- Returns an employee's annual salary (monthly salary x 12).
-- Returns NULL if the employee does not exist or has no salary.
-- =============================================================
CREATE OR REPLACE FUNCTION fn_annual_salary (
  p_emp_id IN employees.emp_id%TYPE
) RETURN NUMBER
IS
  v_salary employees.salary%TYPE;
BEGIN
  SELECT salary
    INTO v_salary
    FROM employees
   WHERE emp_id = p_emp_id;

  IF v_salary IS NULL THEN
    RETURN NULL;
  END IF;

  RETURN v_salary * 12;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN NULL;   -- employee does not exist
END fn_annual_salary;
/

SHOW ERRORS FUNCTION fn_annual_salary;
