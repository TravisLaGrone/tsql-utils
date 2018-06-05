WITH
    ref_obj AS (
        SELECT
            @@SERVERNAME AS [referencing_server_name],
            DB_NAME() AS [referencing_database_name],
            sch.[name] AS [referencing_schema_name],
            obj.name AS [referencing_entity_name],
            CASE WHEN ref.[referencing_minor_id] = 0 THEN NULL ELSE col.name END AS [referencing_minor_name],
            [ref].[referenced_server_name],
            [ref].[referenced_database_name],
            [ref].[referenced_schema_name],
            [ref].[referenced_entity_name],
            [ref].[referenced_minor_name],
            obj.type_desc AS [referencing_entity_class_desc],
            CASE WHEN ref.[referencing_minor_id] = 0 THEN NULL ELSE 'COLUMN' END AS [referencing_minor_class_desc],
            [obj].[type_desc] AS [referenced_entity_class_desc],
            CASE WHEN ref.[referenced_minor_name] IS NULL THEN NULL ELSE 'COLUMN' END AS [referenced_minor_class_desc],
            [ref].[is_caller_dependent],
            [ref].[is_ambiguous],
            [ref].[is_selected],
            [ref].[is_updated],
            [ref].[is_select_all],
            [ref].[is_all_columns_found]
        FROM sys.objects obj
            INNER JOIN sys.schemas sch
                ON  sch.[schema_id] = obj.[schema_id]
            CROSS APPLY sys.[dm_sql_referenced_entities](sch.name + '.' + obj.[name], 'OBJECT') ref
            LEFT JOIN sys.columns col
                ON  col.[object_id] = obj.[object_id]
                AND col.[column_id] = ref.[referencing_minor_id]
    ),
    ref_db_ddl_trg AS (
        SELECT
            @@SERVERNAME AS [referencing_server_name],
            DB_NAME() AS [referencing_database_name],
            NULL AS [referencing_schema_name],
            trg.name AS [referencing_entity_name],
            NULL AS [referencing_minor_name],
            [ref].[referenced_server_name],
            [ref].[referenced_database_name],
            [ref].[referenced_schema_name],
            [ref].[referenced_entity_name],
            [ref].[referenced_minor_name],
            trg.[type_desc] AS [referencing_entity_class_desc],
            NULL AS [referencing_minor_class_desc],
            [trg].[type_desc] AS [referenced_entity_class_desc],
            CASE WHEN ref.[referenced_minor_name] IS NULL THEN NULL ELSE 'COLUMN' END AS [referenced_minor_class_desc],
            [ref].[is_caller_dependent],
            [ref].[is_ambiguous],
            [ref].[is_selected],
            [ref].[is_updated],
            [ref].[is_select_all],
            [ref].[is_all_columns_found]
        FROM sys.triggers trg
            CROSS APPLY sys.[dm_sql_referenced_entities](trg.[name], 'DATABASE_DDL_TRIGGER') ref
        WHERE trg.[parent_class] = 0  -- database (for DDL)
    ),
    ref_srv_ddl_trg AS (
        SELECT
            @@SERVERNAME AS [referencing_server_name],
            NULL AS [referencing_database_name],
            NULL AS [referencing_schema_name],
            trg.name AS [referencing_entity_name],
            NULL AS [referencing_minor_name],
            [ref].[referenced_server_name],
            [ref].[referenced_database_name],
            [ref].[referenced_schema_name],
            [ref].[referenced_entity_name],
            [ref].[referenced_minor_name],
            trg.[type_desc] AS [referencing_entity_class_desc],
            NULL AS [referencing_minor_class_desc],
            [trg].[type_desc] AS [referenced_entity_class_desc],
            CASE WHEN ref.[referenced_minor_name] IS NULL THEN NULL ELSE 'COLUMN' END AS [referenced_minor_class_desc],
            [ref].[is_caller_dependent],
            [ref].[is_ambiguous],
            [ref].[is_selected],
            [ref].[is_updated],
            [ref].[is_select_all],
            [ref].[is_all_columns_found]
        FROM sys.[server_triggers] trg
            CROSS APPLY sys.[dm_sql_referenced_entities](trg.[name], 'SERVER_DDL_TRIGGER') ref
    ),
    ref AS (
        SELECT * FROM [ref_obj]
        UNION ALL
        SELECT * FROM [ref_db_ddl_trg]
        UNION ALL
        SELECT * FROM [ref_srv_ddl_trg]
    )
SELECT *
FROM ref
ORDER BY
    ref.[referencing_server_name],
    ref.[referencing_database_name],
    ref.[referencing_schema_name],
    ref.[referencing_entity_name],
    ref.[referencing_minor_name],
    ref.[referenced_server_name],
    ref.[referenced_database_name],
    ref.[referenced_schema_name],
    ref.[referenced_entity_name],
    ref.[referenced_minor_name]
