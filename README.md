# Netflix Content Analysis Using SQL

![PostgreSQL](https://img.shields.io/badge/PostgreSQL-14%2B-336791)
![SQL](https://img.shields.io/badge/SQL-Data%20Analysis-orange)
![Status](https://img.shields.io/badge/Status-Complete-brightgreen)

## Project overview

This standalone SQL portfolio project analyzes **8,807 Netflix titles** using PostgreSQL. It demonstrates database setup, data-quality validation, reusable views, common table expressions, window functions, conditional aggregation, string normalization, ranking, and percentile calculations.

## Business questions

- What percentage of the catalog consists of movies versus TV shows?
- Which countries contribute the most titles?
- How has the number of titles added changed over time?
- Which ratings, genres, directors, and cast members appear most frequently?
- What are the typical movie runtimes and TV-show season counts?
- How long after release are titles generally added to Netflix?

## Key findings

- The dataset contains **8,807 titles**: 6,131 movies and 2,676 TV shows.
- Movies represent approximately **69.6%** of the catalog.
- The **United States** is the leading contributing country.
- Catalog additions peaked in **2019**, with 2,016 titles added.
- **TV-MA** is the most common maturity rating.
- The median movie runtime is approximately **98 minutes**.

## Repository structure

```text
Netflix-SQL-Analysis/
├── data/
│   ├── netflix_titles.csv
│   └── README.md
├── sql/
│   ├── 01_create_table.sql
│   ├── 02_data_cleaning.sql
│   ├── 03_analysis_queries.sql
│   └── 04_portfolio_findings.sql
├── .gitignore
├── LICENSE
└── README.md
```

## SQL skills demonstrated

- PostgreSQL table creation and indexing
- Data profiling and missing-value checks
- Clean analytical views
- CTEs and window functions
- Conditional aggregation and `FILTER`
- Lateral joins and regular-expression splitting
- Ranking and top-N analysis
- Date extraction and trend analysis
- Median and percentile calculations
- Normalization of multi-value text fields

## How to run

### 1. Create the database

```sql
CREATE DATABASE netflix_analysis;
```

Connect to the database using pgAdmin or `psql`.

### 2. Create the table

Run:

```text
sql/01_create_table.sql
```

### 3. Import the dataset

The original CSV stores dates in a format such as `September 25, 2021`. In pgAdmin, import the CSV into a temporary table or convert the date values to `YYYY-MM-DD` before loading them into the final table.

A practical Python conversion command is:

```bash
python -c "import pandas as pd; d=pd.read_csv('data/netflix_titles.csv'); d['date_added']=pd.to_datetime(d['date_added'].str.strip(), errors='coerce').dt.strftime('%Y-%m-%d'); d=d.rename(columns={'type':'content_type','cast':'cast_members'}); d.to_csv('data/netflix_titles_postgres.csv', index=False)"
```

Then import `data/netflix_titles_postgres.csv` into `netflix_titles` using pgAdmin, or run this command from `psql` after replacing the path:

```sql
\copy netflix_titles(show_id, content_type, title, director, cast_members, country, date_added, release_year, rating, duration, listed_in, description)
FROM '/absolute/path/to/data/netflix_titles_postgres.csv'
WITH (FORMAT csv, HEADER true, NULL '');
```

### 4. Clean and validate the data

Run:

```text
sql/02_data_cleaning.sql
```

This creates the reusable `netflix_titles_clean` view while preserving the raw table.

### 5. Run the analysis

Run individual queries from:

```text
sql/03_analysis_queries.sql
```

For the headline portfolio findings, run:

```text
sql/04_portfolio_findings.sql
```

## Portfolio summary

> Analyzed 8,807 Netflix titles with PostgreSQL. Created a reusable analytical view, validated data quality, normalized multi-value country, genre, director, and cast fields, and applied CTEs, window functions, lateral joins, conditional aggregation, and percentile calculations to identify catalog composition, geographic concentration, content trends, ratings, and runtime patterns.

## Dataset note

The repository contains the provided `netflix_titles.csv` dataset for reproducibility. Confirm the original source and license before redistributing it publicly.
