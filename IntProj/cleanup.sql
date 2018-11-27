/*
 * 
 * Cleanup of functions, procedures, tables related to the project
 * 
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
	   EXECUTE format('DROP PROCEDURE IF EXISTS %s ;', name_to_drop);	  		
	END LOOP;
	CLOSE cur;

	req := 'SELECT table_name
  			  FROM information_schema.tables 
			 WHERE table_schema=''public''';

	OPEN cur FOR EXECUTE(req); 
	LOOP 
	   	FETCH cur INTO name_to_drop;
	    EXIT WHEN NOT FOUND;
	   	EXECUTE format('DROP TABLE IF EXISTS %s CASCADE;', name_to_drop);	  		
	END LOOP;
	CLOSE cur;
END;
$$ LANGUAGE plpgsql;

/* cleanup */
call yk_cleanup();
COMMIT;