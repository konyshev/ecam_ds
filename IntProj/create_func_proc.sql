/*
 * Script which creates helper functions and 
 * procedures for project 'Integration des donnee' ECAM 2018-2019
 * author Yaroslav Konyshev
 */


/* Procedure for filling tables from csv files */

DROP PROCEDURE IF EXISTS yk_csv_to_table(text,text);

CREATE OR REPLACE PROCEDURE yk_csv_to_table(in_target_table text,in_csv_path text)
AS $$
DECLARE
var_column_names text;
cmd_str text;
BEGIN
	SELECT string_agg(column_name, ',') into var_column_names
	 FROM information_schema.columns
	WHERE table_schema = 'public'
	  AND table_name   = in_target_table;
	
	cmd_str := format(E'copy %s(%s) from %L DELIMITER \',\' CSV HEADER;',
						in_target_table, 
						var_column_names, 
						in_csv_path);
	raise notice 'Command to execute: %',cmd_str;
	execute cmd_str;
END;
$$ LANGUAGE plpgsql;


/* Procedure for creation tables based on initial table with data structure */

DROP PROCEDURE IF EXISTS yk_create_tables(text);

CREATE OR REPLACE PROCEDURE yk_create_tables(in_data_struct_table text)
AS $$
DECLARE
--cmd_str text;
var_table_name TEXT;
var_column_name TEXT;
curs_tables_req TEXT;

curs_tables refcursor;
curs_columns refcursor;
BEGIN
	curs_tables_req := format(E'select distinct table_name from %s',in_data_struct_table);
	--curs_columns_req := format(E'select distinct column_name from yako_data_structure where table_name') = p_tname;

	OPEN curs_tables FOR EXECUTE(curs_tables_req); 
	LOOP 
	   	FETCH curs_tables INTO var_table_name;
	    EXIT WHEN NOT FOUND;
		RAISE NOTICE '%',var_table_name;
--		EXECUTE format('DROP TABLE %I', var_table_name);	   
		EXECUTE format('CREATE TABLE %I()', var_table_name);	   
	END LOOP;

--	RAISE NOTICE '%',curs_req;
END;
$$ LANGUAGE plpgsql;