--17. Identify which country won the most gold, most silver, most bronze medals and the most medals in each olympic games.

with tbl_maxgold as
(
	SELECT  region||'-'||count(medal) as max_gold,games,oh.noc as region_Code,count(medal) as no_of_medal,
	DENSE_RANK() OVER(ORDER BY games) as gold_rank_by_medal,
	ROW_NUMBER() OVER (PARTITION BY games ORDER BY count(medal) DESC) as gold_rank_row_num
	FROM olympics_history oh
	JOIN olympics_history_noc_regions ohr
	ON oh.noc = ohr.noc
	WHERE medal = 'Gold'
	GROUP BY region,games,oh.noc
 	ORDER BY games
),
tbl_maxsilver as
(
	SELECT  region||'-'||count(medal) as max_silver,games,oh.noc as region_Code,count(medal) as no_of_medal,
	DENSE_RANK() OVER(ORDER BY games) as silver_rank_by_medal,
	ROW_NUMBER() OVER (PARTITION BY games ORDER BY count(medal) DESC) as silver_rank_row_num
	FROM olympics_history oh
	JOIN olympics_history_noc_regions ohr
	ON oh.noc = ohr.noc
	WHERE medal = 'Silver'
	GROUP BY region,games,oh.noc
	ORDER BY games
),
tbl_maxbronze as 
(
	SELECT  region||'-'||count(medal) as max_bronze,games,oh.noc as region_Code,count(medal) as no_of_medal,
	DENSE_RANK() OVER(ORDER BY games) as bronze_rank_by_medal,
	ROW_NUMBER() OVER (PARTITION BY games ORDER BY count(medal) DESC) as bronze_rank_row_num
	FROM olympics_history oh
	JOIN olympics_history_noc_regions ohr
	ON oh.noc = ohr.noc
	WHERE medal = 'Bronze'
	GROUP BY region,games,oh.noc
	ORDER BY games
),
tbl_maxmedals as
(
	SELECT  region||'-'||count(medal) as max_medal,games,oh.noc as region_Code,count(medal) as no_of_medal,
	DENSE_RANK() OVER(ORDER BY games) as total_rank_by_medal,
	ROW_NUMBER() OVER (PARTITION BY games ORDER BY count(medal) DESC) as total_medal_rank_row_num
	FROM olympics_history oh
	JOIN olympics_history_noc_regions ohr
	ON oh.noc = ohr.noc
	WHERE medal IN ('Gold','Silver','Bronze')
	GROUP BY region,games,oh.noc
	ORDER BY games 
),
tbl_Combined as
(
	SELECT
        mg.games,
        mg.max_gold as Gold,mg.no_of_medal as gold_medal,
        ms.max_silver as Silver,ms.no_of_medal as silver_medal,
        mb.max_bronze as Bronze,mb.no_of_medal as bronze_medal,
		ma.max_medal as Total,ma.no_of_medal as total_medal
    FROM
        tbl_maxgold mg
    JOIN
        tbl_maxsilver ms ON mg.games = ms.games AND mg.region_Code = ms.region_Code
    JOIN
        tbl_maxbronze mb ON mg.games = mb.games AND mg.region_Code = mb.region_Code
	JOIN
        tbl_maxmedals ma ON mg.games = ma.games AND mg.region_Code = ma.region_Code
	WHERE
		gold_rank_row_num = 1 OR silver_rank_row_num = 1 OR bronze_rank_by_medal = 1 OR total_rank_by_medal = 1
	GROUP BY
		mg.games,mg.max_gold,ms.max_silver,mb.max_bronze,ma.max_medal,mg.no_of_medal,ms.no_of_medal,mb.no_of_medal,ma.no_of_medal
	ORDER BY
		mg.games DESC
		

), 
final_tbl as 
(
	SELECT 
	   games,
	   Gold,ROW_NUMBER() OVER(PARTITION BY games ORDER BY gold_medal DESC) as rank_with_gold_medal,
	   Silver,ROW_NUMBER() OVER(PARTITION BY games ORDER BY silver_medal DESC) as rank_with_silver_medal,
	   Bronze,ROW_NUMBER() OVER(PARTITION BY games ORDER BY bronze_medal DESC) as rank_with_bronze_medal,
	   Total,ROW_NUMBER() OVER(PARTITION BY games ORDER BY total_medal DESC) as rank_with_total_medal
	FROM 
	   tbl_Combined
)
SELECT 
	games,
	(case when rank_with_gold_medal = 1 THEN gold END) as max_gold,
	(case when rank_with_silver_medal = 1 THEN gold END) as max_silver,
	(case when rank_with_bronze_medal = 1 THEN gold END) as max_bronze,
	(case when rank_with_bronze_medal = 1 THEN gold END) as total_medal
FROM 
	final_tbl
ORDER BY
	games
--WHERE gold  IS NOT NULL












