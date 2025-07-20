# Frogger Clone on Tiva C Series TM4C123GH6PM

## Overview
This project implements a text‑based clone of the classic **Frogger** game entirely in ARM assembly. It runs on the TI **Tiva C Series TM4C123GH6PM** microcontroller mounted on an **EduBase‑V2** trainer board. Game graphics are rendered via a UART terminal, with user input from a 4×4 keypad and control via timers, LEDs, and a speaker for sound effects.

---

## Hardware

- **Microcontroller**:  
  - TI Tiva C Series TM4C123GH6PM (ARM Cortex‑M4F @ 80 MHz, 256 KB Flash, 32 KB SRAM)
- **Trainer Board**:  
  - EduBase‑V2 (breadboard area, booster‑pack headers)
- **Peripherals Used**:
  - **UART0**: PC terminal I/O at 460 800 baud
  - **GPIO Port D / Port A**: 4×4 keypad scanning
  - **GPIO Port B**: Onboard LEDs for status/debug
  - **GPIO Port F**: RGB LED for game-state indication
  - **Timer0**: 1 Hz game clock
  - **Timer1**: PWM for speaker output
  - **Timer2**: Obstacle movement & board-update ticks

---

## Project Structure
`
/
├── .launches/ # IDE launch configurations
├── .settings/ # IDE project settings
├── Debug/ # Build outputs (ELF, HEX, map files)
├── Library/ # Core ARM‑ASM source modules
│ ├── Initializations.s # Clocks, GPIO & timer setup
│ ├── uart.s # UART driver (init, send, recv)
│ ├── GPIO.s # Keypad scan & LED control
│ ├── tables.s # Lookup tables (keypad, notes)
│ ├── math.s # RNG, div/mod, ASCII conv.
│ └── lab7_library.s # Game engine: board, draw, logic
├── targetConfigs/ # Linker scripts & board configs
├── Lab7.s # Main entry point & menu/high‑score
├── main.c # C “glue” (startup/integration)
├── tm4c123gh6pm.cmd # Linker command file
├── tm4c123gh6pm_startup_ccs.c # CCS startup code
├── .ccsproject # CCS IDE project file
├── .cproject # Eclipse IDE project file
└── .project # Generic Eclipse project file
`

---

## Building & Flashing

1. **Toolchain**: Keil µVision, Code Composer Studio, or GNU ARM  
2. **Assemble** all `.s` files and compile C startup if used  
3. **Link** with the TM4C123GH6PM linker script  
4. **Flash** via on‑board ICDI (lm4flash, UniFlash, or CCS)

### Example (GNU ARM)
```sh
arm-none-eabi-as -mcpu=cortex-m4 -g \
  Library/Initializations.s \
  Library/uart.s \
  Library/GPIO.s \
  Library/tables.s \
  Library/math.s \
  Library/lab7_library.s \
  Lab7.s -o frogger.o

arm-none-eabi-gcc -mcpu=cortex-m4 -mthumb -g \
  tm4c123gh6pm_startup_ccs.c frogger.o \
  -T tm4c123gh6pm.cmd -o frogger.elf

arm-none-eabi-objcopy -O ihex frogger.elf frogger.hex
lm4flash frogger.hex
```
Gameplay Controls

    W/A/S/D (keypad) — Move the frog

    Enter — Confirm menu selection

    E — Quit to menu

    1 — Pause/unpause

    2 — Restart level

    M — Mute/unmute music

License & Credits

    TM4C123GH6PM datasheet & reference manual

    EduBase‑V2 trainer board documentation

    Based on classic Frogger gameplay design

::contentReference[oaicite:0]{index=0}
