param (
    [string]$CommitMessage = ""
)

$ErrorActionPreference = "Stop"

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "  Safiri Holidays Auto-Application & Push" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan

# 1. Verification: Run Flutter test suite
Write-Host "`n[1/4] Running Flutter test suite..." -ForegroundColor Yellow
Set-Location "d:\PRO\safiriV2\flutter_application_v2"
flutter test
if ($LASTEXITCODE -ne 0) {
    Write-Host "`n[ERROR] Tests failed! Aborting push to protect repository integrity." -ForegroundColor Red
    exit 1
}
Write-Host "[SUCCESS] All tests passed cleanly!" -ForegroundColor Green

# 2. Stage changes
Set-Location "d:\PRO\safiriV2"
Write-Host "`n[2/4] Staging changes..." -ForegroundColor Yellow
git add -A

$status = git status --porcelain
if (-not $status) {
    Write-Host "`n[INFO] Working tree is clean. No changes to commit." -ForegroundColor Cyan
    exit 0
}

# 3. Commit changes
if ([string]::IsNullOrWhiteSpace($CommitMessage)) {
    $timestamp = (Get-Date).ToString("yyyy-MM-dd HH:mm")
    $CommitMessage = "feat: time-sensitive greetings, iOS glassmorphism UI, auth resilience, and automated CI/CD ($timestamp)"
}

Write-Host "`n[3/4] Committing changes: '$CommitMessage'..." -ForegroundColor Yellow
git commit -m "$CommitMessage"

# 4. Push to remote
Write-Host "`n[4/4] Pushing to GitHub (origin main)..." -ForegroundColor Yellow
git pull --rebase origin main
git push origin main

if ($LASTEXITCODE -eq 0) {
    Write-Host "`n=========================================" -ForegroundColor Green
    Write-Host " [SUCCESS] Application pushed to GitHub!" -ForegroundColor Green
    Write-Host " GitHub Actions is now auto-building..." -ForegroundColor Green
    Write-Host "=========================================" -ForegroundColor Green
} else {
    Write-Host "`n[ERROR] Failed to push to GitHub. Please verify your network and git credentials." -ForegroundColor Red
    exit 1
}
