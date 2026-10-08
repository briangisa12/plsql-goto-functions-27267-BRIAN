# PL/SQL GOTO Statements and Functions

**Individual Assignment III** – Database Development with PL/SQL (INSY 8311)

| | |
|---|---|
| **NAMES** | Brian GANZA GISAGARA |
| **ID** | 27267 |
| **COURSE NAME** | DATABASE WITH PL/SQL |
| **Submission date** | 8 October 2026 |

---

## Overview

This repository contains my solutions for the PL/SQL practical on:

- **GOTO statements**: how they work, where they are legal or illegal, and how to replace them
- **Stored functions** with parameters, `%TYPE` anchoring and return values
- **Exception handling**: `NO_DATA_FOUND`, `ZERO_DIVIDE`, `RAISE_APPLICATION_ERROR`, `WHEN OTHERS`
- **Functions used inside SQL**: in `SELECT`, `WHERE` and `GROUP BY`
- A combined **payroll validator** that uses GOTO, functions and exceptions together

All examples use a small payroll database: `departments` and `employees`, with monthly salaries in RWF.

## Environment

| Item | Value |
|---|---|
| Database | Oracle AI Database 26ai Free (version 23.26) |
| Pluggable database | `BR_PDB_27267` |
| Schema / user | `brian_plsqlauca_27267` |
| Tool | Oracle SQL Developer |

## Repository Structure

```
plsql-goto-functions-27267-brian/
├── README.md
├── .gitignore
├── 00_setup/
│   └── create_tables.sql
├── 01_goto/
│   ├── A1_number_classifier.sql
│   ├── A2_salary_review.sql
│   ├── A3_illegal_goto.sql
│   └── A4_rewrite_no_goto.sql
├── 02_functions/
│   ├── B1_fn_annual_salary.sql
│   ├── B2_fn_years_of_service.sql
│   ├── B3_fn_calculate_tax.sql
│   ├── B4_fn_dept_name.sql
│   └── C1_fn_validate_payroll.sql
├── 03_tests/
│   ├── B5_functions_in_select.sql
│   ├── test_functions.sql
│   └── test_validate_payroll.sql
├── screenshots/
│   ├── A1_output.png
│   ├── A2_output.png
│   ├── A3_error_and_fix.png
│   ├── A4_output.png
│   ├── B5_select_output.png
│   ├── C1_output.png
│   ├── 00_create_tables.png
│   ├── B_functions_created.png
│   └── B_test_functions.png
└── docs/
    └── REFLECTION.md
```

## How to Run

Connect in SQL Developer as `brian_plsqlauca_27267` (service `br_pdb_27267`). Open each file and run it with **F5 (Run Script)**.

1. Run `00_setup/create_tables.sql`.
2. Run the functions in `02_functions/` (B1 → B4, then C1, because C1 uses B4).
3. Run the programs in `01_goto/`.
4. Run the test files in `03_tests/`.
5. Verify your results and screenshots.

> Turn on output with **View → Dbms Output** (add your connection), or keep the `SET SERVEROUTPUT ON;` line at the top of each script.

## Sample Data

`create_tables.sql` creates 5 departments and 10 employees. Employees **101–105 are valid**. Employees **106–110 have bad data on purpose**, so that the GOTO programs and the validator have something to catch:

| emp_id | Problem |
|---|---|
| 106 | salary is `NULL` |
| 107 | no department |
| 108 | negative salary |
| 109 | hire date in the future |
| 110 | salary above the 10,000,000 maximum |

---

## Part A – GOTO

### A1 – Number Classifier (`01_goto/A1_number_classifier.sql`)
Loops through `-15, -4, 0, 7, 12, NULL` and classifies each number as **NEGATIVE / ZERO / POSITIVE** and **EVEN / ODD**. The `IF` tests use `GOTO` to jump to the label for each case (`<<lbl_negative>>`, `<<lbl_zero>>`, `<<lbl_positive>>`, `<<lbl_null>>`). Each case then jumps to `<<lbl_next>>`, which is followed by `NULL;` because a label must be followed by an executable statement.

### A2 – Salary Review (`01_goto/A2_salary_review.sql`)
Reviews every employee with a cursor `FOR` loop and **proposes** a new salary (the table is not changed):

| Condition | Action (label) |
|---|---|
| salary `NULL` | skipped (`lbl_missing`) |
| salary ≤ 0 | skipped as invalid (`lbl_invalid`) |
| salary ≥ 2,000,000 | no raise (`lbl_no_raise`) |
| < 100,000 / < 500,000 / otherwise | +15% / +10% / +5% |

It ends with a summary: *Raised: 6 | No raise: 2 | Flagged: 2*.

### A3 – Illegal GOTO and Fix (`01_goto/A3_illegal_goto.sql`)
Two illegal GOTOs, each followed by a working fix:

| # | Illegal GOTO | Error | Fix |
|---|---|---|---|
| 1 | Jumping **into** an `IF` statement | `PLS-00375: illegal GOTO statement; this GOTO cannot branch to label 'LBL_PASS'` | Put the GOTO inside the IF and jump **out** to a label in the outer block |
| 2 | Jumping from an **exception handler back into** the block | `PLS-00375 ... label 'LBL_RETRY'` | Put the risky code in a nested block inside a `WHILE` loop. The handler fixes the problem, and the loop retries. |

**Rule:** a GOTO may jump *out of* an IF, LOOP or sub-block. It may **not** jump *into* one, and it may not jump from an exception handler into the current block.

### A4 – Rewrite Without GOTO (`01_goto/A4_rewrite_no_goto.sql`)
The same classifier as A1, rewritten with `CASE`, `IF` and `CONTINUE`. **The output is identical to A1**, but there are no labels and every path reads from top to bottom. This is why structured code is preferred over GOTO.

---

## Part B – Functions

| Task | Function | Returns | Exception / edge-case handling |
|---|---|---|---|
| B1 | `fn_annual_salary(p_emp_id)` | monthly salary × 12 | `NO_DATA_FOUND` → `NULL`; NULL salary → `NULL` |
| B2 | `fn_years_of_service(p_emp_id)` | complete years since `hire_date` | not found / NULL date → `NULL`; future date → `0` |
| B3 | `fn_calculate_tax(p_monthly_salary)` | monthly PAYE tax | NULL → `NULL`; negative → `RAISE_APPLICATION_ERROR(-20010)` |
| B4 | `fn_dept_name(p_dept_id)` | department name | NULL → `'No Department'`; not found → `'Unknown Department'` |

**B3 tax bands** (progressive; each rate applies only to the part of the salary inside that band):

| Monthly salary (RWF) | Rate |
|---|---|
| 0 – 60,000 | 0% |
| 60,001 – 100,000 | 10% |
| 100,001 – 200,000 | 20% |
| above 200,000 | 30% |

Example: 450,000 → 0 + 4,000 + 20,000 + 75,000 = **99,000**.

### B5 – Functions in SQL (`03_tests/B5_functions_in_select.sql`)
Uses the functions directly in SQL:
1. **SELECT list**: a full payroll report (department, annual salary, years of service, tax, net salary)
2. **WHERE clause**: employees with 5 or more years of service
3. **GROUP BY**: total annual salary per department
4. **On literals** from `dual`

> The tax column is wrapped in `CASE WHEN salary >= 0`, because B3 raises an error for negative salaries. Without it, a single bad row (employee 108) would stop the whole query.

---

## Part C – Combined Task

### C1 – Payroll Validator (`02_functions/C1_fn_validate_payroll.sql`)
`fn_validate_payroll(p_emp_id)` returns `'VALID'` or `'INVALID - <reason>'`. It combines all three topics:
- **GOTO**: each failed check sets a reason and jumps to a single `<<lbl_invalid>>` exit point
- **Functions**: it calls `fn_dept_name` (B4) to check the department exists
- **Exceptions**: `NO_DATA_FOUND` for unknown employees, and `WHEN OTHERS` as a safety net

Checks, in order: salary missing → salary ≤ 0 → salary > 10,000,000 → no department → department does not exist → hire date missing or in the future.

### C2 – Reflection
See [`docs/REFLECTION.md`](docs/REFLECTION.md).

---

## Test Results

| Test file | Result |
|---|---|
| `test_functions.sql` | **17 passed, 0 failed** (B1–B4: normal values, NULLs, missing rows, negative salary error) |
| `test_validate_payroll.sql` | **11 passed, 0 failed** (5 valid employees, 5 invalid with the correct reason, 1 non-existent) |

## Screenshots

| File | Shows |
|---|---|
| `screenshots/A1_output.png` | A1 classifier output |
| `screenshots/A2_output.png` | A2 salary review output |
| `screenshots/A3_error_and_fix.png` | PLS-00375 errors and the fixed versions |
| `screenshots/A4_output.png` | A4 output (same as A1, without GOTO) |
| `screenshots/B5_select_output.png` | Functions used in SELECT |
| `screenshots/C1_output.png` | Payroll validator test results |
| `screenshots/00_create_tables.png` | Setup script: tables created and sample data |
| `screenshots/B_functions_created.png` | B1–B4 and C1 functions compiled |
| `screenshots/B_test_functions.png` | `test_functions.sql` results |

---

## Notes

### Use of AI
I used an AI assistant (Claude, by Anthropic) during this assignment. It helped me:
- choose the rules for each task (the assignment lists the task names only)
- draft SQL scripts which I then ran and checked in my own database
- explain the GOTO rules behind the `PLS-00375` errors in A3

I ran every script myself in SQL Developer, checked the output, and took the screenshots. I understand the code and can explain every part of it.
