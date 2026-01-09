--HR DUMMY SCHEMA FUNCTION - ENCRYPT, DECRYPT AND REDACT SSN
-----------------

--CREATE PACKAGE 
CREATE OR REPLACE PACKAGE encrypt_sensitive_data AS
    FUNCTION encrypt_ssn (
        p_ssn_in IN NUMBER
    ) RETURN CLOB;

    FUNCTION decrypt_ssn (
        p_employee_id IN NUMBER
    ) RETURN CLOB;

END;
/


--CREATE PACKAGE BODY
CREATE OR REPLACE PACKAGE BODY encrypt_sensitive_data IS

    FUNCTION encrypt_ssn (
        p_ssn_in IN NUMBER
    ) RETURN CLOB IS

        v_ssn_text      VARCHAR2(4000);
        v_encrypted_raw RAW(32767);
        v_key           RAW(32767);
        v_hex           CLOB;
    BEGIN
        v_ssn_text := to_char(p_ssn_in);
        v_key := utl_raw.cast_to_raw('&encrypt_key');
        v_encrypted_raw := dbms_crypto.encrypt(src => utl_raw.cast_to_raw(v_ssn_text), typ => dbms_crypto.encrypt_aes256 + dbms_crypto.chain_cbc
        + dbms_crypto.pad_pkcs5, key => v_key);

        v_hex := rawtohex(v_encrypted_raw);
        RETURN v_hex;
    END encrypt_ssn;

    FUNCTION decrypt_ssn (
        p_employee_id IN NUMBER
    ) RETURN CLOB IS

        v_encrypted_data CLOB;
        v_decrypted_raw  RAW(32767);
        v_decrypted_text VARCHAR2(32767);
        v_key            RAW(32767);
    BEGIN
        SELECT
            ssn
        INTO v_encrypted_data
        FROM
            employees
        WHERE
            employee_id = p_employee_id;

        v_key := utl_raw.cast_to_raw('&encrypt_key');
        v_decrypted_raw := dbms_crypto.decrypt(src => hextoraw(to_char(v_encrypted_data)), typ => dbms_crypto.encrypt_aes256 + dbms_crypto.chain_cbc
        + dbms_crypto.pad_pkcs5, key => v_key);

        v_decrypted_text := utl_raw.cast_to_varchar2(v_decrypted_raw);
        RETURN v_decrypted_text;
    END decrypt_ssn;

END;
/

--SMALL TEST
UPDATE employees
SET
    ssn = encrypt_sensitive_data.encrypt_ssn(123456789)
WHERE
    employee_id = 100;

SELECT
    encrypt_sensitive_data.decrypt_ssn(employee_id) ssn
FROM
    employees
WHERE
    employee_id = 100;
--MAKE SURE IT WORKS


--LARGER TEST
UPDATE employees
SET
    ssn = encrypt_sensitive_data.encrypt_ssn( TO_CHAR(TRUNC(DBMS_RANDOM.VALUE(POWER(10,9), POWER(10,10) - 1)), '0000000000') )
    ;
    COMMIT ;

SELECT
      encrypt_sensitive_data.decrypt_ssn(employee_id) 
     ,LENGTH(encrypt_sensitive_data.decrypt_ssn(employee_id)) LENGTH_ssn
FROM
    employees
     ;

alter session set nls_date_format='dd-mon-yyyy';


---REDACTION
BEGIN
  dbms_redact.add_policy(
    object_schema => user,
    object_name   => 'EMPLOYEES',
    column_name   => 'SSN',
    policy_name   => 'redact_employe_ssn',
    function_type => dbms_redact.full,
    expression    => 'sys_context(''userenv'',''session_user'') != ''HR'''
  );
end;
/


--GRANT privileges on the procedure to target app user/role

--TEST
-- try test from owning schem and app schema
-- app schema should not see column data but owning schema should be able to
select *
from   employees
order by employee_id;


SELECT
         encrypt_sensitive_data.decrypt_ssn(employee_id) 
FROM
    employees
     ;


--from system
SET LINESIZE 200

COLUMN object_owner FORMAT A20
COLUMN object_name FORMAT A30
COLUMN policy_name FORMAT A30
COLUMN expression FORMAT A30
COLUMN policy_description FORMAT A20

SELECT object_owner,
       object_name,
       policy_name,
       expression,
       enable,
       policy_description
FROM   redaction_policies
ORDER BY 1, 2, 3;


--TO DROP POLICY
begin
  dbms_redact.drop_policy (
    object_schema => user,
    object_name   => 'EMPLOYEES',
    policy_name   => 'redact_employe_ssn'
  );
end;
/



