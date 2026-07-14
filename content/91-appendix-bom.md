---
category: research
section: appendix
weight: 91
status: draft
title: "Bill of Materials and Configuration Notes"
---

## Sensing hardware

| Item | Purpose | Approx. cost |
|---|---|---|
| Coupler continuity kit (6 dowel pins + solder lugs) | Tool-seating assertion (WP3) | **\$0–5** — already documented as the crash-detection mod |
| MEMS differential pressure transducer | Pressure LLD + aspiration-trace monitoring (WP4) | \$10–30 |
| Small-bore tubing, tee, filter | Air-path integration for the transducer | \$10 |
| Dock ID resistors + pogo pins (per dock) | Tool identity (WP3) | \$5 per dock |
| *or* RFID tag + reader (per dock) | Tool identity, richer payload | \$15–20 per dock |
| `jubilee3d/xyz_probe` | Labware touch-off via `G38.2` | ~\$50 |
| Load cell + HX711/ADS1220 (stretch) | Preloaded bed as universal touch-off surface | \$15–40 |

**Total for the core sensing work: well under \$150.** This is the entire hardware cost of the
*sensing*, against a \$1,800 machine.

## The deck: specify it unheated

Jubilee inherits an *optional* silicone heater mat, bonded beneath the MIC6 tool plate and driven
from the Duet's bed-heater output --- a legacy of the platform's descent from tool-changing 3D
printers. **We specify the plate without it**, and the reason is not merely that it is unnecessary.

*No machine in the corpus incubates on the deck.* DuckBot's plates are carried to a growth chamber
daily; FungiBot covers the printbed with waterproof hardboard and a paper towel, prints at ambient
temperature, and *transfers* its prints to a lidded container for a ten-day spawn run
[@luo2025fungibot]; the Sonication Station is ambient. Nor would a print bed serve as an
incubator if one tried: it supplies neither humidity, nor air exchange, nor a photoperiod --- and
a duckweed chamber needs light, not 37 °C.

**And for this proposal specifically, deck heat is an error source, not a null.** Section 21
records that a 3 K gradient across 1 mL of dead air is roughly 10 µL of error, and that ISO 8655-6
bounds temperature drift during verification at $\le 0.5$ K. Our headline sensor (WP4) is a
pressure transducer reading an *air column*; the stretch goal (Section 31) is a *load cell*, whose
thermal drift is the very defect we cite against inductive probes. A heater beneath the deck
degrades both.

It costs nothing to defer. The mat is adhesive-backed, the Duet's bed output and `temp0` remain
free either way (the tool-ID resistor of Section 31 wants `temp1`/`temp2`, so there is no pin
conflict), and a future tool needing a *temperature-controlled* stage would want a Peltier deck
insert rather than a print-bed heater regardless.

## Required: the SBC, without which WP1 is not possible

Not a sensor, and easy to omit from a sensing BOM --- which is exactly why it is called out
separately. A genuine Duet object-model subscription exists **only in SBC mode** (Section 30);
standalone RepRapFirmware polls `rr_model` over HTTP and offers no subscription at all.

| Item | Purpose | Approx. cost |
|---|---|---|
| Raspberry Pi 4 **or 5** | Runs DuetSoftwareFramework; the subscription endpoint for WP1 | \$35–80 |
| Duet 3 SBC ribbon cable (**26-way at the Duet, 40-way at the Pi**) | Duet-to-Pi link | **\$0 — bundled with the board**; \$2.99 as a spare |
| Separate 5 V supply for the Pi | **The Mini 5+ cannot power the Pi** — unlike the 6HC | \$10 |

**The cable is not a generic part, and it is probably already in the box.** The Duet-side header
is a 26-way IDC and the Pi's is 40-way; the cable is wired *straight through*, Pi pins 1--26 to
Duet pins 1--26. A standard 40-to-40 Raspberry Pi GPIO ribbon --- the kind sold for breakout boards
--- **cannot mate with the Duet end at all.** Duet3D bundle the correct cable with the board, and
Filastruder sell it separately for \$2.99. Keep it under $\approx$ 150 mm.

**Run DuetPi, not your favourite distribution.** DSF is published only as Debian packages, from
Duet3D's own apt repository; RPM spec files exist in-tree but are explicitly *"not actively
maintained,"* so a Fedora or Arch host means self-building packages indefinitely. The sharper
obstacle is lower down: on a non-Raspberry-Pi-OS distribution, enabling SPI does **not**
reliably instantiate `/dev/spidev0.0`, which DSF hard-requires --- binding it demands a manual
`driver_override` incantation wrapped in a systemd unit. DSF also confines plugins with AppArmor,
which RedHat-family distributions do not ship. **This is the machine that must survive an
unattended ten-day assay. It is the wrong place to be interesting.**

**Raspberry Pi 5 works**, notwithstanding documentation that still says 3 or 4: Duet3D staff
confirm compatibility and ship a DuetPi image for it. One known trap --- a kernel change remapped
the RP1's GPIO chip, so a stale `"GpioChipDevice": "/dev/gpiochip4"` in `/opt/dsf/conf/config.json`
produces `Failed to open IO device`. Deleting that file lets DCS regenerate it. Prefer a current
DuetPi Bookworm 64-bit image over a hand-configured stock OS.

## The camera: perception as an assertion device

| Item | Purpose | Approx. cost |
|---|---|---|
| On-device-inference camera (Luxonis OAK class) | Deck-level semantic assertions; returns a *predicate*, not an image (Section 31) | \$150–200 |
| Printed bracket + T-nuts, frame extrusion | Static overhead mount | ~\$0 |
| **Not** a depth camera | Stereo is blind to transparent and specular labware (Section 50) | — |

The CSI connector is physically independent of the 40-pin GPIO header, and Duet3D ship an
official **Spyglass** plugin for exactly this configuration, so **one Pi can serve as both the
Duet SBC and the vision host** --- putting the object-model subscription and the camera assertions
on the same machine, where they belong. Two caveats: a USB inference camera is power-hungry and a
Pi's USB3 ports are marginal, so budget a powered hub; and Duet advise disabling Pi WiFi power
management for SPI-link stability, which makes Ethernet the better choice on a machine also
streaming video.

**The metrology camera is a different instrument.** WP0 and WP5 need single-digit
$\mu\mathrm{m}$-per-pixel to resolve a $20\,\mu\mathrm{m}$ figure, which means a small field of
view and real magnification: a **C-mount macro lens on a high-resolution sensor**, looking up at
the tool tip, in the manner of TAMV. A wide-FOV scene camera cannot do this at any resolution,
and should not be asked to.

## Optional: CAN toolboards

Not required by this proposal, but the single best-evidenced mechanical modernisation available
to the platform, and it composes cleanly with the assertion work (each board carries an
accelerometer, enabling per-tool input shaping).

| Item | Note | Cost |
|---|---|---|
| Duet 3 Toolboard 1LC, per *active* tool | Reduces the umbilical from 11–17 conductors to **4** | \$64.99 |
| Duet 3 Tool Distribution Board | 4 × individually-fused 5 A outputs, CAN loop, termination | \$29.99 |

**Three caveats before purchase.** The 1LC's stepper driver caps at **1.6 A peak / 1.1 A RMS** —
adequate for a pipette plunger or a 10 cc syringe, not for anything hungrier (use a 1XD or a
frame-mounted 3HC). **Cameras defeat the four-wire benefit** — DuckBot's Pi cameras are CSI/USB
and need their own run, so plan a mixed bundle. And **passive tools need no board at all**: the
pen, the loop, and the probe want zero wires. Your umbilical count is the count of *active*
tools.

## Optional: feedback for crash detection only

| Item | Note | Cost |
|---|---|---|
| Duet 3 Expansion 1HCL | **Fit to the three Z motors, not X/Y.** Z is 1:1 with its axis; CoreXY is not. | \$101.99 / axis |
| Duet3D magnetic encoder (14-bit) | Calibrates once at assembly; quadrature needs a move at every power-on | \$35.99 / axis |

Run in **assisted open loop** (`M569 D5`), not full closed loop: it retains 256× microstep
interpolation, needs little or no PID tuning, avoids the hunting that has burned most
closed-loop users, and **still raises the same `driver-error.g` events** — which are the only
thing being purchased. Avoid MKS SERVO42 / BTT S42B-class integrated modules: they are step/dir
slaves that *silently self-correct*, so the controller never learns an error occurred, which
defeats the entire purpose.

## Firmware configuration checklist

- **RepRapFirmware $\ge$ 3.6.** The input-shaping algorithm was rewritten to apply to short
  segmented moves; the shipped Jubilee config predates it and contains no `M593` at all.
- **`M400` by default** in every motion primitive of the Python transport (WP1).
- **`driver-error.g` / `driver-warning.g`** macros wired to park, alert, and re-home — *not* to
  halt.
- **`M950 J...`** to expose the coupler-continuity input as a queryable general-purpose input,
  visible in the object model via `M409`. **This is a digital port and only a digital port** ---
  RRF's `GpInputPort::GetState()` performs a digital read and `sensors.gpIn[].value` is 0 or 1.
  Continuity is a digital signal, so Sensor 1 is served correctly.
- **`M308 ... Y"linear-analog"` for the tool-ID resistor**, *not* `M950 J`, which cannot return
  an analogue value. It must land on an ADC-capable pin: on a Duet 3 Mini 5+ those are `io3.in`,
  `io6.in`, `temp1` and `temp2`. **`temp1`/`temp2` are the clean choice** on a Jubilee whose
  heaters live on toolboards, since they are otherwise unused and they leave both analogue-capable
  `io` pins free.
- **Put the tool-lock (U) endstop on the same board as the tool-lock motor.** The Mini 5+'s five
  drivers are consumed by X, Y and three Z motors, so U lands on an expansion board --- and RRF
  cannot use a main-board endstop to control an expansion-board motor.
- **Tool-state interlock** so `G32` refuses to execute with a tool mounted (issue #116).
- **`G38.2` / `M585`** for labware touch-off.
- **`M260.1` / `M261.1`** — Modbus RTU over RS-485, if pumps, valves, or balances are to be
  addressed directly from the motion queue. This is a substantial and entirely unexploited
  advantage of the firmware Jubilee already runs.

## Free interventions (WP0)

Zero cost, and they plausibly dominate everything above:

1. Match the two CoreXY belt tensions to within ~5 Hz over an identical span.
2. Reduce acceleration for tool pickup and drop-off.
3. Diff two TAMV runs a week apart.
4. Swap the Delrin compression flexure in the Remote Elastic Lock for the **O-rings** — already
   an official revision in Jubilee's own CHANGELOG, removing a creep-prone part from the lock's
   load path.
5. Check Y-rail mounting flatness against 0.025 mm / 200 mm before contemplating preloaded rails,
   or the preload will simply bind.

## Materials note for wet-lab work

PLA must go: it cannot be autoclaved ($T_g \approx 55$–60 °C) and loses substantial mechanical
performance after isopropanol exposure. But **do not solve compliance with resin** — the Hawai'i
group's resin parts were brittle (snapping during assembly) *and* showed measurable creep
deflection within weeks of continuous loading. **Resin for chemical resistance; metal for the
structural load path; keep the extrusion.**
