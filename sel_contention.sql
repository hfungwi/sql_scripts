-------------------------------------------------------
-- Author : Harris Fungwi
-- Date : 13 Feb 2026
-- Desc : Display details of contention activity in by
--        connected sesssions in the database where the
--        state is "waiting"
-- Privieleges : requires dba or similar
-----------------------------------------------------

select
      sess.sid,
      sql.sql_id,
      sql.sql_fulltext as sql_statement
from
           gv$sql     sql
inner join gv$session sess on sess.sql_id = sql.sql_id
where sql.sql_id IN (
                        SELECT sql_id
                        FROM   gv$session
                        WHERE event in ('enq: TM - contention', 'enq: TX - row lock contention')
                        AND state = 'WAITING'
                    )
/
