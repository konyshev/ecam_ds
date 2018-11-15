/* connection test */
--select * from pg_tables;

/* creation of tables */
/*
CREATE TABLE sample_submission
(
  SK_ID_CURR character varying(10),
  TARGET character varying(10)
);
*/

/* import */
--copy sample_submission(sk_id_curr,target) 
--from '/home/jovyan/ecam_ds/data/input/sample_submission.csv' DELIMITER ',' CSV HEADER;

/* cleanup */
--drop table sample_submission;

/* check */
--select count(target) from sample_submission;

/* export */
--COPY sample_submission TO '/home/jovyan/ecam_ds/data/sample_submission_db.csv' DELIMITER ',' CSV HEADER;

--select tablename from pg_tables limit 5;

--call function
--select get_userid('qweqwe');

--call procedure
--CALL yk_csv_to_table('qweqe');


CREATE FUNCTION yk_import_to_table(filename text, table_name text) RETURNS NULL 
AS $$
DECLARE
    quantity integer := 30;
BEGIN
    RAISE NOTICE 'Quantity here is %', quantity;  -- Prints 30
    quantity := 50;

    DECLARE
        quantity integer := 80;
    BEGIN
        RAISE NOTICE 'Quantity here is %', quantity;  -- Prints 80
        RAISE NOTICE 'Outer quantity here is %', outerblock.quantity;  -- Prints 50
    END;

    RAISE NOTICE 'Quantity here is %', quantity;  -- Prints 50

    RETURN quantity;
END;
$$ LANGUAGE plpgsql;


---------


CREATE OR REPLACE FUNCTION f_exec1(VARIADIC text[]) 
  RETURNS void LANGUAGE plpgsql AS 
$BODY$  
BEGIN  
   RAISE EXCEPTION 'Reading % % %!', $1[1], $1[2], $1[3];
END;  
$BODY$;
