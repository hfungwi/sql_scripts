-- -----------------------------------------------------------------------------------
-- Description  : Predicts how changes to the PGA_AGGREGATE_TARGET will affect PGA usage.
-- Requirements : Access to the V$ views.
-- -----------------------------------------------------------------------------------

SELECT ROUND(pga_target_for_estimate/1024/1024) target_mb,
       estd_pga_cache_hit_percentage cache_hit_perc,
       estd_overalloc_count
FROM   v$pga_target_advice;
