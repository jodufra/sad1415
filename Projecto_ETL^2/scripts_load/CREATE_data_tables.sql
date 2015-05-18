CREATE TABLE t_dim_store(
	store_key		NUMBER(5),
	store_natural_key	CHAR(6),
	store_name		VARCHAR2(40),
	store_full_address	VARCHAR2(250),
	store_location		VARCHAR2(40),
	store_district		VARCHAR2(30),
	store_zip_code		CHAR(8),
	store_main_phone	CHAR(9),
	store_main_phone_old	CHAR(9),		-- to store previous telephone value
	store_fax		CHAR(9),
	store_fax_old		CHAR(9),		-- to store previous fax value
	store_manager_name	VARCHAR2(100),
	store_manager_since	DATE,
	store_state		VARCHAR2(8),
	is_expired_version	VARCHAR2(3),	-- {'NO'=current version; 'YES'=expired version}
	CONSTRAINT pk_tdimstore_storeKey PRIMARY KEY (store_key)
);


CREATE TABLE t_dim_product(
	product_key		NUMBER(12),
	product_natural_Key	NUMBER(10),
	product_name		VARCHAR2(30),
	product_brand		VARCHAR2(30),
	product_category	VARCHAR2(20),
	product_size_package	VARCHAR2(20),
	product_type_package	VARCHAR2(30),
	product_diet_type	VARCHAR2(15),
	product_liquid_weight	NUMBER(8,2),
	is_expired_version	VARCHAR2(3),	-- {'NO'=current version; 'YES'=expired version}
	CONSTRAINT pk_tdimproduct_productKey PRIMARY KEY (product_key)
);


CREATE TABLE t_dim_promotion(
	promo_key		NUMBER(12),
	promo_natural_Key	NUMBER(10),
	promo_name		VARCHAR2(100),
	promo_red_Price		NUMBER(3,2),
	promo_advertise		VARCHAR2(3),
	promo_board		VARCHAR2(3),
	promo_start_date	DATE,
	promo_end_date		DATE,
	CONSTRAINT pk_tDimPromotion_promoKey PRIMARY KEY (promo_key)
);


CREATE TABLE t_dim_date(
	date_key		NUMBER(6),
	date_full_date		CHAR(10),
	date_month_full		CHAR(7),
	date_day_nr		NUMBER(2),
	date_is_holiday		CHAR(3),
	date_month_name		VARCHAR2(12),
	date_month_short_name	CHAR(3),
	date_month_nr		NUMBER(2),
	date_quarter_nr		NUMBER(1),
	date_quarter_full	CHAR(7),
	date_semester_nr	NUMBER(1),
	date_semester_full	CHAR(7),
	date_event		VARCHAR2(100),
	date_year		NUMBER(4),
	CONSTRAINT pk_tDimDate_dateKey PRIMARY KEY (date_key)
);


CREATE TABLE t_dim_time(
	time_key		NUMBER(6),
	time_full_time		CHAR(8),
	time_period_of_day	VARCHAR2(20),
	time_minutes_after_midnight	NUMBER(4),
	time_hour_nr		NUMBER(2),
	time_minute_nr		NUMBER(2),
	time_second_nr		NUMBER(2),
	CONSTRAINT pk_tDimTime_timeKey PRIMARY KEY (time_key)
);


CREATE TABLE t_fact_lineofsale(
	product_key		NUMBER(12),
	store_key		NUMBER(5),
	date_key		NUMBER(6),
	time_key		NUMBER(6),
	promo_key		NUMBER(12),
	sale_id_dd		NUMBER(10),
	sold_quantity		NUMBER(5,2),
	ammount_sold		NUMBER(7,2),
	CONSTRAINT pk_tFactlineofsale_pk 		PRIMARY KEY (time_key, sale_id_dd),
	CONSTRAINT fk_tFactlineofsale_productkey 	FOREIGN KEY (product_key) REFERENCES t_dim_product(product_key),
	CONSTRAINT fk_tFactlineofsale_storekey 	FOREIGN KEY (store_key) REFERENCES t_dim_store(store_key),
	CONSTRAINT fk_tFactlineofsale_timekey 	FOREIGN KEY (time_key) REFERENCES t_dim_time(time_key),
	CONSTRAINT fk_tFactlineofsale_datekey 	FOREIGN KEY (date_key) REFERENCES t_dim_date(date_key),
	CONSTRAINT fk_tFactlineofsale_promokey 	FOREIGN KEY (promo_key) REFERENCES t_dim_promotion(promo_key)
);


