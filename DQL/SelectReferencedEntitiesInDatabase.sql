/* NOTE:
 *     Nullity of r"referenced_(server|database|schema)_name" *does* indicate whether it is specified in the
 * reference, and not whether the r"referencing_(server|database|schema)_name" is the same.  If the referenced
 * is null, then it must be the same because it is not specified in the reference.  However, if the reference
 * is non-null, then it may or may not be the same, but it is definitely explicitly specified in the reference.
 */
/* NOTE:
 *     It is **NOT** necessarily true that for every entity for which there exists a row with a non-null minor
 * name, there also exists a row with a null minor name, or vice-versa.  It appears that a reference is
 * considered to be a lexical identification of an entity or a minor, rather than a logical reference to or
 * physical access of an entity or its minor as would be implied by a lexical T-SQL definition.
 */
/* NOTE:  Referenced entities include all classes except triggers.
 */
WITH
    ref_obj AS (
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
            obj.[type_desc] AS referencing_object_type_desc,
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
    ref_db_ddl_trg AS (
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
            trg.[type_desc] AS referencing_object_type_desc,
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
    ref_srv_ddl_trg AS (
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
            trg.[type_desc] AS referencing_object_type_desc,
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
    ref AS (
        SELECT * FROM [ref_obj]
        UNION ALL
        SELECT * FROM [ref_db_ddl_trg]
        UNION ALL
        SELECT * FROM [ref_srv_ddl_trg]
    )
SELECT
    ref.referencing_server_name,
    ref.referencing_database_name,
    ref.referencing_schema_name,
    ref.referencing_entity_name,
    ref.referencing_minor_name,
    ref.referenced_server_name,
    ref.referenced_database_name,
    ref.referenced_schema_name,
    ref.referenced_entity_name,
    ref.referenced_minor_name,
    ref.referencing_class_desc,
    ref.referencing_minor_class_desc,
    CASE WHEN ref.referenced_class_desc = 'OBJECT_OR_COLUMN' THEN 'OBJECT'            ELSE ref.referenced_class_desc END AS referenced_class_desc,
    CASE WHEN ref.referenced_minor_name IS NOT NULL          THEN 'COLUMN'            ELSE NULL                      END AS referenced_minor_class_desc,
    ref.referencing_object_type_desc,
    CASE WHEN ref.referenced_class_desc = 'OBJECT_OR_COLUMN' THEN ref_obj.[type_desc] ELSE NULL                      END AS referenced_object_type_desc,
    ref.is_caller_dependent,
    ref.is_ambiguous,
    ref.is_selected,
    ref.is_updated,
    ref.is_select_all,
    ref.is_all_columns_found AS is_all_columns_found_entity
FROM ref
    LEFT JOIN sys.objects AS ref_obj
        ON  ref_obj.[object_id] = ref.referenced_id
ORDER BY
    ref.referencing_server_name,
    ref.referencing_database_name,
    ref.referencing_schema_name,
    ref.referencing_entity_name,
    ref.referencing_minor_name,
    ref.referenced_server_name,
    ref.referenced_database_name,
    ref.referenced_schema_name,
    ref.referenced_entity_name,
    ref.referenced_minor_name
