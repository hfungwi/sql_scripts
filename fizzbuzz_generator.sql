CREATE OR REPLACE FUNCTION FIZZ_BUZZ_RANGE (
    P_START IN NUMBER,
    P_END   IN NUMBER
) RETURN CLOB IS
    V_TEMPVAL VARCHAR2(120);
    V_CURRVAL CLOB;
BEGIN
    FOR I IN P_START..P_END LOOP
        IF I = 1 THEN
            V_CURRVAL := TO_CHAR(I);
        ELSIF MOD(I, 3) = 0 THEN
            IF MOD(I, 5) = 0 THEN
                V_TEMPVAL := 'fizzbuzz';
            ELSE
                V_TEMPVAL := 'fizz';
            END IF;
        ELSIF MOD(I, 5) = 0 THEN
            IF MOD(I, 3) = 0 THEN
                V_TEMPVAL := 'fizzbuzz';
            ELSE
                V_TEMPVAL := 'buzz';
            END IF;
        ELSE
            V_TEMPVAL := I;
        END IF;

        IF I > P_START THEN
            V_CURRVAL := V_CURRVAL || ', ';
        END IF;
        V_CURRVAL := V_CURRVAL || V_TEMPVAL;
    END LOOP;

    RETURN V_CURRVAL;
END;
/
-- write your solution statement below here | DONT DELETE THIS LINE --
SELECT
    FIZZ_BUZZ_RANGE(51, 75)
FROM
    DUAL;
