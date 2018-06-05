WITH
    ref_obj AS (
        SELECT
            @@SERVERNAME AS [server_name],
            DB_NAME() AS [database_name],
            sch.[name] AS referenced_schema_name,
            obj.[name] AS referenced_entity_name,
            ref.referencing_schema_name,
            ref.referencing_entity_name,
            'OBJECT' AS referenced_class_desc,
            ref.referencing_class_desc,
            obj.[type_desc] AS referenced_object_type_desc,
            ref.referencing_id,  -- temporary placeholder to compute [referencing_object_type_desc] later
            ref.is_caller_dependent
        FROM sys.objects AS obj
            INNER JOIN sys.schemas AS sch
                ON  sch.[schema_id] = obj.[schema_id]
            CROSS APPLY sys.dm_sql_referencing_entities(sch.[name] + '.' + obj.[name], 'OBJECT') AS ref
            LEFT JOIN sys.objects AS ref_obj
                ON  ref_obj.[object_id] = ref.referencing_id
            LEFT JOIN sys.triggers          AS ref_trg
                ON  ref_trg.[object_id]     = ref.referencing_id
            LEFT JOIN sys.server_triggers   AS ref_srv_trg
                ON  ref_srv_trg.[object_id] = ref.referencing_id
    ),
    ref_typ AS (
        SELECT
            @@SERVERNAME AS [server_name],
            DB_NAME() AS [database_name],
            sch.[name] AS referenced_schema_name,
            typ.[name] AS referenced_entity_name,
            ref.referencing_schema_name,
            ref.referencing_entity_name,
            'TYPE' AS referenced_class_desc,
            ref.referencing_class_desc,
            NULL AS referenced_object_type_desc,
            ref.referencing_id,  -- temporary placeholder to compute [referencing_object_type_desc] later
            ref.is_caller_dependent
        FROM sys.types typ
            INNER JOIN sys.schemas AS sch
                ON  sch.[schema_id] = typ.[schema_id]
            CROSS APPLY sys.dm_sql_referencing_entities(sch.[name] + '.' + typ.[name], 'TYPE') AS ref
            LEFT JOIN sys.objects AS ref_obj
                ON  ref_obj.[object_id] = ref.referencing_id
            LEFT JOIN sys.triggers          AS ref_trg
                ON  ref_trg.[object_id]     = ref.referencing_id
            LEFT JOIN sys.server_triggers   AS ref_srv_trg
                ON  ref_srv_trg.[object_id] = ref.referencing_id
    ),
    ref_xsc AS (
        SELECT
            @@SERVERNAME AS [server_name],
            DB_NAME() AS [database_name],
            sch.[name] AS referenced_schema_name,
            xsc.[name] AS referenced_entity_name,
            ref.referencing_schema_name,
            ref.referencing_entity_name,
            'XML_SCHEMA_COLLECTION' AS referenced_class_desc,
            ref.referencing_class_desc,
            NULL AS referenced_object_type_desc,
            ref.referencing_id,  -- temporary placeholder to compute [referencing_object_type_desc] later
            ref.is_caller_dependent
        FROM sys.xml_schema_collections xsc
            INNER JOIN sys.schemas AS sch
                ON  sch.[schema_id] = xsc.[schema_id]
            CROSS APPLY sys.dm_sql_referencing_entities(sch.[name] + '.' + xsc.[name], 'XML_SCHEMA_COLLECTION') AS ref
            LEFT JOIN sys.objects           AS ref_obj
                ON  ref_obj.[object_id]     = ref.referencing_id
            LEFT JOIN sys.triggers          AS ref_trg
                ON  ref_trg.[object_id]     = ref.referencing_id
            LEFT JOIN sys.server_triggers   AS ref_srv_trg
                ON  ref_srv_trg.[object_id] = ref.referencing_id
    ),
    ref_par AS (
        SELECT
            @@SERVERNAME AS [server_name],
            DB_NAME() AS [database_name],
            NULL AS referenced_schema_name,
            par.[name] AS referenced_entity_name,
            ref.referencing_schema_name,
            ref.referencing_entity_name,
            'PARTITION_FUNCTION' AS referenced_class_desc,
            ref.referencing_class_desc,
            NULL AS referenced_object_type_desc,
            ref.referencing_id,  -- temporary placeholder to compute [referencing_object_type_desc] later
            ref.is_caller_dependent
        FROM sys.partition_functions par
            CROSS APPLY sys.dm_sql_referencing_entities(par.[name], 'PARTITION_FUNCTION') AS ref
            LEFT JOIN sys.objects AS ref_obj
                ON  ref_obj.[object_id] = ref.referencing_id
            LEFT JOIN sys.triggers          AS ref_trg
                ON  ref_trg.[object_id]     = ref.referencing_id
            LEFT JOIN sys.server_triggers   AS ref_srv_trg
                ON  ref_srv_trg.[object_id] = ref.referencing_id
    ),
    ref AS (
        SELECT * FROM ref_obj
        UNION ALL
        SELECT * FROM ref_typ
        UNION ALL
        SELECT * FROM ref_xsc
        UNION ALL
        SELECT * FROM ref_par
    )
SELECT
    ref.[server_name],
    ref.[database_name],
    ref.referenced_schema_name,
    ref.referenced_entity_name,
    ref.referencing_schema_name,
    ref.referencing_entity_name,
    ref.referenced_class_desc,
    CASE ref.referencing_class_desc
        WHEN 'OBJECT_OR_COLUMN' THEN
            'OBJECT'
        ELSE
            ref.referencing_class_desc
    END AS referencing_class_desc,
    ref.referenced_object_type_desc,
    CASE ref.referencing_class_desc
        WHEN 'OBJECT_OR_COLUMN' THEN
            ref_obj.[type_desc]
        WHEN 'DATABASE_DDL_TRIGGER' THEN
            ref_trg.[type_desc]
        WHEN 'SERVER_DDL_TRIGGER' THEN
            ref_srv_trg.[type_desc]
        ELSE
            NULL  -- this should never happen
    END AS referencing_object_type_desc,
    ref.is_caller_dependent
FROM ref
    LEFT JOIN sys.objects           AS ref_obj
        ON  ref_obj.[object_id]     = ref.referencing_id
    LEFT JOIN sys.triggers          AS ref_trg
        ON  ref_trg.[object_id]     = ref.referencing_id
    LEFT JOIN sys.server_triggers   AS ref_srv_trg
        ON  ref_srv_trg.[object_id] = ref.referencing_id
ORDER BY
    ref.[server_name],
    ref.[database_name],
    ref.[referenced_schema_name],
    ref.[referenced_entity_name],
    ref.[referencing_schema_name],
    ref.[referencing_entity_name]
