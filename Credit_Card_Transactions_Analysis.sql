Select * from credit_card_transactions


--1-write a query to print top 5 cities with highest spends 
--and their percentage contribution of total credit card spends 

with cte1 as (
select city,sum(amount) as total_spend
from credit_card_transactions
group by city)
,total_spent as (select sum(cast(amount as bigint)) as total_amount from credit_card_transactions)
select top 5 cte1.*, round(total_spend*1.0/total_amount * 100,2) as percentage_contribution from 
cte1 inner join total_spent on 1=1
order by total_spend desc

--2- write a query to print highest spend month and amount spent in that month for each card type

with cte as (
select card_type,datepart(year,transaction_date) yt ,datepart(month,transaction_date) mt ,sum(amount) as total_spend
from credit_card_transactions
group by card_type,datepart(year,transaction_date),datepart(month,transaction_date)
)
select * from (select *, rank() over (partition by card_type order by total_spend) as rn from cte) a where rn=1

--3- write a query to print the transaction details(all columns from the table) for each card type when
--it reaches a cumulative of  1,000,000 total spends(We should have 4 rows in the o/p one for each card type)


with cte as (
select *,sum(amount) over (partition by card_type order by transaction_date,transaction_id) as total_spend
from credit_card_transactions
)
select * from (select *,rank() over (partition by card_type order by total_spend) as rn 
from cte where total_spend >= 1000000 ) a where rn=1


--4- write a query to find city which had lowest percentage spend for gold card type
with cte as (
select top 1 city,card_type,sum(amount) as amount
,sum(case when card_type='Gold' then amount end) as gold_amount
from credit_card_transcations
group by city,card_type)
select 
city,sum(gold_amount)*1.0/sum(amount) as gold_ratio
from cte
group by city
having count(gold_amount) > 0 and sum(gold_amount)>0
order by gold_ratio;


select distinct exp_type from credit_card_transcations;

with cte as (
select city,exp_type, sum(amount) as total_amount from credit_card_transcations
group by city,exp_type)
select
city , max(case when rn_asc=1 then exp_type end) as lowest_exp_type
, min(case when rn_desc=1 then exp_type end) as highest_exp_type
from
(select *
,rank() over(partition by city order by total_amount desc) rn_desc
,rank() over(partition by city order by total_amount asc) rn_asc
from cte) A
group by city;

--6- write a query to find percentage contribution of spends by females for each expense type
select exp_type,
sum(case when gender='F' then amount else 0 end)*1.0/sum(amount) as percentage_female_contribution
from credit_card_transcations
group by exp_type
order by percentage_female_contribution desc;














