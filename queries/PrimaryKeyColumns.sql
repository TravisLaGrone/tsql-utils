SELECT
    sch.[name] AS [schema_name],
    tbl.[name] AS [object_name],
    tbl.[type_desc] AS object_type_desc,
    key_con.[name] AS constraint_name,
    key_con.is_system_named AS constraint_is_system_named,
    idx.[name] AS index_name,
    col.[name] AS column_name,
    CASE
        WHEN col.name LIKE 'ID_%' THEN 1
        ELSE 0
    END AS column_name_has_ID_prefix,
    CASE
        WHEN col.name LIKE '%_ID_%' THEN 1
        ELSE 0
    END AS column_name_has_ID_infix,
    CASE
        WHEN col.name LIKE '%_ID' THEN 1
        ELSE 0
    END AS column_name_has_ID_suffix,
    TYPE_NAME(col.user_type_id) AS column_type_name,
    col.max_length AS column_type_max_length,
    col.[precision] AS column_type_numeric_precision,
    col.scale AS column_type_numeric_scale,
    col.collation_name AS column_type_character_collation_name,
    col.is_nullable AS column_is_nullable,
    col.is_rowguidcol AS column_is_rowguidcol,
    col.is_identity AS column_is_identity,
    col.is_computed AS column_is_computed,
    CASE
        WHEN EXISTS(
            SELECT *
            FROM sys.foreign_key_columns AS fkc
            WHERE
                fkc.parent_object_id = col.[object_id]
                AND fkc.parent_column_id = col.[column_id]
        ) THEN 1
        ELSE 0
    END AS column_is_part_of_foreign_key,
    CASE
        WHEN EXISTS(
            SELECT *
            FROM sys.foreign_key_columns AS fkc
            WHERE
                fkc.referenced_object_id = col.[object_id]
                AND fkc.referenced_column_id = col.[column_id]
        ) THEN 1
        ELSE 0
    END AS column_is_referenced_by_foreign_key,
    CONVERT(nvarchar(MAX), ep.value) AS column_MS_Description
FROM sys.columns AS col
    INNER JOIN sys.index_columns AS idx_col
        ON  idx_col.[object_id] = col.[object_id]
        AND idx_col.column_id = col.column_id
    INNER JOIN sys.indexes AS idx
    	ON	idx.[object_id] = idx_col.[object_id]
        AND idx.index_id  = idx_col.index_id
    LEFT JOIN sys.key_constraints AS key_con
        ON  key_con.[object_id] = idx.[object_id]
        AND key_con.unique_index_id = idx.index_id
    INNER JOIN sys.tables AS tbl
    	ON	tbl.[object_id] = idx.[object_id]
    INNER JOIN sys.schemas AS sch
    	ON	sch.[schema_id] = tbl.[schema_id]
    OUTER APPLY sys.fn_listextendedproperty('MS_Description', 'SCHEMA', sch.name, 'TABLE', tbl.name, 'COLUMN', col.name) AS ep
WHERE
    idx.is_primary_key = 1
    AND sch.[name] <> 'sys'
ORDER BY
    sch.[name],
    tbl.[name],
    key_con.[name],
    idx.[name],
    idx_col.key_ordinal