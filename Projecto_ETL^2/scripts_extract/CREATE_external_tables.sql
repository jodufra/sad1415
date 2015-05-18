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


CREATE TABLE t_ext_cursos(
	uc_nome		VARCHAR2(150),
	area_cientifica_sigla		VARCHAR2(20),
	departamento_sigla		VARCHAR2(20)
)
ORGANIZATION EXTERNAL
(
	TYPE oracle_loader
	DEFAULT DIRECTORY src_files
	ACCESS PARAMETERS
	(
		RECORDS DELIMITED BY newline
		BADFILE 'Cursos_g6.bad'
		DISCARDFILE 'Cursos_g6.dis'
		LOGFILE 'Cursos_g6.log'
		SKIP 0
		FIELDS TERMINATED BY ";" OPTIONALLY ENCLOSED BY '"' MISSING FIELD VALUES ARE NULL
		(
			uc_nome		CHAR(150),
			area_cientifica_sigla		CHAR(20),
			departamento_sigla		CHAR(20)
		)
	)
	LOCATION ('Curso_EI.csv','Curso_IS.csv','Curso_JDM.csv','Curso_MEI-CM.csv')
)
REJECT LIMIT UNLIMITED;