set linesize 200
set pagesize 400
set long 10000
col username for a15
col osuser   for a15
col process  for a10
col machine  for a20
col terminal for a15
col program  for a20
col spid     for a10
col sql_text for a40

SELECT
        s.sid
       ,s.serial#
       ,s.username
       ,s.osuser
       ,s.process
       ,s.machine
       ,s.terminal
       ,s.program
       ,p.spid
       ,coalesce( dbms_lob.substr(t.sql_fulltext,4000,1)
                 ,dbms_lob.substr(t.sql_fulltext,4000,4001)
                 ,dbms_lob.substr(t.sql_fulltext,4000,8001)
                ) sql_text
FROM
       v$session s,
       v$process p,
       v$sqlarea t
WHERE
      s.sid = &sid
  AND s.paddr=p.addr
  AND t.address(+)=s.sql_address
/

set linesize 80
set pagesize 40
