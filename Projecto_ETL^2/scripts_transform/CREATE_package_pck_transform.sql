CREATE OR REPLACE PACKAGE PCK_TRANSFORM AS

   PROCEDURE main (p_duplicate_last_iteration BOOLEAN);
   PROCEDURE screen_null_liq_weight (p_iteration_key t_tel_iteration.iteration_key%TYPE, p_source_key t_tel_source.source_key%TYPE, p_screen_order t_tel_schedule.screen_order%TYPE);
   PROCEDURE screen_dimensions (p_iteration_key t_tel_iteration.iteration_key%TYPE, p_source_key t_tel_source.source_key%TYPE, p_screen_order t_tel_schedule.screen_order%TYPE);


END PCK_TRANSFORM;
/
create or replace PACKAGE BODY pck_transform IS

   e_transformation EXCEPTION;

   -- *********************************************
   -- * PUTS AN ERROR IN THE FACT TABLE OF ERRORS *
   -- *********************************************
   PROCEDURE error_log(p_screen_name t_tel_screen.screen_name%TYPE,
                       p_hora_deteccao DATE,
                       p_source_key      t_tel_source.source_key%TYPE,
                       p_iteration_key   t_tel_iteration.iteration_key%TYPE,
                       p_record_id       t_tel_error.record_id%TYPE,
                       p_severity        t_tel_error.error_severity%TYPE) IS
      v_date_key t_tel_date.date_key%TYPE;
      v_screen_key t_tel_screen.screen_key%TYPE;
   BEGIN
      -- obtém o id da dimensão «date» referente ao dia em que o erro foi detectado
      BEGIN
         SELECT date_key
         INTO v_date_key
         FROM t_tel_date
         WHERE TO_CHAR(date_full,'DD-MM-YYYY')=TO_CHAR(p_hora_deteccao,'DD-MM-YYYY');
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            pck_log.write_log('Error: could not find date key from "t_tel_date" ['||sqlerrm||']');
            RAISE e_transformation;
      END;

      BEGIN
         SELECT screen_key
         INTO v_screen_key
         FROM t_tel_screen
         WHERE UPPER(screen_name)=UPPER(p_screen_name);
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            pck_log.write_log('Error: could not find screen key from "t_tel_screen" ['||sqlerrm||']');
            RAISE e_transformation;
      END;

      -- Insere um facto
      INSERT INTO t_tel_error (date_key,screen_key,source_key,iteration_key, record_id, error_severity) VALUES (v_date_key,v_screen_key,p_source_key,p_iteration_key, p_record_id, p_severity);
   EXCEPTION
      WHEN OTHERS THEN
         pck_log.write_log('Error: could not write quality problem to "t_tel_error" fact table ['||sqlerrm||']');
         RAISE e_transformation;
   END;



   -- *******************************************
   -- * DUPLICATE THE LAST SCHEDULED ITERATION  *
   -- *******************************************
   PROCEDURE duplicate_last_iteration(p_start_date t_tel_iteration.iteration_start_date%TYPE) IS
      v_last_iteration_key t_tel_iteration.iteration_key%TYPE;
      v_new_iteration_key t_tel_iteration.iteration_key%TYPE;
      
      CURSOR c_scheduled_screens(p_iteration_key t_tel_iteration.iteration_key%TYPE) IS
         SELECT es.screen_key as screen_key,screen_name,screen_order,screen_source_key
         FROM t_tel_schedule es, t_tel_screen
         WHERE iteration_key=p_iteration_key AND
               es.screen_key = t_tel_screen.screen_key;
   BEGIN
      pck_log.write_log('Action: duplicate last iteration ['||sqlerrm||']');
      
      -- FIND THE LAST ITERATIONS'S KEY
      BEGIN
         SELECT MAX(iteration_key)
         INTO v_last_iteration_key
         FROM t_tel_iteration;
      EXCEPTION
         WHEN NO_DATA_FOUND THEN
            pck_log.write_log('Error: could not find iteration key ['||sqlerrm||']');
            RAISE e_transformation;
      END;

      INSERT INTO t_tel_iteration(iteration_start_date) VALUES (p_start_date) RETURNING iteration_key INTO v_new_iteration_key;
      FOR rec IN c_scheduled_screens(v_last_iteration_key) LOOP
         -- SCHEDULE A SCREEN
         INSERT INTO t_tel_schedule(screen_key,iteration_key,source_key,screen_order)
         VALUES (rec.screen_key,v_new_iteration_key,rec.screen_source_key,rec.screen_order);
      END LOOP;

      pck_log.write_log('Done!');
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         pck_log.write_log('Error: found no screens to reschedule');
         RAISE e_transformation;
      WHEN OTHERS THEN
         pck_log.write_log('Error: could not duplicate last iteration ['||sqlerrm||']');
         RAISE e_transformation;
   END;



   -- ####################### TRANSFORMATION ROUTINES #######################
   
   PROCEDURE transform_estudantes IS
   BEGIN
      pck_log.write_log('Action: transform estudantes'' data');

      INSERT INTO t_clean_estudantes(cd_aluno,cd_curso)
      SELECT e.cd_aluno, e.cd_curso
      FROM t_data_estudantes e
      WHERE e.rejected_by_screen='0';

      pck_log.write_log('Done!');
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         pck_log.write_log('Info: Found no lines to transform');
         pck_log.write_log('Done!');
      WHEN OTHERS THEN
         pck_log.write_log('Error: could not transform estudantes ['||sqlerrm||']');
         RAISE e_transformation;
   END;  


   PROCEDURE transform_tipos_inscricao IS
   BEGIN
      pck_log.write_log('Action: transform tipos inscricao'' data');

      INSERT INTO t_clean_tipos_inscricao(cd_tipo_insc,ds_tipo_insc)
      SELECT DISTINCT(cd_tipo_insc), ds_tipo_insc 
      FROM ei_sad_proj_bda.t_bda_inscricoes 
      ORDER BY 1;

      pck_log.write_log('Done!');
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         pck_log.write_log('Info: Found no lines to transform');
         pck_log.write_log('Done!');
      WHEN OTHERS THEN
         pck_log.write_log('Error: could not transform tipos inscricao ['||sqlerrm||']');
         RAISE e_transformation;
   END;


   PROCEDURE transform_unidades_curriculares IS
   BEGIN
      pck_log.write_log('Action: transform tipos inscricao'' data');

      INSERT INTO t_clean_tipos_inscricao(cd_tipo_insc,ds_tipo_insc)
      SELECT DISTINCT(cd_tipo_insc), ds_tipo_insc 
      FROM ei_sad_proj_bda.t_bda_inscricoes 
      ORDER BY 1;

      pck_log.write_log('Done!');
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         pck_log.write_log('Info: Found no lines to transform');
         pck_log.write_log('Done!');
      WHEN OTHERS THEN
         pck_log.write_log('Error: could not transform tipos inscricao ['||sqlerrm||']');
         RAISE e_transformation;
   END;




   -- *****************************************************************************************************
   -- *                                             MAIN                                                  *
   -- *                                                                                                   *
   -- * EXECUTE THE TRANSFORMATION PROCESS                                                               *
   -- * IN                                                                                                *
   -- *     p_duplicate_last_iteration: TRUE=duplicate last iteration and its schedule (FOR TESTS ONLY!) *
   -- *****************************************************************************************************
   PROCEDURE main (p_duplicate_last_iteration BOOLEAN) IS

      -- GET ALL SCHEDULED SCREENS
      cursor scheduled_screens_cursor(p_iteration_key t_tel_iteration.iteration_key%TYPE) IS
         SELECT UPPER(screen_name) screen_name,source_key,screen_order
         FROM t_tel_schedule, t_tel_screen
         WHERE iteration_key=p_iteration_key AND  t_tel_schedule.screen_key=t_tel_screen.screen_key;

      v_iteration_key t_tel_iteration.iteration_key%TYPE;
      v_sql  VARCHAR2(1000);
   BEGIN
      pck_log.write_log('Info: entering TRANSFORMATION stage');
      -- DUPLICATES THE LAST ITERATION WITH THEN CORRESPONDING SCHEDULE
      IF p_duplicate_last_iteration THEN
         duplicate_last_iteration(SYSDATE);
      END IF;

      -- CLEAN ALL _clean TABLES
      pck_log.write_log('Action: Delete old _clean tables *');
      DELETE FROM t_clean_avaliacoes;
      DELETE FROM t_clean_cursos;
      DELETE FROM t_clean_estudantes;
      DELETE FROM t_clean_planos;
      DELETE FROM t_clean_ramos;
      DELETE FROM t_clean_unidades_curriculares;
      DELETE FROM t_clean_unidades_organicas;
      pck_log.write_log('Done!');

      -- FIND THE MOST RECENTLY SCHEDULED ITERATION
      BEGIN
         select ITERATION_KEY  into v_iteration_key from T_TEL_ITERATION
         where ITERATION_START_DATE = (select max(ITERATION_START_DATE) from  T_TEL_ITERATION group by ITERATION_KEY);
      EXCEPTION
         WHEN OTHERS THEN
            RAISE e_transformation;
      END;

      pck_log.write_log('Info: starting scheduled screens');

      -- RUN ALL SCHEDULED SCREENS
      FOR rec IN scheduled_screens_cursor(v_iteration_key) LOOP
         v_sql:= 'BEGIN PCK_TRANSFORM.' || rec.screen_name || '(:b1, :b2, :b3); END;';
         EXECUTE IMMEDIATE v_sql USING v_iteration_key, rec.source_key, rec.screen_order;
      END LOOP;

      pck_log.write_log('Info: all scheduled screens executed');
      
      -- EXECUTE THE TRANSFORMATION ROUTINES
      pck_log.write_log('Info: starting data transformation');
      transform_estudantes;
      transform_tipos_inscricao;
      /*
      transform_products;
      transform_stores;
      transform_sales;
      transform_linesofsale;
      transform_promotions;
      */
      
      pck_log.write_log('Info: data transformation completed');
      COMMIT;
      pck_log.write_log('Info: All transformed data commited to database');
      pck_log.write_log('Info: TRANSFORMATION stage completed');
   EXCEPTION
      WHEN e_transformation THEN
         pck_log.write_halt_transformation_msg;
         ROLLBACK;
      WHEN OTHERS THEN
         ROLLBACK;
         pck_log.write_log('Error: critical error ['||sqlerrm||']');
         pck_log.write_halt_transformation_msg;
   END;

end pck_transform;
/