@echo off
echo ============================================
echo Windows Packet Filter System Installer
echo ============================================
echo.

REM Check if running as administrator
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo ERROR: This script must be run as Administrator
    echo Right-click and select "Run as administrator"
    pause
    exit /b 1
)

echo WARNING: This will install kernel-level drivers on your system.
echo Make sure you trust this software and have built it from source.
echo.
set /p confirm="Do you want to continue? (Y/N): "
if /i not "%confirm%"=="Y" (
    echo Installation cancelled.
    pause
    exit /b 0
)

echo.
echo Creating required directories...
if not exist "C:\PacketFilterLogs" (
    mkdir "C:\PacketFilterLogs"
    echo Created log directory: C:\PacketFilterLogs
)

echo.
echo Checking if test signing is enabled...
bcdedit /enum | findstr testsigning | findstr Yes >nul
if %errorLevel% neq 0 (
    echo WARNING: Test signing is not enabled!
    echo You need to enable test signing and reboot:
    echo   bcdedit /set testsigning on
    echo   shutdown /r /t 0
    echo.
    set /p enabletest="Enable test signing now? (Y/N): "
    if /i "%enabletest%"=="Y" (
        bcdedit /set testsigning on
        echo Test signing enabled. Please reboot and run this script again.
        pause
        exit /b 0
    ) else (
        echo Continuing without test signing. Driver may fail to load.
    )
)

echo.
echo Installing NDIS Filter Driver...
if exist "BasicNdisFilter\x64\Release\BasicNdisFilter.inf" (
    cd BasicNdisFilter\x64\Release
    netcfg -v -l BasicNdisFilter.inf -c s -i MS_BasicNdisFilter
    if %errorLevel% neq 0 (
        echo ERROR: Driver installation failed
        echo Check Event Viewer for details
        cd ..\..\..
        pause
        exit /b 1
    )
    echo Driver installed successfully
    cd ..\..\..
) else (
    echo ERROR: Driver files not found in BasicNdisFilter\x64\Release\
    echo Please build the project first using build.bat
    pause
    exit /b 1
)

echo.
echo Installing Windows Service...
if exist "PacketFilterService\bin\Release\PacketFilterService.exe" (
    REM Stop service if it exists
    sc query PacketFilterService >nul 2>&1
    if %errorLevel% equ 0 (
        echo Stopping existing service...
        sc stop PacketFilterService >nul 2>&1
        sc delete PacketFilterService >nul 2>&1
    )
    
    REM Get full path to service executable
    set "servicePath=%CD%\PacketFilterService\bin\Release\PacketFilterService.exe"
    
    REM Create and start service
    sc create PacketFilterService binPath="%servicePath%" start=auto DisplayName="Packet Filter Service"
    if %errorLevel% neq 0 (
        echo ERROR: Service creation failed
        pause
        exit /b 1
    )
    
    sc start PacketFilterService
    if %errorLevel% neq 0 (
        echo WARNING: Service failed to start
        echo Check Event Viewer for details
    ) else (
        echo Service installed and started successfully
    )
) else (
    echo ERROR: Service executable not found in PacketFilterService\bin\Release\
    echo Please build the project first using build.bat
    pause
    exit /b 1
)

echo.
echo ============================================
echo Installation completed!
echo ============================================
echo.
echo Service Status:
sc query PacketFilterService
echo.
echo Log files will be written to: C:\PacketFilterLogs\
echo Monitor logs with: powershell "Get-Content C:\PacketFilterLogs\log.txt -Wait -Tail 10"
echo.
echo To uninstall:
echo   sc stop PacketFilterService
echo   sc delete PacketFilterService
echo   netcfg -v -u MS_BasicNdisFilter
echo.
pause 