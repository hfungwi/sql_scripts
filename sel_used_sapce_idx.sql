-- display used space in an index 

select
        index_name,
        leaf_blocks,
        (leaf_blocks * 8192)/1024/1024 as approx_mb_leaf
from
        user_indexes
where
      index_name = upper('&index_name')
/
