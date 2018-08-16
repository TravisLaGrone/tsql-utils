CREATE FUNCTION IsAncestorOf (
    @node1 hierarchyid,
    @node2 hierarchyid
)
RETURNS bit
AS BEGIN
    DECLARE @isAncestorOf bit;
    IF (1 = @node2.IsDescendantOf(@node1))
        SET @isAncestorOf = 1;
    ELSE
        SET @isAncestorOf = 0;
    RETURN @isAncestorOf;
END;