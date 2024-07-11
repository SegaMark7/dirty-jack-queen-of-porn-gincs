@echo off
chcp 65001 > nul
setlocal enabledelayedexpansion

@REM начало отчета времени
for /F "tokens=1-4 delims=:.," %%a in ("%time%") do (
   set /A "start=(((%%a*60)+1%%b %% 100)*60000)+1%%c%%d-610000"
)

@REM Переменные
SET toolsDir=..\tools\
SET musicDir=music\
SET otherDir=others\
SET picsDir=pics\
SET scriptsDir=scripts\
SET tempDir=temp\
SET outputDir=\

@REM получить имя текущей папки и присвоить ее переменной gameName
for %%i in ("%CD%") do set "gameName=%%~nxi"

@REM удалить папку temp если она существует
rmdir /s /q "%tempDir%"

echo.
echo Копирование всех файлов из other в temp
xcopy /s /y "%otherDir%\*.*" "%tempDir%"

echo.
echo Копирование всех файлов из music в temp
xcopy /s /y "%musicDir%*.*" "%tempDir%"

echo.
echo Компиляция файлов скриптов
for %%F in ("%scriptsDir%*.txt") do (
    set "scrName=%%~nF"
    "%toolsDir%zop" "%tempDir%!scrName!.zbc" "%scriptsDir%!scrName!.txt"
)
if errorlevel 1 goto error

echo.
echo Компиляция файлов изображений
for %%F in ("%picsDir%*.pcx") do (
    set imgName=%%~nF
   @REM  echo "%toolsDir%pcx2bkg" "%picsDir%!imgName!.pcx" "%tempDir%!imgName!.bkg"
   @REM  echo "%toolsDir%apack" c "%tempDir%!imgName!.bkg" "%tempDir%!imgName!.bkg"

    "%toolsDir%pcx2bkg" "%picsDir%!imgName!.pcx" "%tempDir%!imgName!.bkg"
    "%toolsDir%apack" c "%tempDir%!imgName!.bkg" "%tempDir%!imgName!.bkg"
)
if errorlevel 1 goto error

cd "%tempDir%"
echo.
echo Запись в файл datalist.txt
dir /b "font.chr" "*.z80" "*.zbc" "*.bkg" "*.cbg" "*.wav" "*.snd" > "datalist.txt"

echo.
echo makegfs
"..\%toolsDir%makegfs" "datalist.txt" "data.gfs"

cd ..
echo.
echo Копирование stub.bin в %gameName%.smd
echo copy "%tempDir%stub.bin" "%outputDir%%gameName%.smd"
copy "%tempDir%stub.bin" "%~dp0\%outputDir%%gameName%.smd"

echo.
echo applygfs
"%toolsDir%applygfs" "%~dp0\%outputDir%%gameName%.smd" 65536 "%tempDir%data.gfs"
if errorlevel 1 goto error

goto done

:error
echo Error during the building process.
pause

:done
@REM конец отчета времени
for /F "tokens=1-4 delims=:.," %%a in ("%time%") do (
   set /A "end=(((%%a*60)+1%%b %% 100)*60000)+1%%c%%d-610000"
)

set /A elapsed=end-start

set /A hh=elapsed/(60*60*1000), rest=elapsed%%(60*60*1000), mm=rest/(60*1000), rest%%=60*1000, ss=rest/1000, cc=rest%%1000
if %hh% lss 10 set hh=0%hh%
if %mm% lss 10 set mm=0%mm%
if %ss% lss 10 set ss=0%ss%
if %cc% lss 10 set cc=0%cc%
if %cc% lss 100 set cc=0%cc%

echo elapsed time: %hh%:%mm%:%ss%.%cc%
@REM elapsed time: 00:00:00.334
@REM pause
