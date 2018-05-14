CREATE TYPE ExtendedProperty
AS TABLE (
	  [name]		sysname			NOT NULL
	, [value]		sql_variant		NULL DEFAULT NULL
	, level0type	varchar(128)	NULL DEFAULT NULL
	, level0name	sysname			NULL DEFAULT NULL
	, level1type	varchar(128)	NULL DEFAULT NULL
	, level1name	sysname			NULL DEFAULT NULL
	, level2type	varchar(128)	NULL DEFAULT NULL
	, level2name	sysname			NULL DEFAULT NULL
);