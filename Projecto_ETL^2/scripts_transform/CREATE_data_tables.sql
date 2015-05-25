CREATE TABLE t_clean_avaliacoes(
	cd_lectivo	VARCHAR2(7), 
	cd_duracao	VARCHAR2(2), 
	cd_aluno	NUMBER(38), 
	cd_curso_aluno	NUMBER(38), 
	cd_discip	NUMBER(38), 
	cd_plano	NUMBER(38), 
	cd_epoca_aval	NUMBER(38), 
	ds_epoca_aval 	VARCHAR2(50), 
	nr_avalia	NUMBER(38) 
);

CREATE TABLE t_clean_cursos(
	cd_curso	NUMBER(38), 
	cd_oficial	VARCHAR2(4), 
	nm_curso	VARCHAR2(240), 
	nm_cur_abr	VARCHAR2(40), 
	cd_instituic	NUMBER(38), 
	cd_regime	VARCHAR2(500), 
	ds_area_estudo	VARCHAR2(100), 
	ds_grau	VARCHAR2(100), 
	cd_activo	VARCHAR2(1), 
	cd_bolonha	VARCHAR2(1) 
);

CREATE TABLE t_clean_estudantes(
	cd_curso  NUMBER(38), 
	cd_aluno  NUMBER(38)
);

CREATE TABLE t_clean_inscricoes(
	cd_lectivo  VARCHAR2(7),
	cd_curso_aluno  NUMBER(38),
	cd_plano  NUMBER(38),
	cd_ramo  NUMBER(38),
	cd_discip  NUMBER(38),
	cd_aluno  NUMBER(38),
	dt_inscri	DATE,
	cd_tipo_insc  NUMBER(38),
	ds_tipo_insc	VARCHAR2(50),
	ects	FLOAT(126),
	cd_epoca_aval	NUMBER,
	ds_epoca_aval	VARCHAR2(50)
);

CREATE TABLE t_clean_planos(
	cd_curso  NUMBER(38),
	cd_plano  NUMBER(38),
	nm_plano	VARCHAR2(280),
	cd_activo	VARCHAR2(1),
	nr_ects_curso	NUMBER(38),
	nr_duracao_curso	NUMBER(3)
);

CREATE TABLE t_clean_ramos(
	cd_curso  NUMBER(38), 
	cd_plano  NUMBER(38), 
	cd_ramo  NUMBER(38), 
	nm_ramo	VARCHAR2(280) 
);

CREATE TABLE t_clean_unidades_curriculares(
	cd_plano  NUMBER(38),
	cd_discip  NUMBER(38),
	ds_discip	VARCHAR2(200),
	ds_abreviatura	VARCHAR2(15),
	cd_duracao	VARCHAR2(2),
	cd_ramo  NUMBER(38),
	cd_curso  NUMBER(38)
);

CREATE TABLE t_clean_unidades_organicas(
	cd_instituic  NUMBER(38),
	ds_instituic  VARCHAR2(100),
	ds_inst_abr	VARCHAR2(30)
);