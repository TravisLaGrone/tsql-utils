

IF OBJECT_ID('tempdb..#COMMON_EXTENSIBLE_OBJECTS') IS NOT NULL
    DROP TABLE #COMMON_EXTENSIBLE_OBJECTS;

CREATE TABLE #COMMON_EXTENSIBLE_OBJECTS (
      level0type    VARCHAR(128)    NULL DEFAULT NULL
    , level0name    sysname         NULL DEFAULT NULL
    , level1type    VARCHAR(128)    NULL DEFAULT NULL
    , level1name    sysname         NULL DEFAULT NULL
    , level2type    VARCHAR(128)    NULL DEFAULT NULL 
    , level2name    sysname         NULL DEFAULT NULL
);



INSERT INTO #COMMON_EXTENSIBLE_OBJECTS (level0type, level0name, level1type, level1name, level2type, level2name)

    /* DATABASE */
    SELECT NULL, NULL, NULL, NULL, NULL, NULL

UNION

    /* SCHEMA */
    SELECT
          'SCHEMA'
        , SCHEMA_NAME(schema_id)
        , NULL
        , NULL
        , NULL
        , NULL
    FROM sys.schemas

UNION

    /* TABLE, VIEW, FUNCTION, PROCEDURE */
    SELECT
          'SCHEMA'
        , SCHEMA_NAME(schema_id)
        , CASE type
            WHEN 'U'  THEN 'TABLE'
            WHEN 'V'  THEN 'VIEW'
            WHEN 'FN' THEN 'FUNCTION'
            WHEN 'IF' THEN 'FUNCTION'
            WHEN 'TF' THEN 'FUNCTION'
            WHEN 'P'  THEN 'PROCEDURE'
            END
        , name
        , NULL
        , NULL
    FROM sys.objects
    WHERE type IN ('U', 'V', 'FN', 'IF', 'TF', 'P')

UNION

    /* COLUMN */
    SELECT
          'SCHEMA'
        , SCHEMA_NAME(objs.schema_id)
        , CASE objs.type
            WHEN 'IF' THEN 'FUNCTION'
            WHEN 'TF' THEN 'FUNCTION'
            WHEN 'P'  THEN 'PROCEDURE'
            WHEN 'U'  THEN 'TABLE'
            WHEN 'V'  THEN 'VIEW'
            END
        , objs.name
        , 'COLUMN'
        , cols.name
    FROM sys.columns AS cols
    INNER JOIN sys.objects AS objs
        ON cols.object_id = objs.object_id
    WHERE objs.type IN ('IF', 'TF', 'P', 'U', 'V')

UNION

    /* PARAMETER */
    SELECT
          'SCHEMA'
        , SCHEMA_NAME(objs.schema_id)
        , CASE objs.type
            WHEN 'FN' THEN 'FUNCTION'
            WHEN 'IF' THEN 'FUNCTION'
            WHEN 'TF' THEN 'FUNCTION'
            WHEN 'P'  THEN 'PROCEDURE'
            END
        , objs.name
        , 'PARAMETER'
        , params.name
    FROM sys.parameters AS params
    INNER JOIN sys.objects AS objs
        ON params.object_id = objs.object_id
    WHERE objs.type IN ('FN', 'IF', 'TF', 'P')
;
