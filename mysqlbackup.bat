@echo off

:: current date
set year=%DATE:~9,4%
set mnt=%DATE:~6,2%
set day=%DATE:~3,2%

:: file names
set backuptime=%year%%mnt%%day%
echo %backuptime%

:: global settings
set dbuser=<user>
set dbpass=<password>
set dbport=3306
set errorLogPath="C:\ProgramData\MySQLBackup\error.log"
set mysqldumpexe="C:\Program Files\MySQL\MySQL Server 5.6\bin\mysqldump.exe"
set backupfldr="C:\ProgramData\MySQLBackup"
set datafldr="C:\ProgramData\MySQL\MySQL Server 5.6\data"
set zipper="C:\Program Files\MySQLBackups\zip\7za.exe"

pushd %datafldr%
echo "Start backup job"

:: dump
FOR /D %%F IN (*) DO (
IF NOT [%%F]==[performance_schema] (
SET %%F=!%%F:@002d=-!
%mysqldumpexe% --user=%dbuser% --password=%dbpass% --port=%dbport% --databases --routines --log-error=%errorLogPath% %%F > "%backupfldr%\%%F_%backuptime%.sql"
) ELSE (
echo Skipping DB backup for performance_schema
)
)

:: archive
echo "Zipping all files ending in .sql in the folder"
%zipper% a -t7z "%backupfldr%\fullbackup_%backuptime%.7z" "%backupfldr%\*.sql"

:: cleanup
echo "Deleting all the files ending in .sql only"
del "%backupfldr%\*.sql"

echo "done"
popd