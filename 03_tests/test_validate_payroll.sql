-- =============================================================
-- test_validate_payroll.sql
-- Tests C1 fn_validate_payroll against every employee plus an
-- employee id that does not exist. A test passes when the result
-- starts with the expected text (status + reason).
-- =============================================================
SET SERVEROUTPUT ON;

DECLARE
  TYPE t_case IS RECORD (emp_id NUMBER, expected VARCHAR2(100));
  TYPE t_cases IS TABLE OF t_case;
  v_cases  t_cases := t_cases();
  v_result VARCHAR2(400);
  v_pass   PLS_INTEGER := 0;
  v_fail   PLS_INTEGER := 0;

  PROCEDURE add_case (p_id NUMBER, p_expected VARCHAR2) IS
  BEGIN
    v_cases.EXTEND;
    v_cases(v_cases.LAST).emp_id   := p_id;
    v_cases(v_cases.LAST).expected := p_expected;
  END;
BEGIN
  add_case(101, 'VALID');
  add_case(102, 'VALID');
  add_case(103, 'VALID');
  add_case(104, 'VALID');
  add_case(105, 'VALID');
  add_case(106, 'INVALID - salary is missing');
  add_case(107, 'INVALID - employee is not assigned to a department');
  add_case(108, 'INVALID - salary must be greater than zero');
  add_case(109, 'INVALID - hire date is missing or in the future');
  add_case(110, 'INVALID - salary 12,000,000 is above the maximum');
  add_case(999, 'INVALID - employee 999 does not exist');

  DBMS_OUTPUT.PUT_LINE('=== C1: fn_validate_payroll ===');
  FOR i IN 1 .. v_cases.COUNT LOOP
    v_result := fn_validate_payroll(v_cases(i).emp_id);

    IF v_result LIKE v_cases(i).expected || '%' THEN
      v_pass := v_pass + 1;
      DBMS_OUTPUT.PUT_LINE('PASS  ' || v_cases(i).emp_id || ': ' || v_result);
    ELSE
      v_fail := v_fail + 1;
      DBMS_OUTPUT.PUT_LINE('FAIL  ' || v_cases(i).emp_id || ': expected '
                           || v_cases(i).expected || ', got ' || v_result);
    END IF;
  END LOOP;

  DBMS_OUTPUT.PUT_LINE('-------------------------------------------');
  DBMS_OUTPUT.PUT_LINE('TOTAL: ' || v_pass || ' passed, ' || v_fail || ' failed');
END;
/

-- Same validator used directly in SQL, together with the B-functions
SELECT e.emp_id,
       e.first_name || ' ' || e.last_name AS employee,
       fn_validate_payroll(e.emp_id)      AS payroll_status,
       CASE WHEN fn_validate_payroll(e.emp_id) = 'VALID'
            THEN e.salary - fn_calculate_tax(e.salary) END AS net_monthly_pay
  FROM employees e
 ORDER BY e.emp_id;
