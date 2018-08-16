CREATE FUNCTION IsParentOf (
    @node1 hierarchyid,
    @node2 hierarchyid
)
RETURNS bit
AS BEGIN
    DECLARE @isParentOf bit;
    IF (1 = @node2.IsDescendantOf(@node1) AND @node1.GetLevel() - @node2.GetLevel() = -1)
        SET @isParentOf = 1;
    ELSE
        SET @isParentOf = 0;
    RETURN @isParentOf;
END;