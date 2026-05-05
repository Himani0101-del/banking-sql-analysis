CREATE TABLE transactions_raw (
    trans_id INT,
    account_id INT,
    date TEXT,
    type TEXT,
    operation TEXT,
    amount NUMERIC,
    balance NUMERIC,
    k_symbol TEXT,
    bank TEXT,
    account TEXT
);

CREATE TABLE account (
    account_id INT,
	district_id int,
	frequency text,
    date TEXT
);

CREATE TABLE card (
    card_id INT,
	disp_id int,
	type text,
    issued TEXT
);

CREATE TABLE client (
    client_id      INT PRIMARY KEY,
    birth_number   VARCHAR(10),
    district_id    INT
);

CREATE TABLE disp (
    disp_id     INT PRIMARY KEY,
    client_id   INT,
    account_id  INT,
    type        VARCHAR(20)
);
CREATE TABLE district (
    district_id   INT PRIMARY KEY,
    A2            VARCHAR(100),
    A3            VARCHAR(100),
    A4            INT,
    A5            INT,
    A6            INT,
    A7            INT,
    A8            INT,
    A9            INT,
    A10           NUMERIC,
    A11           INT,
    A12           NUMERIC,
    A13           NUMERIC,
    A14           INT,
    A15           INT,
    A16           INT
);
CREATE TABLE loan (
    loan_id     INT PRIMARY KEY,
    account_id  INT,
    date        VARCHAR(10),
    amount      NUMERIC,
    duration    INT,
    payments    NUMERIC,
    status      VARCHAR(5)
);
CREATE TABLE orders (
    order_id     INT PRIMARY KEY,
    account_id   INT,
    bank_to      VARCHAR(10),
    account_to   VARCHAR(20),
    amount       NUMERIC,
    k_symbol     VARCHAR(50)
);

ALTER TABLE account
ADD CONSTRAINT account_pkey PRIMARY KEY (account_id);
ALTER TABLE transactions_raw
ADD CONSTRAINT transactions_raw_pkey PRIMARY KEY (trans_id);
ALTER TABLE card
ADD CONSTRAINT card_pkey PRIMARY KEY (card_id);

/* changing date dtypes*/
ALTER TABLE transactions_raw
ALTER COLUMN date TYPE DATE
USING TO_DATE(date, 'YYMMDD');

ALTER TABLE account
ALTER COLUMN date TYPE DATE
USING TO_DATE(date, 'YYMMDD');

ALTER TABLE card
ALTER COLUMN issued TYPE DATE
USING TO_DATE(issued, 'YYMMDD');

ALTER TABLE loan
ALTER COLUMN date TYPE DATE
USING TO_DATE(date, 'YYMMDD');



/* Which districts have the highest loan defaults?*/
SELECT 
    d.A2 AS district_name,
    COUNT(*) AS total_loans,
    COUNT(CASE WHEN l.status = 'D' THEN 1 END) AS defaulted_loans,
    ROUND(
        COUNT(CASE WHEN l.status = 'D' THEN 1 END)::numeric 
        / COUNT(*) * 100, 
        2
    ) AS default_rate_percent
FROM loan l
JOIN account a 
    ON l.account_id = a.account_id
JOIN district d 
    ON a.district_id = d.district_id
GROUP BY d.A2
ORDER BY default_rate_percent DESC;

/*Domazlice is the riskiest district (50% default rate)*/

/*Which accounts show risky transaction behavior?*/

SELECT
    account_id,
    SUM(CASE 
            WHEN type IN ('VYBER', 'VYDAJ', 'VYBER KARTOU', 'PREVOD NA UCET') 
            THEN amount ELSE 0 
        END) AS total_withdrawal_amount,
    SUM(CASE 
            WHEN type IN ('PRIJEM', 'VKLAD', 'PREVOD Z UCTU') 
            THEN amount ELSE 0 
        END) AS total_deposit_amount,
    SUM(CASE 
            WHEN type IN ('VYBER', 'VYDAJ', 'VYBER KARTOU', 'PREVOD NA UCET') 
            THEN amount ELSE 0 
        END)
    -
    SUM(CASE 
            WHEN type IN ('PRIJEM', 'VKLAD', 'PREVOD Z UCTU') 
            THEN amount ELSE 0 
        END) AS difference
FROM transACTIONS_RAW
GROUP BY account_id
HAVING 
    SUM(CASE 
            WHEN type IN ('VYBER', 'VYDAJ', 'VYBER KARTOU', 'PREVOD NA UCET') 
            THEN amount ELSE 0 
        END)
    >
    SUM(CASE 
            WHEN type IN ('PRIJEM', 'VKLAD', 'PREVOD Z UCTU') 
            THEN amount ELSE 0 
        END)
		ORDER BY DIFFERENCE DESC LIMIT 5;

/*Average loan size by region*/
SELECT D.A3,
       AVG(L.AMOUNT)AS avg_loan_size
FROM LOAN L
JOIN ACCOUNT A ON A.ACCOUNT_ID=L.ACCOUNT_ID
JOIN DISTRICT D ON D.district_id =A.DISTRICT_ID
GROUP BY D.A3 
ORDER BY avg_loan_size;

/*monthly transaction growth trends*/
SELECT
    EXTRACT(MONTH FROM date) AS month_number,
    COUNT(*) AS monthly_count,
    COUNT(*)::decimal / (SELECT COUNT(*) FROM loan) * 100 AS percentage_of_year
FROM loan
GROUP BY EXTRACT(MONTH FROM date)
ORDER BY month_number;


/*trend*/

WITH yearly_totals AS (
    SELECT
        EXTRACT(YEAR FROM date) AS year,
        COUNT(*) AS total_year
    FROM loan
    GROUP BY EXTRACT(YEAR FROM date)
)

SELECT
    EXTRACT(YEAR FROM l.date) AS year,
    EXTRACT(MONTH FROM l.date) AS month,
    COUNT(*) AS monthly_count,
    COUNT(*)::decimal / yt.total_year * 100 AS percentage_of_year
FROM loan l
JOIN yearly_totals yt
    ON EXTRACT(YEAR FROM l.date) = yt.year
GROUP BY
    EXTRACT(YEAR FROM l.date),
    EXTRACT(MONTH FROM l.date),
    yt.total_year
ORDER BY
    year,
    month;
	
