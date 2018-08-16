/** Selects all databases, schemas, tables, views, T-SQL functions, T-SQL procedures
 *  table/view columns, and T-SQL function/procedure parameters that allow extended properties,
 *  as well as their extant extended properties (if any), within the current server context +
 *  database context (if any).
 */
WITH
    [extended_properties] AS (
        /* DATABASE */
        SELECT
            [name]
        ,   [value]
        ,   NULL       AS [level0type]
        ,   NULL       AS [level0name]
        ,   NULL       AS [level1type]
        ,   NULL       AS [level1name]
        ,   NULL       AS [level2type]
        ,   NULL       AS [level2name]
        ,   'DATABASE' AS [basetype]
        FROM [sys].[extended_properties]
        WHERE [class] = 0
        UNION

        /* SCHEMA */
        SELECT
            [props].[name]
        , [props].[value]
        ,   'SCHEMA'         AS [level0type]
        , [schemas].[name]   AS [level0name]
        ,   NULL             AS [level1type]
        ,   NULL             AS [level1name]
        ,   NULL             AS [level2type]
        ,   NULL             AS [level2name]
        ,   'SCHEMA'         AS [basetype]
        FROM [sys].[extended_properties] AS [props]
            INNER JOIN [sys].[schemas]   AS [schemas]
                ON [props].[major_id] = [schemas].[schema_id]
        WHERE [props].[class] = 3
        UNION

        /* TABLE, VIEW, FUNCTION, PROCEDURE */
        SELECT
            [props].[name]
        , [props].[value]
        ,   'SCHEMA'                        AS [level0type]
        ,   SCHEMA_NAME([objs].[schema_id]) AS [level0name]
        ,   CASE [objs].[type]
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
            END                             AS [level1type]
        , [objs].[name]                   AS [level1name]
        ,   NULL                            AS [level2type]
        ,   NULL                            AS [level2name]
        ,   CASE [objs].[type]
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
            [props].[name]
        , [props].[value]
        ,   'SCHEMA'                        AS [level0type]
        ,   SCHEMA_NAME([objs].[schema_id]) AS [level0name]
        ,   CASE [objs].[type]
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
            END                             AS [level1type]
        , [objs].[name]                   AS [level1name]
        ,   'COLUMN'                        AS [level2type]
        , [cols].[name]                   AS [level2name]
        ,   'COLUMN'                        AS [basetype]
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
            [props].[name]
        , [props].[value]
        ,   'SCHEMA'                        AS [level0type]
        ,   SCHEMA_NAME([objs].[schema_id]) AS [level0name]
        ,   CASE [objs].[type]
                WHEN 'FN' THEN
                    'FUNCTION'
                WHEN 'IF' THEN
                    'FUNCTION'
                WHEN 'TF' THEN
                    'FUNCTION'
                WHEN 'P' THEN
                    'PROCEDURE'
            END                             AS [level1type]
        , [objs].[name]                   AS [level1name]
        ,   'PARAMETER'                     AS [level2type]
        , [params].[name]                 AS [level2name]
        ,   'PARAMETER'                     AS [basetype]
        FROM [sys].[extended_properties]  AS [props]
            INNER JOIN [sys].[parameters] AS [params]
                ON [props].[major_id] = [params].[object_id]
                    AND [props].[minor_id] = [params].[parameter_id]
            INNER JOIN [sys].[objects]    AS [objs]
                ON [props].[major_id] = [objs].[object_id]
        WHERE [props].[class] = 2
            AND [objs].[type] IN ('FN', 'IF', 'TF', 'P')
    ),
    [extensible_objects] AS (
        /* DATABASE */
        SELECT
            NULL AS [level0type]
        ,   NULL AS [level0name]
        ,   NULL AS [level1type]
        ,   NULL AS [level1name]
        ,   NULL AS [level2type]
        ,   NULL AS [level2name]
        UNION

        /* SCHEMA */
        SELECT
            'SCHEMA'
        ,   SCHEMA_NAME([schema_id])
        ,   NULL
        ,   NULL
        ,   NULL
        ,   NULL
        FROM [sys].[schemas]
        UNION

        /* TABLE, VIEW, FUNCTION, PROCEDURE */
        SELECT
            'SCHEMA'
        ,   SCHEMA_NAME([schema_id])
        ,   CASE [type]
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
            END
        , [name]
        ,   NULL
        ,   NULL
        FROM [sys].[objects]
        WHERE [type] IN ('U', 'V', 'FN', 'IF', 'TF', 'P')
        UNION

        /* COLUMN */
        SELECT
            'SCHEMA'
        ,   SCHEMA_NAME([objs].[schema_id])
        ,   CASE [objs].[type]
                WHEN 'IF' THEN
                    'FUNCTION'
                WHEN 'TF' THEN
                    'FUNCTION'
                WHEN 'P' THEN
                    'PROCEDURE'
                WHEN 'U' THEN
                    'TABLE'
                WHEN 'V' THEN
                    'VIEW'
            END
        , [objs].[name]
        ,   'COLUMN'
        , [cols].[name]
        FROM [sys].[columns]           AS [cols]
            INNER JOIN [sys].[objects] AS [objs]
                ON [cols].[object_id] = [objs].[object_id]
        WHERE [objs].[type] IN ('IF', 'TF', 'P', 'U', 'V')
        UNION

        /* PARAMETER */
        SELECT
            'SCHEMA'
        ,   SCHEMA_NAME([objs].[schema_id])
        ,   CASE [objs].[type]
                WHEN 'FN' THEN
                    'FUNCTION'
                WHEN 'IF' THEN
                    'FUNCTION'
                WHEN 'TF' THEN
                    'FUNCTION'
                WHEN 'P' THEN
                    'PROCEDURE'
            END
        , [objs].[name]
        ,   'PARAMETER'
        , [params].[name]
        FROM [sys].[parameters]        AS [params]
            INNER JOIN [sys].[objects] AS [objs]
                ON [params].[object_id] = [objs].[object_id]
        WHERE [objs].[type] IN ('FN', 'IF', 'TF', 'P')
    )
SELECT
    eo.level0type,
    eo.level0name,
    eo.level1type,
    eo.level1name,
    eo.level2type,
    eo.level2name,
    ep.[name],
    ep.[value],
    CASE
        WHEN eo.level2type IS NOT NULL
            THEN eo.level2type
        WHEN eo.level1type IS NOT NULL
            THEN eo.level1type
        WHEN eo.level0type IS NOT NULL
            THEN eo.level0type
        ELSE 'DATABASE'
    END AS [basetype]
FROM [extensible_objects] AS eo
LEFT JOIN [extended_properties] AS ep
    ON  (ep.level0type = eo.level0type OR (ep.level0type IS NULL AND eo.level0type IS NULL))
    AND (ep.level0name = eo.level0name OR (ep.level0name IS NULL AND eo.level0name IS NULL))
    AND (ep.level1type = eo.level1type OR (ep.level1type IS NULL AND eo.level1type IS NULL))
    AND (ep.level1name = eo.level1name OR (ep.level1name IS NULL AND eo.level1name IS NULL))
    AND (ep.level2type = eo.level2type OR (ep.level2type IS NULL AND eo.level2type IS NULL))
    AND (ep.level2name = eo.level2name OR (ep.level2name IS NULL AND eo.level2name IS NULL))
ORDER BY
    eo.level0type,
    eo.level0name,
    eo.level1type,
    eo.level1name,
    eo.level2type,
    eo.level2name,
    ep.name,
    ep.value