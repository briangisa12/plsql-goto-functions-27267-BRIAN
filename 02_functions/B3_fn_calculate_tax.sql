-- =============================================================
-- B3 - fn_calculate_tax
-- Calculates monthly PAYE income tax with progressive brackets
-- (Rwanda PAYE bands, monthly, RWF):
--         0 –  60,000   ->  0%
--    60,001 – 100,000   -> 10%
--   100,001 – 200,000   -> 20%
--    above    200,000   -> 30%
-- Each rate applies only to the part of the salary inside its band.
--   * NULL salary     -> NULL
--   * negative salary -> raises ORA-20010
-- =============================================================
CREATE OR REPLACE FUNCTION fn_calculate_tax (
  p_monthly_salary IN NUMBER
) RETURN NUMBER
IS
  v_tax NUMBER := 0;
BEGIN
  IF p_monthly_salary IS NULL THEN
    RETURN NULL;
  ELSIF p_monthly_salary < 0 THEN
    RAISE_APPLICATION_ERROR(-20010, 'Salary cannot be negative: ' || p_monthly_salary);
  END IF;

  IF p_monthly_salary > 60000 THEN
    v_tax := v_tax + (LEAST(p_monthly_salary, 100000) - 60000) * 0.10;
  END IF;

  IF p_monthly_salary > 100000 THEN
    v_tax := v_tax + (LEAST(p_monthly_salary, 200000) - 100000) * 0.20;
  END IF;

  IF p_monthly_salary > 200000 THEN
    v_tax := v_tax + (p_monthly_salary - 200000) * 0.30;
  END IF;

  RETURN ROUND(v_tax, 2);
END fn_calculate_tax;
/

SHOW ERRORS FUNCTION fn_calculate_tax;
