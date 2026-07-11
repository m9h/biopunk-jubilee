---
category: research
section: background
weight: 20
status: draft
title: "How a Printer Became a Laboratory Instrument"
slide_summary: |
  ### The lineage in one line

  **Patents (1986--92) → expiry (2009) → RepRap → Marlin/RRF → CoreXY → toolchangers → Jubilee**

  Two inheritances matter, and they pull in opposite directions:

  - **Good:** exact-constraint design, self-replication ethos, open licensing, a G-code
    control surface anyone can drive.
  - **Bad:** *every convention assumes a lone unattended printer whose failure mode is a
    wasted spool.* Nobody built verification, because nobody needed it.

  A ruined print is cheap. **A ruined 10-day assay is not.**
---

Jubilee did not emerge from laboratory instrumentation. It emerged from desktop 3D printing,
and it inherited that field's assumptions wholesale --- including the assumption that failures
are cheap. Understanding this lineage is not antiquarianism; it explains precisely which of
Jubilee's properties are load-bearing and which are vestigial.

## Patent expiry as a design event

Additive manufacturing was born commercial and closed. Charles Hull's 1986 stereolithography
patent [@hull1986apparatus] founded 3D Systems, and Scott Crump's 1992 patent on fused
deposition modeling [@crump1992apparatus] founded Stratasys. For two decades the technology
was a capital purchase.

The decisive event was not an invention but an **expiry**. As Crump's core FDM claims lapsed
around 2009, an entire consumer industry condensed almost overnight. The intellectual
groundwork had been laid by Adrian Bowyer's **RepRap** project [@jones2011reprap], which
framed the machine not as a product but as a self-replicating, openly licensed organism: a
printer whose purpose was to print the parts for the next printer. RepRap established the
conventions that Jubilee still runs on today --- 3D-printed structural parts, commodity
extrusion frames, stepper motors, G-code, and a culture in which the design files are the
deliverable.

Patents remain a live constraint on this design space, and one bears directly on our
recommendations. Stratasys holds US 8,926,484 B1 [@stratasys2015toolchanger], with priority in
2010 and an anticipated expiry in 2033, covering tool changers in which docked heads are
powered through the dock and hand off to the gantry on pickup. This is exactly the "pogo pins
in the dock" architecture that every toolchanger designer eventually proposes, and it is why
no vendor sells one.

## The firmware fork, and why Jubilee is on the right side of it

Control firmware bifurcated. **Marlin** carried the RepRap tradition of running everything on
an 8-bit microcontroller. **Klipper** moved motion planning onto a Linux host, buying
sophisticated resonance compensation at the cost of putting a general-purpose operating system
in the real-time control path. **RepRapFirmware** (RRF), on Duet hardware, kept hard real-time
planning on the microcontroller while exposing a rich, queryable object model over HTTP.

Jubilee runs RRF, and for a laboratory this is the correct choice for a reason that has nothing
to do with print quality. **Klipper hard-fails when any configured MCU is absent or drops:**
`mcu.py` invokes a printer-wide shutdown on lost communication. For a machine whose entire
premise is that tools are added, removed, and serviced, this is disqualifying. RRF degrades
gracefully --- a missing CAN board yields a configuration error and the machine continues.

RRF also carries two capabilities that the laboratory-automation community has almost entirely
overlooked. Its **meta-G-code** provides real conditionals, loops, and variables. And since
version 3.6 it speaks **Modbus RTU over RS-485** (`M260.1`/`M261.1`), meaning the motion
controller can address syringe pumps, valves, and balances *directly from the motion queue*,
with no host round-trip. Klipper has no equivalent. The firmware Jubilee already runs is, for
this application, better than the one the field keeps recommending it migrate to.

## Toolchanging, and the number nobody measured

Multi-material printing drove the development of automatic tool changers, converging on a
common mechanical vocabulary: a three-groove **Maxwell kinematic coupling** giving exact
constraint in six degrees of freedom, with a lock supplying preload. E3D's ToolChanger
popularised the pattern; Jubilee's *Remote Elastic Lock* refines it with a frame-mounted geared
motor driving push-pull cables to a twist-lock, so that lock actuation adds no mass to the
moving gantry, and locking proceeds to a constant *torque* --- sensed by a spring-loaded
microswitch --- rather than to a position.

It is elegant. It is also, as of this writing, **unmeasured**. Jubilee's public claim is that
it "has performed thousands of toolchanges flawlessly": no method, no sample size, no standard
deviation. The entire open-source field contains exactly one independently measured toolchanger
repeatability dataset, for the E3D ToolChanger, and its result is the most useful number in
this document [@e3d_toolchanger_review]:

| Quantity | Value |
|---|---|
| Mean X offset | 0.022 mm |
| Mean Y offset | 0.025 mm |
| Mean $\sigma$ | **0.026 mm** |
| E3D's bench claim for the coupling alone | **$<$ 0.005 mm** |

The coupling repeats to single-digit microns on a bench; the system delivers roughly
$25\,\mu\mathrm{m}$ at the tool tip. **The fivefold gap is gantry compliance, belt stretch,
thermal state, and process --- not the coupling.** The corollary is important and
counter-intuitive: effort spent redesigning a tool changer is spent on the wrong term. And
Jubilee's own tool-alignment guidance (0.02 mm by hand) sits directly on top of E3D's
*measured* figure, which raises a possibility nobody has tested --- that a well-built Jubilee
is already at commercial-toolchanger parity.

## The inheritance that hurts

Every convention Jubilee inherited was formed in a context where **the cost of a silent failure
is a wasted spool of filament**. Printers do not verify that the tool seated, because a
mis-seat shows up as a visible defect in a part that is worthless anyway. They do not confirm
that a move completed, because the next move will simply queue behind it. They do not detect
liquid, because there is none.

Port that machine into a laboratory and every one of those absences becomes a mechanism for
generating plausible, well-formatted, wrong data over a ten-day experiment. The hardware
crossed over. **The verification culture did not.**
