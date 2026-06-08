SELECT
        vsess.sid,
        vsess.osuser,
        vsess.username,
        vsess.machine,
        vsql.sql_text
FROM
        v$session vsess,
        v$sql vsql
WHERE
        vsess.sql_id = vsql.sql_id
 AND    vsess.username is not null
ORDER BY
         vsess.username  ;
