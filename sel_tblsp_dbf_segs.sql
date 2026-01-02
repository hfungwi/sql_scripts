WITH
 total_space as ( SELECT
                              tablespace_name,
                              round(sum(greatest(bytes, decode(maxbytes, 0, bytes, maxbytes))/1024/1024)) total_space_mb
                        FROM   dba_data_files
                        GROUP BY tablespace_name
                      ),
  used_space as ( SELECT
                         tablespace_name,
                         round(sum(bytes/1024/1024)) used_space_mb
                  FROM   dba_segments
                  GROUP BY tablespace_name
                )
  SELECT t.tablespace_name, t.total_space_mb, u.used_space_mb
  FROM          total_space t
     INNER JOIN used_space u  ON t.tablespace_name = u.tablespace_name
  ORDER BY t.tablespace_name
/
