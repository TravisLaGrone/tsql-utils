WITH
    [unique indexes] AS (
        SELECT i.object_id, i.index_id
        FROM sys.indexes AS i
        WHERE i.is_unique = 1 AND i.is_disabled = 0 AND i.has_filter = 0
    ),
    [multi-column indexes] AS (
        SELECT ic.object_id, ic.index_id
        FROM sys.index_columns AS ic
        INNER JOIN [unique indexes] AS ui
            ON ic.object_id = ui.object_id AND ic.index_id = ui.index_id
        GROUP BY ic.object_id, ic.index_id
        HAVING COUNT(ic.column_id) > 1
    ),
    [columns-indexes] AS (
        SELECT ic.object_id, ic.index_id, ic.column_id
        FROM sys.index_columns AS ic
        INNER JOIN [multi-column indexes] AS mci
            ON ic.object_id = mci.object_id AND ic.index_id = mci.index_id
    )
SELECT o.name [object_name], i.name [index_name], c.name [column_name]
FROM [columns-indexes] AS ci
INNER JOIN sys.objects AS o
    ON ci.object_id = o.object_id
INNER JOIN sys.indexes AS i
    ON ci.object_id = i.object_id AND ci.index_id = i.index_id
INNER JOIN sys.columns AS c
    ON ci.object_id = c.object_id AND ci.column_id = c.column_id
INNER JOIN sys.schemas AS s
    ON o.schema_id = s.schema_id
WHERE s.name != 'sys'
ORDER BY o.name, i.name, c.name