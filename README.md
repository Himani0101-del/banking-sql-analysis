# banking-sql-analysis
 Banking Risk & Transaction Analysis — SQL Portfolio Project
A SQL-based exploratory analysis of a relational banking dataset, focused on identifying credit risk signals, transaction behavior patterns, and regional loan trends.
Built using PostgreSQL across 8 interconnected tables.

 Business Questions Answered
#QuestionKey Finding1Which districts have the highest loan default rates?Domazlice had a 50% default rate — the highest in the dataset2Which accounts show risky transaction behavior?Several accounts had withdrawals consistently exceeding deposits3What is the average loan size by region?Significant variation across regions, useful for regional risk scoring4What are the monthly loan issuance trends?Clear seasonal patterns in lending activity across the year5How does loan volume trend year-over-year by month?Year-over-year breakdown reveals growth and slowdown periods

 Database Schema
The dataset consists of 8 related tables:
transactions_raw  →  account  →  district
                  →  loan
                  →  disp     →  client
                              →  card
orders            →  account
Tables:

transactions_raw — individual account transactions (type, amount, balance, operation)
account — account metadata (district, statement frequency, open date)
loan — loan records with status (A=OK, B=defaulted, C=active, D=defaulted)
client — client demographic info
disp — account-to-client disposition (owner vs. user)
card — credit/debit card records
district — regional demographic and economic indicators
orders — standing payment orders


 SQL Techniques Used

Multi-table JOINs — linking up to 4 tables in a single query
CASE WHEN — behavioral segmentation of transaction types
CTEs (Common Table Expressions) — year-over-year trend analysis
Aggregate functions — SUM, COUNT, AVG, ROUND
HAVING clause — filtering grouped results for risk flagging
Date type casting — converting raw YYMMDD text to proper DATE types
Schema design & constraints — PRIMARY KEY definitions and ALTER TABLE transformations


 Files
FileDescriptionschema_and_queries.sqlFull SQL script: schema setup, data type casting, and all analysis queries

 Key Takeaways

Domazlice is the highest-risk district with a 50% loan default rate
Accounts where withdrawals > deposits are strong candidates for early credit risk intervention
Seasonal lending patterns suggest opportunity for time-based forecasting models
Regional average loan sizes vary significantly, pointing to the need for district-level risk pricing


 Tools Used

PostgreSQL
pgAdmin 

 About
This project was built as part of my Business Analyst portfolio to sharpen core SQL skills while exploring real-world financial risk analysis


