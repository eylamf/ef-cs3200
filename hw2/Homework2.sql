-------
-- 395
-------

-- 1a)
WITH A(cname, maxP) AS (
	SELECT cname, max(price)
	FROM Company, Product
	WHERE Company.cid = Product.cid
	GROUP BY Company.cid, cname
)
SELECT Company.cname, price, pname
FROM Company, Product, A
WHERE Company.cid = Product.cid
AND Company.cname = A.cname
GROUP BY Company.cname, price, pname
HAVING max(price) = max(A.maxP);

-- 1b)
SELECT Company.cname, city, count(pname) as num
FROM Company LEFT OUTER JOIN Product ON Company.cid = Product.cid
GROUP BY Company.cname, city;
/*
"Apple";"MountainView";2
"GizmoWorks";"Oslo";2
"ToyFactory";"DreamCity";1
"ToyFactory";"FakeCity";0

One thing we noticed was that the output for ToyFactory at FakeCity was 0
after a FULL JOIN between the company and product tables because that
company made no products, meaning it has a tuple with NULL. The count function
doesn’t count NULL
*/


---------------
-- Chinook 319
---------------

-- 2a)
SELECT Artist.name, Customer.Country
FROM Customer, Invoice, InvoiceLine, Track, Album, Artist
WHERE Customer.customerid = Invoice.customerid
and Invoice.invoiceid = InvoiceLine.invoiceid
and InvoiceLine.trackid = Track.trackid
and Track.albumid = Album.albumid
and Album.artistid = Artist.artistid
GROUP BY Artist.name, Customer.country;


-- 2b)
WITH X(aid, numCountries) AS (
	SELECT Artist.artistid, count(DISTINCT Customer.country)
	FROM Artist JOIN Album ON Artist.artistid = Album.artistid
			JOIN Track ON Track.albumid = Album.albumid
			JOIN InvoiceLine ON InvoiceLine.trackid = Track.trackid
			JOIN Invoice ON Invoice.invoiceid = InvoiceLine.invoiceid
			JOIN Customer ON Customer.customerid = Invoice.customerid
	GROUP BY Artist.artistid
	HAVING count(DISTINCT Customer.country) >= 10
)
SELECT name, X.numCountries
FROM Artist, X
WHERE Artist.artistid = X.aid
ORDER BY X.numCountries ASC;

-- 2c)
WITH X(aid, numCountries) AS (
	SELECT Artist.artistid, count(DISTINCT Customer.country)
	FROM Artist JOIN Album ON Artist.artistid = Album.artistid
			JOIN Track ON Track.albumid = Album.albumid
			JOIN InvoiceLine ON InvoiceLine.trackid = Track.trackid
			JOIN Invoice ON Invoice.invoiceid = InvoiceLine.invoiceid
			JOIN Customer ON Customer.customerid = Invoice.customerid
	GROUP BY Artist.artistid
	HAVING count(DISTINCT Customer.country) >= 10
)
SELECT name, X.numCountries
FROM Artist, X
WHERE Artist.artistid = X.aid
AND X.numCountries =
	(SELECT max(X.numCountries)
	FROM X);

---------
-- IMDB
---------

-- 3)
-- 3163 violations
WITH A(ids) AS (
	SELECT mid
	FROM Genre
	EXCEPT
	SELECT id
	FROM Movie
)
SELECT count(A.ids)
FROM A;

-- 4)
WITH X(mid, c) AS (
	SELECT mid, count(DISTINCT pid) as c
	FROM Casts
	GROUP BY mid
)
SELECT name, max(X.c)
FROM Movie, Casts, X
WHERE Movie.id = Casts.mid
and Movie.id = X.mid
GROUP BY name, X.c
HAVING X.c = (SELECT max(X.c) FROM X);

-- 5)
WITH X(mid, pid, c) AS (
	SELECT mid, pid, count(DISTINCT role)
	FROM Casts
	GROUP BY mid, pid
)
SELECT fname, lname, name, X.c
FROM X, Movie, Actor
WHERE X.pid = Actor.id
AND X.mid = Movie.id
GROUP BY fname, lname, name, X.c
HAVING X.c = (SELECT max(X.c) FROM X);

-- 6)
SELECT count(DISTINCT pid)
FROM Casts,
	(SELECT mid
	FROM Casts JOIN Actor ON Casts.pid = Actor.id
	WHERE fname = 'Kevin' and lname = 'Bacon'
	and id = (SELECT id
		FROM Actor
		WHERE fname = 'Kevin' AND lname = 'Bacon')) as Kbm
WHERE Casts.mid = Kbm.mid
and Casts.pid != (SELECT id
		FROM Actor
		WHERE fname = 'Kevin' AND lname = 'Bacon');
