CREATE FUNCTION GetAllAncestors (
    @node hierarchyid
)
RETURNS table
RETURN
    WITH
        ancestors AS (
            SELECT @node AS ancestor
            UNION ALL
            SELECT ancestor.GetAncestor(1)
            FROM ancestors
            WHERE ancestor IS NOT NULL
        )
    SELECT ancestor
    FROM ancestors
    WHERE ancestor IS NOT NULL;