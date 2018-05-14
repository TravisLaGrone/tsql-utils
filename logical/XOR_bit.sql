CREATE FUNCTION XOR_bit (
	  @a bit NOT NULL
	, @b bit NOT NULL
)
RETURNS bit
WITH SCHEMABINDING
AS BEGIN
	DECLARE @xor bit = 1;
	IF @a = @b
		SET @xor = 0;
	RETURN @xor;
END;