WITH
    [foreign keys] AS (
        SELECT fk.object_id, fk.parent_object_id, fk.referenced_object_id
        FROM sys.foreign_keys AS fk
        WHERE fk.is_disabled = 0
    ),
    [multi-column foreign keys] AS (
        SELECT fkc.constraint_object_id
        FROM [foreign keys] AS fk
        INNER JOIN sys.foreign_key_columns AS fkc
            ON fk.object_id = fkc.constraint_object_id
        GROUP BY fkc.constraint_object_id
        HAVING COUNT(*) > 1
    ),
    [foreign key columns] AS (
        SELECT fkc.constraint_object_id, fkc.parent_column_id, fkc.parent_object_id, fkc.referenced_column_id, fkc.referenced_object_id
        FROM [multi-column foreign keys] AS mcfk
        INNER JOIN sys.foreign_key_columns AS fkc
            ON mcfk.constraint_object_id = fkc.constraint_object_id
    )
SELECT
    con_obj.name [relational_constraint_name]
,   par_obj.name [parent_object_name]
,   par_col.name [parent_column_name]
,   ref_obj.name [referenced_object_name]
,   ref_obj.name [referenced_column_name]
FROM [foreign key columns] AS fkc
INNER JOIN sys.objects AS con_obj
    ON fkc.constraint_object_id = con_obj.object_id
INNER JOIN sys.objects AS par_obj
    ON fkc.parent_object_id = par_obj.object_id
INNER JOIN sys.objects AS ref_obj
    ON fkc.referenced_object_id = ref_obj.object_id
INNER JOIN sys.columns AS par_col
    ON fkc.parent_column_id = par_col.column_id
INNER JOIN sys.columns AS ref_col
    ON fkc.referenced_column_id = ref_col.column_id