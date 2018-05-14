


/********************/
/* CONFIGURE SCRIPT */
/********************/

DECLARE @FILE_NAME varchar(256) = 'D:\RNET_DD.csv';
DECLARE @FIRST_ROW int = 1;
DECLARE @FIELD_TERMINATOR varchar(10) = ',';
DECLARE @ROW_TERMINATOR varchar(10) = CHAR(0x0D) + CHAR(0x0A);  -- '\r\n'

DECLARE @UPDATE_IF_EXISTS bit = 1;  -- 1 is True, 0 is False
DECLARE @REMOVE_MS_DESCRIPTION_IF_SOFT_NULL bit = 1;  -- 1 is True, 0 is False

/* SOFT NULLS */
IF OBJECT_ID('tempdb..#SoftNullKeywords') IS NOT NULL
    DROP TABLE #SoftNullKeywords;

SELECT keyword
INTO #SoftNullKeywords
FROM (VALUES
      ('NULL')
    , ('N/A')
    , ('NA')
    , ('NOT APPLICABLE')
    , ('MISSING')
    , ('0')
    , ('0.0')
    ) AS keywords(keyword);



/**********/
/* IMPORT */
/**********/

/* SET UP TEMPORARY HOLDING TABLE */
IF OBJECT_ID('tempdb..#ExtendedPropertiesImported') IS NOT NULL
    DROP TABLE #ExtendedPropertiesImported;

CREATE TABLE #ExtendedPropertiesImported (
      id            int             NOT NULL PRIMARY KEY  -- must be NON NULL for cleaning step to work properly without having to add complexity
	, [name]		sysname         NULL DEFAULT NULL
	, [value]		sql_variant		NULL DEFAULT NULL
	, level0type	varchar(128)	NULL DEFAULT NULL
	, level0name	sysname			NULL DEFAULT NULL
	, level1type	varchar(128)	NULL DEFAULT NULL
	, level1name	sysname			NULL DEFAULT NULL
	, level2type	varchar(128)	NULL DEFAULT NULL
	, level2name	sysname			NULL DEFAULT NULL
);

/* DO IMPORT */
DECLARE @cmd varchar(999) = '
	BULK INSERT #ExtendedPropertiesImported
	FROM ''' + @FILE_NAME + '''
	WITH (
		  FIRSTROW = ' + str(@FIRST_ROW) + '
		, FIELDTERMINATOR = ''' + @FIELD_TERMINATOR + '''
		, ROWTERMINATOR = ''' + @ROW_TERMINATOR + '''
        , KEEPNULLS
	);
';

EXECUTE (@cmd);



/*********/
/* CLEAN */
/*********/

/* TRIM WHITESPACE */
UPDATE #ExtendedPropertiesImported SET [name] = LTRIM(RTRIM([name])) WHERE [name] IS NOT NULL;
-- UPDATE #ExtendedPropertiesImported SET [value] = LTRIM(RTRIM([value])) WHERE [value] IS NOT NULL;  -- can't be sure that not intended value
UPDATE #ExtendedPropertiesImported SET level0type = LTRIM(RTRIM(level0type)) WHERE level0type IS NOT NULL;
UPDATE #ExtendedPropertiesImported SET level0name = LTRIM(RTRIM(level0name)) WHERE level0name IS NOT NULL;
UPDATE #ExtendedPropertiesImported SET level1type = LTRIM(RTRIM(level1type)) WHERE level1type IS NOT NULL;
UPDATE #ExtendedPropertiesImported SET level1name = LTRIM(RTRIM(level1name)) WHERE level1name IS NOT NULL;
UPDATE #ExtendedPropertiesImported SET level2type = LTRIM(RTRIM(level2type)) WHERE level2type IS NOT NULL;
UPDATE #ExtendedPropertiesImported SET level2name = LTRIM(RTRIM(level2name)) WHERE level2name IS NOT NULL;

/* STANDARDIZE SOFT NULLS */
UPDATE #ExtendedPropertiesImported SET [name] = NULL WHERE [name] IN (SELECT keyword FROM #SoftNullKeywords);
-- UPDATE #ExtendedPropertiesImported SET [value] = NULL WHERE [value] IN (SELECT keyword FROM #SoftNullKeywords);  -- can't be sure that not intended value
UPDATE #ExtendedPropertiesImported SET level0type = NULL WHERE level0type IN (SELECT keyword FROM #SoftNullKeywords);
UPDATE #ExtendedPropertiesImported SET level0name = NULL WHERE level0name IN (SELECT keyword FROM #SoftNullKeywords);
UPDATE #ExtendedPropertiesImported SET level1type = NULL WHERE level1type IN (SELECT keyword FROM #SoftNullKeywords);
UPDATE #ExtendedPropertiesImported SET level1name = NULL WHERE level1name IN (SELECT keyword FROM #SoftNullKeywords);
UPDATE #ExtendedPropertiesImported SET level2type = NULL WHERE level2type IN (SELECT keyword FROM #SoftNullKeywords);
UPDATE #ExtendedPropertiesImported SET level2name = NULL WHERE level2name IN (SELECT keyword FROM #SoftNullKeywords);

/* STANDARDIZE EMPTY AND BLANK STRINGS */
UPDATE #ExtendedPropertiesImported SET [name] = NULL WHERE ISNULL([name], '') = '';
-- UPDATE #ExtendedPropertiesImported SET [value] = NULL WHERE ISNULL([value], '') = '';  -- can't be sure that not intended value
UPDATE #ExtendedPropertiesImported SET level0type = NULL WHERE ISNULL(level0type, '') = '';
UPDATE #ExtendedPropertiesImported SET level0name = NULL WHERE ISNULL(level0name, '') = '';
UPDATE #ExtendedPropertiesImported SET level1type = NULL WHERE ISNULL(level1type, '') = '';
UPDATE #ExtendedPropertiesImported SET level1name = NULL WHERE ISNULL(level1name, '') = '';
UPDATE #ExtendedPropertiesImported SET level2type = NULL WHERE ISNULL(level2type, '') = '';
UPDATE #ExtendedPropertiesImported SET level2name = NULL WHERE ISNULL(level2name, '') = '';

/* REMOVE ROWS WITH NO PROPERTY NAME */
DELETE FROM #ExtendedPropertiesImported WHERE [name] IS NULL;

/* REMOVE MS_DESCRIPTION PROPERTIES WHERE VALUE IS NULL OR SOFT NULL */
IF 1 = @REMOVE_MS_DESCRIPTION_IF_SOFT_NULL
    DELETE FROM #ExtendedPropertiesImported WHERE [name] = 'MS_Description' AND [value] IN (SELECT keyword FROM #SoftNullKeywords);



/*********/
/* APPLY */
/*********/

/* SET UP PERMANENT TABLE OF RECORD */
IF NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.tables WHERE table_schema = 'dbo' AND table_name = 'ExtendedPropertiesApplied') BEGIN
	CREATE TABLE dbo.ExtendedPropertiesApplied (
		  [action]		varchar(6)		NOT NULL
		, [name]		sysname			NULL DEFAULT NULL
		, old_value		sql_variant		NULL DEFAULT NULL
		, new_value		sql_variant		NULL DEFAULT NULL
		, level0type	varchar(128)	NULL DEFAULT NULL
		, level0name	sysname			NULL DEFAULT NULL
		, level1type	varchar(128)	NULL DEFAULT NULL
		, level1name	sysname			NULL DEFAULT NULL
		, level2type	varchar(128)	NULL DEFAULT NULL
		, level2name	sysname			NULL DEFAULT NULL
	);
END;
-- TODO else validate that table has at least expected columns with correct types, otherwise throw error code 208, severity 16

/* SET UP LOOP */
SET NOCOUNT ON;

DECLARE @msg varchar(MAX);

DECLARE @name		sysname;
DECLARE @value		sql_variant;
DECLARE @level0type varchar(128);
DECLARE @level0name sysname;
DECLARE @level1type varchar(128);
DECLARE @level1name sysname;
DECLARE @level2type varchar(128);
DECLARE @level2name sysname;
DECLARE @exists		bit;  -- 1 is True, 0 is False
DECLARE @oldValue	sql_variant;

DECLARE cursorExtendedProperty CURSOR
LOCAL FAST_FORWARD
FOR
	SELECT
		  [name]
		, [value]
		, level0type
		, level0name
		, level1type
		, level1name
		, level2type
		, level2name
	FROM #ExtendedPropertiesImported;

OPEN cursorExtendedProperty;

/* PRIMING READ */
FETCH NEXT
FROM cursorExtendedProperty
INTO  @name
	, @value
	, @level0type
	, @level0name
	, @level1type
	, @level1name
	, @level2type
	, @level2name;

/* PROCESS EACH IMPORTED EXTENDED PROPERTY */
WHILE @@FETCH_STATUS = 0 BEGIN

	/* CATCH ERRORS DUE TO INCORRECT EXTENDED PROPERTIES */
	/* E.G. NON-EXISTENT TARGET OBJECTS, MISSING REQUIRED OBJECT NAMES, INCORRECT OBJECT IDENTIFICATION SYNTAX, ETC. */
	BEGIN TRY

		/* SET FLAG FOR WHETHER PROPERTY ALREADY EXISTED */
		IF EXISTS(SELECT * FROM sys.fn_listextendedproperty(@name, @level0type, @level0name, @level1type, @level1name, @level2type, @level2name)) BEGIN
			SET @exists = 1;
			SET @oldValue = (SELECT [value] FROM sys.fn_listextendedproperty(@name, @level0type, @level0name, @level1type, @level1name, @level2type, @level2name));
		END;
		ELSE BEGIN
			SET @exists = 0;
			SET @oldValue = NULL;
		END;

		/* ADD, UPDATE, OR DO NOTHING WITH IMPORTED EXTENDED PROPERTY */
		IF (1 = @exists) BEGIN
			IF (1 = @UPDATE_IF_EXISTS) BEGIN  -- update

				/* UPDATE */
				EXEC sp_updateextendedproperty
					  @name
					, @value
					, @level0type
					, @level0name
					, @level1type
					, @level1name
					, @level2type
					, @level2name;

				/* RECORD */
				INSERT INTO dbo.ExtendedPropertiesApplied (
                      [action]
		            , [name]
		            , old_value
		            , new_value
		            , level0type
		            , level0name
		            , level1type
		            , level1name
		            , level2type
		            , level2name
                ) VALUES (
					 'update'
                    , @name
					, @oldValue
					, @value
					, @level0type
					, @level0name
					, @level1type
					, @level1name
					, @level2type
					, @level2name
				);

			END;

			-- ELSE nothing to do

		END;
		ELSE BEGIN  -- add
			
			/* ADD */
			EXEC sp_addextendedproperty
				  @name
				, @value
				, @level0type
				, @level0name
				, @level1type
				, @level1name
				, @level2type
				, @level2name;

			/* RECORD */
			INSERT INTO dbo.ExtendedPropertiesApplied (
				  [action]
				, [name]
				, old_value
				, new_value
				, level0type
				, level0name
				, level1type
				, level1name
				, level2type
				, level2name
			) VALUES (
				  'add'
				, @name
                , @oldValue
				, @value
				, @level0type
				, @level0name
				, @level1type
				, @level1name
				, @level2type
				, @level2name
			);

		END;

	END TRY
	BEGIN CATCH

        SET @msg = 'error!';
		-- TODO catch block inside loop
        PRINT(@msg);

	END CATCH;

	/* ADVANCE CURSOR */
	FETCH NEXT
	FROM cursorExtendedProperty
	INTO  @name
		, @value
		, @level0type
		, @level0name
		, @level1type
		, @level1name
		, @level2type
		, @level2name;
		
END;

/* CLEAN UP LOOP */
CLOSE cursorExtendedProperty;
DEALLOCATE cursorExtendedProperty;
