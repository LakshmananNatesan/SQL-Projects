CREATE TABLE employees (
    employee_id INT PRIMARY KEY,
    name VARCHAR(10) NOT NULL,
    join_date DATE NOT NULL,
    department VARCHAR(10) NOT NULL
);
INSERT INTO employees (employee_id, name, join_date, department)
VALUES
    (1, 'Alice', '2018-06-15', 'IT'),
    (2, 'Bob', '2019-02-10', 'Finance'),
    (3, 'Charlie', '2017-09-20', 'HR'),
    (4, 'David', '2020-01-05', 'IT'),
    (5, 'Eve', '2016-07-30', 'Finance'),
    (6, 'Sumit', '2016-06-30', 'Finance');
    
CREATE TABLE salary_history (
    employee_id INT,
    change_date DATE NOT NULL,
    salary DECIMAL(10,2) NOT NULL,
    promotion VARCHAR(3)
);
INSERT INTO salary_history (employee_id, change_date, salary, promotion)
VALUES
    (1, '2018-06-15', 50000, 'No'),
    (1, '2019-08-20', 55000, 'No'),
    (1, '2021-02-10', 70000, 'Yes'),
    (2, '2019-02-10', 48000, 'No'),
    (2, '2020-05-15', 52000, 'Yes'),
    (2, '2023-01-25', 68000, 'Yes'),
    (3, '2017-09-20', 60000, 'No'),
    (3, '2019-12-10', 65000, 'No'),
    (3, '2022-06-30', 72000, 'Yes'),
    (4, '2020-01-05', 45000, 'No'),
    (4, '2021-07-18', 49000, 'No'),
    (5, '2016-07-30', 55000, 'No'),
    (5, '2018-11-22', 62000, 'Yes'),
    (5, '2021-09-10', 75000, 'Yes'),
    (6, '2016-06-30', 55000, 'No'),
    (6, '2017-11-22', 50000, 'No'),
    (6, '2018-11-22', 40000, 'No'),
    (6, '2021-09-10', 75000, 'Yes');

with cte as (
SELECT *,
RANK() OVER (PARTITION BY employee_id ORDER BY change_date DESC ) AS rank1desc,
RANK() OVER (PARTITION BY employee_id ORDER BY change_date asc ) AS rank1asc,
LEAD(salary,1,0)OVER (partition by employee_id ORDER BY change_date desc  ) as previoussalary,
LEAD(change_date,1,0)OVER (partition by employee_id ORDER BY change_date desc  ) as previousdate
FROM salary_history),
latest_salary_cte as (
SELECT employee_id,salary as latest_salary
FROM cte
WHERE rank1desc = 1),
promotions as (
SELECT employee_id,COUNT(*) as promotions
FROM cte
where promotion = 'Yes'
GROUP by 1),
previous1 as (
SELECT *,
LEAD(salary,1,0)OVER (partition by employee_id ORDER BY change_date desc  ) as previoussalary,
LEAD(change_date,1,0)OVER (partition by employee_id ORDER BY change_date desc  ) as previousdate
FROM cte),
salary_growth1 as (
SELECT *,(salary-previoussalary)*100.0 / previoussalary as salary_growth
from cte),
hike_percentages as (
select employee_id,MAX(salary_growth) as sgh
FROM salary_growth1
GROUP BY 1),
salary_decreased as (
SELECT DISTINCT employee_id, 'N' AS never_decreased
FROM cte
WHERE salary < previoussalary ),
average_month_cte as (
SELECT employee_id, AVG(TIMESTAMPDIFF(month, previousdate, change_date)) as month_between_changes
FROM cte
GROUP BY 1),
table_for_rank as(
SELECT employee_id,
	MIN(CASE WHEN rank1desc=1 THEN salary end ) / MIN(CASE WHEN rank1asc=1 THEN salary end ) as 'SALARY_GROWTH_RATIO',
    MIN(change_date) as join_date
 FROM cte
 GROUP BY 1),
 finall_rank as(
SELECT *,rank() OVER ( ORDER BY SALARY_GROWTH_RATIO DESC,join_date asc) AS rank12
FROM table_for_rank)

SELECT cte.employee_id,MAX(CASE WHEN rank1desc=1 then salary end )as latest_Salary
,SUM(CASE WHEN promotion = 'Yes' then 1 ELSE 0 end ) as no_of_promotions
,max((salary-previoussalary)*100.0 / previoussalary) as salary_growth
,case when max(case when salary < previoussalary then 1 else 0 end ) =0 then 'Yes'  else 'No' end  as Never_Decreased
,AVG(TIMESTAMPDIFF(month, previousdate, change_date)) as month_between_changes
,rank() OVER ( ORDER BY tr.SALARY_GROWTH_RATIO DESC,tr.join_date asc) as RankByGrowth
FROM cte
left join table_for_rank  tr on cte.employee_id = tr.employee_id
GROUP BY 1,tr.SALARY_GROWTH_RATIO ,tr.join_date
order by 1



/*
SELECT e.employee_id,e.name,ls.latest_salary,ifnull(p.promotions,0) as no_of_promotions ,hp.sgh,ifnull(sd.never_decreased,'Y'),amc.month_between_changes,fr.rank12
from employees e
LEFT JOIN latest_salary_cte ls on e.employee_id = ls.employee_id
LEFT JOIN promotions p  on e.employee_id = p.employee_id
LEFT JOIN hike_percentages hp on e.employee_id = hp.employee_id
LEFT JOIN salary_decreased sd on e.employee_id = sd.employee_id
LEFT JOIN average_month_cte amc on  e.employee_id = amc.employee_id
LEFT JOIN finall_rank fr on  e.employee_id = fr.employee_id
*/;




