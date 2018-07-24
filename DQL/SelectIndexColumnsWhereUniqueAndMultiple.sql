SELECT
    s.[name] [schema_name],
    o.[name] [object_name],
    i.[name] [index_name],
    c.[name] [column_name],
    o.type_desc [object_type]
FROM sys.index_columns AS ic
    INNER JOIN sys.columns AS c
        ON  ic.object_id = c.object_id
        AND ic.column_id = c.column_id
    INNER JOIN (  -- unique indexes
            SELECT *
            FROM sys.indexes AS i
            WHERE   i.is_unique = 1
                AND i.has_filter = 0
                AND i.is_disabled = 0
                AND i.ignore_dup_key = 0
        ) AS i
        ON  ic.object_id = i.object_id
        AND ic.index_id = i.index_id
    INNER JOIN sys.objects AS o
        ON  ic.object_id = o.object_id
    INNER JOIN (  -- non 'sys' schema
            SELECT *
            FROM sys.schemas AS _s
            WHERE _s.[name] <> 'sys'
        ) AS s
        ON  o.schema_id = s.schema_id
    INNER JOIN (  -- filter for multi-column indexes
            SELECT _ic.object_id, _ic.index_id
            FROM sys.index_columns AS _ic
            GROUP BY _ic.object_id, _ic.index_id
            HAVING COUNT(_ic.column_id) > 1
        ) AS sci
        ON  ic.object_id = sci.object_id
        AND ic.index_id = sci.index_id
ORDER BY
    s.[name],
    o.[name],
    i.[name],
    c.[name]