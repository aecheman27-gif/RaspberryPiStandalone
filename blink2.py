#!/usr/bin/env python3
# blink2.py - drive two LEDs on GPIO17 (IO17) and GPIO5 (IO5)
# Wiring (each LED): GPIO pin -> 220 ohm resistor -> LED long leg (+)
#                    LED short leg (-) -> GND
# Run on the Pi:  python blink2.py     (stop with Ctrl+C)

from gpiozero import LED
from time import sleep

led_a = LED(17)   # IO17
led_b = LED(5)    # IO5

print("Blinking IO17 and IO5 - press Ctrl+C to stop")

try:
    while True:
        # alternate: A on, B off ... then swap
        led_a.on()
        led_b.off()
        sleep(0.5)

        led_a.off()
        led_b.on()
        sleep(0.5)
except KeyboardInterrupt:
    print("\nStopping.")
finally:
    led_a.off()
    led_b.off()
