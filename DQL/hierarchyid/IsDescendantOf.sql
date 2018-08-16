CREATE FUNCTION IsDescendantOf (
    @node1 hierarchyid,
    @node2 hierarchyid
)
RETURNS bit
AS BEGIN
    DECLARE @isDescendantOf bit;
    IF (1 = @node1.IsDescendantOf(@node2))
        SET @isDescendantOf = 1;
    ELSE
        SET @isDescendantOf = 0;
    RETURN @isDescendantOf;
END;