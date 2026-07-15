-- Netflix Content Analysis
-- PostgreSQL table definition

DROP TABLE IF EXISTS netflix_titles;

CREATE TABLE netflix_titles (
    show_id       VARCHAR(10) PRIMARY KEY,
    content_type  VARCHAR(20) NOT NULL,
    title         TEXT NOT NULL,
    director      TEXT,
    cast_members  TEXT,
    country       TEXT,
    date_added    DATE,
    release_year  INTEGER NOT NULL,
    rating        VARCHAR(20),
    duration      VARCHAR(30),
    listed_in     TEXT NOT NULL,
    description   TEXT NOT NULL
);

-- After creating the table, import data with psql's \copy command.
-- Replace the path with the absolute path on your computer.
--
-- \copy netflix_titles(show_id, content_type, title, director, cast_members, country, date_added, release_year, rating, duration, listed_in, description)
-- FROM PROGRAM 'python -c "import pandas as pd; d=pd.read_csv('"'"'data/netflix_titles.csv'"'"'); d['"'"'date_added'"'"']=pd.to_datetime(d['"'"'date_added'"'"'].str.strip(),errors='"'"'coerce'"'"').dt.strftime('"'"'%Y-%m-%d'"'"'); d.to_csv('"'"'/dev/stdout'"'"',index=False)"'
-- WITH (FORMAT csv, HEADER true, NULL '');

CREATE INDEX idx_netflix_content_type ON netflix_titles(content_type);
CREATE INDEX idx_netflix_release_year ON netflix_titles(release_year);
CREATE INDEX idx_netflix_date_added ON netflix_titles(date_added);
CREATE INDEX idx_netflix_rating ON netflix_titles(rating);
