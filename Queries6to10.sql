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