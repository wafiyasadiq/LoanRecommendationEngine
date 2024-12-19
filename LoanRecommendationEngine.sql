create database loanrecommendationengine;
use loanrecommendationengine;
CREATE TABLE Users (
    user_id INT PRIMARY KEY,
    name VARCHAR(50),
    age INT,
    income INT,
    credit_score INT,
    employment_status VARCHAR(20)
);
CREATE TABLE LoanApplications (
    application_id INT PRIMARY KEY,
    user_id INT,
    loan_id INT,
    status VARCHAR(20),
    application_date DATE,
    FOREIGN KEY (user_id) REFERENCES Users(user_id),
    FOREIGN KEY (loan_id) REFERENCES LoanTypes(loan_id)
);
CREATE TABLE LoanTypes (
    loan_id INT PRIMARY KEY,
    loan_name VARCHAR(50),
    interest_rate FLOAT,
    loan_term INT,
    amount_range VARCHAR(20)
);
CREATE TABLE RepaymentHistory (
    repayment_id INT PRIMARY KEY,
    user_id INT,
    loan_id INT,
    repayment_status VARCHAR(20),
    FOREIGN KEY (user_id) REFERENCES Users(user_id),
    FOREIGN KEY (loan_id) REFERENCES LoanTypes(loan_id)
);
-- Listing all repayment Records with User and Loan Details
SELECT 
    r.repayment_id,
    u.name AS user_name,
    u.credit_score,
    l.loan_name,
    r.repayment_status
FROM sys.repaymenthistory r
JOIN sys.users u ON r.user_id = u.user_id
JOIN sys.loantypes l ON r.loan_id = l.loan_id
ORDER BY r.repayment_id;

-- Counting repayment status of all types of loans
SELECT 
    repayment_status,
    COUNT(*) AS total_repayments
FROM sys.repaymenthistory
GROUP BY repayment_status
ORDER BY total_repayments DESC;

-- Finding users with the highest number of on-time payments
SELECT 
    r.user_id,
    u.name AS user_name,
    COUNT(*) AS on_time_payments
FROM sys.repaymenthistory r
JOIN sys.users u ON r.user_id = u.user_id
WHERE r.repayment_status = 'On-time'
GROUP BY r.user_id, u.name
ORDER BY on_time_payments DESC
LIMIT 10;

-- Calculating default rate for each loan type
SELECT 
    l.loan_name,
    COUNT(r.repayment_id) AS total_repayments,
    SUM(CASE WHEN r.repayment_status = 'Defaulted' THEN 1 ELSE 0 END) AS defaulted_repayments,
    ROUND((SUM(CASE WHEN r.repayment_status = 'Defaulted' THEN 1 ELSE 0 END) / COUNT(r.repayment_id)) * 100, 2) AS default_rate
FROM sys.repaymenthistory r
JOIN sys.loantypes l ON r.loan_id = l.loan_id
GROUP BY l.loan_name
ORDER BY default_rate DESC;

-- Analyzing repayment history of a specific user id
SELECT 
    r.repayment_id,
    r.loan_id,
    l.loan_name,
    r.repayment_status
FROM sys.repaymenthistory r
JOIN sys.loantypes l ON r.loan_id = l.loan_id
WHERE r.user_id = 25 -- Replace with the desired user_id
ORDER BY r.repayment_id;

-- Finding loans with the most late repayments
SELECT 
    r.loan_id,
    l.loan_name,
    COUNT(*) AS late_payments
FROM sys.repaymenthistory r
JOIN sys.loantypes l ON r.loan_id = l.loan_id
WHERE r.repayment_status = 'Late'
GROUP BY r.loan_id, l.loan_name
ORDER BY late_payments DESC
LIMIT 10;

-- identifying users with consistent default history
SELECT 
    r.user_id,
    u.name AS user_name,
    COUNT(*) AS total_repayments,
    SUM(CASE WHEN r.repayment_status = 'Defaulted' THEN 1 ELSE 0 END) AS defaulted_count
FROM sys.repaymenthistory r
JOIN sys.users u ON r.user_id = u.user_id
GROUP BY r.user_id, u.name
HAVING total_repayments = defaulted_count
ORDER BY defaulted_count DESC;

-- Summarizing repayment trends by loan types 
SELECT 
    l.loan_name,
    SUM(CASE WHEN r.repayment_status = 'On-time' THEN 1 ELSE 0 END) AS on_time_count,
    SUM(CASE WHEN r.repayment_status = 'Late' THEN 1 ELSE 0 END) AS late_count,
    SUM(CASE WHEN r.repayment_status = 'Defaulted' THEN 1 ELSE 0 END) AS defaulted_count
FROM sys.repaymenthistory r
JOIN sys.loantypes l ON r.loan_id = l.loan_id
GROUP BY l.loan_name
ORDER BY defaulted_count DESC;

-- Tracking repayment history of a specific loan id
SELECT 
    r.repayment_id,
    r.user_id,
    u.name AS user_name,
    r.repayment_status
FROM sys.repaymenthistory r
JOIN sys.users u ON r.user_id = u.user_id
WHERE r.loan_id = 2 -- Replace with the desired loan_id
ORDER BY r.repayment_id;

-- Listing users with mixed repayment behaviour (on-time, defaulted and late payments)
SELECT 
    r.user_id,
    u.name AS user_name,
    COUNT(DISTINCT r.repayment_status) AS unique_statuses
FROM sys.repaymenthistory r
JOIN sys.users u ON r.user_id = u.user_id
GROUP BY r.user_id, u.name
HAVING unique_statuses > 1
ORDER BY unique_statuses DESC;
