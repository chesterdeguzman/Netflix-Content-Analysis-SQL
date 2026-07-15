-- Data-quality checks and reusable cleaned view

-- 1. Confirm row count and unique IDs.
SELECT
    COUNT(*) AS total_rows,
    COUNT(DISTINCT show_id) AS unique_show_ids
FROM netflix_titles;

-- 2. Check duplicate IDs. Expected result: no rows.
SELECT show_id, COUNT(*) AS occurrences
FROM netflix_titles
GROUP BY show_id
HAVING COUNT(*) > 1;

-- 3. Count missing values by column.
SELECT
    COUNT(*) FILTER (WHERE director IS NULL OR TRIM(director) = '') AS missing_director,
    COUNT(*) FILTER (WHERE cast_members IS NULL OR TRIM(cast_members) = '') AS missing_cast,
    COUNT(*) FILTER (WHERE country IS NULL OR TRIM(country) = '') AS missing_country,
    COUNT(*) FILTER (WHERE date_added IS NULL) AS missing_date_added,
    COUNT(*) FILTER (WHERE rating IS NULL OR TRIM(rating) = '') AS missing_rating,
    COUNT(*) FILTER (WHERE duration IS NULL OR TRIM(duration) = '') AS missing_duration
FROM netflix_titles;

-- 4. Validate content types.
SELECT content_type, COUNT(*) AS title_count
FROM netflix_titles
GROUP BY content_type
ORDER BY title_count DESC;

-- 5. Create a cleaned analytical view without overwriting the raw table.
CREATE OR REPLACE VIEW netflix_titles_clean AS
SELECT
    show_id,
    TRIM(content_type) AS content_type,
    TRIM(title) AS title,
    COALESCE(NULLIF(TRIM(director), ''), 'Unknown') AS director,
    COALESCE(NULLIF(TRIM(cast_members), ''), 'Unknown') AS cast_members,
    COALESCE(NULLIF(TRIM(country), ''), 'Unknown') AS country,
    date_added,
    release_year,
    COALESCE(NULLIF(TRIM(rating), ''), 'Not Rated') AS rating,
    COALESCE(NULLIF(TRIM(duration), ''), 'Unknown') AS duration,
    TRIM(listed_in) AS listed_in,
    TRIM(description) AS description,
    EXTRACT(YEAR FROM date_added)::INTEGER AS year_added,
    EXTRACT(MONTH FROM date_added)::INTEGER AS month_added,
    CASE
        WHEN content_type = 'Movie'
        THEN NULLIF(REGEXP_REPLACE(duration, '[^0-9]', '', 'g'), '')::INTEGER
    END AS movie_duration_minutes,
    CASE
        WHEN content_type = 'TV Show'
        THEN NULLIF(REGEXP_REPLACE(duration, '[^0-9]', '', 'g'), '')::INTEGER
    END AS tv_show_seasons
FROM netflix_titles;

-- 6. Optional quality checks against the cleaned view.
SELECT
    MIN(release_year) AS earliest_release_year,
    MAX(release_year) AS latest_release_year,
    MIN(movie_duration_minutes) AS shortest_movie_minutes,
    MAX(movie_duration_minutes) AS longest_movie_minutes,
    MAX(tv_show_seasons) AS maximum_tv_seasons
FROM netflix_titles_clean;
