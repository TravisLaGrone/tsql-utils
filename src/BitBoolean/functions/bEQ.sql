CREATE FUNCTION bEQ (
	  @a bit NOT NULL
	, @b bit NOT NULL
)
RETURNS bit
WITH SCHEMABINDING
AS BEGIN
	DECLARE @eq bit = 1;
	IF @a <> @b
		SET @eq = 0;
	RETURN @eq;
END;