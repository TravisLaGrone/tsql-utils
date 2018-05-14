CREATE FUNCTION bISNULL (
	@value sql_variant NULL
)
RETURNS bit
WITH SCHEMABINDING
AS BEGIN
	DECLARE @isNull bit = 0;
	IF @value IS NULL
		SET @isnull = 1;
	RETURN @isNull;
END;
