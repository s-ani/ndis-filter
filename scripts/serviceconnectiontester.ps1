#  example: .\Invoke-PipeCheck.ps1 -PipeName "PacketFilterPipe" -AddressPort "192.168.1.10:8080"

param(
    [Parameter(Mandatory=$true)]
    [string]$PipeName,

    [Parameter(Mandatory=$true)]
    [string]$AddressPort
)

try {
    # 1. Create and connect the pipe client
    $pipe = [System.IO.Pipes.NamedPipeClientStream]::new(
        ".", $PipeName,
        [System.IO.Pipes.PipeDirection]::InOut,
        [System.IO.Pipes.PipeOptions]::None
    )
    Write-Host "Connecting to \\.\pipe\$PipeName..." -NoNewline
    $pipe.Connect(5000)  # 5-second timeout
    Write-Host " OK"

    # 2. Send the IP:Port
    $writer = [System.IO.StreamWriter]::new($pipe)
    $writer.AutoFlush = $true
    Write-Host "Sending: $AddressPort"
    $writer.WriteLine($AddressPort)

    # 3. Read a single-byte response (0 or 1)
    $reader = [System.IO.BinaryReader]::new($pipe)
    $respByte = $reader.ReadByte()
    Write-Host "Received response byte:" $respByte

    # 4. Interpret and print
    switch ($respByte) {
        0 { Write-Host "→ Decision: BLOCK" }
        1 { Write-Host "→ Decision: ALLOW" }
        default { Write-Host "→ Unexpected response: $respByte" }
    }
}
catch {
    Write-Error "Error: $_"
}
finally {
    # Clean up
    if ($writer) { $writer.Dispose() }
    if ($reader) { $reader.Dispose() }
    if ($pipe)   { $pipe.Dispose() }
}
