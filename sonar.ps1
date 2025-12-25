<#
.SYNOPSIS
    SonarQube Management CLI
.DESCRIPTION
    Script to manage SonarQube server and scanner operations easily.
.EXAMPLE
    .\sonar.ps1 start
    .\sonar.ps1 scan
#>

param (
    [Parameter(Position = 0)]
    [ValidateSet("start", "stop", "scan", "restart", "status", "logs", "help")]
    [string]$Command = "help",

    [Parameter(Position = 1)]
    [string]$Token = ""
)

$ComposeFile = "docker-compose.yml"
$ScanComposeFile = "docker-compose-scan.yml"

# Detect if we're in a subfolder of a project
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$CurrentDir = Get-Location

# If script is in sonarqube/ subfolder, adjust paths
if ($ScriptDir -match "sonarqube$") {
    $ComposeFile = Join-Path $ScriptDir "docker-compose.yml"
    $ScanComposeFile = Join-Path $ScriptDir "docker-compose-scan.yml"
    $ScanPath = Split-Path -Parent $ScriptDir  # Parent directory (the project root)
}
else {
    $ComposeFile = "sonarqube/docker-compose.yml"
    $ScanComposeFile = "docker-compose-scan.yml"
    $ScanPath = $CurrentDir
}

function Show-Help {
    Write-Host "SonarQube Manager CLI" -ForegroundColor Cyan
    Write-Host "------------------------"
    Write-Host "Usage: .\sonar.ps1 [command] [token]"
    Write-Host ""
    Write-Host "Commands:"
    Write-Host "  start   : Start SonarQube server and database"
    Write-Host "  stop    : Stop all services"
    Write-Host "  scan    : Run SonarScanner (use -Token '...' for auth)"
    Write-Host "  restart : Restart the server"
    Write-Host "  status  : Check container status"
    Write-Host "  logs    : View server logs (Ctrl+C to exit)"
    Write-Host "  help    : Show this help message"
    Write-Host ""
}

function Get-AuthHeader ($u, $p) {
    $base64 = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("$($u):$($p)"))
    return @{ Authorization = "Basic $base64" }
}

# Check if docker is available
if (-not (Get-Command "docker" -ErrorAction SilentlyContinue)) {
    Write-Error "Docker is not installed or not in PATH."
    exit 1
}

switch ($Command) {
    "start" {
        Write-Host "Starting SonarQube Server..." -ForegroundColor Green
        docker compose -f $ComposeFile up -d
        Write-Host "`nServices started!" -ForegroundColor Green
        Write-Host "   Web UI: http://localhost:9000"
        Write-Host "   (It may take 1-2 minutes for the server to be fully ready)"
    }
    "stop" {
        Write-Host "Stopping SonarQube Services..." -ForegroundColor Yellow
        docker compose -f $ComposeFile down
        Write-Host "Services stopped." -ForegroundColor Green
    }
    "scan" {
        Write-Host "Starting Code Analysis..." -ForegroundColor Cyan
        
        # 1. Ensure Server is Running
        $serverStatus = docker compose -f $ComposeFile ps -q sonarqube
        if (-not $serverStatus) {
            Write-Warning "SonarQube server is not running. Starting it now..."
            docker compose -f $ComposeFile up -d
            Write-Host "Waiting for server to start..." -ForegroundColor Yellow
        }

        # 2. Wait for API to be ready
        $retryCount = 0
        $maxRetries = 60 
        $sonarUrl = "http://localhost:9000"
        
        Write-Host "Checking SonarQube API status..." -NoNewline
        do {
            try {
                $response = Invoke-RestMethod -Uri "$sonarUrl/api/system/status" -Method Get -ErrorAction Stop
                if ($response.status -eq "UP") {
                    Write-Host " UP!" -ForegroundColor Green
                    break
                }
            }
            catch {
                Write-Host "." -NoNewline
            }
            Start-Sleep -Seconds 5
            $retryCount++
        } while ($retryCount -lt $maxRetries)

        if ($retryCount -ge $maxRetries) {
            Write-Error "`nSonarQube server failed to become ready. Check logs with '.\sonar.ps1 logs'"
            exit 1
        }

        # 3. Auto-Auth & Token Generation (if token not provided)
        if ([string]::IsNullOrWhiteSpace($Token)) {
            Write-Host "No token provided. Attempting auto-configuration..." -ForegroundColor Cyan
            
            $user = "admin"
            $defaultPass = "admin"
            $newPass = "Admin@123456" 
            $tokenName = "ci-token-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
            
            # Try Default Password (admin:admin)
            try {
                # Attempt to change password
                Invoke-RestMethod -Uri "$sonarUrl/api/users/change_password?login=$user&previousPassword=$defaultPass&password=$newPass" -Method Post -Headers (Get-AuthHeader $user $defaultPass) -ErrorAction Stop | Out-Null
                
                Write-Host "Default password changed to '$newPass'" -ForegroundColor Green
                $currentPass = $newPass
            }
            catch {
                # If 401, maybe password was already changed? Try the new password.
                $currentPass = $newPass
                try {
                    Invoke-RestMethod -Uri "$sonarUrl/api/authentication/validate" -Method Get -Headers (Get-AuthHeader $user $currentPass) -ErrorAction Stop | Out-Null
                    Write-Host "Using existing password '$newPass'" -ForegroundColor Gray
                }
                catch {
                    Write-Error "Could not authenticate with 'admin'/'admin' or 'admin'/'$newPass'. Please provide a token manually."
                    exit 1
                }
            }

            # Generate Token
            try {
                $tokenResp = Invoke-RestMethod -Uri "$sonarUrl/api/user_tokens/generate?name=$tokenName" -Method Post -Headers (Get-AuthHeader $user $currentPass) -ErrorAction Stop
                $Token = $tokenResp.token
                Write-Host "Generated temporary token: $Token" -ForegroundColor Green
            }
            catch {
                Write-Error "Failed to generate token: $_"
                exit 1
            }
        }

        # 4. Run the scanner
        $Env:SONAR_TOKEN = $Token
        
        Write-Host "`nScanning directory: $ScanPath" -ForegroundColor Cyan
        Write-Host "----------------------------------------`n" -ForegroundColor Cyan
        
        # Use docker run instead of docker-compose for more flexibility
        $absoluteScanPath = Resolve-Path $ScanPath
        docker run --rm `
            --network sonarqube_sonarqube-network `
            -v "${absoluteScanPath}:/usr/src" `
            -e SONAR_HOST_URL=http://sonarqube:9000 `
            -e SONAR_TOKEN=$Token `
            sonarsource/sonar-scanner-cli
        
        # 5. Check Result
        if ($LASTEXITCODE -eq 0) {
            Write-Host "`n"
            Write-Host "----------------------------------------" -ForegroundColor Green
            Write-Host "       QUALITY GATE PASSED        " -ForegroundColor Green
            Write-Host "----------------------------------------" -ForegroundColor Green
            
            # Extract Project Key safely
            $projectKey = "unknown"
            try {
                $props = Get-Content "sonar-project.properties" -ErrorAction SilentlyContinue
                foreach ($line in $props) {
                    if ($line -match "sonar.projectKey=(.*)") {
                        $projectKey = $matches[1].Trim()
                        break
                    }
                }
            }
            catch {}
            
            Write-Host "Report: $sonarUrl/dashboard?id=$projectKey"
        }
        else {
            Write-Host "`n"
            Write-Host "----------------------------------------" -ForegroundColor Red
            Write-Host "       QUALITY GATE FAILED        " -ForegroundColor Red
            Write-Host "----------------------------------------" -ForegroundColor Red
            Write-Host "Please check the dashboard for details."
        }
    }
    "restart" {
        Write-Host "Restarting services..." -ForegroundColor Yellow
        docker compose -f $ComposeFile restart
    }
    "status" {
        docker compose -f $ComposeFile ps
    }
    "logs" {
        docker compose -f $ComposeFile logs -f
    }
    "help" {
        Show-Help
    }
    Default {
        Show-Help
    }
}
