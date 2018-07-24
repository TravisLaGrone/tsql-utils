SELECT
    par_sch.[name]          AS parent_schema_name,
    par_sch.[schema_id]     AS parent_schema_id,
    par_sch.[principal_id]  AS parent_schema_principal_id,

    par_obj.[name]              AS parent_object_name,
    par_obj.[object_id]         AS parent_object_id,
    par_obj.[principal_id]      AS parent_object_principal_id,
    par_obj.parent_object_id    AS parent_object_parent_object_id,
    par_obj.[type]              AS parent_object_type,
    par_obj.[type_desc]         AS parent_object_type_desc,
    par_obj.create_date         AS parent_object_create_date,
    par_obj.modify_date         AS parent_object_modify_date,
    par_obj.is_ms_shipped       AS parent_object_is_ms_shipped,
    par_obj.is_published        AS parent_object_is_published,
    par_obj.is_schema_published AS parent_object_is_schema_published,

    par_col.[name]                  AS parent_column_name,
    par_col.column_id               AS parent_column_id,
    par_col.max_length              AS parent_column_max_length,
    par_col.[precision]             AS parent_column_precision,
    par_col.scale                   AS parent_column_scale,
    par_col.collation_name          AS parent_column_collation_name,
    par_col.is_nullable             AS parent_column_is_nullable,
    par_col.is_ansi_padded          AS parent_column_is_ansi_padded,
    par_col.is_rowguidcol           AS parent_column_is_rowguidcol,
    par_col.is_identity             AS parent_column_is_identity,
    par_col.is_computed             AS parent_column_is_computed,
    par_col.is_filestream           AS parent_column_is_filestream,
    par_col.is_replicated           AS parent_column_is_replicated,
    par_col.is_non_sql_subscribed   AS parent_column_is_non_sql_subscribed,
    par_col.is_merge_published      AS parent_column_is_merge_published,
    par_col.is_dts_replicated       AS parent_column_is_dts_replicated,
    par_col.is_xml_document         AS parent_column_is_xml_document,
    par_col.xml_collection_id       AS parent_column_xml_collection_id,
    par_col.default_object_id       AS parent_column_default_object_id,
    par_col.rule_object_id          AS parent_column_rule_object_id,
    par_col.is_sparse               AS parent_column_is_sparse,
    par_col.is_column_set           AS parent_column_is_column_set,

    par_typ.[name]              AS parent_column_type_name,
    par_typ.system_type_id      AS parent_column_type_system_id,
    par_typ.user_type_id        AS parent_column_type_user_id,
    par_typ.[schema_id]         AS parent_column_type_schema_id,
    par_typ.[principal_id]      AS parent_column_type_principal_id,
    par_typ.max_length          AS parent_column_type_max_length,
    par_typ.[precision]         AS parent_column_type_precision,
    par_typ.scale               AS parent_column_type_scale,
    par_typ.collation_name      AS parent_column_type_collation_name,
    par_typ.is_nullable         AS parent_column_type_is_nullable,
    par_typ.is_user_defined     AS parent_column_type_is_user_defined,
    par_typ.is_assembly_type    AS parent_column_type_is_assembly_type,
    par_typ.default_object_id   AS parent_column_type_default_object_id,
    par_typ.rule_object_id      AS parent_column_type_rule_object_id,

    CONVERT(nvarchar(MAX), par_ep_col.[value]) AS parent_column_MS_Description,

    ref_sch.[name]          AS referenced_schema_name,
    ref_sch.[schema_id]     AS referenced_schema_id,
    ref_sch.[principal_id]  AS referenced_schema_principal_id,

    ref_obj.[name]              AS referenced_object_name,
    ref_obj.[object_id]         AS referenced_object_id,
    ref_obj.[principal_id]      AS referenced_object_principal_id,
    ref_obj.parent_object_id    AS referenced_object_parent_object_id,
    ref_obj.[type]              AS referenced_object_type,
    ref_obj.[type_desc]         AS referenced_object_type_desc,
    ref_obj.create_date         AS referenced_object_create_date,
    ref_obj.modify_date         AS referenced_object_modify_date,
    ref_obj.is_ms_shipped       AS referenced_object_is_ms_shipped,
    ref_obj.is_published        AS referenced_object_is_published,
    ref_obj.is_schema_published AS referenced_object_is_schema_published,

    ref_col.[name]                  AS referenced_column_name,
    ref_col.column_id               AS referenced_column_id,
    ref_col.max_length              AS referenced_column_max_length,
    ref_col.[precision]             AS referenced_column_precision,
    ref_col.scale                   AS referenced_column_scale,
    ref_col.collation_name          AS referenced_column_collation_name,
    ref_col.is_nullable             AS referenced_column_is_nullable,
    ref_col.is_ansi_padded          AS referenced_column_is_ansi_padded,
    ref_col.is_rowguidcol           AS referenced_column_is_rowguidcol,
    ref_col.is_identity             AS referenced_column_is_identity,
    ref_col.is_computed             AS referenced_column_is_computed,
    ref_col.is_filestream           AS referenced_column_is_filestream,
    ref_col.is_replicated           AS referenced_column_is_replicated,
    ref_col.is_non_sql_subscribed   AS referenced_column_is_non_sql_subscribed,
    ref_col.is_merge_published      AS referenced_column_is_merge_published,
    ref_col.is_dts_replicated       AS referenced_column_is_dts_replicated,
    ref_col.is_xml_document         AS referenced_column_is_xml_document,
    ref_col.xml_collection_id       AS referenced_column_xml_collection_id,
    ref_col.default_object_id       AS referenced_column_default_object_id,
    ref_col.rule_object_id          AS referenced_column_rule_object_id,
    ref_col.is_sparse               AS referenced_column_is_sparse,
    ref_col.is_column_set           AS referenced_column_is_column_set,

    ref_typ.[name]              AS referenced_column_type_name,
    ref_typ.system_type_id      AS referenced_column_type_system_id,
    ref_typ.user_type_id        AS referenced_column_type_user_id,
    ref_typ.[schema_id]         AS referenced_column_type_schema_id,
    ref_typ.[principal_id]      AS referenced_column_type_principal_id,
    ref_typ.max_length          AS referenced_column_type_max_length,
    ref_typ.[precision]         AS referenced_column_type_precision,
    ref_typ.scale               AS referenced_column_type_scale,
    ref_typ.collation_name      AS referenced_column_type_collation_name,
    ref_typ.is_nullable         AS referenced_column_type_is_nullable,
    ref_typ.is_user_defined     AS referenced_column_type_is_user_defined,
    ref_typ.is_assembly_type    AS referenced_column_type_is_assembly_type,
    ref_typ.default_object_id   AS referenced_column_type_default_object_id,
    ref_typ.rule_object_id      AS referenced_column_type_rule_object_id,

    CONVERT(nvarchar(MAX), ref_ep_col.[value]) AS referenced_column_MS_Description

FROM sys.foreign_key_columns AS fkc

    INNER JOIN sys.columns AS par_col
        ON  par_col.[object_id] = fkc.parent_object_id
        AND par_col.column_id = fkc.parent_column_id
    INNER JOIN sys.types AS par_typ
        ON  par_typ.user_type_id = par_col.user_type_id
    INNER JOIN sys.objects AS par_obj
        ON  par_obj.[object_id] = par_col.[object_id]
    INNER JOIN sys.schemas AS par_sch
        ON  par_sch.[schema_id] = par_obj.[schema_id]
    OUTER APPLY sys.fn_listextendedproperty(
            'MS_Description',
            'SCHEMA',
            par_sch.[name],
            'TABLE',  -- ASSUMPTION: only tables may have foreign keys
            par_obj.[name],
            'COLUMN',
            par_col.[name]
        ) AS par_ep_col

    INNER JOIN sys.columns AS ref_col
        ON  ref_col.[object_id] = fkc.referenced_object_id
        AND ref_col.column_id = fkc.referenced_column_id
    INNER JOIN sys.types AS ref_typ
        ON  ref_typ.user_type_id = ref_col.user_type_id
    INNER JOIN sys.objects AS ref_obj
        ON  ref_obj.[object_id] = ref_col.[object_id]
    INNER JOIN sys.schemas AS ref_sch
        ON  ref_sch.[schema_id] = ref_obj.[schema_id]
    OUTER APPLY sys.fn_listextendedproperty(
            'MS_Description',
            'SCHEMA',
            ref_sch.[name],
            'TABLE',  -- ASSUMPTION: only tables may be referenced by foreign keys
            ref_obj.[name],
            'COLUMN',
            ref_col.[name]
        ) AS ref_ep_col
ORDER BY
    par_sch.name,
    par_obj.name,
    par_col.name,
    ref_sch.name,
    ref_obj.name,
    ref_col.name
