create or replace PACKAGE PCK_LOG AS

  PROCEDURE clean;

  PROCEDURE write_log(p_log_text VARCHAR2);
  PROCEDURE write_rollback_msg;
  PROCEDURE write_halt_transformation_msg;
  PROCEDURE write_halt_extraction_msg;
  PROCEDURE write_halt_load_msg;

END PCK_LOG;
/

create or replace PACKAGE BODY PCK_LOG AS

  g_current_log_table_name VARCHAR2(30);
  g_current_log_id PLS_INTEGER:=1;
  
   -- *******************************************************
   -- * RECORDS A MESSAGE IN THE CURRENT LOG TABLE          *
   -- *******************************************************
   PROCEDURE write_log(p_log_text VARCHAR2) IS
      PRAGMA AUTONOMOUS_TRANSACTION;
   BEGIN
      EXECUTE IMMEDIATE 'INSERT INTO '||g_current_log_table_name||' (id,log_text,execution_start) VALUES (:1,:2,:3)' USING g_current_log_id, p_log_text,systimestamp;
      g_current_log_id:=g_current_log_id+1;
      COMMIT;
    EXCEPTION
      WHEN OTHERS THEN
        ROLLBACK;
        RAISE_APPLICATION_ERROR (-20900,'Error writting to log table ['||sqlerrm||']');
   END;
   

   PROCEDURE write_rollback_msg IS
   BEGIN
      write_log('Info: All new/updated data rolled back');
   END;
   
   
   PROCEDURE write_halt_transformation_msg IS
   BEGIN
      write_log('Info: TRANSFORMATION stage halted');
      write_rollback_msg;
   END;
   
   PROCEDURE write_halt_extraction_msg IS
   BEGIN
      write_log('Info: EXTRACTION stage halted');
      write_rollback_msg;
   END;

   PROCEDURE write_halt_load_msg IS
   BEGIN
      write_log('Info: LOAD stage halted');
      write_rollback_msg;
   END;



   -- ******************************************
   -- * CLEANS THE CURRENT LOG TABLE           *
   -- ******************************************

   PROCEDURE clean AS
      PRAGMA AUTONOMOUS_TRANSACTION;
   BEGIN
      DELETE FROM t_log_etl;
      g_current_log_table_name:='t_log_etl';
      COMMIT;
   EXCEPTION
      WHEN OTHERS THEN
         ROLLBACK;
         RAISE_APPLICATION_ERROR (-20901,'Error: could not clean log table ['||sqlerrm||'].');
   END;


  
END;

/