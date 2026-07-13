---
category: research
section: conclusion
weight: 60
status: draft
title: "Conclusion"
slide_summary: |
  ### The proposal in four lines

  1. **Measure the machine first.** It is free, and it may end half this project.
  2. **Give the transport a completion handshake** and real exceptions.
  3. **Port Tandem's assertions** --- and back every one with a *sensor*, not a variable.
  4. **Build the pressure LLD nobody has built.** It closes DuckBot's *sensing* failure.

  ### The ask

  We are not proposing a new machine. We are proposing that an existing one
  be able to **know what it just did** --- and that the lab connect two artefacts
  it has already published.

  *The gantry was never the problem.*
---

The Jubilee programme succeeded at what it set out to do. It put a working tool changer, a real
community, and a genuinely open licence --- CC BY 4.0, OSHWA-certified, with source CAD, which is
more than Opentrons or Printess can claim --- into the hands of researchers who could not
otherwise afford a \$25,000 gantry. DuckBot, FungiBot, and the Sonication Station are the proof.
Nothing in this proposal should be read as an argument against the platform, and its
shortcomings as an instrument are shortcomings only against a standard it never claimed to meet:
it is an HCI artefact, published at an HCI venue, optimising for extensibility.

But the machines built on it have acquired requirements the platform never promised. And when
every one of their limitations is chased to its root, they converge on a single failure class.
The machine cannot detect a mis-seated tool. It cannot confirm that a motion completed. It
cannot find a liquid surface. It cannot feel a crash without dying. It has no primitive with
which to assert that the physical world matches the program's model of it --- and so, where a team
has needed such an assertion badly enough, it has hand-built one for a single organism and left
every other failure class unwatched. **The machine is not imprecise. It is blind.**

That reframing is the proposal's principal intellectual contribution, because it disqualifies
almost every upgrade the surrounding literature would recommend. A stiffer gantry addresses an
error term that the only measured data in the field locates elsewhere. Closed-loop servos on a
CoreXY can observe only the motor shaft, upstream of everything that matters. Eddy-current
probes are physically blind to plastic labware. Klipper would hard-fail the entire machine
whenever a tool is off for maintenance. What survives the cull is cheap and unglamorous: belt
tension, a completion handshake, a seating switch that raises a catchable exception instead of
an emergency stop, a pressure sensor in the pipette's air path, a calibration curve per reagent,
and an assertion layer.

**And the answer has already been built by the people who would receive this proposal.** We want
to be scrupulous about this, because the naive version of our contribution is already taken.

*The End of GCode* [@read2026endofgcode] --- 512 pages, MIT, May 2026, supervised by Gershenfeld,
**with Nadya Peek on the committee** --- diagnoses the disease in its first paragraph ("GCode only
permits one-way data transfer") and prescribes the cure: a feedback-native architecture for
machines that "learn their own constraints" and "monitor errors," so that "machine controllers
are no longer black boxes." Tandem [@oleary2024tandem] contributes the assertion abstraction.
The instrumented extruder [@read2024online] proves self-measurement works with cheap sensors.
*Computational Metrology for Materials* [@warren2025metrology], with NIST, argues in print that
this is the field's missing layer. And MAXL [@read2023maxl] --- Read, **Peek**, and Gershenfeld ---
put motion and sensor data on a common clock.

**There is no intellectual disagreement left to have. There is only an application that was never
made.** The lab machines are still on one-way G-code. The cure was developed, defended, and never
administered to the patient in the next room.

What genuinely remains is narrower than it first appears, and it is worth naming exactly. Read's
machines fit continuous **models of their own physics**. A laboratory machine must also assert its
own **semantics** --- discrete facts about an experiment that has no equation of motion. *No
identification of nozzle dynamics will ever tell you that you picked up the P20 instead of the
P300.* That gap, the three sensors that close it, and the tool-change measurement nobody has
taken: that is the whole of what we propose.

It is worth being precise about whose gap this is, because the uncharitable reading is also the
wrong one. This lineage is not indifferent to measurement: CBA's machine-building class devotes
a full week to metrology [@mas865]. But what it teaches is metrology *as sensing* --- accuracy and
precision, oversampling, Nyquist, "physical phenomena that can be turned into electrical
signals." It teaches you to build a machine that **perceives the world**. It does not teach
error budgets, kinematic-coupling repeatability, or ISO 230; it never asks the machine to
perceive **itself**. That is the whole distance this proposal travels --- and it means the sensing
work we propose is *native* to the tradition, not imported into it. We are turning an instrument
the field already owns onto a target it has not yet considered.

We propose to begin with the measurement, because it costs nothing and because it may make half
of this proposal unnecessary. Pick up a tool one hundred times and write down where it lands. No
one has done this --- not for the Jubilee, not for the Prusa XL, not for the Opentrons OT-2 or
Flex, not for any open toolchanger but one. In a field that currently runs on three genuine
datasets and a great deal of received opinion, that is not merely a gap.

It is the cheapest paper on the list.
