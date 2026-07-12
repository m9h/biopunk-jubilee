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
  - The same lab already built the fix: **Tandem** (CHI 2024) --- wired to a milling
    machine, never to the science machines.

  **Proposal.** Port Tandem's assertions into `science-jubilee`, and add the three
  sensors that make them non-vacuous.
---

The Jubilee multi-tool motion platform has become the de facto substrate for frugal laboratory
automation, carrying DuckBot, FungiBot, the Sonication Station, and a growing body of
self-driving-laboratory work. Yet the platform's hardware repository has been frozen since
January 2023, its tool-change repeatability has never been measured or published, and its
Python control layer is a synchronous G-code-over-HTTP shim that cannot confirm a motion
completed, cannot detect that a tool failed to seat, and cannot find a liquid surface.

We argue that these are not three unrelated defects but a single one: **the machine has no
primitive for asserting that the physical world matches the program's model of it.** Every
resulting failure is therefore silent. A mis-seated tool does not raise an error; it produces
a plate of quietly corrupted data. This is the precise failure mode that renders unattended,
multi-day biological assays --- the platform's central use case --- untrustworthy.

**That the demand is real is demonstrated by the platform's own flagship.** DuckBot already
verifies its transfers with a camera and retries the wells that failed --- a hand-rolled
precondition-action-postcondition loop, written in protocol code because no reusable one exists.
It is built for one organism and one predicate, and it leaves tool seating, tip attachment,
labware registration, and dispensed volume entirely unchecked. Every team reinvents the
assertion, narrowly, and the general failures stay silent.

**The diagnosis is not ours, and we do not claim it.** It belongs to the community we address.
*The End of GCode* --- Jake Read's 2026 MIT dissertation, supervised by Gershenfeld with **Nadya
Peek on the committee** --- opens by observing that "GCode only permits one-way data transfer," and
answers with a *feedback-native* control architecture (OSAP, PIPES, MAXL) for "machines that can
think about what they are doing," which "learn their own constraints" and "monitor errors."
Alongside it, **Tandem** (CHI 2024, also Peek) contributes the missing abstraction: *explicit
assertions that flag mismatches between physical and digital state.* The two lines have already
met formally --- Read, Peek and Gershenfeld co-authored MAXL in 2023.

**And none of it has been pointed at a laboratory machine.** `science-jubilee` still drives
DuckBot and FungiBot through a synchronous, one-way G-code-over-HTTP shim --- precisely the
artefact a 512-page MIT dissertation, examined by their own principal investigator, is titled
against. The cure was developed, defended, and never administered to the patient in the next
room.

Our delta is correspondingly specific. Read's machines fit continuous **models of their own
physics** --- nozzle pressure, cutting force, dynamics. A laboratory machine must additionally
assert its own **semantics**: discrete, protocol-level facts about an experiment that has no
equation of motion. *A fitted model of extrusion pressure cannot tell you that you picked up the
P20 instead of the P300*, that a tool's kinematic balls failed to seat, that a plate is a
millimetre out of its nest, or where a meniscus is.

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
