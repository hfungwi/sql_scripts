-
-- name   : sel_hist_sess_sql.sql
-- author : Harris Fungwi
-- date   : 12-JUN-2025
-- desc   : Displays details about a specified user's historical session and
--           the query they ran. prompts for "username" required argument is
--           a valid oracle user account
--
--   changes :
--

SET LINESIZE 2000
SET LONG 10000
SET TRIMSPOOL ON

col sql_text    for a80
col sample_time for a30
col username    for a28

SELECT
      v_hist.session_id      sid,
      v_hist.session_serial# serial#,
      d_users.username,
      d_sql.sql_id,
      v_hist.sample_time,
      dbms_lob.substr(d_sql.sql_text,4000,1)    sql_text
   --,dbms_lob.substr(d_sql.sql_text,4000,4001) sql_text_2
   --,dbms_lob.substr(d_sql.sql_text,4000,8001) sql_text_3
FROM
                dba_hist_active_sess_history v_hist
   LEFT  JOIN   dba_hist_sqltext             d_sql   ON  v_hist.sql_id   = d_sql.sql_id
   INNER JOIN   dba_users                    d_users ON  v_hist.user_id  = d_users.user_id
WHERE
            d_users.username LIKE upper('%&username%')
ORDER BY
        v_hist.sample_time
/
