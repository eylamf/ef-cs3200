/*
Question 1
- I am taking data from the actor, movie, and casts tables
- I gave each an alias to make the query readable and specific
*/
SELECT fname, lname, role
FROM ACTOR a, MOVIE m, CASTS c
WHERE a.id = c.pid
    and m.id = c.mid
    and m.name = 'Elastico: Experiment 345';

/*
Question 2
- set an inner join on director id and
  movie_directors foreign key of director id (did)
- Subquery to find all movie IDs that cast a role of 'The Problem Solver'
*/
SELECT Directors.fname, Directors.lname
FROM Directors
	INNER JOIN Movie_directors
	ON Directors.id = Movie_directors.did
	WHERE Movie_directors.mid
		IN (SELECT mid
			FROM Casts
			WHERE role = 'The Problem Solver');

/*
Question 3
- Get list of movies with year < 1900, Get list of movies with year > 2000
- Select the actor id (foreign key pid) in Casts that are in the intersection
- Get actor data

It's possible to get results from both X < 1900 and X > 2000
because Actors can have the same names. Actor's names during the 1800s
were also quite generic and resembled public figures at the time
*/
SELECT Actor.*
FROM Actor,
        (SELECT pid
		  FROM Casts,
			(SELECT id
			FROM Movie
			WHERE year < 1900) as X
		WHERE Casts.mid = X.id
		INTERSECT
		SELECT pid
		FROM Casts,
			(SELECT id
			FROM Movie
			WHERE year > 2000) as Y
		WHERE Casts.mid = Y.id) as Z
WHERE Actor.id = Z.pid;

/*
Question 4
- First I defined T as all the director and movie ids of the thriller genre
- Then I select fname, lname and how many movies each director has using
the directors table. I group by director name and make sure they have 30 or
more movie ids
*/
WITH T(did, mid) AS (
	SELECT Movie_directors.*
	FROM Movie_directors INNER JOIN Genre
		ON Movie_directors.mid = Genre.mid
	WHERE genre = 'Thriller'
)
SELECT fname, lname, count(T.mid) as qty
FROM Directors, T
WHERE Directors.id = T.did
GROUP BY fname, lname
HAVING count(T.mid) >= 30
ORDER BY count(T.mid) DESC;

/*
Question 5 A
- join casts and movie on movie id/casts mid
- get movies from the year 2015
- group by actor id and movie name and make sure the c
  ount of role is 5 or more
*/
SELECT fname, lname, M.name, count(M.role)
FROM Actor,
	(SELECT pid, role, name
	FROM Casts INNER JOIN Movie
		ON Casts.mid = Movie.id
	WHERE year = 2015) as M
WHERE Actor.id = M.pid
GROUP BY Actor.id, M.name
HAVING count(role) >= 5;

/*
Question 5 B
- used previous query (5 A) but select the movie id and actor id only
- join Actor, Casts, Movie, and 5A result using actor id and movie id
*/
WITH M(aid, mid) AS (SELECT Actor.id, X.mid
FROM Actor,
	(SELECT Casts.pid, Casts.mid
	FROM Casts INNER JOIN Movie
		ON Casts.mid = Movie.id
		WHERE Movie.year = 2015
	GROUP BY Casts.pid, Movie.name, Casts.mid
	HAVING count(DISTINCT role) >= 5) as X
WHERE Actor.id = X.pid)
SELECT fname, lname, name, role
FROM Actor, Casts, Movie, M
WHERE Actor.id = M.aid
    and Movie.id = M.mid
    and Casts.pid = M.aid
    and Casts.mid = M.mid;
