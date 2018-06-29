SELECT
    s_fk.name AS [foreign_key_schema_name],
    o_fk.name AS [foreign_key_name],
    s_par.name AS [parent_object_schema_name],
    o_par.name AS [parent_object_name],
    s_ref.name AS [referenced_object_schema_name],
    o_ref.name AS [referenced_object_name]
FROM sys.foreign_keys AS fk
    INNER JOIN sys.objects AS o_fk
        ON o_fk.object_id = fk.object_id
    INNER JOIN sys.schemas AS s_fk
        ON s_fk.schema_id = o_fk.schema_id
    INNER JOIN sys.objects AS o_par
        ON o_par.object_id = fk.parent_object_id
    INNER JOIN sys.schemas AS s_par
        ON s_par.schema_id = o_par.schema_id
    INNER JOIN sys.objects AS o_ref
        ON o_ref.object_id = fk.referenced_object_id
    INNER JOIN sys.schemas AS s_ref
        ON s_ref.schema_id = o_ref.schema_id
GROUP BY
    s_fk.name,
    o_fk.name,
    s_par.name,
    o_par.name,
    s_ref.name,
    o_ref.name