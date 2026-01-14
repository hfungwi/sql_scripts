SELECT d.name,
    f.phyrds reads,
    f.phywrts wrts,
    (f.readtim / decode(f.phyrds,0,-1,f.phyrds)) readtime,
    (f.writetim / decode(f.phywrts,0,-1,phywrts)) writetime
    FROM
    v$datafile d,
    v$filestat f
    WHERE
   d.file# = f.file#
  ORDER BY
 d.name;
