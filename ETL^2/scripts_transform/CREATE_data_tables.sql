CREATE TABLE t_clean_products(
	id		NUMBER(10),
	name		VARCHAR2(30),
	brand		VARCHAR2(30),
	pack_size	VARCHAR2(20),
	pack_type	VARCHAR2(30),
	diet_type	VARCHAR2(15),
	liq_weight	NUMBER(8,2),
	category_name	VARCHAR2(20)
);

CREATE TABLE t_clean_stores(
	name		VARCHAR2(100),
	reference	CHAR(6),
	address		VARCHAR2(250),
	zip_code	CHAR(8),
	location	VARCHAR2(40),
	district	VARCHAR2(30),
	telephones	CHAR(9),
	fax		CHAR(9),
	status		VARCHAR2(8),
	manager_name	VARCHAR2(100),
	manager_since	DATE
);


CREATE TABLE t_clean_promotions(
	id		NUMBER(10),
	name		VARCHAR2(100),
	start_date	DATE,
	end_date	DATE,
	reduction	NUMBER(3,2),
	on_street	VARCHAR2(3),
	on_tv		VARCHAR2(3)
);


CREATE TABLE t_clean_sales(
	id		NUMBER(10),
	sale_date	DATE,
	store_id   	CHAR(6)
);


CREATE TABLE t_clean_linesofsale(
	id		NUMBER(10),
	sale_id		NUMBER(10),
	product_id	NUMBER(10),
	promo_id	NUMBER(10),
	line_date	DATE,
	quantity	NUMBER(8,2),
	ammount_paid	NUMBER(11,2)
);



