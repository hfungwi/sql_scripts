-- File    : dba_free_space.sql
-- Purpose : Lists the total amount of free space in each tablespace
-- Params  : None
-- Run As  : SYS, SYSTEM or DBA equivalent
-- Notes   : This query was taken from Oracle Server Manager
-- History : 12-APR-1993  initial code
--           17-JUL-1996  initial code

SET PAGESIZE 100

COLUMN tablespace_name HEADING "TABLESPACE NAME" FORMAT A25
COLUMN status          HEADING "STATUS"          FORMAT A10
COLUMN size            HEADING "SIZE (MB)"        FORMAT 99,999,990
COLUMN used            HEADING "USED (MB)"        FORMAT 99,999,990
COLUMN remaining       HEADING "REMAIN (MB)"      FORMAT 99,999,990
COLUMN pctused         HEADING "% USED"          FORMAT 990

SELECT t.tablespace_name, t.status,
       tsa.bytes / 1024 / 1024 AS "size",
       (tsa.bytes - DECODE(tsf.bytes, NULL, 0, tsf.bytes)) / 1024 /1024 AS used,
       DECODE(tsf.bytes, NULL, 0, tsf.bytes) / 1024 / 1024 AS remaining,
       (1 - DECODE(tsf.bytes, NULL, 0, tsf.bytes) / tsa.bytes) * 100 AS pctused
FROM dba_tablespaces t, sys.sm$ts_avail tsa, sys.sm$ts_free tsf
WHERE t.tablespace_name = tsa.tablespace_name AND
      t.tablespace_name = tsf.tablespace_name (+)
ORDER BY pctused desc
/

CLEAR COLUMNS
SET PAGESIZE 14
