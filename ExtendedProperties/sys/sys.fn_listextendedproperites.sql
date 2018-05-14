SET QUOTED_IDENTIFIER ON
SET ANSI_NULLS ON
GO
create function sys.fn_listextendedproperty
	(@name sysname				= NULL,
	@level0type	varchar(128)	= NULL,
	@level0name	sysname			= NULL,
	@level1type	varchar(128)	= NULL,
	@level1name	sysname			= NULL,
	@level2type	varchar(128)	= NULL,
	@level2name	sysname			= NULL
)
returns @tab table(objtype varchar(128) null,
		objname sysname null,
		name sysname not null,
		value sql_variant null)
as
begin

declare @class int, -- convert to tinyint,
		@major int,
		@minminor int,
		@maxminor int,
		@basetype varchar(128)

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
select	@level0type = UPPER(@level0type collate Latin1_General_CI_AS)
		,@level1type = UPPER(@level1type collate Latin1_General_CI_AS) 
		,@level2type = UPPER(@level2type collate Latin1_General_CI_AS)
		,@basetype = case
			when @level2type is not null then @level2type
			when @level1type is not null then @level1type
			when @level0type is not null then @level0type
			end
			
select	@class = Convert(tinyint,
				EntityPropertyEx ( 'class', @level0type, @level0name, @level1type, @level1name, @level2type, @level2name )) 
		,@major = Convert(int,
				EntityPropertyEx( 'major', @level0type, @level0name, @level1type, @level1name, @level2type, @level2name ))
		,@minminor = Convert(int,
				EntityPropertyEx( 'minminor', @level0type, @level0name, @level1type, @level1name, @level2type, @level2name ))
		,@maxminor = Convert(int,
				EntityPropertyEx( 'maxminor', @level0type, @level0name, @level1type, @level1name, @level2type, @level2name ))

		
if @class is NULL
	return

-- Handle cases with no wildcards OR minor-id-only wildcards.  This will include simple wildcard across
-- all minor_id values (eg. 'INDEX', 'PARAMETER', 'COLUMN').
--
if @major is not null and @minminor is not null and @maxminor is not null
begin
	insert @tab select @basetype, entity_name( major_id, minor_id, class ),
		name, value from sys.extended_properties
		where class = @class and major_id = @major
			and (minor_id >= @minminor and minor_id <= @maxminor)
			and (@name is null or @name = name)
	return
end

-- After this point, approach is to populate an id/name table to join with sysproperties for output.
--	Note that minor_id is 0 for all entitities below.
--
declare @ids table (maj int primary key, nam sysname)

-- First handle single-level entities: @major will be NULL.  Order with pre-yukon queries first.
--
if @major is null
begin
	if @level0name is not null -- level0 entity name could not be resolved
		return
	else if @basetype = 'USER'
		insert @ids select principal_id, name from sys.database_principals
	else if @basetype in ('FILEGROUP','PARTITION SCHEME')
	begin
		insert @ids select data_space_id, name from sys.data_spaces
			where (@basetype = 'PARTITION SCHEME' and type = 'PS')
				or (@basetype = 'FILEGROUP' and type in ('FD', 'FG', 'FL', 'FX'))
	end
	else if @basetype = 'SCHEMA'
		insert @ids select schema_id, name from sys.schemas
	else if @basetype = 'PARTITION FUNCTION'
		insert @ids select function_id, name from sys.partition_functions
	else if @basetype = 'REMOTE SERVICE BINDING'
		insert @ids select remote_service_binding_id, name from sys.remote_service_bindings
	else if @basetype = 'ROUTE'
		insert @ids select route_id, name from sys.routes
	else if @basetype = 'SERVICE'
		insert @ids select service_id, name from sys.services
	else if @basetype = 'CONTRACT'
		insert @ids select service_contract_id, name from sys.service_contracts
	else if @basetype = 'MESSAGE TYPE'
		insert @ids select message_type_id, name from sys.service_message_types
	else if @basetype = 'ASSEMBLY'
		insert @ids select assembly_id, name from sys.assemblies
	else if @basetype = 'CERTIFICATE'
		insert @ids select certificate_id, name from sys.certificates
	else if @basetype = 'ASYMMETRIC KEY'
		insert @ids select asymmetric_key_id, name from sys.asymmetric_keys
	else if @basetype = 'SYMMETRIC KEY'
		insert @ids select symmetric_key_id, name from sys.symmetric_keys
	else if @basetype = 'PLAN GUIDE' 
		insert @ids select plan_guide_id, name from sys.plan_guides
end
--
-- Next handle queries that can service multiple levels
--
else if @basetype in ('TYPE','TRIGGER','EVENT NOTIFICATION')
begin
	if @basetype = 'TYPE'
	begin
		insert @ids select user_type_id, name from sys.types where schema_id = @major
	end
	else if @basetype = 'TRIGGER'
	begin
		insert @ids select object_id, name from sys.triggers
			where parent_class = (case
				when @level0type = 'TRIGGER' then 0		-- On database
				else 1 end)	-- On object
			and parent_id = @major
	end
	else if @basetype = 'EVENT NOTIFICATION'
	begin
		insert @ids select object_id, name from sys.event_notifications
			where parent_class = (case
				when @level0type = 'EVENT NOTIFICATION' then 0		-- On database
				else 1 end)	-- On object
			and parent_id = @major
	end
end
--
-- Handle entities with a @major that are schema-addressed-objects.
--
else if @basetype in ('CONSTRAINT','LOGICAL FILE NAME','XML SCHEMA COLLECTION')
begin
	if @basetype = 'CONSTRAINT'
	begin
		insert @ids select object_id, name from sys.objects
			where parent_object_id = @major and type in ('C','D','F','PK','UQ')
	end
	else if @basetype = 'LOGICAL FILE NAME'
		insert @ids select file_id, name from sys.database_files where data_space_id = @major
	else if @basetype = 'XML SCHEMA COLLECTION'
		insert @ids select xml_collection_id, name from sys.xml_schema_collections where schema_id = @major
end
--
-- Finally, handle schema-addressed objects (type-validation done for us in builtin)
--
else
begin
	-- Get the objects that match: Use dot-separated types to do pattern match
	-- and handle multiple object types.
	--
	insert @ids select object_id, name from sys.objects
		where schema_id = @major
		and parent_object_id = 0
		and 0 <> charindex( '.'+type+'.',
			case @level1type
				when 'TABLE' then '.U .'
				when 'VIEW' then '.V .'
				when 'RULE' then '.R .'
				when 'DEFAULT' then '.D .'
				when 'QUEUE' then '.SQ.'
				when 'SYNONYM' then '.SN.'
				when 'AGGREGATE' then '.AF.'
				when 'FUNCTION' then '.TF.FN.IF.FS.FT.'
				when 'PROCEDURE' then '.P .PC.RF.X .'
				when 'SEQUENCE' then '.SO.'
				end )
end

-- Now get properties from id-s obtained, and return
--
insert @tab select @basetype, i.nam, p.name, p.value
	from sys.extended_properties p join @ids i on p.class = @class and p.major_id = i.maj
	where p.minor_id = 0 and (@name is null or @name = p.name)

return
end

GO