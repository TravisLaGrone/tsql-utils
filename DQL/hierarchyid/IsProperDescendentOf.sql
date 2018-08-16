CREATE FUNCTION IsProperDescendantOf (
    @node1 hierarchyid,
    @node2 hierarchyid
)
RETURNS bit
AS BEGIN
    DECLARE @isProperDescendantOf bit;
    IF (@node1 IS NOT NULL AND @node2 IS NOT NULL AND @node1 <> @node2 AND 1 = @node1.IsDescendantOf(@node2))
        SET @isProperDescendantOf = 1;
    ELSE
        SET @isProperDescendantOf = 0;
    RETURN @isProperDescendantOf;
END;