-------------
--To see amount of space in individual
--datafiles within a tablespace
-- Harris Fungwi
-- 3/11/2023
-----------------------------
set linesize 300
set pagesize 250
col file_name FOR a26
col tablespace_name FOR a23
col PCTFREE FOR a10
col PCTUSED FOR A10

prompt query to see amount of space in individual datafiles within a tablespace,
prompt for all files in the database.
prompt all sizes are in MB
prompt sum maxbytes in this query does not calulate correctly
prompt will be displayed later
prompt displaying output ...

exec dbms_lock.sleep(2);

SELECT    df.tablespace_name,
          substr(df.file_name,(instr(df.file_name, '/', '1', '4') +1)) file_name,
          round(df.bytes/1024/1024)                                    totalSizeMB,
          nvl(round(usedBytes/1024/1024), 0)                           usedMB,
          nvl(round(freeBytes/1024/1024), 0)                           freeMB,
          decode(round(df.MaxBytes/1024/1024), 0, df.bytes/1024/1024, round(df.MaxBytes/1024/1024))                         MaxMB,
          nvl(round(freeBytes/df.bytes * 100), 0) ||'%' AS            "PCTFREE",
          nvl(round(usedBytes/df.bytes * 100), 0) ||'%' AS            "PCTUSED",
          df.autoextensible                                            autoextend,
          1 AS sort_order
FROM      dba_data_files df
   LEFT JOIN (
               SELECT file_id, sum(bytes) usedBytes
               FROM dba_extents
               GROUP BY file_id
              ) ext
   ON df.file_id = ext.file_id
   LEFT JOIN (
                SELECT file_id, sum(bytes) freeBytes
                FROM dba_free_space
                GROUP BY file_id
              ) free
   ON df.file_id = free.file_id
UNION ALL
SELECT    'TOTAL' AS tablespace_name,
          NULL AS file_name,
          round(sum(df.bytes)/1024/1024)                                totalSizeMB,
          nvl(round(sum(usedBytes)/1024/1024), 0)                       usedMB,
          nvl(round(sum(freeBytes)/1024/1024), 0)                       freeMB,
          decode(round(sum(df.MaxBytes)/1024/1024), 0, sum(df.bytes)/1024/1024, sum(df.MaxBytes)/1024/1024)                    MaxMB,
          NULL AS "PCTFREE",
          NULL AS "PCTUSED",
          NULL AS autoextend,
          2 AS sort_order
FROM      dba_data_files df
   LEFT JOIN (
               SELECT file_id, sum(bytes) usedBytes
               FROM dba_extents
               GROUP BY file_id
              ) ext
   ON df.file_id = ext.file_id
   LEFT JOIN (
                SELECT file_id, sum(bytes) freeBytes
                FROM dba_free_space
                GROUP BY file_id
              ) free
   ON df.file_id = free.file_id
ORDER BY sort_order, tablespace_name, file_name
/

prompt the displaying max size database can grow to ...

exec dbms_lock.sleep(2);

WITH df_used_space AS (SELECT    df.tablespace_name,
          substr(df.file_name,(instr(df.file_name, '/', '1', '4') +1)) file_name,
          round(df.bytes/1024/1024)                                    totalSizeMB,
          nvl(round(usedBytes/1024/1024), 0)                           usedMB,
          nvl(round(freeBytes/1024/1024), 0)                           freeMB,
          decode(round(df.MaxBytes/1024/1024), 0, df.bytes/1024/1024, round(df.MaxBytes/1024/1024))                         MaxMB,
          nvl(round(freeBytes/df.bytes * 100), 0) ||'%' AS            "PCTFREE",
          nvl(round(usedBytes/df.bytes * 100), 0) ||'%' AS            "PCTUSED",
          df.autoextensible                                            autoextend,
          1 AS sort_order
FROM      dba_data_files df
   LEFT JOIN (
               SELECT file_id, sum(bytes) usedBytes
               FROM dba_extents
               GROUP BY file_id
              ) ext
   ON df.file_id = ext.file_id
   LEFT JOIN (
                SELECT file_id, sum(bytes) freeBytes
                FROM dba_free_space
                GROUP BY file_id
              ) free
   ON df.file_id = free.file_id
)
SELECT sum(MaxMB) sum_of_maxbytes FROM df_used_space
/
