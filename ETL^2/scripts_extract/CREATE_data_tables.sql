-- t_data_* from ext tables
#CREATE TABLE t_data_managers_new();
#CREATE TABLE t_data_managers_old AS SELECT * FROM t_data_managers_new;

CREATE TABLE t_data_avaliacoes(
	CD_LECTIVO 	NOT NULL VARCHAR2(7) 
	CD_DURACAO 	NOT NULL VARCHAR2(2) 
	CD_ALUNO 	NOT NULL NUMBER(38) 
	CD_CURSO_ALUNO 	NOT NULL NUMBER(38) 
	CD_DISCIP 	NOT NULL NUMBER(38) 
	CD_PLANO 	NOT NULL NUMBER(38) 
	CD_EPOCA_AVAL 	NOT NULL NUMBER(38) 
	DS_EPOCA_AVAL 	VARCHAR2(50) 
	NR_AVALIA		NUMBER(38) 
	rejected_by_screen CHAR	DEFAULT(0)	-- {0=not rejected,1=rejected,will not be used on LOAD stage}
);

CREATE TABLE t_data_cursos(
	CD_CURSO 	NOT NULL NUMBER(38) 
	CD_OFICIAL		VARCHAR2(4) 
	NM_CURSO	NOT NULL VARCHAR2(240) 
	NM_CUR_ABR		VARCHAR2(40) 
	CD_INSTITUIC		NUMBER(38) 
	CD_REGIME		VARCHAR2(500) 
	DS_AREA_ESTUDO		VARCHAR2(100) 
	DS_GRAU		VARCHAR2(100) 
	CD_ACTIVO		VARCHAR2(1) 
	CD_BOLONHA		VARCHAR2(1) 
	rejected_by_screen CHAR	DEFAULT(0)		-- {0=not rejected,1=rejected,will not be used on LOAD stage}
);

CREATE TABLE t_data_estudantes(
	CD_CURSO NOT NULL NUMBER(38) 
	CD_ALUNO NOT NULL NUMBER(38) 
	rejected_by_screen CHAR	DEFAULT(0)		-- {0=not rejected,1=rejected,will not be used on LOAD stage}
);

CREATE TABLE t_data_inscricoes
	CD_LECTIVO NOT NULL VARCHAR2(7) 
	CD_CURSO_ALUNO NOT NULL NUMBER(38) 
	CD_PLANO NOT NULL NUMBER(38) 
	CD_RAMO NOT NULL NUMBER(38) 
	CD_DISCIP NOT NULL NUMBER(38) 
	CD_ALUNO NOT NULL NUMBER(38) 
	DT_INSCRI          DATE  
	CD_TIPO_INSC NOT NULL NUMBER(38) 
	DS_TIPO_INSC          VARCHAR2(50) 
	ECTS             FLOAT(126) 
	CD_EPOCA_AVAL          NUMBER 
	DS_EPOCA_AVAL          VARCHAR2(50) 
	rejected_by_screen CHAR	DEFAULT(0)		-- {0=not rejected,1=rejected,will not be used on LOAD stage}
);

CREATE TABLE t_data_planos(
	CD_CURSO NOT NULL NUMBER(38) 
	CD_PLANO NOT NULL NUMBER(38) 
	NM_PLANO          VARCHAR2(280) 
	CD_ACTIVO          VARCHAR2(1) 
	NR_ECTS_CURSO          NUMBER(38) 
	NR_DURACAO_CURSO          NUMBER(38) 
	rejected_by_screen CHAR	DEFAULT(0)		-- {0=not rejected,1=rejected,will not be used on LOAD stage}
);

CREATE TABLE t_data_ramos(
	CD_CURSO NOT NULL NUMBER(38) 
	CD_PLANO NOT NULL NUMBER(38) 
	CD_RAMO NOT NULL NUMBER(38) 
	NM_RAMO          VARCHAR2(280) 
	rejected_by_screen CHAR	DEFAULT(0)		-- {0=not rejected,1=rejected,will not be used on LOAD stage}
);

CREATE TABLE t_data_unidades_curriculares(
	CD_PLANO NOT NULL NUMBER(38) 
	CD_DISCIP NOT NULL NUMBER(38) 
	DS_DISCIP          VARCHAR2(200) 
	DS_ABREVIATURA          VARCHAR2(15) 
	CD_DURACAO          VARCHAR2(2) 
	CD_RAMO NOT NULL NUMBER(38) 
	CD_CURSO NOT NULL NUMBER(38) 
	rejected_by_screen CHAR	DEFAULT(0)		-- {0=not rejected,1=rejected,will not be used on LOAD stage}
);

CREATE TABLE t_data_unidades_organicas(
	CD_INSTITUIC NOT NULL NUMBER(38) 
	DS_INSTITUIC NOT NULL VARCHAR2(100) 
	DS_INST_ABR          VARCHAR2(30) 
	rejected_by_screen CHAR	DEFAULT(0)		-- {0=not rejected,1=rejected,will not be used on LOAD stage}
);