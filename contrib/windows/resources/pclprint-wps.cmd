if not DEFINED IS_MINIMIZED set IS_MINIMIZED=1 && start "" /min "%~0" %* && exit

@echo off	
cd /D "%~dp0"

:: Check WMIC is available
WMIC.EXE Alias /? >NUL 2>&1 || GOTO s_error

:: Use WMIC to retrieve date and time
FOR /F "skip=1 tokens=1-6" %%G IN ('WMIC Path Win32_LocalTime Get Day^,Hour^,Minute^,Month^,Second^,Year /Format:table') DO (
   IF "%%~L"=="" goto s_done
      Set _yyyy=%%L
      Set _mm=00%%J
      Set _dd=00%%G
      Set _hour=00%%H
      SET _minute=00%%I
      SET _second=00%%K
)
:s_done

:: Pad digits with leading zeros
      Set _mm=%_mm:~-2%
      Set _dd=%_dd:~-2%
      Set _hour=%_hour:~-2%
      Set _minute=%_minute:~-2%
      Set _second=%_second:~-2%

Set logtimestamp=%_yyyy%-%_mm%-%_dd%_%_hour%_%_minute%_%_second%
goto make_dump

:s_error
echo WMIC is not available, using default log filename
Set logtimestamp=_

:make_dump

set FILENAME=%TEMP%\%logtimestamp%.pdf

start /wait /min gpcl6win32.exe -dBATCH -dNOPAUSE -sDEVICE=pdfwrite -sOutputFile=%FILENAME% print.prn
del print.prn

powershell.exe -ExecutionPolicy Bypass -File .\printpdf.ps1 %FILENAME%

rem del %FILENAME%

rem start %FILENAME%

exit