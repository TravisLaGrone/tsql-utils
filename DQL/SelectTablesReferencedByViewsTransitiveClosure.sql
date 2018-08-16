WITH
    referenced AS (
        SELECT
            vw.name AS referencing_view_name,
            ref.referenced_entity_name AS referenced_entity_name
        FROM sys.views AS vw
            CROSS APPLY sys.dm_sql_referenced_entities(
                QUOTENAME(SCHEMA_NAME(vw.schema_id)) + '.' + QUOTENAME(vw.name),
                N'OBJECT'
            ) AS ref
            INNER JOIN sys.objects AS obj
                ON  obj.name = ref.referenced_entity_name
                AND obj.schema_id = vw.schema_id
        WHERE
            obj.type IN ('U', 'V')  -- user-defined table, view
    ),
    recursion AS (
        SELECT
            ref.referencing_view_name,
            ref.referenced_entity_name
        FROM referenced AS ref
        UNION ALL
        SELECT
            src.referencing_view_name,
            tar.referenced_entity_name
        FROM recursion AS src
            INNER JOIN referenced AS tar
                ON  src.referenced_entity_name = tar.referencing_view_name
    )
SELECT DISTINCT  -- distinct because recursion input (B->C, A->B, A->C) would result in output with duplicates (B->C, A->B, A->C, A->C)
    rec.referencing_view_name AS view_name,
    rec.referenced_entity_name AS table_name
FROM recursion AS rec
WHERE rec.referenced_entity_name NOT IN (  -- anti-join
        SELECT ref.referencing_view_name
        FROM referenced AS ref
    )
ORDER BY rec.referencing_view_name
;
GO