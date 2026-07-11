---
category: research
section: introduction
weight: 10
status: draft
title: "The Silent Failure"
slide_summary: |
  ### The failure that defines the problem

  From the DuckBot paper's own text:

  > "almost no successful syringe transfer for *Spirodela polyrhiza*" --- transfer was
  > "very sensitive to the exact height (z-position) of the water column."

  A machine with $\pm 5\,\mu$m repeatability would fail **identically**.

  - This is not a motion error. It is a **sensing** error.
  - The machine cannot find the meniscus, so it must guess the depth.
  - And when it guesses wrong, *nothing tells it.*
---

Consider the failure that the DuckBot paper reports, in its authors' own words: syringe-based
frond transfer was "very sensitive to the exact height (z-position) of the water column," with
"almost no successful syringe transfer for *Spirodela polyrhiza*" [@subbaraman2024duckbot].

It is tempting to read this as a precision problem, and to reach for the remedies the
open-source printer community has spent the last five years perfecting: a stiffer gantry,
closed-loop steppers, resonance compensation, an eddy-current probe. Every one of those
remedies would leave this failure completely unchanged. A machine positioning to
$\pm 5\,\mu\mathrm{m}$ would plunge its needle to exactly the same wrong depth, because the
depth was never known. **The machine cannot see the liquid.**

This is the paper's thesis in miniature. The Jubilee-derived science machines are not
meaningfully limited by their motion; they are limited by their inability to observe their own
state. And because they cannot observe it, they cannot *check* it --- which means their
failures are not loud, they are silent, and a silent failure in an automated assay does not
halt the experiment. It contaminates it.

## Three failures with one root

The pattern recurs at every layer of the stack, and it is worth stating the three most damaging
instances plainly, because the rest of this proposal is a response to them.

**The tool can fail to seat, silently.** Jubilee's own maintainers write that it is "quite
likely with all revisions of Jubilee so far" that a tool is picked up without properly locking:
the twist-lock snags in the wedge and rotates the entire tool rather than drawing it into the
kinematic coupling, so the balls never seat against the pins. Nothing in the machine detects
this. On a 3D printer the consequence is a cosmetic artefact. On a pipetting robot it is a
silently displaced Z datum and a plate of quietly wrong data, with no error anywhere in the
log.

**The control layer cannot tell you a motion finished.** `science-jubilee`'s `Machine.gcode()`
is a synchronous HTTP call that blocks until a command is *acknowledged*, not until motion
*completes* [@sciencejubilee]. Completion is opt-in per call. An independent group at the
University of Hawai'i rediscovered this the hard way while adapting a Jubilee for automated
dip coating, reporting that "the Python script transmitted motion commands more quickly than
the controller could execute them," and that their workaround was "to embed long pauses after
each dip" [@vierra2025dipcoating]. The library's own source concedes the rest: a `TODO` to
"figure out how to print error messages from the Duet," an unimplemented retry backoff, and a
commented-out websocket subscription to the machine's state model.

**The machine cannot find a liquid surface.** There is no liquid-level detection anywhere in
the ecosystem --- neither capacitive nor pressure-based --- and consequently no meniscus
following, no submersion control, and no defence against the carryover that comes from
wetting the outside of a tip. The volume model in `Pipette.py` is a single linear scalar,
`dv = vol * self.mm_to_ul`, with no per-liquid calibration curve.

## The fix is already in the building

The striking thing about this diagnosis is that the Machine Agency has already published the
answer to it. **Tandem**, presented at CHI 2024 by Tran O'Leary, Ramesh, Zhang, and Peek, is a
computational-notebook environment for fabrication whose central contribution is precisely
*"explicit assertions in code to flag potential mismatches between physical and digital
states"* [@oleary2024tandem]. It bundles design intent, machine control, and quality
checkpoints into one re-runnable document, and it was demonstrated on the hardest instance of
physical--digital divergence in subtractive manufacturing: two-sided milling, where the
workpiece is flipped and the datum must be proven to have survived.

A mis-seated tool is a physical--digital mismatch. A stale Python tool-state boolean is a
physical--digital mismatch. A labware slot that is not where the deck file says it is, is a
physical--digital mismatch. These are exactly, and without strain, the category of defect that
Tandem was built to assert against.

And yet Tandem lives in a separate repository --- four stars, last pushed December 2024
[@tandem_repo] --- wired to a CNC mill, while `science-jubilee` continues to drive the
biology machines through an assertion-free HTTP shim. Read DuckBot's own future-work section,
which states that unattended operation "would need additional error detection and failsafes,"
and then read Tandem's abstract. **The same laboratory wrote the answer to its own stated open
problem and never connected the two artefacts.**

## What this proposal is, and is not

We propose to make that connection, and to supply the sensors without which the assertions
would be vacuous --- because an assertion that can only interrogate a Python variable asserts
nothing about the world.

We wish to be clear about what we are *not* proposing, because the temptations are strong and
the evidence is against all of them. We do not propose a new gantry: the only measured
toolchanger dataset in the field locates roughly 80\% of the error budget downstream of the
kinematic coupling, in the machine [@e3d_toolchanger_review]. We do not propose closed-loop
servos for the X and Y axes: on a CoreXY the encoder can only observe the motor shaft, which
is upstream of every error source that actually matters. We do not propose an eddy-current
probe: those sensors detect a conductive target and are physically blind to the plastic
labware that constitutes a laboratory deck. And we do not propose migrating to Klipper, which
hard-fails the entire machine when any configured MCU is absent --- a catastrophic property
for a platform whose tools are designed to come and go.

What is left after those exclusions is cheap, unglamorous, and load-bearing: a completion
handshake, a seating switch, a pressure sensor, a calibration curve, and an assertion layer.
This proposal specifies them, situates them in the history of the two fields that produced
Jubilee, and defines the measurements by which the work should be judged.
