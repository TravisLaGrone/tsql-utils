CREATE FUNCTION IsProperAncestorOf (
    @node1 hierarchyid,
    @node2 hierarchyid
)
RETURNS bit
AS BEGIN
    DECLARE @isAncestorOf bit;
    IF (@node1 IS NOT NULL AND @node2 IS NOT NULL AND @node1 <> @node2 AND 1 = @node2.IsDescendantOf(@node1))
        SET @isAncestorOf = 1;
    ELSE
        SET @isAncestorOf = 0;
    RETURN @isAncestorOf;
END;