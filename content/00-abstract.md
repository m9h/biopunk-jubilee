---
category: research
section: abstract
weight: 0
status: draft
title: "Abstract"
slide_summary: |
  **Thesis.** Science Jubilee's machines are not imprecise. They are *blind*.

  - No completion handshake. No seating check. No liquid-level sensing.
  - Every failure is **silent** --- and silence corrupts data rather than halting it.
  - The same lab already built the fix: **Tandem** (CHI 2024). It was wired to a
    milling machine, never to the science machines.

  **Proposal.** Port Tandem's assertions into `science-jubilee` --- and add the three
  sensors that make them non-vacuous.
---

The Jubilee multi-tool motion platform has become the de facto substrate for frugal laboratory
automation, carrying DuckBot, FungiBot, the Sonication Station, and a growing body of
self-driving-laboratory work. Yet the platform's hardware repository has been frozen since
January 2023, its tool-change repeatability has never been measured or published, and its
Python control layer is a synchronous G-code-over-HTTP shim that cannot confirm a motion
completed, cannot detect that a tool failed to seat, and cannot find a liquid surface.

We argue that these are not three unrelated defects but a single one: **the machine has no
mechanism for asserting that the physical world matches the program's model of it.** Every
resulting failure is therefore silent. A mis-seated tool does not raise an error; it produces
a plate of quietly corrupted data. This is the precise failure mode that renders unattended,
multi-day biological assays --- the platform's central use case --- untrustworthy.

The remedy already exists inside the same research group. Tandem, presented at CHI 2024,
is a computational-notebook environment whose central contribution is *explicit assertions
that flag mismatches between physical and digital state*, demonstrated on two-sided CNC
milling. It has never been connected to `science-jubilee`.

We propose that integration, in three parts. **First**, a transport rewrite: replace the
blocking HTTP shim with a Duet object-model subscription that delivers a genuine
motion-completion handshake and propagates firmware faults as catchable Python exceptions.
**Second**, an assertion layer: Tandem-style pre- and post-conditions on tool state, deck
occupancy, labware registration, and dispensed volume, each backed by a real sensor rather
than by a Python-side boolean. **Third**, the three sensors that make those assertions
non-vacuous --- a tool-seating switch promoted from the existing crash-detection modification,
a pressure-based liquid-level detector in the pipette air path, and dock-side tool identity.

We further propose the measurement the field conspicuously lacks. No Jubilee, Prusa XL,
StealthChanger, or Opentrons machine has a published positional-repeatability figure; the
sole independently measured toolchanger dataset in open-source 3D printing gives
$\sigma \approx 26\,\mu\mathrm{m}$ for the E3D ToolChanger, against a bench claim of
$<5\,\mu\mathrm{m}$ for its coupling. That fivefold gap locates the error budget in the
machine, not the coupling --- and it means a well-built Jubilee may already be at commercial
parity. Nobody has checked. We specify the protocol to check it.

The contribution is deliberately unglamorous. We propose no new gantry, no servos, and no
better tool changer. We propose to give an existing machine the ability to know what it just
did.
