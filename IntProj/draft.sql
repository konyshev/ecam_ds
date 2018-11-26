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

SELECT table_name,column_name,data_type
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name   = 'bureau';
