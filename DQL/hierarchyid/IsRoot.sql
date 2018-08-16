CREATE FUNCTION IsRoot (
    @node hierarchyid
)
RETURNS bit
AS BEGIN
    DECLARE @isRoot bit;
    IF (@node = hierarchyid::GetRoot())
        SET @isRoot = 1;
    ELSE
        SET @isRoot = 0;
    RETURN @isRoot;
END;