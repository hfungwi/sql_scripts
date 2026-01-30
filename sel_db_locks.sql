-- for a given db application
-- select locks cause by users of the appplication ie sessions connected as the application account

set linesize 200
col objects for a30
col osuser for a20
col username for a20
col machine for a20
col program for a30


SELECT
    l.sid,
    s.serial#,
    s.username,
    s.osuser,
    s.machine,
    s.program,
    s.seconds_in_wait,
    l.type,
    l.lmode,
    l.id1,
    o.owner || '.' || o.object_name objects
FROM
         v$lock l
    JOIN v$session   s ON l.sid = s.sid
    LEFT JOIN all_objects o ON l.id1 = o.object_id
WHERE s.type <> 'BACKGROUND'
AND o.owner || '.' || o.object_name <> 'SYS.ORA$BASE'
AND   o.owner LIKE '%&application_account_username%'
ORDER BY s.seconds_in_wait DESC
/
