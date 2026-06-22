#!/usr/bin/env bash
# =====================================================================
#  Raspberry Pi Classroom Setup — Freenove Ultimate Starter Kit
#  Installs every library needed to run the Python (GPIOZero) projects,
#  enables the I2C/SPI interfaces those projects use, and adds a few
#  tools that make learning easier.
#
#  Run on the Pi:   bash pi-classroom-setup.sh
#  (safe to re-run — it skips anything already done)
# =====================================================================

set -u
GREEN="\033[0;32m"; YEL="\033[1;33m"; RED="\033[0;31m"; NC="\033[0m"
say()  { echo -e "${GREEN}==>${NC} $1"; }
warn() { echo -e "${YEL}!  ${NC} $1"; }

say "1/6  Updating the system (this can take a few minutes)…"
sudo apt update && sudo apt full-upgrade -y

say "2/6  Installing core libraries for the kit…"
# gpiozero        – the beginner-friendly GPIO library the course uses
# python3-lgpio   – the GPIO backend for Raspberry Pi 5 (Bookworm)
# smbus / i2c     – needed by the ADC, LCD1602 and MPU6050 projects
# spidev          – SPI backend used by some ADC variants
# pigpio          – precise-timing backend a couple of servo/stepper demos request
sudo apt install -y \
  git python3-pip python3-venv \
  python3-gpiozero python3-lgpio python3-rpi.gpio \
  python3-smbus i2c-tools python3-spidev \
  python3-pigpio

say "3/6  Installing learning & 'enhance' tools…"
# thonny       – simplest editor for beginners (run/stop, see variables)
# matplotlib   – graph live sensor data (great for the analog projects)
# numpy        – helper math for sensor projects
sudo apt install -y thonny python3-matplotlib python3-numpy || warn "Some optional tools were skipped."

say "4/6  Enabling the I2C and SPI interfaces…"
sudo raspi-config nonint do_i2c 0 && say "   I2C enabled"  || warn "Could not auto-enable I2C — do it in raspi-config > Interface Options."
sudo raspi-config nonint do_spi 0 && say "   SPI enabled"  || warn "Could not auto-enable SPI — do it in raspi-config > Interface Options."

# pigpio daemon: used by a few precise-timing examples. On Pi 5 the default
# (lgpio) backend already works; we start pigpiod if it's available and ignore failures.
sudo systemctl enable pigpiod >/dev/null 2>&1 && sudo systemctl start pigpiod >/dev/null 2>&1 \
  && say "   pigpio daemon running" \
  || warn "pigpio daemon not started (fine on Pi 5 — gpiozero uses lgpio by default)."

say "5/6  Getting the Freenove code…"
if [ -d "$HOME/Freenove_Ultimate_Starter_Kit_for_Raspberry_Pi" ]; then
  warn "Freenove repo already in your home folder — skipping clone."
else
  git clone --depth 1 https://github.com/Freenove/Freenove_Ultimate_Starter_Kit_for_Raspberry_Pi.git "$HOME/Freenove_Ultimate_Starter_Kit_for_Raspberry_Pi" \
    && say "   Cloned to ~/Freenove_Ultimate_Starter_Kit_for_Raspberry_Pi" \
    || warn "Clone failed — you can copy the folder from your repo instead."
fi

mkdir -p "$HOME/PiCourse" && say "Created ~/PiCourse (use this folder as PyCharm's deployment path)."

say "6/6  Verifying the install…"
echo "----------------------------------------------------------------"
python3 - <<'PY'
ok = True
for mod in ("gpiozero", "smbus", "spidev"):
    try:
        __import__(mod); print(f"  [ok] {mod}")
    except Exception as e:
        ok = False; print(f"  [MISSING] {mod}  ({e})")
print("  Python libraries:", "ALL GOOD" if ok else "SOMETHING MISSING — see above")
PY
echo "  I2C scan (numbers = a device was found; empty grid is normal with nothing wired):"
sudo i2cdetect -y 1 2>/dev/null || warn "i2cdetect not available yet — reboot and retry."
echo "----------------------------------------------------------------"

say "Done!  Reboot once so I2C/SPI take effect:   sudo reboot"
echo
echo "Then run your first project:"
echo "  cd ~/Freenove_Ultimate_Starter_Kit_for_Raspberry_Pi/Code/Python_GPIOZero_Code/01.1.1_Blink"
echo "  python Blink.py"
