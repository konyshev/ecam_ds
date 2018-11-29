/*
 * Project 'Integration donee' ECAM 2018-2019
 * Script for tables creation.
 * autor:Yaroslav Konyshev
 */

/*
 * Problems:
 * 1. table previous application fields were contained extra spaces in name and did not matched
 * 2. needed to fix application{train|test}.csv case
 * 3. extra column in description
 * 4. remove .csv
 * 5. TARGET doesn't in test
 * 6. without order by id columns were created in wrong order
 * 7. impossible to create forign key in bureau because of absence of id in application_test
 * 8. join train and test for simplicity treatment 
 * 9. finctions max_smallint
 * 10. target is bigint if null in column -> solution: change data load schema
 * 11. id in different tables may not exists + order of cleaning in this case  
 * 12. POS_CASH_balance problem with filename and presentation in database
 * 
 * */

--Creation of tables based on data structure table 
CALL yk_create_tables('/home/jovyan/ecam_ds/data/input/',FALSE);

ALTER TABLE application_train DROP COLUMN target;
create table if not exists application as (
	select * from application_test
	union all
	select * from application_train
);
DROP TABLE application_test,application_train;

create table client as (
	select sk_id_curr as id_client,
		   NOW() - (interval '100 days') + (interval '1 day'*days_birth::smallint) as birthday,
		   code_gender as gender,
		   name_education_type as education_type
	  from application
);
drop table application;

create table credit_types as (
	select distinct DENSE_RANK() OVER(ORDER BY NAME_CONTRACT_TYPE) as id_type
	     , NAME_CONTRACT_TYPE as nom_de_type
    from previous_application
);

create table achat_types as (
	select distinct DENSE_RANK() OVER(ORDER BY name_goods_category) as id_type
	     , name_goods_category as nom_de_type
    from previous_application
);

create table calendar as (
	select 
		d.date as date,
		extract(year from d.date)::smallint as year,
		extract(month from d.date)::smallint as month,
		extract(week from d.date)::smallint as week_of_year,
		extract(dow from d.date)::smallint as weekday,
		extract(day from d.date)::smallint as day_of_month
	from (
		SELECT date_trunc('day', dd):: date as date
		FROM generate_series
		        ( '2010-01-01'::timestamp 
		        , NOW() + (interval '1000 days')
		        , '1 day'::interval) dd
		)d
);

create table demande_de_credit as (
	select 
	p.sk_id_prev as id_demande,
	p.sk_id_curr as id_client,
	(NOW() - (interval '2000 days') + (random() * (interval '1800 days')))::date as date_de_demande,
	c.id_type  as type_de_credit,
	a.id_type as type_de_achat,
	p.amt_goods_price as prix_de_achat,
	p.amt_application as montant_demande,
	p.amt_credit montant_credit,
	p.name_type_suite as type_accompagne, 
	p.name_contract_status as status
    from previous_application p
    left join credit_types c on c.nom_de_type = p.name_contract_type
    left join achat_types a on a.nom_de_type = p.name_goods_category
);
drop table previous_application;

insert into yk_data_struct values ('calendar');
insert into yk_data_struct values ('credit_types');
insert into yk_data_struct values ('demande_de_credit');
insert into yk_data_struct values ('client');
insert into yk_data_struct values ('achat_types');

CALL yk_change_column_types('yk_data_struct');


----

delete from demande_de_credit 
	where id_client in (
		select d.id_client 
		  from demande_de_credit d
		  left outer join client c on d.id_client = c.id_client
		 where c.id_client is null
	 );

--primary keys
ALTER TABLE calendar ADD PRIMARY KEY (date);
ALTER TABLE client ADD PRIMARY KEY (id_client);
ALTER TABLE credit_types ADD PRIMARY KEY (id_type);
ALTER TABLE achat_types ADD PRIMARY KEY (id_type);
ALTER TABLE demande_de_credit ADD PRIMARY KEY (id_demande);


--forign keys and constraints
ALTER TABLE demande_de_credit ADD constraint fk_date_de_demande foreign key (date_de_demande) REFERENCES calendar (date);
ALTER TABLE demande_de_credit ADD constraint fk_type_de_credit foreign key (type_de_credit) REFERENCES credit_types (id_type);
ALTER TABLE demande_de_credit ADD constraint fk_type_de_achat foreign key (type_de_achat) REFERENCES achat_types (id_type);
ALTER TABLE demande_de_credit ADD constraint fk_id_client foreign key (id_client) REFERENCES client (id_client);


--indexes
CREATE UNIQUE INDEX idx_id_demande ON demande_de_credit (id_demande);
CREATE INDEX idx_id_client ON demande_de_credit (id_client);
CREATE UNIQUE INDEX idx_client_id_client ON client (id_client);

-----

select c.gender
	,count(d.id_demande) count_of_demande
	,to_char(avg(d.prix_de_achat),'999999999.99') avg_of_prix
	,to_char(avg(d.montant_demande-d.montant_credit),'999999999.99') avg_demande_minus_credit
	,sum(CASE WHEN d.status='Approved' THEN 1 else 0 END) count_of_approved
	,sum(CASE WHEN d.status='Refused' THEN 1 else 0 END) count_of_refused
	,sum(CASE WHEN d.status='Canceled' THEN 1 else 0 END) count_of_canceled
	,sum(CASE WHEN d.status='Unused offer' THEN 1 else 0 END) count_of_unused
  from demande_de_credit d
  left join client c on d.id_client = c.id_client
group by c.gender;
--------------


select t.range as "age when demande range",
		sum(CASE WHEN d.type_accompagne='Family' THEN 1 else 0 END) count_of_family,
		sum(CASE WHEN d.type_accompagne='Group of people' THEN 1 else 0 END) count_of_group,
		sum(CASE WHEN d.type_accompagne='Unaccompanied' THEN 1 else 0 END) count_of_unaccompanied,
		sum(CASE WHEN d.type_accompagne='Children' THEN 1 else 0 END) count_of_children,
		sum(CASE WHEN d.type_accompagne='Spouse, partner' THEN 1 else 0 END) count_of_spouse
from (
      select a.id_demande,
      	case 
      	 when a.age_when_demande > 0 and a.age_when_demande < 25 then '0-25'
      	 when a.age_when_demande >= 25 and a.age_when_demande < 40 then '25-40'
      	 when a.age_when_demande >= 40 and a.age_when_demande < 65 then '40-65'
      	 when a.age_when_demande >= 65 then '65+' end as range
     from (	select d.id_demande,
     			   extract(year from age(d.date_de_demande,c.birthday))::smallint as age_when_demande
			  from demande_de_credit d
			  left join client c on d.id_client = c.id_client
		  ) a
     ) t
     inner join demande_de_credit d on d.id_demande = t.id_demande
group by t.range
order by t.range
;
----

with age_range as (
      select a.id_demande,
      	case 
      	 when a.age_when_demande > 0 and a.age_when_demande < 25 then '0-25'
      	 when a.age_when_demande >= 25 and a.age_when_demande < 40 then '25-40'
      	 when a.age_when_demande >= 40 and a.age_when_demande < 65 then '40-65'
      	 when a.age_when_demande >= 65 then '65+' end as range
     from (	select d.id_demande,
     			   extract(year from age(d.date_de_demande,c.birthday))::smallint as age_when_demande
			  from demande_de_credit d
			  left join client c on d.id_client = c.id_client
	)a
)
select a_t.nom_de_type,
		sum(CASE WHEN a_r.range='0-25' THEN 1 else 0 END) "0-25",
		sum(CASE WHEN a_r.range='25-40' THEN 1 else 0 END) "25-40",
		sum(CASE WHEN a_r.range='40-65' THEN 1 else 0 END) "40-65",
		sum(CASE WHEN a_r.range='65+' THEN 1 else 0 END) "65+"
	from age_range a_r
	inner join demande_de_credit d on d.id_demande = a_r.id_demande
	inner join achat_types a_t on a_t.id_type = d.type_de_achat
group by a_t.nom_de_type;

----

select c.year,count(d.id_demande)
from calendar c
left join demande_de_credit d on c."date"= d.date_de_demande
group by c.year
order by year
