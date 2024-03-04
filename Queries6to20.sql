/*COMPLEX QUERIES 6-10*/
-- 6. Identify the sport which was played in all summer olympics.
WITH t1 as
(
	SELECT COUNT(DISTINCT(games)) as total_games
	FROM olympics_history WHERE season = 'Summer'
),
t2 as
(
	SELECT DISTINCT sport, games
	FROM olympics_history where season = 'Summer'
),
t3 as
(
	SELECT sport, count(1) as no_of_games
	FROM t2
	GROUP BY sport
)
SELECT * 
FROM t3 
JOIN t1 on t1.total_games = t3.no_of_games

--7. Which Sports were just played only once in the olympics.
with t1 as
(
	SELECT DISTINCT sport,COUNT(DISTINCT(games)) as no_of_games
	FROM olympics_history 
	GROUP BY sport
	order by no_of_games 
),
t2 as 
(
	SELECT sport,no_of_games
	FROM t1
	WHERE no_of_games = (SELECT MIN(no_of_games)  FROM t1)
	
),t3 as
(
	SELECT games,sport   
	FROM olympics_history 
	group by games,sport
	having sport IN (select sport from t2)
)
SELECT t2.sport,t2.no_of_games,t3.games 
FROM t3 
JOIN t2 on t2.sport = t3.sport

--8.Fetch the total no of sports played in each olympic games.

SELECT COUNT(DISTINCT(sport)) as no_of_sport,games
FROM olympics_history
GROUP BY games
ORDER BY no_of_sport DESC

--9. Fetch oldest athletes to win a gold medal
SELECT name,sex,age,team,games,city,sport,event,medal 
FROM olympics_history
WHERE medal = 'Gold' and age != 'NA'
ORDER BY age DESC

--10. Find the Ratio of male and female athletes participated in all olympic games.
WITH t1 as 
(
	SELECT sex, count(1) as cnt
    FROM olympics_history
    GROUP BY sex
),
t2 as
(
	SELECT *, row_number() over(order by cnt) as rn
    from t1
),
min_cnt as
(
	select cnt from t2 where rn = 1
),
max_cnt as 
(
	select cnt from t2 where rn = 2
)
SELECT 
	concat('1:',round(max_cnt.cnt::decimal/min_cnt.cnt,2)) as ratio
FROM min_cnt,max_cnt

--11.Fetch the top 5 athletes who have won the most gold medals.

WITH fintal_table as
(
SELECT name,team,count(1) as total_gold_medals 
FROM olympics_history
WHERE medal = 'Gold' and age != 'NA'
GROUP BY name,team
ORDER BY total_gold_medals DESC
), t1 as
(
	SELECT *,dense_rank() OVER( ORDER BY total_gold_medals DESC) as medal_order 
	FROM fintal_table
)
SELECT name, team, total_gold_medals FROM t1 WHERE medal_order < 6;

--12.Fetch the top 5 athletes who have won the most medals (gold/silver/bronze).

WITH fintal_table as
(
SELECT name,team,count(1) as total_gold_medals 
FROM olympics_history
WHERE medal IN ('Gold','Bronze','Silver')and medal != 'NA'
GROUP BY name,team
ORDER BY total_gold_medals DESC
), t1 as
(
	SELECT *,dense_rank() OVER( ORDER BY total_gold_medals DESC) as medal_order 
	FROM fintal_table
)
SELECT name, team, total_gold_medals FROM t1 WHERE medal_order < 6;

--13.Fetch the top 5 most successful countries in olympics. Success is defined by no of medals won

select region,count(medal) as total_medals_by_country,
RANK() OVER(order by count(medal) DESC) as rnk
from OLYMPICS_HISTORY oh
join OLYMPICS_HISTORY_NOC_REGIONS nr on nr.noc = oh.noc
where medal<> 'NA'
group by nr.region LIMIT 5
	
--14. List down total gold, silver and bronze medals won by each country.

SELECT country,
	coalesce(gold,0) as gold,
	coalesce(silver,0) as silver,
	coalesce(bronze,0) as bronze
FROM CROSSTAB
(
	'SELECT nr.region as country,
	medal, count(1) as total_medals
	FROM olympics_history oh
    JOIN olympics_history_noc_regions nr ON nr.noc = oh.noc
	where medal <> ''NA''
    GROUP BY nr.region,medal
    order BY nr.region,medal',
	'values(''Bronze''),(''Gold''),(''Silver'')')
AS final_Result(country varchar, bronze bigint, gold bigint, silver bigint)
order by gold desc, silver desc, bronze desc;

--15.List down total gold, silver and bronze medals won by each country corresponding to each olympic games.

with Main_tb as
(
	   select o.games, r.region, o.medal
	   from OLYMPICS_HISTORY o 
	   inner join OLYMPICS_HISTORY_NOC_REGIONS r
	   on o.noc = r.noc
	   where o.medal in ('Gold', 'Silver','Bronze')
	   	
)
select games, region,
       sum(case when medal = 'Gold' then 1 else 0 end) as Gold,
	   sum(case when medal = 'Silver' then 1 else 0 end) as Silver,
	   sum(case when medal = 'Bronze' then 1 else 0 end) as Bronze 
from Main_tb 
group by games, region
order by games, region;

--16.Identify which country won the most gold, most silver and most bronze medals in each olympic games.

with Main_tb as
(
	SELECT 
			oh.games, ohr.region,oh.medal
	FROM
			OLYMPICS_HISTORY OH
	INNER JOIN
			OLYMPICS_HISTORY_NOC_REGIONS OHR
	ON OH.noc = OHR.noc 
	WHERE 
		oh.medal in ('Gold','Silver','Bronze') and oh.medal <> 'NA'
),
total_sum as
(
	select games,region,
		   sum(case when medal = 'Gold' then 1 else 0 end) as total_gold_by_games,
		   sum(case when medal = 'Silver' then 1 else 0 end) as total_silver_by_games,
		   sum(case when medal = 'Bronze' then 1 else 0 end) as total_bronze_by_games
	from Main_tb 
	group by games, region
	order by games
)
SELECT 
		DISTINCT games,
				 concat(first_value(region) OVER (partition by games order by total_gold_by_games DESC),'-',
					   first_value(total_gold_by_games) OVER(partition by games order by total_gold_by_games DESC)) as max_gold,
				 concat(first_value(region) OVER (partition by games order by total_silver_by_games DESC),'-',
					   first_value(total_silver_by_games) OVER(partition by games order by total_silver_by_games DESC)) as max_silver,
				 concat(first_value(region) OVER (partition by games order by total_bronze_by_games DESC),'-',
					   first_value(total_bronze_by_games) OVER(partition by games order by total_bronze_by_games DESC)) as max_bronze
FROM total_sum
order by games


--17. Identify which country won the most gold, most silver, most bronze medals and the most medals in each olympic games.
with Main_tb as
(
	SELECT 
			oh.games, ohr.region,oh.medal
	FROM
			OLYMPICS_HISTORY OH
	INNER JOIN
			OLYMPICS_HISTORY_NOC_REGIONS OHR
	ON OH.noc = OHR.noc 
	WHERE 
		oh.medal in ('Gold','Silver','Bronze')
),
total_sum as
(
	select games,region,
		   sum(case when medal = 'Gold' then 1 else 0 end) as total_gold_by_games,
		   sum(case when medal = 'Silver' then 1 else 0 end) as total_silver_by_games,
		   sum(case when medal = 'Bronze' then 1 else 0 end) as total_bronze_by_games,
		   sum(case when medal <> 'NA' then 1 else 0 end) as total_medal_by_games
	from Main_tb 
	group by games, region
	order by games
)
SELECT 
		DISTINCT games,
				 concat(first_value(region) OVER (partition by games order by total_gold_by_games DESC),'-',
					   first_value(total_gold_by_games) OVER(partition by games order by total_gold_by_games DESC)) as max_gold,
				 concat(first_value(region) OVER (partition by games order by total_silver_by_games DESC),'-',
					   first_value(total_silver_by_games) OVER(partition by games order by total_silver_by_games DESC)) as max_silver,
				 concat(first_value(region) OVER (partition by games order by total_bronze_by_games DESC),'-',
					   first_value(total_bronze_by_games) OVER(partition by games order by total_bronze_by_games DESC)) as max_bronze,
			     concat(first_value(region) OVER (partition by games order by total_medal_by_games DESC),'-',
					   first_value(total_medal_by_games) OVER(partition by games order by total_medal_by_games DESC)) as max_medals
FROM total_sum
order by games
--18. Which countries have never won gold medal but have won silver/bronze medals?

with Main_tb as
(
	SELECT 
			oh.games, ohr.region,oh.medal
	FROM
			OLYMPICS_HISTORY OH
	INNER JOIN
			OLYMPICS_HISTORY_NOC_REGIONS OHR
	ON OH.noc = OHR.noc 
	WHERE 
		oh.medal in ('Silver','Bronze')
),
total_sum as
(
	select region,
		   sum(case when medal = 'Gold' then 1 else 0 end) as total_gold_by_games,
		   sum(case when medal = 'Silver' then 1 else 0 end) as total_silver_by_games,
		   sum(case when medal = 'Bronze' then 1 else 0 end) as total_bronze_by_games
	from Main_tb 
	group by region
	order by region
)
SELECT * FROM total_sum 

--19. In which Sport/event, India has won highest medals.

with Main_tb as
(
		SELECT 
				oh.sport, ohr.region,oh.medal
		FROM
				OLYMPICS_HISTORY OH
		INNER JOIN
				OLYMPICS_HISTORY_NOC_REGIONS OHR
		ON OH.noc = OHR.noc 
		WHERE 
			oh.medal in ('Gold','Silver','Bronze')
),
total_medals_by_country as
(
	SELECT 
			sport,
			sum(case when medal <> 'NA' then 1 else 0 end) as total_medal_by_games
	FROM Main_tb 
	WHERE region = 'India'
	GROUP BY sport
)

SELECT sport, total_medal_by_games
	  FROM 	total_medals_by_country
	  WHERE total_medal_by_games = (SELECT MAX(total_medal_by_games) FROM total_medals_by_country)
	  
--20 Break down all olympic games where India won medal for Hockey and how many medals in each olympic games
with Main_tb as
(
		SELECT 
				oh.games,oh.sport, ohr.region,oh.medal
		FROM
				OLYMPICS_HISTORY OH
		INNER JOIN
				OLYMPICS_HISTORY_NOC_REGIONS OHR
		ON OH.noc = OHR.noc 
		WHERE 
			oh.medal in ('Gold','Silver','Bronze')
),
total_medals_by_country as
(
	SELECT 
			sport,games,
			sum(case when medal <> 'NA' then 1 else 0 end) as total_medal_by_games
	FROM Main_tb 
	WHERE region = 'India' and sport = 'Hockey'
	GROUP BY sport,games
)
SELECT * FROM total_medals_by_country order by 
total_medal_by_games DESC