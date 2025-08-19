## Create Struct
```
create type seasons_stats as(
    season INT,
    gp INT,
    pts REAL,
    reb REAL,
    ast REAL
)

CREATE TYPE scoring_class AS ENUM('Star','Good','Average','Bad')
```
## DDL For Player Table 
```
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
```
## Cummulative Table Design

```
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
```
## Image 
```
select * from players where current_season = '2022'

```
<img width="1512" height="982" alt="Screenshot 2025-08-19 at 2 50 13 PM" src="https://github.com/user-attachments/assets/ae36e1c7-6c41-4ea9-9186-24405dc7a26f" />
