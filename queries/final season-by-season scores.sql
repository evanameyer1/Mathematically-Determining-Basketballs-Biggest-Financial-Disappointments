-- normalize scores --
UPDATE player_scores
SET production_score = ((production_score - min_score) / (max_score - min_score))::decimal(5,4)
FROM (SELECT MIN(production_score) AS min_score, MAX(production_score) AS max_score FROM player_scores) AS sub;

-- join the two tables together --
drop table final_seasons_scores
create table final_seasons_scores as (
select
	season.*,
	play.salary,
	play.percent_of_team,
	play.wins_contributed,
	play.production_score
	from player_scores as play
	join season_totals as season
		on play.uuid = season.uuid and play.year = season.year
)