@echo off
setlocal EnableExtensions EnableDelayedExpansion
title Local 240x240 MJPEG Converter

REM ============================================================
REM SELF-ELEVATE TO ADMINISTRATOR
REM ============================================================
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo Requesting Administrator permission...
    powershell.exe -NoProfile -ExecutionPolicy Bypass -Command ^
        "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

REM ============================================================
REM LOCATIONS
REM ============================================================
cd /d "%~dp0"

set "ROOT=%~dp0"
set "FFMPEG_DIR=%ROOT%ffmpeg"
set "FFMPEG_BIN=%FFMPEG_DIR%\bin"
set "FFMPEG=%FFMPEG_BIN%\ffmpeg.exe"

set "IN=%ROOT%In"
set "OUT=%ROOT%Out"

REM Use Windows TEMP for downloading/extracting.
set "DOWNLOAD=%TEMP%\ffmpeg_%RANDOM%%RANDOM%.zip"
set "EXTRACT=%TEMP%\ffmpeg_extract_%RANDOM%%RANDOM%"

REM ============================================================
REM CREATE FOLDERS
REM ============================================================
if not exist "%IN%" mkdir "%IN%"
if not exist "%OUT%" mkdir "%OUT%"

REM ============================================================
REM CHECK LOCAL FFMPEG
REM ============================================================
if exist "%FFMPEG%" goto FFMPEG_READY

echo.
echo ============================================================
echo FFmpeg is not installed locally.
echo.
echo Downloading FFmpeg...
echo ============================================================
echo.

REM ============================================================
REM DOWNLOAD FFmpeg
REM Uses curl.exe instead of PowerShell Invoke-WebRequest.
REM Windows 10/11 normally includes curl.exe.
REM ============================================================

where curl.exe >nul 2>&1

if %errorlevel% neq 0 (
    echo ERROR: curl.exe was not found.
    echo.
    echo Windows curl is required for the first installation.
    echo.
    pause
    exit /b 1
)

curl.exe -L ^
    --fail ^
    --retry 5 ^
    --retry-delay 2 ^
    -o "%DOWNLOAD%" ^
    "https://www.gyan.dev/ffmpeg/builds/ffmpeg-release-essentials.zip"

if errorlevel 1 (
    echo.
    echo ============================================================
    echo ERROR: FFmpeg download failed.
    echo ============================================================
    echo.
    if exist "%DOWNLOAD%" del /q "%DOWNLOAD%" >nul 2>&1
    pause
    exit /b 1
)

if not exist "%DOWNLOAD%" (
    echo.
    echo ERROR: FFmpeg ZIP was not downloaded.
    pause
    exit /b 1
)

echo.
echo Download complete.
echo Extracting FFmpeg...
echo.

REM ============================================================
REM EXTRACT
REM ============================================================

powershell.exe -NoProfile -ExecutionPolicy Bypass -Command ^
    "Expand-Archive -LiteralPath '%DOWNLOAD%' -DestinationPath '%EXTRACT%' -Force"

if errorlevel 1 (
    echo.
    echo ERROR: Could not extract FFmpeg.
    del /q "%DOWNLOAD%" >nul 2>&1
    rmdir /s /q "%EXTRACT%" >nul 2>&1
    pause
    exit /b 1
)

REM ============================================================
REM FIND EXTRACTED FFMPEG
REM ============================================================

set "FOUND="

for /d %%D in ("%EXTRACT%\ffmpeg-*") do (
    if exist "%%D\bin\ffmpeg.exe" (
        set "FOUND=%%D"
        goto FOUND_FFMPEG
    )
)

:FOUND_FFMPEG

if not defined FOUND (
    echo.
    echo ERROR: ffmpeg.exe was not found after extraction.
    echo.
    del /q "%DOWNLOAD%" >nul 2>&1
    rmdir /s /q "%EXTRACT%" >nul 2>&1
    pause
    exit /b 1
)

REM ============================================================
REM COPY FFMPEG LOCALLY
REM ============================================================

echo Installing local FFmpeg...

if not exist "%FFMPEG_DIR%" mkdir "%FFMPEG_DIR%"
if not exist "%FFMPEG_BIN%" mkdir "%FFMPEG_BIN%"

xcopy "%FOUND%\bin\*" "%FFMPEG_BIN%\" /E /I /Y >nul

if not exist "%FFMPEG%" (
    echo.
    echo ERROR: Local FFmpeg installation failed.
    del /q "%DOWNLOAD%" >nul 2>&1
    rmdir /s /q "%EXTRACT%" >nul 2>&1
    pause
    exit /b 1
)

REM ============================================================
REM CLEAN TEMP FILES
REM ============================================================

del /q "%DOWNLOAD%" >nul 2>&1
rmdir /s /q "%EXTRACT%" >nul 2>&1

echo.
echo ============================================================
echo FFmpeg installed locally:
echo %FFMPEG%
echo ============================================================
echo.

:FFMPEG_READY

REM ============================================================
REM VERIFY FFMPEG
REM ============================================================

"%FFMPEG%" -version >nul 2>&1

if errorlevel 1 (
    echo.
    echo ERROR: Local FFmpeg exists but cannot be executed.
    echo.
    echo Location:
    echo %FFMPEG%
    echo.
    pause
    exit /b 1
)

echo.
echo ============================================================
echo LOCAL 240x240 MJPEG CONVERTER
echo ============================================================
echo.
echo FFmpeg:
echo %FFMPEG%
echo.
echo Input folder:
echo %IN%
echo.
echo Output folder:
echo %OUT%
echo.
echo ============================================================
echo.

REM ============================================================
REM FIND VIDEOS
REM ============================================================

set "FOUND_VIDEO=0"

for %%E in (
    mp4
    mov
    mkv
    avi
    webm
    m4v
    mpg
    mpeg
    ts
    mts
    m2ts
    flv
) do (
    for %%F in ("%IN%\*.%%E") do (
        if exist "%%~fF" (
            set "FOUND_VIDEO=1"
            call :CONVERT "%%~fF"
        )
    )
)

if "%FOUND_VIDEO%"=="0" (
    echo.
    echo No supported videos were found.
    echo.
    echo Put your video files inside:
    echo %IN%
    echo.
    echo Supported formats:
    echo MP4 MOV MKV AVI WEBM M4V MPG MPEG TS MTS M2TS FLV
    echo.
    pause
    exit /b 0
)

echo.
echo ============================================================
echo CONVERSION COMPLETE
echo ============================================================
echo.
echo Output:
echo %OUT%
echo.
pause
exit /b 0


REM ============================================================
REM CONVERSION FUNCTION
REM ============================================================

:CONVERT

set "SOURCE=%~1"
set "NAME=%~n1"

set "FINAL=%OUT%\%NAME%.mjpeg"
set "TEMP_OUTPUT=%OUT%\.%NAME%.mjpeg.tmp"

echo.
echo ------------------------------------------------------------
echo INPUT:
echo %SOURCE%
echo ------------------------------------------------------------
echo.

REM ============================================================
REM FILTER
REM
REM min(iw,ih) = shorter dimension
REM
REM crop:
REM   width  = shorter dimension
REM   height = shorter dimension
REM
REM This means:
REM
REM 1920x1080
REM -> 1080x1080
REM -> 240x240
REM
REM 1080x1920
REM -> 1080x1080
REM -> 240x240
REM
REM 1280x720
REM -> 720x720
REM -> 240x240
REM
REM No stretching.
REM No distortion.
REM Center crop.
REM
REM Lanczos gives high-quality downscaling.
REM ============================================================

if exist "%TEMP_OUTPUT%" del /q "%TEMP_OUTPUT%" >nul 2>&1

"%FFMPEG%" ^
    -hide_banner ^
    -loglevel warning ^
    -stats ^
    -y ^
    -i "%SOURCE%" ^
    -map 0:v:0 ^
    -vf "crop=min(iw\,ih):min(iw\,ih):(iw-min(iw\,ih))/2:(ih-min(iw\,ih))/2,scale=240:240:flags=lanczos" ^
    -r 24 ^
    -fps_mode cfr ^
    -c:v mjpeg ^
    -q:v 2 ^
    -pix_fmt yuvj420p ^
    -an ^
    -f mjpeg ^
    "%TEMP_OUTPUT%"

if errorlevel 1 (
    echo.
    echo ============================================================
    echo FAILED
    echo ============================================================
    echo %SOURCE%
    echo.
    echo Temporary output has been removed.
    echo.
    del /q "%TEMP_OUTPUT%" >nul 2>&1
    exit /b 1
)

REM ============================================================
REM VERIFY OUTPUT
REM ============================================================

if not exist "%TEMP_OUTPUT%" (
    echo.
    echo ERROR: FFmpeg did not create an output file.
    exit /b 1
)

for %%A in ("%TEMP_OUTPUT%") do set "FILESIZE=%%~zA"

if "%FILESIZE%"=="0" (
    echo.
    echo ERROR: Output file is empty.
    del /q "%TEMP_OUTPUT%" >nul 2>&1
    exit /b 1
)

REM ============================================================
REM MOVE ONLY AFTER SUCCESSFUL ENCODE
REM ============================================================

move /Y "%TEMP_OUTPUT%" "%FINAL%" >nul

if errorlevel 1 (
    echo.
    echo ERROR: Could not move completed output.
    del /q "%TEMP_OUTPUT%" >nul 2>&1
    exit /b 1
)

echo.
echo SUCCESS:
echo %FINAL%
echo.

exit /b 0