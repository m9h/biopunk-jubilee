---
category: research
section: introduction
weight: 10
status: draft
title: "The Silent Failure"
slide_summary: |
  ### The failure that defines the problem

  From the DuckBot paper's own text --- syringe transfer was

  > "very sensitive to the exact height (z-position) of the water column."

  A machine with $\pm 5\,\mu$m repeatability would fail **identically**.

  - This is not a motion error. It is a **sensing** error.
  - The machine cannot find the meniscus, so it must guess the depth.
  - And when it guesses wrong, *nothing tells it.*
---

Consider the failure that the DuckBot paper reports, in its authors' own words: syringe-based
frond transfer was "very sensitive to the exact height (z-position) of the water column in the
source container" [@subbaraman2024duckbot].

It is tempting to read this as a precision problem, and to reach for the remedies the
open-source printer community has spent the last five years perfecting: a stiffer gantry,
closed-loop steppers, resonance compensation, an eddy-current probe. Every one of those
remedies would leave this failure completely unchanged. A machine positioning to
$\pm 5\,\mu\mathrm{m}$ would plunge its needle to exactly the same wrong depth, because the
depth was never known. **The machine cannot see the liquid.**

We are careful with this example, because the same sentence in DuckBot reports a *second*
sensitivity --- to "exact positioning of the syringe over the centre of the frond" --- and the
paper's worst result, "almost no successful syringe transfer for *Spirodela polyrhiza*," is
attributed by its authors to neither, but to "heavy, multi-frond ramets and entangled root
systems." Nothing we propose untangles a root system. The z-position sensitivity is the one this
proposal addresses, and it is enough: it is a failure the machine could have *detected* and did
not.

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

## The constraint is not cost. It is attention.

Frugal laboratory automation is routinely motivated by price, and we decline that motivation,
because the field's own evidence does not support it.

The most direct evidence is a study by the same laboratory. De Lange, Dunn and Peek interviewed
sixteen members across eleven community biolabs --- half the identified organisations worldwide ---
and report, as a titled finding, that **"the cost of commercial lab equipment is not a major
constraint"** [@delange2022biolabs]. Every lab in the sample sourced equipment second-hand or by
donation, from local biotech firms and university surplus; several participants complained not of
scarcity but of *overabundance*, and of the space it consumed. DIY equipment, they found, is
rarely built because a commercial equivalent is unaffordable. It is built because building it is
meaningful.

What the same study finds *is* binding is time. Community biolab users are "almost always
hobbyists," for whom lab work is "a minor activity in their lives in terms of time allotment,"
pursuing biology that is simultaneously time-consuming --- long protocols, long incubations --- and
time-sensitive, with steps that must occur inside fixed windows. The paper's title is a
participant's phrase: *short on time and big on ideas*.

This inverts the usual argument for automation, and it sharpens ours. **The scarce resource in
these laboratories is not money and it is not motion precision. It is human attention** --- and
attention is exactly what a machine consumes when it cannot be trusted to run unwatched. A
silent failure does not merely waste a plate. It withdraws the one thing automation was supposed
to return: the ability to *not be there*. A hobbyist who must sit beside a robot to see whether
it seated its tool has bought an expensive pipette-holder. A hobbyist who returns on day ten to a
plate of quietly corrupted data has lost ten days that were never fungible in the first place.

An assertion layer is therefore not a cost-reduction measure. It is what makes an unattended run
*worth attempting*, and it is aimed at the resource the field has told us, in print, that it
actually lacks.
