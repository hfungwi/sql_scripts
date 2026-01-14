------------------------------------------
--USAGE:        To audit specifiv user activity
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


SELECT
        os_username,
        username,
        userhost,
        terminal client,
        action_name,
        returncode,
        to_char(timestamp, 'YYYY-MM-DD HH24:MI:SS') timestamp
FROM
        dba_audit_session
WHERE   upper(username) like upper('%&username%')
ORDER BY timestamp
/
