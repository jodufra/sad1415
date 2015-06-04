create or replace package pck_load is
   PROCEDURE main (p_load_epocas BOOLEAN, p_init_dimensions BOOLEAN);
END;
/
create or replace package body pck_load is

   e_load EXCEPTION;

   -- ***************************************************
   -- * INITIALIZES DIMENSIONS WITH AN 'INVALID RECORD' *
   -- ***************************************************
   PROCEDURE init_dimensions IS
   BEGIN
      pck_log.write_log('Action: Initialize dimensions with "invalid" record'); 
      -- 'INVALID PRODUCT'
      INSERT INTO t_dim_curso (curso_key,curso_natural_key,curso_oficial_key,curso_nome,curso_nome_abv,curso_regime,curso_grau,curso_activo,curso_bolonha,curso_instituicao_key,curso_instituicao_nome,curso_instituicao_nome_abv,is_expired_version)
      VALUES (pck_error_codes.c_load_invalid_dim_record_key,pck_error_codes.c_load_invalid_dim_record_Nkey,null,'INVALID CURSO',null,null,null,null,null,pck_error_codes.c_load_invalid_dim_record_Nkey,null,null,'NO');
      -- 'INVALID PROMOTION'
      INSERT INTO t_dim_estudante (estudante_key,estudante_natural_key,curso_key,is_expired_version)
      VALUES (pck_error_codes.c_load_invalid_dim_record_key, pck_error_codes.c_load_invalid_dim_record_Nkey,pck_error_codes.c_load_invalid_dim_record_key,'NO');
      -- 'INVALID DATE'
      INSERT INTO t_dim_tipo_inscricao (tipo_insc_key,tipo_insc_natural_key,tipo_insc_descricao,is_expired_version)
      VALUES (pck_error_codes.c_load_invalid_dim_record_key,pck_error_codes.c_load_invalid_dim_record_Nkey, 'INVALID TIPO INSCRICAO','NO');
      -- 'INVALID TIME'
      INSERT INTO t_dim_unidade_curricular (uc_key,uc_natural_key,curso_key,ramo_key,plano_key,uc_nome,uc_nome_abv,uc_duracao,uc_area_cientifica,uc_area_cientifica_abv,uc_departamento_abv,uc_ramo,uc_plano,uc_plano_activo,uc_plano_ano_semestre,is_expired_version)
      VALUES (pck_error_codes.c_load_invalid_dim_record_key,pck_error_codes.c_load_invalid_dim_record_Nkey,pck_error_codes.c_load_invalid_dim_record_key,pck_error_codes.c_load_invalid_dim_record_Nkey,pck_error_codes.c_load_invalid_dim_record_Nkey,'INVALID UNIDADES CURRICULARES' ,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,'NO');
      -- 'INVALID STORE'
      INSERT INTO t_dim_epoca_avaliacao (epoca_key,epoca_natural_key,epoca_descricao,epoca_anoletivo,is_expired_version)
      VALUES (pck_error_codes.c_load_invalid_dim_record_key, 'INVALID_EPOCA_KEY', 'INVALID EPOCA', NULL, 'NO');

      pck_log.write_log('Done!');
   EXCEPTION
      WHEN OTHERS THEN
         pck_log.write_log('Error: could not initialize dimensions ['||sqlerrm||'].');
         RAISE e_load;
   END;



   -- ***********************************
   -- * LOADS THE 'PROMOTION' DIMENSION *
   -- ***********************************
   PROCEDURE load_dim_curso IS
   BEGIN
      pck_log.write_log('Action: Load cursos');
      -- FOR EACH NEW OR UPDATED SOURCE PROMOTION
      MERGE INTO t_dim_curso dim
      USING (SELECT 
          curso_natural_key,
          curso_oficial_key,
          curso_nome,
          curso_nome_abv,
          curso_regime,
          curso_grau,
          curso_activo,
          curso_bolonha,
          curso_instituicao_key,
          curso_instituicao_nome,
          curso_instituicao_nome_abv
          FROM t_clean_cursos) clean
      ON (dim.curso_natural_key = clean.curso_natural_key)
      WHEN MATCHED THEN UPDATE SET dim.curso_oficial_key=clean.curso_oficial_key,
                                   dim.curso_nome=clean.curso_nome,
                                   dim.curso_nome_abv=clean.curso_nome_abv,
                                   dim.curso_regime=clean.curso_regime,
                                   dim.curso_grau=clean.curso_grau,
                                   dim.curso_activo=clean.curso_activo,
                                   dim.curso_bolonha=clean.curso_bolonha,
                                   dim.curso_instituicao_key=clean.curso_instituicao_key,
                                   dim.curso_instituicao_nome=clean.curso_instituicao_nome,
                                   dim.curso_instituicao_nome_abv=clean.curso_instituicao_nome_abv


      WHEN NOT MATCHED THEN INSERT (dim.curso_key,dim.curso_oficial_key,dim.curso_nome,dim.curso_nome_abv,dim.curso_regime,dim.curso_grau,dim.curso_activo,dim.curso_bolonha,dim.curso_instituicao_key,dim.curso_instituicao_nome,dim.curso_instituicao_nome_abv,dim.is_expired_version)
                            VALUES (seq_dim_curso.NEXTVAL,clean.curso_oficial_key,clean.curso_nome,clean.curso_nome_abv,clean.curso_regime,clean.curso_grau,clean.curso_activo,clean.curso_bolonha,clean.curso_instituicao_key,clean.curso_instituicao_nome,clean.curso_instituicao_nome_abv,'NO');

      pck_log.write_log('Info: '||SQL%ROWCOUNT|| 'curso(s) merged');
      pck_log.write_log('Done!');
   EXCEPTION
      WHEN OTHERS THEN
         pck_log.write_log('Error: Could not load dimension ['||sqlerrm||']');
         RAISE e_load;
   END;


   PROCEDURE load_dim_estudante IS
   BEGIN
      pck_log.write_log('Action: Load Estudantes');
      -- FOR EACH NEW OR UPDATED SOURCE PROMOTION
      MERGE INTO t_dim_estudante dim
      USING (SELECT 
         estudante_natural_key,
         curso_key
          FROM t_clean_estudantes) clean
      ON (dim.estudante_natural_key = clean.estudante_natural_key)
      WHEN MATCHED THEN UPDATE SET
                            dim.estudante_natural_key=clean.estudante_natural_key,
                            dim.curso_key=clean.curso_key
      WHEN NOT MATCHED THEN INSERT (dim.estudante_key, dim.estudante_natural_key, dim.curso_key, dim.is_expired_version)
                            VALUES (seq_dim_estudante.NEXTVAL, clean.estudante_natural_key, clean.curso_key,'NO');

      pck_log.write_log('Info: '||SQL%ROWCOUNT|| ' curso(s) merged');
      pck_log.write_log('Done!');
   EXCEPTION
      WHEN OTHERS THEN
         pck_log.write_log('Error: Could not load dimension ['||sqlerrm||']');
         RAISE e_load;
   END;

   PROCEDURE load_dim_unidade_curricular IS
   BEGIN
      pck_log.write_log('Action: Load Estudantes');
      -- FOR EACH NEW OR UPDATED SOURCE PROMOTION
      MERGE INTO t_dim_unidade_curricular dim
      USING (SELECT 
         uc_natural_key,
         plano_key,
         curso_key,
         ramo_key,
         uc_nome,
         uc_nome_abv,
         uc_duracao,
         uc_ramo,
         uc_plano,
         uc_plano_activo
          FROM t_clean_unidades_curriculares) clean
      ON (dim.uc_natural_key = clean.uc_natural_key)
      WHEN MATCHED THEN UPDATE SET dim.uc_natural_key=clean.uc_natural_key,
                                    dim.plano_key=clean.plano_key,
                                    dim.curso_key=clean.curso_key,
                                    dim.ramo_key=clean.ramo_key,
                                    dim.uc_nome=clean.uc_nome,
                                    dim.uc_nome_abv=clean.uc_nome_abv,
                                    dim.uc_duracao=clean.uc_duracao,
                                    dim.uc_ramo=clean.uc_ramo,
                                    dim.uc_plano=clean.uc_plano,
                                    dim.uc_plano_activo=clean.uc_plano_activo
      WHEN NOT MATCHED THEN INSERT (dim.uc_key,dim.uc_natural_key,dim.plano_key,dim.curso_key,dim.ramo_key,dim.uc_nome,dim.uc_nome_abv,dim.uc_duracao,dim.uc_ramo,dim.uc_plano,dim.uc_plano_activo,dim.is_expired_version)
                            VALUES (seq_dim_unidade_curricular.NEXTVAL,clean.uc_natural_key,clean.plano_key,clean.curso_key,clean.ramo_key,clean.uc_nome,clean.uc_nome_abv,clean.uc_duracao,clean.uc_ramo,clean.uc_plano,clean.uc_plano_activo,'NO');

      pck_log.write_log('Info: '||SQL%ROWCOUNT|| ' Uc(s) merged');
      pck_log.write_log('Done!');
   EXCEPTION
      WHEN OTHERS THEN
         pck_log.write_log('Error: Could not load dimension ['||sqlerrm||']');
         RAISE e_load;
   END;



 PROCEDURE load_dim_tipo_inscricao IS
   BEGIN
      pck_log.write_log('Action: Load tipo inscricao');
      -- FOR EACH NEW OR UPDATED SOURCE PROMOTION
      MERGE INTO t_dim_tipo_inscricao dim
      USING (SELECT 
            tipo_insc_natural_key,
            tipo_insc_descricao
          FROM t_clean_tipos_inscricao) clean
      ON (dim.tipo_insc_natural_key = clean.tipo_insc_natural_key)
      WHEN MATCHED THEN UPDATE SET 
                                    dim.tipo_insc_natural_key=clean.tipo_insc_natural_key,
                                    dim.tipo_insc_descricao=clean.tipo_insc_descricao
      WHEN NOT MATCHED THEN INSERT (dim.tipo_insc_key, dim.tipo_insc_natural_key,dim.tipo_insc_descricao,dim.is_expired_version)
                            VALUES (seq_dim_tipo_inscricao.NEXTVAL,clean.tipo_insc_natural_key,clean.tipo_insc_descricao,'NO');

      pck_log.write_log('Info: '||SQL%ROWCOUNT|| ' Tipo inscricao(s) merged');
      pck_log.write_log('Done!');
   EXCEPTION
      WHEN OTHERS THEN
         pck_log.write_log('Error: Could not load dimension ['||sqlerrm||']');
         RAISE e_load;
   END;


PROCEDURE load_dim_epoca_avaliacao IS
  cursor cursor_epocas is 
  SELECT 
    DISTINCT(nvl(a.CD_LECTIVO,i.CD_LECTIVO)) EPOCA_ANOLETIVO,
    (to_char(nvl(a.CD_LECTIVO,i.CD_LECTIVO)) || '_' || to_char(nvl(a.cd,i.cd))) EPOCA_NATURAL_KEY,
    nvl(a.DS_EPOCA_AVAL,i.DS_EPOCA_AVAL) EPOCA_DESCRICAO
  FROM
    (select DISTINCT(CD_EPOCA_AVAL) cd, (CD_LECTIVO) CD_LECTIVO, DS_EPOCA_AVAL from T_DATA_AVALIACOES order by 1) a FULL JOIN
    (select DISTINCT(CD_EPOCA_AVAL) cd, (CD_LECTIVO) CD_LECTIVO, DS_EPOCA_AVAL from T_DATA_INSCRICOES order by 1) i on a.cd = i.cd
  WHERE
    a.DS_EPOCA_AVAL is not null and
    i.DS_EPOCA_AVAL is not null;

 BEGIN
    pck_log.write_log('Action: Load tipo inscricao');
    -- FOR EACH NEW OR UPDATED SOURCE PROMOTION
   FOR rec in cursor_epocas LOOP
            INSERT INTO t_dim_epoca_avaliacao(epoca_key, epoca_natural_key, epoca_descricao, epoca_anoletivo) 
            values(seq_dim_epoca_avaliacao.NEXTVAL, rec.epoca_natural_key, rec.epoca_descricao, rec.epoca_anoletivo);
   END LOOP;
         

 END;

/*
-- ************************
PROCEDURE load_fact_table IS
  v_source_lines INTEGER;
BEGIN
  -- JUST FOR STATISTICS
  SELECT COUNT(*)
  INTO v_source_lines
  FROM t_clean_linesofsale;

  INSERT INTO t_fact_lineofsale(product_key,store_key,promo_key,date_key,time_key,sold_quantity,ammount_sold,sale_id_dd)
  SELECT
     product_key,
     store_key,
     promo_key,
     date_key,
     time_key,
     los.quantity,
     los.ammount_paid,
     los.sale_id
  FROM
     t_dim_product,
     t_dim_store,
     t_dim_promotion,
     t_dim_date,
     t_dim_time,
     t_clean_linesofsale los,
     t_clean_sales sales
  WHERE
     -- join between the two source tables
     sales.id=los.sale_id AND
     -- joins to get dimension keys using sources' natural keys
     los.product_id=t_dim_product.product_natural_key AND
     NVL(los.promo_id,pck_error_codes.c_load_invalid_dim_record_NKey)=t_dim_promotion.promo_natural_key AND
     sales.store_id=t_dim_store.store_natural_key AND
     TO_CHAR(sales.sale_date,'dd-mm-yyyy')=t_dim_date.date_full_date AND
     TO_CHAR(los.line_date,'hh24:mi:ss')=t_dim_time.time_full_time AND
     -- excludes EXPIRED VERSIONS of product and store dimensions
     t_dim_store.is_expired_version='NO' AND
     t_dim_product.is_expired_version='NO';

  pck_log.write_log('Info: '||SQL%ROWCOUNT ||' fact(s) loaded');
  pck_log.write_log('Done!');
EXCEPTION
  WHEN NO_DATA_FOUND THEN
     pck_log.write_log('Info: No facts generated from '||v_source_lines||' source lines-of-sale');
  WHEN OTHERS THEN
     pck_log.write_log('Error: Could not load fact table ['||sqlerrm||']');
     RAISE e_load;
END;
*/



   -- *****************************************************************************************************
   -- *                                             MAIN                                                  *
   -- *                                                                                                   *
   -- * EXECUTES THE LOADING PROCESS                                                                      *
   -- * IN                                                                                                *
   -- *     p_load_dates: TRUE=t_dim_date dimension will be loaded                                        *
   -- *     p_init_dimensions: TRUE=all dimensions will be filled with an INVALID record                  *
   -- *****************************************************************************************************
   PROCEDURE main (p_load_epocas BOOLEAN, p_init_dimensions BOOLEAN) IS
   BEGIN
      pck_log.write_log('Info: entering LOAD stage');

      -- LOADS 'DATE' DIMENSIONS
      IF p_load_epocas THEN
         null;
      END IF;

      -- INTIALIZE DIMENSIONS
      IF p_init_dimensions THEN
         init_dimensions;
      END IF;

      -- LOAD DIMENSIONS

      pck_log.write_log('Info: data load completed');
      COMMIT;
      pck_log.write_log('Info: All loaded data commited to database');
      pck_log.write_log('Info: LOAD stage completed');
   EXCEPTION
      WHEN e_load THEN
         pck_log.write_halt_load_msg;
         ROLLBACK;
      WHEN OTHERS THEN
         ROLLBACK;
         pck_log.write_log('Error: critical error ['||sqlerrm||']');
         pck_log.write_halt_load_msg;
   END;
end pck_load;
/