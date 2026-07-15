------------------------------------------------------
-- name: sel_segs_at_hwm.sql
-- desc: display database objects at the absolute end of the datafile(s)
--       in a tablespace. (objects at the hwm)
-- date: 15th July 2026
------------------------------------------------------
SELECT * 
	FROM (    
		SELECT e.tablespace_name,
                       e.file_id,           
                       e.segment_name,
                       e.segment_type,           
                       e.block_id,           
                       e.blocks,                      
                       ROUND((e.block_id + e.blocks) * 8192 / 1024 / 1024, 2) AS end_position_mb    
                FROM   dba_extents e    
                WHERE  e.tablespace_name = '&tablespace_name'    
                ORDER BY e.block_id DESC
             )
WHERE rownum <= 10
/
