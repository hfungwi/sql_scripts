col member for a35

select v$log.members, v$log.archived, v$logfile.group#, v$logfile.member,
v$logfile.status
from v$log
join v$logfile
on v$log.group#=v$logfile.group#;
