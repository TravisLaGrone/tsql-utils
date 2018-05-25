SELECT
    s.name [schema_name],
    o.name [object_name],
    i.name [index_name]
FROM sys.indexes AS i
    INNER JOIN sys.objects AS o
        ON  i.parent_object_id = o.object_id
    INNER JOIN (  -- non 'sys' schema
            SELECT *
            FROM sys.schemas AS _s
            WHERE _s.name <> 'sys'
        ) AS s
        ON  o.schema_id = s.schema_id
ORDER BY s.name, o.name, i.name, c.name