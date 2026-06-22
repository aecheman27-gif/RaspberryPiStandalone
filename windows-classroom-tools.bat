@echo off
setlocal EnableExtensions
title Windows Classroom Toolkit - Raspberry Pi teaching

REM =====================================================================
REM  Installs the Windows-side tools that make teaching/learning on the
REM  Pi easier. Pairs with setup-pi-connection.bat (which handles SSH/VNC).
REM
REM  Uses winget (built into Windows 11). You may see UAC prompts — that
REM  is the installers asking for permission; approve them.
REM =====================================================================

echo.
echo ===============================================================
echo   Windows Classroom Toolkit for Raspberry Pi
echo ===============================================================
echo.

where winget >nul 2>&1
if errorlevel 1 (
  echo winget was not found. Update "App Installer" from the Microsoft Store,
  echo then re-run this script. Skipping automated installs.
  goto :nextsteps
)

echo [1/4] PyCharm  (unified product - edit on Windows, run on the Pi over SSH)
echo      Installs the unified PyCharm: starts a 1-month Pro trial; Pro stays
echo      FREE for non-commercial use (students: activate with your .edu account).
echo      NOTE: plain "Community" cannot do the SSH remote interpreter - use this.
winget install --id JetBrains.PyCharm.Professional -e --accept-source-agreements --accept-package-agreements --silent

echo.
echo [2/4] Git  (clone the Freenove repo, manage your course repo)
winget install --id Git.Git -e --accept-source-agreements --accept-package-agreements --silent

echo.
echo [3/4] Python 3  (optional - local practice before moving to the Pi)
winget install --id Python.Python.3.12 -e --accept-source-agreements --accept-package-agreements --silent

echo.
echo [4/4] Fritzing  (optional - draw breadboard/circuit diagrams for handouts)
winget install --id Fritzing.Fritzing -e --accept-source-agreements --accept-package-agreements --silent
if errorlevel 1 echo     Fritzing not available via winget - get it free at https://fritzing.org

:nextsteps
echo.
echo ===============================================================
echo   CONNECT PYCHARM TO THE PI (edith) OVER SSH
echo ===============================================================
echo  PyCharm runs your code ON the Pi using the Pi's Python + GPIO
echo  libraries, while you edit on Windows. Needs PyCharm PROFESSIONAL
echo  (free for non-commercial use).
echo.
echo  0. Run setup-pi-connection.bat FIRST (key login + ~/PiCourse folder).
echo     In PyCharm, activate Pro:  Help ^> Register  (trial or .edu license).
echo.
echo  1. New Project on the C: drive (NOT an external/F: drive).
echo.
echo  2. Settings (Ctrl+Alt+S) ^> Python ^> Add Interpreter ^> On SSH.
echo.
echo  3. Host: 100.104.213.4   User: aecheman
echo     Auth: Key pair ^> %%USERPROFILE%%\.ssh\id_ed25519
echo.
echo  4. Environment: SELECT EXISTING  (do NOT generate a new virtualenv).
echo     Type: Python   Path: /usr/bin/python3
echo     ^(The Pi's gpiozero/smbus live here; a fresh venv would not see them.^)
echo.
echo  5. IMPORTANT - fix the upload folder so it survives Pi reboots:
echo     Settings ^> Build, Execution, Deployment ^> Deployment ^> your server
echo       Connection tab  -^> Root path:  /home/aecheman/PiCourse
echo       Mappings tab    -^> Deployment path:  /
echo     Then  menu ^> Tools ^> Deployment ^> Automatic Upload (always).
echo     ^(Default /tmp gets WIPED on every reboot - that caused our errors.^)
echo.
echo  6. Do NOT "update" the listed packages in the interpreter view - they are
echo     managed by the Pi's apt; updating via pip can break Raspberry Pi OS.
echo.
echo  7. Put blink.py in the project, press Run. It executes on the Pi.
echo.
echo  Command-line fallback that always works (PowerShell):
echo     scp C:\path\to\Blink.py edith:~/PiCourse/
echo     ssh -t edith "python3 ~/PiCourse/Blink.py"
echo ===============================================================
echo.
pause
endlocal
