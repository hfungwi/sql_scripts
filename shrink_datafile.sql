- SHRINK_DATAFILE.SQL

-- This script lists the object names and types that must be moved in order to resize a datafile to a specified smaller size

-- Input: FILE_ID from DBA_DATA_FILES or FILE# from V$DATAFILE
-- Size in bytes that the datafile will be resized to

SET SERVEROUTPUT ON

Prompt Displaying file_names and their ids
COL file_name for a40
SELECT
      file_id,
      substr(file_name, instr(file_name,'/',-1, 1),instr(file_name,'dbf')) file_name
FROM
      dba_data_files
/

PROMPT ENTER file_id
ACCEPT file_id

PROMPT ENTER target_size (in megabytes)
ACCEPT resize_file_to

DECLARE
     v_file_id     NUMBER;
     v_block_size  NUMBER;
     v_resize_size NUMBER;
BEGIN
     v_file_id := &file_id;
     v_resize_size := &resize_file_to;

     SELECT block_size
     INTO   v_block_size
     FROM   v$datafile
     WHERE FILE# = v_file_id;

     dbms_output.put_line('.');
     dbms_output.put_line('.');
     dbms_output.put_line('.');
     dbms_output.put_line('OBJECTS IN FILE '||v_file_id||' THAT MUST MOVE IN ORDER TO RESIZE THE FILE TO '||v_resize_size||' MEGABYTES');
     dbms_output.put_line('===================================================================');
     dbms_output.put_line('NON-PARTITIONED OBJECTS');
     dbms_output.put_line('===================================================================');

     for my_record in (
          SELECT distinct(owner||'.'||segment_name||' - OBJECT TYPE = '||segment_type) oname
          FROM dba_extents
          WHERE (block_id + blocks-1)*v_block_size / 1048576 > v_resize_size
          AND file_id = v_file_id
          AND segment_type NOT LIKE '%PARTITION%'
          ORDER BY 1) LOOP
               dbms_output.put_line(my_record.ONAME);
     END LOOP;

     dbms_output.put_line('===================================================================');
     dbms_output.put_line('PARTITIONED OBJECTS');
     dbms_output.put_line('===================================================================');

     for my_record in (
          SELECT distinct(owner||'.'||segment_name||' - PARTITION = '||partition_name||' - OBJECT TYPE = '||segment_type) oname
          FROM dba_extents
          WHERE (block_id + blocks-1)*v_block_size / 1048576 > v_resize_size
          AND file_id = v_file_id
          AND segment_type LIKE '%PARTITION%'
          ORDER BY 1) LOOP
               dbms_output.put_line(my_record.oname);
     END LOOP;

END;
/
