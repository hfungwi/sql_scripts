-- from blog on tracing by arup nanda on oracle blogs
-- use to create blog, improving peformance of inserts with direct path loads
-- link to blog is : https://blogs.oracle.com/connect/beginning-performance-tuning-trace-your-steps
-- simplified into 3 steps
-- scenario setting :
/* consider an application that is running slowly, however running slowly inconsistently
 from v4session you're unable to pinpoint the sql_id (probably the app is waiting a lot of the time)
 and when you do you're not quite clear about what actually goes on and what the optimizer is doing to 
 resolve all the optimizer requets. How to fix this: Introducing TKprof the tuning tool you never knew you needed
up until this point I had never used this utility and I had an issue; an ETL application was doing some update and they 
took a long time but not always, sometimes the jobs ran fast sometimes they ran slow (In my specific case we had the option to choose to
turn on bulk load in the application or not) after turning bulk load omn (direct path insert) the difference in peformance was different
the first session ran row vby row or "slow by slow" and the second ran perfectly. I used tkprof to identify the difference in the sessions and
these are the steps.*/

--step 1: Identify sid and serial# of session/app you want to trace
-- while the application is running, from a users with sysdba privilege, run
select sid, serial#
from v$session
where username = upper('&username');
-- pass in the application username

--step 2: trace the session using dbms_monitor
-- when you get the sid and serial# run
begin
  dbms_monitor.session_trace_enable (
    session_id => <SID>, 
    serial_num => <serial#>, 
    waits      => true, 
    binds      => true
    plan_stat  => 'all_executions');
end;

-- an os file is generated which can be identified using
select
   r.value                                ||'/diag/rdbms/'||
   sys_context('USERENV','DB_NAME')       ||'/'||
   sys_context('USERENV','INSTANCE_NAME') ||'/trace/'||
   sys_context('USERENV','DB_NAME')       ||'_ora_'||p.spid||'.trc'
   as tracefile_name
from v$session s, v$parameter r, v$process p
where r.name = 'diagnostic_dest'
and s.sid = &1
and p.addr = s.paddr;
-- 
-- NB: When the file path is generated example :  /u01/app/oracle/diag/rdbms/TESTDB/TESTDB/trace/TESTDB_ora_2745911.trc
-- change the first sid to lowercase ie: /u01/app/oracle/diag/rdbms/testdb/TESTDB/trace/TESTDB_ora_2745911.trc

-- step 3: use tkprof to format the output and then cat the resulting file to analyze the session
$tkprof /u01/app/oracle/diag/rdbms/TESTDB/TESTDB/trace/TESTDB_ora_2745911.trc

--when prompted for output, enter the name of the output file you want
--cat the generated file and analyze it for issues with your sql/session
