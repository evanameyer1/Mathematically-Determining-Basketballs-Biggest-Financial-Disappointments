-- first attempt at calculating scores --

select
	sub.player,
	sub.uuid,
	sub.og_score,
	(NTILE(200) OVER (ORDER BY sub.og_score asc) - 100) as adjusted_score,
	--sub.salary_perc,
	sub.salary
	from (
		select 
			stat."Player" as player,
			stat."UUID" as uuid,
			((("Rpm" * "Wins") / ("Gp" * "Mpg")) * 1000)::Decimal(6,3) as og_score,
			"Salary" as salary
			from stats_2000 stat
			join salaries_2000 sal
				using("UUID")
	)sub	
	order by 4 desc

-- calculating relative production over salary to define player worth -- 

select 
	sub.player, 
	sub.uuid,
	sub.production,
	sub.salary,
	case when sub.relative_production = 0 then 0 else (sub.salary / sub.production) end,
	case when sub.relative_production = 0 then 0 else (sub.relative_salary / sub.relative_production) end as cost_per_output
	from(
		with t1 as (
		select 
			avg("Salary") as salary,
			avg((("Rpm" * "Wins") / ("Gp" * "Mpg")) * 1000)::Decimal(6,3) as og_score
			from salaries_2000
			join stats_2000
				using("UUID")
		),

		t2 as (
		select 
			sal."Player",
			"UUID",
			"Salary",
			"Year",
			"Pos",
			"Team",
			"Gp",
			"Mpg",
			"Orpm",
			"Drpm",
			"Rpm",
			"Wins"
			from salaries_2000 sal
			left join stats_2000 stat
				using("UUID")
		)

		select
			t2."Player" as player,
			t2."UUID" as uuid,
			t2."Salary" as salary,
			t1."salary" as average_salary,
			(t2."Salary" / t1.salary) * 100 as relative_salary,
			t1.og_score,
			((("Rpm" * "Wins") / ("Gp" * "Mpg")) * 1000) as production, 
			(((("Rpm" * "Wins") / ("Gp" * "Mpg")) * 1000) / t1.og_score) * 100 as relative_production
			from t1, t2
			order by 7 desc
	) sub
	where sub.production IS NOT NULL
	order by 5 desc
	
-- redoing player worth after realizing the "wins" column already accounts for possessions played --

select 
	sub.player, 
	sub.uuid,
	sub.wins,
	sub.salary,
	case when sub.relative_contributions = 0 then 0 else (sub.relative_salary / sub.relative_contributions) end as cost_per_output
	from(
		with t1 as (
		select 
			avg("Salary") as avg_salary,
			avg("Wins")::Decimal(6,3) as avg_wins
			from salaries_2000
			join stats_2000
				using("UUID")
		),

		t2 as (
		select 
			sal."Player",
			"UUID",
			"Salary",
			"Year",
			"Pos",
			"Team",
			"Wins"
			from salaries_2000 sal
			left join stats_2000 stat
				using("UUID")
		)

		select
			t2."Player" as player,
			t2."UUID" as uuid,
			t2."Salary" as salary,
			t1.avg_salary,
			(t2."Salary" / t1.avg_salary) * 100 as relative_salary,
			t1.avg_wins,
			t2."Wins" as wins, 
			(t2."Wins" / t1.avg_wins) * 100 as relative_contributions
			from t1, t2
			order by 7 desc
	) sub
	where sub.wins IS NOT NULL
	order by 5 desc