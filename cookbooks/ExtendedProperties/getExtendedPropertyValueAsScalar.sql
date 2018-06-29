CREATE FUNCTION getExtendedPropertyAsScalar (
	  @name      sysname NOT NULL
	, @level0type varchar(128) = NULL
	, @level0name sysname = NULL
	, @level1type varchar(128) = NULL
	, @level1name sysname = NULL
	, @level2type varchar(128) = NULL
	, @level2name sysname = NULL
)
RETURNS sql_variant
WITH SCHEMABINDING
AS BEGIN
    DECLARE @value sql_variant;
    SET @value = (
        SELECT value
        FROM sys.fn_listextendedproperty(
                 @name
               , @level0type
               , @level0name
               , @level1type
               , @level1name
               , @level2type
               , @level2name
             )
    );
    RETURN @value;
END;
