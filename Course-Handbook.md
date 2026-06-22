# Raspberry Pi Electronics — Instructor Course Handbook

**A hands-on STEM course built on the Freenove Ultimate Starter Kit (FNK0020)**
Python track · adult beginners · taught on a headless Raspberry Pi 5 ("edith")

> This handbook is written for the **instructor**. It turns the Freenove kit and its in-repo code into a teachable, 8-session course: what to say, what to build, what goes wrong, and how to check understanding. Student-facing slides live in `Raspberry-Pi-STEM-Course.pptx`.

---

## 1. How this course is organized

The course follows the kit's official **GPIOZero** Python code, which is already in this repository at:

```
Freenove_Ultimate_Starter_Kit_for_Raspberry_Pi-master/Code/Python_GPIOZero_Code/
```

Each project lives in its own numbered folder (e.g. `01.1.1_Blink/Blink.py`). The matching written tutorial is `Tutorial_Python_GPIOZero.pdf` at the repo root — use it for wiring diagrams and schematics, which this handbook does not reproduce.

After running `pi-classroom-setup.sh` (below), the same code also sits on the Pi at:

```
~/Freenove_Ultimate_Starter_Kit_for_Raspberry_Pi/Code/Python_GPIOZero_Code/
```

**Run pattern for every project:**

```bash
cd ~/Freenove_Ultimate_Starter_Kit_for_Raspberry_Pi/Code/Python_GPIOZero_Code/01.1.1_Blink
python Blink.py        # stop any running project with Ctrl+C
```

The filename inside each folder matches the folder name (minus the number). Helper modules (`ADCDevice.py`, `LCD1602.py`, `Freenove_DHT.py`, etc.) ship inside the project folders, so projects run without extra installs once the libraries below are present.

---

## 2. Course at a glance

| | |
|---|---|
| **Audience** | Adults, complete beginners to electronics and Python |
| **Class size** | Best at 2 learners per Pi + kit (pair programming) |
| **Sessions** | 8 × ~90 minutes (or split into 16 × 45) |
| **Language** | Python 3 via the `gpiozero` library |
| **Hardware per pair** | 1 Raspberry Pi 5, 1 Freenove kit, 1 microSD, power supply |
| **Prerequisites** | None. Comfort with a keyboard; willingness to make mistakes |

**Learning outcomes.** By the end, a learner can: wire a circuit on a breadboard safely; read and modify Python that controls GPIO; use digital and analog inputs and outputs; drive motors and displays; combine components into an original project; and explain what each part does well enough to help the next person.

---

## 3. Before the first class — setup

You only do this once per Pi. All of it is scripted.

**On each Raspberry Pi** (over SSH or on the desktop):

```bash
bash pi-classroom-setup.sh     # from this repo
sudo reboot                    # so I2C/SPI turn on
```

This installs `gpiozero`, `lgpio`, `smbus`, `spidev`, `i2c-tools`, `pigpio`, Thonny, matplotlib/numpy; enables the **I2C** and **SPI** interfaces (required by the ADC, LCD1602, and MPU6050 projects); and clones the Freenove code to the Pi's home folder.

**On each Windows machine** students will use:

```
setup-pi-connection.bat        # SSH key + 'ssh edith' + TigerVNC
windows-classroom-tools.bat    # PyCharm Professional, Git, Python, Fritzing
```

**Recommended teaching setup:** students edit and run code in **PyCharm Professional** using an **SSH remote interpreter** pointed at `edith` (the code runs on the Pi while they edit on Windows), or in **Thonny** on the Pi desktop via VNC. Thonny is friendlier for absolute beginners (big Run/Stop buttons, a variable inspector); PyCharm is the better home once they're comfortable. Note: PyCharm Professional is free for non-commercial use, and the SSH remote interpreter is a **Professional-only** feature — Community Edition can't run code on the Pi.

> **Classroom tip:** image one microSD card fully, get it working, then clone it for every other Pi. Far faster than running setup on each.

---

## 4. Teaching method (read this once)

Six habits make this course land:

1. **Run first, explain second.** Get the LED blinking before dissecting the code. The payoff buys attention for the concepts.
2. **Predict, then run.** Before every run ask "what will this do?" Being wrong out loud is where the learning sticks.
3. **One new idea per project.** Each project should add exactly one concept over the last. Name that concept explicitly.
4. **Pair and swap.** One student wires, one types; swap every project. Verbalizing doubles retention.
5. **Treat bugs as the lesson.** A loose jumper or a wrong pin number is the curriculum, not a failure. Model calm, systematic debugging (Section 12).
6. **End every session on a working demo.** Momentum is the strongest motivator beginners have.

---

## 5. Session-by-session plan

Each session lists its concept arc, the Freenove project folders to use, wiring gotchas, a short live-teaching script, a challenge that forces understanding, and check-for-understanding questions.

### Session 1 — Foundations & first light

**Concept arc:** electricity safety → breadboard → GPIO → digital output → input.

| Project (folder) | Run | Teaches |
|---|---|---|
| `00.0.0_Hello` | `python Hello.py` | The toolchain works; Python runs on the Pi |
| `01.1.1_Blink` | `python Blink.py` | Digital output, the loop, `sleep()` |
| `02.1.1_ButtonLED` | `python ButtonLED.py` | Digital input, reacting to the world |
| `02.2.1_Tablelamp` | `python Tablelamp.py` | Toggling state (press = flip on/off) |

**Wiring gotchas:** LED has a polarity — long leg (anode) to the resistor/GPIO side, flat-edge/short leg to ground. Always include the 220Ω resistor. Confirm the pin number in the code matches the pin the wire is in.

**Live-teaching script (Blink):** "This program does three things forever: turn the pin on, wait, turn it off, wait. That `while True:` loop is the heartbeat of almost everything we'll build. Change `sleep(1)` to `sleep(0.1)` — predict what happens, then run it."

**Challenge:** make the LED blink "SOS" (three short, three long, three short). Forces them to think in sequence and timing.

**Check for understanding:** What is the resistor for? What's the difference between an input and an output pin? Why doesn't the program ever reach the line after the loop?

---

### Session 2 — Light shows & PWM

**Concept arc:** many outputs at once → PWM (fake "in-between" levels) → mixing color.

| Project | Run | Teaches |
|---|---|---|
| `03.1.1_LightWater` | `python LightWater.py` | Driving several LEDs in sequence; lists/loops |
| `04.1.1_BreathingLED` | `python BreathingLED.py` | PWM — dimming via duty cycle |
| `05.1.1_ColorfulLED` | `python ColorfulLED.py` | RGB = three PWM channels mixed |

**Wiring gotchas:** the RGB LED has four legs (common + R/G/B); orientation matters — match the longest leg to the common pin in the diagram. The LED bar needs one resistor per LED.

**Live-teaching script (Breathing):** "A pin is only ever on or off. So how do we get *half* brightness? We flip it on and off thousands of times a second — more 'on' time looks brighter. That's PWM. The RGB LED is just three of these at once; change the three numbers and you get any color."

**Challenge:** make the RGB LED cycle smoothly through the rainbow, or pulse a 'heartbeat' on the bar graph.

**Check for understanding:** What does "duty cycle" mean? Why can a digital-only pin still dim an LED? How many PWM channels make one color?

---

### Session 3 — Sound & the analog world

**Concept arc:** active vs passive buzzers → why the Pi can't read analog → the ADC.

| Project | Run | Teaches |
|---|---|---|
| `06.1.1_Doorbell` | `python Doorbell.py` | Active buzzer triggered by a button |
| `06.2.1_Alertor` | `python Alertor.py` | Passive buzzer playing tones |
| `07.1.1_ADC` | `python ADC.py` | Reading an analog voltage as a number |
| `08.1.1_Softlight` | `python Softlight.py` | A knob (potentiometer) dimming an LED |

**Wiring gotchas:** this is the first I2C project — if `ADC.py` errors, the ADC module isn't on the bus. Check `sudo i2cdetect -y 1` (you should see an address like `48` or `4b`), and confirm I2C is enabled (the setup script does this). A transistor drives the buzzer; mind its orientation.

**Live-teaching script (ADC):** "The Pi only understands on/off — it can't read 'how far is the knob turned.' So the kit includes an ADC chip: it measures the voltage and hands Python a number from 0 to 1. We turn the knob, read the number, and use it. Every sensor for the rest of the course works this way."

**Challenge:** turn the potentiometer into a volume-style control for the passive buzzer's pitch.

**Check for understanding:** Why does an analog sensor need the ADC chip? What's the difference between the active and passive buzzer? What does `i2cdetect` tell you?

---

### Session 4 — Sensing the environment

**Concept arc:** sensors are just resistors that change → mapping a raw reading to something useful → two-axis input.

| Project | Run | Teaches |
|---|---|---|
| `09.1.1_ColorfulSoftlight` | `python ColorfulSoftlight.py` | Three pots mixing RGB by hand |
| `10.1.1_Nightlamp` | `python Nightlamp.py` | Photoresistor → automatic light |
| `11.1.1_Thermometer` | `python Thermometer.py` | Thermistor → temperature with a little math |
| `12.1.1_Joystick` | `python Joystick.py` | Two analog axes + a button |

**Wiring gotchas:** all four use the ADC from Session 3 — keep that circuit as the base. The thermistor math (Steinhart-Hart) is in the code; don't derail into the equation, just show the °C output changing when they pinch the thermistor.

**Live-teaching script (Nightlamp):** "A photoresistor's resistance drops in bright light. Feed it through the ADC and we get a 'how bright is the room' number. Add one `if` statement — if it's dark, turn the LED on — and we've built something genuinely useful. That `if` is the whole idea of a 'smart' device."

**Challenge:** combine the photoresistor and a buzzer to make a 'don't open the fridge at night' alarm, or auto-tune an LED's brightness inversely to room light.

**Check for understanding:** What does the ADC value do as the room gets darker? Where would you change the threshold for "dark"? What two things does a joystick report?

---

### Session 5 — Motion & power

**Concept arc:** motors need their own power → drivers and H-bridges → precise angles vs continuous spin.

| Project | Run | Teaches |
|---|---|---|
| `13.1.1_Motor` | `python Motor.py` | DC motor + driver, direction & speed |
| `14.1.1_Relay` | `python Relay.py` | Switching bigger loads safely |
| `15.1.1_Sweep` | `python Sweep.py` | Servo to a precise angle (0–180°) |
| `16.1.1_SteppingMotor` | `python SteppingMotor.py` | Stepper for exact, repeatable rotation |

**Wiring gotchas:** **never power a motor straight from a GPIO pin** — always through the included driver board, with the motor's own power leg connected. The stepper uses the ULN2003 driver board; make sure the connector orientation matches the diagram. On a Pi 5, if a servo example that requests the pigpio backend stutters, it's because pigpiod isn't supported on Pi 5 — the default `lgpio` backend still drives it; note this and move on.

**Live-teaching script (Sweep):** "A servo isn't 'spin' — it's 'go to this angle and hold.' `servo.min()`, `servo.mid()`, `servo.max()` are 0°, 90°, 180°. That's how a robot arm or a door lock knows exactly where to stop."

**Challenge:** make the servo act as a needle gauge that follows the potentiometer from Session 3.

**Check for understanding:** Why can't a motor run off a GPIO pin directly? When would you choose a stepper over a servo? What does the relay let you switch that GPIO can't?

---

### Session 6 — Displays

**Concept arc:** shift registers (control many things with few pins) → multiplexing → I2C displays.

| Project | Run | Teaches |
|---|---|---|
| `17.1.1_LightWater02` | `python LightWater02.py` | 74HC595 shift register basics |
| `18.1.1_SevenSegmentDisplay` | `python SevenSegmentDisplay.py` | Driving digits |
| `18.2.1_StopWatch` | `python StopWatch.py` | A real 4-digit counting display |
| `19.1.1_LEDMatrix` | `python LEDMatrix.py` | 8×8 dot patterns & scrolling |
| `20.1.1_I2CLCD1602` | `python I2CLCD1602.py` | Text on an LCD over I2C |

**Wiring gotchas:** the shift-register projects have a lot of wires — budget time, and have them check each row before powering on. The LCD is I2C (like the ADC); if it shows nothing, check contrast (the little blue pot on the back) and the I2C address with `i2cdetect`.

**Live-teaching script (LCD):** "A number on a screen is the moment electronics becomes a *product*. The LCD takes plain text: `lcd.write('Hello')`. Pair this with any sensor we've built and you've made a real instrument — which is exactly the next session's capstones."

**Challenge:** show the live potentiometer percentage (Session 3) on the LCD; or scroll your name across the 8×8 matrix.

**Check for understanding:** Why use a shift register instead of one pin per LED? What protocol do the LCD and the ADC share? What turns the matrix dots on?

---

### Session 7 — Smart sensors & interaction

**Concept arc:** digital sensor protocols → scanning a keypad → motion and distance → orientation.

| Project | Run | Teaches |
|---|---|---|
| `21.1.1_DHT11` | `python DHT11.py` | Temperature + humidity over a 1-wire protocol |
| `22.1.1_MatrixKeypad` | `python MatrixKeypad.py` | Reading a 4×4 keypad (row/column scan) |
| `23.1.1_SenseLED` | `python SenseLED.py` | PIR motion sensor triggers an output |
| `24.1.1_UltrasonicRanging` | `python UltrasonicRanging.py` | Distance by timing a sound echo |
| `25.1.1_MPU6050` | `python MPU6050.py` | Accelerometer/gyro orientation (I2C) |

**Wiring gotchas:** the DHT11 sometimes returns a failed reading — the code retries; that's normal, not a bug (good teaching moment). The PIR has two trim pots (sensitivity/time) and a warm-up period of ~30s. The ultrasonic sensor needs both `trigger` and `echo` pins wired correctly — swapped pins give nonsense distances.

**Live-teaching script (Ultrasonic):** "This sends a chirp and times how long the echo takes — same trick a bat or a car's parking sensor uses. Distance equals time times the speed of sound, halved for the round trip. Watch the number drop as I move my hand closer."

**Challenge:** beep faster as your hand gets closer to the ultrasonic sensor (the parking-sensor capstone in miniature).

**Check for understanding:** Why does the DHT11 occasionally need a retry? What two pins does the ultrasonic sensor need and why? What does a PIR actually detect?

---

### Session 8 — IoT, capstones & permanence

**Concept arc:** control the Pi from a browser → combine everything → make it permanent.

| Project | Run | Teaches |
|---|---|---|
| `26.1.1_WebIO` | `python WebIO.py` then open the Pi's IP in a browser | Controlling hardware over the network (IoT) |
| `27.2.1_LightWater03` | (soldering project) | Moving from breadboard to a soldered build |

Spend most of this session on **capstones** (Section 6). End with a demo-and-share: each pair shows their project and explains one thing that went wrong and how they fixed it.

---

## 6. Capstone projects (combine what you learned)

Each capstone fuses earlier projects. Give pairs the components and the goal, not the code — let them assemble it from projects they've already run.

| Capstone | Combines | Goal |
|---|---|---|
| **Smart night-light** | Photoresistor (10) + RGB LED (05) | LED fades on as the room darkens |
| **Mini weather station** | DHT11 (21) + LCD1602 (20) | Live temp & humidity on the screen |
| **Ultrasonic theremin** | Ultrasonic (24) + passive buzzer (06.2) | Hand distance controls pitch |
| **Reverse parking sensor** | Ultrasonic (24) + buzzer (06) + LEDs (03) | Beeps/flashes faster as objects approach |
| **Keypad door lock** | Keypad (22) + servo (15) + LCD (20) | Correct code rotates the servo to "unlock" |
| **Intruder alarm** | PIR (23) + buzzer (06) + LED | Motion trips an alarm; reset to re-arm |
| **Web sensor dashboard** | WebIO (26) + any sensor | Read a sensor from your phone's browser |
| **Motion-reactive display** | MPU6050 (25) + 8×8 matrix (19) | Tilt the board, the dot "rolls" |

**Capstone rubric (10 pts):** works as specified (4) · code is understood, not copied — pair can explain it (3) · clean wiring & safe practices (2) · one extension beyond the brief (1).

---

## 7. Tools installed, and why

**On the Raspberry Pi** (`pi-classroom-setup.sh`):

| Tool | Why it's needed |
|---|---|
| `gpiozero`, `lgpio`, `rpi.gpio` | Control GPIO pins; `lgpio` is the Pi 5 backend |
| `smbus`, `i2c-tools` | Talk to I2C devices: ADC, LCD1602, MPU6050 |
| `spidev` | SPI backend for some ADC variants |
| `pigpio` | Precise-timing backend a few servo/stepper demos request |
| **I2C + SPI enabled** | Without these the ADC/LCD/MPU projects simply won't run |
| Thonny | Beginner editor: visible Run/Stop, variable inspector |
| matplotlib, numpy | Graph live sensor data — a powerful "enhance" exercise |

**On Windows** (`windows-classroom-tools.bat`):

| Tool | Why it's needed |
|---|---|
| PyCharm Professional (**SSH interpreter**) | Edit on Windows, run on the Pi's Python; free for non-commercial use |
| Git | Clone the Freenove repo, manage the course repo |
| Python 3 | Optional local practice before moving to hardware |
| Fritzing | Draw breadboard/circuit diagrams for handouts |
| (from `setup-pi-connection.bat`) SSH, TigerVNC | Connect to `edith` by terminal and graphical desktop |

---

## 8. Suggested two-track scheduling

- **Workshop (1 day):** Sessions 1–4 in the morning, 5–6 after lunch, one capstone to finish. Fast but doable for motivated adults.
- **Evening course (8 weeks):** one session per week, capstones in weeks 7–8. Best retention.

---

## 9. Per-pair equipment checklist

Raspberry Pi 5 · power supply · microSD (imaged) · Freenove kit (keep parts in a labeled tray) · the GPIO extension board + ribbon cable · a Windows laptop with the two `.bat` scripts run · network access to reach `edith`.

---

## 10. Assessment & evidence of learning

- **Per session:** the end-of-session demo working = the formative check.
- **Mid-course (after Session 4):** "explain the ADC to your partner" — verbal check.
- **Final:** a capstone graded on the Section 6 rubric, plus each learner answering one "why does this work?" question about their build.

---

## 11. Instructor troubleshooting appendix

| Symptom | Likely cause | Fix |
|---|---|---|
| `ImportError: No module named gpiozero` | Setup script not run | `sudo apt install python3-gpiozero` |
| ADC / LCD / MPU project errors immediately | I2C not enabled, or device not detected | `sudo raspi-config` → Interface → I2C on; `sudo i2cdetect -y 1` should show an address |
| LCD backlight on but no text | Contrast pot, or wrong I2C address | Turn the blue pot on the LCD's back; check address with `i2cdetect` |
| LED never lights | Polarity or missing resistor | Long leg toward GPIO/resistor; add 220Ω |
| Servo jitters on Pi 5 | Example requests pigpio (unsupported on Pi 5) | Ignore — `gpiozero` falls back to `lgpio`; motion still works |
| DHT11 prints a read error sometimes | Normal for this sensor | The code retries; only worry if it never succeeds |
| Motor does nothing / Pi reboots | Powered from GPIO instead of the driver | Use the driver board with its own power leg |
| "Permission denied" on GPIO | Rare on current Pi OS | Add user to `gpio` group, or run within the desktop session |
| PyCharm can't connect to `edith` | SSH login/key missing, or using Community | Run `setup-pi-connection.bat`; use PyCharm **Professional** → Add Interpreter → On SSH (host `edith`, key `~/.ssh/id_ed25519`) |

---

## 12. The debugging routine to teach (put it on the wall)

1. **What did you expect, and what happened?** Say both out loud.
2. **Power & wires:** is it on? Is every wire in the right row? Any loose leg?
3. **Pin numbers:** does the code's pin match the breadboard?
4. **Read the error's last line** — it usually names the problem.
5. **Change one thing, run again.** Never change two things at once.
6. **Still stuck?** Compare against the working Freenove example in the project folder.

---

## 13. Resources

- **Freenove code (this repo):** `Freenove_Ultimate_Starter_Kit_for_Raspberry_Pi-master/Code/Python_GPIOZero_Code/`
- **Wiring diagrams & schematics:** `Tutorial_Python_GPIOZero.pdf` (repo root)
- **Official repo:** https://github.com/Freenove/Freenove_Ultimate_Starter_Kit_for_Raspberry_Pi
- **gpiozero docs:** https://gpiozero.readthedocs.io
- **Your Pi setup guide:** `Pi5.md` · **student slides:** `Raspberry-Pi-STEM-Course.pptx`

---

*Start them on Blink. Get one win. The other 27 projects — and every capstone — follow from there.*
