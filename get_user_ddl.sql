---------------------------------------------
-- author : Harris Fungwi
-- desc   : Used to generate ddl for a user
-- date   : 27-MAR-2025
-- usage  : @get_user_ddl.sql
---------------------------------------------
SET LONG 100000
SET LONGCHUNKSIZE 20000
SET PAGESIZE 0
SET LINESIZE 1000
SET SERVEROUT ON SIZE UNLIMITED
SET HEADING OFF
SET FEEDBACK OFF
SET VERIFY OFF
SET TRIMSPOOL ON

-- prompt user for username
DEFINE username = &username ;

-- store output of script in a sql file that could be run to recreate the user
spool dbms_stats.crtusr_${ORACLE_SID}_&username..sql

--for better output
BEGIN
   DBMS_METADATA.set_transform_param (DBMS_METADATA.session_transform, 'SQLTERMINATOR', true);
   DBMS_METADATA.set_transform_param (DBMS_METADATA.session_transform, 'PRETTY', true);
END;
/

-- GENERATE DDL FOR CREATING THE USER
SELECT DBMS_METADATA.GET_DDL('USER','&username') FROM dual;

--get ddl for all grantes to user
SELECT DBMS_METADATA.GET_GRANTED_DDL('ROLE_GRANT', '&username') FROM dual;

-- get ddl for all system grants to the user
DECLARE
 v_output VARCHAR2(32767);
 v_username VARCHAR2(64) := '&username' ;
 exc_no_sys_grant EXCEPTION ;
 PRAGMA exception_init(exc_no_sys_grant, -31608);
BEGIN
  SELECT DBMS_METADATA.GET_GRANTED_DDL('SYSTEM_GRANT', v_username)
  INTO v_output
  FROM dual;
  dbms_output.put_line(v_output);
EXCEPTION
  WHEN exc_no_sys_grant THEN NULL;
END;
/
   
-- get ddl for all object grants to user
DECLARE
  exc_no_obj_grant EXCEPTION;
  PRAGMA EXCEPTION_INIT(exc_no_obj_grant, -31608);
  v_output     CLOB;
  v_username   VARCHAR2(64) := '&username';
BEGIN
    BEGIN
      SELECT DBMS_METADATA.GET_GRANTED_DDL('OBJECT_GRANT', v_username)
      INTO   v_output
      FROM   dual;
      DBMS_OUTPUT.PUT_LINE(DBMS_LOB.SUBSTR(v_output, 32767, 1));
    EXCEPTION
      WHEN exc_no_obj_grant THEN
        DBMS_OUTPUT.PUT_LINE('-- No object grants found for ' || v_username);
    END;
END;
/

SELECT DBMS_METADATA.get_ddl ('SYNONYM', synonym_name, owner)
FROM   all_synonyms
WHERE  owner = UPPER('&USERNAME')
;


spool off;
UNDEFINE username
SET HEADING ON
SET FEEDBACK ON
SET VERIFY ON
SET TRIMSPOOL OFF
SET PAGESIZE 14
SET LONG 80
SET LONGCHUNKSIZE 80
SET LINESIZE 80
SET SERVEROUTPUT OFF
                                                                 
