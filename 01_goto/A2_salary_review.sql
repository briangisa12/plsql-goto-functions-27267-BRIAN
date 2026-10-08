-- =============================================================
-- A2 - Salary Review (using GOTO)
-- Reviews every employee and proposes a new monthly salary:
--   salary missing (NULL)      -> skipped, flagged
--   salary <= 0                -> skipped, flagged as invalid
--   salary >= 2,000,000        -> no raise
--   salary <   100,000         -> 15% raise
--   salary <   500,000         -> 10% raise
--   otherwise                  ->  5% raise
-- The table is NOT updated; the review only reports proposals.
-- =============================================================
SET SERVEROUTPUT ON;

DECLARE
  v_rate        NUMBER;
  v_new_salary  NUMBER;
  v_raised      PLS_INTEGER := 0;
  v_unchanged   PLS_INTEGER := 0;
  v_flagged     PLS_INTEGER := 0;
BEGIN
  DBMS_OUTPUT.PUT_LINE('=== A2: Salary Review (with GOTO) ===');

  FOR emp IN (SELECT emp_id,
                     first_name || ' ' || last_name AS full_name,
                     salary
                FROM employees
               ORDER BY emp_id)
  LOOP
    IF emp.salary IS NULL THEN
      GOTO lbl_missing;
    END IF;

    IF emp.salary <= 0 THEN
      GOTO lbl_invalid;
    END IF;

    IF emp.salary >= 2000000 THEN
      GOTO lbl_no_raise;
    END IF;

    -- Normal case: calculate the raise
    IF emp.salary < 100000 THEN
      v_rate := 0.15;
    ELSIF emp.salary < 500000 THEN
      v_rate := 0.10;
    ELSE
      v_rate := 0.05;
    END IF;

    v_new_salary := ROUND(emp.salary * (1 + v_rate));
    DBMS_OUTPUT.PUT_LINE(emp.emp_id || ' ' || RPAD(emp.full_name, 22)
                         || TO_CHAR(emp.salary, 'FM999,999,990') || ' -> '
                         || TO_CHAR(v_new_salary, 'FM999,999,990')
                         || '  (+' || (v_rate * 100) || '%)');
    v_raised := v_raised + 1;
    GOTO lbl_next;

    <<lbl_no_raise>>
    DBMS_OUTPUT.PUT_LINE(emp.emp_id || ' ' || RPAD(emp.full_name, 22)
                         || TO_CHAR(emp.salary, 'FM999,999,990')
                         || '  no raise (already at the top band)');
    v_unchanged := v_unchanged + 1;
    GOTO lbl_next;

    <<lbl_missing>>
    DBMS_OUTPUT.PUT_LINE(emp.emp_id || ' ' || RPAD(emp.full_name, 22)
                         || 'SKIPPED: salary is missing');
    v_flagged := v_flagged + 1;
    GOTO lbl_next;

    <<lbl_invalid>>
    DBMS_OUTPUT.PUT_LINE(emp.emp_id || ' ' || RPAD(emp.full_name, 22)
                         || 'SKIPPED: invalid salary ' || emp.salary);
    v_flagged := v_flagged + 1;

    <<lbl_next>>
    NULL;
  END LOOP;

  DBMS_OUTPUT.PUT_LINE('-------------------------------------------');
  DBMS_OUTPUT.PUT_LINE('Raised: ' || v_raised || ' | No raise: ' || v_unchanged
                       || ' | Flagged: ' || v_flagged);
END;
/
