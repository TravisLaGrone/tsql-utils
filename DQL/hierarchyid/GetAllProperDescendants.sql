CREATE FUNCTION GetAllProperDescendants (
    @node hierarchyid,
    @selectAllNodesQuery nvarchar(MAX)
)
RETURNS @properDescendants TABLE (
    properDescendant hierarchyid PRIMARY KEY NOT NULL
)
AS BEGIN
    DECLARE @sql nvarchar(MAX);
    SET @sql = (
        N'  SELECT node' +
        N'  FROM (' + @selectAllNodesQuery + N') AS nodes' +
        N'  WHERE node IS NOT NULL' +
        N'      AND node.IsDescendantOf(hierarchyid::Parse(' + @node + N'))' +
        N'      AND node <> hierarchyid::Parse(' + @node + N')'
    );
    
    INSERT INTO @properDescendants
    EXECUTE sp_executesql @sql;

    RETURN;
END;