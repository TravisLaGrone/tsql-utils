CREATE FUNCTION IsChildOf (
    @node1 hierarchyid,
    @node2 hierarchyid
)
RETURNS bit
AS BEGIN
    DECLARE @isChildOf bit;
    IF (1 = @node1.IsDescendantOf(@node2) AND @node1.GetLevel() - @node2.GetLevel() = 1)
        SET @isChildOf = 1;
    ELSE
        SET @isChildOf = 0;
    RETURN @isChildOf;
END;