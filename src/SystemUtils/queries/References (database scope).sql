WITH
    referenced_obj AS (
        SELECT
            @@SERVERNAME AS referencing_server_name,
            DB_NAME() AS referencing_database_name,
            sch.[name] AS referencing_schema_name,
            obj.[name] AS referencing_entity_name,
            CASE WHEN ref.referencing_minor_id = 0 THEN NULL ELSE ref_col.[name] END AS referencing_minor_name,
            ref.referenced_server_name,
            ref.referenced_database_name,
            ref.referenced_schema_name,
            ref.referenced_entity_name,
            ref.referenced_minor_name,
            'OBJECT' AS referencing_class_desc,
            obj.type_desc AS referencing_object_type_desc,
            CASE WHEN ref.referencing_minor_id = 0 THEN NULL ELSE 'COLUMN' END AS referencing_minor_class_desc,
            ref.referenced_class_desc,
            ref.referenced_id,  -- temporary placeholder to compute [referenced_object_type_desc] later
            ref.is_caller_dependent,
            ref.is_ambiguous,
            ref.is_selected,
            ref.is_updated,
            ref.is_select_all,
            ref.is_all_columns_found
        FROM sys.objects AS obj
            INNER JOIN sys.schemas AS sch
                ON  sch.[schema_id]             = obj.[schema_id]
            CROSS APPLY sys.dm_sql_referenced_entities(sch.[name] + '.' + obj.[name], 'OBJECT') AS ref
            LEFT JOIN sys.objects                   AS ref_obj
                ON  ref_obj.[object_id]         = ref.referenced_id
            LEFT JOIN sys.columns                   AS ref_col
                ON  ref_col.[object_id]         = obj.[object_id]
                AND ref_col.column_id         = ref.referencing_minor_id
    ),
    referenced_db_ddl_trg AS (
        SELECT
            @@SERVERNAME AS referencing_server_name,
            DB_NAME() AS referencing_database_name,
            NULL AS referencing_schema_name,
            trg.[name] AS referencing_entity_name,
            NULL AS referencing_minor_name,
            ref.referenced_server_name,
            ref.referenced_database_name,
            ref.referenced_schema_name,
            ref.referenced_entity_name,
            ref.referenced_minor_name,
            'DATABASE_DDL_TRIGGER' AS referencing_class_desc,
            trg.type_desc AS referencing_object_type_desc,
            NULL AS referencing_minor_class_desc,
            ref.referenced_class_desc,
            ref.referenced_id,  -- temporary placeholder to compute [referenced_object_type_desc] later
            ref.is_caller_dependent,
            ref.is_ambiguous,
            ref.is_selected,
            ref.is_updated,
            ref.is_select_all,
            ref.is_all_columns_found
        FROM sys.triggers AS trg
            CROSS APPLY sys.dm_sql_referenced_entities(trg.[name], 'DATABASE_DDL_TRIGGER') AS ref
            LEFT JOIN sys.objects                   AS ref_obj
                ON  ref_obj.[object_id]         = ref.referenced_id
        WHERE trg.parent_class = 0  -- database (for DDL)
    ),
    referenced_srv_ddl_trg AS (
        SELECT
            @@SERVERNAME AS referencing_server_name,
            NULL AS referencing_database_name,
            NULL AS referencing_schema_name,
            trg.[name] AS referencing_entity_name,
            NULL AS referencing_minor_name,
            ref.referenced_server_name,
            ref.referenced_database_name,
            ref.referenced_schema_name,
            ref.referenced_entity_name,
            ref.referenced_minor_name,
            'SERVER_DDL_TRIGGER' AS referencing_class_desc,
            trg.type_desc AS referencing_object_type_desc,
            NULL AS referencing_minor_class_desc,
            ref.referenced_class_desc,
            ref.referenced_id,  -- temporary placeholder to compute [referenced_object_type_desc] later
            ref.is_caller_dependent,
            ref.is_ambiguous,
            ref.is_selected,
            ref.is_updated,
            ref.is_select_all,
            ref.is_all_columns_found
        FROM sys.server_triggers AS trg
            CROSS APPLY sys.dm_sql_referenced_entities(trg.[name], 'SERVER_DDL_TRIGGER') AS ref
            LEFT JOIN sys.objects AS ref_obj
                ON  ref_obj.[object_id] = ref.referenced_id
    ),
    referenced_all AS (
        SELECT * FROM referenced_obj
        UNION ALL
        SELECT * FROM referenced_db_ddl_trg
        UNION ALL
        SELECT * FROM referenced_srv_ddl_trg
    ),
    referenced AS (
        SELECT
            referenced_all.referencing_server_name,
            referenced_all.referencing_database_name,
            referenced_all.referencing_schema_name,
            referenced_all.referencing_entity_name,
            referenced_all.referencing_minor_name,
            referenced_all.referenced_server_name,
            referenced_all.referenced_database_name,
            referenced_all.referenced_schema_name,
            referenced_all.referenced_entity_name,
            referenced_all.referenced_minor_name,
            referenced_all.referencing_class_desc,
            referenced_all.referencing_minor_class_desc,
            CASE WHEN referenced_all.referenced_class_desc = 'OBJECT_OR_COLUMN' THEN 'OBJECT'          ELSE referenced_all.referenced_class_desc END AS referenced_class_desc,
            CASE WHEN referenced_all.referenced_minor_name IS NOT NULL          THEN 'COLUMN'          ELSE NULL                                 END AS referenced_minor_class_desc,
            referenced_all.referencing_object_type_desc,
            CASE WHEN referenced_all.referenced_class_desc = 'OBJECT_OR_COLUMN' THEN ref_obj.type_desc ELSE NULL                                 END AS referenced_object_type_desc,
            referenced_all.is_caller_dependent,
            referenced_all.is_ambiguous,
            referenced_all.is_selected,
            referenced_all.is_updated,
            referenced_all.is_select_all,
            referenced_all.is_all_columns_found AS is_all_referenced_columns_found_for_entity
        FROM referenced_all
            LEFT JOIN sys.objects AS ref_obj
                ON  ref_obj.[object_id] = referenced_all.referenced_id
    ),
    referencing_obj AS (
        SELECT
            @@SERVERNAME AS [server_name],
            DB_NAME() AS [database_name],
            sch.[name] AS referenced_schema_name,
            obj.[name] AS referenced_entity_name,
            ref.referencing_schema_name,
            ref.referencing_entity_name,
            'OBJECT' AS referenced_class_desc,
            ref.referencing_class_desc,
            obj.type_desc AS referenced_object_type_desc,
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
    referencing_typ AS (
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
    referencing_xsc AS (
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
    referencing_par AS (
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
    referencing_all AS (
        SELECT * FROM referencing_obj
        UNION ALL
        SELECT * FROM referencing_typ
        UNION ALL
        SELECT * FROM referencing_xsc
        UNION ALL
        SELECT * FROM referencing_par
    ),
    referencing AS (
        SELECT
            referencing_all.[server_name] AS referenced_server_name,
            referencing_all.[database_name] AS referenced_database_name,
            referencing_all.referenced_schema_name,
            referencing_all.referenced_entity_name,
            referencing_all.[server_name] AS referencing_server_name,
            referencing_all.[database_name] AS referencing_database_name,
            referencing_all.referencing_schema_name,
            referencing_all.referencing_entity_name,
            referencing_all.referenced_class_desc,
            CASE referencing_all.referencing_class_desc WHEN 'OBJECT_OR_COLUMN' THEN 'OBJECT' ELSE referencing_all.referencing_class_desc END AS referencing_class_desc,
            referencing_all.referenced_object_type_desc,
            CASE referencing_all.referencing_class_desc
                WHEN 'OBJECT_OR_COLUMN' THEN
                    ref_obj.type_desc
                WHEN 'DATABASE_DDL_TRIGGER' THEN
                    ref_trg.type_desc
                WHEN 'SERVER_DDL_TRIGGER' THEN
                    ref_srv_trg.type_desc
                ELSE
                    NULL  -- this should never happen
            END AS referencing_object_type_desc,
            referencing_all.is_caller_dependent
        FROM referencing_all
            LEFT JOIN sys.objects           AS ref_obj
                ON  ref_obj.[object_id]     = referencing_all.referencing_id
            LEFT JOIN sys.triggers          AS ref_trg
                ON  ref_trg.[object_id]     = referencing_all.referencing_id
            LEFT JOIN sys.server_triggers   AS ref_srv_trg
                ON  ref_srv_trg.[object_id] = referencing_all.referencing_id
    )
SELECT
    rd.referencing_server_name,
    rd.referencing_database_name,
    rd.referencing_schema_name,
    rd.referencing_entity_name,
    rd.referencing_minor_name,

    rd.referenced_server_name,
    rd.referenced_database_name,
    rd.referenced_schema_name,
    rd.referenced_entity_name,
    rd.referenced_minor_name,

    rd.referencing_class_desc,
    rd.referencing_minor_class_desc,
    rd.referenced_class_desc,
    rd.referenced_minor_class_desc,

    rd.referencing_object_type_desc,
    rd.referenced_object_type_desc,

    rd.is_caller_dependent,
    rd.is_ambiguous,
    rd.is_selected,
    rd.is_updated,
    rd.is_select_all,
    rd.is_all_referenced_columns_found_for_entity
FROM referenced rd
UNION
SELECT
    -- TODO

    rg.referenced_server_name,
    rg.referenced_database_name,

    rg.referenced_schema_name,
    rg.referenced_entity_name,

    rg.referencing_schema_name,
    rg.referencing_entity_name,

    rg.referenced_class_desc,
    rg.referencing_class_desc,

    rg.referenced_object_type_desc,
    rg.referencing_object_type_desc,

    rg.is_caller_dependent
FROM referencing rg
WHERE NOT EXISTS(  -- same (server, database, schema, entity)
        SELECT *
        FROM referenced _rd
        WHERE
            (  -- servers match
                (_rd.referenced_server_name IS NULL AND rg.referenced_server_name IS NULL)  -- both null
                OR _rd.referenced_server_name = rg.referenced_server_name  -- both equal
                OR (_rd.referenced_server_name IS NULL AND _rd.referencing_server_name = rg.referenced_server_name)  -- referenced server is omitted because just same as referencing server
            )
            AND (  -- databases match
                (_rd.referenced_database_name IS NULL AND rg.referenced_database_name IS NULL)  -- both null
                OR _rd.referenced_database_name = rg.referenced_database_name  -- both equal
                OR (_rd.referenced_database_name IS NULL AND _rd.referencing_database_name = rg.referenced_database_name)  -- referenced database is omitted because just same as referencing database
            )
            AND (  -- schemas match
                (_rd.referenced_schema_name IS NULL AND rg.referenced_schema_name IS NULL)  -- both null
                OR _rd.referenced_schema_name = rg.referenced_schema_name  -- both equal
                OR (_rd.referenced_schema_name IS NULL AND _rd.referencing_schema_name = rg.referenced_schema_name)  -- referenced schema is omitted because just same as referencing schema
            )
            AND _rd.referenced_entity_name = rg.referenced_entity_name
            -- QUESTION:  do I need to match on entity "class_desc" as well?
    )