CREATE TABLE t_ext_areas_cientificas(
	nome		VARCHAR2(150),
	sigla		VARCHAR2(10)
)
ORGANIZATION EXTERNAL
(
	TYPE oracle_loader
	DEFAULT DIRECTORY src_files
	ACCESS PARAMETERS
	(
		RECORDS DELIMITED BY newline
		BADFILE 'areas_cientificas_g6.bad'
		DISCARDFILE 'areas_cientificas_g6.dis'
		LOGFILE 'areas_cientificas_g6.log'
		SKIP 1
		FIELDS TERMINATED BY ";" OPTIONALLY ENCLOSED BY '"' MISSING FIELD VALUES ARE NULL
		(
			nome		CHAR(150),
			sigla		CHAR(10)
		)
	)
	LOCATION ('Areas_Cientificas.csv')
)
REJECT LIMIT UNLIMITED;