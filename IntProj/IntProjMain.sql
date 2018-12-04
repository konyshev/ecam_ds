DO $$ 
DECLARE 
	ZERO_POINT CONSTANT DATE := '2018-05-18'::DATE - (INTERVAL '100 days');
	CALENDAR_DELTA CONSTANT INTERVAL := INTERVAL '10 years';
BEGIN
	--Creation of tables based on data structure table 
	CALL yk_create_tables('/home/jovyan/ecam_ds/data/input/',TRUE);
	
	ALTER TABLE	application_train DROP	COLUMN target;
	
	CREATE TABLE application AS (
			SELECT * FROM application_test
		UNION ALL
			SELECT * FROM application_train 
		);	
	DROP TABLE	application_test, application_train;
	
	CREATE TABLE client AS (
			SELECT
				sk_id_curr AS id_client,
				(ZERO_POINT + (INTERVAL '1 day' * days_birth::SMALLINT))::DATE AS birthday,
				code_gender AS gender,
				name_education_type AS education_type
			FROM
				application 
		);	
	DROP TABLE	application;
	
	CREATE TABLE credit_types AS (
			SELECT
				DISTINCT DENSE_RANK() OVER(ORDER BY NAME_CONTRACT_TYPE) AS id_type ,
				NAME_CONTRACT_TYPE AS nom_de_type
			FROM
				previous_application 
		);
	
	CREATE TABLE achat_types AS (
			SELECT
				DISTINCT DENSE_RANK() OVER(ORDER BY name_goods_category) AS id_type ,
				name_goods_category AS nom_de_type
			FROM
				previous_application 
		);
	
	CREATE TABLE calendar AS (
			SELECT
				d.date AS DATE,
				EXTRACT(YEAR FROM d.date)::SMALLINT AS YEAR,
				EXTRACT(MONTH FROM d.date)::SMALLINT AS MONTH,
				EXTRACT(WEEK FROM d.date)::SMALLINT AS week_of_year,
				EXTRACT(isodow	FROM d.date)::SMALLINT AS weekday,
				EXTRACT(DAY	FROM d.date)::SMALLINT AS day_of_month
			FROM
				(
					SELECT
						date_trunc('day',dd):: DATE AS DATE
					FROM
						generate_series ( 
							ZERO_POINT - CALENDAR_DELTA ,
							ZERO_POINT + CALENDAR_DELTA ,
							'1 day'::INTERVAL
						) dd 
				)d 
		);
	
	CREATE TABLE demande_de_credit AS (
			SELECT
				p.sk_id_prev AS id_demande,
				p.sk_id_curr AS id_client,
				(ZERO_POINT + (INTERVAL '1 day' * days_decision::SMALLINT))::DATE AS date_de_demande,
				c.id_type AS type_de_credit,
				a.id_type AS type_de_achat,
				p.amt_goods_price AS prix_de_achat,
				p.amt_application AS montant_demande,
				p.amt_credit montant_credit,
				p.name_type_suite AS type_accompagne,
				p.name_contract_status AS status
			FROM
				previous_application p
			LEFT JOIN credit_types c ON
				c.nom_de_type = p.name_contract_type
			LEFT JOIN achat_types a ON
				a.nom_de_type = p.name_goods_category 
		);

	DROP TABLE previous_application;
	
	INSERT INTO	yk_data_struct VALUES ('calendar');
	INSERT INTO	yk_data_struct VALUES ('credit_types');
	INSERT INTO	yk_data_struct VALUES ('demande_de_credit');
	INSERT INTO	yk_data_struct VALUES ('client');
	INSERT INTO	yk_data_struct VALUES ('achat_types');
	
	CALL yk_change_column_types('yk_data_struct');

	DELETE FROM demande_de_credit
		WHERE id_client IN (
			SELECT
				d.id_client
			FROM
				demande_de_credit d
			LEFT OUTER JOIN client c ON
				d.id_client = c.id_client
			WHERE
				c.id_client IS NULL 
			);

	--primary keys
	ALTER TABLE calendar ADD PRIMARY KEY (DATE);
	ALTER TABLE	client ADD PRIMARY KEY (id_client);
	ALTER TABLE credit_types ADD PRIMARY KEY (id_type);
	ALTER TABLE	achat_types ADD PRIMARY KEY (id_type);
	ALTER TABLE	demande_de_credit ADD PRIMARY KEY (id_demande);

	--forign keys
	ALTER TABLE demande_de_credit ADD CONSTRAINT fk_date_de_demande FOREIGN KEY (date_de_demande) REFERENCES calendar (DATE);	
	ALTER TABLE	demande_de_credit ADD CONSTRAINT fk_type_de_credit FOREIGN KEY (type_de_credit) REFERENCES credit_types (id_type);	
	ALTER TABLE	demande_de_credit ADD CONSTRAINT fk_type_de_achat FOREIGN KEY (type_de_achat) REFERENCES achat_types (id_type);	
	ALTER TABLE	demande_de_credit ADD CONSTRAINT fk_id_client FOREIGN KEY (id_client) REFERENCES client (id_client);

	--indexes
	CREATE UNIQUE INDEX idx_id_demande ON	demande_de_credit (id_demande);
	CREATE UNIQUE INDEX idx_client_id_client ON	client (id_client);	
	CREATE INDEX idx_id_client ON demande_de_credit (id_client);
END;

$$ LANGUAGE plpgsql;