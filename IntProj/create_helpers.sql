/*
 * Script which creates helper functions and 
 * procedures for project 'Integration des donnee' ECAM 2018-2019
 * author Yaroslav Konyshev
 *
 */

create or replace function MAX_SMALLINT() returns smallint immutable language sql as '
  select 32767::smallint;
';

create or replace function MIN_SMALLINT() returns smallint immutable language sql as '
  select -max_smallint()::smallint;
';

create or replace function MAX_INT() returns integer immutable language sql as '
  select 2147483647::integer;
';

create or replace function MIN_INT() returns integer immutable language sql as '
  select -max_int()::integer;
';

create or replace function MAX_BIGINT() returns bigint immutable language sql as '
  select 9223372036854775807::bigint;
';

create or replace function MIN_BIGINT() returns bigint immutable language sql as '
  select -max_bigint()::bigint;
';

create or replace function MAX_REAL() returns real immutable language sql as '
  select 1E+37::real;
';

create or replace function MIN_REAL() returns real immutable language sql as '
  select -max_real()::real;
';

CREATE OR REPLACE PROCEDURE yk_convert_col_to_proper_int(in_table text,in_col text)
AS $$
DECLARE
c_min bigint;
c_max bigint;
proper_type varchar(100);
alter_req text;
BEGIN
	execute format('select min(%s) from %s',in_col,in_table) into c_min;
	execute format('select max(%s) from %s',in_col,in_table) into c_max;
    if c_min > min_smallint() and c_max < max_smallint() then
        proper_type := 'smallint';
    elsif c_min > min_int() and c_max < max_int() then
        proper_type := 'int';
    else
        proper_type := 'bigint';
	end if;

	BEGIN
		alter_req := format('ALTER TABLE %s 
						 	 	ALTER COLUMN %s TYPE %s USING %s::%s;'
					,in_table,in_col,proper_type,in_col,proper_type); 
		EXECUTE alter_req;
--		RAISE NOTICE '%.% converted to %',in_table,in_col,proper_type;
	EXCEPTION 
		WHEN OTHERS THEN
	    	raise notice 'Caught exception % %', SQLERRM, SQLSTATE;
	END;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE yk_convert_col_to_proper_float(in_table text,in_col text)
AS $$
DECLARE
c_min numeric;
c_max numeric;
proper_type varchar(100);
alter_req text;
BEGIN
	execute format('select min(%s) from %s',in_col,in_table) into c_min;
	execute format('select max(%s) from %s',in_col,in_table) into c_max;
    if c_min > min_real() and c_max < max_real() then
        proper_type := 'real';
    else
        proper_type := 'double precision';
	end if;

	BEGIN
		alter_req := format('ALTER TABLE %s 
						 	 	ALTER COLUMN %s TYPE %s USING %s::%s;'
					,in_table,in_col,proper_type,in_col,proper_type); 
		EXECUTE alter_req;
--		RAISE NOTICE '%.% converted to %',in_table,in_col,proper_type;
	EXCEPTION 
		WHEN OTHERS THEN
	    	raise notice 'Caught exception % %', SQLERRM, SQLSTATE;
	END;
END;
$$ LANGUAGE plpgsql;


/*
head in windows:
https://stackoverflow.com/questions/9682024/how-to-do-what-head-tail-more-less-sed-do-in-powershell

COPY limit numbers from file

 https://stackoverflow.com/questions/51862739/postgres-limit-number-of-rows-copy-from

 https://dba.stackexchange.com/questions/105603/copying-csv-file-to-temp-table-with-dynamic-number-of-columns
 
 */

CREATE OR REPLACE PROCEDURE yk_csv_to_table(in_target_table text,in_csv_path text,debug bool)
AS $$
DECLARE
var_column_names text;
cmd_str text;
tmp_str text;
BEGIN
--	RAISE NOTICE 'Removing all data from table: % ...',in_target_table;	
	EXECUTE format('DELETE FROM %s;', in_target_table);
					
	RAISE NOTICE 'Copying data to table: % ...',in_target_table;

	IF debug=true THEN
		cmd_str := format(E'copy %s from PROGRAM \'head -n100000 %I\' DELIMITER \',\' CSV HEADER;',
							lower(in_target_table), 
							in_csv_path);		
	ELSE
		cmd_str := format(E'copy %s from %L DELIMITER \',\' CSV HEADER;',
							lower(in_target_table),
							in_csv_path);
	END IF;
	EXECUTE cmd_str;
	RAISE NOTICE 'Done.';
END;
$$ LANGUAGE plpgsql;


/* Procedure for creation tables based on initial table with data structure */
CREATE OR REPLACE PROCEDURE yk_create_tables(in_folder text,debug bool)
AS $$
declare
req text;
cur_table text;
full_path text;

curs_tables refcursor;

begin
	CREATE TABLE IF NOT EXISTS yk_data_struct(table_name text);	
 
	req := format(E'COPY yk_data_struct FROM PROGRAM \'ls -1 %I | sed \"s/.csv//\" \' DELIMITER \',\';', 
					in_folder);
	EXECUTE req;

	req := format(E'select distinct table_name from yk_data_struct');
	OPEN curs_tables FOR EXECUTE(req); 
	LOOP 
	   	FETCH curs_tables INTO cur_table;
	    EXIT WHEN NOT FOUND;
	   	
	    -- Save column names to tmp table
		CREATE TEMP TABLE IF NOT EXISTS yk_tmp_cols(cols text) ON COMMIT DROP;
		full_path := format(E'%s%s.csv',in_folder,cur_table);
	    req := format(E'COPY yk_tmp_cols FROM PROGRAM \'head -n1 %I\';', full_path);
	    EXECUTE req;
	   
		-- Tables creation
		SELECT format('CREATE TABLE %I(',lower(cur_table))
				|| string_agg(quote_ident(REPLACE (lower(col),' ','')) || ' text', ',')
			    || ')' into req
			  FROM  (SELECT cols FROM yk_tmp_cols LIMIT 1) t
		       		, unnest(string_to_array(t.cols, ',')) col;

		EXECUTE req;	
		-- Import data		
		CALL yk_csv_to_table(cur_table,full_path,debug);
		--Cleanup
		DELETE FROM yk_tmp_cols;
	END LOOP;
	CLOSE curs_tables;
end;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE yk_change_column_types(in_data_struct_table text)
AS $$
DECLARE
table_name TEXT;
column_name TEXT;
curs_tables_req TEXT;
curs_columns_req TEXT;
alter_req TEXT;
req TEXT;
remainder smallint;

curs_tables refcursor;
curs_columns refcursor;
BEGIN
	curs_tables_req := format(E'select distinct table_name from %s;' ,in_data_struct_table);

	OPEN curs_tables FOR EXECUTE(curs_tables_req); 
	LOOP 
	   	FETCH curs_tables INTO table_name;
	    EXIT WHEN NOT FOUND;

		curs_columns_req := format(E'SELECT column_name 
									 FROM information_schema.columns 
									 WHERE table_schema = ''public'' 
									   and table_name = %L;'
							,lower(table_name));
	
		OPEN curs_columns FOR EXECUTE(curs_columns_req); 
		LOOP 
		   	FETCH curs_columns INTO column_name;
		    EXIT WHEN NOT FOUND;
			BEGIN
				alter_req := format('ALTER TABLE %s 
								 	 	ALTER COLUMN %s TYPE NUMERIC USING %s::NUMERIC;'
							,table_name,column_name,column_name); 
--				RAISE NOTICE 'Conversion of %.% to numeric...',table_name,column_name;
				EXECUTE alter_req;
				-- if type is numeric we continue
--				RAISE NOTICE 'Change to proper number type %.% ...',table_name,column_name;
				req = format('select max(%s%%1) from %s;',column_name,table_name);
				execute req into remainder;
				if remainder>0 then
					call yk_convert_col_to_proper_float(table_name,column_name);
				else 
					call yk_convert_col_to_proper_int(table_name,column_name);
				end if;
--				RAISE NOTICE '-----';
			EXCEPTION 
				WHEN invalid_text_representation THEN
--					RAISE NOTICE 'Caught Exception: invalid_text_representation. Column %.% stays TEXT',table_name,column_name;
--			    	raise notice '-----';
				WHEN OTHERS THEN
			    	raise notice 'Caught exception % %', SQLERRM, SQLSTATE;
--			    	raise notice '-----';
			END;
		END LOOP;
	
		CLOSE curs_columns;
	END LOOP;

	CLOSE curs_tables;
END;
$$ LANGUAGE plpgsql;

