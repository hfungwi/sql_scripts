select
       decode
       ( sign(floor(maxwidth/2)-rownum)
       , 1, lpad( ' ', floor(maxwidth/2)-(rownum-1))
         || rpad( '*', 2*(rownum-1)+1, ' *')
       , lpad( '* * *', floor(maxwidth/2)+3))
from all_objects
   , (select 40 as maxwidth from dual)
where rownum < floor(maxwidth/2) +5
union all
SELECT chr(10)|| ' Merry Christmas Everyone ! '
FROM   dual ;
