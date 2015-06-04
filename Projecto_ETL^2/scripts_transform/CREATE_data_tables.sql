CREATE TABLE t_clean_avaliacoes(
	epoca_natural_key VARCHAR2(20),
	cd_duracao VARCHAR2(10), 
	cd_aluno NUMBER(38), 
	cd_curso_aluno NUMBER(38), 
	cd_discip NUMBER(38), 
	cd_plano NUMBER(38), 
	ds_epoca_aval VARCHAR2(50), 
	nr_avalia NUMBER(38) 
);

CREATE TABLE t_clean_cursos(
	curso_natural_key NUMBER(38), 
	curso_oficial_key VARCHAR2(4), 
	curso_nome VARCHAR2(240), 
	curso_nome_abv VARCHAR2(38), 
	curso_regime VARCHAR2(500), 
	curso_grau VARCHAR2(100), 
	curso_activo VARCHAR2(3), 
	curso_bolonha VARCHAR2(3),
	curso_instituicao_key NUMBER(*,0),
	curso_instituicao_nome VARCHAR2(100),
	curso_instituicao_nome_abv VARCHAR2(30)
);

CREATE TABLE t_clean_estudantes(
	estudante_natural_key NUMBER(38),
	curso_key NUMBER(38)
);

CREATE TABLE t_clean_inscricoes(
	epoca_natural_key VARCHAR2(20),
	cd_curso_aluno NUMBER(38),
	cd_plano NUMBER(38),
	cd_ramo NUMBER(38),
	cd_discip NUMBER(38),
	cd_aluno NUMBER(38),
	dt_inscri DATE,
	cd_tipo_insc NUMBER(38),
	ds_tipo_insc VARCHAR2(50),
	ects FLOAT(126),
	ds_epoca_aval VARCHAR2(50)
);

CREATE TABLE t_clean_tipos_inscricao(
	tipo_insc_natural_key NUMBER(38),
	tipo_insc_descricao VARCHAR2(50)
);

CREATE TABLE t_clean_unidades_curriculares(
	uc_natural_key NUMBER(38),
	curso_key NUMBER(38),
	ramo_key NUMBER(38),
	plano_key NUMBER(38),
	uc_nome VARCHAR2(200),
	uc_nome_abv VARCHAR2(10),
	uc_duracao VARCHAR2(10),
	uc_area_cientifica VARCHAR2(150),
	uc_area_cientifica_abv VARCHAR2(10),
	uc_departamento_abv VARCHAR2(10),
	uc_ramo VARCHAR2(280),
	uc_plano  VARCHAR2(280),
	uc_plano_activo VARCHAR2(3),
	uc_plano_ano_semestre VARCHAR2(50)
);

CREATE TABLE t_clean_epoca_avaliacao(
	epoca_natural_key NUMBER(38),
	epoca_descricao VARCHAR2(200),
	epoca_semestre_anoletivo VARCHAR2(100),
	epoca_semestre VARCHAR2(100),
	epoca_anoletivo VARCHAR2(100)
);
