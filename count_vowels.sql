CREATE OR REPLACE FUNCTION COUNT_VOWELS (p_string IN VARCHAR2)
RETURN NUMBER
IS
   v_count  NUMBER := 0;
   v_length NUMBER;
   v_char   VARCHAR2(1);
BEGIN
    v_length := length(p_string);
    FOR I in 1..v_length 
      LOOP
        v_char := upper(substr(p_string, i, 1));
         IF v_char in ('A', 'E','I','O','U')
          THEN v_count := v_count + 1;
          ELSE NULL;
         END IF; 
      END LOOP;
RETURN v_count;
END;
/

---
select count_vowels('THe QUICK BROWN iOX JUMPED OVER THE LAZY DOGS') ;

        
