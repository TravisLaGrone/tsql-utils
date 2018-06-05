-- OBJECT
-- TYPE
-- XML_SCHEMA_COLLECTION
-- PARTITION_FUNCTION

WITH
    ref_obj AS (
        SELECT
            @@SERVERNAME AS [referenced_server_name],
            DB_NAME() AS [referenced_database_name],
            [sch].[name] AS [referenced_schema_name],
            [obj].[name] AS [referenced_entity_name],
            @@SERVERNAME AS [referencing_server_name],
            DB_NAME() AS [referencing_database_name],
            [ref].[referencing_schema_name],
            [ref].[referencing_entity_name],
            [obj].[type_desc] AS [referenced_entity_class_desc],
            [ref].[referencing_class_desc] AS [referencing_entity_class_desc],  -- FIXME (do for other query too)
            [ref].[is_caller_dependent]
        FROM [sys].[objects] obj
            INNER JOIN [sys].[schemas] sch
                ON  [sch].[schema_id] = [obj].[schema_id]
            CROSS APPLY [sys].[dm_sql_referencing_entities]([sch].[name] + '.' + [obj].[name], 'OBJECT') AS ref
    ),
    ref_type AS (
        SELECT
            @@SERVERNAME AS [referenced_server_name],
            DB_NAME() AS [referenced_database_name],
            [sch].[name] AS [referenced_schema_name],
            [typ].[name] AS [referenced_entity_name],
            @@SERVERNAME AS [referencing_server_name],
            DB_NAME() AS [referencing_database_name],
            [ref].[referencing_schema_name],
            [ref].[referencing_entity_name],
            'TYPE' AS [referenced_entity_class_desc],
            [ref].[referencing_class_desc] AS [referencing_entity_class_desc],  -- FIXME (do for other query too)
            [ref].[is_caller_dependent]
        FROM [sys].[types] typ
            INNER JOIN [sys].[schemas] sch
                ON  [sch].[schema_id] = [typ].[schema_id]
            CROSS APPLY [sys].[dm_sql_referencing_entities]([sch].[name] + '.' + [typ].[name], 'OBJECT') AS ref
    ),