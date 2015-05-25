CREATE OR REPLACE PACKAGE PCK_TRANSFORM AS

   PROCEDURE main (p_duplicate_last_iteration BOOLEAN);
   PROCEDURE screen_null_liq_weight (p_iteration_key t_tel_iteration.iteration_key%TYPE, p_source_key t_tel_source.source_key%TYPE, p_screen_order t_tel_schedule.screen_order%TYPE);
   PROCEDURE screen_dimensions (p_iteration_key t_tel_iteration.iteration_key%TYPE, p_source_key t_tel_source.source_key%TYPE, p_screen_order t_tel_schedule.screen_order%TYPE);


END PCK_TRANSFORM;
/

create or replace PACKAGE BODY pck_transform IS

   e_transformation EXCEPTION;
   
   -- **********************************
   -- * PUT A QUALITY ERROR IN THE TEL *
   -- **********************************
   PROCEDURE error_log(p_screen_name t_tel_screen.screen_name%TYPE,
                       p_hora_deteccao DATE,
                       p_source_key      t_tel_source.source_key%TYPE,
                       p_iteration_key   t_tel_iteration.iteration_key%TYPE,
                       p_record_id       t_tel_error.record_id%TYPE,
                       p_severity        t_tel_error.error_severity%TYPE) IS
      v_date_key t_tel_date.date_key%TYPE;
      v_screen_key t_tel_screen.screen_key%TYPE;
   BEGIN
      -- GET THE ID OF THE DATE WHEN THE QUALITY ERROR WAS FOUND
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

      -- GET THE KEY OF THE SCREEN WHICH DETECTED THE QUALITY ERROR
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

      -- REGISTER A QUALITY PROBLEM
      INSERT INTO t_tel_error (date_key,screen_key,source_key,iteration_key, record_id, error_severity) VALUES (v_date_key,v_screen_key,p_source_key,p_iteration_key, p_record_id, p_severity);
   EXCEPTION
      WHEN OTHERS THEN
         pck_log.write_log('Error: could not write quality error in "t_tel_error" fact table ['||sqlerrm||']');
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


   -- *************************************************************************************
   -- * FILTER PROBLEMATIC DATA IN THE SIZE OF THE PRODUCTS                               *
   -- * IN                                                                                *
   -- *     p_iteration_key: key of the iteration in which the screen will be run         *
   -- *     p_source_key: key of the source system related to the screen's execution      *
   -- *     p_screen_order: order number in which the screen is to be executed            *
   -- *************************************************************************************
   PROCEDURE screen_dimensions (p_iteration_key t_tel_iteration.iteration_key%TYPE,
                                             p_source_key t_tel_source.source_key%TYPE,
                                             p_screen_order t_tel_schedule.screen_order%TYPE) IS
      
      CURSOR screen_dimensions_cursor IS
      SELECT p.rowid, p.* FROM T_DATA_PRODUCTS p JOIN T_LOOKUP_PACK_DIMENSIONS dims ON UPPER(dims.pack_type) = UPPER(p.pack_type)
      WHERE p.rejected_by_screen = 0 AND ((p.width is null AND p.height is null AND p.depth is null AND dims.has_dimensions = 1) OR
               ((p.width is not null OR p.height is not null OR p.depth is not null) AND dims.has_dimensions = 0));    
      
      i PLS_INTEGER:=0;
      v_screen_name VARCHAR2(30):='screen_dimensions';
   BEGIN
      pck_log.write_log('Action: Start screen "'||v_screen_name||'" with order #'||p_screen_order||' * ');

      FOR product IN screen_dimensions_cursor LOOP
       -- error_log(v_screen_name , sysdate, p_source_key, p_iteration_key, product.rowid, pck_error_codes.c_transform_minorPass_error);
        i := i+1;
      END LOOP;

      pck_log.write_log('Info: Found '|| i || ' line(s) with error; line(s) will not be rejected');
      pck_log.write_log('Done!');
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         pck_log.write_log('Info: No quality errors found');
         pck_log.write_log('Done!');
      WHEN OTHERS THEN
         pck_log.write_log('Error: could not execute screen ['||sqlerrm||']');
         RAISE e_transformation;
   END;


   -- *************************************************************************************
   -- * FILTER PROBLEMATIC DATA IN THE LIQ WEIGHT OF THE PRODUCTS                               *
   -- * IN                                                                                *
   -- *     p_iteration_key: key of the iteration in which the screen will be run         *
   -- *     p_source_key: key of the source system related to the screen's execution      *
   -- *     p_screen_order: order number in which the screen is to be executed            *
   -- *************************************************************************************
   PROCEDURE screen_null_liq_weight (p_iteration_key t_tel_iteration.iteration_key%TYPE,
                                             p_source_key t_tel_source.source_key%TYPE,
                                             p_screen_order t_tel_schedule.screen_order%TYPE) IS
      
      CURSOR screen_null_liq_weight_cursor IS
      SELECT p.rowid tdp_rowid, p.* FROM T_DATA_PRODUCTS p
      WHERE p.rejected_by_screen = 0 AND not ((p.liq_weight is null AND p.PACK_TYPE is null) OR (p.liq_weight is not null AND p.PACK_TYPE is not null));
      
      i PLS_INTEGER:=0;
      v_screen_name VARCHAR2(30):='screen_null_liq_weight';
   BEGIN
      pck_log.write_log('Action: Start screen "'||v_screen_name||'" with order #'||p_screen_order||' * ');

      FOR product IN screen_null_liq_weight_cursor LOOP
        EXECUTE IMMEDIATE  'UPDATE  t_data_products set rejected_by_screen = 1 where rowid=:tdp_rowid' 
        USING product.tdp_rowid;
       
        --error_log(v_screen_name , sysdate, p_source_key, p_iteration_key, product.tdp_rowid, pck_error_codes.c_transform_minorReject_error);
        i := i+1;
      END LOOP;

      pck_log.write_log('Info: Found '|| i || ' line(s) with error; line(s) will not be rejected');
      pck_log.write_log('Done!');
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         pck_log.write_log('Info: No quality errors found');
         pck_log.write_log('Done!');
      WHEN OTHERS THEN
         pck_log.write_log('Error: could not execute screen ['||sqlerrm||']');
         RAISE e_transformation;
   END;

   -- ####################### TRANSFORMATION ROUTINES #######################

   PROCEDURE transform_products IS
   BEGIN
      pck_log.write_log('Action: transform products'' data');

      INSERT INTO t_clean_products(id,name,brand,pack_size,pack_type,diet_type,liq_weight,category_name)
      SELECT prod.id,prod.name,brand,height||'x'||width||'x'||depth,pack_type,cal.type,liq_weight,categ.name
      FROM t_data_products prod, t_lookup_calories cal, t_data_categories categ
      WHERE categ.rejected_by_screen='0' AND prod.rejected_by_screen='0' AND
            calories_100g>=cal.min_calories_100g AND calories_100g<=cal.max_calories_100g AND
            categ.id=prod.category_id;

      pck_log.write_log('Done!');
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         pck_log.write_log('Info: Found no lines to transform');
         pck_log.write_log('Done!');
      WHEN OTHERS THEN
         pck_log.write_log('Error: could not transform products ['||sqlerrm||']');
         RAISE e_transformation;
   END;



   -- **********************************************************
   -- * TRANSFORMATION OF STORES ACCORDING TO LOGICAL DATA MAP *
   -- **********************************************************
   PROCEDURE transform_stores IS
   BEGIN
      pck_log.write_log('Action: transform stores'' data');

      INSERT INTO t_clean_stores(name,reference,address,zip_code,location,district,telephones,fax,status,manager_name,manager_since)
      SELECT name,s.reference,CASE building WHEN '-' THEN NULL ELSE building||' - ' END || address||' / '||zip_code||', '||location,zip_code,location,district,SUBSTR(REPLACE(REPLACE(telephones,'.',''),' ',''),1,9),fax,CASE WHEN closure_date IS NULL THEN 'ACTIVE' ELSE 'INACTIVE' END, manager_name,manager_since
      FROM (SELECT name,reference,building,address,zip_code,location,district,telephones,fax,closure_date
            FROM t_data_stores_new
            WHERE rejected_by_screen='0'
            MINUS
            SELECT name,reference,building,address,zip_code,location,district,telephones,fax,closure_date
            FROM t_data_stores_old) s, t_data_managers_new d
      WHERE s.reference=d.reference AND
            d.rejected_by_screen='0';

      pck_log.write_log('Done!');
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         pck_log.write_log('Info: Found no lines to transform');
         pck_log.write_log('Done!');
      WHEN OTHERS THEN
         pck_log.write_log('Error: could not transform stores ['||sqlerrm||']');
         RAISE e_transformation;
   END;

   -- **********************************************************
   -- * TRANSFORMATION OF PROMOTIONS ACCORDING TO LOGICAL DATA MAP *
   -- **********************************************************
   PROCEDURE transform_promotions IS
   BEGIN
      pck_log.write_log('Action: transform promotions'' data');

      INSERT INTO t_clean_promotions(id, name, start_date, end_date, reduction, on_street, on_tv)
      SELECT id, name, start_date, end_date, reduction, CASE 'on_street' WHEN '1' THEN 'YES' ELSE 'NO' END, CASE 'on_tv' WHEN '1' THEN 'YES' ELSE 'NO' END
      FROM t_data_promotions
      WHERE rejected_by_screen='0';

      pck_log.write_log('Done!');
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         pck_log.write_log('Info: Found no lines to transform');
         pck_log.write_log('Done!');
      WHEN OTHERS THEN
         pck_log.write_log('Error: could not transform promotions ['||sqlerrm||']');
         RAISE e_transformation;
   END;

   -- *********************************************************
   -- * TRANSFORMATION OF SALES ACCORDING TO LOGICAL DATA MAP *
   -- *********************************************************
   PROCEDURE transform_sales IS
   BEGIN
      pck_log.write_log('Action: transform sales'' data');

      INSERT INTO t_clean_sales(id,sale_date,store_id)
      SELECT id,sale_date,store_id
      FROM t_data_sales
      WHERE rejected_by_screen='0';

      pck_log.write_log('Done!');
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         pck_log.write_log('Info: Found no lines to transform');
         pck_log.write_log('Done!');
      WHEN OTHERS THEN
         pck_log.write_log('Error: could not transform sales ['||sqlerrm||']');
         RAISE e_transformation;
   END;



   -- *****************************************************************
   -- * TRANSFORMATION OF LINES OF SALE ACCORDING TO LOGICAL DATA MAP *
   -- *****************************************************************
   PROCEDURE transform_linesofsale IS
   BEGIN
      pck_log.write_log('Action: transform lines of sales'' data');

      INSERT INTO t_clean_linesofsale(id,sale_id,product_id,promo_id,quantity,ammount_paid,line_date)
      SELECT los.id,los.sale_id,los.product_id,losp.promo_id,quantity,ammount_paid, los.line_date
      FROM t_data_linesofsale los LEFT JOIN (SELECT line_id,promo_id
                                            FROM t_data_linesofsalepromotions
                                            WHERE rejected_by_screen='0') losp ON los.id=losp.line_id, t_data_sales
      WHERE los.rejected_by_screen='0' AND
            t_data_sales.id=los.sale_id;

      pck_log.write_log('Done!');
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         pck_log.write_log('Info: Found no lines to transform');
         pck_log.write_log('Done!');
      WHEN OTHERS THEN
         pck_log.write_log('Error: could not transform lines of sale ['||sqlerrm||']');
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
      DELETE FROM t_clean_products;
      DELETE FROM t_clean_linesofsale;
      DELETE FROM t_clean_stores;
      DELETE FROM t_clean_promotions;
      DELETE FROM t_clean_sales;
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
      transform_products;
      transform_stores;
      transform_sales;
      transform_linesofsale;
      transform_promotions;
      
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