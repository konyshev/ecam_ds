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
p_column_names text;
cmd_str text;
BEGIN
	SELECT string_agg(column_name, ',') into p_column_names
	 FROM information_schema.columns
	WHERE table_schema = 'public'
	  AND table_name   = in_target_table;
	
	cmd_str := format(E'copy %s(%s) from %L DELIMITER \',\' CSV HEADER;',
						in_target_table, 
						p_column_names, 
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
p_column_names text;
cmd_str text;
BEGIN
	SELECT string_agg(column_name, ',') into p_column_names
	 FROM information_schema.columns
	WHERE table_schema = 'public'
	  AND table_name   = in_target_table;
	
	cmd_str := format(E'copy %s(%s) from %L DELIMITER \',\' CSV HEADER;',
						in_target_table, 
						p_column_names, 
						in_csv_path);
	raise notice 'Command to execute: %',cmd_str;
	execute cmd_str;
END;
$$ LANGUAGE plpgsql;


/*
$$
DECLARE
	var_table_name TEXT;
--	var_column_name TEXT;
    curs_tables CURSOR FOR select distinct table_name from yako_data_structure;
--    curs_columns CURSOR(p_tname text) FOR select distinct column_name from yako_data_structure where table_name = p_tname;
BEGIN
	OPEN curs_tables; 
    LOOP 
	   	FETCH curs_tables INTO var_table_name;
	    EXIT WHEN NOT FOUND;

	   	PRINT var_table_name;
--		EXECUTE format('CREATE TABLE %I()', var_table_name);	   
   	END LOOP;

END;$$ 
LANGUAGE plpgsql;
*/