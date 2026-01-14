col os_username for a12
col username for a16
col terminal for a12
select os_username, username, terminal,
 to_char(timestamp,'mm/dd/yyyy hh24:mi:ss') timestamp,
 returncode
from dba_audit_session
where action_name = 'LOGON'
 and  returncode > 0
order by timestamp
/
