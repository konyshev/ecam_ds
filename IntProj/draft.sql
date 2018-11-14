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

select tablename from pg_tables limit 5;