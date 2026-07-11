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
proposal, against a \$1,800 machine.

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
  visible in the object model via `M409`.
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
