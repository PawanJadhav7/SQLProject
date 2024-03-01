
select count(*) from OLYMPICS_HISTORY;

--1. how many olympics games held so far
SELECT count(distinct games) as total_lympic_games
FROM OLYMPICS_HISTORY

--2.List down all Olympics games held so far
SELECT year, season, city 
FROM OLYMPICS_HISTORY
GROUP BY season,year,city
order by year

--3. Mention the total no of nations who participated in each olympics game?
WITH all_countries as 
(
	select games, region
	from OLYMPICS_HISTORY oh
	join OLYMPICS_HISTORY_NOC_REGIONS nr on nr.noc = oh.noc
	group by games, nr.region
)
SELECT  games, count(1) as total_countries
FROM all_countries
GROUP BY games
ORDER BY games

--4. Which year saw the highest and lowest no of countries participating in olympics
WITH participating_countries as
(
	select games, region
	from OLYMPICS_HISTORY oh
	join OLYMPICS_HISTORY_NOC_REGIONS nr on nr.noc = oh.noc
	group by games, nr.region
),
tot_countries as 
(
	SELECT games, count(1) as total_countries 	
	FROM participating_countries
	GROUP BY games
	ORDER BY total_countries
)
SELECT DISTINCT
	concat(first_value(games) over(order by total_countries), '-', 
		  	first_value(total_countries) over(order by total_countries)) as Lowest_Countries,
			
	concat(first_value(games) over(order by total_countries DESC), '-',
		  	first_value(total_countries) over(order by total_countries DESC)) as Highest_Countries
FROM tot_countries

--5. Which nation has participated in all of the olympic games

WITH tot_games as
(
	SELECT COUNT(DISTINCT(games)) as total_games
	FROM OLYMPICS_HISTORY
),
countries as
(
	SELECT  games, nr.region as country
    FROM olympics_history oh
    JOIN olympics_history_noc_regions nr ON nr.noc=oh.noc
    GROUP BY games, nr.region 
),
countries_participated as
(
	SELECT country, count(1) as total_participated_games
	FROM countries
	GROUP BY country
)
SELECT 
		cp.*
FROM
		countries_participated cp
JOIN
		tot_games tg on tg.total_games = cp.total_participated_games
ORDER BY 
		1













-- DROP TABLE IF EXISTS OLYMPICS_HISTORY;
-- CREATE TABLE IF NOT EXISTS OLYMPICS_HISTORY
-- (
-- 	id INT,
-- 	name VARCHAR,
-- 	sex VARCHAR,
-- 	age VARCHAR,
-- 	height VARCHAR,
-- 	weight VARCHAR,
-- 	team VARCHAR,
-- 	noc VARCHAR,
-- 	games VARCHAR,
-- 	year INT,
-- 	season VARCHAR,
-- 	city VARCHAR,
-- 	sport VARCHAR,
-- 	event VARCHAR,
-- 	medal VARCHAR
	
-- )
--SELECT * FROM OLYMPICS_HISTORY;
--SELECT * FROM OLYMPICS_HISTORY_NOC_REGIONS;
-- DROP TABLE IF EXISTS OLYMPICS_HISTORY_NOC_REGIONS;
-- CREATE TABLE IF NOT EXISTS OLYMPICS_HISTORY_NOC_REGIONS
-- (
-- 	noc VARCHAR,
-- 	region VARCHAR,
-- 	notes VARCHAR
-- )