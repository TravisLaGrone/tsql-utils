SELECT
    par_sch.[name] AS parent_schema_name,
    par_obj.[name] AS parent_object_name,
    par_col.[name] AS parent_column_name,
    ref_sch.[name] AS referenced_schema_name,
    ref_obj.[name] AS referenced_object_name,
    ref_col.[name] AS referenced_column_name
FROM sys.foreign_key_columns AS fkc
    INNER JOIN sys.columns AS par_col
        ON  par_col.[object_id] = fkc.parent_object_id
        AND par_col.column_id = fkc.parent_column_id
    INNER JOIN sys.objects AS par_obj
        ON  par_obj.[object_id] = par_col.[object_id]
    INNER JOIN sys.schemas AS par_sch
        ON  par_sch.[schema_id] = par_obj.[schema_id]
    INNER JOIN sys.columns AS ref_col
        ON  ref_col.[object_id] = fkc.referenced_object_id
        AND ref_col.column_id = fkc.referenced_column_id
    INNER JOIN sys.objects AS ref_obj
        ON  ref_obj.[object_id] = ref_col.[object_id]
    INNER JOIN sys.schemas AS ref_sch
        ON  ref_sch.[schema_id] = ref_obj.[schema_id]
ORDER BY
    par_sch.name,
    par_obj.name,
    par_col.name,
    ref_sch.name,
    ref_obj.name,
    ref_col.name
