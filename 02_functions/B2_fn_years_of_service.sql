-- =============================================================
-- B2 - fn_years_of_service
-- Returns the number of COMPLETE years an employee has worked,
-- counted from hire_date to today.
--   * employee not found or hire_date missing -> NULL
--   * hire_date in the future                 -> 0
-- =============================================================
CREATE OR REPLACE FUNCTION fn_years_of_service (
  p_emp_id IN employees.emp_id%TYPE
) RETURN NUMBER
IS
  v_hire_date employees.hire_date%TYPE;
BEGIN
  SELECT hire_date
    INTO v_hire_date
    FROM employees
   WHERE emp_id = p_emp_id;

  IF v_hire_date IS NULL THEN
    RETURN NULL;
  ELSIF v_hire_date > TRUNC(SYSDATE) THEN
    RETURN 0;
  END IF;

  RETURN TRUNC(MONTHS_BETWEEN(TRUNC(SYSDATE), v_hire_date) / 12);
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN NULL;
END fn_years_of_service;
/

SHOW ERRORS FUNCTION fn_years_of_service;
