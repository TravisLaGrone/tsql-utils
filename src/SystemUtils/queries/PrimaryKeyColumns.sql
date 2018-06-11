SELECT
    sch.[name] AS [schema_name],
    obj.[name] AS [object_name],
    key_con.[name] AS primary_key_name,
    col.[name] AS column_name
FROM sys.columns AS col
    INNER JOIN sys.index_columns AS idx_col
        ON  idx_col.[object_id] = col.[object_id]
        AND idx_col.column_id = col.column_id
    INNER JOIN sys.indexes AS idx
    	ON	idx.[object_id] = idx_col.[object_id]
        AND idx.index_id  = idx_col.index_id
    INNER JOIN sys.key_constraints AS key_con
        ON  key_con.[object_id] = idx.[object_id]
        AND key_con.unique_index_id = idx.index_id
    INNER JOIN sys.objects AS obj
    	ON	obj.[object_id] = idx.[object_id]
    INNER JOIN sys.schemas AS sch
    	ON	sch.[schema_id] = obj.[schema_id]
WHERE
    idx.is_primary_key = 1
    AND sch.[name] <> 'sys'
ORDER BY
    sch.[name],
    obj.[name],
    key_con.[name],
    idx_col.key_ordinal