do
$$
declare
in_path_prefix text;
req text;
create_req text;
cur_table text;
full_path text;

curs_tables refcursor;

begin
	CREATE TEMP TABLE yk_tmp_tables(table_name text);	

	in_path_prefix := '/home/jovyan/ecam_ds/data/input/'; 
	req := format(E'COPY yk_tmp_tables FROM PROGRAM \'ls -1 %I | sed \"s/.csv//\" \' DELIMITER \',\' CSV HEADER;', 
					in_path_prefix);
	EXECUTE req;

	req := format(E'select distinct table_name from yk_tmp_tables');
	OPEN curs_tables FOR EXECUTE(req); 
	LOOP 
	   	FETCH curs_tables INTO cur_table;
	    EXIT WHEN NOT FOUND;
	   	
	    -- Save column names to tmp table
		CREATE TEMP TABLE IF NOT EXISTS yk_tmp_cols(cols text);
		full_path := format(E'%s%s.csv',in_path_prefix,cur_table);
	    req := format(E'COPY yk_tmp_cols FROM PROGRAM \'head -n1 %I\';', full_path);
	    EXECUTE req;

	
		-- Tables creation
		SELECT format('CREATE TABLE %I(',lower(cur_table))
				|| string_agg(quote_ident(col) || ' text', ',')
			    || ')' into req
			  FROM  (SELECT cols FROM yk_tmp_cols LIMIT 1) t
		       		, unnest(string_to_array(t.cols, ',')) col;

--		req := format(E'SELECT \'CREATE TABLE %I(\'
--					 || string_agg(quote_ident(col) || \' text\', \',\')
--			     	 || \')\'
--			  FROM  (SELECT cols FROM yk_tmp_cols LIMIT 1) t
--		       , unnest(string_to_array(t.cols, E\',\')) col', cur_table);
--		raise notice 'req: = %s',req;
--		EXECUTE req INTO create_req;	
--		raise notice 'create_req:= %s',create_req;
		EXECUTE req;	
		-- Import data		
		CALL yk_csv_to_table(table_name,full_path,debug);	   
		DELETE FROM yk_tmp_cols;
	END LOOP;
	CLOSE curs_tables;
	DROP TABLE yk_tmp_cols;
--	DROP TABLE yk_tmp_tables;
end;
$$ LANGUAGE plpgsql;