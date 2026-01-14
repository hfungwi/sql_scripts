col tablespace for a20
select   round(max(block_id+blocks)*8192/1024/1024) || ' mb' HWM
from dba_extents
where tablespace_name = Upper('&TABLESPACE_NAME')
group by tablespace_name
/
