col osuser  for a15
col username for a20
col machine for a15

select sid, osuser, username, sql_id, machine
from v$session
where username is not null
order by username
/
