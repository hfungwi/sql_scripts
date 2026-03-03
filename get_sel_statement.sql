CREATE OR REPLACE FUNCTION get_sel_statement (
    tab_name_in IN VARCHAR2
) RETURN VARCHAR2
    AUTHID CURRENT_USER IS
    v_tab_name VARCHAR2(1000) := tab_name_in;
    v_sel_stmt VARCHAR2(32000);
BEGIN
    SELECT
        ' SELECT ' || LISTAGG(column_name, ', ') WITHIN GROUP (ORDER BY column_id) || ' FROM ' || table_name || ' ;'
   INTO
        v_sel_stmt
        all_tab_columns
    WHERE
        upper(table_name) = upper(v_tab_name)
    GROUP BY
        table_name;
    RETURN v_sel_stmt;
EXCEPTION
    WHEN no_data_found THEN
            RETURN NULL;
    WHEN OTHERS THEN
        RAISE;
END;
/
