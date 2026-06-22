@echo off
setlocal EnableExtensions
title Raspberry Pi (edith) - New PC Connection Setup

REM =====================================================================
REM  Sets up a fresh Windows PC to reach the Pi "edith" from ANYWHERE.
REM  Installs: SSH client + key, the 'ssh edith' shortcut, Tailscale,
REM  and TigerVNC; then installs your key on the Pi and makes ~/PiCourse.
REM  Re-runnable. You sign in to Tailscale once and type the Pi password once.
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
echo   Connect THIS PC to your Raspberry Pi "edith"
echo ===============================================================
echo.
if not exist "%TOOLS%" mkdir "%TOOLS%"
if not exist "%USERPROFILE%\.ssh" mkdir "%USERPROFILE%\.ssh"

echo [1/6] SSH client...
where ssh >nul 2>&1 && (echo       OK) || (powershell -NoProfile -Command "Add-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0 | Out-Null")

echo [2/6] SSH key...
if not exist "%USERPROFILE%\.ssh\id_ed25519" (ssh-keygen -t ed25519 -f "%USERPROFILE%\.ssh\id_ed25519" -N "" -C "%USERNAME%@windows") else (echo       OK)

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
  echo       Added.
) else (echo       OK)

echo [4/6] Tailscale ^(needed to reach the Pi off your home network^)...
where tailscale >nul 2>&1
if errorlevel 1 (
  echo       Installing Tailscale...
  winget install --id tailscale.tailscale -e --accept-source-agreements --accept-package-agreements
  echo.
  echo   ============================================================
  echo    ACTION NEEDED: open Tailscale from the system tray and SIGN IN
  echo    with the SAME account that owns 'edith'. Then RE-RUN this script
  echo    to finish installing your SSH key.
  echo   ============================================================
  echo.
  pause
  goto :end
) else (echo       OK - Tailscale present.)

echo [5/6] TigerVNC viewer ^(free, no account^)...
if exist "%VNCEXE%" (echo       OK - already downloaded.) else (
  powershell -NoProfile -Command "try { $ProgressPreference='SilentlyContinue'; Invoke-WebRequest -Uri 'https://sourceforge.net/projects/tigervnc/files/stable/%VNCVER%/vncviewer64-%VNCVER%.exe/download' -OutFile '%VNCEXE%' -UseBasicParsing; $b=[IO.File]::ReadAllBytes('%VNCEXE%'); if($b.Length -lt 100000 -or $b[0] -ne 0x4D -or $b[1] -ne 0x5A){ Remove-Item '%VNCEXE%' -Force; exit 2 } } catch { exit 1 }"
  if errorlevel 1 (echo       Manual: https://sourceforge.net/projects/tigervnc/files/stable/%VNCVER%/ -^> save vncviewer64-%VNCVER%.exe to %TOOLS%) else (echo       OK.)
)

echo [6/6] Installing your key on the Pi + making ~/PiCourse...
ssh %SSHOPTS% -o BatchMode=yes edith "echo ok" >nul 2>&1
if not errorlevel 1 (
  echo       Key already works.
  ssh %SSHOPTS% edith "mkdir -p ~/PiCourse" >nul 2>&1
  goto :done
)
echo       Trying your home network first ^(edith.local^)...
type "%USERPROFILE%\.ssh\id_ed25519.pub" | ssh %SSHOPTS% %PI_USER%@%PI_LOCAL% "mkdir -p ~/.ssh && chmod 700 ~/.ssh && cat >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys && mkdir -p ~/PiCourse" 2>nul
if not errorlevel 1 (echo       Done over local network. & goto :done)
echo       Trying over Tailscale ^(%PI_TS_IP%^) - type the Pi password if asked...
type "%USERPROFILE%\.ssh\id_ed25519.pub" | ssh %SSHOPTS% %PI_USER%@%PI_TS_IP% "mkdir -p ~/.ssh && chmod 700 ~/.ssh && cat >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys && mkdir -p ~/PiCourse"
if errorlevel 1 (echo       Could not reach the Pi. Make sure it's powered on and Tailscale is signed in, then re-run.)

:done
powershell -NoProfile -Command "Set-Content -Encoding ASCII -Path '%TOOLS%\Connect-edith-SSH.bat' -Value @('@echo off','ssh edith')"
powershell -NoProfile -Command "Set-Content -Encoding ASCII -Path '%TOOLS%\Connect-edith-VNC.bat' -Value @('@echo off','start \"\" \"%VNCEXE%\" %PI_TS_IP%:5900')"
echo.
echo ===============================================================
echo   DONE. Test from anywhere:   ssh edith "hostname"
echo   Desktop (VNC):              %TOOLS%\Connect-edith-VNC.bat
echo ===============================================================

:end
echo.
pause
endlocal
