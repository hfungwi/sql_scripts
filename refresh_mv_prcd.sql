------------------------------------------------------------------------
--    refresh test_MV Materialized view
--    Author:  Harris Fungwi        Apr 09, 2025
------------------------------------------------------------------------

DEFINE prcd_name='REFRESH_TEST_MV'

PROMPT Processing ... &prcd_name
CREATE OR REPLACE PROCEDURE &prcd_name AS

 PRAGMA AUTONOMOUS_TRANSACTION ;
    v_mview_name VARCHAR2(32) := 'TEST_MV';
--
    CURSOR test_indexes_cur IS
    SELECT
        index_name
    FROM
        user_indexes
    WHERE
        table_name = v_mview_name;

BEGIN
-- refresh materialized_view
    dbms_mview.refresh(v_mview_name);
-- shrink segments
    EXECUTE IMMEDIATE ' ALTER TABLE '
                      || v_mview_name
                      || ' ENABLE ROW MOVEMENT ';
    EXECUTE IMMEDIATE ' ALTER TABLE '
                      || v_mview_name
                      || ' SHRINK SPACE ';
    EXECUTE IMMEDIATE ' ALTER TABLE '
                      || v_mview_name
                      || ' DISABLE ROW MOVEMENT';
-- rebuild indexes
    FOR i IN flow_indexes_cur LOOP
        EXECUTE IMMEDIATE ' ALTER INDEX '
                          || i.index_name
                          || ' REBUILD ';
    END LOOP;
    dbms_output.put_line('refresh completed successfully');
EXCEPTION
    WHEN OTHERS THEN
        dbms_output.put_line('mview refresh errors: ' || sqlerrm);
END &prcd_name;
/
