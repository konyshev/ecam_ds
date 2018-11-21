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
 * */

/* create initial table with structure of tables */
CREATE TABLE IF NOT EXISTS yk_data_struct
(
id SERIAL PRIMARY KEY,
table_name TEXT,
column_name TEXT,
column_description TEXT,
special TEXT
);

/* fill the table */
CALL yk_csv_to_table('yk_data_struct',
					 '/home/jovyan/ecam_ds/data/input/HomeCredit_columns_description.csv',false);
			
--CALL yk_csv_to_table('application_test',
--					 '/home/jovyan/ecam_ds/data/input/HomeCredit_columns_description.csv',false);

					
--select * from yk_data_struct;
					
/* Rename 'application_{train|test}.csv' case */
update yk_data_struct
   set
      table_name = REPLACE (
      table_name,
      'application_{train|test}.csv',
      'application_train.csv'
      )
 where table_name = 'application_{train|test}.csv';
COMMIT;

/* check if case is fixed */
--select distinct table_name 
--  from yk_data_struct 
-- where table_name ~ '^appl';

/* remove .csv from table_name and spaces from column_name */
update yk_data_struct
   set
      table_name = REPLACE (
         table_name,
         '.csv',
         ''
      ),
      column_name = REPLACE (
         column_name,
         ' ',
         ''
      )
;
COMMIT;

/* column does not exists in previous_application.csv */
delete from yk_data_struct 
 where column_name = 'NFLAG_MICRO_CASH' 
   and table_name = 'previous_application';
COMMIT;
  
/* setup correct sequence number */
select  setval('yk_data_struct_id_seq',  (select max(id) from yk_data_struct));

/* add records for APPLICATION_TEST table */
insert into yk_data_struct 
	select nextval('yk_data_struct_id_seq') as id,
		   'application_test' as table_name,
		   column_name,
		   column_description,
		   special
	from yk_data_struct 
   where table_name = 'application_train'
	order by yk_data_struct.id;
COMMIT;

--Creation of tables based on data structure table 
CALL yk_create_tables('yk_data_struct');

CALL yk_fill_tables('yk_data_struct','/home/jovyan/ecam_ds/data/input/',True);

CALL yk_change_column_types('yk_data_struct');

create table if not exists application as (
	select * from application_test
	union all
	select * from application_train
);

drop table if exists application_test,application_train;

--select count(*) from application_test;
--select column_name from yk_data_struct where table_name = 'previous_application' order by id;
--select * from previous_application limit 5;--where sk_id_prev=55075.5; 

ALTER TABLE application ADD PRIMARY KEY (SK_ID_CURR);
ALTER TABLE bureau ADD PRIMARY KEY (SK_BUREAU_ID);
ALTER TABLE previous_application ADD PRIMARY KEY (SK_ID_PREV);
ALTER TABLE bureau ADD constraint fk_sk_id_curr foreign key (sk_id_curr) REFERENCES application (sk_id_curr);


/*
delete from bureau 
where sk_id_curr in (
select b.sk_id_curr 
  from bureau b
  left outer join application a on a.sk_id_curr=b.sk_id_curr
 where a is null
 );

*/






