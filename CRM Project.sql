create database crm;
use crm;

-- 2. Identify the top 5 customers with the highest Estimated Salary in the last quarter of the year.
select CustomerID, estimatedsalary
from customerinfo
where month(bankdoj)>=10 and month(bankdoj)<=12
order by estimatedsalary desc
limit 5 ;

-- 3. Calculate the average number of products used by customers who have a credit card. 
select customerID, round(avg(NumOfProducts),2) as avg_num_of_products
from bank_churn 
where hascrcard='1'
group by customerID
order by avg_num_of_products desc;

-- 5. Compare the average credit score of customers who have exited and those who remain. 
select 
case 
when exited=1 then 'Exit' else 'Retain' End as Exited,
 round(avg(creditscore),2) as Avg_creditscore
from bank_churn
group by Exited;

-- 6.	Which gender has a higher average estimated salary, and how does it relate to the number of active accounts? 
select 
case when c.genderid=1 then 'Male' else 'Female' End as Gender,
round(avg(c.estimatedsalary),2) as Avg_estimatedsalary,
count(b.customerID) as active_accounts
from customerinfo c 
join bank_churn b 
on c.customerID=b.customerID
where isactivemember= 1
group by Gender
order by Avg_estimatedsalary desc ;

-- 7. Segment the customers based on their credit score and identify the segment with the highest exit rate. 
select  credit_score_segment, 
round(sum(exited)/count(*)*100,2) as exit_rate
from (
select 
case when CreditScore>=800 then 'Excellent' 
when CreditScore>=740 then 'Very Good'
when CreditScore>=670 then 'Good'
when CreditScore>=580 then 'Fair'
else 'Poor'
end as credit_score_segment,exited
from bank_churn
) as segmented_customers
group by credit_score_segment
order by exit_rate desc
limit 1;

-- 8.	Find out which geographic region has the highest number of active customers with a tenure greater than 5 years. 
select  g.GeographyLocation, 
count(b.isactivemember)  as active_customer 
from bank_churn b
join customerinfo ci 
on b.customerid=ci.customerID
join geography g
on ci.geographyID=g.geographyID
where b.IsActiveMember=1 and 
b.tenure>5
group by g.geographylocation
order by active_customer desc
limit 1;

-- 11.	Examine the trend of customers joining over time and identify any seasonal patterns (yearly or monthly). Prepare the data through SQL and then visualize it.
select 
year(bankDOJ) as Join_year,
count(*) as customer_count
from customerinfo
group by join_year
order by join_year;

-- 15.	Using SQL, write a query to find out the gender-wise average income of males and females in each geography id. Also, rank the gender according to the average value. 
select ci.GeographyID, geo.GeographyLocation, g.Gendercategory as Gender,
round(avg(ci.estimatedsalary),2) as avg_income,
DENSE_rank() over (partition by GeographyID order by avg(ci.estimatedsalary) ) as Gender_Rank
from customerinfo ci
join gender g on ci.genderID=g.genderID
join geography geo on ci.geographyID=geo.geographyID
group by ci.GeographyID, geo.GeographyLocation, g.Gendercategory,g.genderID
order by ci.geographyID;

-- 16.	Using SQL, write a query to find out the average tenure of the people who have exited in each age bracket (18-30, 30-50, 50+).
select 
case 
when ci.age between 18 and 30 then '18-30'
when ci.age between 30 and 50 then '30-50'
when ci.age>50 then '50 Above'
end as Age_Group,
round(avg(b.tenure),2) as avg_tenure
from bank_churn b
join customerinfo ci on b.customerID=ci.customerID
where exited=1 
group by age_Group
order by age_Group;

-- 19.	Rank each bucket of credit score as per the number of customers who have churned the bank.
WITH Credit_score_credentials as( 
select case
when creditscore>= 800 then 'Excellent'
when creditscore>=750 then 'Very Good' 
when creditscore>=670 then 'Good'
when creditscore>=580 then 'Fair'
else 'Poor' 
end as CreditScore_bucket
from bank_churn
where exited=1 
)
select creditscore_bucket, count(*) as Num_of_customers_churned,
rank() over(order by count(*) desc ) as Creditscore_rank
from Credit_score_credentials 
group by creditscore_bucket
order by Creditscore_rank;

-- 23.	Without using “Join”, can we get the “ExitCategory” from ExitCustomers table to Bank_Churn table? If yes do this using SQL.
select bc.*,
(select ec.exitcategory from exitcustomer ec where ec.exitID=bc.exited) as Exit_Category
from bank_churn bc;

-- 25.	Write the query to get the customer IDs, their last name, and whether they are active or not for the customers whose surname ends with “on”.
select  ci.customerID, ciactivecustomer.surname, bc.isactivemember 
from customerinfo ci 
join bank_churn bc
on bc.customerID=ci.customerID
where surname like '%on'










 