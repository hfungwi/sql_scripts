------------------------------------------
--USAGE:        To audit user activity
--REQUIREMENTS: session audit ON
--SYNTAX:       @audit2
--DATE:         4 OCT, 2023
------------------------------------------


REM AUDIT SESSION -- TO TURN AUDITING ON
REM NOAUDIT SESSION -- TO TURN AUDITING OFF


set linesize 200
col username for a15
col os_username for a15
col action_name for a15
col userhost for a27
col client for a15
col terminal for a20

select os_username, username, userhost, terminal, to_char(timestamp, 'YYYY-MM-DD HH24:MI:SS') as "TIME(year-mon-date)",
ACTION_NAME
FROM DBA_AUDIT_SESSION
order by timestamp
/

select
os_username,
username,
userhost,
terminal client,
action_name,
returncode,
to_char(timestamp, 'YYYY-MM-DD HH24:MI:SS') timestamp
from
dba_audit_session
where upper(username) like upper('%&username%')
order by timestamp
/
