select c.gender
	,count(d.id_demande) "count"
	,to_char(percentile_cont(0.5) within group(order by prix_de_achat),'999999999.99') med_of_prix
	,to_char(avg(d.montant_demande-d.montant_credit),'999999999.99') "avg (demande - credit)"
	,to_char(sum(CASE WHEN d.status='Approved' THEN 1 else 0 END)::float/count(d.id_demande)*100,'99.99 %') "% of approved"
	,to_char(sum(CASE WHEN d.status='Refused' THEN 1 else 0 END)::float/count(d.id_demande)*100,'99.99 %') "% of refused"
  from demande_de_credit d
  left join client c on d.id_client = c.id_client
group by c.gender;

--------------

select t.range as "age when demande range",
		to_char(sum(CASE WHEN d.type_accompagne='Family' THEN 1 else 0 END)::float/count(t.id_demande)*100,'99.99 %') "% of family",
		to_char(sum(CASE WHEN d.type_accompagne='Group of people' THEN 1 else 0 END)::float/count(t.id_demande)*100,'99.99 %') "% of group",
		to_char(sum(CASE WHEN d.type_accompagne='Unaccompanied' THEN 1 else 0 END)::float/count(t.id_demande)*100,'99.99 %') "% of unaccompanied",
		to_char(sum(CASE WHEN d.type_accompagne='Children' THEN 1 else 0 END)::float/count(t.id_demande)*100,'99.99 %') "%of children",
		to_char(sum(CASE WHEN d.type_accompagne='Spouse, partner' THEN 1 else 0 END)::float/count(t.id_demande)*100,'99.99 %') "% of spouse"
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

select c."year",count(d.id_demande)
from calendar c
left join demande_de_credit d on c."date"= d.date_de_demande
group by c.year
order by year