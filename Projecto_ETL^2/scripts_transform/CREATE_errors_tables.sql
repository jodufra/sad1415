CREATE TABLE t_errors_date(
	date_key		INTEGER,
	date_full		DATE,
	year_nr		NUMBER(4),
	month_nr		NUMBER(2),
	month_name_full	VARCHAR2(9),
	month_name_short	CHAR(3),
	day_nr_in_week	NUMBER(1),
	day_nr		NUMBER(2),
	day_name_full	VARCHAR2(13),
	day_name_short	CHAR(3),
	CONSTRAINT errors_date_pk PRIMARY KEY (date_key)
);


CREATE TABLE t_errors_iteration(
	iteration_key			INTEGER,
	iteration_start_date		DATE,
	iteration_duration_preview 	INTEGER,	-- in minutes
	iteration_duration_real		INTEGER,
	iteration_nr_tested_lines	INTEGER,
	CONSTRAINT errors_iteration_pk PRIMARY KEY (iteration_key)
);


CREATE TABLE t_errors_source(
	source_key			INTEGER,
	source_table_name		VARCHAR2(100),
	source_is_remote_database	VARCHAR2(3),
      source_file_name		VARCHAR2(100),
	source_database_name	VARCHAR2(100),
	source_description	VARCHAR2(250),
	source_inactive_period	VARCHAR2(100),
	source_DSA_table		VARCHAR2(30),
	source_usual_extract_day	VARCHAR2(9),
	source_usual_extract_hour	CHAR(5),
	source_OS_name		VARCHAR2(50),
	source_OS_version		VARCHAR2(30),
	source_OS_hardware	VARCHAR2(250),
	source_expired		VARCHAR2(3),	-- {YES,NO}
	CONSTRAINT errors_source_pk PRIMARY KEY (source_key)
);


CREATE TABLE t_errors_screen(
	screen_key			INTEGER,
	screen_name			VARCHAR2(30),
	screen_class		VARCHAR2(15),	-- {consistência,completude,correcção}
	screen_type			VARCHAR2(20),	-- {tamanho das colunas,nulidade,contagem,...}
	screen_sql_text		VARCHAR2(2000),
	screen_error_severity	INTEGER,
	screen_action_on_error	VARCHAR2(20),	-- {abortar ETL,passar registo,rejeitar registo}
	screen_stage_to_run	CHAR,			-- 0=before transformation; 1=after transformation
	screen_version		INTEGER,
	screen_expired		VARCHAR2(3),	-- {YES,NO}
	screen_source_key		INTEGER,
	CONSTRAINT errors_screen_pk PRIMARY KEY (screen_key),
	CONSTRAINT errors_screen_source_fk FOREIGN KEY (screen_source_key) REFERENCES t_errors_source(source_key)
);


-- FACT TABLE
CREATE TABLE t_errors_errors(
	date_key		INTEGER,
	screen_key		INTEGER,
	iteration_key	INTEGER,
	source_key		INTEGER,
	record_id		VARCHAR2(100)	NOT NULL,
	error_severity	INTEGER		NOT NULL,
	CONSTRAINT errors_errors_pk PRIMARY KEY (date_key,screen_key,iteration_key,source_key,record_id),
	CONSTRAINT errors_errors_date_fk FOREIGN KEY (date_key) REFERENCES t_errors_date(date_key),
	CONSTRAINT errors_errors_screen_fk FOREIGN KEY (screen_key) REFERENCES t_errors_screen(screen_key),
	CONSTRAINT errors_errors_iteration_fk FOREIGN KEY (iteration_key) REFERENCES t_errors_iteration(iteration_key),
	CONSTRAINT errors_errors_source_fk FOREIGN KEY (source_key) REFERENCES t_errors_source(source_key)
);

-- COVERAGE FACT TABLE
CREATE TABLE t_errors_schedule(
	screen_key		INTEGER,
	iteration_key	INTEGER,
	source_key		INTEGER,
	screen_order	INTEGER,
	CONSTRAINT errors_schedule_pk PRIMARY KEY (screen_key,iteration_key,source_key),
	CONSTRAINT errors_schedule_screen_fk FOREIGN KEY (screen_key) REFERENCES t_errors_screen(screen_key),
	CONSTRAINT errors_schedule_iteration_fk FOREIGN KEY (iteration_key) REFERENCES t_errors_iteration(iteration_key),
	CONSTRAINT errors_schedule_source_fk FOREIGN KEY (source_key) REFERENCES t_errors_source(source_key)
);

