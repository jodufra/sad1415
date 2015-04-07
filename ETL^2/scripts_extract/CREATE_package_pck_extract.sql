CREATE OR REPLACE PACKAGE pck_extract IS
   PROCEDURE main (p_initialize BOOLEAN);
   PROCEDURE read_file(p_dir VARCHAR2, p_file_name VARCHAR2);
END pck_extract;
/


create or replace PACKAGE BODY pck_extract IS

   e_extraction EXCEPTION;

   -- **************************************
   -- * USED FOR READING SOURCE TEXT FILES *
   -- **************************************
   PROCEDURE read_file(p_dir VARCHAR2, p_file_name VARCHAR2) IS
      v_line NVARCHAR2(32767);
      v_file UTL_FILE.FILE_TYPE;
   BEGIN
      SET TRANSACTION READ WRITE NAME 'read file from server''s directory';
      DELETE FROM t_info_file_reading;
      v_file := UTL_FILE.FOPEN_NCHAR(UPPER(p_dir),p_file_name,'R');
      LOOP
         UTL_FILE.GET_LINE_NCHAR(v_file,v_line,32767);
         INSERT INTO t_info_file_reading VALUES (v_line);
      END LOOP;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         UTL_FILE.FCLOSE(v_file);
         COMMIT;
      WHEN UTL_FILE.INVALID_PATH THEN
         ROLLBACK;
         RAISE_APPLICATION_ERROR(-20001,'invalid_path ['||sqlerrm||']');
      WHEN UTL_FILE.INVALID_MODE THEN
         ROLLBACK;
         RAISE_APPLICATION_ERROR(-20002,'invalid_mode ['||sqlerrm||']');
      WHEN UTL_FILE.INVALID_FILEHANDLE THEN
         ROLLBACK;
         RAISE_APPLICATION_ERROR(-20003,'invalid_filehandle ['||sqlerrm||']');
      WHEN UTL_FILE.INVALID_OPERATION THEN
         ROLLBACK;
         RAISE_APPLICATION_ERROR(-20004,'invalid_operation ['||sqlerrm||']');
      WHEN UTL_FILE.READ_ERROR THEN
         ROLLBACK;
         UTL_FILE.FCLOSE(v_file);
         RAISE_APPLICATION_ERROR(-20005,'read_error ['||sqlerrm||']');
      WHEN UTL_FILE.INTERNAL_ERROR THEN
         ROLLBACK;
         RAISE_APPLICATION_ERROR(-20007,'internal_error ['||sqlerrm||']');
      WHEN OTHERS THEN
         ROLLBACK;
         UTL_FILE.FCLOSE(v_file);
         RAISE_APPLICATION_ERROR(-20009,'unknown_error ['||sqlerrm||']');
   END;



   -- *****************************************
   -- * INTITALIZE t_info_extractions TABLE   *
   -- *****************************************
   PROCEDURE initialize_extractions_table (p_clean_before BOOLEAN) IS
      v_source_table VARCHAR2(100);
   BEGIN
      BEGIN
         IF p_clean_before=TRUE THEN
            pck_log.write_log('Action: delete previous initialization data');
            DELETE FROM t_info_extractions;
            pck_log.write_log('Done!');
            
            pck_log.write_log('Action: delete %_new and %_old data'); 
            DELETE FROM t_data_managers_new;
            DELETE FROM t_data_managers_old;
            DELETE FROM t_data_stores_new;
            DELETE FROM t_data_stores_old;
            pck_log.write_log('Done!');
         END IF;
      EXCEPTION
         WHEN OTHERS THEN
            pck_log.write_log('Error: could not delete previous initialization data ['||sqlerrm||'].');
            RAISE e_extraction;
      END;

      #INSERT INTO t_info_extractions (last_timestamp,source_table_name) VALUES (NULL,'view_produtos@DBLINK_SADSB');
      #INSERT INTO t_info_extractions (last_timestamp,source_table_name) VALUES (NULL,'view_promocoes@DBLINK_SADSB');
      #INSERT INTO t_info_extractions (last_timestamp,source_table_name) VALUES (NULL,'view_vendas@DBLINK_SADSB');
      #INSERT INTO t_info_extractions (last_timestamp,source_table_name) VALUES (NULL,'view_linhasvenda@DBLINK_SADSB');
      #INSERT INTO t_info_extractions (last_timestamp,source_table_name) VALUES (NULL,'view_linhasvenda_promocoes@DBLINK_SADSB');
      #INSERT INTO t_info_extractions (last_timestamp,source_table_name) VALUES (NULL,'view_categorias@DBLINK_SADSB');
      pck_log.write_log('Done!');
   EXCEPTION
      WHEN OTHERS THEN
         pck_log.write_log('Error: could not initiale data for table "'||v_source_table||'" ['||sqlerrm||']');
         RAISE e_extraction;
   END;



   -- ********************************************************************
   -- *                     TABLE_EXTRACT                                *
   -- *                                                                  *
   -- * EXTRACT NEW AND CHANGED ROWS FROM SOURCE TABLE                   *
   -- * IN                                                               *
   -- *   p_source_table: the source table/view to use                   *
   -- *   p_attributes_src: list of attributes to extract from           *
   -- *   p_attributes_dest: list of attributes to fill                  *
   -- *   p_dsa_table: name of the t_data_* table to fill                *
   -- ********************************************************************
   PROCEDURE table_extract (p_source_table VARCHAR2, p_DSA_table VARCHAR2, p_attributes_src VARCHAR2, p_attributes_dest VARCHAR2) IS
      v_end_date TIMESTAMP;
      v_start_date t_info_extractions.LAST_TIMESTAMP%TYPE;
      v_sql  VARCHAR2(1000);
   BEGIN
      pck_log.write_log('Action: extract data using view "'||p_source_table||'"');

      -- CLEAN DESTINATION TABLE
      EXECUTE IMMEDIATE 'DELETE FROM '||p_DSA_table;

       --  find the date of change of the last record extracted in the previous extraction 
       v_sql:='SELECT last_timestamp FROM t_info_extractions WHERE UPPER(source_table_name)='''||UPPER(p_source_table)||'''';
       EXECUTE IMMEDIATE v_sql INTO v_start_date;

       --    ---------------------
       --   |   FISRT EXTRACTION  |
       --    ---------------------
      IF v_start_date IS NULL THEN
          -- FIND THE DATE OF CHANGE OF THE MOST RECENTLY CHANGED RECORD IN THE SOURCE TABLE
          v_sql:='SELECT MAX(SRC_LAST_CHANGED) FROM '||p_source_table;
          EXECUTE IMMEDIATE v_sql INTO v_end_date;

          -- EXTRACT ALL RELEVANT RECORDS FROM THE SOURCE TABLE TO THE DSA
          v_sql:='INSERT INTO '||p_DSA_table||'('|| p_attributes_dest||') SELECT '||p_attributes_src||' FROM '||p_source_table;
          EXECUTE IMMEDIATE v_sql;

          -- UPDATE THE t_info_extractions TABLE
          v_sql:='UPDATE t_info_extractions SET LAST_TIMESTAMP = :v_end_date WHERE UPPER(source_table_name)='''||UPPER(p_source_table)||'''';
          EXECUTE IMMEDIATE v_sql USING v_end_date;
       ELSE
       --    -------------------------------------
       --   |  OTHER EXTRACTIONS AFTER THE FIRST  |
       --    -------------------------------------
          -- FIND THE DATE OF CHANGE OF THE MOST RECENTLY CHANGED RECORD IN THE SOURCE TABLE
          v_sql:='SELECT MAX(SRC_LAST_CHANGED) FROM '||p_source_table;
          EXECUTE IMMEDIATE v_sql INTO v_end_date;

          IF v_end_date>v_start_date THEN
             -- EXTRACT ALL RELEVANT RECORDS FROM THE SOURCE TABLE TO THE DSA
             v_sql:='INSERT INTO '||p_DSA_table||'('|| p_attributes_dest||')   (SELECT '||p_attributes_src||' FROM '||p_source_table||'  WHERE SRC_LAST_CHANGED > :v_start_date AND SRC_LAST_CHANGED <= :v_end_date)';
             EXECUTE IMMEDIATE v_sql USING v_start_date, v_end_date;

             -- UPDATE THE t_info_extractions TABLE
             v_sql:='UPDATE t_info_extractions SET LAST_TIMESTAMP = :v_end_date WHERE UPPER(source_table_name)='''||UPPER(p_source_table)||'''';
             EXECUTE IMMEDIATE v_sql USING v_end_date;
          END IF;
       END IF;

      pck_log.write_log('Done!');
   EXCEPTION
      WHEN OTHERS THEN
         pck_log.write_log('Error: could not extract from source table "'||p_source_table||'" ['||sqlerrm||']');
         RAISE e_extraction;
   END;


   -- **************************************************************
   -- *                       FILE_EXTRACT                         *
   -- *                                                            *
   -- * EXTRACT ROWS FROM SOURCE FILE                              *
   -- * IN                                                         *
   -- *    p_external_table: the external table to use             *
   -- *    p_attributes_src: list of attributes to extract         *
   -- *    p_attributes_dest: list of attributes to fill           *
   -- *    p_dsa_table_new: name of the t_data_*_new table to fill *
   -- *    p_dsa_table_old: name of the t_data_*_old table to fill *
   -- **************************************************************
   PROCEDURE file_extract (p_external_table VARCHAR2, p_attributes_src VARCHAR2, p_attributes_dest VARCHAR2, p_dsa_table_new VARCHAR2, p_dsa_table_old VARCHAR2) IS
      v_sql  VARCHAR2(1000);
   BEGIN
      pck_log.write_log('Action: extract from external table "'||p_external_table||'"');      

      -- CLEAN _old TABLE
      EXECUTE IMMEDIATE 'DELETE FROM '||p_dsa_table_old;

      -- COPY from _new TABLE to _old TABLE
      v_sql:='INSERT INTO '||p_dsa_table_old||'('|| p_attributes_dest||') SELECT '||p_attributes_dest||' FROM '||p_dsa_table_new;
      EXECUTE IMMEDIATE v_sql;

      -- CLEAN _new TABLE
      EXECUTE IMMEDIATE 'DELETE FROM '||p_dsa_table_new;

      -- COPY from _ext TABLE to _new TABLE
      v_sql:='INSERT INTO '||p_dsa_table_new||'('|| p_attributes_dest||') SELECT '||p_attributes_src||' FROM '||p_external_table;
      EXECUTE IMMEDIATE v_sql;

      pck_log.write_log('Done!');
   EXCEPTION
      WHEN OTHERS THEN
         pck_log.write_log('Error: could not extract from external table "'||p_external_table||'" ['||sqlerrm||']');
         RAISE e_extraction;
   END;


   -- ********************************************************************
   -- *                TABLE_EXTRACT_NON_INCREMENTAL                     *
   -- *                                                                  *
   -- * EXTRACT ROWS FROM SOURCE TABLE IN NON INCREMENTAL WAY            *
   -- * IN: (same as table_extract)                                      *
   -- ********************************************************************
   PROCEDURE table_extract_non_incremental (p_source_table VARCHAR2, p_DSA_table VARCHAR2, p_attributes_src VARCHAR2, p_attributes_dest VARCHAR2) IS
      v_sql  VARCHAR2(1000);
   BEGIN 
      pck_log.write_log('Action: extract data using view "'||p_source_table||'"');
      -- LIMPAR A TABELA DESTINO
      EXECUTE IMMEDIATE 'DELETE FROM '||p_DSA_table;

      -- extrair TODOS os registos da tabela fonte para a tabela correspondente na DSA
      v_sql:='INSERT INTO '||p_DSA_table||'('|| p_attributes_dest||') SELECT '||p_attributes_src||' FROM '||p_source_table;
      EXECUTE IMMEDIATE v_sql;
   EXCEPTION
      WHEN OTHERS THEN
         pck_log.write_log('Error: could not extract from source table "'||p_source_table||'" ['||sqlerrm||']');
         RAISE e_extraction;
   END;

   
   -- *****************************************************************************
   -- *                                        MAIN                               *
   -- *                                                                           *
   -- * EXECUTE THE EXTRACTION PROCESS                                            *
   -- * IN                                                                        *
   -- *     p_initialize: TRUE=t_info_extractions will be cleaned and then filled *
   -- *****************************************************************************
   PROCEDURE main (p_initialize BOOLEAN) IS
   BEGIN
      pck_log.clean;
      pck_log.write_log('Info: entering EXTRACTION stage');

      -- INITIALIZE THE EXTRACTION TABLE t_info_extractions
      IF p_initialize=TRUE THEN
         DELETE FROM t_info_extractions;
         initialize_extractions_table(TRUE);
      END IF;

      -- EXTRACT FROM SOURCE TABLES
      -- table_extract('','','','');
      table_extract('EI_SAD_PROJ_BDA.T_BDA_UNIDADES_CURRICULARES', 't_data_unidades_curriculares', 'cd_plano,cd_discip,ds_discip,ds_abreviatura,cd_duracao,cd_ramo,cd_curso', 'cd_plano,cd_discip,ds_discip,ds_abreviatura,cd_duracao,cd_ramo,cd_curso');
      table_extract('EI_SAD_PROJ_BDA.T_BDA_UNIDADES_ORGANICAS','t_data_unidades_organicas','cd_instituic,ds_instituic,ds_inst_abr','cd_instituic,ds_instituic,ds_inst_abr');
      #table_extract('view_linhasvenda@dblink_sadsb', 't_data_linesofsale', 'src_id,src_sale_id,src_product_id,src_quantity,src_ammount_paid,src_line_date', 'id,sale_id,product_id,quantity,ammount_paid,line_date');
      #table_extract('view_vendas@dblink_sadsb', 't_data_sales', 'src_id,src_sale_date,src_store_id','id,sale_date,store_id');
      #table_extract('view_promocoes@dblink_sadsb', 't_data_promotions','src_id,src_name,src_start_date,src_end_date,src_reduction,src_on_outdoor,src_on_tv','id,name,start_date,end_date,reduction,on_outdoor,on_tv');
      #table_extract('view_linhasvenda_promocoes@dblink_sadsb', 't_data_linesofsalepromotions','src_line_id,src_promo_id','line_id,promo_id');
      #table_extract_non_incremental('view_categorias@dblink_sadsb', 't_data_categories', 'src_id,src_name', 'id,name');
      -- EXTRACT FROM SOURCE FILES
      #file_extract ('t_ext_stores', 'name,refer,building,address,zip_code,city,district,phone_nrs,fax_nr,closure_date', 'name,reference,building,address,zip_code,location,district,telephones,fax,closure_date', 't_data_stores_new', 't_data_stores_old'); 
      #file_extract ('t_ext_managers', 'reference,manager_name,manager_since', 'reference,manager_name,manager_since', 't_data_managers_new', 't_data_managers_old');

      pck_log.write_log('Info: data extraction completed');
      COMMIT;
      pck_log.write_log('Info: All extracted data commited to database');
      pck_log.write_log('Info: EXTRACTION stage completed');
   EXCEPTION
      WHEN e_extraction THEN
         pck_log.write_halt_extraction_msg;
         ROLLBACK;
      WHEN OTHERS THEN
         ROLLBACK;
         pck_log.write_log('Error: critical error ['||sqlerrm||']');
         pck_log.write_halt_extraction_msg;
   END;
end pck_extract;
/
