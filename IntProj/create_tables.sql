/*
 * Project 'Integration donee' ECAM 2018-2019
 * Script for tables creation.
 * autor:Yaroslav Konyshev
 */

/* initial cleanup */
drop table if exists yk_data_struct;

/* create initial table with structure of tables */
CREATE TABLE yk_data_struct
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

/* check and cleanup table*/
select * from yk_data_struct; 
--delete from yk_data_struct;

/*
 * 
 * Modification of initial table
 * 
 * */
					
/* Rename 'application_{train|test}.csv' case */
select distinct table_name from yk_data_struct;

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

/* remove .csv and convert table name to upper case */
update yk_data_struct
set
   table_name = UPPER(REPLACE (
   table_name,
 '.csv',
 ''
   ));

/* setup correct sequence number */
select setval('yk_data_struct_id_seq',  (select max(id) from yk_data_struct));

/* add records for APPLICATION_TEST table */
insert into yk_data_struct 
select nextval('yk_data_struct_id_seq') as id,
	   'APPLICATION_TEST' as table_name,
	   column_name,
	   column_description,
	   special
from yk_data_struct where table_name = 'APPLICATION_TRAIN';

/*
 * 
 * Creation of tables based on data structure table
 * 
 * */

select distinct table_name from yk_data_struct order by 1;

CALL yk_create_tables('yk_data_struct');

--CREATE TABLE yako_application_test();

--select * from yako_application_test;

--drop table yako_application_test;










