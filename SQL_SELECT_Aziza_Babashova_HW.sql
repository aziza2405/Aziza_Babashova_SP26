/*The marketing team needs a list of animation movies between 2017 and 2019 to promote family-friendly content in an upcoming season 
 * in stores. Show all animation movies released during this period with rate more than 1, sorted alphabetically*/


/* With join */
SELECT f.film_id ,f.title, f.release_year ,f.rental_rate, c."name" 
FROM film f
JOIN  film_category f_c ON f_c.film_id =f.film_id 
JOIN  category c ON c.category_id=f_c.category_id  
WHERE c."name" = 'Animation'
AND f.rental_rate >1
AND f.release_year BETWEEN 2017 AND 2019
ORDER BY f.title


/* With CTE */
with animation_films as (
   select f.film_id ,f.title, f.release_year ,f.rental_rate, c."name"
   FROM film f
   JOIN  film_category f_c ON f_c.film_id =f.film_id 
   JOIN  category c ON c.category_id=f_c.category_id
   WHERE c."name" = 'Animation'
)

SELECT a_f.film_id ,a_f.title, a_f.release_year ,a_f.rental_rate, a_f."name" 
FROM animation_films a_f
where a_f.rental_rate >1
AND a_f.release_year BETWEEN 2017 AND 2019
ORDER BY a_f.title

/* With subquery */
SELECT f.film_id ,f.title, f.release_year ,f.rental_rate
FROM film f
WHERE f.rental_rate > 1
  AND f.release_year BETWEEN 2017 AND 2019
  AND f.film_id IN (
        SELECT fc.film_id
        FROM film_category fc
        WHERE fc.category_id = (
            SELECT c.category_id
            FROM category c
            WHERE c.name = 'Animation'
        )
  )

ORDER BY f.title;

/* I prefer choose join solition.Because of logic is not so complicated as subquery and common table expression.*/
/*************************************************************************************************************/


/*The finance department requires a report on store performance to assess profitability and plan resource allocation for stores 
 * after March 2017. Calculate the revenue earned by each rental store after March 2017 (since April) (include columns: address and 
 * address2 – as one column, revenue) */

/* join solution */
SELECT store.address_id, CONCAT(a.address,a.address2) AS Location, SUM(pay.amount) AS Revenue
FROM store
JOIN staff 
ON staff.store_id = store.store_id 
JOIN payment pay 
ON pay.staff_id = staff.staff_id
JOIN address a 
ON store.address_id = a.address_id 
WHERE pay.payment_date >= '2017-04-01'
GROUP BY store.store_id, a.address , a.address2 ;

/* CTE solution */
WITH store_revenue AS (
      SELECT store.store_id,store.address_id,a.address,a.address2,SUM(pay.amount) AS revenue
      FROM store
      JOIN staff 
      ON staff.store_id = store.store_id 
      JOIN payment pay 
      ON pay.staff_id = staff.staff_id
      JOIN address a 
      ON store.address_id = a.address_id 
      WHERE pay.payment_date >= '2017-04-01'
      GROUP BY store.store_id, a.address , a.address2 
)
SELECT 
    address_id, CONCAT(address, address2) AS Location, revenue
    FROM store_revenue
        
/*The marketing department in our stores aims to identify the most successful actors since 2015 to boost customer interest in their 
 * films. Show top-5 actors by number of movies (released since 2015) they took part in (columns: first_name, last_name, 
 * number_of_movies, sorted by number_of_movies in descending order)*/

SELECT a.first_name ,a.last_name ,COUNT(f.film_id )
FROM film f
JOIN film_actor f_a ON f.film_id =f_a.film_id 
JOIN actor a ON a.actor_id=f_a.actor_id 
WHERE f.release_year >= 2015
GROUP BY a.actor_id
ORDER BY COUNT(f.film_id ) DESC
LIMIT(5)


/*The marketing team needs to track the production trends of Drama, Travel, and Documentary films to inform genre-specific marketing 
 * strategies. Show number of Drama, Travel, Documentary per year (include columns: release_year, number_of_drama_movies, 
 * number_of_travel_movies, number_of_documentary_movies), sorted by release year in descending order. Dealing with NULL values is 
 * encouraged)*/

SELECT f.release_year,
COUNT(*) FILTER (WHERE c.name = 'Drama') AS number_of_drama_movies,
COUNT(*) FILTER (WHERE c.name = 'Travel') AS number_of_travel_movies,
COUNT(*) FILTER (WHERE c.name = 'Documentary') AS number_of_documentary_movies
FROM film f
JOIN film_category f_c ON f.film_id =f_c.film_id 
JOIN category c ON c.category_id =f_c.category_id
GROUP BY f.release_year 
ORDER BY f.release_year DESC


/*The HR department aims to reward top-performing employees in 2017 with bonuses to recognize their contribution to stores 
 revenue. Show which three employees generated the most revenue in 2017? */

SELECT s.first_name _name , s.last_name, sum(pay.amount ), s.store_id 
FROM staff s 
JOIN payment pay ON s.staff_id = pay.staff_id 
WHERE pay.payment_date >= '2017-01-01'
  AND pay.payment_date <  '2018-01-01'
GROUP BY s.staff_id 
ORDER BY SUM(pay.amount ) DESC

/*The management team wants to identify the most popular movies and their target audience age groups to optimize marketing efforts. 
 * Show which 5 movies were rented more than others (number of rentals), and what's the expected age of the audience for these movies?
 *  To determine expected age please use*/
SELECT f.title, sum(r.rental_id),f.rating 
FROM film f
JOIN inventory i ON f.film_id = i.film_id 
JOIN rental r ON i.inventory_id = r.inventory_id 
GROUP BY f.film_id
ORDER BY sum(r.rental_id) DESC
LIMIT(5)

/*According to the result audiences PG (Parental Guidance): Suitable for children, but parental guidance is advised. The primary audience is around 8–12 years old.
PG-13 (Parents Strongly Cautioned): Teens aged 13–16 are the main audience; some content may not be appropriate for younger children without parental supervision.
NC-17 (Adults Only): Intended for adults; viewers under 17 are not allowed.*/





/*The stores’ marketing team wants to analyze actors' inactivity periods to select those with notable career breaks for targeted
 *  promotional campaigns, highlighting their comebacks or consistent appearances to engage customers with nostalgic or reliable
 *  film stars
The task can be interpreted in various ways, and here are a few options (provide solutions for each one):
V1: gap between the latest release_year and current year per each actor;
V2: gaps between sequential films per each actor;
 */

/* V1 */
SELECT a.first_name, a.last_name  ,(EXTRACT(YEAR FROM CURRENT_DATE)-max(f.release_year)) AS gap 
FROM film f
JOIN film_actor f_a ON f.film_id = f_a.film_id 
JOIN actor a ON a.actor_id = f_a.actor_id 
GROUP BY a.actor_id
ORDER BY (EXTRACT(YEAR FROM CURRENT_DATE)-max(f.release_year)) DESC

/* V */

SELECT 
    a.first_name,
    a.last_name,
    (max(f1.release_year) - (
        SELECT MAX(f2.release_year)
        FROM film_actor fa2
        JOIN film f2 ON fa2.film_id = f2.film_id
        WHERE fa2.actor_id = a.actor_id
          AND f2.release_year < max(f1.release_year)
    )) AS gap_years
FROM actor a
JOIN film_actor fa1 ON a.actor_id = fa1.actor_id
JOIN film f1 ON fa1.film_id = f1.film_id
GROUP BY a.actor_id 
ORDER BY(max(f1.release_year) - (
        SELECT MAX(f2.release_year)
        FROM film_actor fa2
        JOIN film f2 ON fa2.film_id = f2.film_id
        WHERE fa2.actor_id = a.actor_id
          AND f2.release_year < max(f1.release_year)
    )) DESC




