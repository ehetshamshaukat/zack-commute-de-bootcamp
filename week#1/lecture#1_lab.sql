create type seasons_stats as(
    season INT,
    gp INT,
    pts REAL,
    reb REAL,
    ast REAL
)

CREATE TYPE scoring_class AS ENUM('Star','Good','Average','Bad')

drop table players

CREATE TABLE players(
    player_name TEXT,
    height TEXT,
    college TEXT,
    country TEXT,
    draft_year TEXT,
    season_detail seasons_stats[],
    scoring scoring_class,
    years_since_last_season INT,
    current_season INT,
    is_active BOOLEAN,
    primary key (player_name,current_season)
);


insert into players
with yesterday as (
    select * from players where current_season=2021
),
    today as (
        select * from player_seasons where season=2022
)
select coalesce(yesterday.player_name,today.player_name) as player_name,
       coalesce(yesterday.height,today.height) as height,
       coalesce(yesterday.college,today.college) as college,
       coalesce(yesterday.country,today.country) as country,
       coalesce(yesterday.draft_year,today.draft_year) as draft_year,
       case
           when yesterday.season_detail is null then array[row(today.season,today.gp,today.pts,today.reb,today.ast)::seasons_stats]
           when today.season is not null then yesterday.season_detail || array[row(today.season,today.gp,today.pts,today.reb,today.ast)::seasons_stats]
           else yesterday.season_detail
           end as season_detail,
       case
           when today.season is not null then
            case
                when today.pts  > 20 then 'Star'
                when today.pts > 15 then 'Good'
                when today.pts > 10 then 'Average'
                else 'Bad'
            END::scoring_class
           ELSE yesterday.scoring
       END as scoring_class,
       case
           when today.season is not null then 0
           else yesterday.years_since_last_season + 1 end  years_since_last_season,
       coalesce(today.season, yesterday.current_season+1) as current_season,
       case when yesterday.years_since_last_season=0 then true
            else false
       end as is_active
from yesterday
    full outer join today
        on yesterday.player_name=today.player_name



select * from players

select * from players where current_season = '2022'
