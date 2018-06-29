CREATE FUNCTION calcBaseType(
      @level0type varchar(128) NULL DEFAULT NULL
    , @level1type varchar(128) NULL DEFAULT NULL
    , @level2type varchar(128) NULL DEFAULT NULL
)
RETURNS varchar(128)
BEGIN
    DECLARE @basetype varchar(128);
    IF @level2type IS NOT NULL
        SET @basetype = @level2type
    ELSE IF @level1type IS NOT NULL
        SET @basetype = @level1type
    ELSE IF @level0type IS NOT NULL
        SET @basetype = @level0type
    ELSE
        SET @basetype = 'DATABASE'
    RETURN @basetype;
END;