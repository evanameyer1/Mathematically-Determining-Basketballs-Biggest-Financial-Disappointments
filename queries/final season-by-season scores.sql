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
	play.production_score,
	(case when play.pos is null then season.pos else play.pos end) as position
	from player_scores as play
	join season_totals as season
		on play.uuid = season.uuid and play.year = season.year
	where salary != 26238422
)

drop table player_scores
drop table season_totals

drop table clean_final_scores
create table clean_final_scores as (
select row_number() over (order by production_score desc) as bad_rank, row_number() over (order by production_score asc) as good_rank, *
from final_seasons_scores
)

select * from final_seasons_scores where year = 2021 and player = 'Kemba Walker'

select * from season_totals_1996 order by pts desc
