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



CREATE TABLE client
(
	ncli varchar(10) NOT NULL,
	nom varchar(32) NOT NULL,
	addresse varchar(60) NULL,
	localite varchar(30) NULL,
	cat varchar(2),
	compte decimal(9,2) NULL,
	PRIMARY KEY (ncli));

--select * from client;

CREATE TABLE commande
(
	ncom varchar(12) NOT NULL,
	datecom date NOT NULL,
	ncli varchar(10) NOT NULL,
	PRIMARY KEY (ncom),
	FOREIGN KEY (ncli) REFERENCES client (ncli)
);

select * from commande;

CREATE TABLE detail
(
	ncom varchar(12) NOT NULL,
	npro varchar(15) NOT NULL,
	qcom decimal(8) NOT NULL,
	PRIMARY KEY (ncom,npro),
	FOREIGN KEY (ncom) REFERENCES commande (ncom),
	FOREIGN KEY (npro) REFERENCES produit (npro)
);

select * from commande;


CREATE TABLE produit
(
	npro varchar(15) NOT NULL,
	libelle varchar(60) NOT NULL,
	prix decimal(6) NOT NULL,
	qstock decimal(8) NOT NULL,
	PRIMARY KEY (npro)
);

select * from produit

create index clinom on client(nom);

drop index clinom;
drop table client,commande,produit,detail;

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

