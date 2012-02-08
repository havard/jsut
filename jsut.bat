@echo off
setlocal enableextensions
setlocal enabledelayedexpansion

set TIMEOUT=60
set INSTALLDIR=%~dp0
set CURRENTDIR=%CD%

set CHROMEEXE=%LOCALAPPDATA%\Google\Chrome\Application\chrome.exe
set FFEXE=%PROGRAMFILES(X86)%\Mozilla Firefox\firefox.exe
set IEEXE=%PROGRAMFILES(X86)%\Internet Explorer\iexplore.exe
set OPERAEXE=%PROGRAMFILES(X86)%\Opera\opera.exe
set SAFARIEXE=%PROGRAMFILES(X86)%\Safari\safari.exe

set BROWSERCOUNT=0
set FILECOUNT=0
set NODE=no

:ReadOptions
set OPT=%1
if (%OPT%) == () goto Run
if /I (%OPT%) == (-h) goto PrintHelp
if /I (%OPT%) == (-b) goto ReadBrowserParameter
if /I (%OPT%) == (-n) goto ReadNodeParameter
if /I (%OPT:~0,1%) == (-) goto ErrorUnknownOption
goto ReadFileParameter

:ReadBrowserParameter
if (%2) == () goto ErrorMissingBrowserName
if (%2) == (chrome) goto ReadOkBrowser
if (%2) == (c) goto ReadOkBrowser
if (%2) == (firefox) goto ReadOkBrowser
if (%2) == (ff) goto ReadOkBrowser
if (%2) == (f) goto ReadOkBrowser
if (%2) == (internetexplorer) goto ReadOkBrowser
if (%2) == (ie) goto ReadOkBrowser
if (%2) == (i) goto ReadOkBrowser
if (%2) == (opera) goto ReadOkBrowser
if (%2) == (o) goto ReadOkBrowser
if (%2) == (safari) goto ReadOkBrowser
if (%2) == (s) goto ReadOkBrowser
goto ErrorUnknownBrowser
:ReadOkBrowser
set BROWSER!BROWSERCOUNT!=%2
set /A BROWSERCOUNT=!BROWSERCOUNT! + 1
shift
shift
goto ReadOptions

:ReadNodeParameter
set NODE=yes
shift
goto ReadOptions

:ReadFileParameter
set FILE!FILECOUNT!=%1
set /A FILECOUNT=!FILECOUNT! + 1
shift
goto ReadOptions

:ErrorMissingBrowserName
echo Error: Browser option specified without a browser name.
goto PrintUsage

:ErrorUnknownBrowser
echo Error: Browser %2 is not a known browser.
goto PrintUsage

:ErrorUnknownOption
echo Error: Unknown option %1.
goto PrintUsage

:ErrorNoFilesSpecified
echo Error: No test files specified.
goto PrintUsage

:ErrorNoTestEnvironmentsSpecified
echo Error: No test environments specified. You must specify at least one of -b or -n.
goto PrintUsage

:PrintHelp
echo JSUT is JavaScript Unit Testing. It supports running tests across browsers and
echo in Node.js keeping its influence on how you write unit tests as small as
echo possible.
echo.
echo Options:
echo   -b ^<browser^>  Run test in the specified browser. Can be repeated to specify
echo                 multiple browsers.
echo   -n            Run tests in Node.js. Requires Node.js to be present in the 
echo                 PATH of the local machine.
echo   -t ^<timeout^>  Specify how long to wait (in seconds) before terminating the
echo                 test run. This is useful if tests are waiting for asynchronous
echo                 operations to complete. 
echo                 The default timeout is %TIMEOUT% seconds.
echo   -h            Print this help text and exit.
echo.
echo Writing a unit test is as simple as writing a single argument function. Your
echo test functions will be passed a test object as their first argument. When a
echo test is done, it should call the done() function on this test object to signal
echo that it has completed successfully. To signal failure the test should either
echo contain a failing assertion, throw an exception, or call fail() on the test
echo object, optionally passing an error message as the first argument.
echo.
echo JSUT supports assertions in the style of the Node.js assert module. Please see
echo the Node.js site at http://nodejs.org for documentation on its assert module.
goto End

:PrintUsage
echo Usage: jsut [-b ^<browser^> ]* [ -nh ] ^<file^> [file ...]
goto End

:ErrorMissingBrowser
echo Error: The specified browser is not installed on your system.
goto PrintUsage

:jsut_chrome
:jsut_c
if not exist "%CHROMEEXE%" Goto ErrorMissingBrowser
"%CHROMEEXE%" "%JSUTURL%"
goto End

:jsut_firefox
:jsut_ff
:jsut_f
if not exist "%FFEXE%" goto ErrorMissingBrowser
"%FFEXE%" "%JSUTURL%"
goto End

:jsut_internetexplorer
:jsut_ie
:jsut_i
if not exist "%IEEXE%" Goto ErrorMissingBrowser
"%IEEXE%" "%JSUTURL%"
goto End

:jsut_opera
:jsut_o
if not exist "%OPERAEXE%" goto ErrorMissingBrowser
"%OPERAEXE%" "%JSUTURL%"
goto End

:jsut_safari
:jsut_s
if not exist "%SAFARIEXE%" goto ErrorMissingBrowser
"%SAFARIEXE%" "%JSUTURL%"
goto End

:FindAndReplace
setlocal disabledelayedexpansion
for /f "tokens=1,* delims=]" %%A in ('"type jsut.html|find /n /v """') do (
    set "line=%%B"
    if defined line (
        call set "line=echo.%%line:%TOFIND%=%TOREPLACE%%%"
        for /f "delims=" %%X in ('"echo."%%line%%""') do %%~X >> "%TARGETFILE%"
    ) ELSE echo. >> "%TARGETFILE%"
)
setlocal enabledelayedexpansion
goto StartTests

:Run
if %FILECOUNT% LEQ 0 goto ErrorNoFilesSpecified
if %BROWSERCOUNT% LEQ 0 (
	if not "%NODE%" == "yes" (
		goto ErrorNoTestEnvironmentsSpecified
	)
)
set hours=%TIME:~0,2%
set hours=%hours: =0%
set minutes=%TIME:~3,2%
set minutes=%minutes: =0%
set seconds=%TIME:~6,2%
set seconds=%seconds: =0%
set /a "hours=1!hours! %% 100"
set /a "minutes=1!minutes! %% 100"
set /a "seconds=1!seconds! %% 100"

set JSUTDIR=%TMP%\jsut-%DATE%-%hours%-%minutes%-%seconds%
md "%JSUTDIR%"
set JSUTURL=file://%JSUTDIR:\=/%/jsut.html

copy /y "%INSTALLDIR%\jsut.js" "%JSUTDIR%\__jsut.js" > nul
copy /y "%INSTALLDIR%\assert.js" "%JSUTDIR%\__assert.js" > nul
set TOFIND=SCRIPTS
set TOREPLACE=
:FileLoop
if %FILECOUNT% LEQ 0 goto EndFileLoop
set /A FILECOUNT=%FILECOUNT% - 1
set CURRENTFILE=!FILE%FILECOUNT%!
copy /y "%CURRENTFILE%" "%JSUTDIR%" > nul
set TOREPLACE=%TOREPLACE%^<script type="text/javascript" src="%CURRENTFILE%"^>^</script^>
goto FileLoop
:EndFileLoop
set TARGETFILE=%JSUTDIR%\jsut.html
cd %INSTALLDIR%
goto :FindAndReplace
:StartTests
cd %CURRENTDIR%
:BrowserLoop
if %BROWSERCOUNT% LEQ 0 goto EndBrowserLoop 
set /A BROWSERCOUNT=%BROWSERCOUNT% - 1
set BROWSERTORUN=!BROWSER%BROWSERCOUNT%!
goto jsut_!BROWSERTORUN!
goto BrowserLoop

:EndBrowserLoop
if (%NODE%) == (yes) goto Node
goto End

:Node
cd %JSUTDIR%
set NODEFILES=
for /f "delims=|" %%f in ('dir /b') do (
	set CURRENTFILE="%%f"
	if not "%CURRENTFILE%" == "__jsut.js" ( 
		if not "%CURRENTFILE%" == "__assert.js" (
			if "%CURRENTFILE:~-3%" == ".js" (set NODEFILES="%NODEFILES% %CURRENTFILE%")
)))
node __jsut.js %NODEFILES%
:End