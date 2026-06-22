# Raspberry Pi 5 — Headless Setup Guide

End-to-end setup for a Raspberry Pi 5 running **Raspberry Pi OS (64-bit, Desktop / "Bookworm")**, accessed remotely from a Windows 11 desktop via SSH, Tailscale, and VNC.

**This build's identity**

| Setting | Value |
|---|---|
| Hostname | `edith` |
| Username | `aecheman` |
| OS | Raspberry Pi OS 64-bit, Desktop |
| Display server | Wayland (Bookworm default on Pi 5) |
| VNC server | Built-in **WayVNC** (enabled via `raspi-config`) |
| Remote tools | OpenSSH + Tailscale + **TigerVNC Viewer** (client) |

> **Note on the VNC client:** WayVNC is a standard VNC server, but **RealVNC Viewer now requires a paid plan to connect to non-RealVNC ("third-party") servers**, so it will nag you. Use the free, no-account **TigerVNC Viewer** instead (TightVNC/UltraVNC also work). The Raspberry Pi project itself recommends TigerVNC.

> Throughout, replace `aecheman` only if you change the username. Commands run **on the Pi** are noted as such; everything else runs in **Windows PowerShell / Windows Terminal**.

---

## Part 1 — Flash the SD card with Raspberry Pi Imager

1. On Windows, download and install **Raspberry Pi Imager** from <https://www.raspberrypi.com/software/>.
2. Insert the microSD card into your USB card reader.
3. Open Imager and set the three choices:
   - **Choose Device** → *Raspberry Pi 5*
   - **Choose OS** → *Raspberry Pi OS (64-bit)* (the full Desktop version — it's the top entry, not "Lite")
   - **Choose Storage** → your microSD card (double-check the size so you don't wipe the wrong drive)
4. Click **Next**. When asked *"Would you like to apply OS customisation settings?"*, choose **Edit Settings**. This is where the headless magic happens.

### OS customisation — General tab

- **Set hostname:** `edith`  → the Pi will be reachable as `edith.local` on your LAN.
- **Set username and password:** username `aecheman`, and a strong password. (Set a password even though we'll use keys — WayVNC and `sudo` will use it.)
- **Configure wireless LAN:**
  - **SSID:** your Wi-Fi network name (exactly, case-sensitive)
  - **Password:** your Wi-Fi password
  - **Wireless LAN country:** `US` (required so the Wi-Fi radio enables on the correct channels)
- **Set locale settings:** your time zone and keyboard layout.

### OS customisation — Services tab

- Tick **Enable SSH**.
- Choose **Allow public-key authentication only** if you already have a key, or paste your public key (we generate one in Part 2). If you don't yet have a key handy, select **Use password authentication** here and we'll switch to keys after first boot — either path works.

> ⚠️ **Known Imager bug (v2.0.0):** in that specific version, choosing *public-key only* sometimes silently breaks the other customisations (hostname, Wi-Fi, user). If you're on 2.0.0 and the Pi doesn't come up correctly, re-flash using **password authentication** in Imager, boot, then add your SSH key manually (Part 2, Step 4b). Recent Imager releases fixed this.

5. **Save**, then **Yes** to apply settings, then **Yes** to confirm erasing the card. Wait for write + verify to finish, then eject.
6. Put the microSD into the Pi 5 and power it on. Give it **2–4 minutes** on first boot to expand the filesystem, join Wi-Fi, and start SSH.

---

## Part 2 — SSH key authentication from Windows

### Step 1 — Check for an existing key

In PowerShell:

```powershell
Test-Path $env:USERPROFILE\.ssh\id_ed25519
Test-Path $env:USERPROFILE\.ssh\id_rsa
```

If either returns `True`, you already have a key — skip to Step 3.

### Step 2 — Generate a key (if needed)

```powershell
ssh-keygen -t ed25519 -C "aecheman27@gmail.com"
```

Press Enter to accept the default path (`C:\Users\<you>\.ssh\id_ed25519`). Set a passphrase or leave blank. (Ed25519 is preferred over RSA; if you specifically need `id_rsa`, use `ssh-keygen -t rsa -b 4096` instead.)

### Step 3 — First connection

```powershell
ssh aecheman@edith.local
```

Type `yes` to accept the host fingerprint, then enter the password you set in Imager. You're now on the Pi.

### Step 4 — Install your public key on the Pi

**4a — If you used password auth in Imager**, run this single command from **Windows PowerShell** (not on the Pi). It copies your public key into the Pi's `authorized_keys`:

```powershell
type $env:USERPROFILE\.ssh\id_ed25519.pub | ssh aecheman@edith.local "mkdir -p ~/.ssh && chmod 700 ~/.ssh && cat >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys"
```

**4b — If Imager already installed your key**, nothing to do here.

Now reconnect — it should **not** ask for a password:

```powershell
ssh aecheman@edith.local
```

---

## Part 3 — The `~/.ssh/config` shortcut (type `ssh pi`)

Create or edit `C:\Users\<you>\.ssh\config` on Windows and add:

```sshconfig
# Reach the Pi anywhere via Tailscale (set up in Part 5)
Host pi
    HostName edith
    User aecheman
    IdentityFile ~/.ssh/id_ed25519

# Reach the Pi on the local network only (works before Tailscale)
Host pi-local
    HostName edith.local
    User aecheman
    IdentityFile ~/.ssh/id_ed25519
```

Quick way to append it from PowerShell:

```powershell
@"
Host pi
    HostName edith
    User aecheman
    IdentityFile ~/.ssh/id_ed25519

Host pi-local
    HostName edith.local
    User aecheman
    IdentityFile ~/.ssh/id_ed25519
"@ | Out-File -Append -Encoding ascii $env:USERPROFILE\.ssh\config
```

After this you connect with just `ssh pi-local` (on your LAN now) and `ssh pi` (from anywhere, once Tailscale is up).

---

## Part 4 — Finish setup on the Pi

SSH in (`ssh pi-local`), then run:

### Update the system

```bash
sudo apt update && sudo apt full-upgrade -y
```

### Enable the built-in VNC server (WayVNC)

Because Bookworm on the Pi 5 uses **Wayland**, the built-in VNC server is **WayVNC**, not classic RealVNC Server. Connect to it with a free client like TigerVNC Viewer (see Part 5) — note RealVNC Viewer now needs a paid plan for third-party servers.

```bash
sudo raspi-config
```

Navigate: **Interface Options → VNC → Yes** (enable). While you're here, set the Pi to boot to the desktop with auto-login so a session exists for VNC to share: **System Options → Boot / Auto Login → Desktop Autologin**. Then **Finish** and reboot if prompted:

```bash
sudo reboot
```

> WayVNC serves on **port 5900** and uses your Pi login (`aecheman` + password). It shares the *physical* desktop session — that's why desktop autologin matters for headless use.

### Install Tailscale

```bash
curl -fsSL https://tailscale.com/install.sh | sh
sudo tailscale up
```

This prints a URL. Open it in your Windows browser and sign in **with GitHub** (or whatever account you use for Tailscale). The Pi joins your tailnet as `edith`.

Recommended for an always-on device — disable key expiry so it never drops off:

```bash
# After auth, in the Tailscale admin console (https://login.tailscale.com/admin/machines):
# click the edith machine → ⋯ → "Disable key expiry"
```

If you want MagicDNS short names (so `ssh pi` → `edith` just works), make sure **MagicDNS is enabled** in the Tailscale admin console under **DNS**. It's on by default for new tailnets.

---

## Part 5 — Connect from Windows

### VNC (graphical desktop)

1. Download **TigerVNC Viewer** for Windows — the free, no-account client. TigerVNC ships its Windows binaries on **SourceForge**, not GitHub: go to <https://sourceforge.net/projects/tigervnc/files/stable/> → newest version, and grab the standalone viewer named **`vncviewer64-<version>.exe`** (the ~24 MB one). It needs no install — just double-click it. (Avoid the `*winvnc*` files — those are the Windows *server*.)
2. In the **VNC server** box type either:
   - `edith.local:5900` — on your home network, or
   - `100.x.y.z:5900` (your Tailscale IP) or `edith:5900` — from anywhere via Tailscale.
3. On first connect you'll get an **"unknown certificate issuer"** prompt, then possibly a **"certificate hostname mismatch"** prompt (because you connected by IP). Both are expected — WayVNC uses a self-signed cert named after your user, and the connection is encrypted by Tailscale regardless. Click **Yes** to trust it; it's remembered after the first time. Then log in with `aecheman` + your Pi password.

> Why not RealVNC Viewer? RealVNC now requires a **paid plan to connect to third-party VNC servers** like WayVNC, so it nags or blocks. TigerVNC (used here), **TightVNC**, and **UltraVNC** are all free and connect to WayVNC the same way. Tailscale already encrypts the transport end-to-end.

### SSH

```powershell
ssh pi-local   # on your home Wi-Fi
ssh pi         # from anywhere, over Tailscale
```

---

## Part 6 — Verification checklist

Run these to confirm all three channels work.

**SSH key auth (from Windows):** should land you on the Pi with no password prompt.
```powershell
ssh pi-local "echo SSH OK; hostname"
```
Expected: `SSH OK` then `edith`.

**VNC server listening (on the Pi):**
```bash
sudo ss -tlnp | grep 5900
```
Expected: a line showing `wayvnc` listening on `:5900`. Then confirm you can open the desktop in TigerVNC Viewer.

**Tailscale (on the Pi):**
```bash
tailscale status
tailscale ip -4
```
Expected: `tailscale status` lists `edith` and your other devices; `tailscale ip -4` returns a `100.x.y.z` address.

**End-to-end (from Windows, ideally on a different network / phone hotspot):**
```powershell
ssh pi "hostname && tailscale ip -4"
```
If this returns `edith` and the `100.x` IP while you're *off* your home Wi-Fi, remote access is fully working.

---

## Quick reference

| Task | Command / Location |
|---|---|
| Flash + headless config | Raspberry Pi Imager → Edit Settings |
| First SSH login | `ssh aecheman@edith.local` |
| Install public key | `type ...id_ed25519.pub \| ssh ... cat >> authorized_keys` |
| Connect (LAN) | `ssh pi-local` |
| Connect (anywhere) | `ssh pi` |
| Enable VNC | `sudo raspi-config` → Interface Options → VNC |
| Install Tailscale | `curl -fsSL https://tailscale.com/install.sh \| sh` then `sudo tailscale up` |
| VNC client | TigerVNC Viewer (`vncviewer64-*.exe`) → `edith.local:5900` or `100.x.y.z:5900` |

---

## Sources

- [Raspberry Pi Imager / getting started — Raspberry Pi Documentation](https://www.raspberrypi.com/documentation/computers/getting-started.html)
- [A new Raspberry Pi Imager — Raspberry Pi](https://www.raspberrypi.com/news/a-new-raspberry-pi-imager/)
- [Imager v2.0.0 public-key customisation bug — GitHub issue #1320](https://github.com/raspberrypi/rpi-imager/issues/1320)
- [VNC on the Raspberry Pi 5 with PiOS Bookworm — Raspberry Connect](https://www.raspberryconnect.com/projects/41-tutorials-and-guides-1/201-vnc-on-the-raspberrypi-5-with-pios-bookworm)
- [Set Up VNC on Raspberry Pi Bookworm: wayvnc & RealVNC — raspberry.tips](https://raspberry.tips/en/raspberrypi-einsteiger/raspberry-pi-vnc-setup-bookworm-wayvnc-realvnc-connect)
- [RealVNC Connect and Raspbe