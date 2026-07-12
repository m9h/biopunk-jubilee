---
category: research
section: methodology
weight: 32
status: draft
title: "Work Packages and Sequencing"
slide_summary: |
  | WP | Deliverable | Effort |
  |---|---|---|
  | **0** | **Characterise the machine** | **1 wk, \$0** |
  | 1 | Transport: websocket, `M400`, typed exceptions | 3 wk |
  | 2 | Assertion layer + provenance | 3 wk |
  | 3 | Seating sensor $\rightarrow$ recoverable assertion | 2 wk |
  | 4 | Pressure LLD + liquid classes | 8 wk |
  | 5 | Metrological validation | 4 wk |

  **WP0 is a decision gate.** If offsets already repeat inside 20 µm, the mechanical
  half of this proposal is unnecessary --- and we say so publicly.
---

The work is sequenced so that the cheapest, most decision-relevant results arrive first, and so
that a negative result at any stage is publishable rather than merely disappointing.

## WP0 --- Characterise the machine before changing it (1 week, \$0)

Nothing in this proposal should be built before the machine is measured, because the measurement
may obviate half of it.

- **Match the two CoreXY belt tensions** to within ~5 Hz plucked over an identical span, and
  **reduce acceleration for tool pickup and drop-off.** The rationale is given in Section 41: a
  belt-tension mismatch racks the gantry *as a function of the acceleration vector*, and a
  dynamic rack --- unlike a static skew --- is **not** absorbed by per-tool offsets, because the
  dock approach has a different acceleration profile from the calibration moves. This is a
  plausible mechanical explanation for the reported mis-seating, and it is free to eliminate.
- **Diff two TAMV runs a week apart.** TAMV is Jubilee's existing machine-vision tool-alignment
  utility; the difference between two runs is a real repeatability figure for a real machine.
- **Run the formal repeatability protocol** of Section 40.

**This is a decision gate, not a formality.** If tool offsets repeat inside
$\approx 20\,\mu\mathrm{m}$, the machine is already at the measured E3D ToolChanger figure
($\sigma \approx 26\,\mu\mathrm{m}$ [@e3d_toolchanger_review]), the mechanical anxieties in the
literature are misplaced, and we should say so loudly and proceed directly to the software and
sensing work. If it does not, we have located the problem before spending anything.

## WP1 --- Transport (3 weeks)

Replace the blocking HTTP shim. Subscribe to the Duet object model; default `M400` on every
motion primitive; surface RRF driver and heater events as typed Python exceptions; wire
`driver-error.g` and `driver-warning.g` to hooks that pause, park, and alert rather than halt.
Retain `simulated=True` and make it faithful enough to test against, which it currently is not.

**This work package has a hardware prerequisite, and it is easy to miss.** A real object-model
subscription requires **SBC mode**: a Raspberry Pi attached to the Duet, running
DuetSoftwareFramework, addressed from Python via `dsf-python`. Standalone RepRapFirmware offers
no subscription --- only HTTP polling of `rr_model` (Section 30). Provision the Pi, the ribbon
cable, and its separate power supply *before* WP1 begins, or the work package will be discovered
to be impossible in its first week.

**Acceptance:** a protocol issuing 10,000 queued moves completes with no lost commands and no
`sleep()` anywhere in the caller's code; a deliberately induced stall raises a catchable
`MotionFault` within one motion segment.

## WP2 --- Assertion layer and provenance (3 weeks)

Port Tandem's assertion model [@oleary2024tandem] into `science_jubilee`. Implement
`machine.asserting()` contexts, `require`/`assert_` primitives, recovery policies (`Retry`,
`Park`, `Escalate`), and an append-only run record capturing every discharged assertion with its
measured value, tolerance, and timestamp.

Re-implement `@requires_active_tool` to query the firmware object model rather than a Python
boolean --- closing the latent correctness bug described in Section 30.

**Acceptance:** the DuckBot growth assay runs end-to-end with assertions enabled, and the run
record contains a verified entry for every tool change and every dispense.

## WP3 --- Seating assertion (2 weeks)

Promote the existing crash-detection modification to a queryable input; check it on every
pickup; implement bounded re-seat-and-retry. Add the firmware-side tool-state interlock that
issue #116 has requested since 2021, so that `G32` cannot execute with a tool mounted.

**Two firmware constraints to design around, both discovered late by anyone who does not read
them first.** Coupler continuity is a digital read and is correctly an `M950 J` general-purpose
input --- but **`M950 J` is digital-only**, so the *analogue* tool-ID of Section 31 cannot use it
and must be an `M308` `linear-analog` sensor on an ADC-capable pin (Appendix 91). And on a Duet 3
Mini 5+, whose five drivers are consumed by X, Y and three Z motors, the U tool-lock axis lands
on an expansion board --- where RRF's CAN limitation bites: *endstops connected to the main board
cannot control motors on an expansion board.* The tool-lock endstop must therefore live on the
same board as the tool-lock motor. This is precisely the interlock WP3 exists to build.

**Acceptance:** a deliberately fouled parking post produces a logged, recovered mis-seat rather
than a silent one --- and, after exhausting retries, a parked machine and an alert rather than a
dead one.

## WP4 --- Pressure LLD and liquid classes (8 weeks)

Build the pressure-sensing pipette tool of Section 31. Validate the seating-transient gating
strategy first, on the bench, because if in-line pressure sensing proves incompatible with
press-fit tip attachment the tool's design must change and we would rather know in week one.

Then replace the linear `mm_to_ul` scalar with a per-liquid, per-tip calibration curve plus
settling delays, blow-out parameters, and liquid-following --- a minimal liquid-class model.
Calibrate against water, a viscous standard (glycerol), and a volatile (ethanol), which is the
minimum set that exposes the *anti-correlated* parameter problem described in Section 21.

**Acceptance:** meniscus detection with a standard deviation under 0.5 mm across the deck's
labware; aspiration-trace monitoring that flags a deliberately introduced air bubble.

## WP5 --- Metrological validation (4 weeks)

Execute the protocols of Section 40 and publish the numbers whatever they are. Gravimetric
volume verification per ISO 23783 [@iso23783]; photometric verification via ratiometric dual-dye
[@bradshaw2005mvs] for channel-resolved data. Report systematic and random error separately,
across the volume range, for each of the three liquid classes.

**Acceptance:** the first published, independently measured accuracy and precision figures for a
Jubilee-based liquid handler --- benchmarked against the Digital Pipette's demonstration that a
DIY tool can meet ISO 8655-2 permissible error [@yoshikawa2023digitalpipette].

## Deliberate non-goals

We are not building a scheduler, a laboratory information system, or a domain-specific language.
We are not migrating to Klipper. We are not redesigning the tool changer, the frame, or the
gantry. We are not adding closed-loop servos to X and Y. Each of these is either evidenced
against in Section 42 or is simply a different project.
