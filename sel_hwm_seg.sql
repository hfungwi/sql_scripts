-----------------------------------------------------
-- name: sel_hwm_seg.sql
-- author: Harris Fungwi
-- date: 02nd October 2026
------------------------------------------------------

col segment_name for a20
col segment_type for a20
col HWM for a20
set linesize 100

SELECT
       segment_name
      ,segment_type
      ,round(max(block_id+blocks)*8192/1024/1024) || ' mb' HWM
FROM
       dba_extents
WHERE
       segment_name = Upper('&segment_name')
GROUP BY
       segment_name
      ,segment_type
/
