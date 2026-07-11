---
category: research
section: discussion
weight: 50
status: draft
title: "Roads Not Taken, and Why"
slide_summary: |
  ### Four upgrades the field will recommend. All four are wrong here.

  - **Eddy-current probe.** Physically cannot see plastic labware. Two of three
    don't even run on RRF.
  - **Closed-loop servos on X/Y.** On CoreXY the encoder sees only the *motor shaft* ---
    upstream of belts, coupling, frame. Duet confirms linear scales are impossible on CoreXY.
  - **Migrate to Klipper.** Hard-fails the whole machine when any MCU is missing. For a
    toolchanger, disqualifying.
  - **Pogo pins through the coupling.** Nobody does this --- not Prusa XL, not E3D. Blocked
    by a Stratasys patent to 2033. The one builder who shipped it *reverted*.

  **What survives: belt tension, a handshake, a switch, a pressure sensor.**
---

A proposal is strengthened by the alternatives it rejects, and in this case the rejected
alternatives are precisely the ones a well-read engineer would reach for first. Each is
excluded on evidence, not taste.

## Why not a better gantry?

The measured E3D data locate roughly 80\% of the system error budget *downstream* of the
kinematic coupling [@e3d_toolchanger_review]: the coupling repeats to $<5\,\mu\mathrm{m}$ on a
bench and the machine delivers $\approx 26\,\mu\mathrm{m}$ at the tool tip. Effort spent
redesigning the coupling optimises the wrong term.

More to the point, laboratory loads are small. A pipette, a camera, a loop, and a syringe exert
newtons, not the tens of newtons an extruder reacts at 15,000 mm/s². Jubilee's frame is soft
*for a fast printer* and very likely adequate *as a positioner*. WP0 tests this rather than
assuming it.

The one mechanical intervention we do endorse is free: **match the CoreXY belt tensions and slow
the dock approach.** A tension mismatch racks the gantry as a function of the acceleration
vector, and a *dynamic* rack --- unlike a static skew --- cannot be absorbed by per-tool offsets,
because the tool-pickup move has a different acceleration profile from the moves used to
calibrate those offsets. This is a credible mechanical mechanism for the reported mis-seating,
and eliminating it costs an afternoon.

## Why not closed-loop steppers?

Because they would measure the wrong thing, and their own designers say so. On the Duet forum, a
veteran servo engineer put it plainly --- closed loop "is not going to get you better accuracy
than open-loop if you are not crashing" --- and the developer who *wrote* Duet's closed-loop
firmware replied: "You're definitely right there."

The CoreXY case is worse still. Duet's own staff confirm that **linear scales cannot be used on
CoreXY** (neither motor maps to an axis, so a per-motor controller cannot consume a 45° scale).
The encoder therefore observes only the **motor shaft** --- upstream of the pulley, the belt, the
carriage, the rail, the frame, and the coupling. Every error source that actually limits the
machine is downstream of where the encoder can see. A 1000 CPR encoder even *degrades*
resolution relative to the 256× microstep interpolation already in use.

And yet the conclusion is not "never." It is **"for detection, not precision"** --- which is
exactly the trade Opentrons made when the Flex added encoders to *"detect a discrepancy, throw
an error, and inform the user to recalibrate."* If we fit feedback at all, we fit it in
**assisted open-loop** mode (`M569 D5`), on the **three Z motors** (which are 1:1 with their
axes and free of kinematic mixing), for the sole purpose of raising RRF's `driver-error.g`
events. That is a sensing intervention, and it belongs in this proposal's logic. Chasing
accuracy with it does not.

## Why not an eddy-current probe?

Because it cannot see the deck. Beacon, Cartographer, and BTT Eddy detect a target by inducing
eddy currents in a **conductor**; a Delrin deck, a well plate, a tip rack, and a Petri dish are
invisible to them. The sensor reads the aluminium *through* the labware, or fails to trigger and
drives the tool into it. Two of the three do not run on RepRapFirmware at all, and every vendor's
sub-micron claim is short-term *noise at a fixed height and temperature*, not accuracy --- the
only published thermal-drift figure for this sensor class is on the order of
$12\,\mu\mathrm{m}/^\circ$C.

Contact probing is the correct technology, and Jubilee already owns it: `jubilee3d/xyz_probe`
plus RRF's `G38.2`.

## Why not migrate to Klipper?

Klipper has the livelier toolchanger ecosystem and a genuinely better resonance-measurement
workflow. It is still the wrong choice here, for one decisive reason: **Klipper invokes a
machine-wide shutdown when any configured MCU is absent or drops** (`mcu.py`:
`invoke_shutdown("Lost communication with MCU ...")`). For a platform whose defining feature is
that tools are attached, detached, and serviced, this is disqualifying. RepRapFirmware degrades
gracefully.

Migration would also cost native multi-tool support (`M563`, `tfree`/`tpre`/`tpost`), the object
model that `science-jubilee` is built against, standalone real-time operation with no Linux
scheduler in the control path, Modbus, and meta-G-code --- to purchase a tuning UX that can be
replicated by capturing RRF's `M956` data and post-processing it with Klipper's own
`calibrate_shaper.py`.

## Why not route utilities through the tool coupling?

This is Jubilee's oldest open issue (#12, January 2020), and it looks like the platform's most
obvious unfinished business. It is not.

**Nobody hot-plugs tool connections.** Not E3D, not StealthChanger, not TapChanger, and **not
Prusa XL** --- a shipping five-tool commercial product with a full engineering team, which routes
five *permanent* cable bundles and red-screens with "board not found" if a tool is unplugged.
The one community builder who shipped pogo-pin tool contacts withdrew them: "more problematic
than expected." Prusa's own field failures are instructive --- their most common electrical fault
is fretting at a **fixed, never-mated** connector, patched twice with additional strain relief. A
make/break contact would be strictly worse.

Nor is this a firmware gap awaiting a patch. It is an *electrical-layer* constraint: as Duet's
designer notes, "the CAN bus does not support man-in-the-middle devices, as the ACK bit has to
be set in real time by the receiving nodes." And the powered-dock architecture is claimed by a
live Stratasys patent until 2033 [@stratasys2015toolchanger].

**Keep the umbilicals.** The available win is different and better: **CAN toolboards** reduce
each umbilical from 11--17 conductors to four. The E3D community made this migration years ago;
Jubilee never did.

## The relationship to PyLabRobot

The obvious question is whether `science-jubilee` should simply be replaced by PyLabRobot
[@wierenga2023pylabrobot], which has 1,779 tests to its one, plus tip and volume trackers that
reject an invalid aspirate *before any command is emitted*, an I/O capture-and-replay layer, and
backends for some forty machines.

We think the framing is wrong, because **the two are not competitors at the same layer.**
`science-jubilee` is a *driver* (Duet HTTP, G-code, toolchange macros). PyLabRobot is a
*protocol and state framework* that is missing exactly that driver. They already share the
Opentrons labware schema, so definitions transfer unchanged.

The natural synthesis is a `JubileeBackend(LiquidHandlerBackend)` --- roughly eight real methods,
with the 96-channel ones legitimately raising `NotImplementedError` --- emitting through
`science-jubilee`'s `Machine` as transport. That inherits the trackers, the tests, and the
accessory fleet while keeping the hard-won Duet and toolchange knowledge underneath.

**But there is a real design obstacle, and we name it rather than hand-wave it.** PyLabRobot
models a **fixed head with `num_channels`**. It has no concept of tool changing anywhere. A
Jubilee's entire reason to exist is swapping a pipette for a camera for a sonicator. If a
protocol must change tools *within* a liquid-handling run, one is not writing a backend --- one is
extending PyLabRobot's core, which is a negotiation with upstream and not a patch. We therefore
scope the backend as **future work contingent on WP1--WP2**, and note that the assertion layer
proposed here is a prerequisite for it either way: a backend built on a transport that cannot
confirm a motion completed would simply relocate the problem.

## Sterility: the limitation we cannot engineer away

DuckBot's authors concede that the system "does not ensure a sterile experimental environment,"
and propose running it inside a laminar-flow hood. The materials literature reaches the same
conclusion independently, less optimistically, and --- importantly --- *by measurement rather than
by assertion*. Testing re-sterilisation of printed parts, Luchini and colleagues report that
**"significant bacterial growth was observed in all PLA and TPU based samples following
re-sterilization, regardless of the methods used"** ($p < 0.05$) --- that is, isopropanol, bleach,
*and* hydrogen peroxide all failed, with colonies measurable within 24 hours. Their diagnosis is
geometric: the "crypts and small spaces created by the infill" simply cannot be reached by a
cleaning solution [@luchini2021sterilization]. PLA additionally cannot be autoclaved, and loses
substantial mechanical performance after isopropanol exposure [@vierra2025dipcoating].

Note the force of this. It is not that a printed part is *hard* to sterilise. It is that a
printed part which has been contaminated **cannot be returned to a sterile state by any of the
three methods a laboratory would actually reach for.** For a machine whose wetted parts are
printed, that is a structural fact, not a procedural one.

Compounding this, a converted FDM printer *sheds*: exposed belts, greased leadscrews directly
above the deck, and open steppers, all inside what is supposed to be a unidirectional downflow
that would carry the debris onto the plates. And UV-C offers no rescue --- it is strictly
line-of-sight, and a liquid-handling deck is all shadow (beneath tip racks, inside tips, behind
rails), with dose requirements spanning three orders of magnitude across organisms.

The honest position is that **sterility is out of scope for this proposal**, and that the
Printess architecture --- 3 kg, 23 × 23 × 40 cm, carried one-handed into a biosafety cabinet,
with a single-use sterile fluid path [@weiss2025printess] --- is a genuinely better answer for
work that requires it. We note it as the strongest argument for a *second*, smaller machine
rather than a modification of this one.

## Threats to validity

**"Read's thesis already does this."** This is the strongest objection and it deserves the first
answer. *The End of GCode* [@read2026endofgcode] genuinely anticipates the control-architecture
half of this proposal, and we say so in Section 23 rather than burying it. But its feedback loop
closes over **machine physics** --- pressure, force, dynamics --- via continuous models fitted to the
machine's own behaviour. A laboratory protocol additionally requires **semantic** assertions:
discrete, protocol-level facts with no equation of motion behind them. No identification of
nozzle dynamics reveals that a tool's kinematic balls failed to seat, that the P20 is mounted
where the protocol expects a P300, that a plate is a millimetre out of its nest, or where a
meniscus sits. Those require *sensors that do not exist in either lineage*, and a predicate
layer that Tandem supplies and MAXL does not. The honest framing of this proposal is **execution,
not invention** --- and the fact that the diagnosis is already defended at MIT, with Jubilee's own
author on the committee, is an argument *for* the work rather than against it.

**The seating transient may defeat in-line pressure sensing.** Press-fit tip attachment drives
force through the air column the sensor watches. Our mitigation is to gate and tare the sensor
across attachment, and WP4 validates this in week one precisely because a negative result
changes the tool's design.

**WP0 may find the machine is already good enough**, in which case a substantial part of the
motivation for hardware work evaporates. We regard this as a *success* condition and will report
it as one.

**Assertion overhead may prove unacceptable in a long protocol.** We believe not --- the checks
are digital and analogue reads against tool changes measured in seconds --- but throughput must be
measured, not assumed.

**We may be wrong about pressure LLD being unbuilt.** We searched and found nothing. If it
exists, the correct response is to adopt it, and we would rather be corrected early than
duplicate work.
