@echo off
setlocal
set "JB_LAUNCHER_DIR=%~dp0"
set "JB_START_FILE=%~dp0OpenCode-jb.start"
if not exist "%JB_START_FILE%" (
  echo Extract the entire ZIP first. Keep OpenCode-jb.start next to this file.
  pause
  exit /b 1
)
powershell.exe -NoLogo -NoProfile -STA -ExecutionPolicy Bypass -Command "& ([scriptblock]::Create([IO.File]::ReadAllText($env:JB_START_FILE)))"
if errorlevel 1 pause
