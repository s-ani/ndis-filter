@echo off
echo ============================================
echo Windows Packet Filter System Build Script
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

echo Building NDIS Filter Driver...
echo.

REM Build the driver
cd BasicNdisFilter
if exist "BasicNdisFilter.sln" (
    echo Found driver solution file
    msbuild BasicNdisFilter.sln /p:Configuration=Release /p:Platform=x64
    if %errorLevel% neq 0 (
        echo ERROR: Driver build failed
        pause
        exit /b 1
    )
    echo Driver build completed successfully
) else (
    echo ERROR: Cannot find BasicNdisFilter.sln
    pause
    exit /b 1
)

cd ..
echo.

echo Building Windows Service...
echo.

REM Build the service
cd PacketFilterService
if exist "PacketFilterService.sln" (
    echo Found service solution file
    msbuild PacketFilterService.sln /p:Configuration=Release
    if %errorLevel% neq 0 (
        echo ERROR: Service build failed
        pause
        exit /b 1
    )
    echo Service build completed successfully
) else (
    echo ERROR: Cannot find PacketFilterService.sln
    pause
    exit /b 1
)

cd ..
echo.

echo ============================================
echo Build completed successfully!
echo ============================================
echo.
echo Driver output: BasicNdisFilter\x64\Release\
echo Service output: PacketFilterService\bin\Release\
echo.
echo Next steps:
echo 1. Enable test signing: bcdedit /set testsigning on
echo 2. Reboot your system
echo 3. Install driver: netcfg -v -l BasicNdisFilter.inf -c s -i MS_BasicNdisFilter
echo 4. Install service: sc create PacketFilterService binPath="[path]\PacketFilterService.exe"
echo.
pause 