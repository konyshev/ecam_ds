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
