**Names:** Brian GANZA GISAGARA  
**ID:** 27267  
**COURSE:** DATABASE WITH PL/SQL ASSIGNMENT III

# C2 – Reflection

## 1. What I learned about GOTO

- `GOTO` jumps unconditionally to a label (`<<label_name>>`) in the same block.
- A label must be followed by an executable statement. When there is nothing to do at that point, `NULL;` is used.
- A GOTO can jump FROM an IF, LOOP or sub-block, but not to one. It also cannot jump from an exception handler back into the block. Both cases give `PLS-00375: illegal GOTO statement` (see A3).
- In A1 and A2 the GOTO versions work, but the reader has to keep jumping around to follow the flow.

## 2. GOTO vs. structured code

- A4 gives exactly the same output as A1 but uses `CASE`, `IF` and `CONTINUE`. It is shorter, reads from top to bottom, and is easier to change.
- GOTO was useful in C1: every failed check jumps to one `<<lbl_invalid>>` exit point, which avoids repeating the same `RETURN` code. Even there, `ELSIF` or raising a custom exception could do the same job.
- My conclusion: GOTO should be rare. Use it only when it really makes the code simpler, and prefer loops, `CASE`, `CONTINUE`/`EXIT` and exceptions.

## 3. What I learned about functions

- A function return a value, and it can be called from PL/SQL and can also be called from SQL (B5) in `SELECT`, `WHERE` and `GROUP BY`.
- `%TYPE` (for example `employees.salary%TYPE`) keeps parameter and variable types in step with the table.
- Small, single-purpose functions (B1–B4) can be reused. C1 reuses `fn_dept_name`, and B5 combines all of them in one report.

## 4. Exception handling

- `NO_DATA_FOUND` is raised by `SELECT ... INTO` when no row exists. B1, B2, B4 and C1 handle it and return a meaningful value instead of failing.
- `RAISE_APPLICATION_ERROR(-20010, ...)` in B3 rejects invalid input with a clear custom message.
- A function that raises an error inside a SQL query stops the entire query. That is why B5 only calls `fn_calculate_tax` when `salary >= 0`.

## 5. Challenges and how I solved them

| Challenge | Solution |
|---|---|
| The `PLS-00375` error in A3 was confusing at first | Learned that GOTO can only jump to a label in the same or an enclosing sequence of statements, not into an IF/LOOP or from a handler |
| Some `INSERT` rows were silently skipped | A `-- comment` after the `;` on the same line stopped the statement from ending correctly in the script runner. I moved comments onto their own lines. |
| A test passed even though the result was wrong | The C1 test only checked for the word "INVALID". I changed it to check the exact reason. |
| One bad salary broke the whole B5 report | Wrapped the tax function in `CASE WHEN salary >= 0` |

## 6. What I would improve

- Store the tax bands in a table instead of hard-coding them in B3.
- Put the functions in a **package** (for example `pkg_payroll`) to group them together.
- Add a procedure that uses `fn_validate_payroll` before actually applying the A2 salary raises.
