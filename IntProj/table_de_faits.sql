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
CALL yk_create_tables('/home/jovyan/ecam_ds/data/input/',True);

ALTER TABLE application_train DROP COLUMN target;
create table if not exists application as (
	select * from application_test
	union all
	select * from application_train
);
DROP TABLE application_test,application_train;

UPDATE yk_data_struct 
	SET table_name = 'application' 
  WHERE table_name = 'application_test';
DELETE FROM yk_data_struct where table_name = 'application_train';


ALTER TABLE application ADD COLUMN birthday date null;

select name_education_type, count(1) from client group by name_education_type;

create table client as (
	select code_gender,
		   NOW() - (interval '100 days') + (interval '1 day'*days_birth::smallint) as birthday,
		   amt_income_total,
		   name_education_type
	  from application
)

create table paiements as (
	select 
		sk_id_prev as id_demande,
		amt_instalment,
		amt_payment,
		num_instalment_number,
		days_instalment,
		days_entry_payment
	from installments_payments
);
drop table installments_payments;

create table demande_de_credit as (
	select 
	sk_id_curr as id_person,
	sk_id_prev as id_demande,
	amt_application,
	amt_credit,
	(NOW() - (interval '2000 days') + (random() * (interval '1800 days')))::date as date_de_demande,
	days_decision,
	name_contract_status
    from previous_application
);
drop table previous_application;

create table credit_card_balance_mensuel as (
	select 
		sk_id_prev as id_demande,
		amt_balance,
		amt_credit_limit_actual,
		amt_drawings_atm_current,
		cnt_drawings_atm_current
	  from credit_card_balance
)
drop table credit_card_balance;

update yk_data_struct set table_name = 'credit_bureau' where table_name = 'bureau';
update yk_data_struct set table_name = 'paiements' where table_name = 'installments_payments';
update yk_data_struct set table_name = 'demande_de_credit' where table_name = 'previous_application';
update yk_data_struct set table_name = 'credit_card_balance_mensuel' where table_name = 'credit_card_balance';

CALL yk_change_column_types('yk_data_struct');

----



delete from bureau 
	where id_person in (
		select b.id_person 
		  from bureau b
		  left outer join demande_de_credit d on d.id_person = b.id_person
		 where d.id_person is null
	 );

delete from paiements
	where id_demande in (
		select p.id_demande 
		  from paiements p
		  left outer join demande_de_credit d on d.id_demande=p.id_demande
		 where d.id_demande is null
	 );

delete from credit_card_balance 
where id_person in (
select c_c_b.id_person 
  from credit_card_balance c_c_b
  left outer join demande_de_credit d on d.id_demande=c_c_b.id_person
 where d.id_demande is null
 );

 
 ---num_instalment_number + id_demande ---> unique


--primary keys
ALTER TABLE application ADD PRIMARY KEY (sk_id_curr);
ALTER TABLE bureau ADD PRIMARY KEY (sk_id_bureau);
ALTER TABLE previous_application ADD PRIMARY KEY (sk_id_prev);

--forign keys
ALTER TABLE bureau ADD constraint fk_sk_id_curr foreign key (sk_id_curr) REFERENCES application (sk_id_curr);
ALTER TABLE pos_cash_balance ADD constraint fk_sk_id_curr foreign key (sk_id_curr) REFERENCES application (sk_id_curr);
ALTER TABLE previous_application ADD constraint fk_sk_id_curr foreign key (sk_id_curr) REFERENCES application (sk_id_curr);
ALTER TABLE credit_card_balance ADD constraint fk_sk_id_curr foreign key (sk_id_curr) REFERENCES application (sk_id_curr);
ALTER TABLE installments_payments ADD constraint fk_sk_id_curr foreign key (sk_id_curr) REFERENCES application (sk_id_curr);

ALTER TABLE bureau_balance ADD constraint fk_sk_id_bureau foreign key (sk_id_bureau) REFERENCES bureau (sk_id_bureau);

ALTER TABLE pos_cash_balance ADD constraint fk_sk_id_prev foreign key (sk_id_prev) REFERENCES previous_application (sk_id_prev);
ALTER TABLE credit_card_balance ADD constraint fk_sk_id_prev foreign key (sk_id_prev) REFERENCES previous_application (sk_id_prev);

-- transformation of age
ALTER TABLE application ADD COLUMN age smallint null;
update application set age = days_birth/(-365);

--dimension date
create table application_0_25 as select * from application where age between 0 and 25;





create table application_25_40 as select * from application where age between 25 and 40;





create table application_40_65 as select * from application where age between 40 and 65;
create table application_65_inf as select * from application where age > 65;

--indexes
CREATE UNIQUE INDEX appl_id_curr_idx ON application (sk_id_curr);

CREATE INDEX bur_id_curr_idx ON bureau (sk_id_curr);
CREATE UNIQUE INDEX bur_id_bureau_idx ON bureau (sk_id_bureau);

CREATE INDEX bur_blnc_id_bureau_idx ON bureau_balance (sk_id_bureau);

CREATE INDEX prev_appl_id_curr_idx ON previous_application (sk_id_curr);
CREATE UNIQUE INDEX prev_appl_id_prev_idx ON previous_application (sk_id_prev);

CREATE INDEX pos_id_curr_idx ON pos_cash_balance (sk_id_curr);
CREATE INDEX pos_id_prev_idx ON pos_cash_balance (sk_id_prev);

CREATE INDEX inst_id_curr_idx ON installments_payments (sk_id_curr);

CREATE INDEX card_id_curr_idx ON credit_card_balance (sk_id_curr);
CREATE INDEX card_id_prev_idx ON credit_card_balance (sk_id_prev);

