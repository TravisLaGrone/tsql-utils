SELECT
    s.name [schema_name],
    o.name [object_name],
    i.name [index_name],
    c.name [column_name],
    ic.[key_ordinal],
    ic.[partition_ordinal],
    ic.[is_descending_key],
    ic.[is_included_column]
FROM sys.index_columns AS ic
    INNER JOIN sys.indexes AS i
        ON i.index_id = ic.index_id
    INNER JOIN sys.columns AS c
        ON  ic.object_id = c.object_id
        AND ic.column_id = c.column_id
    INNER JOIN sys.objects AS o
        ON  ic.object_id = o.object_id
    INNER JOIN (  -- non 'sys' schema
            SELECT *
            FROM sys.schemas AS _s
            WHERE _s.name <> 'sys'
        ) AS s
        ON  o.schema_id = s.schema_id
ORDER BY s.name, o.name, i.name, c.name