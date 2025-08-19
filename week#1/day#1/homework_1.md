## creating struct 
```
create type films_info as (
    film_id text,
    films_name text,
    rating real,
    votes int
)

create type ratings as enum('star','good','average','bad')
```

## DDL For actor Table 
```
create table actors(
    actor_id text,
    actor_name text,
    films films_info[],
    film_rate_status text,
    is_active boolean,
    current_year int,
    primary key (actor_id,current_year)
);
```
## Cummulative Table Design

```
INSERT INTO actors
WITH yesterday AS (
    SELECT *
    FROM actors
    WHERE current_year = 1974
),
today AS (
    SELECT actorid, actor, year,
           array_agg(row(filmid, film, rating, votes)::films_info) AS films ,avg(rating) as avg_rating_per_year
    FROM actor_films
    WHERE year = 1975
    GROUP BY actor, actorid, year
)

SELECT
    COALESCE(y.actor_id,t.actorid),
    COALESCE(y.actor_name,t.actor),
    CASE
        WHEN y.actor_id IS NULL AND y.films IS NULL THEN t.films
        WHEN t.actorid IS NOT NULL THEN y.films || t.films
        ELSE y.films
    END AS films,
    CASE
        WHEN t.avg_rating_per_year > 8 THEN 'star'
        WHEN t.avg_rating_per_year > 7 THEN 'good'
        WHEN t.avg_rating_per_year > 6 THEN 'average'
        ELSE 'bad'
    END::rating,
    case when t.year is not null then true
        else false
    end as  is_active,
    COALESCE(t.year,y.current_year+1) AS current_year
FROM yesterday y
FULL OUTER JOIN today t
    ON y.actor_id = t.actorid
```
## Image 
```
select * from actors
where current_year = '1975'

```
<img width="1512" height="982" alt="Screenshot 2025-08-19 at 2 33 30 PM" src="https://github.com/user-attachments/assets/9e3ffc35-cf86-4b9c-9162-1edfc5e43d81" />

