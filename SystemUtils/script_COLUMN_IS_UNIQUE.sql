/**
 * A query that returns the fully-scoped path names of columns that are statically guaranteed to be unique.
 * A column is considered statically guaranteed to be unique if it is has a unique index that is unfiltered,
 * currently enabled, and does not contain any other columns.  This criteria is sufficient but not necessary
 * for a column to be statically guaranteed to be unique; obverse examples include columns returned from
 * functions or procedures.  Neither does this criteria encompass columns that may be dynamically guaranteed
 * to be unique (i.e. according to the current state of the database's data), nor those that may be semantically
 * guaranteed to be unique (e.g. unimplemented uniqueness constraints).
 */
WITH
    [columns] AS (
        SELECT
              c.[object_id]
            , c.[column_id]
        FROM sys.columns AS c
    ),
    [indexes] AS (
        SELECT
              c.[object_id]
            , ic.[index_id]
        FROM [columns] AS c
        INNER JOIN sys.index_columns ic
            ON c.[object_id] = ic.[object_id] AND c.[column_id] = ic.[column_id]
    ),
    [single_indexes] AS (
        SELECT
              i.[object_id]
            , i.[index_id]
        FROM [indexes] AS i
        INNER JOIN sys.index_columns ic
            ON i.[object_id] = ic.[object_id] AND i.[index_id] = ic.[index_id]
        GROUP BY i.[object_id], i.[index_id]
        HAVING COUNT(*) = 1
    ),
    [unique_unfiltered_enabled_single_indexes] AS (
        SELECT
              si.[object_id]
            , si.[index_id]
        FROM [single_indexes] AS si
        INNER JOIN sys.indexes AS i
            ON si.[object_id] = i.[object_id] AND si.[index_id] = i.[index_id]
        WHERE i.[is_unique] = 1 AND i.[has_filter] = 0 AND i.[is_disabled] = 0
    ),
    [unique_columns] AS (
        SELECT
              uuesi.[object_id]
            , ic.[column_id]
        FROM [unique_unfiltered_enabled_single_indexes] AS uuesi
        INNER JOIN sys.index_columns AS ic
            ON uuesi.[object_id] = ic.[object_id] AND uuesi.[index_id] = ic.[index_id]
    )
SELECT
      s.[name] AS [schema_name]
    , t.[name] AS [table_name]
    , c.[name] AS [column_name]
FROM [unique_columns] AS uc
INNER JOIN sys.columns AS c
    ON uc.[object_id] = c.[object_id] AND uc.[column_id] = c.[column_id]
INNER JOIN sys.tables AS t
    ON uc.[object_id] = t.[object_id]
INNER JOIN sys.schemas AS s
    ON t.[schema_id] = s.[schema_id]
;