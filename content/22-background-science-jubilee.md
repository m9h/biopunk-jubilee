---
category: research
section: background
weight: 22
status: draft
title: "Science Jubilee and Its Machines"
slide_summary: |
  ### An ambitious software stack on a frozen mechanical base

  | | |
  |---|---|
  | Jubilee hardware, last commit | **January 2023** (62 open issues) |
  | `science-jubilee`, last push | **April 2026** (actively developed) |
  | Tests in `science-jubilee` | **1** (a 93-byte import check) |
  | Tests in PyLabRobot | **1,779** |
  | Published tool-change repeatability | **none, anywhere** |

  Thirteen tool drivers. Opentrons labware schema. Real scientific output.

  And **a `TODO` in `Machine.py` that reads: "Figure out how to print error messages
  from the Duet."**
---

## The platform

Jubilee [@vasquez2020jubilee] is a CoreXY motion platform with an automatic tool changer,
released under CC BY 4.0 and certified by OSHWA. It offers a 300 mm cube of travel, a
kinematically coupled bed with three-point auto-tramming, MGN12 linear rails throughout, and a
tool rack holding four tools. The Filastruder kit is \$1,800; self-sourcing runs about \$1,400.
It is controlled by a Duet 3 board running RepRapFirmware.

Its provenance matters for how it should be judged. It came out of the **Machine Agency**, a
group in the University of Washington's Department of Human Centered Design & Engineering,
whose stated thesis is "the precision of machines for the creativity of individuals," and whose
intellectual lineage runs through Peek's work on modular machine building
[@peek2016machines]. Jubilee was published at CHI --- a human--computer interaction venue --- and
it optimises for *extensibility, accessibility, and democratisation*.

**This is the correct frame for every criticism in this proposal.** Jubilee contains no
characterisation section because it is not a metrology paper, and it never claimed to be. It
succeeded, comprehensively, at what it set out to do. The difficulty is that the machines now
being built on it have inherited requirements it never promised to meet.

## The science stack

`science-jubilee` [@sciencejubilee] is the MIT-licensed Python layer, and it is genuinely
impressive in scope. It ships thirteen tool drivers --- pipette, syringe, HTTP syringe, syringe
extruder, camera, web camera, inoculation loop, sonicator, spectrometer, AS7341, peristaltic
pumps, pump dispenser, pneumatic sample loader --- along with deck and labware abstractions that
consume **Opentrons labware JSON (schema v2)** directly, and calibration notebooks. Its
documentation is excellent and is arguably the project's most valuable asset.

Four machines have been built on it, and they are real science:

- **DuckBot** [@subbaraman2024duckbot] --- automated imaging and manipulation of duckweed, with
  a six-tool set and a genuinely autonomous behaviour: after each transfer round, the camera
  images the destination plates, identifies wells that remain empty, and *re-attempts them*.
- **FungiBot** [@luo2025fungibot] --- a paste extruder for mycelium biocomposites, printing a
  living, inoculated coffee-ground medium.
- **The Sonication Station** [@politi2023sonication] --- a materials-acceleration platform for
  CdSe nanocrystal synthesis, running 625 conditions in triplicate. Note its architecture
  carefully: it ran a Jubilee **alongside** an OT-2 and a plate reader. It did not replace the
  commercial instrument; it partnered with it.
- A **dip-coating** platform, independently developed at the University of Hawai'i
  [@vierra2025dipcoating].

The programme is funded (NSF award 2229018) and has institutional momentum
[@pelkie2025democratizing].

## The structural problem

The hardware repository's last commit to `main` was **January 2023**; the design is frozen at
v2.2.2, released October 2021, with **62 open issues** that include every failure mode discussed
in this proposal. Meanwhile `science-jubilee` commits into 2026. **An increasingly sophisticated
laboratory-automation layer is accumulating on a mechanically unmaintained base.**

The specific defects that this proposal responds to are all documented in the project's own
tracker and source:

- **#12** (open since January 2020) --- no quick-disconnect for tool utilities.
- **#43 / #119** --- silent tool mis-seating; toolchange repeatability named by the maintainers
  as a cause of print artefacts.
- **#116** (open) --- no tool-state interlock; `G32` will drive a mounted tool through the bed.
- **#26** --- printed toolplates creep under the twist lock's own axial preload. The
  maintainer's conclusion: "A metal plate will fix all of these issues." The stock design still
  ships printed plates.
- **#45** (open) --- "I'm on my 7th replacement Z homing switch."

And in `Machine.py` itself: a blocking HTTP transport, a `TODO` reading *"Figure out how to
print error messages from the Duet,"* an unimplemented retry backoff, and a commented-out
websocket import.

## What the machines actually measured

For a proposal that turns on metrology, it is essential to be exact about the state of the
evidence. **DuckBot publishes no liquid-handling metrology at all** --- no volume accuracy, no
%CV, no throughput beyond "approximately a minute" per well, and no transfer-success
percentages (the species comparison is entirely qualitative, with no $n$). The paper
explicitly performs **no significance tests**.

The authors are candid about this, and it is a fair statement of an extensibility paper: "the
results from our example experiments are not the key contribution of this work." The single
accuracy statement in the entire ecosystem appears in the *documentation*, not the paper, and
is a claim of having "reproduce[d] the accuracy and precision values published by Opentrons for
their pipettes" after gravimetric calibration.

**DuckBot's volumetric performance is therefore asserted by reference to another vendor's
datasheet, and has never been independently tabulated.** That is the gap. It is not a criticism
of the authors, who told us as much. It is a statement of what remains to be done --- and it is
the first thing a reviewer of any Jubilee-based assay will ask.

Their own limitations section closes the loop for us. Unattended operation, they write, "would
need additional error detection and failsafes." That sentence is this proposal's charter.
