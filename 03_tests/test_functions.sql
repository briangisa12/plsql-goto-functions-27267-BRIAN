-- =============================================================
-- test_functions.sql
-- Unit tests for B1 - B4. Each test prints PASS or FAIL.
-- Covers normal values, NULLs, missing rows and errors.
-- =============================================================
SET SERVEROUTPUT ON;

DECLARE
  v_pass PLS_INTEGER := 0;
  v_fail PLS_INTEGER := 0;

  PROCEDURE check_num (p_name VARCHAR2, p_actual NUMBER, p_expected NUMBER) IS
  BEGIN
    IF (p_actual = p_expected) OR (p_actual IS NULL AND p_expected IS NULL) THEN
      DBMS_OUTPUT.PUT_LINE('PASS  ' || p_name || ' = ' || NVL(TO_CHAR(p_actual), 'NULL'));
      v_pass := v_pass + 1;
    ELSE
      DBMS_OUTPUT.PUT_LINE('FAIL  ' || p_name || ': expected ' || NVL(TO_CHAR(p_expected), 'NULL')
                           || ', got ' || NVL(TO_CHAR(p_actual), 'NULL'));
      v_fail := v_fail + 1;
    END IF;
  END;

  PROCEDURE check_str (p_name VARCHAR2, p_actual VARCHAR2, p_expected VARCHAR2) IS
  BEGIN
    IF p_actual = p_expected THEN
      DBMS_OUTPUT.PUT_LINE('PASS  ' || p_name || ' = ' || p_actual);
      v_pass := v_pass + 1;
    ELSE
      DBMS_OUTPUT.PUT_LINE('FAIL  ' || p_name || ': expected ' || p_expected || ', got ' || p_actual);
      v_fail := v_fail + 1;
    END IF;
  END;
BEGIN
  DBMS_OUTPUT.PUT_LINE('=== B1 fn_annual_salary ===');
  check_num('annual salary of 101 (450,000 x 12)', fn_annual_salary(101), 5400000);
  check_num('annual salary of 106 (NULL salary)',  fn_annual_salary(106), NULL);
  check_num('annual salary of 999 (no employee)',  fn_annual_salary(999), NULL);

  DBMS_OUTPUT.PUT_LINE('=== B2 fn_years_of_service ===');
  check_num('years of 104 (hired 2010-09-20)',
            fn_years_of_service(104),
            TRUNC(MONTHS_BETWEEN(TRUNC(SYSDATE), DATE '2010-09-20') / 12));
  check_num('years of 109 (future hire date)',     fn_years_of_service(109), 0);
  check_num('years of 999 (no employee)',          fn_years_of_service(999), NULL);

  DBMS_OUTPUT.PUT_LINE('=== B3 fn_calculate_tax ===');
  check_num('tax on 50,000 (0% band)',          fn_calculate_tax(50000),   0);
  check_num('tax on 85,000 (10% band)',         fn_calculate_tax(85000),   2500);
  check_num('tax on 150,000 (20% band)',        fn_calculate_tax(150000),  14000);
  check_num('tax on 450,000 (30% band)',        fn_calculate_tax(450000),  99000);
  check_num('tax on 2,500,000 (30% band)',      fn_calculate_tax(2500000), 714000);
  check_num('tax on NULL',                      fn_calculate_tax(NULL),    NULL);

  BEGIN
    v_fail := v_fail + 1;   -- counted as a failure unless the error below is raised
    DBMS_OUTPUT.PUT_LINE('FAIL  tax on -1 should raise ORA-20010, got ' || fn_calculate_tax(-1));
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLCODE = -20010 THEN
        v_fail := v_fail - 1;
        v_pass := v_pass + 1;
        DBMS_OUTPUT.PUT_LINE('PASS  tax on -1 raised: ' || SQLERRM);
      ELSE
        DBMS_OUTPUT.PUT_LINE('FAIL  tax on -1 raised the wrong error: ' || SQLERRM);
      END IF;
  END;

  DBMS_OUTPUT.PUT_LINE('=== B4 fn_dept_name ===');
  check_str('dept 10',               fn_dept_name(10),   'Information Technology');
  check_str('dept 30',               fn_dept_name(30),   'Human Resources');
  check_str('dept NULL',             fn_dept_name(NULL), 'No Department');
  check_str('dept 99 (not existing)', fn_dept_name(99),  'Unknown Department');

  DBMS_OUTPUT.PUT_LINE('-------------------------------------------');
  DBMS_OUTPUT.PUT_LINE('TOTAL: ' || v_pass || ' passed, ' || v_fail || ' failed');
END;
/
