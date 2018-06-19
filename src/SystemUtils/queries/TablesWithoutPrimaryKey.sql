SELECT
    sch.name AS schema_name,
    tbl.name AS table_name
FROM sys.schemas AS sch
    INNER JOIN sys.tables AS tbl
        ON  tbl.schema_id = sch.schema_id
    INNER JOIN sys.indexes AS idx
        ON  idx.object_id = tbl.object_id
WHERE sch.name <> 'sys'
GROUP BY tbl.object_id
HAVING SUM(CONVERT(int, idx.is_primary_key)) = 0