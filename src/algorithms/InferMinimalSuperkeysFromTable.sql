CREATE FUNCTION (
    @schema_name sysname = 'dbo',
    @table_name sysname
)
RETURNS TABLE (
    [table_name] sysname,
    [minimal_superkey] sysname,
    
)
WITH SCHEMABINDING
AS BEGIN
    -- TODO
END;