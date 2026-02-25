--returns the size(not number) of free extents within a segment
-- as well as the size of chained rows in that segment
DECLARE
  v_used_bytes      NUMBER;
  v_alloc_bytes     NUMBER;
  v_unformat_bytes  NUMBER;
BEGIN
  DBMS_SPACE.OBJECT_SPACE_USAGE(
    object_owner      => '&object_owner',
    object_name       => '&object_name',
    object_type       => '&object_type',
    sample_control    => NULL,
    space_used        => v_used_bytes,
    space_allocated   => v_alloc_bytes,
    chain_pcent       => v_unformat_bytes
  );
  DBMS_OUTPUT.PUT_LINE('Used: '      || v_used_bytes/1024/1024 || ' MB');
  DBMS_OUTPUT.PUT_LINE('Allocated: ' || v_alloc_bytes/1024/1024 || ' MB');
  DBMS_OUTPUT.PUT_LINE('chained_rows: ' || v_unformat_bytes/1024/1024 || ' MB');
END;
/
