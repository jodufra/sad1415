CREATE TABLE t_dim_cursos(
	cursos_key NUMBER(38),
	curso_natural_key NUMBER(38), 
	curso_oficial_key VARCHAR2(4), 
	curso_nome VARCHAR2(240), 
	curso_nome_abv NUMBER(38), 
	curso_regime VARCHAR2(500), 
	curso_grau VARCHAR2(100), 
	curso_activo VARCHAR2(3), 
	curso_bolonha VARCHAR2(3),
	curso_instituicao_key NUMBER(*,0),
	curso_instituicao_nome VARCHAR2(100),
	curso_instituicao_nome_abv VARCHAR2(30),
	is_expired_version	VARCHAR2(3),
	CONSTRAINT pk_tdimcursos_cursosKey PRIMARY KEY (cursos_key)
);

CREATE TABLE t_dim_estudantes(
	estudante_key NUMBER(38), 
	estudante_natural_key NUMBER(38),
	curso_key NUMBER(38),
	is_expired_version	VARCHAR2(3),
	CONSTRAINT pk_tdimestudantes_estudanteKey PRIMARY KEY (estudante_key)
);

CREATE TABLE t_dim_tipos_inscricao(
	tipo_insc_key NUMBER(38),
	tipo_insc_natural_key NUMBER(38),
	tipo_insc_descricao VARCHAR2(50),
	is_expired_version	VARCHAR2(3),
	CONSTRAINT pk_tdimtiposInscricao_tipoInscKey PRIMARY KEY (tipo_insc_key)
);

CREATE TABLE t_dim_unidades_curriculares(
	uc_key NUMBER(38),
	uc_natural_key NUMBER(38),
	curso_key NUMBER(38),
	uc_nome VARCHAR2(200),
	uc_nome_abv VARCHAR2(10),
	uc_duracao VARCHAR2(10),
	uc_area_cientifica VARCHAR2(150),
	uc_area_cientifica_abv VARCHAR2(10),
	uc_departamento_abv VARCHAR2(10),
	ramo_key NUMBER(38),
	uc_ramo NUMBER(38),
	plano_key NUMBER(38),
	uc_plano  VARCHAR2(280),
	uc_plano_activo VARCHAR2(3),
	uc_plano_ano_semestre VARCHAR2(20),
	is_expired_version	VARCHAR2(3),
	CONSTRAINT pk_tdimunidadesCurriculares_ucKey PRIMARY KEY (uc_key)
);

CREATE TABLE t_dim_epoca_avaliacao(
	epoca_key NUMBER(38),
	epoca_natural_key VARCHAR2(20),
	epoca_descricao VARCHAR2(200),
	epoca_semestre_anoletivo VARCHAR2(100),
	epoca_semestre VARCHAR2(100),
	epoca_anoletivo VARCHAR2(100),
	is_expired_version	VARCHAR2(3),
	CONSTRAINT pk_tdimepocaAvaliacao_epocaKey PRIMARY KEY (epoca_key)
);

CREATE TABLE t_fact_inscricao(
	fact_inscricao_key NUMBER(38),
	uc_key NUMBER(38), 
	estudante_key NUMBER(38),
	epoca_key NUMBER(38),
	inscrito NUMBER(1),
	ects NUMBER(3),
	CONSTRAINT pk_tFactincricao_pk PRIMARY KEY (fact_inscricao_key,uc_key,estudante_key,epoca_key),
	CONSTRAINT fk_tFactincricao_unidadescurriculareskey FOREIGN KEY (uc_key) REFERENCES t_dim_unidades_curriculares(uc_key),
	CONSTRAINT fk_tFactincricao_estudanteskey FOREIGN KEY (estudante_key) REFERENCES t_dim_estudantes(estudante_key),
	CONSTRAINT fk_tFactincricao_epocaavaliacaokey FOREIGN KEY (epoca_key) REFERENCES t_dim_epoca_avaliacao(epoca_key)
);

CREATE TABLE t_fact_avaliacao(
	fact_avaliacao_key NUMBER(38), 
	uc_key NUMBER(38), 
	estudante_key NUMBER(38), 
	epoca_key NUMBER(38), 
	avaliacao NUMBER(3),
	avaliado NUMBER(1),
	aprovado NUMBER(1),
	CONSTRAINT pk_tFactavaliacao_pk PRIMARY KEY (fact_avaliacao_key,uc_key,estudante_key,epoca_key),
	CONSTRAINT fk_tFactavaliacao_unidadescurriculareskey FOREIGN KEY (uc_key) REFERENCES t_dim_unidades_curriculares(uc_key),
	CONSTRAINT fk_tFactavaliacao_estudanteskey FOREIGN KEY (estudante_key) REFERENCES t_dim_estudantes(estudante_key),
	CONSTRAINT fk_tFactavaliacao_epocaavaliacaokey FOREIGN KEY (epoca_key) REFERENCES t_dim_epoca_avaliacao(epoca_key)
);
