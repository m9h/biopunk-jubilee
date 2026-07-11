---
category: research
section: background
weight: 23
status: draft
title: "The Answer, Already Written Twice"
slide_summary: |
  ### Two threads converge here. They have already met.

  - **Tandem** (CHI '24, **Peek**): *"explicit assertions... to flag mismatches between
    physical and digital states."* Pointed at a milling machine.
  - **Jake Read's line** (CBA, **Gershenfeld**): machines that measure themselves.

  ### MAXL (SCF '23) --- Read, **Peek**, Gershenfeld

  Time-synchronised trajectories across heterogeneous actuators **and sensors**.
  One demo is synchronised accelerometer *retrieval*.

  The clock is shared. The sensors are plumbed. **Nobody wrote the `assert`.**
---

The strongest argument for this proposal is that it is not really a new idea. It is the
conjunction of two lines of work that the same people have already published, and that have
already once appeared in the same paper.

## Thread one: Tandem, and the assertion

Tandem [@oleary2024tandem] addresses a problem in experimental digital fabrication: workflows
are increasingly elaborate and consequently increasingly irreproducible. Its response is to
encode an entire end-to-end process as a computational-notebook program that another person can
execute to physically recreate the work.

Four capabilities distinguish it from a plain Jupyter notebook driving a machine. It exchanges
data with CAD and CAM, so design intent stays live in the program. It projects augmented-reality
interfaces onto the machine to guide the manual interventions real workflows always contain. It
directly controls machines. And --- decisively for us --- it supports **explicit assertions in
code to flag potential mismatches between physical and digital state.**

Its demonstration is two-sided CNC milling: machine one face, flip the workpiece, and then
*prove* the datum survived the flip. This is the canonical instance of physical--digital
divergence, and it is structurally identical to a tool change. In both cases a physical object is
decoupled from its reference frame, re-coupled, and thereafter trusted.

## Thread two: Jake Read, and the machine that measures itself

Running in parallel at MIT's Center for Bits and Atoms is a body of work whose thesis is that
**machines should observe their own state rather than assume it.**

The clearest artefact is *Online Measurement for Parameter Discovery in Fused Filament
Fabrication* [@read2024online]. An extruder is instrumented with a load cell, a filament encoder,
a Hall-effect diameter sensor, and a thermocouple; it fits a pressure function $P = f(T, Q)$ *in
situ*; and it then **derives** its own process parameters instead of being told them --- succeeding,
in the authors' words, "even in materials that we had never printed before." That is a machine
that measures itself, built with cheap sensors, on a commodity motion platform. It is the
existence proof that everything this proposal asks for is achievable.

The programme states its own diagnosis explicitly. *Computational Metrology for Materials*
[@warren2025metrology], written with NIST, observes that R&D "is continuously hindered by the
lack of data," that characterisation workflows are "proprietary… often poorly integrated," and
proposes to "merge the metrological and control aspects of the entire system" by modelling "each
of the sensors onboard a machine… as well as the function of the machine itself." And Read's
thesis proposal, *The End of GCode* [@read2024endofgcode], puts the indictment in one line:
machines should stop "blindly executing pre-generated instructions" and instead "measure their
own performance."

**The verification gap is therefore not an outside criticism of this lineage. It is a deficiency
the lineage has named, in print, itself.**

## The two threads have already met, and stopped one step short

In 2023, Jake Read, **Nadya Peek**, and Neil Gershenfeld jointly published **MAXL: Distributed
Trajectories for Modular Motion** [@read2023maxl] --- CBA and the UW Machine Agency, on the same
paper. It is a modular control architecture for "synchronous control of heterogeneous
components," and its four contributions include a distributed trajectory object, high- and
low-level APIs, and a time-synchronisation algorithm.

Read what it demonstrates. One application is time-synchronised data *output* (light-painting).
The other is time-synchronised data ***retrieval*** --- from an accelerometer. **MAXL already
solves the hard part: getting sensor data and machine motion onto a common timebase, across
heterogeneous hardware.**

And then it stops. The trajectory object has "one author and multiple readers." Sensors are
*readers*. Nothing in the architecture allows a sensor reading to **contradict** the trajectory,
because the architecture defines **no predicate over the data it so carefully synchronises**.

> **This is the gap, stated with precision: MAXL delivers synchronisation without assertion.**
> The clock is shared. The sensors are plumbed. Nobody wrote the `assert`.

## What is conspicuously absent

We searched the CBA corpus --- the news archive from 2022 to 2026, and the full papers index ---
for work on tool changers, tool-seating verification, liquid handling, self-driving laboratories,
or reproducibility in fabrication.

**There is none.** Not one paper. The closest adjacents are the CBA/NIST Open Metrology workshop
and a 2019 melt-electrowriting paper that performs *post-hoc* machine-learning metrology on a
fabricated scaffold --- verification of the *product*, offline, not of the *machine*, in-process.

That absence is not a hole in our search. **It is the finding.** The lineage that produced
Jubilee's motion architecture possesses the sensing substrate (MAXL), the self-characterisation
technique (the instrumented extruder), the assertion abstraction (Tandem), and an explicit,
published account of why measurement matters (Computational Metrology). It has assembled every
component of the answer. **It has simply never pointed them at a laboratory machine.**

This proposal is the next paper in a sequence that already has four entries --- and we can say so
with citations rather than assertion.
