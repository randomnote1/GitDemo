USE OperationsManagerDW
GO

DECLARE @startDate date = '1/1/2019'
DECLARE @endDate date = '7/7/2020'

SELECT	Date
		,Server
		,DatabaseName
		,FileName
		,CASE
			WHEN [DB File Allocated Space Left (%)] = 0 THEN 0
			ELSE [DB File Allocated Space Left (MB)] / ( [DB File Allocated Space Left (%)] / 100 )
		END AS DatabaseFileUsedSpaceMB
		,CASE
			WHEN [DB File Allocated Space Left (%)] = 0 THEN 0
			ELSE [DB File Allocated Space Left (MB)] / ( [DB File Allocated Space Left (%)] / 100 ) /1024
		END AS DatabaseFileUsedSpaceGB
FROM
(
	SELECT	vpd.DateTime AS Date
			,UPPER(SUBSTRING(me.PATH, 0, CHARINDEX('.', me.PATH))) AS Server
			,SUBSTRING(SUBSTRING(SUBSTRING(me.Path,CHARINDEX(';',me.Path)+1,LEN(me.Path)),CHARINDEX(';',SUBSTRING(me.Path,CHARINDEX(';',me.Path)+1,LEN(me.Path)))+1,LEN(SUBSTRING(me.Path,CHARINDEX(';',me.Path)+1,LEN(me.Path)))),0,CHARINDEX(';',SUBSTRING(SUBSTRING(me.Path,CHARINDEX(';',me.Path)+1,LEN(me.Path)),CHARINDEX(';',SUBSTRING(me.Path,CHARINDEX(';',me.Path)+1,LEN(me.Path)))+1,LEN(SUBSTRING(me.Path,CHARINDEX(';',me.Path)+1,LEN(me.Path)))))) AS DatabaseName
			,me.DisplayName AS FileName
			,pr.CounterName
			,vpd.MaxValue
	FROM	perf.vPerfDaily vpd 
	INNER	JOIN dbo.vPerformanceRuleInstance pri ON vpd.PerformanceRuleInstanceRowId = pri.PerformanceRuleInstanceRowId
	INNER	JOIN dbo.ManagedEntity me ON vpd.ManagedEntityRowId = me.ManagedEntityRowId
	INNER	JOIN dbo.vPerformanceRule pr ON pri.RuleRowId = pr.RuleRowId
	WHERE	CAST(vpd.DateTime AS DATE) >= @startDate
		AND	CAST(vpd.DateTime AS DATE) <= @endDate
		AND	(
			( pr.ObjectName = 'SQL DB File' AND pr.CounterName = 'DB File Allocated Space Left (MB)' )
			OR ( pr.ObjectName = 'SQL DB File' AND pr.CounterName = 'DB File Allocated Space Left (%)' )
		)
) AS src
PIVOT
(
	SUM(MaxValue)
	FOR CounterName IN ([DB File Allocated Space Left (MB)],[DB File Allocated Space Left (%)])
) AS pvt
ORDER	BY Date DESC , Server, DatabaseName, FileName
