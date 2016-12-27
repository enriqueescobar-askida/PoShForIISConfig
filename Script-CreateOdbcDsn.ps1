Add-OdbcDsn -Name "AskidaOdbc64" 
-DriverName "SQL Server" 
-DsnType "System" 
-Platform "64-bit" 
-SetPropertyValue @("StatsLog_On=Yes"
, "Description=Askida ODBC x64"
, "Server=BUILD-DEV-HS"
, "StatsLogFile=C:\Askida\ODBC\64\STATS.LOG"
, "QueryLog_On=Yes"
, "Language=us_english"
, "QueryLogFile=C:\Askida\ODBC\64\QUERY.LOG")
;
