/* table yako_data_structure */


CREATE TABLE yako_data_structure
(
id numeric,
table_name character varying(50),
column_name character varying(50),
column_description character varying(1000),
special character varying(400)
);

drop table yako_data_structure;

select * from yako_data_structure;
/* import */
copy yako_data_structure(id,table_name,column_name,column_description,special) 
from '/home/jovyan/ecam_ds/data/input/HomeCredit_columns_description.csv' DELIMITER ',' CSV HEADER;
