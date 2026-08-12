param(
    [Parameter(Mandatory = $true)]
    [ValidateSet("start", "stop", "restart", "status")]
    [string]$Action
)

$Port = 8080
$ProjectDir = $PSScriptRoot
$LogFile = Join-Path $ProjectDir "server.log"

function Test-PortListening {
    return $null -ne (Get-NetTCPConnection -LocalPort $Port -State Listen -ErrorAction SilentlyContinue)
}

function Get-ServerProcesses {
    Get-CimInstance Win32_Process -ErrorAction SilentlyContinue |
        Where-Object {
            $_.CommandLine -and (
                $_.CommandLine -like "*web-port=$Port*" -or
                $_.CommandLine -like "*$ProjectDir*"
            )
        }
}

function Start-Server {
    if (Test-PortListening) {
        Write-Host "O servidor ja esta rodando em http://localhost:$Port" -ForegroundColor Yellow
        return
    }
    Write-Host "Iniciando servidor em segundo plano..." -ForegroundColor Cyan
    $cmdLine = "/c cd /d `"$ProjectDir`" && flutter run -d web-server --web-port=$Port > `"$LogFile`" 2>&1"
    Start-Process -FilePath "cmd.exe" -ArgumentList $cmdLine -WindowStyle Hidden
    Start-Sleep -Seconds 3
    if (Test-PortListening) {
        Write-Host "Servidor rodando em http://localhost:$Port" -ForegroundColor Green
    } else {
        Write-Host "Ainda iniciando... confira o log em alguns segundos (opcao 'Ver log')." -ForegroundColor Yellow
    }
}

function Stop-Server {
    $procs = Get-ServerProcesses
    if (-not $procs) {
        Write-Host "Nenhum servidor rodando." -ForegroundColor Yellow
        return
    }
    foreach ($p in $procs) {
        Stop-Process -Id $p.ProcessId -Force -ErrorAction SilentlyContinue
    }
    Start-Sleep -Seconds 1
    Write-Host "Servidor parado." -ForegroundColor Green
}

switch ($Action) {
    "start"   { Start-Server }
    "stop"    { Stop-Server }
    "restart" { Stop-Server; Start-Sleep -Seconds 1; Start-Server }
    "status"  {
        if (Test-PortListening) {
            Write-Host "Status: RODANDO em http://localhost:$Port" -ForegroundColor Green
        } else {
            Write-Host "Status: PARADO" -ForegroundColor Red
        }
    }
}
