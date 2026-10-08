-- =============================================================
-- A3 - Illegal GOTO and Fix
-- Run with F5. Blocks 1 and 3 FAIL TO COMPILE on purpose
-- (PLS-00375: illegal GOTO statement); blocks 2 and 4 are fixes.
--
-- Rules shown here: a GOTO can NOT jump
--   * INTO an IF statement, LOOP or sub-block
--   * from an exception handler back into the block
-- A GOTO CAN jump out of an IF/LOOP to a label in an enclosing
-- sequence of statements.
-- =============================================================
SET SERVEROUTPUT ON;

-- -------------------------------------------------------------
-- 1) ILLEGAL: GOTO jumps INTO an IF statement
-- -------------------------------------------------------------
DECLARE
  v_score NUMBER := 75;
BEGIN
  GOTO lbl_pass;                 -- illegal: target is inside the IF
  IF v_score >= 50 THEN
    <<lbl_pass>>
    DBMS_OUTPUT.PUT_LINE('Score ' || v_score || ': PASSED');
  END IF;
END;
/

-- -------------------------------------------------------------
-- 2) FIX: the GOTO is inside the IF and jumps OUT to a label in
--    the same sequence as the IF (the outer block)
-- -------------------------------------------------------------
DECLARE
  v_score NUMBER := 75;
BEGIN
  DBMS_OUTPUT.PUT_LINE('=== A3 Fix 1: GOTO out of IF ===');
  IF v_score >= 50 THEN
    GOTO lbl_pass;
  END IF;

  DBMS_OUTPUT.PUT_LINE('Score ' || v_score || ': FAILED');
  GOTO lbl_end;

  <<lbl_pass>>
  DBMS_OUTPUT.PUT_LINE('Score ' || v_score || ': PASSED');

  <<lbl_end>>
  NULL;
END;
/

-- -------------------------------------------------------------
-- 3) ILLEGAL: GOTO from an exception handler back into the block
-- -------------------------------------------------------------
DECLARE
  v_divisor NUMBER := 0;
  v_result  NUMBER;
BEGIN
  <<lbl_retry>>
  v_result := 100 / v_divisor;
  DBMS_OUTPUT.PUT_LINE('Result: ' || v_result);
EXCEPTION
  WHEN ZERO_DIVIDE THEN
    v_divisor := 4;
    GOTO lbl_retry;              -- illegal: cannot re-enter the block
END;
/

-- -------------------------------------------------------------
-- 4) FIX: put the risky statement in a nested block inside a
--    loop. The handler deals with the error, and the loop retries.
-- -------------------------------------------------------------
DECLARE
  v_divisor NUMBER := 0;
  v_result  NUMBER;
  v_done    BOOLEAN := FALSE;
BEGIN
  DBMS_OUTPUT.PUT_LINE('=== A3 Fix 2: retry with a loop + nested block ===');
  WHILE NOT v_done LOOP
    BEGIN
      v_result := 100 / v_divisor;
      DBMS_OUTPUT.PUT_LINE('Result: 100 / ' || v_divisor || ' = ' || v_result);
      v_done := TRUE;
    EXCEPTION
      WHEN ZERO_DIVIDE THEN
        DBMS_OUTPUT.PUT_LINE('Division by zero caught - retrying with divisor 4');
        v_divisor := 4;
    END;
  END LOOP;
END;
/
