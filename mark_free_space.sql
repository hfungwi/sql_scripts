set pagesize 100
col file_name for a50

select file_name, bytes/1024/1024 Mbytes,
         maxbytes/1024/1024 MaxMbytes, AUTOEXTENSIBLE
from dba_data_files
order by autoextensible, bytes, file_name;
