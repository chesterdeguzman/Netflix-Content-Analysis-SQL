# Data

`netflix_titles.csv` is the original source file used for the SQL analysis.

The SQL schema renames two columns during import:

- `type` becomes `content_type`
- `cast` becomes `cast_members`

The `date_added` field should be converted from values such as `September 25, 2021` to PostgreSQL's `YYYY-MM-DD` date format before import.
