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
set DEPENDENCYCOUNT=0
set FILECOUNT=0
set NODE=no

:ReadOptions
set OPT=%1
if (%OPT%) == () goto Run
if /I (%OPT%) == (-h) goto PrintHelp
if /I (%OPT%) == (-b) goto ReadBrowserParameter
if /I (%OPT%) == (-d) goto ReadDependencyParameter
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

:ReadDependencyParameter
set DEPENDENCY!DEPENDENCYCOUNT!=%2
set /A DEPENDENCYCOUNT=!DEPENDENCYCOUNT! + 1
shift
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
echo   -d ^<path^>     Add the given path to the test environment as a dependency.
echo                 Any tests in any files in the dependency path will be ignored.
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
echo Usage: jsut [-b ^<browser^> ]* [ -d ^<path^> ] [ -nh ] ^<path^> [^<path^> ...]
goto End

:ErrorMissingBrowser
echo Error: The specified browser is not installed on your system.
goto PrintUsage

:ErrorPathIsNotAFileOrDirectory
echo Error: The specified path is not a file or directory.
goto PrintUsage

:ErrorDependencyIsNotAFileOrDirectory
echo Error: The dependency "%ERRONEOUSDEPENDENCY%" is not a file or directory.
goto PrintUsage

:ErrorTestArgumentIsNotAFileOrDirectory
echo Error: "%ERRONEOUSFILE%" is not a file or directory.
goto PrintUsage

:ErrorCouldNotCreateDirectory
echo Error: Could not create directory in temporary test environment.
echo Please check that you have permissions to write to %TMP%.
goto PrintUsage

:jsut_chrome
:jsut_c
if not exist "%CHROMEEXE%" Goto ErrorMissingBrowser
"%CHROMEEXE%" "%JSUTURL%"
goto Browser

:jsut_firefox
:jsut_ff
:jsut_f
if not exist "%FFEXE%" goto ErrorMissingBrowser
"%FFEXE%" "%JSUTURL%"
goto Browser

:jsut_internetexplorer
:jsut_ie
:jsut_i
if not exist "%IEEXE%" Goto ErrorMissingBrowser
"%IEEXE%" "%JSUTURL%"
goto Browser

:jsut_opera
:jsut_o
if not exist "%OPERAEXE%" goto ErrorMissingBrowser
"%OPERAEXE%" "%JSUTURL%"
goto Browser

:jsut_safari
:jsut_s
if not exist "%SAFARIEXE%" goto ErrorMissingBrowser
"%SAFARIEXE%" "%JSUTURL%"
goto Browser

:AddFile 
if "%3" == "" (
	set FILE=%1
) else (
	set FILE=%3\%1
)

if "%COMMON_ROOT%" == "" (
	set FILE=!FILE:^:=!
) else (
	set FILE=!FILE:%COMMON_ROOT%\=!
)
set SCRIPTS=!SCRIPTS!^<script type="text/javascript" src="%FILE:\=/%"^>^<^/script^>
if "%2" == "yes" (
	call :AddNodeFile %FILE%
)
goto End

:AddNodeFile
set NODEFILE=%1
set NODEFILE=!NODEFILE:\=/!
set NODEFILES=%NODEFILES% "%NODEFILE%"
goto End

:IsDirectory 
set ATTR=%~a1
set DIRATTR=%ATTR:~0,1%
if /I "%DIRATTR%"=="d" (
  set IS_DIRECTORY=yes
) else (
  set IS_DIRECTORY=no
)
goto End

:GetDirectory
set DIRECTORY=%~dp1
goto End

:GetLastDirectoryName
set THEPATH=%1
pushd .
cd /d %THEPATH%
cd ..
set PATHBELOW=%CD%
popd
set LAST_DIRECTORY_NAME=!THEPATH:%PATHBELOW%\=!
goto End

:GetAbsolutePath
set ABSOLUTEPATH=%~f1
goto End

:GetDifference
set A=%1
set DIFFERENCE=!A:%2=!
goto End

:IsFile
set ATTR=%~a1
set FILEATTR=%ATTR:~0,1%
if "%FILEATTR%"=="-" (
  set IS_FILE=yes
) else (
  set IS_FILE=no
)
goto End

:UpdateCommonRoot
if "%COMMON_ROOT%" == "" goto End
pushd .
cd /d %1 > nul
if %ERRORLEVEL% NEQ 0 (
	set COMMON_ROOT=
	popd
	goto End
)
:ContinueSearchForCommonRoot
set CURPATH=!CD!
set PATHDIFFERENCE=!COMMON_ROOT:%CURPATH%=!
if "%PATHDIFFERENCE%" == "%COMMON_ROOT%" (
	set PREVDIR=!CD!
	cd ..
	if "%PREVDIR%" == "!CD!" (
		set COMMON_ROOT=
		popd
		goto End
	)

	goto ContinueSearchForCommonRoot
)
set COMMON_ROOT=%CURPATH%
popd
goto End

:FindAndReplace
setlocal disabledelayedexpansion
for /f "tokens=1,* delims=]" %%A in ('"type %3|find /n /v """') do (
    set "line=%%B"
    if defined line (
        call set "line=echo.%%line:%~1=%~2%%"
        for /f "delims=" %%X in ('"echo."%%line%%""') do %%~X >> "%4"
    ) else echo. >> "%4"
)
setlocal enabledelayedexpansion
goto End

:Run
if %FILECOUNT% LEQ 0 goto ErrorNoFilesSpecified
if %BROWSERCOUNT% LEQ 0 (
	if not "%NODE%" == "yes" (
		goto ErrorNoTestEnvironmentsSpecified
	)
)

call :GetAbsolutePath "%FILE0%"
set COMMON_ROOT=%ABSOLUTEPATH%
rem TODO: Validate common root

set CDCOUNT=!DEPENDENCYCOUNT!
:ValidateDependencies
if %CDCOUNT% LEQ 0 goto ContinueWithFileValidation
set /A CDCOUNT=%CDCOUNT% - 1
set TOCHECK=!DEPENDENCY%CDCOUNT%!
call :GetAbsolutePath "%TOCHECK%"
set TOCHECK=%ABSOLUTEPATH%
set ADEPENDENCY!CDCOUNT!=%ABSOLUTEPATH%
call :IsDirectory "%TOCHECK%"
if not "!IS_DIRECTORY!" == "yes" (
	call :IsFile "%TOCHECK%"
	if not "!IS_FILE!" == "yes" (
		set ERRONEOUSDEPENDENCY=!DEPENDENCY%CDCOUNT%!
		goto ErrorDependencyIsNotAFileOrDirectory
	)
	call :GetDirectory %TOCHECK%
	set TOCHECK=!DIRECTORY!
)
call :UpdateCommonRoot !TOCHECK!
goto ValidateDependencies

:ContinueWithFileValidation
set CFCOUNT=!FILECOUNT!
:ValidateFiles
if %CFCOUNT% LEQ 0 goto PrepareTestEnvironment
set /A CFCOUNT=%CFCOUNT% - 1
set TOCHECK=!FILE%CFCOUNT%!
call :GetAbsolutePath "%TOCHECK%"
set TOCHECK=%ABSOLUTEPATH%
set AFILE!CFCOUNT!=%ABSOLUTEPATH%
call :IsDirectory "%TOCHECK%"
if not "!IS_DIRECTORY!" == "yes" (
	call :IsFile "%TOCHECK%"
	if not "!IS_FILE!" == "yes" (
		set ERRONEOUSFILE=!FILE%CFCOUNT%!
		goto ErrorTestArgumentIsNotAFileOrDirectory
	)
	call :GetDirectory %TOCHECK%
	set TOCHECK=!DIRECTORY!
)
call :UpdateCommonRoot !TOCHECK!
goto ValidateFiles

:PrepareTestEnvironment
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

set SCRIPTS=
set NODEFILES=

:DependencyLoop
if %DEPENDENCYCOUNT% LEQ 0 goto FileLoop
set /A DEPENDENCYCOUNT=%DEPENDENCYCOUNT% - 1
set CURRENTDEPENDENCY=!DEPENDENCY%DEPENDENCYCOUNT%!
set THEABSOLUTEPATH=!ADEPENDENCY%DEPENDENCYCOUNT%!
if "%COMMON_ROOT%" == "" (
	set PATH_RELATIVE_TO_ROOT=!THEABSOLUTEPATH!
) else (
	set PATH_RELATIVE_TO_ROOT=!THEABSOLUTEPATH:%COMMON_ROOT%\=!
)
set PREPEND_PATH=!PATH_RELATIVE_TO_ROOT:%CURRENTDEPENDENCY%=!
if not "%PREPEND_PATH%" == "" (
	md "%JSUTDIR%\%PREPEND_PATH%"
	if %ERRORLEVEL% NEQ 0 goto ErrorCouldNotCreateDirectory
)
call :IsDirectory "%CURRENTDEPENDENCY%"
if "!IS_DIRECTORY!" == "yes" (
	call :GetLastDirectoryName "%THEABSOLUTEPATH%"
	md "%JSUTDIR%\%PREPEND_PATH%\!LAST_DIRECTORY_NAME!" > nul
	xcopy /e "%CURRENTDEPENDENCY%" "%JSUTDIR%\%PREPEND_PATH%\!LAST_DIRECTORY_NAME!" > nul
	for /f "delims=|" %%f in ('dir /b /s "%CURRENTDEPENDENCY%\"') do (call :AddFile %%~ff "no" %PREPEND_PATH%)
) else (
	set ARGUMENT_PATH=
	set PATHSTART=!THEABSOLUTEPATH:%CURRENTDEPENDENCY%=!
	if not "!PATHSTART!" == "" (
		call :GetDirectory %CURRENTDEPENDENCY%
		call :GetDifference !DIRECTORY! !PATHSTART!
		set ARGUMENT_PATH=!DIFFERENCE!
		md "%JSUTDIR%\%PREPEND_PATH%\!ARGUMENT_PATH!" > nul
	)
	copy /y "%CURRENTDEPENDENCY%" "%JSUTDIR%\%PREPEND_PATH%\!ARGUMENT_PATH!" > nul
	call :AddFile %CURRENTDEPENDENCY% "no" %PREPEND_PATH%
)
goto DependencyLoop

:FileLoop
if %FILECOUNT% LEQ 0 goto WriteScriptsToHtmlFile
set /A FILECOUNT=%FILECOUNT% - 1
set CURRENTFILE=!FILE%FILECOUNT%!
set THEABSOLUTEPATH=!AFILE%FILECOUNT%!
if "%COMMON_ROOT%" == "" (
	set PATH_RELATIVE_TO_ROOT=!THEABSOLUTEPATH!
) else (
	set PATH_RELATIVE_TO_ROOT=!THEABSOLUTEPATH:%COMMON_ROOT%\=!
)
set PREPEND_PATH=!PATH_RELATIVE_TO_ROOT:%CURRENTFILE%=!
if not "%PREPEND_PATH%" == "" (
	md "%JSUTDIR%\%PREPEND_PATH%"
	if %ERRORLEVEL% NEQ 0 goto ErrorCouldNotCreateDirectory
)
call :IsDirectory "%CURRENTFILE%"
if "!IS_DIRECTORY!" == "yes" (
	call :GetLastDirectoryName "%THEABSOLUTEPATH%"
	md "%JSUTDIR%\%PREPEND_PATH%\!LAST_DIRECTORY_NAME!" > nul
	xcopy /e "%CURRENTFILE%" "%JSUTDIR%\%PREPEND_PATH%\!LAST_DIRECTORY_NAME!" > nul
	for /f  "delims=|" %%f in ('dir /b /s "%CURRENTFILE%\"') do (call :AddFile %%~ff %NODE% %PREPEND_PATH%)
) else (
	set ARGUMENT_PATH=
	set PATHSTART=!THEABSOLUTEPATH:%CURRENTFILE%=!
	if not "!PATHSTART!" == "" (
		call :GetDirectory %CURRENTFILE%
		call :GetDifference !DIRECTORY! !PATHSTART!
		set ARGUMENT_PATH=!DIFFERENCE!
		md "%JSUTDIR%\%PREPEND_PATH%\!ARGUMENT_PATH!" > nul
	)
	copy /y "%CURRENTFILE%" "%JSUTDIR%\%PREPEND_PATH%\!ARGUMENT_PATH!" > nul
	call :AddFile %CURRENTFILE% %NODE% %PREPEND_PATH%
)
goto FileLoop

:WriteScriptsToHtmlFile
call :FindAndReplace SCRIPTS "%SCRIPTS%" "%INSTALLDIR%\jsut.html" "%JSUTDIR%\jsut.html"
:StartTests
cd /d %CURRENTDIR%

:Browser
if %BROWSERCOUNT% LEQ 0 goto Node 
set /A BROWSERCOUNT=%BROWSERCOUNT% - 1
set BROWSERTORUN=!BROWSER%BROWSERCOUNT%!
goto jsut_!BROWSERTORUN!

:Node
if not "%NODE%" == "yes" goto End
cd /d "%JSUTDIR%"
node __jsut.js %NODEFILES%
:End