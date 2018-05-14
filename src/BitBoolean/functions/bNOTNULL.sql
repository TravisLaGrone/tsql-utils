CREATE FUNCTION bNOTNULL (
	@value sql_variant NULL
)
RETURNS bit
WITH SCHEMABINDING
AS BEGIN
	DECLARE @isNull bit = 1;
	IF @value IS NULL
		SET @isnull = 0;
	RETURN @isNull;
END;
