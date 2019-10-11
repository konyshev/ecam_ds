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

ALTER TABLE application_test ADD COLUMN target text;
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
COMMIT;

CALL yk_change_column_types('yk_data_struct');

delete from bureau 
where sk_id_curr in (
select b.sk_id_curr 
  from bureau b
  left outer join application a on a.sk_id_curr=b.sk_id_curr
 where a is null
 );

delete from previous_application 
where sk_id_curr in (
select p_a.sk_id_curr 
  from previous_application p_a
  left outer join application a on a.sk_id_curr=p_a.sk_id_curr
 where a is null
 );

delete from credit_card_balance 
where sk_id_curr in (
select c_c_b.sk_id_curr 
  from credit_card_balance c_c_b
  left outer join application a on a.sk_id_curr=c_c_b.sk_id_curr
 where a is null
 );

delete from pos_cash_balance 
where sk_id_curr in (
select p_c_b.sk_id_curr 
  from pos_cash_balance p_c_b
  left outer join application a on a.sk_id_curr=p_c_b.sk_id_curr
 where a is null
 );

delete from installments_payments 
where sk_id_curr in (
select i_p.sk_id_curr 
  from installments_payments i_p
  left outer join application a on a.sk_id_curr=i_p.sk_id_curr
 where a is null
 );


delete from bureau_balance 
where sk_id_bureau in (
select b_b.sk_id_bureau 
  from bureau_balance b_b
  left outer join bureau b on b_b.sk_id_bureau=b.sk_id_bureau
 where b is null
 );

delete from pos_cash_balance 
where sk_id_curr in (
select p_c_b.sk_id_curr 
  from pos_cash_balance p_c_b
  left outer join previous_application p_a on p_a.sk_id_prev = p_c_b.sk_id_prev
 where p_a is null
 );

delete from credit_card_balance 
where sk_id_curr in (
select c_c_b.sk_id_curr 
  from credit_card_balance c_c_b
  left outer join previous_application p_a on p_a.sk_id_prev = c_c_b.sk_id_prev
 where p_a is null
 );


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

