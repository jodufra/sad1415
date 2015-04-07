-- t_data_* from ext tables
-- #CREATE TABLE t_data_managers_new();
-- #CREATE TABLE t_data_managers_old AS SELECT * FROM t_data_managers_new;

CREATE TABLE t_data_avaliacoes(
	cd_lectivo	VARCHAR2(7), 
	cd_duracao	VARCHAR2(2), 
	cd_aluno	NUMBER(38), 
	cd_curso_aluno	NUMBER(38), 
	cd_discip	NUMBER(38), 
	cd_plano	NUMBER(38), 
	cd_epoca_aval	NUMBER(38), 
	ds_epoca_aval 	VARCHAR2(50), 
	nr_avalia	NUMBER(38), 
	rejected_by_screen CHAR	DEFAULT(0)	-- {0=not rejected,1=rejected,will not be used on LOAD stage}
);

CREATE TABLE t_data_cursos(
	cd_curso	NUMBER(38), 
	cd_oficial	VARCHAR2(4), 
	nm_curso	VARCHAR2(240), 
	nm_cur_abr	VARCHAR2(40), 
	cd_instituic	NUMBER(38), 
	cd_regime	VARCHAR2(500), 
	ds_area_estudo	VARCHAR2(100), 
	ds_grau	VARCHAR2(100), 
	cd_activo	VARCHAR2(1), 
	cd_bolonha	VARCHAR2(1), 
	rejected_by_screen CHAR	DEFAULT(0)	-- {0=not rejected,1=rejected,will not be used on LOAD stage}
);

CREATE TABLE t_data_estudantes(
	cd_curso  NUMBER(38), 
	cd_aluno  NUMBER(38),
	rejected_by_screen CHAR	DEFAULT(0)	-- {0=not rejected,1=rejected,will not be used on LOAD stage}
);

CREATE TABLE t_data_inscricoes(
	cd_lectivo  VARCHAR2(7),
	cd_curso_aluno  NUMBER(38),
	cd_plano  NUMBER(38),
	cd_ramo  NUMBER(38),
	cd_discip  NUMBER(38),
	cd_aluno  NUMBER(38),
	dt_inscri	DATE ,
	cd_tipo_insc  NUMBER(38),
	ds_tipo_insc	VARCHAR2(50),
	ects	FLOAT(126),
	cd_epoca_aval	NUMBER,
	ds_epoca_aval	VARCHAR2(50),
	rejected_by_screen CHAR	DEFAULT(0)	-- {0=not rejected,1=rejected,will not be used on LOAD stage}
);

CREATE TABLE t_data_planos(
	cd_curso  NUMBER(38),
	cd_plano  NUMBER(38),
	nm_plano	VARCHAR2(280),
	cd_activo	VARCHAR2(1),
	nr_ects_curso	NUMBER(38),
	nr_duracao_curso	NUMBER(38),
	rejected_by_screen CHAR	DEFAULT(0)	-- {0=not rejected,1=rejected,will not be used on LOAD stage}
);

CREATE TABLE t_data_ramos(
	cd_curso  NUMBER(38), 
	cd_plano  NUMBER(38), 
	cd_ramo  NUMBER(38), 
	nm_ramo	VARCHAR2(280), 
	rejected_by_screen CHAR	DEFAULT(0)	-- {0=not rejected,1=rejected,will not be used on LOAD stage}
);

CREATE TABLE t_data_unidades_curriculares(
	cd_plano  NUMBER(38),
	cd_discip  NUMBER(38),
	ds_discip	VARCHAR2(200),
	ds_abreviatura	VARCHAR2(15),
	cd_duracao	VARCHAR2(2),
	cd_ramo  NUMBER(38),
	cd_curso  NUMBER(38),
	rejected_by_screen CHAR	DEFAULT(0)	-- {0=not rejected,1=rejected,will not be used on LOAD stage}
);

CREATE TABLE t_data_unidades_organicas(
	cd_instituic  NUMBER(38),
	ds_instituic  VARCHAR2(100),
	ds_inst_abr	VARCHAR2(30),
	rejected_by_screen CHAR	DEFAULT(0)	-- {0=not rejected,1=rejected,will not be used on LOAD stage}
);