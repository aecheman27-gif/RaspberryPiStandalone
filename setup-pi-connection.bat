@echo off
setlocal EnableExtensions
title Raspberry Pi (edith) - One-Shot Windows Connection Setup

REM =====================================================================
REM  ONE script to make a Windows PC ready to use the Pi "edith":
REM    - SSH client + key
REM    - 'ssh edith' shortcut
REM    - installs your key ON the Pi (passwordless) + makes ~/PiCourse
REM    - downloads TigerVNC viewer
REM    - checks Tailscale
REM  Safe to re-run. You'll type the Pi password ONCE (for the key copy).
REM =====================================================================

set "PI_USER=aecheman"
set "PI_TS_IP=100.104.213.4"
set "PI_LOCAL=edith.local"
set "TOOLS=%USERPROFILE%\PiTools"
set "VNCVER=1.16.2"
set "VNCEXE=%TOOLS%\vncviewer64-%VNCVER%.exe"
set "SSHOPTS=-o ConnectTimeout=10 -o StrictHostKeyChecking=accept-new"

echo.
echo ===============================================================
echo   Connecting this PC to your Raspberry Pi (edith)
echo   The Pi must be powered on and on the network for step 4.
echo ===============================================================
echo.

if not exist "%TOOLS%" mkdir "%TOOLS%"
if not exist "%USERPROFILE%\.ssh" mkdir "%USERPROFILE%\.ssh"

echo [1/6] SSH client...
where ssh >nul 2>&1 && (echo       OK) || (
  echo       Installing OpenSSH Client...
  powershell -NoProfile -Command "Add-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0 | Out-Null"
)

echo [2/6] SSH key...
if not exist "%USERPROFILE%\.ssh\id_ed25519" (
  echo       Generating a key ^(no passphrase^)...
  ssh-keygen -t ed25519 -f "%USERPROFILE%\.ssh\id_ed25519" -N "" -C "%USERNAME%@windows"
) else ( echo       OK - already have one. )

echo [3/6] 'ssh edith' shortcut...
findstr /C:"Host edith" "%USERPROFILE%\.ssh\config" >nul 2>&1
if errorlevel 1 (
  >>"%USERPROFILE%\.ssh\config" echo.
  >>"%USERPROFILE%\.ssh\config" echo Host edith
  >>"%USERPROFILE%\.ssh\config" echo     HostName %PI_TS_IP%
  >>"%USERPROFILE%\.ssh\config" echo     User %PI_USER%
  >>"%USERPROFILE%\.ssh\config" echo     IdentityFile ~/.ssh/id_ed25519
  >>"%USERPROFILE%\.ssh\config" echo.
  >>"%USERPROFILE%\.ssh\config" echo Host edith-local
  >>"%USERPROFILE%\.ssh\config" echo     HostName %PI_LOCAL%
  >>"%USERPROFILE%\.ssh\config" echo     User %PI_USER%
  >>"%USERPROFILE%\.ssh\config" echo     IdentityFile ~/.ssh/id_ed25519
  echo       Added - now you can type:  ssh edith
) else ( echo       OK - already configured. )

echo [4/6] Installing your key ON the Pi + creating ~/PiCourse...
echo       ^(Type your Pi password once if prompted. Skips if already done.^)
ssh %SSHOPTS% -o BatchMode=yes edith "echo keyok" >nul 2>&1
if errorlevel 1 (
  type "%USERPROFILE%\.ssh\id_ed25519.pub" | ssh %SSHOPTS% %PI_USER%@%PI_TS_IP% "mkdir -p ~/.ssh && chmod 700 ~/.ssh && cat >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys && mkdir -p ~/PiCourse"
  if errorlevel 1 (
    echo       Could not reach the Pi. Make sure it's on, then re-run this script.
  ) else (
    echo       Key installed + ~/PiCourse created. SSH is now passwordless.
  )
) else (
  echo       OK - key already works. Ensuring ~/PiCourse exists...
  ssh %SSHOPTS% edith "mkdir -p ~/PiCourse" >nul 2>&1
)

echo [5/6] TigerVNC Viewer ^(free, no account^)...
if exist "%VNCEXE%" ( echo       OK - already downloaded. ) else (
  powershell -NoProfile -Command "try { $ProgressPreference='SilentlyContinue'; Invoke-WebRequest -Uri 'https://sourceforge.net/projects/tigervnc/files/stable/%VNCVER%/vncviewer64-%VNCVER%.exe/download' -OutFile '%VNCEXE%' -UseBasicParsing; $b=[IO.File]::ReadAllBytes('%VNCEXE%'); if($b.Length -lt 100000 -or $b[0] -ne 0x4D -or $b[1] -ne 0x5A){ Remove-Item '%VNCEXE%' -Force; exit 2 } } catch { exit 1 }"
  if errorlevel 1 ( echo       Manual: https://sourceforge.net/projects/tigervnc/files/stable/%VNCVER%/ -^> save vncviewer64-%VNCVER%.exe to %TOOLS% ) else ( echo       OK - saved. )
)

echo [6/6] Tailscale + launchers...
where tailscale >nul 2>&1 || echo       Tailscale not found: winget install tailscale.tailscale  ^(sign in with the SAME account as edith^)
powershell -NoProfile -Command "Set-Content -Encoding ASCII -Path '%TOOLS%\Connect-edith-SSH.bat' -Value @('@echo off','ssh edith')"
powershell -NoProfile -Command "Set-Content -Encoding ASCII -Path '%TOOLS%\Connect-edith-VNC.bat' -Value @('@echo off','start \"\" \"%VNCEXE%\" %PI_TS_IP%:5900')"

echo.
echo ===============================================================
echo   DONE. Test it:   ssh edith "hostname"     (should NOT ask for a password)
echo   Desktop (VNC):   %TOOLS%\Connect-edith-VNC.bat
echo   Your code folder on the Pi:  ~/PiCourse   (use this in PyCharm)
echo ===============================================================
echo.
pause
endlocal
