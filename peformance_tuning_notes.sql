--THE FOLLOWING ARE THE STEPS TO TUNE A SQL
-----------------------------------------

-- 1) KNOW WHAT SQL YOU WANT TO TUNE
	--------------------

--You can find this from the v$sqlstat view using the
--following...

select * from (SELECT upper(sql_id), executions,
 ROUND (elapsed_time/1000000, 2) total_time,
 ROUND (cpu_time/1000000, 2) cpu_seconds
 FROM (SELECT * FROM V$SQLSTATS
 ORDER BY elapsed_time desc))
where rownum <=10 ;

-- The above query ranks the transactions by the total number of elapsed seconds. 
-- You can also rank the statements according to CPU seconds used.
-- Once you have the value for the HASH_VALUE column from the query you just ran, 
-- it's a simple matter to find out the execution plan for this statement, 
-- which is in your library cache. The following query uses the V$SQL_PLAN view to get you 
-- the execution plan for your longest-running SQL statements:

 select sql_id from v$session where sid = 295
-- to see actual sql causing error
 @$ORACLE_HOME/rdbms/admin/sqltrpt.sql			

--INPUT THE SQL_ID




-- 2) Once you have the sql_id of the expensive sqls, you can use the following 

--PL/SQL procedure to create a tuning task.
	--------------------------
-----------------------------------------------------------------------------------------------
DECLARE
sql_tune_task_id VARCHAR2(100);
BEGIN
sql_tune_task_id := DBMS_SQLTUNE.create_tuning_task (
sql_id => '&&sql_id',
scope => DBMS_SQLTUNE.scope_comprehensive,
time_limit => 500,
task_name => '&&task_name',
description => 'Tuning task1 for statement &sql_id');
DBMS_OUTPUT.put_line('sql_tune_task_id: ' || sql_tune_task_id);
END;
/


---------------------- or if you know the sql text,---------------------------------------- 

DECLARE
sql_tune_task_id VARCHAR2(100);
BEGIN
sql_tune_task_id := DBMS_SQLTUNE.create_tuning_task (
sql_text => ' <type text here>',
scope => DBMS_SQLTUNE.scope_comprehensive,
time_limit => 500,
task_name => '&&task_name',
description => 'Tuning task1 for statement');
DBMS_OUTPUT.put_line('sql_tune_task_id: ' || sql_tune_task_id);
END;
/
---------------------------------------------------------------------------------------------

-- ENTER SQL_ID (or text), TASK_NAME(MUST BE A WORD CANT START WITH A #), ENTER SQL_ID AGAIN



-- 3) Execute the tuning task
	------------

EXEC DBMS_SQLTUNE.execute_tuning_task(task_name => '&task_name');

-- 4) Get the tuning task results and recommendations.
	-----------------------------
set long 65536
set longchunksize 65536
set linesize 100
select dbms_sqltune.report_tuning_task('&task_name') from dual;



--We can get the list of tuning tasks present in database from DBA_ADVISOR_LOG

SELECT TASK_NAME, STATUS FROM DBA_ADVISOR_LOG 
WHERE TASK_NAME = '&task_name';

--Drop a tuning task:
execute dbms_sqltune.drop_tuning_task('&task_name');
 

-- 5)GET BLOCKING SESSIONS
	--------
set linesize 200
col objects for a30
col osuser for a20

SELECT blocking_session, sid, serial#, wait_class, seconds_in_wait, state, sql_id
FROM v$session 
WHERE
  (blocking_session is not null OR
  (wait_class = 'Application' AND seconds_in_wait > 0)) AND
  type != 'BACKGROUND'
ORDER BY
  blocking_session;


--- 5b)) GET LOCKS - Note that this query filters for locks on objects owned by any of the cams users
	--------
set linesize 200
col objects for a30
col osuser for a20
col username for a20
col machine for a20
col program for a30


SELECT
    l.sid,
    s.serial#,
    s.username,
    s.osuser,
    s.machine,
    s.program,
    s.seconds_in_wait,
    l.type,
    l.lmode,
    l.id1,
    o.owner || '.' || o.object_name objects
FROM
         v$lock l
    JOIN v$session   s ON l.sid = s.sid
    LEFT JOIN all_objects o ON l.id1 = o.object_id
WHERE s.type <> 'BACKGROUND'
AND o.owner || '.' || o.object_name <> 'SYS.ORA$BASE'
AND   o.owner LIKE '%&username%'
ORDER BY s.seconds_in_wait DESC
/





-- 6) GET_IDLE_SESSION
	--------

set linesize 200
col osuser for a15
col program for a20
SELECT s.sid, s.serial#, s.sql_hash_value, s.username, s.osuser, s.machine,
 s.program, s.status, s.last_call_et/60 "Minutes idle"
FROM v$session s
WHERE s.status = 'INACTIVE'
AND s.last_call_et/60 > 50
ORDER BY s.last_call_et/60 ASC;
-- GETS LONGEST IDLE TIME AT BOTTOM


SELECT * FROM (SELECT s.sid, s.serial#, s.sql_hash_value, s.username, s.osuser, s.last_call_et/60 "Minutes idle"
FROM v$session s
WHERE s.status = 'INACTIVE'
AND s.last_call_et/60 > 10
order by s.last_call_et/60 DESC)
WHERE ROWNUM <=50;

-- GETS LONGEST IDLE TIME AT TOP

-- 50 is time in minutes and should be replaced with that...


-- [to kill use] ALTER SYSTEM KILL SESSION '<sid>,<serial#>' immediate;
-- [or] Alter SYSTEM DISCONNECT SESSION 'sid,serial#' immediate;
-- [to cancel the sql] ALTER SYSTEM CANCEL SQL 'SID,SERIAL#';


-- 7) GET TOP WAIT EVENTS
	-----------

SELECT * FROM (SELECT NVL(s.username,'(oracle)') as username,s.sid,s.serial#,sw.event,sw.wait_time, sw.seconds_in_wait, sw.state FROM v$session_wait sw,v$session s
WHERE s.sid=sw.sid and s.username = '&username' ORDER BY sw.seconds_in_wait DESC)
WHERE ROWNUM <= 15;

-- TOP WAITING SESSIONS DISPLAYED AT TOP

-- 8) GETTING STALE STATISTICS
	--------
-- for table
 select stale_stats, owner, table_name from dba_tab_statistics
 where upper(table_name) like upper('%&table_name%')
 and stale_stats like 'Y%';

--for schema
 select stale_stats, owner, table_name from dba_tab_statistics
 where upper(owner) like upper('%&owner%')
 and stale_stats like 'Y%';



---- It's also your responsibility to collect system statistics as the server will not
---- do so for you, use the below
EXECUTE dbms_stats.gather_system_stats('start');
EXECUTE dbms_stats.gather_system_stats('stop');
SELECT * FROM sys.aux_stats$;


--QUERYING STATISTICS ON COLUMNS IN A TABLE

SELECT column_name, num_distinct
FROM  dba_tab_col_statistics
WHERE table_name='&TABLE_NAME';

---TO FIX,

exec dbms_stats.gather_table_stats ('Schema_name', 'Table_name'); 
EXEC DBMS_STATS.gather_schema_stats('SCHEMA_NAME', estimate_percent => 25, cascade => TRUE);

--SCHEDULING A JOB TO DO THAT!!!
--------------

SET SERVEROUTPUT ON

DECLARE
DB_STATS NUMBER;
BEGIN
SELECT MAX (job) + 1 INTO DB_STATS FROM dba_jobs;
DBMS_JOB.submit(DB_STATS,
'BEGIN DBMS_STATS.gather_schema_stats(''&SCHEMA_NAME'',estimate_percent => dbms_stats.auto_sample_size, degree=>32 ); END;',
trunc(next_day(SYSDATE,'SUNDAY'))+11/24,
'TRUNC (SYSDATE+7)+11/24');
COMMIT;
DBMS_OUTPUT.put_line('Job: ' || DB_STATS);
END;
/
-----------------------------------------------------------------------------------

OR
EXEC DBMS_STATS.gather_database_stats;
OR
DBMS_STATS.gather_schema_stats ('MEHMET', estimate_percent => 25, cascade => TRUE);



--------------------------------------------------------------------------------------

9) SEE IF STATS ARE BEING GATHERED AS THEY SHOULD BE

SELECT last_analyzed, table_name, owner, num_rows, sample_size
FROM dba_tables
ORDER by last_analyzed

--shows last time a table was analyzed
select to_char(max(last_analyzed), 'YYYY-MM-DD HH24:MI:SS') last_analyzed from dba_tables;


10) SEE TEMP SPACE USAGE

SELECT    S.sid || ',' || S.serial# sid_serial, S.username, S.osuser, P.spid, S.module,
              P.program, SUM (T.blocks) * TBS.block_size / 1024 / 1024 mb_used, T.tablespace,
              COUNT(*) statements
     FROM     v$sort_usage T, v$session S, dba_tablespaces TBS, v$process P
     WHERE    T.session_addr = S.saddr
     AND      S.paddr = P.addr
     AND      T.tablespace = TBS.tablespace_name
     GROUP BY S.sid, S.serial#, S.username, S.osuser, P.spid, S.module,
              P.program, TBS.block_size, T.tablespace
   ORDER BY sid_serial;


--Other things to do include;
--runnning the addm
--monitor server resources...


--PARAMETERS AFFECTING PEFORMANCE

---PARALELL QUERY

-parallel_min_servers*
-parallel_max_servers*
-parallel servers_target
-parallel_degree_policy

--turn parallel query off by setting the * above to 0 this help solved cams peformance issues in the past

---COST BASED OPTIMIZER
--optimizer_mode - set to ALL_ROWS for optimal peformance of online and ad_hoc reports
-




--FROM CONNOR MCDONALD
   1)see the execution plans
         SELECT /*+ GATHER_PLAN_STATISTICS */ count(*) from ( select first_name
         || ' ' || last_name ename, salary*12, department_name from employees,
	departments where employees.department_id = departments.department_id
	and department_name = 'Sales' order by 2)

	select * from (dbms_xplan.display_cursor(format=>'ALLSTATS LAST'));
or 

--YOU CAN ALSO SET AUTOTRACE ON TO SEE THE PLANS FOR A NON_PRIVILEGED USER
--RECOMMENDED TO DO SO AS TO GET ALL EXECUTIONS PLAN AT BOTTOM use steps
--   1) login as the account to run said query
--    2) SET LINESIZE 200
--    3) RUN @$ORACLE_HOME/RDBMS/ADMIN/UTLXPLAN.SQL
--    4) CONNECT AS SYSDBA
--    5) run @$ORACLE_HOME/SQLPLUS/ADMIN/PLUSTRCE.SQL
--    6) AS SYS, GRANT PLUSTRACE TO <username> ;
--    7) CONNECT AS USER TO RUN QUERY
--    8)  SET LINESIZE 200
--    9)  run the query and take note of plan (copy plan to a notepad, take note of row
--         "TABLE ACCESS BY INDEX ROWID" specifficlally the rows column how many are displayed
-- optional ;
--  10) change user password, grant dba to user, run query and do 
           select * from (dbms_xplan.display_cursor(format=>'ALLSTATS LAST'));
           compare e rows and a rows


-- you can try to improve this query by
--   a) gather stats
--   b) gather extended stats
--   c) rewrite query
--   d) check for missing histograms
       -- eliminate functions applied on primary key columns in where clause
       -- possibly adding indexes and/or function based indexes
       -- replacing >=, <=, >, < with the between clause
       -- replacing union with union all if uniqueness is already ensured in result set
       -- other tuning rules
--   e) some queries are to complex they cannot be optimized based on precalculated tasks
--   f) running the sql tuning advisor and accepting the recommendations

--WHEN ALLL ESLE FAILS TURN TO DYNAMIC SAMPLING

--go to alternate version;
--   THE GAME CHANGER
 ----------------  
ALTER SESSION SET optimizer_dynamic_sampling=4;
ALTER SESSION SET optimizer_dynamic_sampling=11;

--eg from sys

--get sql_id 
SELECT sql_id
FROM v$sql
WHERE plan_hash_value = 2178791499

--set baseline
declare
  n pls_integer;
begin
   n := dbms_spm.load_plans_from_cursor_cache(sql_id => 'azwbcpyqfxgw1');
end;
/

--confirm it was accepted

col sql_text for a50
col plan_name for a40
col accepted for a20
col sql_handle for a30
set linesize 20

select sql_handle, plan_name, sql_text, accepted
from dba_sql_plan_baselines;


--to drop baseline
declare
  n pls_integer;
begin
   n := dbms_spm.drop_sql_plan_baseline(plan_name => 'SQL_PLAN_ap8rjh63yb7gz636d145e');
end;
/

-- SQL_PLAN_ap8rjh63yb7gz1997805c
-- SQL_PLAN_ap8rjh63yb7gz636d145e

---remember to turn down dynamic sampling for the usersession 
ALTER SESSION SET optimizer_dynamic_sampling=2;




-- recommendation from connor is to crank dynamic sampling up to 11, and then when you get a good plan you can lock it in using spm(sql plan management)
-- Dynamic sampling is not useful or advised for run once queries i.e queries that will not be run repeatedly against the database
-- make sure to revoke dba from the user and change password back so that developpers can use the account
-- don't leave DS on at 11 because it consumes a lot of resources(cpu) pay the price once, get a good plan and store said  plan to be re-run multiple times

--11)
-- command to show you how often stats are gathered

SELECT last_analyzed, table_name, owner, num_rows, sample_size
FROM dba_tables
ORDER by last_analyzed


--12)
---- The following formula provides you with the library cache hit ratio:
 SELECT SUM(pinhits)/sum(pins) Library_cache_hit_ratio
from v$librarycache;


----- Determining the Efficiency of the Library Cache
SELECT namespace, pins, pinhits, reloads
FROM V$LIBRARYCACHE
order by namespace;
-- creating a bind variable 

--SQL> VARIABLE bindvar NUMBER;
--SQL> BEGIN
-- 2   :bindvar :=7900;
-- 3   END;
-- 4   /
--
SELECT ename FROM scott.emp WHERE empid = :bindvar;

--This cuts hard parsing (and high latch activity) and the attendant CPU usage drastically, 
--and dramatically reduces the time taken to retrieve data. For example, all the following 
--statements can use the parsed version of the query that uses the bind variable:

SELECT ename FROM scott.emp WHERE empid = 7499;
SELECT ename FROM scott.emp WHERE empid = 7788;
SELECT ename FROM scott.emp WHERE empid = 7902;
--Unfortunately, in too many applications, literal values rather than bind values are used.
-- You can alleviate this problem to some extent by setting up the following initialization 
--parameter:
--CURSOR_SHARING=FORCE
--CURSOR_SHARING=SIMILAR

--13)
--- Determining sessions with a high number of parses
SELECT s.sid, s.value "Hard Parses",
t.value "Executions Count"
FROM v$sesstat s, v$sesstat t
WHERE s.sid=t.sid
AND s.statistic#=(select statistic#
FROM v$statname where name='parse count (hard)')
AND t.statistic#=(select statistic#
FROM v$statname where name='execute count')
AND s.value>0
ORDER BY 2 desc;

--14)
-- finding high cpu users
SELECT n.username,
s.sid,
s.value
FROM v$sesstat s,v$statname t, v$session n
WHERE s.statistic# = t.statistic#
AND n.sid = s.sid
AND t.name='CPU used by this session'
ORDER BY s.value desc;

--15)
-- determining session level cpu usage
SELECT sid, s.value "Total CPU Used by this Session"
FROM V$SESSTAT S
WHERE S.statistic# = 12
ORDER BY S.value DESC;

--The total CPU time used by an instance (or a session) can be viewed as the sum of the following 
--components:
--total CPU time = parsing CPU usage + recursive CPU usage + other CPU usage


--16)
--- DECOMPOSITION OF TOTAL CPU USAGE
SELECT name,value FROM V$SYSSTAT
WHERE NAME IN ('CPU used by this session',
'recursive cpu usage',
'parse time cpu'); 

--17)
---Parse Time CPU Usage
--a)
	SELECT name, value FROM V$SYSSTAT
WHERE name LIKE '%CPU%'

--b)
	SELECT name, value FROM V$SYSSTAT
WHERE name LIKE '%parse%';

--c)
	SELECT a.value " Tot_CPU_Used_This_Session",
b.value "Total_Parse_Count",
c.value "Hard_Parse_Count",
d.value "Parse_Time_CPU"
FROM v$sysstat a,
v$sysstat b,
v$sysstat c,
v$sysstat d
WHERE a.name = 'CPU used by this session'
AND b.name = 'parse count (total)'
AND c.name = 'parse count (hard)'
AND d.name = 'parse time cpu';
-----------------------------------------------------------------------------

--18)
-----------------------------------------------------------------------------
--TUNING SQL WHEN YOU KNOW THE SQL_TEXT EXAMPLE
-----------------------------------------------------------------------------
DECLARE
 my_task_name VARCHAR2(30);
 my_sqltext CLOB;
BEGIN
 my_sqltext := 'SELECT /*+ ORDERED */ *
                FROM employees e, locations l, departments d
                WHERE e.department_id = d.department_id AND
                l.location_id = d.location_id AND
                e.employee_id < :bnd';
Next, I create the following tuning task:

my_task_name := DBMS_SQLTUNE.CREATE_TUNING_TASK(
         sql_text    => my_sqltext,
         bind_list   => sql_binds(anydata.ConvertNumber(90)),
         user_name   => 'HR',
         scope       => 'COMPREHENSIVE',
         time_limit  => 60,
         task_name   => 'my_sql_tuning_task',
         description => 'Task to tune a query on a specified employee');
END;
/
--------------------------------------------------------------------------


--References:
-------------
-- Book: expert oracle database 11g administration by Sam Alapati
-- https://blogs.oracle.com/optimizer/post/dynamic-sampling-and-its-impact-on-the-optimizer
-- https://blogs.oracle.com/optimizer/post/extended-statistics
-- https://blogs.oracle.com/optimizer/post/cardinality-and-dynamic-statistics
-- https://blogs.oracle.com/optimizer/post/extended-statistics



-- on sql profiles;
----------------
-- https://asktom.oracle.com/ords/f?p=100:11:::::P11_QUESTION_ID:9543852800346796391
-- https://blog.go-faster.co.uk/2017/12/hints-patches-force-matching-and-sql.html
-- https://houseofbrick.com/blog/manual-creation-of-a-sql-profile/

