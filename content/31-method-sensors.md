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
  | **Pressure LLD** | where the meniscus is | ~\$30 | **unbuilt in the open** |
  | **Dock tool ID** | the right tool is mounted | ~\$5--20 | resistor or RFID |

  Plus: **generalise the camera they already have** --- one overhead frame discharges
  whole-plate occupancy; DuckBot rasters at \~1 min/well.

  *No eddy-current probe: blind to plastic. No depth camera: blind to what it holds.*
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

## The sensor they already have, and what it should become

The three sensors above are the ones that do not exist. A camera is the one thing that does ---
DuckBot ships two --- and the proposal would be incomplete if it did not say what should become of
it, because a camera is already the ecosystem's only working assertion device (Section 30).

**Generalise it from a predicate to a predicate *engine*.** DuckBot's camera answers exactly one
question, about one organism, in protocol code: *is there a frond in this well?* The same physical
device, addressed as a perception tool with a declared set of predicates, could equally discharge
*is a plate seated in its nest*, *is the tip rack present and full*, *did a tip attach*, and *is
this well empty when the protocol says it should be full.* These are the deck-level semantic
assertions of Section 30, and none of them requires new hardware --- only that the camera be
exposed as an assertion primitive rather than buried in an experiment script.

**Prefer a camera that returns a predicate, not an image.** An on-device inference camera --- the
Luxonis OAK class, built around a vision accelerator --- runs the network on the camera and returns
the *result*. This matters architecturally rather than merely conveniently: the Sensor Rule
demands that an assertion be discharged by a measurement, and such a device's output *is* the
discharged measurement. It also keeps a perception workload off the single-board computer that,
after Section 30, is holding the machine's object-model subscription.

**One frame can replace an hour of rastering.** DuckBot images its plates well by well, at roughly
one minute per well --- 448 images over a ten-day assay [@subbaraman2024duckbot]. But a 12-megapixel
sensor spans about 4000 pixels. Framed across a whole Jubilee deck ($\approx$ 300 mm), that is
some 13 px/mm; framed across a single microplate, better than 30 px/mm. A duckweed frond of 3 mm
is tens of pixels across in either case. **For the occupancy predicate --- which wells contain a
frond --- a single static overhead frame answers for an entire plate**, where the per-well raster
spends an hour of machine time to answer the same question.

We state the boundary of that claim precisely, because it is easy to overreach. DuckBot's per-well
imaging exists for *growth quantification* --- frond area over time --- and that is a measurement, not
an assertion; it plausibly needs the magnification and we do not propose to remove it. The claim
is narrow: **an overhead perception camera discharges deck-level assertions cheaply. It does not
replace the assay's imaging.**

**Occlusion is not a problem; it is an argument.** A camera above a Jubilee deck looks through the
gantry and the mounted tool. The answer is not to mount off-axis and rectify, but to capture *when
the deck is clear* --- which requires knowing that a motion completed and the gantry has parked.
That is precisely the handshake WP1 exists to build. A machine that cannot confirm a move has
finished cannot even take a clean photograph of its own deck.

## What we deliberately do not add

**No eddy-current probe.** The modern probing advance (Beacon, Cartographer, BTT Eddy) works by
inducing currents in a **conductor** and is physically blind to plastic. A Delrin deck, a well
plate, a tip rack, a Petri dish does not exist to these sensors: they read the aluminium
*through* the labware or fail to trigger and drive the tool into it. Two of the three do not run
on RepRapFirmware at all.

**No depth camera** --- and the reason rhymes with the one above, which is why we state them
together. Stereo depth, including active stereo with an infrared dot projector, must correlate a
*diffuse, opaque, textured* surface. A laboratory deck is transparent well plates, clear
polypropylene tips, glossy plastic, and liquid. **A meniscus is close to the worst target stereo
can be given**: it is transparent and specular, so the projected pattern scatters or mirrors
rather than landing on it. Two fashionable sensors, two unrelated physics, defeated by the same
deck --- one blind to plastic, the other blind to what plastic contains (Section 50).

The geometry is decisive independently of the optics. Stereo depth resolves to roughly 1--2\% of
range, which is millimetres at any working distance over a Jubilee deck. Tool seating is a
micron-scale question, and a continuity switch answers it for nothing. The registration assertion
we actually want --- *is this plate a millimetre out of its nest* --- requires resolving comfortably
inside a millimetre, so millimetre-class depth sits exactly at the noise floor of the effect it
is supposed to detect. And tool-change repeatability is a $20\,\mu\mathrm{m}$ question, three
orders of magnitude away. **Every assertion needing sub-millimetre precision is beyond stereo's
reach, and every assertion within its reach is already answerable in two dimensions.** Depth
purchases nothing this machine needs.

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
