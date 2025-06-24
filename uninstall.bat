@echo off
echo ============================================
echo Windows Packet Filter System Uninstaller
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

echo This will remove the Packet Filter System from your computer.
echo.
set /p confirm="Do you want to continue? (Y/N): "
if /i not "%confirm%"=="Y" (
    echo Uninstallation cancelled.
    pause
    exit /b 0
)

echo.
echo Stopping and removing Windows Service...
sc query PacketFilterService >nul 2>&1
if %errorLevel% equ 0 (
    echo Stopping service...
    sc stop PacketFilterService
    timeout /t 3 /nobreak >nul
    
    echo Removing service...
    sc delete PacketFilterService
    if %errorLevel% equ 0 (
        echo Service removed successfully
    ) else (
        echo WARNING: Failed to remove service
    )
) else (
    echo Service not found or already removed
)

echo.
echo Removing NDIS Filter Driver...
netcfg -v -u MS_BasicNdisFilter
if %errorLevel% equ 0 (
    echo Driver removed successfully
) else (
    echo WARNING: Failed to remove driver or driver not installed
)

echo.
echo Cleaning up log directory...
if exist "C:\PacketFilterLogs" (
    set /p cleanlog="Remove log directory C:\PacketFilterLogs? (Y/N): "
    if /i "%cleanlog%"=="Y" (
        rmdir /s /q "C:\PacketFilterLogs"
        echo Log directory removed
    ) else (
        echo Log directory preserved
    )
) else (
    echo Log directory not found
)

echo.
echo Checking test signing status...
bcdedit /enum | findstr testsigning | findstr Yes >nul
if %errorLevel% equ 0 (
    echo Test signing is currently enabled.
    echo You may want to disable it if you're not using other test drivers:
    echo   bcdedit /set testsigning off
    echo   shutdown /r /t 0
    echo.
    set /p disabletest="Disable test signing now? (Y/N): "
    if /i "%disabletest%"=="Y" (
        bcdedit /set testsigning off
        echo Test signing disabled. You should reboot for changes to take effect.
        set /p reboot="Reboot now? (Y/N): "
        if /i "%reboot%"=="Y" (
            shutdown /r /t 10
            echo System will reboot in 10 seconds...
        )
    )
)

echo.
echo ============================================
echo Uninstallation completed!
echo ============================================
echo.
echo The Packet Filter System has been removed from your computer.
echo.
pause 