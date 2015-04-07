CREATE TABLE t_info_extractions(
	last_timestamp		TIMESTAMP,
	source_table_name	VARCHAR2(100),
	CONSTRAINT info_extractions_log_uk UNIQUE(source_table_name)
);


CREATE TABLE t_info_file_reading(
	text VARCHAR2(2000)
);