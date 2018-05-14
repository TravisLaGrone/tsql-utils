CREATE PROCEDURE addOrUpdateExtendedProperty (
	  @name			sysname			NOT NULL = "MS_Description"
	, @value		sql_variant		NULL
	, @level0type	varchar(128)	NULL
	, @level0name	sysname			NULL
	, @level1type	varchar(128)	NULL
	, @level1name	sysname			NULL
	, @level2type	varchar(128)	NULL
	, @level2name	sysname			NULL
)
WITH SCHEMABINDING
AS BEGIN
	DECLARE @returnCode bit;

	DECLARE @exists bit = existsExtendedProperty(
		  @name
		, @level0type
		, @level0name
		, @level1type
		, @level1name
		, @level2type
		, @level2name
	);

    IF 0 = @exists /* does not exist */ BEGIN
		SET @returnCode = sys.sp_addextendedproperty(
			  @name
			, @value
			, @level0type
			, @level0name
			, @level1type
			, @level1name
			, @level2type
			, @level2name
		);
	END;
	ELSE BEGIN
		SET @returnCode = sys.sp_updateextendedproperty(
			  @name
			, @value
			, @level0type
			, @level0name
			, @level1type
			, @level1name
			, @level2type
			, @level2name
		);
    END;

	RETURN @returnCode;
END;