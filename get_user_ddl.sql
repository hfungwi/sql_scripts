---------------------------------------------
-- author : Harris Fungwi
-- desc   : Used to
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

DEFINE username = &username ;

spool dbms_stats.crtusr_${ORACLE_SID}_&username..sql
BEGIN
   DBMS_METADATA.set_transform_param (DBMS_METADATA.session_transform, 'SQLTERMINATOR', true);
   DBMS_METADATA.set_transform_param (DBMS_METADATA.session_transform, 'PRETTY', true);
END;
/

SELECT DBMS_METADATA.GET_DDL('USER','&username') FROM dual;

DECLARE
 v_username VARCHAR2(128) := '&username' ;
 CURSOR granted_role_cur is
          SELECT granted_role
          FROM   dba_role_privs
          WHERE grantee = v_username
          AND    granted_role NOT IN ('PLUSTRACE', 'CONNECT','RESOURCE');
 v_rolename VARCHAR2(64);
 v_output   VARCHAR2(32767);
BEGIN
    FOR i in granted_role_cur
      LOOP
       v_rolename := i.granted_role;
        SELECT DBMS_METADATA.get_ddl ('ROLE', v_rolename)
        INTO v_output
        FROM DUAL;
        dbms_output.put_line(v_output);
      END LOOP;
END;
/

SELECT DBMS_METADATA.GET_GRANTED_DDL('ROLE_GRANT', '&username') FROM dual;

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

DECLARE
  exc_no_obj_grant EXCEPTION ;
  PRAGMA exception_init(exc_no_obj_grant, -31608);
  v_output VARCHAR2(32767);
  v_username VARCHAR2(64) := '&username' ;
   CURSOR granted_role_cur is
          SELECT granted_role
          FROM   dba_role_privs
          WHERE grantee = v_username
          AND    granted_role NOT IN ('PLUSTRACE', 'CONNECT','RESOURCE');
  v_rolename VARCHAR2(64) ;

TYPE role_table  IS TABLE OF VARCHAR2(64);
list_of_roles role_table ;
BEGIN
 SELECT granted_role BULK COLLECT INTO list_of_roles
  FROM   dba_role_privs
  WHERE  grantee = v_username
  AND    granted_role NOT IN ('PLUSTRACE','CONNECT','RESOURCE');

  IF list_of_roles.count = 0
   THEN
          SELECT
                DBMS_METADATA.GET_GRANTED_DDL('OBJECT_GRANT', v_username )
          INTO  v_output
          FROM dual;
                dbms_output.put_line(v_output);
  ELSE
     FOR l_roles in 1 .. list_of_roles.count
      LOOP
        SELECT
                DBMS_METADATA.GET_GRANTED_DDL('OBJECT_GRANT', l_roles )
          INTO  v_output
          FROM dual;
                dbms_output.put_line(v_output);
      END LOOP;
        SELECT
                DBMS_METADATA.GET_GRANTED_DDL('OBJECT_GRANT', v_username )
          INTO  v_output
          FROM dual;
                dbms_output.put_line(v_output);
  END IF;
EXCEPTION
  WHEN exc_no_obj_grant THEN
     FOR i in granted_role_cur
       LOOP
         v_rolename := i.granted_role ;
            SELECT
                  DBMS_METADATA.GET_GRANTED_DDL('OBJECT_GRANT', v_rolename)
            INTO  v_output
            FROM  dual ;
                  dbms_output.put_line(v_output);
       END LOOP;
END;
/

SELECT DBMS_METADATA.get_ddl ('SYNONYM', synonym_name, owner)
FROM   all_synonyms
WHERE  owner = UPPER('&USERNAME')
;


spool off;
