set linesize 200
set pagesize 10000
set trimout on
set trimspool on
col db_link format a15
col column_name format a10
col owner format a20
col grantee format a20
col grantor format a20
col PRIVILEGE format a30
col role format a15
col sql_stmt for a130
col table_owner format a20
spool crtusr_${ORACLE_SID}_&1..sql

select sql_stmt
from
(select username, 1 stmt_seq,
           'create user '||username
         ||' default tablespace '||DEFAULT_TABLESPACE
         ||' temporary tablespace '||TEMPORARY_TABLESPACE
         ||' identified '||decode(substr(username,1,4),
                  'OPS$','EXTERNALLY',' by values '''||password||'''')
         ||decode(profile,
                  'DEFAULT','',' profile '||profile)
         ||';'      sql_stmt
 from dba_users
--
 union
 select username, 2 stmt_seq,
           'alter user '||username
         ||' quota '||decode(max_bytes,-1,'UNLIMITED',max_bytes)
         ||' on '||tablespace_name
         ||';'      sql_stmt
 from dba_ts_quotas
--
 union
 select grantee username, 3 stmt_seq,
           'grant '||privilege
         ||' to '||grantee
         ||';'      sql_stmt
 from dba_sys_privs
--
 union
 select grantee username, 4 stmt_seq,
           'grant '||granted_role
         ||' to '||grantee
         ||decode(admin_option,'YES',' with admin option')
         ||';'      sql_stmt
 from dba_role_privs
--
 union
 select username, 5 stmt_seq,
           'alter user '||username
         ||' account lock ;'      sql_stmt
 from dba_users
 where lock_date is not null
) subqry
 where exists
       (select 'X'
        from dba_users du
        where subqry.username = du.username)
  and  username not in
   (
   'ANONYMOUS'
  ,'APPQOSSYS'
  ,'AUDSYS'
  ,'DBSFWUSER'
  ,'DBSNMP'
  ,'DIP'
  ,'GGSYS'
  ,'GSMADMIN_INTERNAL'
  ,'GSMCATUSER'
  ,'GSMUSER'
  ,'ORACLE_OCM'
  ,'OUTLN'
  ,'REMOTE_SCHEDULER_AGENT'
  ,'SYS'
  ,'SYS$UMF'
  ,'SYSBACKUP'
  ,'SYSDG'
  ,'SYSKM'
  ,'SYSRAC'
  ,'SYSTEM'
  ,'WMSYS'
  ,'XDB'
  ,'XS$NULL'
   )
order by username, stmt_seq
;
spool off
