---
category: research
section: methodology
weight: 31
status: draft
title: "The Three Sensors That Make Assertions Bite"
slide_summary: |
  | Sensor | What it asserts | Cost | Status |
  |---|---|---|---|
  | **Coupler continuity** | the tool seated | ~\$0 | *exists* --- as an E-stop |
  | **Pressure LLD** | where the meniscus is | ~\$30 | **nobody has built this** |
  | **Dock tool ID** | the right tool is mounted | ~\$5--20 | resistor or RFID |

  **`jubilee3d/xyz_probe`** (\$50, already exists, unused) + `G38.2` touches off well A1.

  *Do not buy an eddy-current probe. It cannot see plastic.*
---

An assertion layer over a blind machine asserts nothing. This section specifies the minimum
sensing required, in ascending order of effort. All three are modest; one of them, to our
knowledge, has never been built in this ecosystem and is the single highest-leverage piece of
hardware available to it.

## Sensor 1: Tool seating (promote what already exists)

**The hardware is already documented.** `science-jubilee` describes a tool-crash-detection
modification: six dowel pins and solder lugs across the coupler, forming a circuit that is
broken when the tool's balls lift out of their kinematic seats. This is, functionally, a
seating sensor --- a mis-seat means the balls never seated, so the circuit never closes.

**Three changes convert it from a tripwire into an assertion.**

1. **Check it on every pickup**, not only when a crash occurs. Seating is a *precondition* for
   every subsequent motion, and it is free to verify.
2. **Route it into the object model as a queryable input**, not into an emergency stop. In RRF
   this is a `M950 J...` general-purpose input, readable via `M409` and therefore visible in the
   websocket state we are already subscribing to.
3. **Make the failure recoverable.** On a failed assertion the machine should return the tool
   to its post, re-approach, and retry --- and only escalate after a bounded number of attempts.
   The existing E-stop behaviour, which the docs concede is "a major hassle" to recover from, is
   precisely the wrong response for an unattended run.

## Sensor 2: Pressure-based liquid-level detection (the unbuilt one)

This is the proposal's most substantive hardware contribution. It addresses one of the two
sensitivities DuckBot reports --- the one that is a sensing problem rather than a vision or a
biology problem (Section 21).

**Why pressure rather than capacitance.** Capacitive LLD requires a conductive tip and a
conductive liquid, and its signal depends on the vessel's stray capacitance --- making it a
thresholded, labware-dependent sensor [@pochert2000lld]. Pressure-based LLD requires neither. Its
signal is **independent of vessel size**, works in a 1536-well plate, and functions on
non-conductive organics. For a DIY build it is also simply easier: it needs a differential
pressure sensor in the air path, not a high-frequency capacitance bridge and a conductive tip.

**Construction.** A MEMS differential pressure transducer (a few dollars; the class of part used
in ventilators and spirometers) tees into the air column between the plunger and the tip. The
tool descends while the plunger aspirates air at a constant, slow rate. The instant the orifice
seals against the liquid surface, the pressure drops sharply. Detection latency in commercial
systems is under 10 ms; at a 100 mm/s descent that corresponds to sub-millimetre resolution.

**What it buys, in order of importance.**

- **Meniscus finding**, which eliminates the fixed-depth guess behind the z-position sensitivity
  DuckBot reports.
- **Liquid-following**: submerge 1--2 mm and track the surface down during aspiration. This is
  the *actual* fix for carryover, because it minimises the wetted outer tip area --- the
  contamination path that no filter tip can address, since it is on the wrong side of the
  filter.
- **Aspiration-trace monitoring** for free. The same sensor, watching the pressure curve
  against a per-liquid envelope, detects clots, bubbles, and short volumes. This is Hamilton's
  TADM, and it is the mechanism by which a dispense becomes *assertable* rather than merely
  commanded.
- **A hydrostatic volume check.** The post-aspiration plateau pressure is offset by exactly the
  head of the column just drawn. The sensor that finds the surface also, in principle,
  *measures the draw*.

**The coupling constraint, stated honestly.** As Section 21 argued, Hamilton engineered tip
retention *away* from Z-axis force precisely so that in-line pressure sensing could exist.
DuckBot's press-fit tip attachment drives the seating force through the same air column the
sensor watches. We therefore expect a seating transient, and we do not propose to solve it
mechanically. We propose to **gate the sensor**: the pressure channel is ignored during tip
attachment and zeroed (tared) immediately afterward, exactly as load-cell probes tare before
each probe. This is a well-understood pattern and we flag it as the first thing to validate on
the bench.

## Sensor 3: Tool identity, in the dock

The machine should know *which* tool it picked up, and refuse to run a protocol calling for a
P300 with a P20 on the carriage.

The correct implementation places the contacts in the **dock**, not in the coupling. Two
variants, both endorsed by Duet's designer in response to exactly this question:

- **Pogo pins plus an ID resistor** on each tool --- a different resistance per tool, read as an
  analogue input.
- **An RFID tag per tool and a reader per dock**, carrying not just an identity but the tool's
  CAN address, type, and capabilities.

Placing the contacts in the dock avoids all three problems that kill contacts on the coupling:
there is no make/break under load, no risk of breaking a stepper connection under a live driver,
and no exposure to the Stratasys patent [@stratasys2015toolchanger], which claims powered docks
that *hand off* to the gantry --- not passive identity contacts.

## What we deliberately do not add

**No eddy-current probe.** The modern probing advance (Beacon, Cartographer, BTT Eddy) works by
inducing currents in a **conductor** and is physically blind to plastic. A Delrin deck, a well
plate, a tip rack, a Petri dish does not exist to these sensors: they read the aluminium
*through* the labware or fail to trigger and drive the tool into it. Two of the three do not run
on RepRapFirmware at all.

**Use contact probing instead --- which Jubilee already has and does not use.**
`jubilee3d/xyz_probe` is a \$50 kinematically-coupled touch probe that reaches 38 mm into a
pocket, and RRF has supported the `G38.2` straight probe and `M585` probe-to-feature for years.
This is the Renishaw pattern: material-agnostic, and the right way to register well A1 and
tip-rack corners.

**A stretch goal worth naming.** Jubilee's own V3 wishlist proposes that "since the bed is
kinematically coupled, it can be used, in principle, as a touch-off surface," requiring only
that the bed be preloaded. **Preload the three-point bed and instrument one point with a load
cell, and the entire deck becomes the probe** --- surface-agnostic, tool-agnostic, free of the
thermal drift that plagues inductive sensors, and returning a *force*, which in a laboratory is
the point: it distinguishes "touched the plate lip" from "crushing a tip." We list this as a
stretch goal rather than a core deliverable because it touches the machine's structural loop and
therefore requires re-tramming, but it is the most elegant sensing idea in the entire Jubilee
corpus and it is sitting unbuilt in the project's own documentation.
