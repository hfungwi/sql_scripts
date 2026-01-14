-- File    : who.sql
-- Purpose : Show all processes connected to the current database
-- Params  : None
-- Run As  : SYS, SYSTEM or DBA equivalent
-- Notes   : If access is granted to SYS.V_$SESSION, any Oracle account can run
--           this script.
--           When running the parallel server, only the processes connected
--           to the current instance are visible.
-- History : BMB  05-JAN-1994  initial code
--           BMB  24-JAN-1994  added ID column
--           BMB  11-DEC-1995  added '*' to denote current session
--           BMB  29-JAN-1997  remove v$process query only v$session
--                             display operating system username (of the Oracle
--                             user, not the background process)
--                             added serial# for use with trace_session script
--                             added machine name
--                             removed program field; too big to fit on screen

SET PAGESIZE 60
SET FEEDBACK ON
SET TERMOUT OFF
SET LINESIZE 150

COLUMN username HEADING "ORACLE|USERNAME"  FORMAT A15 TRUNCATED
COLUMN osuser   HEADING "OS|USERNAME"      FORMAT A10 TRUNCATED
COLUMN sid      HEADING "SESS ID/|SERIAL#" FORMAT A13
COLUMN server   HEADING "SERVER|TYPE"      FORMAT A9  TRUNCATED
COLUMN program  HEADING "PROGRAM|NAME"     FORMAT A20 TRUNCATED
COLUMN machine  HEADING "MACHINE|NAME"     FORMAT A10 TRUNCATED

BREAK ON username

COLUMN name NEW_VALUE db_name NOPRINT
SELECT name FROM v$database
/

SET TERMOUT ON

PROMPT
PROMPT Users currently connected to database &&db_name (* = current session):
PROMPT
PROMPT SRVR TYPE: S=SHARED,N=NONE,D=DEDICATED

SELECT DECODE(terminal, USERENV('TERMINAL'), '*') || username
       AS username,
       osuser, machine,
       sid || '/' || serial# AS sid,
       terminal,
       server
FROM v$session
WHERE type <> 'BACKGROUND'
ORDER BY username, sid, serial#
/

UNDEFINE db_name
CLEAR BREAKS
CLEAR COLUMNS
SET PAGESIZE 14
SET LINESIZE 80
