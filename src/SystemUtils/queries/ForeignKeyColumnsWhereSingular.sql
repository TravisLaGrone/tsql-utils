SELECT
    s_con.name [foreign_key_schema_name],
    o_con.name [foreign_key_name],
    fkc.constraint_column_id [foreign_key_column_id],
    s_par.name [parent_schema_name],
    o_par.name [parent_object_name],
    c_par.name [parent_column_name],
    s_ref.name [referenced_schema_name],
    o_ref.name [referenced_object_name],
    c_ref.name [referenced_column_name]
FROM sys.foreign_key_columns AS fkc
    INNER JOIN (  -- filter for multi-column foreign keys
            SELECT _fkc.constraint_object_id
            FROM sys.foreign_key_columns AS _fkc
            GROUP BY _fkc.constraint_object_id
            HAVING COUNT(_fkc.constraint_column_id) = 1
        ) AS mcfk
        ON  mcfk.constraint_object_id = fkc.constraint_object_id
    INNER JOIN (  -- filter for enabled and trusted foreign keys
            SELECT _fk.object_id
            FROM sys.foreign_keys AS _fk
            WHERE   _fk.is_disabled = 0
                AND _fk.is_not_trusted = 0
        ) AS efk
        ON  efk.object_id = mcfk.constraint_object_id
    INNER JOIN sys.objects AS o_con  -- to name foreign key
        ON  o_con.object_id = fkc.constraint_object_id
    INNER JOIN sys.schemas AS s_con  -- to name foreign key schema
        ON  s_con.schema_id = o_con.schema_id
    INNER JOIN sys.columns AS c_par  -- to name parent column
        ON  c_par.object_id = fkc.parent_object_id
        AND c_par.column_id = fkc.parent_column_id
    INNER JOIN sys.objects AS o_par  -- to name parent
        ON  o_par.object_id = fkc.parent_object_id
    INNER JOIN sys.schemas AS s_par  -- to name parent schema
        ON  s_par.schema_id = o_par.schema_id
    INNER JOIN sys.columns AS c_ref  -- to name referenced column
        ON  c_ref.object_id = fkc.referenced_object_id
        AND c_ref.column_id = fkc.parent_column_id
    INNER JOIN sys.objects AS o_ref  -- to name referenced
        ON  o_ref.object_id = fkc.referenced_object_id
    INNER JOIN sys.schemas AS s_ref  -- to name referenced schema
        ON  s_ref.schema_id = o_ref.schema_id
ORDER BY s_con.name, o_con.name, fkc.constraint_column_id