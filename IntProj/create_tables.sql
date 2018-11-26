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

/*
delete from bureau 
where sk_id_curr in (
select b.sk_id_curr 
  from bureau b
  left outer join application a on a.sk_id_curr=b.sk_id_curr
 where a is null
 );

ALTER TABLE application ADD PRIMARY KEY (SK_ID_CURR);
ALTER TABLE bureau ADD PRIMARY KEY (SK_BUREAU_ID);
ALTER TABLE previous_application ADD PRIMARY KEY (SK_ID_PREV);
ALTER TABLE bureau ADD constraint fk_sk_id_curr foreign key (sk_id_curr) REFERENCES application (sk_id_curr);

*/






