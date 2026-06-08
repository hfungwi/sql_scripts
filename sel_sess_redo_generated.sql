select  se.sid,
        se.username,
        se.program,
        s.name,
        round(st.value/1024/1024,2) value_in_mb
from
        v$statname s,
        v$sesstat st,
        v$session se
where
        st.STATISTIC# = s.STATISTIC#
 and    s.name = 'redo size'
 and    st.sid = se.sid
order by st.value DESC
FETCH FIRST 20 ROWS ONLY ;
