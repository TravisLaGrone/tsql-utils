SELECT
    s.name [schema_name],
    o.name [object_name],
    i.name [index_name],
    i.[type],
    i.[type_desc],
    i.[is_unique],
    i.[ignore_dup_key] AS [allow_duplicate_keys],
    i.[is_primary_key],
    i.[is_unique_constraint],
    i.[fill_factor],
    i.[is_padded],
    ~i.[is_disabled] AS [is_enabled],
    i.[is_hypothetical],
    i.[allow_row_locks],
    i.[allow_page_locks],
    i.[has_filter],
    i.[filter_definition]
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