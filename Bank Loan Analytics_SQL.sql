create database project_loan_analytics;
use project_loan_analytics;
select * from finance_1_cleaned;
select * from finance_2_cleaned;
select * from merged;

#Year wise loan amount
WITH ranked_loans AS (
    SELECT
        year_issue_d AS issue_year,
        loan_amnt,
        ROW_NUMBER() OVER (PARTITION BY year_issue_d ORDER BY loan_amnt) AS rn,
        COUNT(*) OVER (PARTITION BY year_issue_d) AS cnt
    FROM merged
)
SELECT
    issue_year,
    SUM(loan_amnt) AS total_loan,
    AVG(loan_amnt) AS avg_loan,
    AVG(loan_amnt) AS median_loan,
    MAX(loan_amnt) AS max_loan,
    MIN(loan_amnt) AS min_loan
FROM ranked_loans
WHERE rn IN (FLOOR((cnt + 1) / 2), FLOOR((cnt + 2) / 2))
GROUP BY issue_year
ORDER BY issue_year DESC;



#Grade, sub-grade wise revol-balance
SELECT
    grade,
    sub_grade,
    CONCAT('$', FORMAT(ROUND(SUM(F2_revol_bal) / 1000000, 2), 2), 'M') AS sum_revol_bal,
    CONCAT('$', FORMAT(ROUND(AVG(F2_revol_bal) / 1000000, 2), 2), 'M') AS avg_revol_bal
FROM merged
GROUP BY grade, sub_grade
ORDER BY grade, sub_grade;


#Home-Ownership vs Total Payment
select verification_status,CONCAT('$', FORMAT(ROUND(SUM(F2_total_pymnt) / 1000000, 2), 2), 'M')  as Total_payment from merged group by verification_status;

#State wise month wise loan status(need to do)
select addr_state,loan_status,month_issue_d as month_issue,count(*) as loan_count from merged  group by addr_state,loan_status,month_issue ORDER BY loan_count desc,month_issue desc; 

select * from merged;
desc merged;
#Home-ownership vs Last Payment
select home_ownership,F2_last_pymnt_d,count(*) as Total_count from merged group by home_ownership,F2_last_pymnt_d order by home_ownership asc,total_count desc;

