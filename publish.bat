@echo off

REM Set source and destination directories
set "source=C:\Users\parag\OneDrive\Documents\GitHub\GuildRecruiter"
set "destination=C:\Program Files (x86)\World of Warcraft\_retail_\Interface\AddOns\GuildRecruiter"

REM Delete contents of destination directory
echo Deleting contents of %destination%...
rd /s /q "%destination%"
mkdir "%destination%"

REM Copy contents from source to destination
echo Copying contents from %source% to %destination%...
xcopy /s /e /i "%source%\*" "%destination%"

echo Update complete.
pause
