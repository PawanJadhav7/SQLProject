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



