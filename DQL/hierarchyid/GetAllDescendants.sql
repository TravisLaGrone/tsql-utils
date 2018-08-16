CREATE FUNCTION GetAllDescendants (
    @node hierarchyid,
    @selectAllNodesQuery nvarchar(MAX)
)
RETURNS @descendants TABLE (
    descendant hierarchyid PRIMARY KEY NOT NULL
)
AS BEGIN
    DECLARE @sql nvarchar(MAX);
    SET @sql = (
        N'  SELECT node AS descendant' +
        N'  FROM (' + @selectAllNodesQuery + N') AS nodes' +
        N'  WHERE node IS NOT NULL' +
        N'      AND node.IsDescendantOf(hierarchyid::Parse(' + @node + N'))'
    );
    
    INSERT INTO @descendants
    EXECUTE sp_executesql @sql;

    RETURN;
END;