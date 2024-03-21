-- Q1. Find the total number of rows in each table of the schema?
SELECT table_name,
       table_rows
FROM   INFORMATION_SCHEMA.TABLES
WHERE  TABLE_SCHEMA = 'imdb'; 

-- Q2. Which columns in the movie table have null values?
describe MOVIE;
SELECT 'ID',
       COUNT(*) AS Null_Count
FROM   MOVIE
WHERE  ID IS NULL
UNION
SELECT 'Title',
       COUNT(*) AS Null_Count
FROM   MOVIE
WHERE  TITLE IS NULL
UNION
SELECT 'Year',
       COUNT(*) AS Null_Count
FROM   MOVIE
WHERE  YEAR IS NULL
UNION
SELECT 'Date Published',
       COUNT(*) AS Null_Count
FROM   MOVIE
WHERE  DATE_PUBLISHED IS NULL
UNION
SELECT 'Movie',
       COUNT(*) AS Null_Count
FROM   MOVIE
WHERE  DURATION IS NULL
UNION
SELECT 'Country',
       COUNT(*) AS Null_Count
FROM   MOVIE
WHERE  COUNTRY IS NULL
UNION
SELECT 'WorldWide_Gross',
       COUNT(*) AS Null_Count
FROM   MOVIE
WHERE  WORLWIDE_GROSS_INCOME IS NULL
UNION
SELECT 'Languages',
       COUNT(*) AS Null_Count
FROM   MOVIE
WHERE  LANGUAGES IS NULL
UNION
SELECT 'Prod Company',
       COUNT(*) AS Null_Count
FROM   MOVIE
WHERE  PRODUCTION_COMPANY IS NULL; 

-- country, worlwide_gross_income, languages and production_company columns have NULL values.

-- Q3. Find the total number of movies released each year? How does the trend look ? (Output expected)
-- Number of movies release in each year.
SELECT year, COUNT('title') AS 'number_of_movies' 
FROM MOVIE
GROUP BY year;

-- Number of Movies release in each month.
SELECT MONTH(DATE_PUBLISHED) AS'month_num',
       COUNT(TITLE) AS 'number_of_movies'
FROM   MOVIE
GROUP  BY MONTH(DATE_PUBLISHED)
ORDER BY number_of_movies desc;
-- we can tell trend is decreasing from 2017,2018,2019 movie release number is 3052,2944,2001
-- The highest number of movies is produced in the month of March.
-- The lowest number of movies is produced in the month of December.

-- Q4. How many movies were produced in the USA or India in the year 2019??
SELECT year, count(title) 
FROM movie
WHERE year = 2019 AND (country like '%India%' or country like '%USA%')
GROUP BY year;

-- In year 2019 alone in INDIA and USA has produce more than 1000 movies

-- Q5. Find the unique list of the genres present in the data set?
SELECT DISTINCT genre 
FROM   GENRE; 

-- Q6.Which genre had the highest number of movies produced overall?
SELECT g.genre, COUNT(m.TITLE) AS no_of_movies
FROM   MOVIE as m
INNER JOIN GENRE as g ON g.MOVIE_ID = m.ID
GROUP  BY g.GENRE
ORDER  BY COUNT(m.TITLE) DESC
LIMIT  1; 

-- In drama genre highest 4285 number of movie produce.
-- Q7. How many movies belong to only one genre?
WITH AGG 
	AS (
	SELECT m.id, count(G.GENRE) as GENRE
    FROM genre as g INNER JOIN movie as m ON g.movie_id=m.id
    GROUP BY m.id
	HAVING count(g.genre) = 1)
SELECT 	COUNT(ID) AS movie_count
FROM AGG ;

-- Q8.What is the average duration of movies in each genre? 
SELECT g.genre, avg(m.duration) as avg_duration
FROM movie as m INNER JOIN genre as g ON m.id=g.movie_id
GROUP BY g.genre
ORDER BY avg(m.duration) DESC;

-- Q9.What is the rank of the ‘thriller’ genre of movies among all the genres in terms of number of movies produced? 
WITH GENRE_RANKS
     AS (SELECT genre, Count(MOVIE_ID) AS 'movie_count',
                RANK()
                  OVER(ORDER BY Count(MOVIE_ID) DESC) AS genre_rank
         FROM   GENRE
         GROUP  BY GENRE)
SELECT *
FROM   GENRE_RANKS
WHERE  GENRE = 'thriller'; 

-- Q10.  Find the minimum and maximum values in  each column of the ratings table except the movie_id column?
SELECT MIN(avg_rating) as min_avg_rating,
		max(avg_rating) as max_avg_rating,
        MIN(total_votes) as min_total_votes,
		max(total_votes) as max_total_votes,
        MIN(median_rating) as min_median_rating,
		max(median_rating) as max_median_rating
FROM ratings;

-- Q11. Which are the top 10 movies based on average rating?
SELECT m.title, avg_rating,
RANK() OVER(ORDER BY avg_rating DESC) as movie_rank
FROM ratings as r INNER JOIN movie as m ON r.movie_id=m.id
order by r.avg_rating DESC
limit 10;

-- Q12. Summarise the ratings table based on the movie counts by median ratings.
SELECT median_rating, count(movie_id) as num_movie
FROM ratings
GROUP BY median_rating
ORDER BY count(movie_id) DESC;

-- Q13. Which production house has produced the most number of hit movies (average rating > 8)??
SELECT m.production_company, count(m.id) as hit_movie
FROM movie as m INNER JOIN ratings as r ON m.id=r.movie_id
WHERE r.avg_rating > 8 
GROUP BY m.production_company
HAVING m.production_company is not null
ORDER BY count(r.avg_rating) DESC
limit 3;
-- Best production house with highest number of hit movie are Dream Warrior Pictures, National Theatre Live,Lietuvos Kinostudija

-- Q14. How many movies released in each genre during March 2017 in the USA had more than 1,000 votes?
select g.genre, count(g.movie_id) as num_movie
FROM genre as g INNER JOIN movie as m  ON g.movie_id=m.id 
				INNER JOIN ratings as r ON m.id=r.movie_id
WHERE  r.TOTAL_VOTES > 1000
                AND Month(m.DATE_PUBLISHED) = 3
                AND Year(m.DATE_PUBLISHED) = 2017
                AND m.COUNTRY IN ( 'USA' )
GROUP BY g.genre
ORDER BY count(m.id) DESC;

-- Q15. Find movies of each genre that start with the word ‘The’ and which have an average rating > 8?
SELECT m.title, g.genre, r.avg_rating
FROM genre as g INNER JOIN movie as m  ON g.movie_id=m.id 
				INNER JOIN ratings as r ON m.id=r.movie_id
WHERE r.avg_rating >8 AND lower(m.title) like 'the%';

-- Q16. Of the movies released between 1 April 2018 and 1 April 2019, how many were given a median rating of 8?
SELECT r.median_rating, count(m.TITLE) AS movie_count
FROM RATINGS as r INNER JOIN MOVIE as m ON m.ID = r.MOVIE_ID
WHERE  r.MEDIAN_RATING = 8
       AND m.DATE_PUBLISHED BETWEEN '2018-04-01' AND '2019-04-01'
GROUP  BY r.MEDIAN_RATING;

-- Q17. Do German movies get more votes than Italian movies? 
WITH LANGUAGES_GROUPED
AS
  (
             SELECT     languages,
                        total_votes,
                        CASE
                                   WHEN LANGUAGES REGEXP 'German' THEN 'German'
                                   WHEN LANGUAGES REGEXP 'Italian' THEN 'Italian'
                                   ELSE 'Others'
                        END AS languages_grouped
             FROM       MOVIE M
             INNER JOIN RATINGS R
             ON         M.ID=R.MOVIE_ID )
  SELECT   LANGUAGES_GROUPED AS 'languages',
           SUM(TOTAL_VOTES)  AS total_votes
  FROM     LANGUAGES_GROUPED
  WHERE    LANGUAGES_GROUPED IN ('German',
                                 'Italian')
  GROUP BY LANGUAGES_GROUPED
  ORDER BY TOTAL_VOTES DESC ;
  
  -- Q18. Which columns in the names table have null values??
SELECT COUNT(*) - COUNT(ID)               AS id_nulls,
       COUNT(*) - COUNT(NAME)             AS name_nulls,
       COUNT(*) - COUNT(HEIGHT)           AS height_nulls,
       COUNT(*) - COUNT(DATE_OF_BIRTH)    AS date_of_birth_nulls,
       COUNT(*) - COUNT(KNOWN_FOR_MOVIES) AS known_for_movies_nulls
FROM   NAMES; 

-- Q19. Who are the top three directors whose movies have an average rating > 8?
SELECT 	n.name, count(m.id)
FROM ratings as r INNER JOIN movie as m ON r.movie_id=m.id
					INNER JOIN director_mapping as d ON d.movie_id=m.id
                    INNER JOIN names as n ON n.id=d.name_id
WHERE avg_rating > 8
GROUP BY n.name
ORDER BY count(m.id) DESC
limit 3;

-- Top 3 director with highest rating hit movie are Joe Russo, Anthony Russo & James Mangold

-- Q20. Who are the top actors whose movies have a median rating >= 8?
SELECT NAME AS actor_name,
       COUNT(NAME) AS movie_count
FROM   NAMES N
       INNER JOIN ROLE_MAPPING RO ON N.ID = RO.NAME_ID
       INNER JOIN RATINGS RA ON RO.MOVIE_ID = RA.MOVIE_ID
WHERE  MEDIAN_RATING >= 8 AND CATEGORY = 'actor'
GROUP  BY NAME
ORDER  BY COUNT(NAME) DESC
LIMIT  3; 
-- Top 3 actor which has highest number of hit movies are Mammootty,Mohanlal,Johnny Yong Bosch