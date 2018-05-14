SELECT
	sys.fn_listextendedproperty(
		  DEFAULT
		, level0type
		, DEFAULT
		, level1type
		, DEFAULT
        , level2type
		, DEFAULT
	)
FROM ExtendedPropertyTypePaths paths
;