CREATE FUNCTION GetLastChild (
    @node hierarchyid,
    @selectAllNodesQuery nvarchar(MAX)
)
RETURNS hierarchyid
AS BEGIN
    DECLARE @sql nvarchar(MAX);
    SET @sql = (
        N'  SELECT @lastChild = MAX(node)' +
        N'  FROM (' + @selectAllNodesQuery + N') AS nodes' +
        N'  WHERE node IS NOT NULL' +
        N'      AND node.IsDescendantOf(hierarchyid::Parse(' + @node + N'))' +
        N'      AND node.GetLevel() - hierarchyid::Parse(' + @node + N').GetLevel() = 1'
    );

    DECLARE @params nvarchar(MAX);
    SET @params = N'@lastChild hierarchyid OUTPUT';
    
    DECLARE @lastChild hierarchyid;
    EXECUTE sp_executesql @sql, @params, @lastChild = @lastChild;

    RETURN @lastChild;
END;