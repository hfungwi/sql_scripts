--------------------------------------------------------------
-- name : index_usage.sql
-- author : sqlmaria.com (Maria Colgen)
-- usage :  check how frequently indexes are being accessed
-- date : 14th Feb 2024
--------------------------------------------------------------------

REM script to check index usage for a particular index owner
REM run as system


PROMPT ENTER INDEX OWNER

define index_owner = &1

set linesize 140
set pagesize 80
col index_name for a30
SELECT i.index_name, u.total_access_count tot_access, u.total_exec_count exec_cnt,
       u.bucket_0_access_count B0, u.bucket_1_access_count B1, u.bucket_2_10_access_count B2_10,
       u.bucket_11_100_access_count B11_100, u.bucket_101_1000_access_count B101_1K,
       u.bucket_1000_plus_access_count B1K, u.last_used
FROM    DBA_INDEX_USAGE u
RIGHT JOIN DBA_INDEXES i
ON     i.index_name = u.name
WHERE  i.owner='&index_owner'
ORDER BY u.total_access_count desc;

-- ALTER INDEX prod_sub_idx INVISIBLE;
-- ALTER INDEX prod_sub_idx VISIBLE;
-- New indexes can be marked invisible until you have an opportunity to prove they improve performance
-- CREATE INDEX my_idx ON t(x, object_id) INVISIBLE;
-- Test newly created invisible indexes by setting OPTIMIZER_USE_INVISBLE_INDEXES to TRUE
-- ALTER SESSION SET optimizer_use_invisible_indexes  = TRUE;
