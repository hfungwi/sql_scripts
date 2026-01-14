set linesize 200
set pagesize 900
col username for a20
col osuser for a20
col process for a20
col machine for a20
col terminal for a20
col sid for a20
col program for a20
col spid for a20
col serial# for a20
set long 10000
col DBMS_LOB.SUBSTR(T.SQL_FULLTEXT,4000,4000,8001) for a60
--
SELECT
        dbms_lob.substr(sql_fulltext,4000,1)
       ,dbms_lob.substr(sql_fulltext,4000,4001)
       ,dbms_lob.substr(sql_fulltext,4000,8001) sql_text
from  v$sqlarea
where sql_id = '&sql_id'
/
