-- =============================================================
-- C1 - fn_validate_payroll  (Combined task: GOTO + functions +
--                            exception handling)
-- Checks whether an employee's payroll data is valid.
-- Returns 'VALID' or 'INVALID - <reason>'.
-- The first failed check jumps with GOTO to <<lbl_invalid>>, so
-- there is one single exit point for every invalid case.
-- Uses fn_dept_name (B4) to check the department exists.
-- =============================================================
CREATE OR REPLACE FUNCTION fn_validate_payroll (
  p_emp_id IN employees.emp_id%TYPE
) RETURN VARCHAR2
IS
  c_max_salary CONSTANT NUMBER := 10000000;   -- 10,000,000 RWF per month
  v_emp        employees%ROWTYPE;
  v_reason     VARCHAR2(200);
BEGIN
  SELECT *
    INTO v_emp
    FROM employees
   WHERE emp_id = p_emp_id;

  IF v_emp.salary IS NULL THEN
    v_reason := 'salary is missing';
    GOTO lbl_invalid;
  END IF;

  IF v_emp.salary <= 0 THEN
    v_reason := 'salary must be greater than zero (' || v_emp.salary || ')';
    GOTO lbl_invalid;
  END IF;

  IF v_emp.salary > c_max_salary THEN
    v_reason := 'salary ' || TO_CHAR(v_emp.salary, 'FM999,999,990')
                || ' is above the maximum of ' || TO_CHAR(c_max_salary, 'FM999,999,990');
    GOTO lbl_invalid;
  END IF;

  IF v_emp.dept_id IS NULL THEN
    v_reason := 'employee is not assigned to a department';
    GOTO lbl_invalid;
  END IF;

  IF fn_dept_name(v_emp.dept_id) = 'Unknown Department' THEN
    v_reason := 'department ' || v_emp.dept_id || ' does not exist';
    GOTO lbl_invalid;
  END IF;

  IF v_emp.hire_date IS NULL OR v_emp.hire_date > TRUNC(SYSDATE) THEN
    v_reason := 'hire date is missing or in the future';
    GOTO lbl_invalid;
  END IF;

  RETURN 'VALID';

  <<lbl_invalid>>
  RETURN 'INVALID - ' || v_reason;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN 'INVALID - employee ' || p_emp_id || ' does not exist';
  WHEN OTHERS THEN
    RETURN 'ERROR - ' || SQLERRM;
END fn_validate_payroll;
/

SHOW ERRORS FUNCTION fn_validate_payroll;
