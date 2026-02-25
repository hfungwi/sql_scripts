-- display wait stats for current session
-- useful for debugging session activity 
select
   event
  ,total_waits
  ,total_timeouts
  ,secs
  ,rpad(to_char(100 * ratio_to_report(secs) over (), 'FM000.00') || '%',8)  pct
  ,max_wait
from (
  select
     event
    ,total_waits
    ,total_timeouts
    ,time_waited/100 secs
    ,max_wait
  from v$session_event
  where sid = sys_context('USERENV','SID')
  and event not like 'SQL*Net%'
)
/
