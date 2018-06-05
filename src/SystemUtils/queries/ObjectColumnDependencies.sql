SELECT
    [dependencies].[referencing_id]             AS [referencing_entity_id],
    [objects].[name]                            AS [referencing_entity_name],
    [dependencies].[referenced_id]              AS [referenced_entity_id],
    [dependencies].[referenced_entity_name]     AS [referenced_entity_name],
    [entities].[referenced_minor_id]            AS [referenced_column_id],
    [entities].[referenced_minor_name]          AS [referenced_column_name],
    [dependencies].[is_schema_bound_reference]  AS [is_schema_bound_reference]
FROM [sys].[sql_expression_dependencies]                                                                AS [dependencies]
    JOIN [sys].[objects]                                                                                AS [objects]
        ON [objects].[object_id] = [dependencies].[referencing_id]
    JOIN [sys].[schemas]                                                                                AS [schemas]
        ON [schemas].[schema_id] = [objects].[schema_id]
    CROSS APPLY [sys].[dm_sql_referenced_entities]([schemas].[name] + '.' + [objects].[name], 'OBJECT') AS [entities]
WHERE   [entities].[referenced_entity_name] = [dependencies].[referenced_entity_name]
    AND (   [dependencies].[is_schema_bound_reference] = 0
        OR  [entities].[referenced_minor_id]           = [dependencies].[referenced_minor_id]
    )