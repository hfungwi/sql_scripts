------------------------------------------------------------------------
-- NAME   : jl_star_dml.sql
-- AUTHOR : Harris Fungwi
-- DATE   : 07th April 2026
-- DESC   : used for populating the justlee star schema tables
--          Demonstration, for practice purposes only
--          Logically the star schema desgin is not perfect, however the 
--          pl/sql program structure for generating the data is ideal  
------------------------------------------------------------------------

SET ECHO ON
SET SERVEROUTPUT ON SIZE UNLIMITED
DECLARE
    v_start_time TIMESTAMP;
    v_end_time   TIMESTAMP;
    v_diff       INTERVAL DAY TO SECOND;
-- customers array
    v_rowcount      NUMBER;
    TYPE dim_customer_rec IS RECORD (
            customer# NUMBER,
            firstname VARCHAR2(25 CHAR),
            lastname  VARCHAR2(25 CHAR),
            full_name VARCHAR2(50 CHAR)
    );
    TYPE dim_customer_array IS TABLE OF dim_customer_rec INDEX BY PLS_INTEGER;
    cust_values     dim_customer_array;
-- book_array
    TYPE dim_books_rec IS RECORD (
            book_id   NUMBER,
            isbn      VARCHAR2(10 CHAR),
            title     VARCHAR2(40 CHAR),
            publisher VARCHAR2(30 CHAR),
            price     NUMBER,
            pubdate   DATE
    );
    TYPE dim_books_array IS TABLE OF dim_books_rec INDEX BY PLS_INTEGER;
    book_values     dim_books_array;
-- authors_array
    TYPE dim_author_rec IS RECORD (
            author_id  VARCHAR2(32 CHAR),
            first_name VARCHAR2(25 CHAR),
            last_name  VARCHAR2(25 CHAR),
            full_name  VARCHAR2(50 CHAR)
    );
    TYPE dim_author_array IS TABLE OF dim_author_rec INDEX BY PLS_INTEGER;
    author_values   dim_author_array;
-- time_array
    TYPE dim_time_rec IS RECORD (
            orderdate   DATE,
            year        NUMBER,
            month       VARCHAR2(25 CHAR),
            day         NUMBER,
            day_of_week VARCHAR2(10 CHAR),
            quarter     VARCHAR2(25 CHAR)
    );
    TYPE dim_time_array IS TABLE OF dim_time_rec INDEX BY PLS_INTEGER;
    time_values     dim_time_array;
-- location_array
    TYPE dim_location_rec IS RECORD (
            location_id NUMBER,
            address     VARCHAR2(100 CHAR),
            city        VARCHAR2(50 CHAR),
            state       VARCHAR2(50 CHAR),
            postal_code VARCHAR2(20 CHAR)
    );
    TYPE dim_location_array IS     TABLE OF dim_location_rec INDEX BY PLS_INTEGER;
    location_values dim_location_array;
-- fact_sales_array
    TYPE fact_sales_rec IS RECORD (
            sales_id      NUMBER,
            order_id      NUMBER,
            customer_id   NUMBER,
            book_id       NUMBER,
            author_id     VARCHAR2(32 CHAR),
            time_id       NUMBER,
            location_id   NUMBER,
            quantity      NUMBER,
            sales_amount  NUMBER,
            shipping_cost NUMBER
    );
    TYPE fact_sales_array IS TABLE OF fact_sales_rec INDEX BY PLS_INTEGER;
    sales_values    fact_sales_array;
BEGIN
-- record start_time
        v_start_time := SYSTIMESTAMP;
        dbms_output.put_line('Start time: ' || to_char(v_start_time, 'YYYY-MM-DD HH24:MI:SS.FF3'));
--DIM_CUSTOMER
    BEGIN
        dbms_output.put_line(' processing... DIM_CUSTOMER Table ');
        SELECT
            customer#,
            firstname,
            lastname,
            firstname
            || ' '
            || lastname AS "FULL_NAME"
        BULK COLLECT
        INTO cust_values
        FROM
            customers;

        FORALL i IN 1..cust_values.count
            INSERT INTO dim_customer VALUES cust_values ( i );

        v_rowcount := SQL%rowcount;
        dbms_output.put_line(' Inserted '
                             || v_rowcount
                             || ' rows into dim_customer ');
        dbms_output.put_line(' ============================ ');
    END;
--DIM_BOOK
    dbms_output.put_line(' processing... DIM_BOOK TABLE ');
    BEGIN
        SELECT
            dw_book_seq.NEXTVAL,
            b.isbn,
            b.title,
            p.name,
            b.retail,
            b.pubdate
        BULK COLLECT
        INTO book_values
        FROM
                 books b
            JOIN publisher p ON b.pubid = p.pubid;

        FORALL i IN 1..book_values.count
            INSERT INTO dim_book VALUES book_values ( i );

        v_rowcount := SQL%rowcount;
        dbms_output.put_line(' Inserted '
                             || v_rowcount
                             || ' rows into DIM_BOOKS ');
        dbms_output.put_line(' ============================ ');
    END;

--DIM_AUTHOR
    dbms_output.put_line(' processing... DIM_AUTHOR TABLE ');
    BEGIN
        WITH bookauthor_t AS (
            SELECT
                isbn,
                decode(COUNT(authorid),
                       '1',
                       LISTAGG(authorid),
                       LISTAGG(authorid)
                ) authorid
            FROM
                     bookauthor
                NATURAL JOIN author
            GROUP BY
                isbn
        )
        SELECT DISTINCT
            b.authorid,
            decode(a.fname, NULL, 'N/A', a.fname) fname,
            decode(a.lname, NULL, 'N/A', a.lname) lname,
            CASE
                WHEN a.fname IS NULL THEN
                    'MULTIPLE AUTHORS'
                ELSE
                    a.fname
                    || ' '
                    || a.lname
            END                                   AS "FULL_NAME"
        BULK COLLECT
        INTO author_values
        FROM
            bookauthor_t b
            LEFT OUTER JOIN author       a ON b.authorid = a.authorid;

        FORALL i IN 1..author_values.count
            INSERT INTO dim_author VALUES author_values ( i );

        v_rowcount := SQL%rowcount;
        dbms_output.put_line(' Inserted '
                             || v_rowcount
                             || ' rows into DIM_AUTHOR ');
        dbms_output.put_line(' ============================ ');
    END;
--DIM_TIME
    dbms_output.put_line(' processing... DIM_TIME TABLE ');
    BEGIN
        SELECT DISTINCT
            orderdate,
            to_char(orderdate, 'YYYY') year,
            to_char(orderdate, 'MON')  month,
            to_char(orderdate, 'D')    day,
            to_char(orderdate, 'DAY')  day_of_week,
            CASE
                WHEN to_char(orderdate, 'MM') IN ( '01', '02', '03' ) THEN
                    'First Quarter'
                WHEN to_char(orderdate, 'MM') IN ( '04', '05', '06' ) THEN
                    'Second Quarter'
                WHEN to_char(orderdate, 'MM') IN ( '07', '08', '09' ) THEN
                    'Third Quarter'
                WHEN to_char(orderdate, 'MM') IN ( '10', '11', '12' ) THEN
                    'Fourth Quarter'
                ELSE
                    'Fifth Quarter'
            END                        AS quarter
        BULK COLLECT
        INTO time_values
        FROM
            orders;

        FORALL i IN 1..time_values.count
            INSERT INTO dim_time VALUES (
                dw_time_seq.NEXTVAL,
                time_values(i).orderdate,
                time_values(i).year,
                time_values(i).month,
                time_values(i).day,
                time_values(i).day_of_week,
                time_values(i).quarter
            );

        v_rowcount := SQL%rowcount;
        dbms_output.put_line('Inserted '
                             || v_rowcount
                             || ' rows into DIM_TIME ');
        dbms_output.put_line(' ============================ ');
    END;
--DIM_LOCATION
    dbms_output.put_line(' processing... DIM_LOCATION TABLE ');
    BEGIN
        SELECT
            dw_location_seq.NEXTVAL,
            address,
            city,
            state,
            zip
        BULK COLLECT
        INTO location_values
        FROM
            customers;

        FORALL i IN 1..location_values.count
            INSERT INTO dim_location VALUES location_values ( i );

        v_rowcount := SQL%rowcount;
        dbms_output.put_line(' Inserted '
                             || v_rowcount
                             || ' rows into DIM_LOCATION');
        dbms_output.put_line(' ============================ ');
    END;
--FACT_SALES
    dbms_output.put_line(' processing... FACT_SALES TABLE ');
    BEGIN
        WITH bookauthor_t AS (
            SELECT
                isbn,
                decode(COUNT(authorid),
                       '1',
                       LISTAGG(authorid),
                       LISTAGG(authorid)
                ) authorid
            FROM
                     bookauthor
                NATURAL JOIN author
            GROUP BY
                isbn
        ), temp_paid AS (
            SELECT
                order#,
                ( SUM(paideach) + nvl(SUM(shipcost),
                                      0) ) total_paid
            FROM
                     orderitems
                NATURAL JOIN orders
            GROUP BY
                order#
            ORDER BY
                1
        )
        SELECT
            dw_fact_seq.NEXTVAL,
            o.order#,
            c.customer_id,
            b.book_id,
            a.authorid,
            t.time_id,
            l.location_id,
            oi.quantity,
            ts.total_paid,
            o.shipcost
        BULK COLLECT
        INTO sales_values
        FROM
            orders       o
            LEFT OUTER JOIN dim_customer c ON o.customer# = c.customer_id
            LEFT OUTER JOIN orderitems   oi ON o.order# = oi.order#
            LEFT OUTER JOIN temp_paid    ts ON o.order# = ts.order#
            LEFT OUTER JOIN customers ON c.customer_id = customers.customer#
            LEFT OUTER JOIN dim_location l ON l.address = customers.address
            LEFT OUTER JOIN dim_time     t ON t.order_date = o.orderdate
            LEFT OUTER JOIN dim_book     b ON b.isbn = oi.isbn
            LEFT OUTER JOIN bookauthor_t a ON a.isbn = b.isbn;

        FORALL i IN 1..sales_values.count
            INSERT INTO fact_sales VALUES sales_values ( i );

        v_rowcount := SQL%rowcount;
        dbms_output.put_line(' Inserted '
                             || v_rowcount
                             || ' rows into FACT_SALES');
        dbms_output.put_line(' ============================ ');
    END;
-- record end_time and elapsed time
        v_end_time := SYSTIMESTAMP;
        dbms_output.put_line('End time: ' || to_char(v_end_time, 'YYYY-MM-DD HH24:MI:SS.FF3'));
        v_diff := v_end_time-v_start_time;
    dbms_output.put_line('Elapsed time: '
        ||        EXTRACT(DAY    FROM v_diff) || ' days '
        ||        EXTRACT(HOUR   FROM v_diff) || ' hours '
        ||        EXTRACT(MINUTE FROM v_diff) || ' minutes '
        || ROUND( EXTRACT(SECOND FROM v_diff), 3) || ' seconds');
EXCEPTION
    WHEN OTHERS THEN
        dbms_output.put_line(' errors: ' || sqlerrm);
        ROLLBACK;
END;
/
COMMIT ;
