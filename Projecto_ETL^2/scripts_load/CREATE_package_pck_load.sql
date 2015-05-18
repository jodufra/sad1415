create or replace package pck_load is
   PROCEDURE main (p_load_dates BOOLEAN, p_init_dimensions BOOLEAN);
END;
/


create or replace
package body pck_load is

   e_load EXCEPTION;

   -- **************************************************
   -- * INITIALIZE DIMENSIONS WITH AN 'INVALID RECORD' *
   -- **************************************************
   PROCEDURE init_dimensions IS
   BEGIN
      pck_log.write_log('Action: Initialize dimensions with "invalid" record');
      -- 'INVALID PRODUCT'
      INSERT INTO t_dim_product (product_key,product_natural_key,product_name,product_brand,product_category,product_size_package,product_type_package,product_diet_type,product_liquid_weight,is_expired_version)
      VALUES (pck_error_codes.c_load_invalid_dim_record_key, pck_error_codes.c_load_invalid_dim_record_Nkey,'INVALID PRODUCT',NULL,NULL,NULL,NULL,NULL,NULL,'NO');
      -- 'INVALID PROMOTION'
      INSERT INTO t_dim_promotion (promo_key,promo_natural_key,promo_name,promo_red_price,promo_advertise,promo_board,promo_start_date,promo_end_date)
      VALUES (pck_error_codes.c_load_invalid_dim_record_key, pck_error_codes.c_load_invalid_dim_record_Nkey,'INVALID PROMOTION',NULL,NULL,NULL,NULL,NULL);
      -- 'INVALID DATE'
      INSERT INTO t_dim_date (date_key,date_full_date,date_month_full,date_month_name,date_month_short_name,date_month_nr,date_quarter_nr,date_quarter_full,date_semester_nr,date_semester_full,date_event,date_year, date_day_nr,date_is_holiday)
      VALUES (pck_error_codes.c_load_invalid_dim_record_key, 'INVALID',NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
      -- 'INVALID TIME'
      INSERT INTO t_dim_time (time_key,time_full_time,time_period_of_day,time_minutes_after_midnight,time_hour_nr,time_minute_nr,time_second_nr)
      VALUES (pck_error_codes.c_load_invalid_dim_record_key, 'INVALID',NULL,NULL,NULL,NULL,NULL);
      -- 'INVALID STORE'
      INSERT INTO t_dim_store (store_key,store_natural_key,store_name,store_full_address,store_location,store_district,store_zip_code,store_main_phone,store_main_phone_old,store_fax,store_fax_old,store_manager_name,store_manager_since,store_state,is_expired_version)
      VALUES (pck_error_codes.c_load_invalid_dim_record_key, pck_error_codes.c_load_invalid_dim_record_Nkey, 'INVALID STORE', 'NOT APPLICABLE', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 'NO');
      
      pck_log.write_log('Done!');
   EXCEPTION
      WHEN OTHERS THEN
         pck_log.write_log('Error: could not initialize dimensions ['||sqlerrm||'].');
         RAISE e_load;
   END;



   -- **********************************
   -- * LOAD THE PROMOTION DIMENSION   *
   -- **********************************
   PROCEDURE load_dim_promotion IS
   BEGIN
      pck_log.write_log('Action: Load promotions');

      -- FOR EACH NEW OR UPDATED SOURCE PROMOTION, APPLY SCD CHANGES
      -- SOMETHING IS MISSING... I CAN DO THIS, I CAN DO THIS, I CAN DO THIS...
      null;

      pck_log.write_log('Info: '||SQL%ROWCOUNT|| ' promotion(s) merged');
      pck_log.write_log('Done!');
   EXCEPTION
      WHEN OTHERS THEN
         pck_log.write_log('Error: Could not load dimension ['||sqlerrm||']');
         RAISE e_load;
   END;



   -- *********************************
   -- * LOADS THE PRODUCT   DIMENSION *
   -- *********************************
   PROCEDURE load_dim_product IS
      CURSOR products_cursor IS
         SELECT id,name,brand,pack_size,pack_type,diet_type,liq_weight,category_name
         FROM t_clean_products;

      -- COUNTERS
      i INTEGER:=0;
      v_new_products INTEGER:=0;
      v_new_versions INTEGER:=0;
      v_old_versions INTEGER:=0;

      -- VARIABLES FOR SCD CHECKING
      v_product_key t_dim_product.product_key%TYPE;
      v_size_package t_dim_product.product_size_package%TYPE;
      v_type_package t_dim_product.product_type_package%TYPE;
      v_diet_type t_dim_product.product_diet_type%TYPE;
      v_liquid_weight t_dim_product.product_liquid_weight%TYPE;
   BEGIN
      pck_log.write_log('Action: Load products');
      FOR rec IN products_cursor LOOP
         -- SEARCH THE PRODUCT IN THE DIMENSION BY SELECTING SCD2 ATTRIBUTES
         BEGIN
            SELECT product_key, NVL(UPPER(product_size_package),-1),NVL(UPPER(product_type_package),-1),UPPER(product_diet_type),NVL(product_liquid_weight,-1)
            INTO v_product_key,v_size_package,v_type_package,v_diet_type,v_liquid_weight
            FROM t_dim_product
            WHERE product_natural_key=rec.id AND is_expired_version='NO';

            -- IF A RECORD WAS FOUND, THEN THE SOURCE PRODUCT IS IN FACT A NEW VERSION:
            -- DID ANY OF THE SCD2 ATTRIBUTES CHANGE?
            null;

         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               -- IF NOT FOUND, THEN ITS A NEW PRODUCT
               INSERT INTO t_dim_product (product_key,PRODUCT_NATURAL_KEY,PRODUCT_NAME,PRODUCT_BRAND,PRODUCT_CATEGORY,PRODUCT_SIZE_PACKAGE,PRODUCT_TYPE_PACKAGE,PRODUCT_DIET_TYPE,PRODUCT_LIQUID_WEIGHT,IS_EXPIRED_VERSION)
               VALUES (seq_dim_product.NEXTVAL, rec.id,rec.name,rec.brand,rec.category_name,rec.pack_size,rec.pack_type,rec.diet_type,rec.liq_weight,'NO');
               v_new_products:=v_new_products+1;
         END;
      END LOOP;
      -- RECORD SOME STATISTICS CONCERNING LOADED PRODUCTS
      pck_log.write_log(v_old_versions|| ' old product(s) updated in SCD1 attributes');
      pck_log.write_log(v_new_versions|| ' old product(s) got new version(s) (old have expired)');
      pck_log.write_log(v_new_products|| ' new product(s) found and loaded');
      pck_log.write_log('Done!');
   EXCEPTION
      WHEN OTHERS THEN
         pck_log.write_log('Error: Could not load dimension ['||sqlerrm||']');
         RAISE e_load;
   END;



   -- *******************************
   -- * LOADS THE STORE   DIMENSION *
   -- *******************************
   PROCEDURE load_dim_store IS
      CURSOR stores_cursor IS
         SELECT name,reference,address,zip_code,location,district,telephones,fax,status,manager_name,manager_since
         FROM t_clean_stores;

      v_table_name VARCHAR2(30):='t_dim_store';
      -- COUNTERS
      i INTEGER:=0;
      v_new_stores INTEGER:=0;
      v_new_versions INTEGER:=0;
      v_old_versions INTEGER:=0;

      -- VARIABLES FOR SCD CHECKING
      v_store_key t_dim_store.store_key%TYPE;
      v_store_name t_dim_store.store_name%TYPE;
      v_manager_name t_dim_store.store_manager_name%TYPE;
      v_manager_since t_dim_store.store_manager_since%TYPE;
      v_store_main_phone t_dim_store.store_main_phone%TYPE;
      v_store_fax t_dim_store.store_fax%TYPE;
      v_old_main_phone t_dim_store.store_main_phone%TYPE;
      v_old_fax t_dim_store.store_fax%TYPE;
   BEGIN
      pck_log.write_log('Action: Load stores');
      FOR rec IN stores_cursor LOOP
         -- SEARCH THE STORE IN THE DIMENSION BY SELECTING SCD2 AND SCD3 ATTRIBUTES
         BEGIN
            SELECT store_key, UPPER(store_name),UPPER(store_manager_name),store_manager_since, store_main_phone,store_fax
            INTO v_store_key,v_store_name,v_manager_name,v_manager_since,v_store_main_phone,v_store_fax
            FROM t_dim_store
            WHERE store_natural_key=rec.reference AND is_expired_version='NO';

            -- IF A RECORD WAS FOUND, THEN THE SOURCE STORE IS IN FACT A NEW STORE VERSION:
            -- DID ANY OF THE SCD3 ATTRIBUTES CHANGE?
            v_old_main_phone:=NULL;
            IF rec.telephones<>v_store_main_phone THEN
               -- the old phone is kept
               v_old_main_phone:=v_store_main_phone;
            END IF;

            v_old_fax:=NULL;

            IF rec.fax<>v_store_fax THEN
               -- the old fax is kept
               v_old_fax:=v_store_fax;
            END IF;

            -- HAVE ANY OF THE SCD2 ATTRIBUTES CHANGE?
            IF UPPER(rec.name)!=v_store_name OR
               UPPER(rec.manager_name)!=v_manager_name OR
               rec.manager_since!=v_manager_since THEN

               -- UPDATE THE PREVIOUS VERSION OF THE STORE TO THE STATE 'EXPIRED'
               UPDATE t_dim_store
               SET is_expired_version='YES'
               WHERE store_key=v_store_key;

               -- INSERT THE NEW STORE'S VERSION
               INSERT INTO t_dim_store (store_key,store_natural_key,store_name,store_full_address,store_location,store_district,store_zip_code,store_main_phone,store_main_phone_old,store_fax,store_fax_old,store_manager_name,store_manager_since,store_state,is_expired_version)
               VALUES (seq_dim_store.NEXTVAL, rec.reference,rec.name,rec.address,rec.location,rec.district,rec.zip_code,rec.telephones,v_old_main_phone,rec.fax,v_old_fax,rec.manager_name,rec.manager_since,rec.status,'NO');
               v_new_versions:=v_new_versions+1;
            ELSE
               -- NO SCD2 ATTRIBUTES CHANGED? THEN AT LEAST ONE SCD1 OR SCD3 ATTRIBUTE MUST BE DIFFERENT
               -- UPDATE THE SCD1 ATTRIBUTES OF THE MOST RECENT VERSION OF THE STORE
               UPDATE t_dim_store
               SET store_full_address=rec.address,
                   store_location=rec.location,
                   store_district=rec.district,
                   store_zip_code=rec.zip_code,
                   store_manager_since=rec.manager_since,
                   store_manager_name=rec.manager_name,
                   -- SCD3 attributes
                   store_main_phone=rec.telephones,
                   store_fax=rec.fax,
                   store_main_phone_old=v_old_main_phone,
                   store_fax_old=v_old_fax
               WHERE store_key=v_store_key;

               v_old_versions:=v_old_versions+1;
            END IF;
         EXCEPTION
            WHEN NO_DATA_FOUND THEN
               -- IF NOT FOUND, THEN ITS A NEW STORE
               -- SCD3 _old ATTRIBUTES ARE NOT FILLED
               INSERT INTO t_dim_store (store_key,store_natural_key,store_name,store_full_address,store_location,store_district,store_zip_code,store_main_phone,store_main_phone_old,store_fax,store_fax_old,store_manager_name,store_manager_since,store_state,is_expired_version)
               VALUES (seq_dim_store.NEXTVAL, rec.reference,rec.name,rec.address,rec.location,rec.district,rec.zip_code,rec.telephones,NULL,rec.fax,NULL,rec.manager_name,rec.manager_since,rec.status,'NO');
               v_new_stores:=v_new_stores+1;
         END;
      END LOOP;
      -- RECORD SOME STATISTICS CONCERNING LOADED PRODUCTS
      pck_log.write_log(v_old_versions|| ' old store(s) updated in SCD1 attributes');
      pck_log.write_log(v_new_versions|| ' old store(s) got new version(s) (old have expired)');
      pck_log.write_log(v_new_stores|| ' new store(s) found and loaded');
      pck_log.write_log('Done!');
   EXCEPTION
      WHEN OTHERS THEN
         pck_log.write_log('Error: Could not load dimension ['||sqlerrm||']');
         RAISE e_load;
   END;



   -- ******************************
   -- * LOADS THE DATE   DIMENSION *
   -- ******************************
   PROCEDURE load_dim_date IS
   BEGIN
      pck_log.write_log('Action: Load "t_dim_date" dimension');
      -- LOAD ALL DATE RECORDS FROM FILE
      INSERT INTO t_dim_date(date_key,date_full_date,date_month_full,date_month_name,date_month_short_name,date_month_nr,date_quarter_nr,date_quarter_full,date_semester_nr,date_semester_full,date_day_nr,date_is_holiday,date_event,date_year)
         SELECT 	date_key,
			date_full_date,
			date_month_full,
			date_month_name,
			date_month_short_name,
			date_month_nr,
			date_quarter_nr,
			date_quarter_full,
			date_semester_nr,
			date_semester_full,
			date_day_nr,
			date_is_holiday,
			date_event,
			date_year
         FROM t_ext_dates;

      pck_log.write_log('Info: '||SQL%ROWCOUNT ||' record(s) successfully loaded');
      pck_log.write_log('Done!');
   EXCEPTION
      WHEN OTHERS THEN
         pck_log.write_log('Error: Could not load dimension ['||sqlerrm||']');
         RAISE e_load;
   END;



   -- ****************************
   -- * LOADS THE TIME DIMENSION *
   -- ****************************
   PROCEDURE load_dim_time IS
   BEGIN
      pck_log.write_log('Action: Load "t_dim_time" dimension');
      -- LOAD ALL TIME RECORDS FROM FILE
      INSERT INTO /*+ APPEND */ t_dim_time(time_key,time_full_time,time_period_of_day,time_minutes_after_midnight,time_hour_nr,time_minute_nr,time_second_nr)
         SELECT   time_key,
                  time_full_time,
                  time_period_of_day,
                  time_minutes_after_00,
                  time_hour_nr,
                  time_minute_nr,
                  time_second_nr
         FROM t_ext_time;
      
      pck_log.write_log('Info: '||SQL%ROWCOUNT ||' record(s) successfully loaded');
      pck_log.write_log('Done!');
   EXCEPTION
      WHEN OTHERS THEN
         pck_log.write_log('Error: Could not load dimension ['||sqlerrm||']');
         RAISE e_load;
   END;



   -- ***********************
   -- * LOAD THE FACT TABLE *
   -- ***********************
   PROCEDURE load_fact_table IS
      v_source_lines INTEGER;
   BEGIN
      -- JUST FOR STATISTICS
      SELECT COUNT(*)
      INTO v_source_lines
      FROM t_clean_linesofsale;

      -- SOMETHING IS MISSING
      null;

      pck_log.write_log('Info: '||SQL%ROWCOUNT ||' fact(s) loaded');
      pck_log.write_log('Done!');
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
         pck_log.write_log('Info: No facts generated from '||v_source_lines||' source lines-of-sale');
      WHEN OTHERS THEN
         pck_log.write_log('Error: Could not load fact table ['||sqlerrm||']');
         RAISE e_load;
   END;




   -- *****************************************************************************************************
   -- *                                             MAIN                                                  *
   -- *                                                                                                   *
   -- * EXECUTES THE LOADING PROCESS                                                                      *
   -- * IN                                                                                                *
   -- *     p_load_dates: TRUE=t_dim_date dimension will be loaded                                        *
   -- *     p_init_dimensions: TRUE=all dimensions will be filled with an INVALID record                  *
   -- *****************************************************************************************************
   PROCEDURE main (p_load_dates BOOLEAN,
                   p_init_dimensions BOOLEAN) IS
   BEGIN
      pck_log.write_log('Info: entering LOAD stage');

      -- LOAD TIME RELATED DIMENSIONS
      IF p_load_dates THEN
         load_dim_date;
         load_dim_time;
      END IF;

      -- INTIALIZE DIMENSIONS
      IF p_init_dimensions THEN
         init_dimensions;
      END IF;

      -- SOMETHING IS MISSING
      null;

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