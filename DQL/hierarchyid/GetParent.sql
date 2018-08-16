CREATE FUNCTION GetParent (
    @node hierarchyid
)
RETURNS hierarchyid
AS BEGIN
    DECLARE @parent hierarchyid;
    SET @parent = @node.GetAncestor(1);
    RETURN @parent;
END;