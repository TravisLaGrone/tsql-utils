CREATE FUNCTION noneNull (
	@values Array1D NOT NULL	
)
RETURNS bit
WITH SCHEMABINDING
AS BEGIN
	DECLARE @noneNull bit = 1;
	IF EXISTS(SELECT * FROM @values WHERE [value] IS NULL)
		SET @noneNull = 0;
	RETURN @noneNull;
END;