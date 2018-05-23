
/* DATABASE */
SELECT
    NULL       AS [level0type],
    NULL       AS [level0name],
    NULL       AS [level1type],
    NULL       AS [level1name],
    NULL       AS [level2type],
    NULL       AS [level2name],
    [name]     AS [name],
    [value]    AS [value],
    'DATABASE' AS [basetype]
FROM [sys].[extended_properties]
WHERE [class] = 0

UNION

/* SCHEMA */
SELECT
    'SCHEMA'         AS [level0type],
    [schemas].[name] AS [level0name],
    NULL             AS [level1type],
    NULL             AS [level1name],
    NULL             AS [level2type],
    NULL             AS [level2name],
    [props].[name],
    [props].[value],
    'SCHEMA'         AS [basetype]
FROM [sys].[extended_properties] AS [props]
    INNER JOIN [sys].[schemas]   AS [schemas]
        ON [props].[major_id] = [schemas].[schema_id]
WHERE [props].[class] = 3

UNION

/* TABLE, VIEW, FUNCTION, PROCEDURE */
SELECT
    'SCHEMA'                        AS [level0type],
    SCHEMA_NAME([objs].[schema_id]) AS [level0name],
    CASE [objs].[type]
        WHEN 'U' THEN
            'TABLE'
        WHEN 'V' THEN
            'VIEW'
        WHEN 'FN' THEN
            'FUNCTION'
        WHEN 'IF' THEN
            'FUNCTION'
        WHEN 'TF' THEN
            'FUNCTION'
        WHEN 'P' THEN
            'PROCEDURE'
    END                             AS [level1type],
    [objs].[name]                   AS [level1name],
    NULL                            AS [level2type],
    NULL                            AS [level2name],
    [props].[name],
    [props].[value],
    CASE [objs].[type]
        WHEN 'U' THEN
            'TABLE'
        WHEN 'V' THEN
            'VIEW'
        WHEN 'FN' THEN
            'FUNCTION'
        WHEN 'IF' THEN
            'FUNCTION'
        WHEN 'TF' THEN
            'FUNCTION'
        WHEN 'P' THEN
            'PROCEDURE'
    END                             AS [basetype]
FROM [sys].[extended_properties] AS [props]
    INNER JOIN [sys].[objects]   AS [objs]
        ON [props].[major_id] = [objs].[object_id]
WHERE [props].[class] = 1
    AND [props].[minor_id] = 0
    AND [objs].[type] IN ('U', 'V', 'FN', 'IF', 'TF', 'P')
    
UNION

/* COLUMN */
SELECT
    'SCHEMA'                        AS [level0type],
    SCHEMA_NAME([objs].[schema_id]) AS [level0name],
    CASE [objs].[type]
        WHEN 'U' THEN
            'TABLE'
        WHEN 'V' THEN
            'VIEW'
        WHEN 'IF' THEN
            'FUNCTION'
        WHEN 'TF' THEN
            'FUNCTION'
        WHEN 'P' THEN
            'PROCEDURE'
    END                             AS [level1type],
    [objs].[name]                   AS [level1name],
    'COLUMN'                        AS [level2type],
    [cols].[name]                   AS [level2name],
    [props].[name],
    [props].[value],
    'COLUMN'                        AS [basetype]
FROM [sys].[extended_properties] AS [props]
    INNER JOIN [sys].[columns]   AS [cols]
        ON [props].[major_id] = [cols].[object_id]
            AND [props].[minor_id] = [cols].[column_id]
    INNER JOIN [sys].[objects]   AS [objs]
        ON [props].[major_id] = [objs].[object_id]
WHERE [props].[class] = 1
    AND [props].[minor_id] <> 0
    AND [objs].[type] IN ('U', 'V', 'IF', 'TF', 'P')
    
UNION

/* PARAMETER */
SELECT
    'SCHEMA'                        AS [level0type],
    SCHEMA_NAME([objs].[schema_id]) AS [level0name],
    CASE [objs].[type]
        WHEN 'FN' THEN
            'FUNCTION'
        WHEN 'IF' THEN
            'FUNCTION'
        WHEN 'TF' THEN
            'FUNCTION'
        WHEN 'P' THEN
            'PROCEDURE'
    END                             AS [level1type],
    [objs].[name]                   AS [level1name],
    'PARAMETER'                     AS [level2type],
    [params].[name]                 AS [level2name],
    [props].[name],
    [props].[value],
    'PARAMETER'                     AS [basetype]
FROM [sys].[extended_properties]  AS [props]
    INNER JOIN [sys].[parameters] AS [params]
        ON [props].[major_id] = [params].[object_id]
            AND [props].[minor_id] = [params].[parameter_id]
    INNER JOIN [sys].[objects]    AS [objs]
        ON [props].[major_id] = [objs].[object_id]
WHERE [props].[class] = 2
    AND [objs].[type] IN ('FN', 'IF', 'TF', 'P')

ORDER BY
    level0type,
    level0name,
    level1type,
    level1name,
    level2type,
    level2name,
    [name],
    [value]