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

/*
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
*/

---------

/*
CREATE OR REPLACE FUNCTION f_exec1(VARIADIC text[]) 
  RETURNS void LANGUAGE plpgsql AS 
$BODY$  
BEGIN  
   RAISE EXCEPTION 'Reading % % %!', $1[1], $1[2], $1[3];
END;  
$BODY$;
*/



--------





CREATE TABLE artistes
(
	nom varchar(60) NOT NULL,
	ganre varchar(20) NOT NULL,
	nationalite varchar(60) NOT NULL,
	PRIMARY KEY (nom)
);

insert into artistes values('madonna','pop','usa');
insert into artistes values('aznavour','chanson','france');

select * from artistes;

drop table albums;
CREATE TABLE albums
(
	titre varchar(255) NOT NULL,
	annee interval year default '2004' check(annee>'1900' and annee>'2100') NOT NULL,
	artiste_nom varchar(60) NOT NULL,
    constraint fk_artists 
    	foreign key (artiste_nom) 
	    REFERENCES artistes (nom),
	PRIMARY KEY (titre)
);

select * from albums;

insert into albums values('True Blue','1986','madonna');
insert into albums values('La mamma','1963','aznavour');

select a1.nom,a2.titre from artistes a1 , albums a2 where a2.artiste_nom = a1.nom


----

drop table chansons;
CREATE TABLE chansons
(
	titre varchar(255) NOT NULL,
	album varchar(255) NOT NULL,
	numero smallint,
	duree interval second not null,
    constraint fk_album 
    	foreign key (album) 
	    REFERENCES albums (titre),
	PRIMARY KEY (titre),
	unique(album,numero)
);


--delete from chansons where titre = 'Jimmy Jimmy';
insert into chansons values('Je t''attends','La mamma','3','187');
insert into chansons values('Les aventuriers','La mamma','5','155');
insert into chansons values('Jimmy Jimmy','True Blue','8','235');
insert into chansons values('La Isla Bonita','True Blue','7','242');

select * from chansons;

select a1.nom,a2.titre,c1.titre 
from artistes a1 , albums a2,chansons c1 
where a2.artiste_nom = a1.nom and c1.album = a2.titre;

ALTER TABLE chansons ADD COLUMN artiste varchar(60);
ALTER TABLE chansons
	ALTER COLUMN numero SET NOT NULL;
ALTER TABLE artistes ADD CONSTRAINT ganre_limit CHECK (ganre in ('ROCK','Hard Rock', 'Jazz','chanson','pop')); 


ALTER TABLE chansons
	ALTER COLUMN artiste TYPE varchar(60);
ALTER TABLE chansons ADD constraint fk_artiste foreign key (artiste) REFERENCES artistes (nom);

select * from chansons;

update chansons set artiste = (
select alb.artiste_nom 
from albums alb
where
chansons.album = alb.titre);

GRANT SELECT ON artistes TO PUBLIC;
GRANT SELECT,INSERT,UPDATE ON albums TO PUBLIC;
GRANT ALL PRIVILEGES ON chansons TO PUBLIC;
