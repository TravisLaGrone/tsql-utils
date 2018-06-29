
/* DATABASE */
SELECT
    NULL AS [level0type]
  , NULL AS [level0name]
  , NULL AS [level1type]
  , NULL AS [level1name]
  , NULL AS [level2type]
  , NULL AS [level2name]
UNION

/* SCHEMA */
SELECT
    'SCHEMA'
  , SCHEMA_NAME([schema_id])
  , NULL
  , NULL
  , NULL
  , NULL
FROM [sys].[schemas]
UNION

/* TABLE, VIEW, FUNCTION, PROCEDURE */
SELECT
    'SCHEMA'
  , SCHEMA_NAME([schema_id])
  , CASE [type]
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
  , NULL
  , NULL
FROM [sys].[objects]
WHERE [type] IN ('U', 'V', 'FN', 'IF', 'TF', 'P')
UNION

/* COLUMN */
SELECT
    'SCHEMA'
  , SCHEMA_NAME([objs].[schema_id])
  , CASE [objs].[type]
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
  , 'COLUMN'
  , [cols].[name]
FROM [sys].[columns]           AS [cols]
    INNER JOIN [sys].[objects] AS [objs]
        ON [cols].[object_id] = [objs].[object_id]
WHERE [objs].[type] IN ('IF', 'TF', 'P', 'U', 'V')
UNION

/* PARAMETER */
SELECT
    'SCHEMA'
  , SCHEMA_NAME([objs].[schema_id])
  , CASE [objs].[type]
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
  , 'PARAMETER'
  , [params].[name]
FROM [sys].[parameters]        AS [params]
    INNER JOIN [sys].[objects] AS [objs]
        ON [params].[object_id] = [objs].[object_id]
WHERE [objs].[type] IN ('FN', 'IF', 'TF', 'P')
ORDER BY
    eo.level0type,
    eo.level0name,
    eo.level1type,
    eo.level1name,
    eo.level2type,
    eo.level2name