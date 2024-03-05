--------------------ex.1--------------------------------------------------------------------------------
SELECT 
EXTRACT(year from transaction_date) as year,
product_id, 
spend as curr_year_spend,
lag(spend) over(PARTITION BY product_id ORDER BY EXTRACT(year from transaction_date)) as prev_year_spend,
round(100*(spend-lag(spend) over(PARTITION BY product_id ORDER BY EXTRACT(year from transaction_date)))
/
lag(spend) over(PARTITION BY product_id ORDER BY EXTRACT(year from transaction_date)),2) as yoy_rate
FROM user_transactions

--------------------ex.2--------------------------------------------------------------------------------
WITH card_launch AS (
SELECT 
  card_name,
  issued_amount,
  MAKE_DATE(issue_year, issue_month, 1) AS issue_date,
  MIN(MAKE_DATE(issue_year, issue_month, 1)) OVER (
    PARTITION BY card_name) AS launch_date
FROM monthly_cards_issued
)

SELECT card_name, issued_amount
FROM card_launch
where issue_date=launch_date
ORDER BY issued_amount desc;

--------------------ex.3--------------------------------------------------------------------------------
with a as (
SELECT user_id, spend,transaction_date,
row_number() over(PARTITION BY user_id order by transaction_date) as rank
FROM transactions
)
select 
user_id, spend,transaction_date
from a  
where rank =3

--------------------ex.4--------------------------------------------------------------------------------
with recent_trans as (
SELECT 
transaction_date, user_id, product_id,
rank() over(PARTITION BY user_id order by transaction_date desc)
FROM user_transactions)
select 
transaction_date, 
  user_id,
  COUNT(product_id)
  from recent_trans
where rank = 1 
group by transaction_date, 
  user_id
order by transaction_date

--------------------ex.5--------------------------------------------------------------------------------
  with tweet as
(SELECT
  user_id,
  tweet_date,
 tweet_count, 
 lag(tweet_count) over( PARTITION BY user_id order by tweet_date) as pre_1_day,
 lag(tweet_count,2) over( PARTITION BY user_id order by tweet_date) as pre_2_days
FROM tweets)
select 
user_id,
  tweet_date,
case 
    when pre_2_days is not null 
          then round((tweet_count+pre_1_day+pre_2_days)/3.0,2)  
    when  pre_1_day is not null 
          then round((tweet_count+pre_1_day)/2.0,2)
    else round(tweet_count,2)
end
from tweet 

--------------------ex.6--------------------------------------------------------------------------------
with time as 
(select merchant_id, 
  credit_card_id, 
  amount,
 round(EXTRACT(EPOCH FROM transaction_timestamp - 
    LAG(transaction_timestamp) OVER(
      PARTITION BY merchant_id, credit_card_id, amount 
      ORDER BY transaction_timestamp)
  )/60,0) AS diff_time
FROM transactions)
select 
count(*) from time 
where diff_time <= 10

--------------------ex.7--------------------------------------------------------------------------------
SELECT 
  category, 
  product, 
  total_spend 
FROM (SELECT 
    category, 
    product, 
    SUM(spend) AS total_spend,
    RANK() OVER ( PARTITION BY category 
      ORDER BY SUM(spend) DESC) AS rank
  FROM product_spend
  WHERE EXTRACT(YEAR FROM transaction_date) = 2022
  GROUP BY category, product
) AS spend_rank
WHERE rank <= 2 
ORDER BY category, rank
--------------------ex.8--------------------------------------------------------------------------------
with top_10 as (select
 a.artist_name,
dense_rank() over (
      order by COUNT(s.song_id) DESC) AS artist_rank
FROM artists as a  
join songs as s on a.artist_id=s.artist_id 
join global_song_rank as g on s.song_id=g.song_id 
where g.rank <=10
group by a.artist_name
)
select artist_name, artist_rank
from top_10 
where artist_rank <=5










