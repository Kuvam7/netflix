# Netflix Project

 ![Netflix logo](https://github.com/Kuvam7/netflix/blob/main/BrandAssets_Logos_01-Wordmark.jpg)

## Overview
This project involves a comprehensive analysis of Netflix's movies and TV shows data using SQL. The goal is to extract valuable insights and answer various business questions based on the dataset. The following README provides a detailed account of the project's objectives, business problems, solutions, findings, and conclusions.

## Objectives

- Analyze the distribution of content types (movies vs TV shows).
- Identify the most common ratings for movies and TV shows.
- List and analyze content based on release years, countries, and durations.
- Explore and categorize content based on specific criteria and keywords.

## Dataset

The data for this project is sourced from the Kaggle dataset:

- **Dataset Link:** [Movies Dataset](https://www.kaggle.com/datasets/shivamb/netflix-shows?resource=download)

## Schema

```sql
DROP TABLE IF EXISTS netflix;
CREATE TABLE netflix
(
    show_id      VARCHAR(5),
    type         VARCHAR(10),
    title        VARCHAR(250),
    director     VARCHAR(550),
    casts        VARCHAR(1050),
    country      VARCHAR(550),
    date_added   VARCHAR(55),
    release_year INT,
    rating       VARCHAR(15),
    duration     VARCHAR(15),
    listed_in    VARCHAR(250),
    description  VARCHAR(550)
);
```

## Business Problems and Solutions

### 1. Count the Number of Movies vs TV Shows

```sql
SELECT
	type,
	COUNT(1)
FROM netflix
GROUP BY type;
```

**Objective:** Determine the distribution of content types on Netflix.

### 2. Find the Most Common Rating for Movies and TV Shows

```sql
SELECT
	type,
	rating
FROM 
	(SELECT
		type,
		rating,
		COUNT(*),
		RANK() OVER(PARTITION BY type ORDER BY COUNT(*) DESC) rank
	FROM
		netflix
	GROUP BY type,rating) as t
WHERE rank = 1;
```

**Objective:** Identify the most frequently occurring rating for each type of content.

### 3. List All Movies Released in a Specific Year (e.g., 2020)

```sql
SELECT
	title,
	release_year
FROM 
	netflix
WHERE
	release_year = 2020;
```

**Objective:** Retrieve all movies released in a specific year.

### 4. Find the Top 5 Countries with the Most Content on Netflix

```sql
SELECT
	TRIM(UNNEST(STRING_TO_ARRAY(country,','))) new_country,
	COUNT(show_id) as content_count
FROM
	netflix
WHERE
	country is not null
GROUP BY
	new_country
ORDER BY
	content_count DESC
LIMIT 5;
```

**Objective:** Identify the top 5 countries with the highest number of content items.

### 5. Identify the Longest Movie

```sql
SELECT
	title,
	duration,
	CAST(SPLIT_PART(duration,' ',1) AS INT) AS min
FROM netflix
WHERE type = 'Movie' AND SPLIT_PART(duration,' ',1) is not null
ORDER BY min DESC
LIMIT 1;
```

**Objective:** Find the movie with the longest duration.

### 6. Find Content Added in the Last 5 Years

```sql
SELECT 
	EXTRACT(YEAR FROM TO_DATE(REPLACE(date_added, ',', ''), 'Month DD YYYY')) as release_year,
	*
FROM netflix
WHERE TO_DATE(REPLACE(date_added, ',', ''), 'Month DD YYYY') >= CURRENT_DATE - INTERVAL '5 years'
ORDER BY EXTRACT(YEAR FROM TO_DATE(REPLACE(date_added, ',', ''), 'Month DD YYYY'));
```

**Objective:** Retrieve content added to Netflix in the last 5 years.

### 7. Find All Movies/TV Shows by Director 'Rajiv Chilaka'

```sql
SELECT * FROM netflix
WHERE director ILIKE '%Rajiv Chilaka%';
```

**Objective:** List all content directed by 'Rajiv Chilaka'.

### 8. List All TV Shows with More Than 5 Seasons

```sql
SELECT
	duration,
	*
FROM netflix
WHERE type = 'TV Show' AND SPLIT_PART(duration,' ',1):: INT > 5;
```

**Objective:** Identify TV shows with more than 5 seasons.

### 9. Count the Number of Content Items in Each Genre

```sql
SELECT 
	TRIM(UNNEST(STRING_TO_ARRAY(genre,','))) as Gen,
	COUNT(*)
FROM netflix
GROUP BY Gen
ORDER BY 2 DESC;
```

**Objective:** Count the number of content items in each genre.

### 10.Find each year and the average numbers of content release in India on netflix. 
return top 5 year with highest avg content release!

```sql
SELECT
	EXTRACT(YEAR FROM TO_DATE(date_added, 'Month DD, YYYY')) as year,
	COUNT(*) as content_per_year,
	ROUND(COUNT(*)::numeric/(SELECT COUNT(*) FROM netflix WHERE country ILIKE '%India%')*100,2)::numeric as yearly_content_release_proportion
FROM
	netflix
WHERE 
	country ILIKE 'India'
GROUP BY
	year
ORDER BY
	3 DESC
LIMIT 5;
```

**Objective:** Calculate and rank years by the average number of content releases by India.

### 11. List All Movies that are Documentaries

```sql
SELECT *
FROM netflix
WHERE genre ILIKE '%Documentaries%' AND type = 'Movie';
```

**Objective:** Retrieve all movies classified as documentaries.

### 12. Find All Content Without a Director

```sql
SELECT *
FROM netflix
WHERE director ISNULL;
```

**Objective:** List content that does not have a director.

### 13. Find How Many Movies Actor 'Salman Khan' Appeared in the Last 10 Years

```sql
SELECT *
FROM netflix
WHERE casts ILIKE '%Salman Khan%' 
	AND release_year > (EXTRACT(YEAR FROM CURRENT_DATE))-10;
```

**Objective:** Count the number of movies featuring 'Salman Khan' in the last 10 years.

### 14. Find the Top 10 Actors Who Have Appeared in the Highest Number of Movies Produced in India

```sql
SELECT
	TRIM(UNNEST(STRING_TO_ARRAY(casts,','))) as actors,
	COUNT(*) as count_india_movies
FROM netflix
WHERE country ILIKE '%India%'
GROUP BY actors
ORDER BY count_india_movies DESC
LIMIT 10;
```

**Objective:** Identify the top 10 actors with the most appearances in Indian-produced movies.

### 15. Categorize Content Based on the Presence of 'Kill' and 'Violence' Keywords

```sql
SELECT 
	CASE
		WHEN
			description ILIKE '%kill%' OR description ILIKE '%violence%' 
		THEN
			'Bad'
		ELSE
			'Good'
	END as category,
	COUNT(*)
FROM netflix
GROUP BY category;
```

**Objective:** Categorize content as 'Bad' if it contains 'kill' or 'violence' and 'Good' otherwise. Count the number of items in each category.
