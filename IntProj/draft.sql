/* connection test */
--select * from pg_tables;


/* export */
--COPY sample_submission TO '/home/jovyan/ecam_ds/data/sample_submission_db.csv' DELIMITER ',' CSV HEADER;

--ALTER TABLE artistes ADD CONSTRAINT ganre_limit CHECK (ganre in ('ROCK','Hard Rock', 'Jazz','chanson','pop')); 

--ALTER TABLE chansons
--	ALTER COLUMN artiste TYPE varchar(60);
--ALTER TABLE chansons ADD constraint fk_artiste foreign key (artiste) REFERENCES artistes (nom);

--GRANT SELECT ON artistes TO PUBLIC;
--GRANT SELECT,INSERT,UPDATE ON albums TO PUBLIC;
--GRANT ALL PRIVILEGES ON chansons TO PUBLIC;

--SELECT column_name,ordinal_position
--  FROM information_schema.columns 
-- WHERE table_schema='public' 
--   and table_name = 'application_train';-- and column_name <>'target';

--------


do
$$
declare
remainder smallint;
req text;
begin
	req = format('select max(%s%%1) from %s','amt_credit','application_test');
	RAISE NOTICE '%',req;
	execute req into remainder;
	if remainder>0 then
		RAISE NOTICE 'not zero';
	else 
		raise notice 'zero';
	end if;
end;
$$ LANGUAGE plpgsql;


DO
$$
DECLARE 
table_name TEXT;
column_name TEXT;
alter_req TEXT;
BEGIN
	table_name := 'bureau';
	column_name := 'sk_bureau_id';--'credit_active';
	alter_req := format('ALTER TABLE %s 
						 	ALTER COLUMN %s TYPE NUMERIC USING %s::NUMERIC;'
				,table_name,column_name,column_name); 
	EXECUTE alter_req;
EXCEPTION 
	WHEN datatype_mismatch THEN
		RAISE NOTICE 'Caught Exception: datatype_mismatch';
	WHEN invalid_text_representation THEN
		RAISE NOTICE 'Caught Exception: invalid_text_representation';	
	WHEN OTHERS THEN
    	raise notice 'Caught exception % %', SQLERRM, SQLSTATE;
END;
$$ LANGUAGE plpgsql;

 
do
$$
declare
remainder smallint;
req text;
begin
	req = format('select max(%s%%1) from %s','amt_credit','application_test');
	RAISE NOTICE '%',req;
	execute req into remainder;
	if remainder>0 then
		RAISE NOTICE 'not zero';
	else 
		raise notice 'zero';
	end if;
end;
$$ LANGUAGE plpgsql;

call yk_change_column_types('yk_data_struct');

SELECT table_name,column_name,data_type
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name   = 'application';

 
 select min(target) from application; --target is bigint ????
 select null>min_smallint();
 select min(basementarea_avg)<-max_real() from application_test;



do
$$
declare
in_path_prefix text;
req text;
cur_table text;
full_path text;

curs_tables refcursor;

begin
	CREATE TEMP TABLE yk_tmp_tables(table_name text) ON COMMIT DROP;	

	in_path_prefix := '/home/jovyan/ecam_ds/data/input/'; 
	req := format(E'COPY yk_tmp_tables FROM PROGRAM \'ls -1 %I | sed \"s/.csv//\" \' DELIMITER \',\' CSV HEADER;', in_path_prefix);
	EXECUTE req;

	req := format(E'select distinct table_name from yk_tmp_tables');
	OPEN curs_tables FOR EXECUTE(req); 
	LOOP 
	   	FETCH curs_tables INTO cur_table;
	    EXIT WHEN NOT FOUND;
	   	
	    -- Save column names to tmp table
		CREATE TEMP TABLE yk_tmp_cols(cols text) ON COMMIT DROP;
		full_path := format(E'%s%s.csv',in_path_prefix,cur_table);
	    req := format(E'COPY yk_tmp_cols FROM PROGRAM \'head -n1 %I\' DELIMITER \',\' CSV HEADER;', full_path);
		EXECUTE req;
	
		-- Tables creation
		EXECUTE (
		      SELECT format('CREATE TABLE %I(', cur_table)
					 || string_agg(quote_ident(col) || ' text', ',')
			     	 || ')'
			  FROM  (SELECT cols FROM yk_tmp_cols LIMIT 1) t
		       , unnest(string_to_array(t.cols, E'\t')) col
	      );
	
		-- Import data		
		CALL yk_csv_to_table(cur_table,full_path,debug);	   
	   	COMMIT;		
	END LOOP;
	CLOSE curs_tables;
end;
$$ LANGUAGE plpgsql;


select * from yk_tmp_cols;

SELECT 'CREATE TABLE application_train('
					 || string_agg(quote_ident(col) || ' text', ',')
			     	 || ')'
			  FROM  (SELECT cols FROM yk_tmp_cols LIMIT 1) t
		       , unnest(string_to_array(t.cols, E',')) col
		       
SELECT --string_agg(quote_ident(col) || ' text', ',')
select col.*
FROM  (SELECT cols FROM yk_tmp_cols LIMIT 1) t
	, unnest(string_to_array(t.cols, E',')) col





do
$$
declare
req text;
in_file text;
begin
in_file := '/home/jovyan/ecam_ds/data/input/application_train.csv'; 
req := format(E'COPY yk_tmp_cols FROM PROGRAM \'head -n1 %I\';', in_file);
raise notice '%s',req; 
execute req;
--commit;
end;
$$ LANGUAGE plpgsql;

CREATE TABLE yk_tmp_tables(table_name text);
select * from yk_tmp_cols;


SELECT table_name
  			  FROM information_schema.tables 
			 WHERE table_schema='public';

select * from yk_tmp_tables;
			

select * from yk_tmp_tables;