CREATE TABLE t_dim_curso(
	curso_key NUMBER(38),
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
	curso_instituicao_nome_abv VARCHAR2(30),
	is_expired_version	VARCHAR2(3),
	CONSTRAINT pk_TDimCurso_cursoKey PRIMARY KEY (curso_key)
);

CREATE TABLE t_dim_estudante(
	estudante_key NUMBER(38), 
	estudante_natural_key NUMBER(38),
	curso_key NUMBER(38),
	is_expired_version	VARCHAR2(3),
	CONSTRAINT pk_TDimEstudante_estudanteKey PRIMARY KEY (estudante_key)
);

CREATE TABLE t_dim_tipo_inscricao(
	tipo_insc_key NUMBER(38),
	tipo_insc_natural_key NUMBER(38),
	tipo_insc_descricao VARCHAR2(50),
	is_expired_version	VARCHAR2(3),
	CONSTRAINT pk_tDimTipoInsc_tipoInscKey PRIMARY KEY (tipo_insc_key)
);

CREATE TABLE t_dim_unidade_curricular(
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
	uc_ramo VARCHAR2(150),
	plano_key NUMBER(38),
	uc_plano  VARCHAR2(280),
	uc_plano_activo VARCHAR2(3),
	uc_plano_ano_semestre VARCHAR2(20),
	is_expired_version	VARCHAR2(3),
	CONSTRAINT pk_tDimUC_ucKey PRIMARY KEY (uc_key)
);

CREATE TABLE t_dim_epoca_avaliacao(
	epoca_key NUMBER(38),
	epoca_natural_key VARCHAR2(20),
	epoca_descricao VARCHAR2(200),
	epoca_anoletivo VARCHAR2(100),
	is_expired_version	VARCHAR2(3),
	CONSTRAINT pk_tDimEpoca_epocaKey PRIMARY KEY (epoca_key)
);

CREATE TABLE t_fact_inscricao(
	fact_inscricao_key NUMBER(38),
	uc_key NUMBER(38), 
	estudante_key NUMBER(38),
	epoca_key NUMBER(38),
	inscrito NUMBER(1),
	ects NUMBER(3),
	CONSTRAINT pk_tFInscricao_pk PRIMARY KEY (fact_inscricao_key,uc_key,estudante_key,epoca_key),
	CONSTRAINT fk_tFInscricao_uckey FOREIGN KEY (uc_key) REFERENCES t_dim_unidade_curricular(uc_key),
	CONSTRAINT fk_tFInscricao_estudantekey FOREIGN KEY (estudante_key) REFERENCES t_dim_estudante(estudante_key),
	CONSTRAINT fk_tFInscricao_epocakey FOREIGN KEY (epoca_key) REFERENCES t_dim_epoca_avaliacao(epoca_key)
);

CREATE TABLE t_fact_avaliacao(
	fact_avaliacao_key NUMBER(38), 
	uc_key NUMBER(38), 
	estudante_key NUMBER(38), 
	epoca_key NUMBER(38), 
	avaliacao NUMBER(3),
	avaliado NUMBER(1),
	aprovado NUMBER(1),
	CONSTRAINT pk_tFAvaliacao_pk PRIMARY KEY (fact_avaliacao_key,uc_key,estudante_key,epoca_key),
	CONSTRAINT fk_tFAvaliacao_uckey FOREIGN KEY (uc_key) REFERENCES t_dim_unidade_curricular(uc_key),
	CONSTRAINT fk_tFAvaliacao_estudantekey FOREIGN KEY (estudante_key) REFERENCES t_dim_estudante(estudante_key),
	CONSTRAINT fk_tFAvaliacao_epocakey FOREIGN KEY (epoca_key) REFERENCES t_dim_epoca_avaliacao(epoca_key)
);
