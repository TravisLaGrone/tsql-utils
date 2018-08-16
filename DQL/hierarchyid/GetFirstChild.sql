CREATE FUNCTION GetFirstChild (
    @node hierarchyid,
    @selectAllNodesQuery nvarchar(MAX)
)
RETURNS hierarchyid
AS BEGIN
    DECLARE @sql nvarchar(MAX);
    SET @sql = (
        N'  SELECT node AS child' +
        N'  FROM (' + @selectAllNodesQuery + N') AS nodes' +
        N'  WHERE node IS NOT NULL' +
        N'      AND node.IsDescendantOf(hierarchyid::Parse(' + @node + N'))' +
        N'      AND node.GetLevel() - hierarchyid::Parse(' + @node + N').GetLevel() = 1'
    );
    
    DECLARE @children TABLE ( child hierarchyid PRIMARY KEY NOT NULL );
    INSERT INTO @children EXECUTE sp_executesql @sql;

    DECLARE @firstChild hierarchyid;
    SELECT @firstChild = MIN(child) FROM @children;

    RETURN @firstChild;
END;