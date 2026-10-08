-- =============================================================
-- A4 - Rewrite Without GOTO
-- Same logic and same output as A1, written with CASE / IF
-- instead of GOTO. Each case has one clear path, so labels and
-- jumps are no longer needed.
-- =============================================================
SET SERVEROUTPUT ON;

DECLARE
  TYPE t_numbers IS TABLE OF NUMBER;
  v_numbers t_numbers := t_numbers(-15, -4, 0, 7, 12, NULL);
  v_num     NUMBER;
  v_parity  VARCHAR2(4);
BEGIN
  DBMS_OUTPUT.PUT_LINE('=== A4: Number Classifier (without GOTO) ===');

  FOR i IN 1 .. v_numbers.COUNT LOOP
    v_num := v_numbers(i);

    IF v_num IS NULL THEN
      DBMS_OUTPUT.PUT_LINE(RPAD('NULL', 6) || ' -> cannot classify a missing value');
      CONTINUE;
    END IF;

    v_parity := CASE WHEN MOD(v_num, 2) = 0 THEN 'EVEN' ELSE 'ODD' END;

    CASE
      WHEN v_num < 0 THEN
        DBMS_OUTPUT.PUT_LINE(RPAD(TO_CHAR(v_num), 6) || ' -> NEGATIVE and ' || v_parity);
      WHEN v_num = 0 THEN
        DBMS_OUTPUT.PUT_LINE(RPAD(TO_CHAR(v_num), 6) || ' -> ZERO (neither positive nor negative)');
      ELSE
        DBMS_OUTPUT.PUT_LINE(RPAD(TO_CHAR(v_num), 6) || ' -> POSITIVE and ' || v_parity);
    END CASE;
  END LOOP;
END;
/
