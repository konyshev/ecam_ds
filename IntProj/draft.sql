/* connection test */
--select * from pg_tables;

-- number of lines
-- wc -l ~/Downloads/homeCreditData/to_db/*
--number of columns
--ls | xargs head -1 | awk 'BEGIN{FS=","};{print NF+1}'


/* export */
--COPY sample_submission TO '/home/jovyan/ecam_ds/data/sample_submission_db.csv' DELIMITER ',' CSV HEADER;

--ALTER TABLE chansons
--	ALTER COLUMN artiste TYPE varchar(60);
--ALTER TABLE chansons ADD constraint fk_artiste foreign key (artiste) REFERENCES artistes (nom);

--SELECT column_name,ordinal_position
--  FROM information_schema.columns 
-- WHERE table_schema='public' 
--   and table_name = 'application_train';-- and column_name <>'target';


--SELECT table_name,pg_size_pretty(pg_total_relation_size(format('%I.%I',table_schema,table_name))) 
--FROM information_schema.tables
--WHERE table_schema = 'public'
-- order by table_name;

--------

SELECT table_name,count(column_name)--column_name,data_type
FROM information_schema.columns
WHERE table_schema = 'public'
group by table_name
  --AND table_name   = 'pos_cash_balance'; --'bureau';
 
select * from bureau_balance;

SELECT table_name,count(column_name)--column_name,data_type
FROM information_schema.columns
WHERE table_schema = 'public'
group by table_name ;

SELECT * --table_name,column_name,data_type
FROM information_schema.check_constraints
WHERE constraint_schema = 'public';

SELECT t.table_name
FROM information_schema.tables t
WHERE t.table_schema = 'public';

select column_name
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name   = 'credit_card_balance';

select * from yk_data_struct;
 
select 'calendar' as text ,count(1) from calendar
union all
select 'credit_types' as text ,count(1) from credit_types
union all
select 'demande_de_credit' as text ,count(1) from demande_de_credit
union all
select 'client' as text ,count(1) from client
union all
select 'achat_types' as text ,count(1) from achat_types


select * from previous_application limit 5;

-- transformation of age
ALTER TABLE application ADD COLUMN age smallint null;
ALTER TABLE application DROP COLUMN age;

ALTER TABLE application ADD COLUMN birthday date null;
update application set birthday = ;
ALTER TABLE application ADD COLUMN tmp_birthday text;

select birthday from application;

update application set tmp_birthday = format(E'%s',days_birth::smallint*(-1));

select interval '1 days'*-15;

select tmp_birthday) from application;
select NOW() - (interval '100 days') + (interval '1 day'*days_birth::smallint) as a from application ;--where birthday is not null;

select days_birth as a from application order by a;

select * from application limit 5;


--dimension date
select case
		when t.change_in_years_ago = 0 then 'no change'
		when t.change_in_years_ago BETWEEN 0 AND 1 then 'this year'
		when t.change_in_years_ago > 1 then trunc(change_in_years_ago)||' years ago'
		else 'no info'
	   end as "last_phone_change_in_years"
from (
	select cast(DAYS_LAST_PHONE_CHANGE as real)/cast (-365 as real) as change_in_years_ago 
	from application
) t;

select count(1) from application_0_25;
select count(1) from application_25_40;
select count(1) from application_40_65;
select count(1) from application_65_inf;

select cast(DAYS_LAST_PHONE_CHANGE as real)/cast (-365 as real) as change_in_years_ago


select * from application;

SELECT * FROM yk_data_struct;

--how many payment by every previous credit
select appl.sk_id_curr,prev_appl.sk_id_prev,count(inst_pmt.*) payments_count,max(inst_pmt.DAYS_INSTALMENT-inst_pmt.DAYS_ENTRY_PAYMENT) as max_days_overdue
  from application appl
  inner join previous_application prev_appl on prev_appl.sk_id_curr = appl.sk_id_curr
  inner join installments_payments inst_pmt on inst_pmt.sk_id_curr = appl.sk_id_curr and inst_pmt.sk_id_prev = prev_appl.sk_id_prev
group by appl.sk_id_curr,prev_appl.sk_id_prev
order by 3 desc;
  
--


select count(*) from installments_payments;-- limit 5;
select DAYS_INSTALMENT,DAYS_ENTRY_PAYMENT from installments_payments limit 5;


select id_demande,count(AMT_BALANCE) from credit_card_balance group by id_demande;

select id_demande,count(1) from paiements  group by id_demande;


select sk_id_curr,days_decision,weekday_appr_process_start
from previous_application
where days_decision = '-3';

select sk_id_curr,count(sk_id_prev),min(days_decision::numeric)
from previous_application group by sk_id_curr
having count(sk_id_prev)>2
order by min(days_decision::numeric);

select * from client;



-- demande by education_type
select education_type,count(id_demande), max(prix_de_achat), max(montant_credit) 
from client c 
join demande_de_credit d using(id_client)
group by education_type;

---

select distinct status from demande_de_credit;
select * from calendar;


select weekday
,to_char(SUM(CASE WHEN d.status = 'Approved' THEN 1 ELSE 0 END)::FLOAT / COUNT(d.id_demande)* 100,'99.99') "% of Approved"
from calendar c 
join demande_de_credit d on d.date_de_demande = c."date"
group by weekday
order by 2 desc;
---

select weekday
,to_char(SUM(CASE WHEN d.status = 'Refused' THEN 1 ELSE 0 END)::FLOAT / COUNT(d.id_demande)* 100,'99.99 %') "% of Refused"
from calendar c 
join demande_de_credit d on d.date_de_demande = c."date"
group by weekday
order by 2 desc;


--

select d1.type_accompagne
,to_char(SUM(CASE WHEN d2.status = 'Approved' THEN 1 ELSE 0 END)::FLOAT / COUNT(d2.id_demande)* 100,'99.99') "% of Approved"
from demande_de_credit d1 
join demande_de_credit d2 using(date_de_demande)
group by d1.type_accompagne
order by 2 desc;
---

select d1.type_accompagne
,to_char(SUM(CASE WHEN d2.status = 'Refused' THEN 1 ELSE 0 END)::FLOAT / COUNT(d2.id_demande)* 100,'99.99')::float "% of Refused"
from demande_de_credit d1 
join demande_de_credit d2 using(date_de_demande)
group by d1.type_accompagne
order by 2 DESC;


select DISTINCT nom_de_type from credit_types;

select days_decision from previous_application;


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
	a_t.nom_de_type as "Type de achat", 
	SUM(CASE WHEN a_r.range = '0-25' THEN 1 ELSE 0 END) "0-25",
	SUM(CASE WHEN a_r.range = '25-40' THEN 1 ELSE 0 END) "25-40",
	SUM(CASE WHEN a_r.range = '40-65' THEN 1 ELSE 0 END) "40-65",
	SUM(CASE WHEN a_r.range = '65+' THEN 1 ELSE 0 END) "65+",
	COUNT(d.id_demande) "Total"
FROM
	age_range a_r
	INNER JOIN demande_de_credit d ON d.id_demande = a_r.id_demande
	INNER JOIN achat_types a_t ON a_t.id_type = d.type_de_achat
GROUP BY a_t.nom_de_type having COUNT(d.id_demande) > 10000
ORDER BY "Total" DESC;
