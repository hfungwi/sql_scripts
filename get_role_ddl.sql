---------------------------------------------
-- author : Harris Fungwi
-- desc   : Used to get the ddl for a role, including all grants to the role
-- date   : 22-July-2026
-- usage  : @get_role_ddl.sql
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

-- prompt user for role name
DEFINE role = &role ;

-- store output of script in a sql file that could be run to recreate the role
spool dbms_stats.crtusr_${ORACLE_SID}_&role..sql

--for "pretty" output
BEGIN
   DBMS_METADATA.set_transform_param (DBMS_METADATA.session_transform, 'SQLTERMINATOR', true);
   DBMS_METADATA.set_transform_param (DBMS_METADATA.session_transform, 'PRETTY', true);
END;
/


-- Get the ddl for the role
DECLARE
 v_rolename VARCHAR2(64) := '&role' ;
 v_output   VARCHAR2(32767);
BEGIN
        SELECT DBMS_METADATA.get_ddl ('ROLE', v_rolename)
        INTO v_output
        FROM DUAL;
        dbms_output.put_line(v_output);
END;
/

-- get ddl for all grants to the role
DECLARE
  exc_no_obj_grant EXCEPTION;
  PRAGMA EXCEPTION_INIT(exc_no_obj_grant, -31608);
  v_rolename   VARCHAR2(64) := '&role' ;
  v_output     CLOB;
BEGIN
      BEGIN
        SELECT DBMS_METADATA.GET_GRANTED_DDL('OBJECT_GRANT', v_rolename )
        INTO   v_output
        FROM   dual;
        DBMS_OUTPUT.PUT_LINE(DBMS_LOB.SUBSTR(v_output, 32767, 1));
      EXCEPTION
        WHEN exc_no_obj_grant THEN
          DBMS_OUTPUT.PUT_LINE('-- No object grants found for role ' || v_rolename);
      END;
END;
/

spool off;
SET HEADING ON
SET FEEDBACK ON
SET VERIFY ON
SET TRIMSPOOL OFF
SET PAGESIZE 14
SET LONG 80
SET LONGCHUNKSIZE 80
SET LINESIZE 80
SET SERVEROUTPUT OFF
