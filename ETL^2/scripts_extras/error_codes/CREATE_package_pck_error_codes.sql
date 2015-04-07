create or replace PACKAGE PCK_ERROR_CODES AS

  c_extract_NOERROR CONSTANT INTEGER:= -1;
  c_extract_initialize_error CONSTANT INTEGER:= 0;
  c_extract_getsourcedata_error  CONSTANT INTEGER:= 1;
  c_extract_delOldInit_error CONSTANT INTEGER:= 2;  -- for error while deleting old intialization of extractions info
  
  c_transform_NOERROR CONSTANT INTEGER:=-1;           -- no error occurred
  c_transform_minorPass_error CONSTANT INTEGER:=0;    -- allows the record to pass and continues ETL
  c_transform_minorReject_error CONSTANT INTEGER:=1;  -- rejects record but continues ETL
  c_transform_critical_error CONSTANT INTEGER:=2;     -- STOPS ETL
  c_transform_initialize_error CONSTANT INTEGER:=3;   -- error while initializing a screen, iteration, time or source

  c_load_NOERROR CONSTANT INTEGER:=-1;                -- no error occurred
  c_load_initialize_error CONSTANT INTEGER:=1;        -- error while initializing a dimension
  c_load_critical_error CONSTANT INTEGER:=10;         -- STOPS ETL
  c_load_invalid_dim_record_Nkey CONSTANT INTEGER:=-1;   -- used as the NATURAL key to represent invalid dimension records
  c_load_invalid_dim_record_key CONSTANT INTEGER:=0;     -- used as the DIMENSION key to represent invalid dimension records
  
  
  -- returns if error is critical to the ETL process
  FUNCTION extract_error_is_not_critical(p_error_code INTEGER) RETURN BOOLEAN;
  FUNCTION transf_error_is_not_critical(p_error_code INTEGER) RETURN BOOLEAN;
  FUNCTION load_error_is_not_critical(p_error_code INTEGER) RETURN BOOLEAN;

END PCK_ERROR_CODES;
/

