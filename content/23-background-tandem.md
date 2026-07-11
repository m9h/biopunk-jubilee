---
category: research
section: background
weight: 23
status: draft
title: "Tandem: The Answer Already Written"
slide_summary: |
  ### Tandem (CHI 2024) --- Tran O'Leary, Ramesh, Zhang, Peek

  A notebook environment for fabrication whose central contribution is:

  > **"explicit assertions in code to flag potential mismatches between physical
  > and digital states."**

  Demonstrated on **two-sided CNC milling** --- the hardest datum-survival problem in
  subtractive manufacturing: you flip the workpiece and must *prove* the datum held.

  ### And DuckBot's future-work section reads:

  > unattended operation "would need **additional error detection and failsafes**."

  Same lab. Same building. **Never connected.**
---

## What Tandem is

Tandem [@oleary2024tandem] addresses a problem in experimental digital fabrication: workflows
are increasingly elaborate, and consequently increasingly irreproducible. Its response is to
encode an entire end-to-end fabrication process as a computational-notebook program that another
person can execute to physically recreate the work.

Four capabilities distinguish it from a plain Jupyter notebook driving a machine:

1. It **exchanges data with CAD and CAM** software, so design intent stays live in the program.
2. It **projects augmented-reality interfaces onto the machine** to guide the manual
   interventions that real workflows always contain.
3. It **directly controls fabrication machines.**
4. Decisively for our purposes, it supports **explicit assertions in code to flag potential
   mismatches between physical and digital state.**

Its demonstration is two-sided CNC milling: you machine one face, flip the workpiece, and must
then establish that the datum survived the flip. This is the canonical instance of
physical--digital divergence, and it is *structurally identical* to a tool change. In both cases
a physical object is decoupled from its reference frame, re-coupled, and thereafter trusted.

## Why it is the right abstraction for the science machines

The three failures in our introduction are not three problems. Under Tandem's framing they are
one, and they are all **assertable**:

| Failure | The assertion it demands |
|---|---|
| Tool fails to seat (#43, #119) | *Assert:* the tool's three balls are in their kinematic seats. |
| Python tool-state boolean goes stale (#116) | *Assert:* the firmware's active tool equals the program's belief. |
| Motion has not completed when the next command issues | *Assert:* the motion queue is drained and position matches target. |
| Labware is not where the deck file says | *Assert:* a touch probe finds the plate lip within tolerance. |
| The dispensed volume is not the requested volume | *Assert:* the pressure trace matches the liquid class envelope. |
| The wrong tool is on the carriage | *Assert:* the dock's tool identity matches the protocol's requirement. |

Every row is a physical--digital mismatch. Every row is currently unchecked.

## The unclaimed opportunity

Tandem is a separate repository --- `machineagency/tandem`, CC BY 4.0, Python and TypeScript,
**four stars, last pushed December 2024** [@tandem_repo]. It has never been connected to
`science-jubilee`, which drives the group's biology and chemistry machines through an
assertion-free HTTP shim.

We want to state the resulting situation plainly, because it is the strongest argument in this
proposal and it costs nothing to act on. **The Machine Agency published, at CHI 2024, a general
mechanism for asserting that a machine's physical state matches its program's model of it. In
the same period, the same group published a laboratory robot whose stated limitation is that
unattended operation "would need additional error detection and failsafes." The mechanism was
demonstrated on a milling machine. It was never pointed at the laboratory.**

The intellectual work is done. What remains is engineering, and --- as the next sections argue
--- a modest amount of sensing hardware to make the assertions bite.
