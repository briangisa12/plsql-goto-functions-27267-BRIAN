-- =============================================================
-- A1 - Number Classifier (using GOTO)
-- Classifies each number as NEGATIVE / ZERO / POSITIVE and as
-- EVEN / ODD. GOTO jumps to the label that handles each case,
-- and every case jumps to <<lbl_next>> to continue the loop.
-- =============================================================
SET SERVEROUTPUT ON;

DECLARE
  TYPE t_numbers IS TABLE OF NUMBER;
  v_numbers t_numbers := t_numbers(-15, -4, 0, 7, 12, NULL);
  v_num     NUMBER;
  v_parity  VARCHAR2(4);
BEGIN
  DBMS_OUTPUT.PUT_LINE('=== A1: Number Classifier (with GOTO) ===');

  FOR i IN 1 .. v_numbers.COUNT LOOP
    v_num := v_numbers(i);

    IF v_num IS NULL THEN
      GOTO lbl_null;
    END IF;

    IF MOD(v_num, 2) = 0 THEN
      v_parity := 'EVEN';
    ELSE
      v_parity := 'ODD';
    END IF;

    IF v_num < 0 THEN
      GOTO lbl_negative;
    ELSIF v_num = 0 THEN
      GOTO lbl_zero;
    END IF;
    GOTO lbl_positive;

    <<lbl_negative>>
    DBMS_OUTPUT.PUT_LINE(RPAD(TO_CHAR(v_num), 6) || ' -> NEGATIVE and ' || v_parity);
    GOTO lbl_next;

    <<lbl_zero>>
    DBMS_OUTPUT.PUT_LINE(RPAD(TO_CHAR(v_num), 6) || ' -> ZERO (neither positive nor negative)');
    GOTO lbl_next;

    <<lbl_positive>>
    DBMS_OUTPUT.PUT_LINE(RPAD(TO_CHAR(v_num), 6) || ' -> POSITIVE and ' || v_parity);
    GOTO lbl_next;

    <<lbl_null>>
    DBMS_OUTPUT.PUT_LINE(RPAD('NULL', 6) || ' -> cannot classify a missing value');

    <<lbl_next>>
    NULL;   -- a label must be followed by an executable statement
  END LOOP;
END;
/
