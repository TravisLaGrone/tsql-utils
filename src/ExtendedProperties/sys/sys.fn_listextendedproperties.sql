SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO
CREATE FUNCTION sys.fn_listextendedproperty (
    @name       sysname = NULL,
    @level0type varchar(128) = NULL,
    @level0name sysname = NULL,
    @level1type varchar(128) = NULL,
    @level1name sysname = NULL,
    @level2type varchar(128) = NULL,
    @level2name sysname = NULL
)
RETURNS @tab table (
    objtype varchar(128) NULL,
    objname sysname      NULL,
    name    sysname      NOT NULL,
    value   sql_variant  NULL
)
AS BEGIN

    DECLARE
        @class    int, -- convert to tinyint,
        @major    int,
        @minminor int,
        @maxminor int,
        @basetype varchar(128);

    /*	NOTES ON BUILTINS THAT WOULD NEED TO BE IMPLEMENTED:

EntityPropertyEx ( 'internal-property',
	@level0type varchar(128), @level0name sysname,
	@level1type varchar(128), @level1name sysname,
	@level2type varchar(128), @level2name sysname )
return sql_variant, 'internal-property' is one of:
	'class' -- null if error, else class
	'major' -- the lowest-level top-level id that could be resolved (schema-id, parent-object-id, etc)
	'minminor' -- non-null if exact major-id found, 
				  null if parent is a wild-card,
				  0 if @level2type is null,
				  minimum id otherwise
	'maxminor' -- non-null if exact major-id found, 
				  null if parent is a wild-card,
				  0 if @level2type is null,
				  maximum id otherwise
	'basetype' -- returns lowest-level type-name that is applicable (NULL for database)
Validates existence of all names if given (not wildcard) - null if not.
Could optimize so that validation check only done for 'class' property...
Some specific notes on values returned by 'major' for code below to work:
	if @level0type = 'TYPE', then 'major' = 1 (for dbo)
	if @level0type = 'FILEGROUP', then 'major' = data_space_id
	if @level0type = 'TRIGGER', then 'major' = 0 for parent_id of database
	if @level0type = 'EVENT NOTIFICATION', then 'major' = 0 for parent_id of database
	if @level1type is wildcarded object, 'major' returns schema_id


Entity_Name( class, major_id, minor_id ) -- returns lowest-level name of entity. Note that this
	will only be used for one cached-level entity. Also note that we always want to output the actual entity
	name rather than the given entity-name, which may differ in case, etc.
*/

    -- Validate Input: Any problems will return NULL 'class' (bad levels, types, names, etc)
    -- Use Latin1_General_CI_AS for the input param used in constant comparison as otherwise the collation from 
    -- the context/calling db will be used which could result in a problem. Example is Turkish_CS_AI_KS_WS with small 'i'.
    -- 
    SELECT
        @level0type = UPPER(@level0type COLLATE Latin1_General_CI_AS),
        @level1type = UPPER(@level1type COLLATE Latin1_General_CI_AS),
        @level2type = UPPER(@level2type COLLATE Latin1_General_CI_AS),
        @basetype   = CASE
                          WHEN @level2type IS NOT NULL THEN
                              @level2type
                          WHEN @level1type IS NOT NULL THEN
                              @level1type
                          WHEN @level0type IS NOT NULL THEN
                              @level0type
                      END;

    SELECT
        @class    =
        CONVERT(
            tinyint,
            EntityPropertyEx('class', @level0type, @level0name, @level1type, @level1name, @level2type, @level2name)
        ),
        @major    =
            CONVERT(
                int,
                EntityPropertyEx('major', @level0type, @level0name, @level1type, @level1name, @level2type, @level2name)
            ),
        @minminor =
            CONVERT(
                int,
                EntityPropertyEx(
                    'minminor', @level0type, @level0name, @level1type, @level1name, @level2type, @level2name
                )
            ),
        @maxminor =
            CONVERT(
                int,
                EntityPropertyEx(
                    'maxminor', @level0type, @level0name, @level1type, @level1name, @level2type, @level2name
                )
            );


    IF @class IS NULL
        RETURN;

    -- Handle cases with no wildcards OR minor-id-only wildcards.  This will include simple wildcard across
    -- all minor_id values (eg. 'INDEX', 'PARAMETER', 'COLUMN').
    --
    IF @major IS NOT NULL
        AND @minminor IS NOT NULL
        AND @maxminor IS NOT NULL BEGIN
        INSERT @tab
            SELECT
                @basetype,
                entity_name(major_id, minor_id, class),
                name,
                value
                FROM sys.extended_properties
                WHERE class = @class
                    AND major_id = @major
                    AND (
                        minor_id >= @minminor
                            AND minor_id <= @maxminor
                    )
                    AND (
                        @name IS NULL
                            OR @name = name
                    );
        RETURN;
    END;

    -- After this point, approach is to populate an id/name table to join with sysproperties for output.
    --	Note that minor_id is 0 for all entitities below.
    --
    DECLARE @ids table (
        maj int PRIMARY KEY,
        nam sysname
    );

    -- First handle single-level entities: @major will be NULL.  Order with pre-yukon queries first.
    --
    IF @major IS NULL BEGIN
        IF @level0name IS NOT NULL -- level0 entity name could not be resolved
            RETURN;
        ELSE IF @basetype = 'USER'
            INSERT @ids
                SELECT
                    principal_id,
                    name
                    FROM sys.database_principals;
        ELSE IF @basetype IN ('FILEGROUP', 'PARTITION SCHEME') BEGIN
                 INSERT @ids
                     SELECT
                         data_space_id,
                         name
                         FROM sys.data_spaces
                         WHERE (
                             @basetype = 'PARTITION SCHEME'
                                   AND type = 'PS'
                         )
                             OR (
                                 @basetype = 'FILEGROUP'
                                    AND type IN ('FD', 'FG', 'FL', 'FX')
                             );
        END;
        ELSE IF @basetype = 'SCHEMA'
            INSERT @ids
                SELECT
                    schema_id,
                    name
                    FROM sys.schemas;
        ELSE IF @basetype = 'PARTITION FUNCTION'
            INSERT @ids
                SELECT
                    function_id,
                    name
                    FROM sys.partition_functions;
        ELSE IF @basetype = 'REMOTE SERVICE BINDING'
            INSERT @ids
                SELECT
                    remote_service_binding_id,
                    name
                    FROM sys.remote_service_bindings;
        ELSE IF @basetype = 'ROUTE'
            INSERT @ids
                SELECT
                    route_id,
                    name
                    FROM sys.routes;
        ELSE IF @basetype = 'SERVICE'
            INSERT @ids
                SELECT
                    service_id,
                    name
                    FROM sys.services;
        ELSE IF @basetype = 'CONTRACT'
            INSERT @ids
                SELECT
                    service_contract_id,
                    name
                    FROM sys.service_contracts;
        ELSE IF @basetype = 'MESSAGE TYPE'
            INSERT @ids
                SELECT
                    message_type_id,
                    name
                    FROM sys.service_message_types;
        ELSE IF @basetype = 'ASSEMBLY'
            INSERT @ids
                SELECT
                    assembly_id,
                    name
                    FROM sys.assemblies;
        ELSE IF @basetype = 'CERTIFICATE'
            INSERT @ids
                SELECT
                    certificate_id,
                    name
                    FROM sys.certificates;
        ELSE IF @basetype = 'ASYMMETRIC KEY'
            INSERT @ids
                SELECT
                    asymmetric_key_id,
                    name
                    FROM sys.asymmetric_keys;
        ELSE IF @basetype = 'SYMMETRIC KEY'
            INSERT @ids
                SELECT
                    symmetric_key_id,
                    name
                    FROM sys.symmetric_keys;
        ELSE IF @basetype = 'PLAN GUIDE'
            INSERT @ids
                SELECT
                    plan_guide_id,
                    name
                    FROM sys.plan_guides;
    END;
    --
    -- Next handle queries that can service multiple levels
    --
    ELSE IF @basetype IN ('TYPE', 'TRIGGER', 'EVENT NOTIFICATION') BEGIN
             IF @basetype = 'TYPE' BEGIN
                 INSERT @ids
                     SELECT
                         user_type_id,
                         name
                         FROM sys.types
                         WHERE schema_id = @major;
             END;
             ELSE IF @basetype = 'TRIGGER' BEGIN
                      INSERT @ids
                          SELECT
                              object_id,
                              name
                              FROM sys.triggers
                              WHERE parent_class = (CASE
                                                        WHEN @level0type = 'TRIGGER' THEN
                                                            0 -- On database
                                                        ELSE
                                                            1
                                                    END
                                                   ) -- On object
                                  AND parent_id = @major;
             END;
             ELSE IF @basetype = 'EVENT NOTIFICATION' BEGIN
                      INSERT @ids
                          SELECT
                              object_id,
                              name
                              FROM sys.event_notifications
                              WHERE parent_class = (CASE
                                                        WHEN @level0type = 'EVENT NOTIFICATION' THEN
                                                            0 -- On database
                                                        ELSE
                                                            1
                                                    END
                                                   ) -- On object
                                  AND parent_id = @major;
             END;
    END;
    --
    -- Handle entities with a @major that are schema-addressed-objects.
    --
    ELSE IF @basetype IN ('CONSTRAINT', 'LOGICAL FILE NAME', 'XML SCHEMA COLLECTION') BEGIN
             IF @basetype = 'CONSTRAINT' BEGIN
                 INSERT @ids
                     SELECT
                         object_id,
                         name
                         FROM sys.objects
                         WHERE parent_object_id = @major
                             AND type IN ('C', 'D', 'F', 'PK', 'UQ');
             END;
             ELSE IF @basetype = 'LOGICAL FILE NAME'
                 INSERT @ids
                     SELECT
                         file_id,
                         name
                         FROM sys.database_files
                         WHERE data_space_id = @major;
             ELSE IF @basetype = 'XML SCHEMA COLLECTION'
                 INSERT @ids
                     SELECT
                         xml_collection_id,
                         name
                         FROM sys.xml_schema_collections
                         WHERE schema_id = @major;
    END;
    --
    -- Finally, handle schema-addressed objects (type-validation done for us in builtin)
    --
    ELSE BEGIN
             -- Get the objects that match: Use dot-separated types to do pattern match
             -- and handle multiple object types.
             --
             INSERT @ids
                 SELECT
                     object_id,
                     name
                     FROM sys.objects
                     WHERE schema_id = @major
                         AND parent_object_id = 0
                         AND 0 <> CHARINDEX('.' + type + '.',
                                            CASE @level1type
                                                WHEN 'TABLE' THEN
                                                    '.U .'
                                                WHEN 'VIEW' THEN
                                                    '.V .'
                                                WHEN 'RULE' THEN
                                                    '.R .'
                                                WHEN 'DEFAULT' THEN
                                                    '.D .'
                                                WHEN 'QUEUE' THEN
                                                    '.SQ.'
                                                WHEN 'SYNONYM' THEN
                                                    '.SN.'
                                                WHEN 'AGGREGATE' THEN
                                                    '.AF.'
                                                WHEN 'FUNCTION' THEN
                                                    '.TF.FN.IF.FS.FT.'
                                                WHEN 'PROCEDURE' THEN
                                                    '.P .PC.RF.X .'
                                                WHEN 'SEQUENCE' THEN
                                                    '.SO.'
                                            END
                                  );
    END;

    -- Now get properties from id-s obtained, and return
    --
    INSERT @tab
        SELECT
            @basetype,
            i.nam,
            p.name,
            p.value
            FROM sys.extended_properties AS p
                JOIN @ids                AS i
                    ON p.class = @class
                        AND p.major_id = i.maj
            WHERE p.minor_id = 0
                AND (
                    @name IS NULL
                        OR @name = p.name
                );

    RETURN;
END;

GO