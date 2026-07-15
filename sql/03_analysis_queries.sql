-- Netflix Content Analysis: portfolio-ready PostgreSQL queries

-- 1. Movies versus TV shows
SELECT
    content_type,
    COUNT(*) AS title_count,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS percentage_of_catalog
FROM netflix_titles_clean
GROUP BY content_type
ORDER BY title_count DESC;

-- 2. Titles released by year
SELECT release_year, COUNT(*) AS title_count
FROM netflix_titles_clean
GROUP BY release_year
ORDER BY release_year;

-- 3. Titles added to Netflix by year
SELECT year_added, COUNT(*) AS titles_added
FROM netflix_titles_clean
WHERE year_added IS NOT NULL
GROUP BY year_added
ORDER BY year_added;

-- 4. Peak catalog-addition year
SELECT year_added, COUNT(*) AS titles_added
FROM netflix_titles_clean
WHERE year_added IS NOT NULL
GROUP BY year_added
ORDER BY titles_added DESC
LIMIT 1;

-- 5. Top ratings
SELECT
    rating,
    COUNT(*) AS title_count,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2) AS catalog_percentage
FROM netflix_titles_clean
GROUP BY rating
ORDER BY title_count DESC
LIMIT 10;

-- 6. Top countries, counting international co-productions in every listed country
WITH country_split AS (
    SELECT
        show_id,
        TRIM(country_name) AS country_name
    FROM netflix_titles_clean
    CROSS JOIN LATERAL REGEXP_SPLIT_TO_TABLE(country, '\s*,\s*') AS country_name
    WHERE country <> 'Unknown'
)
SELECT country_name, COUNT(*) AS title_count
FROM country_split
GROUP BY country_name
ORDER BY title_count DESC, country_name
LIMIT 10;

-- 7. Content-type mix for the top countries
WITH country_split AS (
    SELECT
        show_id,
        content_type,
        TRIM(country_name) AS country_name
    FROM netflix_titles_clean
    CROSS JOIN LATERAL REGEXP_SPLIT_TO_TABLE(country, '\s*,\s*') AS country_name
    WHERE country <> 'Unknown'
),
top_countries AS (
    SELECT country_name
    FROM country_split
    GROUP BY country_name
    ORDER BY COUNT(*) DESC
    LIMIT 10
)
SELECT
    cs.country_name,
    cs.content_type,
    COUNT(*) AS title_count
FROM country_split cs
JOIN top_countries tc USING (country_name)
GROUP BY cs.country_name, cs.content_type
ORDER BY cs.country_name, title_count DESC;

-- 8. Most common genres/categories
WITH genre_split AS (
    SELECT
        show_id,
        content_type,
        TRIM(genre_name) AS genre_name
    FROM netflix_titles_clean
    CROSS JOIN LATERAL REGEXP_SPLIT_TO_TABLE(listed_in, '\s*,\s*') AS genre_name
)
SELECT genre_name, COUNT(*) AS title_count
FROM genre_split
GROUP BY genre_name
ORDER BY title_count DESC, genre_name
LIMIT 15;

-- 9. Most common genres by content type
WITH genre_split AS (
    SELECT
        show_id,
        content_type,
        TRIM(genre_name) AS genre_name
    FROM netflix_titles_clean
    CROSS JOIN LATERAL REGEXP_SPLIT_TO_TABLE(listed_in, '\s*,\s*') AS genre_name
),
ranked AS (
    SELECT
        content_type,
        genre_name,
        COUNT(*) AS title_count,
        DENSE_RANK() OVER (
            PARTITION BY content_type
            ORDER BY COUNT(*) DESC
        ) AS genre_rank
    FROM genre_split
    GROUP BY content_type, genre_name
)
SELECT content_type, genre_name, title_count
FROM ranked
WHERE genre_rank <= 10
ORDER BY content_type, genre_rank, genre_name;

-- 10. Movie-duration summary
SELECT
    COUNT(movie_duration_minutes) AS movies_with_duration,
    ROUND(AVG(movie_duration_minutes), 2) AS average_minutes,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY movie_duration_minutes) AS median_minutes,
    MIN(movie_duration_minutes) AS shortest_minutes,
    MAX(movie_duration_minutes) AS longest_minutes
FROM netflix_titles_clean
WHERE content_type = 'Movie';

-- 11. Movie-duration bands
SELECT
    CASE
        WHEN movie_duration_minutes < 60 THEN 'Under 60 minutes'
        WHEN movie_duration_minutes < 90 THEN '60-89 minutes'
        WHEN movie_duration_minutes < 120 THEN '90-119 minutes'
        WHEN movie_duration_minutes < 150 THEN '120-149 minutes'
        ELSE '150+ minutes'
    END AS duration_band,
    COUNT(*) AS movie_count
FROM netflix_titles_clean
WHERE content_type = 'Movie'
  AND movie_duration_minutes IS NOT NULL
GROUP BY duration_band
ORDER BY MIN(movie_duration_minutes);

-- 12. TV-show season distribution
SELECT
    tv_show_seasons,
    COUNT(*) AS show_count
FROM netflix_titles_clean
WHERE content_type = 'TV Show'
  AND tv_show_seasons IS NOT NULL
GROUP BY tv_show_seasons
ORDER BY tv_show_seasons;

-- 13. Top directors
WITH director_split AS (
    SELECT
        show_id,
        TRIM(director_name) AS director_name
    FROM netflix_titles_clean
    CROSS JOIN LATERAL REGEXP_SPLIT_TO_TABLE(director, '\s*,\s*') AS director_name
    WHERE director <> 'Unknown'
)
SELECT director_name, COUNT(*) AS title_count
FROM director_split
GROUP BY director_name
ORDER BY title_count DESC, director_name
LIMIT 15;

-- 14. Most frequently credited cast members
WITH cast_split AS (
    SELECT
        show_id,
        TRIM(actor_name) AS actor_name
    FROM netflix_titles_clean
    CROSS JOIN LATERAL REGEXP_SPLIT_TO_TABLE(cast_members, '\s*,\s*') AS actor_name
    WHERE cast_members <> 'Unknown'
)
SELECT actor_name, COUNT(*) AS title_count
FROM cast_split
GROUP BY actor_name
ORDER BY title_count DESC, actor_name
LIMIT 15;

-- 15. Average delay between release and Netflix addition
SELECT
    content_type,
    ROUND(AVG(year_added - release_year), 2) AS average_years_to_add,
    PERCENTILE_CONT(0.5) WITHIN GROUP (
        ORDER BY year_added - release_year
    ) AS median_years_to_add
FROM netflix_titles_clean
WHERE year_added IS NOT NULL
  AND year_added >= release_year
GROUP BY content_type
ORDER BY content_type;

-- 16. Titles added in the same year they were released
SELECT
    content_type,
    COUNT(*) AS same_year_titles,
    ROUND(
        100.0 * COUNT(*) /
        SUM(COUNT(*)) OVER (PARTITION BY content_type),
        2
    ) AS percentage_within_same_year_subset
FROM netflix_titles_clean
WHERE year_added = release_year
GROUP BY content_type;

-- 17. Monthly addition pattern
SELECT
    month_added,
    TO_CHAR(MAKE_DATE(2000, month_added, 1), 'Month') AS month_name,
    COUNT(*) AS titles_added
FROM netflix_titles_clean
WHERE month_added IS NOT NULL
GROUP BY month_added
ORDER BY month_added;

-- 18. Recent releases by country
WITH country_split AS (
    SELECT
        n.show_id,
        n.title,
        n.content_type,
        n.release_year,
        TRIM(country_name) AS country_name
    FROM netflix_titles_clean n
    CROSS JOIN LATERAL REGEXP_SPLIT_TO_TABLE(n.country, '\s*,\s*') AS country_name
    WHERE n.country <> 'Unknown'
)
SELECT country_name, COUNT(*) AS recent_title_count
FROM country_split
WHERE release_year >= 2018
GROUP BY country_name
ORDER BY recent_title_count DESC
LIMIT 10;

-- 19. Search titles and descriptions for a theme
SELECT
    title,
    content_type,
    release_year,
    listed_in
FROM netflix_titles_clean
WHERE title ILIKE '%love%'
   OR description ILIKE '%love%'
ORDER BY release_year DESC, title;

-- 20. Catalog age by content type
SELECT
    content_type,
    ROUND(AVG(2021 - release_year), 2) AS average_catalog_age_as_of_2021,
    MIN(release_year) AS earliest_release,
    MAX(release_year) AS latest_release
FROM netflix_titles_clean
GROUP BY content_type;
