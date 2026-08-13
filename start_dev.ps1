# ============================================================
#  KneaYerng Dev Launcher
#  Starts Laravel + ngrok, then prints the Flutter run command
# ============================================================

$backendPath  = "$PSScriptRoot\backend"
$flutterPath  = "$PSScriptRoot\app_ky_service_center"

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "   KneaYerng Service Center - Dev Mode  " -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check ngrok is installed
if (-not (Get-Command ngrok -ErrorAction SilentlyContinue)) {
    Write-Host "[ERROR] ngrok is not installed or not in PATH." -ForegroundColor Red
    Write-Host "  Download from: https://ngrok.com/download" -ForegroundColor Yellow
    exit 1
}

# Start Laravel in a new window
Write-Host "[1/3] Starting Laravel backend..." -ForegroundColor Green
Start-Process powershell -ArgumentList "-NoExit", "-Command", `
    "Set-Location '$backendPath'; php artisan serve --host=0.0.0.0 --port=8000" `
    -WindowStyle Normal

Start-Sleep -Seconds 3

# Start ngrok in a new window
Write-Host "[2/3] Starting ngrok tunnel on port 8000..." -ForegroundColor Green
Start-Process powershell -ArgumentList "-NoExit", "-Command", `
    "ngrok http 8000" `
    -WindowStyle Normal

Write-Host "      Waiting for ngrok to initialize..." -ForegroundColor Gray
Start-Sleep -Seconds 5

# Get ngrok URL from local API
Write-Host "[3/3] Fetching ngrok public URL..." -ForegroundColor Green
$ngrokUrl = $null

for ($i = 0; $i -lt 10; $i++) {
    try {
        $response = Invoke-RestMethod -Uri "http://localhost:4040/api/tunnels" -ErrorAction Stop
        $https = $response.tunnels | Where-Object { $_.proto -eq "https" } | Select-Object -First 1
        if ($https) {
            $ngrokUrl = $https.public_url
            break
        }
    } catch {
        Start-Sleep -Seconds 2
    }
}

Write-Host ""

if ($ngrokUrl) {
    $apiUrl = "$ngrokUrl/api"
    Write-Host "========================================" -ForegroundColor Green
    Write-Host "  ngrok URL: $ngrokUrl" -ForegroundColor Yellow
    Write-Host "  API URL  : $apiUrl" -ForegroundColor Yellow
    Write-Host "========================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "Run Flutter with:" -ForegroundColor Cyan
    Write-Host "  flutter run --dart-define=API_BASE_URL=$apiUrl" -ForegroundColor White
    Write-Host ""
    $runNow = Read-Host "Start Flutter now? (y/n)"

    if ($runNow -eq "y" -or $runNow -eq "Y") {
        Set-Location $flutterPath
        flutter run "--dart-define=API_BASE_URL=$apiUrl"
    }
} else {
    Write-Host "[WARNING] Could not auto-detect ngrok URL." -ForegroundColor Yellow
    Write-Host "  Check the ngrok window and run manually:" -ForegroundColor Gray
    Write-Host "  flutter run --dart-define=API_BASE_URL=https://YOUR_URL.ngrok-free.app/api" -ForegroundColor White
}

Write-Host ""
Write-Host "REMINDER: Facebook login requires your Facebook App" -ForegroundColor Yellow
Write-Host "to be LIVE or your account added as a Tester." -ForegroundColor Yellow
Write-Host "See: https://developers.facebook.com/apps" -ForegroundColor Cyan
