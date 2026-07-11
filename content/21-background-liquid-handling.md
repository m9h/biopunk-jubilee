---
category: research
section: background
weight: 21
status: draft
title: "The Other Lineage: Liquid-Handling Robotics"
slide_summary: |
  ### What the incumbents built that a printer never needed

  **Hamilton CO-RE (c. 2000):** an O-ring expands to grip the tip, so retention is
  *decoupled from Z-axis force*. That single decision is what makes in-line pressure
  sensing --- and therefore liquid-level detection --- physically possible.

  **The capability cascade it unlocks:**

  - **cLLD / pLLD:** find the meniscus in $<$ 10 ms, to $\approx$ 0.5 mm.
  - Follow it down → submerge only 1--2 mm → **no carryover on the tip's outside.**
  - **TADM:** the pressure trace *is* an audit log --- clots, bubbles, short volumes.

  Opentrons democratised the *gantry*. It did not democratise **the sensing.**
---

Jubilee is arriving in a field with its own hundred-year lineage, its own standards, and its
own hard-won understanding of how liquid handling goes wrong. The gap between a syringe bolted
to a printer and a Hamilton STAR is not the syringe. It is everything the incumbents learned
about *not trusting the machine*.

## The physics the incumbents designed around

The dominant technology is **air-displacement** pipetting, in which a piston moves an air
column that in turn moves the liquid. ISO 8655-2:2022 formally distinguishes this (Type A) from
positive displacement (Type D), and --- tellingly --- provides an entire informative annex
enumerating error sources *unique to the air cushion*, with no counterpart for positive
displacement [@iso8655-2].

The air cushion is a compressible spring in series with the sample, and it misbehaves in ways
that have no analogue in extrusion:

- **Hydrostatic loading.** A 40 mm water column in a 1000 µL tip exerts roughly 390 Pa, about
  0.39\% of atmosphere. Against ~1 mL of dead air that is on the order of 4 µL of phantom
  volume --- roughly half the entire ISO tolerance for a P1000.
- **Volatile solvents** evaporate into the cushion and *push liquid out*; this is why Hamilton
  sells a product called Anti-Droplet Control.
- **Viscous liquids** fail *kinetically*: the piston stops long before the liquid has finished
  flowing. The remedy is a settling delay, not a calibration factor.
- **Thermal drift.** A 3 K gradient across 1 mL of dead air is roughly 10 µL of error, which is
  why ISO 8655-6 constrains temperature drift to $\le 0.5$ K during verification.

The engineering response was not better positioning. It was **sensing**.

## Hamilton CO-RE: the decision that made sensing possible

Hamilton's *Compression-induced O-Ring Expansion* coupling is the single most instructive piece
of design in this literature, and it is worth stating why. In Hamilton's own account, a motor
compresses an O-ring which expands to grip a tip having "a cylindrical connector instead of the
widely used conical one," allowing the seal to be made "without applying high forces," which in
turn "enables real-time pressure measurement" and "an aerosol-free tip release"
[@pochert2000lld].

Read that causally. A **press-fit** tip requires the gantry to *push*, which (i) demands a
stiff, heavy Z axis, (ii) reacts an equal force back through the tip rack and deck, (iii) makes
tip attachment a mechanical shock that corrupts any in-line pressure sensor, and (iv) puffs
aerosol on ejection. **A press-fit head cannot easily also be a pressure-metrology head.**
Hamilton engineered the force *out of the problem* so that liquid-level detection could exist
at all.

This matters directly for Jubilee. DuckBot attaches OT-2 tips by press-fit, driven by the Z
axis, detected by a flexure and a limit switch [@subbaraman2024duckbot]. That is a clever
*detection* scheme, but it does not reduce the force --- it only reports when enough has been
applied. It forecloses the pressure-sensing path unless the sensor is isolated from the
seating transient.

## Liquid-level detection, and why its absence is DuckBot's root cause

Two independent LLD technologies are standard in serious instruments, both documented by
Hamilton [@pochert2000lld]:

**Capacitive (cLLD)** applies a high-frequency signal to a conductive tip and detects the
capacitance change on contact, firing about 5 ms after onset. It works on water and DMSO, fails
on non-conductive organics, and --- crucially --- its signal "also depend[s] on the size of the
reagent container because stray capacitance also contributes." It is a thresholded,
labware-dependent sensor.

**Pressure-based (pLLD)** descends while continuously aspirating air and detects the pressure
drop the instant the orifice seals against liquid, in under 10 ms. Its decisive advantage is
that "the $\Delta p$ signal is **independent of the vessel size** and thus has potential for LLD
even within 1536-well microplates." As a bonus, the post-aspiration plateau pressure is offset
by exactly the hydrostatic head of the column just drawn --- *the sensor that finds the surface
also measures the draw.*

Running both at a 100 mm/s descent, the 5 ms response difference corresponds to about **0.5 mm
--- "the size of a bubble on the surface."** The disagreement between two independent sensors is
therefore used as a *foam and bubble detector*.

Everything good follows from knowing where the meniscus is. You submerge the tip 1--2 mm and
follow the surface down: you do not crash into the well bottom, you do not aspirate air at the
end of a draw, and --- the under-appreciated one --- **you do not drag a film of sample up the
outside of the tip into the next well.** A liquid handler without LLD has a carryover problem
that no filter tip can fix, because the contamination is on the *outside* of the tip: the wrong
side of the filter.

DuckBot's reported failure --- transfer "very sensitive to the exact height (z-position) of the
water column" --- is not a motion defect. **It is an LLD-shaped hole in the system.**

## Liquid classes: the twenty parameters a syringe does not have

Commercial systems bind each reagent's physics to machine motion through a *liquid class*: flow
rates and accelerations for aspiration and dispense, settling delays, blow-out volume and rate,
leading and trailing air gaps, submersion depth and liquid-following, tip withdrawal speed,
pre-wetting, reverse-pipetting excess, touch-off, and a volume calibration curve fitted per
liquid *and* per tip type.

That these parameters are not merely numerous but **mutually contradictory** is the point.
Opentrons' own application data gives 99\% glycerol a tip-withdrawal speed of 2 mm/s and a 10 s
settling delay, while 62\% alcohol --- a volatile --- requires a **20 mm/s** withdrawal, ten
times faster, plus mandatory touch-off. *There is no "just go slower" rule, and there is no safe
default.* Recent work shows the envelope can be pushed hard with optimisation --- multi-objective
Bayesian optimisation of aspiration and dispense rates reached within 5\% transfer error at
1275 cP, far outside the rated 100 cP range [@nambiar2024viscous] --- but only by *measuring*,
iteratively and gravimetrically.

`science-jubilee` exposes none of this. Its volume model is `dv = vol * self.mm_to_ul`: one
linear scalar and a feedrate.

## Verification: gravimetry, photometry, and the standard that actually applies

Two definitions must be kept apart. *Systematic error* (trueness, bias) is
$e_s = \bar{V} - V_s$; *random error* (precision) is the sample standard deviation, reported as
%CV. They are orthogonal, and a naive syringe pump is characteristically **precise and
inaccurate** --- which is the *good* failure mode, because a calibration curve fixes it. The
dangerous failure is liquid-dependent bias, which changes with every reagent.

**Gravimetry** is the reference method, and it is demanding: 1 µg balance resolution below
20 µL, $20 \pm 3^\circ$C, drift $\le 0.5$ K, and a buoyancy-corrected Z-factor to convert mass
to volume. Below ~50 µL, evaporation dominates.

**Photometry** --- Artel's dual-dye, dual-wavelength ratiometric absorbance, in which the *ratio*
cancels path-length and well-geometry variation [@bradshaw2005mvs] --- is now a *reference*
method in its own right under the 2022 revision. For an automated handler it is strictly the
better tool, for a reason worth internalising: **gravimetry gives one number per weighing
vessel, and therefore cannot find one bad channel in a 96-channel head without 96 separate
weighings.** Ratiometric photometry measures every channel simultaneously, in the destination
plate, in the real protocol geometry.

Finally, a point of standards hygiene that the open-hardware literature gets wrong almost
universally: for an *automated* liquid-handling system, the governing standard is
**ISO 23783** [@iso23783], which cancels and replaces IWA 15:2015 --- **not** ISO 8655, which
addresses piston-operated apparatus.

## Opentrons, and what it did and did not democratise

**Opentrons** is the formative open project in this space, and its trajectory is the sharpest
available commentary on our thesis.

The **OT-2** runs **open-loop steppers homed against limit switches, with no encoders**. It has
11 SLAS deck slots, two independent pipette mounts, and --- notably --- **no published
positional-accuracy or repeatability specification at all.** Its pipettes, by contrast, are
characterised in detail: a GEN2 P300 is specified at $\pm 4\%$ / 2.5\% CV at 20 µL, improving
to $\pm 0.6\%$ / 0.3\% CV at 300 µL. Note what that asymmetry says. **The gantry's accuracy was
never the binding constraint. The pipette's was.**

The **Flex** (2023) then added **encoders** --- and Opentrons' own explanation of why is the
single best validation of this proposal's framing. It is not for precision. It is so that "if
the robot expects a certain number of motor rotations but only completes fewer due to a crash,
it will **detect a discrepancy, throw an error**, and inform the user to recalibrate," and to
reduce how often re-homing is required mid-protocol. **The most relevant commercial reference in
our exact application adopted feedback for error detection, not for accuracy.**

There is one further, uncomfortable observation. Opentrons is an open-*software* company:
its Protocol API is Apache-2.0 and developed daily. Its **hardware is not open** --- the OT-2
hardware repository carries no licence and has been untouched since October 2020, and the Flex
makes no open-hardware claim at all. Jubilee (CC BY 4.0, OSHWA-certified, with source CAD) and
the Pipettin' Bot (CERN-OHL-S) are the only genuinely reproducible platforms in the field. This
is Jubilee's real and defensible advantage, and it is worth defending with evidence.

## The frugal tier is a legitimate strategy

It is worth resisting the inference that the answer is simply to buy a commercial instrument.
An OT-2 is \$15,950 today; a realistically equipped Flex clears \$60,000. A Jubilee motion
platform is \$1,800. Below roughly 5 µL, *nothing* in the Opentrons range beats $\pm 8\%$
systematic error --- which is precisely the regime in which an open platform gives up almost
nothing.

A substantial literature now defends this "frugal twin" tier explicitly [@lo2024frugal], and
the existence proofs are real: FINDUS demonstrated a printable liquid-handling workstation for
under a few hundred dollars [@barthels2020findus]; Chi.Bio built a parallel bioreactor platform
with in-situ optics for a few hundred per unit [@steel2020chibio]; and --- most directly relevant
--- the **Digital Pipette** is an \$80 3D-printed linear-servo syringe tool **validated to
within ISO 8655-2 permissible error** [@yoshikawa2023digitalpipette]. **A DIY tool can be
metrologically serious. It simply has to be measured.**

Against this, note where the celebrated self-driving laboratories actually sit: Ada uses an N9
SCARA arm and a UR5e [@macleod2020ada]; the A-Lab uses three robotic arms and eight furnaces
[@szymanski2023alab]. Gantries are the frugal tier, and that is a legitimate research strategy
--- but it is one that must be defended with characterisation data, which is exactly what the
Jubilee line currently lacks.

## Software: PyLabRobot and the bridge that is already half-built

**PyLabRobot** [@wierenga2023pylabrobot] is the field's hardware-agnostic Python framework,
splitting a stateful `LiquidHandler` frontend from thin backends, with support for Hamilton
STAR, Tecan EVO, the OT-2, and some forty accessory machines. Its decisive features are the
ones `science-jubilee` lacks: **tip and volume trackers that reject an invalid aspirate before
any command is emitted**, an I/O capture-and-replay layer for hardware-free regression testing,
a browser visualiser, and **1,779 test functions**. `science-jubilee` has one --- a 93-byte
import check [@sciencejubilee].

The two communities are mutually invisible: searching either repository for the other returns
nothing. Yet **they already share the Opentrons labware JSON schema**, which is itself little
more than a machine-readable encoding of ANSI/SLAS 1--4 [@slas2004]. The bridge is half-built.
We return to this in the discussion, because the correct relationship between the two is a
genuine design question and not an obvious import.
