-- Compact queries that reproduce the headline portfolio findings.

-- Finding 1: Movies dominate the catalog.
SELECT content_type, COUNT(*) AS title_count
FROM netflix_titles_clean
GROUP BY content_type
ORDER BY title_count DESC;

-- Finding 2: The United States contributes the largest number of titles.
WITH countries AS (
    SELECT TRIM(value) AS country_name
    FROM netflix_titles_clean
    CROSS JOIN LATERAL REGEXP_SPLIT_TO_TABLE(country, '\s*,\s*') AS value
    WHERE country <> 'Unknown'
)
SELECT country_name, COUNT(*) AS title_count
FROM countries
GROUP BY country_name
ORDER BY title_count DESC
LIMIT 10;

-- Finding 3: Catalog additions peaked in 2019.
SELECT year_added, COUNT(*) AS titles_added
FROM netflix_titles_clean
WHERE year_added IS NOT NULL
GROUP BY year_added
ORDER BY titles_added DESC
LIMIT 5;

-- Finding 4: TV-MA is the most common rating.
SELECT rating, COUNT(*) AS title_count
FROM netflix_titles_clean
GROUP BY rating
ORDER BY title_count DESC
LIMIT 10;

-- Finding 5: International Movies and Dramas are leading categories.
WITH genres AS (
    SELECT TRIM(value) AS genre_name
    FROM netflix_titles_clean
    CROSS JOIN LATERAL REGEXP_SPLIT_TO_TABLE(listed_in, '\s*,\s*') AS value
)
SELECT genre_name, COUNT(*) AS title_count
FROM genres
GROUP BY genre_name
ORDER BY title_count DESC
LIMIT 10;

-- Finding 6: The median movie duration is approximately 98 minutes.
SELECT
    ROUND(AVG(movie_duration_minutes), 2) AS average_minutes,
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY movie_duration_minutes) AS median_minutes
FROM netflix_titles_clean
WHERE content_type = 'Movie';
