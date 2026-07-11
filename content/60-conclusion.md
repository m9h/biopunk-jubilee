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
  4. **Build the pressure LLD nobody has built.** It is DuckBot's own root cause.

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
cannot find a liquid surface. It cannot feel a crash without dying. It cannot assert that the
physical world matches the program's model of it. **The machine is not imprecise. It is blind.**

That reframing is the proposal's principal intellectual contribution, because it disqualifies
almost every upgrade the surrounding literature would recommend. A stiffer gantry addresses an
error term that the only measured data in the field locates elsewhere. Closed-loop servos on a
CoreXY can observe only the motor shaft, upstream of everything that matters. Eddy-current
probes are physically blind to plastic labware. Klipper would hard-fail the entire machine
whenever a tool is off for maintenance. What survives the cull is cheap and unglamorous: belt
tension, a completion handshake, a seating switch that raises a catchable exception instead of
an emergency stop, a pressure sensor in the pipette's air path, a calibration curve per reagent,
and an assertion layer.

**And the assertion layer already exists.** Tandem was published at CHI 2024 by the same group,
in the same period, with the same people; its central contribution is explicit assertions that
flag mismatches between physical and digital state; and it was pointed at a milling machine
while the laboratory robot down the hall listed "additional error detection and failsafes" as
its principal unmet need. The most valuable work available here is not to invent anything. **It
is to connect two artefacts the group has already built, and then --- finally --- to measure the
result.**

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
