SELECT
      s.sid,
      s.serial#,
      s.username,
      s.program,
      t.used_ublk * to_number(p.value)/1024/1024 AS undo_usage_mb,
      t.used_urec   number_of_records
FROM
      v$session     s,
      v$transaction t,
      v$parameter   p
WHERE
      s.taddr=t.addr
  AND p.name='db_block_size'
 ORDER BY
       5 DESC
/
