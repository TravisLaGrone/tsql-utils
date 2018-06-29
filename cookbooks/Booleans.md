# Booleans
Recipes relating to boolean logic.  Written in T-SQL.

**`ISTRUE_`**
```sql
CREATE FUNCTION ISTRUE_ (
    @value sql_variant NULL
)
RETURNS bit
BEGIN
    IF @value IS NULL
        RETURN NULL;
    ELSE IF TRY_CONVERT(int, @value) NOT NULL  /* i.e. type is numeric; different from ISNUMERIC(...) */
    BEGIN
        IF @value <> 0
            RETURN 1;
        ELSE
            RETURN 0;
    END
    ELSE  /* type is non-numeric, so assumed to be character or binary */
    BEGIN
        IF LEN(@value) <> 0
            RETURN 1;
        ELSE
            RETURN 0;
    END;
END;
```

**`ISFALSE_`**
```sql
CREATE FUNCTION ISFALSE_ (
    @value sql_variant NULL
)
RETURNS bit
BEGIN
    IF @value IS NULL
        RETURN NULL;
    ELSE IF TRY_CONVERT(int, @value) NOT NULL  /* i.e. type is numeric; different from ISNUMERIC(...) */
    BEGIN
        IF @value <> 0
            RETURN 0;
        ELSE
            RETURN 1;
    END
    ELSE  /* type is non-numeric, so assumed to be character or binary */
    BEGIN
        IF LEN(@value) <> 0
            RETURN 0;
        ELSE
            RETURN 1;
    END;
END;
```

**`ANY_`**
```sql
CREATE FUNCTION ANY_ (
    @array Array NOT NULL
)
RETURNS bit
AS BEGIN
    IF EXISTS(SELECT [value] FROM @array WHERE ISTRUE([value]) = 1)
        RETURN 1;
    ELSE IF EXISTS(SELECT [value] FROM @array WHERE ISTRUE([value]) IS NULL)
        RETURN NULL;
    ELSE
        RETURN 0;
END;
```

**`ALL_`**
```sql
CREATE FUNCTION ALL_ (
    @array Array NOT NULL
)
RETURNS bit
AS BEGIN
    IF EXISTS(SELECT [value] FROM @array WHERE ISTRUE([value]) IS NULL)
        RETURN NULL;
    ELSE IF EXISTS(SELECT [value] FROM @array WHERE ISTRUE([value]) = 0)
        RETURN 0;
    ELSE
        RETURN 1;
END;
```

**`NONE_`**
```sql
CREATE FUNCTION NONE_ (
    @array Array NOT NULL
)
RETURNS bit
AS BEGIN
    IF EXISTS(SELECT [value] FROM @array WHERE ISTRUE([value]) IS NULL)
        RETURN NULL;
    ELSE IF EXISTS(SELECT [value] FROM @array WHERE ISTRUE([value]) = 1)
        RETURN 0;
    ELSE
        RETURN 1;
END;
```

**`EQ_`**
```sql
CREATE FUNCTION EQ_ (
    @a sql_variant NULL,
    @b sql_variant NULL
)
RETURNS bit
AS BEGIN
    IF @a IS NULL OR @b IS NULL
        RETURN NULL;
    ELSE IF @a = @b
        RETURN 1;
    ELSE
        RETURN 0;
END;
```

**`NE_`***
```sql
CREATE FUNCTION NE_ (
    @a sql_variant NULL,
    @b sql_variant NULL
)
RETURNS bit
AS BEGIN
    IF @a IS NULL OR @b IS NULL
        RETURN NULL;
    ELSE IF @a = @b
        RETURN 0;
    ELSE
        RETURN 1;
END;
```

**`AND_`***
```sql
CREATE FUNCTION AND_ (
    @a sql_variant NULL,
    @b sql_variant NULL
)
RETURNS bit
AS BEGIN
    IF @a IS NULL OR @b IS NULL
    BEGIN
        IF 0 = ISTRUE(@a) OR 0 = ISTRUE(@b)
            RETURN 0;
        ELSE
            RETURN NULL;
    END
    ELSE IF 1 = ISTRUE(@a) AND 1 = ISTRUE(@b)
        RETURN 1;
    ELSE
        RETURN 0;
END;
```

**`OR_`***
```sql
CREATE FUNCTION OR_ (
    @a sql_variant NULL,
    @b sql_variant NULL
)
RETURNS bit
AS BEGIN
    IF @a IS NULL OR @b IS NULL
    BEGIN
        IF 0 = ISTRUE(@a) OR 0 = ISTRUE(@b)
            RETURN 0;
        ELSE
            RETURN NULL;
    END
    ELSE IF 1 = ISTRUE(@a) OR 1 = ISTRUE(@b)
        RETURN 1;
    ELSE
        RETURN 0;
END;
```

**`XOR_`**
```sql
CREATE FUNCTION XOR_ (
    @a sql_variant NULL,
    @b sql_variant NULL
)
RETURNS bit
AS BEGIN
    IF @a IS NULL OR @b IS NULL
        RETURN NULL;
    ELSE IF ISTRUE(@a) <> ISTRUE(@b)
        RETURN 1;
    ELSE
        RETURN 0;
END;
```

**`ISNULL_`**
```sql
CREATE FUNCTION ISNULL_ (
    @value sql_variant NULL
)
RETURNS bit
AS BEGIN
    IF @value IS NULL
        RETURN 1;
    ELSE
        RETURN 0;
END;
```

**`NOTNULL_`**
```sql
CREATE FUNCTION NOTNULL_ (
    @value sql_variant NULL
)
RETURNS bit
AS BEGIN
    IF @value NOT NULL
        RETURN 1;
    ELSE
        RETURN 0;
END;
```
