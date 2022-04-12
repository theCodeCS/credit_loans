--Business Question: A business manager of a consumer credit card portfolio is facing the problem 
--of customer attrition. They want to analyze the data to find out the reason behind this and 
--leverage the same to predict customers who are likely to drop off.
select *
from credit_loan

--viewing the credit limit per income category
select *
from (select income_category, gender, avg(credit_limit)
	 	from credit_loan
	  	group by 1,2
	 ) as sub
	 
--Seeing how many of our customers left
select sum(case when attrition_flag = 'Attrited Customer' THEN 1
			ELSE 0 END) as attrition
from credit_loan

--we see that most people cancel there card when they are 2-3months inactive
select months_inactive_12_mon, card_category,count(card_category)
from credit_loan
where attrition_flag = 'Attrited Customer'
group by 1,2
order by 3 desc, 1 desc

--For each card category the months avg out between 2-3months inactivity
select card_category, avg(months_inactive_12_mon)
from (select months_inactive_12_mon, card_category,count(card_category)
		from credit_loan
		where attrition_flag = 'Attrited Customer'
		group by 1,2
	 ) as sub
group by 1

---Seeing how gender takes into the affect of months since activity
select card_category,gender, avg(months_inactive_12_mon) as avg_inactive_mon
from credit_loan
where attrition_flag = 'Attrited Customer'
group by 1, 2
order by 3 desc

--Gender of number of customer who attrited
select COUNT(CASE WHEN gender = 'M' THEN 1 ELSE NULL END) AS n_male,
		COUNT(CASE WHEN gender = 'F' THEN 1 ELSE NULL END) AS n_female
from credit_loan
where attrition_flag = 'Attrited Customer'

--We see that people with lower income are likely to attrited 
select income_category, count(*)
from credit_loan
where attrition_flag = 'Attrited Customer'
group by 1
order by 2 desc, 1 desc

-- attrition for inactive month
select months_inactive_12_mon,
		count(total_trans_ct)
from credit_loan
where attrition_flag = 'Attrited Customer'
group by 1
order by 1

--attrition based on transaction count
select months_inactive_12_mon,
	COUNT(CASE WHEN total_trans_ct BETWEEN 0 and 9 THEN '0-9' ELSE NULL END) trans_ct_0_9,
	COUNT(CASE WHEN total_trans_ct BETWEEN 10 AND 19 THEN '10-19' ELSE NULL END) trans_ct_10_19,
	COUNT(CASE WHEN total_trans_ct BETWEEN 20 AND 29 THEN '20-29' ELSE NULL END) trans_ct_20_29,
	COUNT(CASE WHEN total_trans_ct BETWEEN 30 AND 39 THEN '30-39' ELSE NULL END) trans_ct_30_39,
	COUNT(CASE WHEN total_trans_ct BETWEEN 40 AND 49 THEN '40-49' ELSE NULL END) trans_ct_40_49,
	COUNT(CASE WHEN total_trans_ct BETWEEN 50 AND 59 THEN '50-59' ELSE NULL END) trans_ct_50_59,
	COUNT(CASE WHEN total_trans_ct BETWEEN 60 AND 69 THEN '60-69' ELSE NULL END) trans_ct_60_69,
	COUNT(CASE WHEN total_trans_ct BETWEEN 70 AND 79 THEN '70-79' ELSE NULL END) trans_ct_70_79,
	COUNT(CASE WHEN total_trans_ct BETWEEN 80 AND 89 THEN '80-89' ELSE NULL END) trans_ct_80_89,
	COUNT(CASE WHEN total_trans_ct BETWEEN 90 AND 99 THEN '90-99' ELSE NULL END) trans_ct_90_99
from credit_loan
where attrition_flag = 'Attrited Customer'
group by 1
order by 1

--Seeing customers that customers 60-69 have a higher attrition rate
select CASE WHEN customer_age BETWEEN 20 AND 29 THEN '20-29'
			WHEN customer_age BETWEEN 30 AND 39 THEN '30-39'
			WHEN customer_age BETWEEN 40 AND 49 THEN '40-49'
			WHEN customer_age BETWEEN 50 AND 59 THEN '50-59'
			WHEN customer_age BETWEEN 60 AND 69 THEN '60-69'
			ELSE '70+' END AS age,
		avg(months_inactive_12_mon)
from credit_loan
where attrition_flag = 'Attrited Customer'
group by 1
order by 2 desc

--Even if we do spread the range further we see people 60+ still have a higher attrition rate
select CASE WHEN customer_age BETWEEN 20 AND 39 THEN '20-39'
			WHEN customer_age BETWEEN 40 AND 59 THEN '40-59'
			ELSE '60+' END AS age,
		avg(months_inactive_12_mon)
from credit_loan
where attrition_flag = 'Attrited Customer'
group by 1
order by 2 desc

--We do see the bulk of it though that our customer base leaving are in month2-3 of inactivity,
-- and are in the range of 40-59, regardless of income_category
select CASE WHEN customer_age BETWEEN 20 AND 39 THEN '20-39'
			WHEN customer_age BETWEEN 40 AND 59 THEN '40-59'
			ELSE '60+' END AS age,
		months_inactive_12_mon,
		income_category,
		count(*) as n_count
from credit_loan
where attrition_flag = 'Attrited Customer'
group by 1,2,3
order by 4 desc

--we see that total relationship count doesnt take any affect in our search
select CASE WHEN customer_age BETWEEN 20 AND 39 THEN '20-39'
			WHEN customer_age BETWEEN 40 AND 59 THEN '40-59'
			ELSE '60+' END AS age,
		months_inactive_12_mon,
		income_category,
		total_relationship_count,
		count(*) as n_count
from credit_loan
where attrition_flag = 'Attrited Customer'
group by 1,2,3,4
order by 5 desc

--We do see the same thing that its mostly the age, income less than $40k and month inactivity 
--taking into the affect than anything else
select CASE WHEN customer_age BETWEEN 20 AND 39 THEN '20-39'
			WHEN customer_age BETWEEN 40 AND 59 THEN '40-59'
			ELSE '60+' END AS age,
		months_inactive_12_mon,
		income_category,
		marital_status,
		count(*) as n_count
from credit_loan
where attrition_flag = 'Attrited Customer'
group by 1,2,3,4
order by 5 desc

--looks like credit limit does affect it as much
select CASE WHEN credit_limit BETWEEN 0 AND 4999 THEN '<5K'
			WHEN credit_limit BETWEEN 5000 AND 9999 THEN '5K-10K'
			WHEN credit_limit BETWEEN 10000 AND 14999 THEN '10K-15k'
			WHEN credit_limit BETWEEN 15000 AND 19999 THEN '15K-20K'
			WHEN credit_limit BETWEEN 20000 AND 24999 THEN '20K-25K'
			WHEN credit_limit BETWEEN 25000 AND 29999 THEN '25K-30K'
			ELSE '30K+' END AS cred_limit,
			avg(months_inactive_12_mon)
from credit_loan
where attrition_flag = 'Attrited Customer'
group by 1
order by 2 desc

--Looks like with a credit_limit <10k they are more likely to attrite taking into the account the
-- age range 40-59
select CASE WHEN customer_age BETWEEN 20 AND 39 THEN '20-39'
			WHEN customer_age BETWEEN 40 AND 59 THEN '40-59'
			ELSE '60+' END AS age,
		CASE WHEN credit_limit BETWEEN 0 AND 9999 THEN '<10K'
			WHEN credit_limit BETWEEN 10000 AND 19999 THEN '10K-20K'
			WHEN credit_limit BETWEEN 20000 AND 29999 THEN '20K-30K'
			ELSE '30K+' END AS cred_limit,
			months_inactive_12_mon,
			income_category,
			marital_status,
			count(*) as n_count
from credit_loan
where attrition_flag = 'Attrited Customer'
group by 1,2,3,4,5
order by 6 desc

-- mostly spent 30-39months with the bank before they attrited
select CASE WHEN months_on_book BETWEEN 10 AND 19 THEN '10-19'
			WHEN months_on_book BETWEEN 20 AND 29 THEN '20-29'
			WHEN months_on_book BETWEEN 30 AND 39 THEN '30-39'
			WHEN months_on_book BETWEEN 40 AND 49 THEN '40-49'
			ELSE '50+' END AS time_with_bank,
		months_inactive_12_mon,
		count(*) as n_amt
from credit_loan
where attrition_flag = 'Attrited Customer'
group by 1,2
order by 3 desc

--The profile is they are age 40-59, have a credit limit less than 10k, spent 30-39months with the bank
-- are inactive the most 2-3months and have income less than 40k
select CASE WHEN customer_age BETWEEN 20 AND 39 THEN '20-39'
			WHEN customer_age BETWEEN 40 AND 59 THEN '40-59'
			ELSE '60+' END AS age,
		CASE WHEN credit_limit BETWEEN 0 AND 9999 THEN '<10K'
			WHEN credit_limit BETWEEN 10000 AND 19999 THEN '10K-20K'
			WHEN credit_limit BETWEEN 20000 AND 29999 THEN '20K-30K'
			ELSE '30K+' END AS cred_limit,
		CASE WHEN months_on_book BETWEEN 10 AND 19 THEN '10-19'
			WHEN months_on_book BETWEEN 20 AND 29 THEN '20-29'
			WHEN months_on_book BETWEEN 30 AND 39 THEN '30-39'
			WHEN months_on_book BETWEEN 40 AND 49 THEN '40-49'
			ELSE '50+' END AS time_with_bank,
			months_inactive_12_mon,
			income_category,
			marital_status,
			count(*) as n_count
from credit_loan
where attrition_flag = 'Attrited Customer'
group by 1,2,3,4,5,6
order by 7 desc

--We do notice as well that even though the age 40-49 with credit_limit less than 10k
--they do have the largest sum of credit given for all groups
select CASE WHEN credit_limit BETWEEN 0 AND 9999 THEN '<10K'
			WHEN credit_limit BETWEEN 10000 AND 19999 THEN '10K-20K'
			WHEN credit_limit BETWEEN 20000 AND 29999 THEN '20K-30K'
			ELSE '30K+' END AS cred_limit,
		CASE WHEN customer_age BETWEEN 20 AND 39 THEN '20-39'
			WHEN customer_age BETWEEN 40 AND 59 THEN '40-59'
			ELSE '60+' END AS age,
		sum(customer_age),
		count(*)
from credit_loan
where attrition_flag = 'Attrited Customer'
group by 1,2
order by 3 desc



