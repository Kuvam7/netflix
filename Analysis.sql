-- Netflix Data Analysis

-- Initial Inspection

SELECT *
FROM netflix;

-- Tasks - 

-- 1. Count the number of Movies vs TV Shows

SELECT
	type,
	COUNT(1)
FROM netflix
GROUP BY type;

-- 2. Find the most common rating for movies and TV shows

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


-- 3. List all movies released in a specific year (e.g., 2020)

SELECT
	title,
	release_year
FROM 
	netflix
WHERE
	release_year = 2020;


-- 4. Find the top 5 countries with the most content on Netflix

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

-- 5. Identify the longest movie

SELECT
	title,
	duration,
	CAST(SPLIT_PART(duration,' ',1) AS INT) AS min
FROM netflix
WHERE type = 'Movie' AND SPLIT_PART(duration,' ',1) is not null
ORDER BY min DESC
LIMIT 1;


-- 6. Find content added in the last 5 years

SELECT 
	EXTRACT(YEAR FROM TO_DATE(REPLACE(date_added, ',', ''), 'Month DD YYYY')) as release_year,
	*
FROM netflix
WHERE TO_DATE(REPLACE(date_added, ',', ''), 'Month DD YYYY') >= CURRENT_DATE - INTERVAL '5 years'
ORDER BY EXTRACT(YEAR FROM TO_DATE(REPLACE(date_added, ',', ''), 'Month DD YYYY'));


-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'!

SELECT * FROM netflix
WHERE director ILIKE '%Rajiv Chilaka%';

-- 8. List all TV shows with more than 5 seasons

SELECT
	duration,
	*
FROM netflix
WHERE type = 'TV Show' AND SPLIT_PART(duration,' ',1):: INT > 5;


-- 9. Count the number of content items in each genre

SELECT 
	TRIM(UNNEST(STRING_TO_ARRAY(genre,','))) as Gen,
	COUNT(*)
FROM netflix
GROUP BY Gen
ORDER BY 2 DESC;

-- 10.Find the proportion of content released in India each year on netflix. 
-- return top 5 year with highest avg content release!

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


-- 11. List all movies that are documentaries

SELECT *
FROM netflix
WHERE genre ILIKE '%Documentaries%' AND type = 'Movie';

-- 12. Find all content without a director

SELECT *
FROM netflix
WHERE director ISNULL;

-- 13. Find how many movies actor 'Salman Khan' appeared in last 10 years!

SELECT *
FROM netflix
WHERE casts ILIKE '%Salman Khan%' 
	AND release_year > (EXTRACT(YEAR FROM CURRENT_DATE))-10;

-- 14. Find the top 10 actors who have appeared in the highest number of movies produced in India.

SELECT
	TRIM(UNNEST(STRING_TO_ARRAY(casts,','))) as actors,
	COUNT(*) as count_india_movies
FROM netflix
WHERE country ILIKE '%India%'
GROUP BY actors
ORDER BY count_india_movies DESC
LIMIT 10;

-- 15. Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
-- the description field. Label content containing these keywords as 'Bad' and all other 
-- content as 'Good'. Count how many items fall into each category.

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