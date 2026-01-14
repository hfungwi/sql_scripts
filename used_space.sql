--------------------------------
--USAGE : Check space occupied by objects in a tablespace
--AUTHOR: Harris Fungwi
--DATE:   27/10/2023
--CALLING SYNTAX: @used_space
------------------------------------


set linesize 150
set pagesize 100
col file_name for a50

select tablespace_name, sum(bytes)/1024/1024 MB_USED
from dba_segments
group by tablespace_name
order by sum(bytes) desc
/
