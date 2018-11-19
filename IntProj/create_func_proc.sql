/*
 * Script which creates helper functions and 
 * procedures for project 'Integration des donnee' ECAM 2018-2019
 * author Yaroslav Konyshev
 */


CREATE OR REPLACE PROCEDURE yk_cleanup()
AS $$
DECLARE
name_to_drop text;
cur refcursor;

req text;
BEGIN
	req :='SELECT routine_name 
	  		 FROM information_schema.routines 
			WHERE routines.specific_schema=''public''';

	OPEN cur FOR EXECUTE(req); 
	LOOP 
	   	FETCH cur INTO name_to_drop;
	    EXIT WHEN NOT FOUND;
--		raise notice 'proc_name= %',proc_name;
	   EXECUTE format('DROP PROCEDURE IF EXISTS %s ;', name_to_drop);	  		
	END LOOP;
	CLOSE cur;

	req := 'SELECT table_name
  			  FROM information_schema.tables 
			 WHERE table_schema=''public'' and table_name not in (''albums'',''artistes'',''chansons'')';

	OPEN cur FOR EXECUTE(req); 
	LOOP 
	   	FETCH cur INTO name_to_drop;
	    EXIT WHEN NOT FOUND;
--		raise notice 'proc_name= %',proc_name;
	   	EXECUTE format('DROP TABLE IF EXISTS %s ;', name_to_drop);	  		
	END LOOP;
	CLOSE cur;

END;
$$ LANGUAGE plpgsql;



CREATE OR REPLACE PROCEDURE yk_csv_to_table(in_target_table text,in_csv_path text)
AS $$
DECLARE
--var_column_names text;
cmd_str text;
BEGIN
	/*
	SELECT string_agg(column_name, ',') into var_column_names
	 FROM information_schema.columns
	WHERE table_schema = 'public'
	  AND table_name   = in_target_table;
	*/
	
	EXECUTE format('DELETE FROM %s;', in_target_table);
	cmd_str := format(E'copy %s from %L DELIMITER \',\' CSV HEADER;',
						lower(in_target_table), 
						in_csv_path);

/*
	cmd_str := format(E'copy %s(%s) from %L DELIMITER \',\' CSV HEADER;',
						in_target_table, 
						var_column_names, 
						in_csv_path);
*/
	raise notice 'Command to execute: %',cmd_str;
	execute cmd_str;
END;
$$ LANGUAGE plpgsql;


/* Procedure for creation tables based on initial table with data structure */
CREATE OR REPLACE PROCEDURE yk_create_tables(in_data_struct_table text)
AS $$
DECLARE
table_name TEXT;
column_name TEXT;
curs_tables_req TEXT;
curs_columns_req TEXT;

curs_tables refcursor;
curs_columns refcursor;
BEGIN
	curs_tables_req := format(E'select distinct table_name from %s',in_data_struct_table);
--	RAISE NOTICE '%',curs_tables_req;

	OPEN curs_tables FOR EXECUTE(curs_tables_req); 
	LOOP 
	   	FETCH curs_tables INTO table_name;
	    EXIT WHEN NOT FOUND;
		EXECUTE format('CREATE TABLE IF NOT EXISTS %s()', table_name);	  

		curs_columns_req := format(E'select column_name from %s where table_name = %L',in_data_struct_table,table_name);
		RAISE NOTICE 'Created table %',table_name;
	
		OPEN curs_columns FOR EXECUTE(curs_columns_req); 
		LOOP 
		   	FETCH curs_columns INTO column_name;
		    EXIT WHEN NOT FOUND;
			EXECUTE format('ALTER TABLE %s ADD COLUMN %s text;', table_name,column_name);	  		
		END LOOP;
		CLOSE curs_columns;

	END LOOP;

	CLOSE curs_tables;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE yk_fill_tables(in_data_struct_table text,in_path_prefix text)
AS $$
DECLARE
table_name TEXT;
full_path TEXT;
curs_tables_req TEXT;

curs_tables refcursor;
BEGIN
	curs_tables_req := format(E'select distinct table_name from %s',in_data_struct_table);

	OPEN curs_tables FOR EXECUTE(curs_tables_req); 
	LOOP 
	   	FETCH curs_tables INTO table_name;
	    EXIT WHEN NOT FOUND;
		full_path := format(E'%s%s.csv',in_path_prefix,table_name);
--		RAISE NOTICE '%',full_path;
		CALL yk_csv_to_table(table_name,full_path);
		RAISE NOTICE 'Filled %',table_name;
	END LOOP;

	CLOSE curs_tables;
END;
$$ LANGUAGE plpgsql;