-- display info about blocked sessions 
-- and the sessions doing the blocking

col blocker_user for a20
col blocker_status for a20
col blocked_user  for a20
col blocked_event for a35
col ws.seconds_in_wait for a20
set linesize 200
--
SELECT
     bs.sid              AS blocker_sid,
     bs.serial#          AS blocker_serial,
     bs.username         AS blocker_user,
     bs.status           AS blocker_status,
     ws.sid              AS blocked_sid,
     ws.serial#          AS blocked_serial,
     ws.username         AS blocked_user,
     ws.event            AS blocked_event,
     ws.seconds_in_wait
  FROM
       v$session ws
  JOIN v$session bs  ON ws.blocking_session = bs.sid
ORDER BY
        ws.seconds_in_wait DESC
/
