CREATE FUNCTION GetAllProperAncestors (
    @node hierarchyid
)
RETURNS table
RETURN
    WITH
        properAncestors AS (
            SELECT @node AS properAncestor
            UNION ALL
            SELECT properAncestor.GetAncestor(1)
            FROM properAncestors
            WHERE properAncestor IS NOT NULL
        )
    SELECT properAncestor
    FROM properAncestors
    WHERE properAncestor IS NOT NULL AND (@node IS NULL OR properAncestor <> @node);