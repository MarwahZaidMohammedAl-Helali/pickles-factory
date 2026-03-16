@echo off
echo ========================================
echo   Deploying Backend to Railway
echo ========================================
echo.

echo Step 1: Enabling PowerShell scripts...
powershell -Command "Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force"

echo.
echo Step 2: Deploying to Railway...
powershell -Command "railway up"

echo.
echo ========================================
echo   Deployment Complete!
echo ========================================
echo.
echo Press any key to exit...
pause > nul
