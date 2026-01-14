---------------------------------------------
--NAME     :undo_advise.sql
--USAGE    :get undo tbs advise from undo_advisor
--AUTHOR   :ORACLE (MOS DOC)
--REQUIRED :system or sysdba privs
--DATE     :6th OCT 2023
---------------------------------------------
set serveroutput on
DECLARE
tbs_name    VARCHAR2(30);
tbs_size    NUMBER(10);
tbs_autoextend    BOOLEAN;
tbs_retention    NUMBER(5);
tbs_guarantee    BOOLEAN;
undo_adv BOOLEAN;
BEGIN
dbms_output.put_line('=====================================================================');
undo_adv := dbms_undo_adv.undo_info(tbs_name, tbs_size, tbs_autoextend, tbs_retention, tbs_guarantee);
If undo_adv=TRUE then
dbms_output.put_line('UNDO Tablespace Name : ' || tbs_name);
dbms_output.put_line('UNDO tablespace is '|| CASE WHEN tbs_autoextend THEN  'Auto Extensiable' ELSE 'Fixed Size' END);
If tbs_autoextend=TRUE then dbms_output.put_line('UNDO Tablespace Maximum size (MB) is : ' || TO_CHAR(tbs_size));
else dbms_output.put_line('UNDO Tablespace Fixed size (MB) is : ' || TO_CHAR(tbs_size));
end if;
dbms_output.put_line('Undo Retention is ' || TO_CHAR(tbs_retention)||' Seconds' ||' Equivelant to ' ||round((tbs_retention/60),2) ||' Minutes');
dbms_output.put_line('Retention : '||CASE WHEN tbs_guarantee THEN 'Guaranteed ' ELSE 'Not Guaranteed' END);
else dbms_output.put_line('Function undo_info can only run if parameters undo_management is auto');
end if;
dbms_output.put_line('=====================================================================');
END;
/



set serveroutput on
DECLARE
utbsiz_in_MB NUMBER;
BEGIN
utbsiz_in_MB := DBMS_UNDO_ADV.RBU_MIGRATION;
dbms_output.put_line('=================================================================');
dbms_output.put_line('The Minimum size of the undo tablespace required is : '||utbsiz_in_MB||' MB');
dbms_output.put_line('=================================================================');
end;
/

set serveroutput on

DECLARE
 prob VARCHAR2(100);
 reco VARCHAR2(100);
 rtnl VARCHAR2(100);
 retn PLS_INTEGER;
 utbs PLS_INTEGER;
 retv PLS_INTEGER;
BEGIN
retv := dbms_undo_adv.undo_health(prob, reco, rtnl, retn, utbs);
dbms_output.put_line('=====================================================================');
If retv=0 Then dbms_output.put_line('Problem: ' || prob || ' The undo tablespace is OK');
ELSIF retv=2 Then dbms_output.put_line('Long running queries may fail , The recommendation is : ' || reco);
dbms_output.put_line('rationale: ' || rtnl);
dbms_output.put_line('retention: ' || TO_CHAR(retn));

ELSIF retv=3 Then dbms_output.put_line('The Undo tablespace cannot satisfy the longest query , The recommendation is : ' || reco);
dbms_output.put_line('rationale: ' || rtnl);
dbms_output.put_line('undo tablespace size in MB : ' || TO_CHAR(utbs));
dbms_output.put_line('retention: ' || TO_CHAR(retn));

ELSIF retv=4 Then dbms_output.put_line('The System does not have an online undo tablespace , The recommendation is : ' || reco);
dbms_output.put_line('rationale: ' || rtnl);
dbms_output.put_line('undo tablespace size in MB : ' || TO_CHAR(utbs));

ELSIF retv=1 Then dbms_output.put_line('The Undo tablespace cannot satisfy the specified undo_retention or The Undo tablespace cannot satisfy auto tuning undo retention , The recommendation is : ' || reco);
dbms_output.put_line('rationale: ' || rtnl);
dbms_output.put_line('undo tablespace size in MB : ' || TO_CHAR(utbs));
end if;
dbms_output.put_line('=====================================================================');

END;
/

SELECT 'The Required undo_retention using Statistics In Memory is ' || dbms_undo_adv.required_retention required_retention FROM dual;

SELECT 'The best possible value for undo_retention the current undo tablespace can satisfy is ' ||
