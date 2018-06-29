CREATE PROCEDURE #addOrUpdateExtendedProperties (
	@extendedProperties ExtendedProperty NOT NULL
)
WITH SCHEMABINDING
AS BEGIN
	-- QUESTION: do we need to verify user-defined type / func / sproc existence? or does the DBMS raise an appropriately descriptive exception on its own?

	SET NOCOUNT ON;

	/* LOCAL VARIABLES */
	DECLARE @name		sysname;
	DECLARE @value		sql_variant;
	DECLARE @level0type varchar(128);
	DECLARE @level0name sysname;
	DECLARE @level1type varchar(128);
	DECLARE @level1name sysname;
	DECLARE @level2type varchar(128);
	DECLARE @level2name sysname;

	DECLARE cursorExtendedProperty CURSOR
	LOCAL FAST_FORWARD
	FOR	SELECT
			  [name]
			, [value]
			, level0type
			, level0name
			, level1type
			, level1name
			, level2type
			, level2name
		FROM @extendedProperties;

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

	/* PROCESS ALL EXTENDED PROPERTIES */
	WHILE @@FETCH_STATUS = 0 BEGIN

		-- QUESTION: do we need to verify object existence? or does the fn_addextendedproperty already do that?

		/* PROCESS EXTENDED PROPERTY */
		EXEC addOrUpdateExtendedProperty
			  @name = @name
			, @value = @value
			, @level0type = @level0type
			, @level0name = @level0name
			, @level1type = @level1type
			, @level1name = @level1name
			, @level2type = @level2type
			, @level2name = @level2name;

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

END;