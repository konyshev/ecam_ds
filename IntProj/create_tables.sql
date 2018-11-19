/*
 * Project 'Integration donee' ECAM 2018-2019
 * Script for tables creation.
 * autor:Yaroslav Konyshev
 */

/*
 * Problems:
 * 1. table previous application fields were contained extra spaces in name and did not matched
 * 2. needed to fix application{train|test}.csv case
 * */

/* cleanup */
call yk_cleanup();

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
					 '/home/jovyan/ecam_ds/data/input/HomeCredit_columns_description.csv');

/* check table*/
select * from yk_data_struct limit 5; 
--delete from yk_data_struct;

					
/* Rename 'application_{train|test}.csv' case */
update 
   yk_data_struct
set
   table_name = REPLACE (
   table_name,
   'application_{train|test}.csv',
   'application_train.csv'
   )
where table_name = 'application_{train|test}.csv';

/* check if case is fixed */
select distinct table_name 
  from yk_data_struct 
 where table_name ~ '^appl';

/* remove .csv to upper case */
update yk_data_struct
set
   table_name = REPLACE (
   table_name,
 '.csv',
 ''
   );

/* remove spaces from column names */
update yk_data_struct
set
   column_name = REPLACE (
   column_name,
 ' ',
 ''
   );

/* column does not exists in previous_application.csv */
delete from yk_data_struct where column_name = 'NFLAG_MICRO_CASH' and table_name = 'previous_application';
  
/* setup correct sequence number */
select setval('yk_data_struct_id_seq',  (select max(id) from yk_data_struct));

/* add records for APPLICATION_TEST table */
insert into yk_data_struct 
select nextval('yk_data_struct_id_seq') as id,
	   'application_test' as table_name,
	   column_name,
	   column_description,
	   special
from yk_data_struct where table_name = 'application_train' and column_name <> 'TARGET';

/*
 * 
 * Creation of tables based on data structure table
 * 
 * */

select distinct table_name from yk_data_struct order by 1;

CALL yk_create_tables('yk_data_struct');

CALL yk_fill_tables('yk_data_struct','/home/jovyan/ecam_ds/data/input/');

CALL yk_csv_to_table('POS_CASH_balance','/home/jovyan/ecam_ds/data/input/POS_CASH_balance.csv');