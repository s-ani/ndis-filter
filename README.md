﻿# Windows Packet Filter System (Initial Draft)

A Windows network packet filtering system consisting of an NDIS lightweight filter driver and a companion Windows service for real-time packet decision making.

## Overview

This project provides a complete packet filtering solution for Windows:

- **BasicNdisFilter**: NDIS 6.x lightweight filter driver that intercepts network packets at the kernel level
- **PacketFilterService**: Windows service that makes allow/block decisions via named pipe communication

The system works by having the driver capture network traffic and communicate with the service through named pipes to determine whether packets should be allowed or blocked based on configurable rules.

## Architecture

```
Network Packets → NDIS Filter Driver → Named Pipe → Windows Service → Decision Engine
                                                                           ↓
                                                                      Log Files
```

## Prerequisites

### Development Environment

- **Visual Studio 2019/2022** with C++ and C# workloads
- **Windows Driver Kit (WDK) 10** or later
- **Windows SDK 10** or later
- **.NET Framework 4.5** or later

### Target System Requirements

- **Windows 10/11** (x64 recommended)
- **Administrator privileges** (required for driver installation)
- **Test signing enabled** or **properly signed driver** for production

## Building the Project

### 1. Build the NDIS Filter Driver

```cmd
# Open BasicNdisFilter/BasicNdisFilter.sln in Visual Studio
# Select Debug x64 or Release x64 configuration
# Build solution (Ctrl+Shift+B)
# Output: BasicNdisFilter/x64/{Debug|Release}/BasicNdisFilter.sys
```

### 2. Build the Windows Service

```cmd
# Open PacketFilterService/PacketFilterService.sln in Visual Studio
# Select Release configuration
# Build solution
# Output: PacketFilterService/bin/Release/PacketFilterService.exe
```

## Installation

### Step 1: Enable Test Signing (Development Only)

```cmd
# Enable test signing (requires reboot)
bcdedit /set testsigning on
# Reboot your system
shutdown /r /t 0
```

### Step 2: Create Required Directories

```cmd
# Create log directory
mkdir C:\PacketFilterLogs
```

### Step 3: Install the Driver

```cmd
# Navigate to driver output directory
cd BasicNdisFilter\x64\Release\BasicNdisFilter

# Install using pnputil, netcfg or devcon
pnputil /add-driver BasicNdisFilter.inf /install
devcon install BasicNdisFilter.inf MS_BasicNdisFilter
netcfg -v -l BasicNdisFilter.inf -c s -i MS_BasicNdisFilter

# Alternatively, you can install the driver manually through Device Manager as described [here](https://learn.microsoft.com/en-us/samples/microsoft/windows-driver-samples/ndis-60-filter-driver/) in Manual deployment
```

### Step 4: Install and Start the Service

```cmd
# Navigate to service output directory
cd PacketFilterService\bin\Release

# Create service
sc create PacketFilterService binPath="%CD%\PacketFilterService.exe" start=auto

# Start service
sc start PacketFilterService
```

## Usage & Monitoring

### Check Service Status

```cmd
sc query PacketFilterService
```

### View Real-time Logs

```cmd
# View log file
type C:\PacketFilterLogs\log.txt

# Monitor in real-time
powershell "Get-Content C:\PacketFilterLogs\log.txt -Wait -Tail 10"
```

### Example Log Output

```
[2024-01-20 14:30:15] 192.168.1.50:80 => ALLOW
[2024-01-20 14:30:16] 192.168.1.100:443 => BLOCK
[2024-01-20 14:30:17] 10.0.0.1:22 => BLOCK
```

## Uninstallation

### Remove Service

```cmd
sc stop PacketFilterService
sc delete PacketFilterService
```

### Remove Driver

```cmd
netcfg -v -u MS_BasicNdisFilter
```

### Disable Test Signing (Optional)

```cmd
bcdedit /set testsigning off
# Reboot required
shutdown /r /t 0
```

### Debug Commands

```cmd
# Check driver status
sc query BasicNdisFilter

# Check service status  
sc query PacketFilterService

# View system events
eventvwr.msc
```
