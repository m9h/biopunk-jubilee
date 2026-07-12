---
category: research
section: methodology
weight: 30
status: draft
title: "Architecture: An Assertion Layer with Teeth"
slide_summary: |
  ```
  +-- Protocol (Jupyter / Tandem notebook) -------------+
  |   with machine.asserting():                         |
  |       machine.pickup_tool(p300)  # asserts seating  |
  |       p300.aspirate(200, well)   # asserts meniscus |
  +-----------------------------------------------------+
  +-- Assertion layer   (NEW) --------------------------+
  |   Precondition -> Action -> Postcond -> Provenance  |
  +-----------------------------------------------------+
  +-- Transport   (REWRITTEN) --------------------------+
  |   Duet object model over websocket. M400 default.   |
  |   Firmware faults -> catchable Python exceptions.   |
  +-----------------------------------------------------+
  ```

  **The Sensor Rule:** *every assertion must be backed by a sensor, not a variable.*
---

We propose three layers. The top is a protocol expressed as a Tandem notebook; the middle is a
new assertion layer; the bottom is a rewritten transport. One rule governs the whole design.

> **The Sensor Rule.** *Every assertion must be discharged by a physical measurement, not by a
> program variable.* An assertion that interrogates Python's own belief about the world is not
> an assertion; it is a tautology.

This rule is what separates the proposal from a refactor, and it is why the work has a hardware
component. `science-jubilee` today contains a decorator, `@requires_active_tool`, which appears
to guard against operating a parked tool. It does not: it checks a **Python-side boolean**. Any
divergence between the object and the firmware --- a manual `T` command, a crash, a reconnect ---
passes the guard silently. It is a latent correctness bug, and it is an instructive one, because
it shows how naturally a verification layer decays into theatre when nothing is measuring
anything.

## The layer already exists, once, by hand

We must be scrupulous here, because the strongest objection to this proposal is that part of it
has already been built --- in the very codebase we are proposing to change.

**DuckBot verifies its transfers, and retries them.** Its authors state that each transfer tool
"can be used as a part of a closed loop wherein transfer success is confirmed using the camera
tool, and automatically retried on failures," and describe the mechanism: after the first round,
the camera images each destination plate, identifies the wells that are still empty, and
initiates a second attempt for those wells, "repeated indefinitely" at a cost in duration
[@subbaraman2024duckbot].

That is a *precondition, an action, a sensed postcondition, and a bounded recovery.* It satisfies
the Sensor Rule --- the postcondition is discharged by a camera, not by a variable --- and it is
precisely the pattern this proposal advocates. We did not invent it and we do not claim it.

**But notice what it took, and what it left uncovered.** The loop is hand-rolled in protocol
code, for one organism, against one camera, checking one predicate: *is there a frond in this
well?* It is not reusable, not composable, and not available to any other tool on the machine.
DuckBot's authors had to write a bespoke verification loop **because the platform offers no
assertion primitive** --- and having written it, they still shipped a machine whose tool changes,
tip seating, labware registration, and dispensed volumes go entirely unchecked, because no camera
is pointed at any of them.

This sharpens the thesis rather than weakening it, and it is worth stating the corrected version
plainly. It is **not** that Jubilee's machines cannot assert. It is that they have **no assertion
primitive, so every team reinvents one** --- narrowly, in application code, for whichever single
failure hurt them most --- while the general failure classes stay silent for want of a sensor and a
place to hang the check. DuckBot proves the demand. It does not discharge it.

## Layer 1: Transport

The existing transport is the foundation of the problem, and it must be replaced before any
assertion can be trusted.

**What exists.** `Machine.gcode()` POSTs to `/machine/code` and, on failure, falls back to
polling `rr_gcode` → `rr_model?key=seqs` → `rr_reply`. It blocks until a command is
*acknowledged*. Motion completion is opt-in per call via `M400`, and the private
`_move_xyzev()` defaults it to `False`. Firmware errors are not propagated; retry backoff is a
bare `except` and a `sleep`.

**What we propose.**

- **Subscribe to the Duet object model over websocket.** The import is already present in
  `Machine.py`, commented out. This gives continuous, structured machine state --- axis
  positions, tool state, endstop and probe status, driver faults --- instead of string-parsing
  `M114` replies.
- **Make motion completion the default, not an option.** `M400` is emitted for every motion
  primitive unless a caller explicitly opts into pipelining. The Hawai'i group's workaround of
  "long pauses after each dip" [@vierra2025dipcoating] should become unnecessary and, more
  importantly, *unnecessary to know about*.
- **Propagate firmware faults as typed Python exceptions.** RepRapFirmware already raises
  events for driver errors, stall detection, and heater faults, and it will execute
  `driver-error.g` and `driver-warning.g` macros. We route these into the object model, and
  from there into exceptions such as `ToolNotSeated`, `MotionFault`, `ProbeNoContact`.
- **Preserve graceful degradation.** RRF's tolerance of a missing CAN board is a feature for a
  machine whose tools are removable, and the transport must not paper over it: a tool that is
  physically absent should raise a clear, catchable error, not a shutdown.

## Layer 2: Assertions

We adopt Tandem's model directly: a protocol step is wrapped in a precondition, an action, and a
postcondition, and each is recorded.

```python
with machine.asserting() as ctx:
    ctx.require(machine.tool_dock_identity(2) == "p300")   # dock RFID / ID resistor
    machine.pickup_tool(p300)
    ctx.assert_(machine.tool_seated(),                     # coupler continuity
                on_fail=Retry(machine.reseat_tool, times=2))
    ctx.assert_(machine.active_tool_is(p300))              # firmware object model, not a bool
```

Three properties of this design are load-bearing.

**Assertions are recoverable, not fatal.** This is the single most important design decision in
the proposal, and it is where we depart from the existing hardware. `science-jubilee` already
documents a *tool crash detection* modification --- dowel pins and solder lugs across the
coupler, so that balls lifting out of their kinematic seats break a circuit. **The sensor
exists.** But it fires an **E-stop**, and the documentation concedes that recovery is "a major
hassle." For a ten-day assay, a machine halted at hour 40 is a lost experiment. **A detected
mis-seat must raise a catchable exception that re-seats and retries, not a dead machine.**

**Assertions are cheap enough to leave on.** A coupler continuity check is a digital read. A
tool-identity check is an analogue read. A completion check is already in the object model.
These are microseconds against a tool change measured in seconds; there is no reason to run a
protocol with them disabled.

**Assertions write provenance.** Every discharged assertion --- with its measured value, its
tolerance, and its timestamp --- is appended to a run record alongside the data. This is what
converts "the machine ran overnight" into "the machine ran overnight, and here is the evidence
that every tool change seated and every dispense matched its pressure envelope." It is also,
not incidentally, what a reviewer will want.

## Layer 3: The protocol notebook

The top layer is where Tandem's existing contributions arrive intact: the notebook *is* the
experiment record, the assertions *are* the quality checkpoints, and the AR projection
capability --- which we do not need to build --- offers a natural home for the manual
interventions that DuckBot already requires (a human moves plates to and from the growth chamber
daily).

We note one deliberate non-goal. We are **not** proposing a domain-specific language, a
scheduler, or a laboratory operating system. Several exist and most are abandoned. The notebook
is already the interface the Machine Agency's users have adopted, and the proposal's value comes
from making that interface *honest*, not from replacing it.
