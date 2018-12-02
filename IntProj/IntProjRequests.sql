SELECT
	c.gender ,
	COUNT(d.id_demande) "count" ,
	to_char(PERCENTILE_CONT(0.5) WITHIN GROUP(ORDER BY prix_de_achat),'999999999.99') med_of_prix ,
	to_char(AVG(d.montant_demande-d.montant_credit),'999999999.99') "avg (demande - credit)" ,
	to_char(SUM(CASE WHEN d.status = 'Approved' THEN 1 ELSE 0 END)::FLOAT / COUNT(d.id_demande)* 100,'99.99 %') "% of approved" ,
	to_char(SUM(CASE WHEN d.status = 'Refused' THEN 1 ELSE 0 END)::FLOAT / COUNT(d.id_demande)* 100,'99.99 %') "% of refused"
FROM
	demande_de_credit d
	LEFT JOIN client c ON d.id_client = c.id_client
GROUP BY c.gender;

--------------


WITH age_range AS (
	SELECT	a.id_demande,
		CASE
			WHEN a.age_when_demande > 0	AND a.age_when_demande < 25 THEN '0-25'
			WHEN a.age_when_demande >= 25 AND a.age_when_demande < 40 THEN '25-40'
			WHEN a.age_when_demande >= 40 AND a.age_when_demande < 65 THEN '40-65'
			WHEN a.age_when_demande >= 65 THEN '65+'
		END AS RANGE
	FROM
		(
		SELECT
			d.id_demande,
			EXTRACT(YEAR FROM age(d.date_de_demande,c.birthday))::SMALLINT AS age_when_demande
		FROM
			demande_de_credit d
		LEFT JOIN client c ON d.id_client = c.id_client )a 
)
SELECT
	a.range AS "age when demande range", 
	to_char(SUM(CASE WHEN d.type_accompagne = 'Family' THEN 1 ELSE 0 END)::FLOAT / COUNT(a.id_demande)* 100,'99.99 %') "% of family",
	to_char(SUM(CASE WHEN d.type_accompagne = 'Group of people' THEN 1 ELSE 0 END)::FLOAT / COUNT(a.id_demande)* 100,'99.99 %') "% of group",
	to_char(SUM(CASE WHEN d.type_accompagne = 'Unaccompanied' THEN 1 ELSE 0 END)::FLOAT / COUNT(a.id_demande)* 100,'99.99 %') "% of unaccompanied",
	to_char(SUM(CASE WHEN d.type_accompagne = 'Children' THEN 1 ELSE 0 END)::FLOAT / COUNT(a.id_demande)* 100,'99.99 %') "%of children",
	to_char(SUM(CASE WHEN d.type_accompagne = 'Spouse, partner' THEN 1 ELSE 0 END)::FLOAT / COUNT(a.id_demande)* 100,'99.99 %') "% of spouse"
FROM
	age_range a
INNER JOIN demande_de_credit d ON d.id_demande = a.id_demande
GROUP BY a.range
ORDER BY a.range ;

----

WITH age_range AS (
	SELECT	a.id_demande,
		CASE
			WHEN a.age_when_demande > 0	AND a.age_when_demande < 25 THEN '0-25'
			WHEN a.age_when_demande >= 25 AND a.age_when_demande < 40 THEN '25-40'
			WHEN a.age_when_demande >= 40 AND a.age_when_demande < 65 THEN '40-65'
			WHEN a.age_when_demande >= 65 THEN '65+'
		END AS RANGE
	FROM
		(
		SELECT
			d.id_demande,
			EXTRACT(YEAR FROM age(d.date_de_demande,c.birthday))::SMALLINT AS age_when_demande
		FROM
			demande_de_credit d
		LEFT JOIN client c ON d.id_client = c.id_client )a 
)
SELECT
	a_t.nom_de_type,
	SUM(CASE WHEN a_r.range = '0-25' THEN 1 ELSE 0 END) "0-25",
	SUM(CASE WHEN a_r.range = '25-40' THEN 1 ELSE 0 END) "25-40",
	SUM(CASE WHEN a_r.range = '40-65' THEN 1 ELSE 0 END) "40-65",
	SUM(CASE WHEN a_r.range = '65+' THEN 1 ELSE 0 END) "65+",
	COUNT(d.id_demande) "Total"
FROM
	age_range a_r
	INNER JOIN demande_de_credit d ON d.id_demande = a_r.id_demande
	INNER JOIN achat_types a_t ON a_t.id_type = d.type_de_achat
GROUP BY a_t.nom_de_type
ORDER BY "Total" DESC;

----

SELECT
	c."year",
	COUNT(d.id_demande)
FROM calendar c
	 LEFT JOIN demande_de_credit d ON c."date" = d.date_de_demande
GROUP BY c."year"
ORDER BY c."year";

----

SELECT
	c.weekday,
	COUNT(d.id_demande)
FROM calendar c
	 LEFT JOIN demande_de_credit d ON c."date" = d.date_de_demande
GROUP BY c.weekday
ORDER BY c.weekday;