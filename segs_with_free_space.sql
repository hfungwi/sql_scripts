-----------------------------------------------------
-- script_name : segs_with_free_space.sql
-- source      : https://www.dbi-services.com/blog/how-much-free-space-can-be-reclaimed-from-a-segment/
-- modified by : Harris Fungwi
-- date        : 8th July 2026
-- Description : uses a function to compute the free space within a segment.
--               it then computes the difference segment total space and segment free space as used_space
--               displays the top 10 segments with free space within them throughout the database
--               basically, it shows the total space allocated to that segment, the total space actually
--               used by that segment, and the free space that could possibly be reclaimed.
--               space in a table can be reclaimed by using a move or shrink operation
--               space in an index can be reclaimed by rebuilding the index
-------------------------------------------------------
SET LINESIZE 180
COL owner for a20
col segment_name for a35
col segment_type for a20
WITH
    FUNCTION freebytes (
        segment_owner  VARCHAR2,
        segment_name   VARCHAR2,
        segment_type   VARCHAR2,
        partition_name VARCHAR2
    ) RETURN NUMBER AS
        unf   NUMBER;
        unfb  NUMBER;
        fs1   NUMBER;
        fs1b  NUMBER;
        fs2   NUMBER;
        fs2b  NUMBER;
        fs3   NUMBER;
        fs3b  NUMBER;
        fs4   NUMBER;
        fs4b  NUMBER;
        full  NUMBER;
        fullb NUMBER;
    BEGIN
        dbms_space.space_usage(segment_owner, segment_name, segment_type, unf, unfb,
                               fs1, fs1b, fs2, fs2b, fs3,
                               fs3b, fs4, fs4b, full, fullb,
                               partition_name => partition_name);
        RETURN unfb + fs1b + fs2b * 0.25 + fs3b * 0.5 + fs4b * 0.75;
    END;
SELECT
    owner,
    segment_name,
    segment_type,
    bytes/1024/1024 mbytes_allocated,
    (bytes/1024/1024) - ( round(freebytes(owner, segment_name, segment_type, partition_name) / 1024 / 1024, 3)) mbytes_used,
    round(freebytes(owner, segment_name, segment_type, partition_name) / 1024 / 1024, 3) free_mb
FROM
    dba_segments
WHERE
        segment_subtype = 'ASSM'
    AND segment_type IN ( 'TABLE', 'TABLE PARTITION', 'TABLE SUBPARTITION', 'CLUSTER', 'LOB',
                          'LOB PARTITION', 'LOB SUBPARTITION' )
ORDER BY free_mb DESC
FETCH FIRST 10 ROWS ONLY
/
SET LINESIZE 80
