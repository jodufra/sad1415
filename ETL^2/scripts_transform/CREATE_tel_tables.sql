CREATE TABLE t_tel_date(
	date_key	NUMBER(10),
	date_full	DATE,
	year_nr		NUMBER(4),
	month_nr	NUMBER(2),
	month_name_full	VARCHAR2(9),
	month_name_short	CHAR(3),
	day_nr_in_week	NUMBER(1),
	day_nr		NUMBER(2),
	day_name_full	VARCHAR2(20),
	day_name_short	CHAR(3),
	CONSTRAINT pk_telDate_dateKey PRIMARY KEY (date_key)
);


CREATE TABLE t_tel_iteration(
	iteration_key			NUMBER(10),
	iteration_start_date		DATE,
	iteration_duration_preview 	INTEGER,	-- in minutes
	iteration_duration_real		INTEGER,
	iteration_nr_tested_lines	INTEGER,
	CONSTRAINT pk_telIteration_iterationKey PRIMARY KEY (iteration_key)
);


CREATE TABLE t_tel_source(
	source_key		NUMBER(5),
	source_table_name	VARCHAR2(100),
	source_is_remote_database	VARCHAR2(3),
	source_file_name	VARCHAR2(100),
	source_database_name	VARCHAR2(100),
	source_description	VARCHAR2(250),
	source_inactive_period	VARCHAR2(100),
	source_DSA_table	VARCHAR2(30),
	source_usual_extract_day	VARCHAR2(9),
	source_usual_extract_hour	CHAR(5),
	source_OS_name		VARCHAR2(50),
	source_OS_version	VARCHAR2(30),
	source_OS_hardware	VARCHAR2(250),
	source_expired		VARCHAR2(3),	-- {YES,NO}
	CONSTRAINT pk_telSource_sourceKey PRIMARY KEY (source_key)
);


CREATE TABLE t_tel_screen(
	screen_key		NUMBER(5),
	screen_name		VARCHAR2(30),
	screen_class		VARCHAR2(15),
	screen_type		VARCHAR2(20),
	screen_sql_text		VARCHAR2(2000),
	screen_error_severity	NUMBER(2),
	screen_action_on_error	VARCHAR2(20),
	screen_stage_to_run	CHAR,			-- 0=before transformation; 1=after transformation
	screen_version		NUMBER(3),
	screen_expired		VARCHAR2(3),		-- {YES,NO}
	screen_source_key	NUMBER(5),
	CONSTRAINT pk_telScreen_screenKey PRIMARY KEY (screen_key),
	CONSTRAINT fk_telScreen_sourceKey FOREIGN KEY (screen_source_key) REFERENCES t_tel_source(source_key)
);


CREATE TABLE t_tel_error(
	date_key	NUMBER(10),
	screen_key	NUMBER(5),
	iteration_key	NUMBER(10),
	source_key	NUMBER(5),
	record_id	VARCHAR2(100)	NOT NULL,
	error_severity	NUMBER(1)	NOT NULL,
	CONSTRAINT pk_telError 		PRIMARY KEY (date_key,screen_key,iteration_key,source_key,record_id),
	CONSTRAINT fk_telError_dateKey 	FOREIGN KEY (date_key) REFERENCES t_tel_date(date_key),
	CONSTRAINT fk_telError_screenKey 	FOREIGN KEY (screen_key) REFERENCES t_tel_screen(screen_key),
	CONSTRAINT fk_telError_iterationKey 	FOREIGN KEY (iteration_key) REFERENCES t_tel_iteration(iteration_key),
	CONSTRAINT fk_telError_sourceKey 	FOREIGN KEY (source_key) REFERENCES t_tel_source(source_key)
);

CREATE TABLE t_tel_schedule(
	screen_key	NUMBER(5),
	iteration_key	NUMBER(10),
	source_key	NUMBER(5),
	screen_order	NUMBER(3),
	CONSTRAINT pk_telSchedule 		PRIMARY KEY (screen_key,iteration_key,source_key),
	CONSTRAINT fk_telSchedule_screenKey 	FOREIGN KEY (screen_key) REFERENCES t_tel_screen(screen_key),
	CONSTRAINT fk_telSchedule_iterationKey FOREIGN KEY (iteration_key) REFERENCES t_tel_iteration(iteration_key),
	CONSTRAINT fk_telSchedule_sourceKey 	FOREIGN KEY (source_key) REFERENCES t_tel_source(source_key)
);

