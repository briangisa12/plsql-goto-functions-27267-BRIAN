-- =============================================================
-- 00_setup/create_tables.sql
-- Creates and fills the sample tables used by every task.
-- Run as: brian_plsqlauca_27267 (PDB: BR_PDB_27267)
-- Salaries are MONTHLY amounts in Rwandan Francs (RWF).
-- Some rows contain bad data ON PURPOSE (NULL salary, negative
-- salary, missing department, future hire date, very high salary)
-- so the GOTO programs and the payroll validator can be tested.
-- =============================================================

DROP TABLE IF EXISTS employees;
DROP TABLE IF EXISTS departments;

CREATE TABLE departments (
  dept_id    NUMBER(4)     PRIMARY KEY,
  dept_name  VARCHAR2(50)  NOT NULL,
  location   VARCHAR2(50)
);

CREATE TABLE employees (
  emp_id      NUMBER(6)     PRIMARY KEY,
  first_name  VARCHAR2(30)  NOT NULL,
  last_name   VARCHAR2(30)  NOT NULL,
  job_title   VARCHAR2(40),
  salary      NUMBER(12,2),             -- monthly salary (RWF)
  hire_date   DATE,
  dept_id     NUMBER(4) REFERENCES departments (dept_id)
);

INSERT INTO departments VALUES (10, 'Information Technology', 'Kigali');
INSERT INTO departments VALUES (20, 'Finance',                'Kigali');
INSERT INTO departments VALUES (30, 'Human Resources',        'Huye');
INSERT INTO departments VALUES (40, 'Marketing',              'Musanze');
INSERT INTO departments VALUES (50, 'Research',               'Rubavu');

-- Valid employees
INSERT INTO employees VALUES (101, 'Alice',    'Uwase',       'Software Developer', 450000,  DATE '2018-03-15', 10);
INSERT INTO employees VALUES (102, 'Jean',     'Habimana',    'Accountant',         1200000, DATE '2015-07-01', 20);
INSERT INTO employees VALUES (103, 'Grace',    'Mukamana',    'HR Assistant',       85000,   DATE '2023-01-10', 30);
INSERT INTO employees VALUES (104, 'Eric',     'Niyonzima',   'IT Manager',         2500000, DATE '2010-09-20', 10);
INSERT INTO employees VALUES (105, 'Diane',    'Ingabire',    'Marketing Intern',   55000,   DATE '2025-02-01', 40);
-- Employees with problems (used to test validation):
--   106 salary missing, 107 no department, 108 negative salary,
--   109 hire date in the future, 110 salary above allowed maximum
INSERT INTO employees VALUES (106, 'Patrick',  'Mugisha',     'Auditor',            NULL,     DATE '2020-05-05', 20);
INSERT INTO employees VALUES (107, 'Claire',   'Umutoni',     'Designer',           300000,   DATE '2019-11-11', NULL);
INSERT INTO employees VALUES (108, 'Kevin',    'Nshuti',      'Recruiter',          -50000,   DATE '2021-06-30', 30);
INSERT INTO employees VALUES (109, 'Sandrine', 'Iradukunda',  'Analyst',            150000,   DATE '2027-01-01', 20);
INSERT INTO employees VALUES (110, 'Samuel',   'Nkurunziza',  'Consultant',         12000000, DATE '2012-04-02', 10);

COMMIT;

SELECT * FROM departments ORDER BY dept_id;
SELECT * FROM employees   ORDER BY emp_id;
