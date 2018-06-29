# Exceptions
Recipes relating to exceptions in T-SQL.

```sql
CREATE TABLE #Errors (
      ErrorNumber       int             NOT NULL
    , ErrorSeverity     int             NOT NULL
    , ErrorState        int             NOT NULL
    , ErrorProcedure    nvarchar(128)   NULL DEFAULT NULL
    , ErrorLine         int             NOT NULL
    , ErrorMessage      nvarchar(4000)  NOT NULL
);
```
