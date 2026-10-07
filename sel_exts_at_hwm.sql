------------------------------------------------------
-- name: sel_exts_at_hwm.sql
-- desc: display database objects at the absolute end of the datafile(s)
--       in a tablespace.
-- date: 15th July 2026
------------------------------------------------------
set linesize 150
col segment_name for a20
col tablespace_name for a20
set pagesize 100
    
SELECT *
    FROM (
            SELECT
                         e.extent_id,
                         e.tablespace_name,
                         e.file_id,
                         e.segment_name,
                         e.segment_type,
                         e.block_id,
                         e.blocks,
                         ROUND((e.block_id + e.blocks) * 8192 / 1024 / 1024, 2) AS end_position_mb
                  FROM   dba_extents e
                  WHERE  e.tablespace_name = '&tablespace_name'
                  AND    e.segment_name = '&segment_name'
                  ORDER BY e.block_id DESC
               )
WHERE rownum <= 40
/
