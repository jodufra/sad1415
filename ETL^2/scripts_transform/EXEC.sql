-- CREATES AND POPULATES THE DSA STRUCTURES
@@CREATE_data_tables
@@CREATE_lookup_tables

-- CREATES THE TRANSFORMATION ERROR LOGGER (TEL) STRUCTURES
@@create_tel_tables
@@create_sequences
@@create_triggers
@@create_views

@@CREATE_package_pck_transform
@@INSERT_data.sql

COMMIT;
