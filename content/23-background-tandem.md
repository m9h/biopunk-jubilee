---
category: research
section: background
weight: 23
status: draft
title: "The Answer, Already Written Twice --- and the Delta That Remains"
slide_summary: |
  ### The diagnosis is not ours. It is theirs, and it is defended.

  **"The End of GCode"** --- Read, PhD, MIT, May 2026, 512 pp.
  Committee: Gershenfeld, **Nadya Peek**, Seppala (NIST).

  > *"GCode only permits **one-way data transfer**"* → a **feedback-native** architecture
  > for *"machines that can think about what they are doing."*

  ### So what is left for us?

  Read fits models of **machine physics**. We must assert **experimental semantics** ---
  *did the tool seat? which tip is on? where is the meniscus?*

  **A model of extrusion pressure cannot tell you that you picked up the P20.**

  And `science-jubilee` still drives the lab machines over **one-way G-code**.
---

The strongest argument for this proposal is also, at first sight, the strongest argument
against it: **the diagnosis is not ours.** It belongs to the very group we are addressing, it has
been defended as a doctoral thesis, and Nadya Peek --- author of both Jubilee and Tandem --- sat on
the committee. We therefore state the prior work at its full strength before claiming any delta,
because a proposal that pretended otherwise would deserve to fail.

## Thread one: Tandem, and the assertion

Tandem [@oleary2024tandem] encodes a fabrication workflow as a computational-notebook program
another person can execute to physically recreate the work. It exchanges data with CAD and CAM,
projects augmented-reality interfaces for manual steps, drives machines directly, and ---
decisively --- supports **explicit assertions in code to flag potential mismatches between physical
and digital state.**

Its demonstration is two-sided CNC milling: machine one face, flip the workpiece, then *prove*
the datum survived. That is the canonical physical--digital divergence, and it is structurally
identical to a tool change: an object is decoupled from its reference frame, re-coupled, and
thereafter trusted.

## Thread two: Read, and the end of one-way control

Running in parallel at MIT's Center for Bits and Atoms is a body of work whose thesis --- now
literally a thesis --- is that **machines should observe themselves rather than assume their
state.**

*The End of GCode: Intelligent Modular Machines with Model Based Control* [@read2026endofgcode]
is a 512-page dissertation, submitted May 2026, supervised by Neil Gershenfeld, with **Nadya Peek
(UW) and Jonathan Seppala (NIST) on the committee.** Its opening diagnosis is one this proposal
would otherwise have had to argue for:

> "Innovation in this domain is hampered by the pervasive use of GCode: an antiquated interface
> between machine users and machine controllers. **GCode only permits one-way data transfer** and
> prevents us from smoothly crossing the boundary between high- and low-level planning and
> control tasks."

Its remedy is a **feedback-native control architecture** for "machines that can think about what
they are doing," delivered in three layers: **OSAP**, a network providing low-latency messaging,
clock synchronisation, and device discovery across heterogeneous devices; **PIPES**, combining
dataflow for real-time operation with scripting for machine tasking; and **MAXL**, motion control
as dataflow modules. On top of these it builds machines that "**learn their own constraints** by
fitting models of their dynamics," replaces feed-forward parameter tuning with feedback from
fitted physics, and --- explicitly --- "**monitor[s] errors**," so that "machine controllers are no
longer black boxes."

Supporting this are two published results we take as existence proofs. *Online Measurement for
Parameter Discovery in FFF* [@read2024online] instruments an extruder with a load cell, filament
encoder, Hall-effect diameter sensor and thermocouple, fits $P = f(T, Q)$ *in situ*, and
**derives** its process parameters rather than being told them --- succeeding "even in materials
that we had never printed before." And *Computational Metrology for Materials*
[@warren2025metrology], written with NIST, states the field's deficiency outright: R&D "is
continuously hindered by the lack of data," and the remedy is to "merge the metrological and
control aspects of the entire system."

## The threads have already met --- twice, formally

In 2023, **Read, Peek, and Gershenfeld** jointly published **MAXL** [@read2023maxl]: CBA and the
UW Machine Agency on one paper, building time-synchronised trajectories across heterogeneous
actuators *and sensors*, with one demonstration being time-synchronised data **retrieval** from
an accelerometer. And in 2026, **Peek sat on the committee** that approved *The End of GCode*.

**There is no intellectual disagreement to resolve here.** The people who built Jubilee and the
people who built the feedback-native control architecture are the same community, they have
co-authored, and they have examined each other's work. What has not happened is that any of it
has been pointed at a laboratory machine.

## The delta: what remains genuinely undone

We must be precise, because the prior work is strong and the naive version of our contribution is
already taken.

| | Read's thesis / CBA | This proposal |
|---|---|---|
| **What is observed** | **Machine physics** --- nozzle pressure, cutting force, motion constraints, material dynamics | **Experimental state** --- tool seated? which tip? where is the meniscus? did the labware move? |
| **Form of knowledge** | Continuous **models fitted** to dynamics | Discrete **predicates asserted** over the world |
| **Failure it catches** | Process error, mis-tuned parameters, model divergence | Silent corruption of a *sample* |
| **Domain** | Fabrication: FFF printing, milling | Wet biology: pipetting, imaging, incubation |
| **Machine** | Modified state-of-the-art printer; a purpose-built mill | Jubilee, DuckBot, FungiBot |

The distinction is not cosmetic. **A fitted model of extrusion pressure cannot tell you that you
picked up the P20 instead of the P300.** No amount of dynamics identification reveals that a
tool's kinematic balls failed to seat, that a plate is 1 mm out of its nest, or where a meniscus
is. Read's machines learn their own *physics*; a laboratory machine must also assert its own
*semantics* --- discrete, protocol-level facts about an experiment that has no equation of motion.

Three further gaps are simply unoccupied by either thread:

1. **The lab sensors do not exist.** No pressure-based liquid-level detection, no seating
   assertion, no tool identity --- in Read's work, in Tandem, or in `science-jubilee`.
2. **The toolchanger has never been characterised.** Not by CBA, not by the Machine Agency, not
   by anyone (Section 40).
3. **And, most bluntly: the lab machines are still on one-way G-code.** `science-jubilee` drives
   DuckBot through a synchronous G-code-over-HTTP shim --- *the precise artefact a 512-page MIT
   dissertation, examined by their own principal investigator, is titled against.* FungiBot is
   further from feedback still: it is not driven through `science-jubilee` at all, but by a
   pre-sliced G-code file uploaded to the Duet from a laptop. The cure was developed, defended,
   and never administered to the patient in the next room.

## A worked example of the cure not administered: FungiBot

The abstract form of this argument is easy to wave away, so here is a concrete instance from
inside the same laboratory.

**FungiBot** [@luo2025fungibot] extrudes *Mycofluid* --- a mycelium-inoculated paste made from
spent coffee grounds. That is about as unruly a feedstock as extrusion has: a living,
particulate, biologically active medium whose rheology varies with grind, moisture, inoculation
density, and how long it has been sitting. Every one of those varies batch to batch. The machine
is told its extrusion parameters in advance, and extrudes.

**This is not an inference; it is the published method.** FungiBot's models are designed in
Rhinoceros and *sliced in PrusaSlicer*, and the print is started by "uploading the G-Code file
[...] on a laptop computer connected to the Jubilee mainboard via ethernet" [@luo2025fungibot].
The parameters are therefore fixed at slice time, before the paste is ever loaded. There is no
runtime channel from the machine back to the program --- not a weak one, none --- and so nothing
the extruder encounters can change what it does next. Note that this is *not* the
`science-jubilee` shim we criticise elsewhere: it is a step further from feedback than the shim,
and it is the control path the flagship biopaste machine actually ships with.

Now read Read's contribution again [@read2024online]. An instrumented extruder fits a pressure
model *in situ* and **derives** its own flow parameters --- and the paper's own headline claim is
that it succeeds *"even in materials that we had never printed before."*

**That method was built for exactly FungiBot's problem, by the same research community, and
FungiBot does not use it.** A living paste with batch-variable rheology is the single strongest
case in the entire corpus for online parameter discovery, and it is being printed feed-forward.
This is not a criticism of FungiBot, which is a fine piece of work with a different research
question. It is the clearest available illustration of the thesis of this section: **the cure
exists, it was developed next door, and nobody carried it across the hall.**

## What is conspicuously absent from the whole corpus

We swept the CBA record --- the news archive 2022--2026, the full papers index, and the theses list
--- for tool changers, tool-seating verification, liquid handling, self-driving laboratories, or
reproducibility in fabrication. **There is none.** The nearest adjacents are the CBA/NIST Open
Metrology workshop and a 2019 melt-electrowriting paper doing *post-hoc* machine-learning
metrology on a finished scaffold --- verification of the **product**, offline, not of the
**machine**, in-process.

That absence is not a hole in our search. **It is the finding.** This community has assembled
every component of the answer --- the network and clock (OSAP), the dataflow substrate (PIPES,
MAXL), the self-characterisation technique (the instrumented extruder), the assertion abstraction
(Tandem), and a published argument for why measurement matters. **It has simply never pointed
them at a laboratory machine, and the machines it did point at biology cannot tell you whether
they worked.**

This proposal is therefore not a new idea. It is the execution of a conclusion this community has
already reached, in the one domain where the cost of not reaching it is a corrupted experiment.
