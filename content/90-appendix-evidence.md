---
category: research
section: appendix
weight: 90
status: draft
title: "Evidence Grades for Every Load-Bearing Number"
---

Every quantitative claim in this proposal is graded. **[M]** = measured and published with a
method. **[C]** = claimed by a vendor or author without a stated method. **[N]** = no data
exists; the absence is itself the finding. **[D]** = derived by us from primary sources.

## Motion and toolchanging

| Quantity | Value | Grade |
|---|---|---|
| E3D ToolChanger, system repeatability at the tool tip | mean $\sigma$ **0.026 mm** (X 0.022, Y 0.025) | **[M]** |
| E3D coupling, bench claim | $<5\,\mu$m | **[C]** |
| Jubilee tool-change repeatability | — | **[N]** |
| Jubilee tool-change cycle time | — | **[N]** |
| Jubilee tool alignment guidance | 0.02 mm manual; 0.05 mm by microscope | rule of thumb |
| Prusa XL docking repeatability | "±0.015 mm" — **traces to a single synthetic SEO page; do not cite** | **[C, discredited]** |
| Opentrons OT-2 / Flex positional repeatability | — | **[N]** |
| Jubilee shipped acceleration | 1500 mm/s²; jerk 8.3 mm/s | **[M]** (config.g) |
| Jubilee XY motor current | 3005 mA $\approx$ 85\% of rated, with a "do not exceed 90\% without heatsinking" comment | **[M]** (config.g) |
| Commodity C-grade MGN rail, running parallelism over 400–500 mm | **19 µm** | **[M]** (HIWIN catalogue) |
| HIWIN mounting flatness requirement, coplanar rails | 0.025 mm / 200 mm | **[M]** |

## Printess (the counter-architecture)

| Quantity | Value | Grade |
|---|---|---|
| Repeatability | **±5 µm** per axis (optical encoder, 10 mm sawtooth × 10) | **[M]** |
| Backlash, **uncompensated** | **±75 µm X, ±150 µm Y, ±50 µm Z** | **[M]** |
| Periodic error | ~50 µm, tracking the 1 mm leadscrew pitch | **[M]** |
| Crosshatch pitch fidelity | 513 ± 11.4 µm vs 500 commanded | **[M]** |
| Mass / footprint / cost | 3 kg / 23×23×40 cm / ~\$350 current (\$250 as published) | **[M]** |
| Hardware licence | **none — no LICENSE file; default copyright applies** | **[M]** |
| "10 µm accuracy" in press coverage | **misreading of ±5 µm *repeatability*; accuracy is an order of magnitude worse** | **[D]** |

## DuckBot

| Quantity | Value | Grade |
|---|---|---|
| Dispense accuracy / %CV | — (asserted by reference to Opentrons' datasheet, in the docs, not the paper) | **[N]** |
| Transfer success rate by species | qualitative only; no $n$, no percentages | **[N]** |
| Significance testing | *"no significance tests were performed"* | **[N]** |
| Imaging throughput | ~1 min per well; 64 wells × 10 days = 448 images | **[M]** |
| Volume model | `dv = vol * self.mm_to_ul` — one linear scalar | **[M]** (source) |
| Syringe transfer sensitivities, as reported | **two**: z-height of the water column **and** xy-centring over the frond | **[M]** (paper) |
| *Spirodela polyrhiza* transfer failure, attributed cause | **morphology** — "heavy, multi-frond ramets and entangled root systems" — *not* z-height | **[M]** (paper) |
| Camera-based confirm-and-retry loop | **exists** — postcondition discharged by camera, empty wells re-attempted, "repeated indefinitely" | **[M]** (paper, Fig. 7) |

**A claim we withdrew during drafting.** Earlier versions of this proposal asserted that
liquid-level detection was "DuckBot's root cause" and its "dominant failure mode." Checked
against the primary source, that is **not supported**. DuckBot reports *two* sensitivities, only
one of which is a liquid-level problem, and attributes its catastrophic species result to neither
of them. The narrow claim — pressure LLD closes the z-position sensitivity — is what the evidence
supports, and it is the only one now made. See Sections 10 and 21.

## The community-biolab premise

| Claim | Status | Grade |
|---|---|---|
| Equipment **cost** is the binding constraint on community biolabs | **contradicted** — "the cost of commercial lab equipment is not a major constraint"; equipment is donated or second-hand, and *overabundant* | **[M]** [@delange2022biolabs] |
| Community biolabs need throughput automation | **not supported** — 7 of 11 labs own a liquid handler; usage is minimal; "so many one-offs that it hasn't rewarded making something that's highly repeatable" | **[M]** [@delange2022biolabs] |
| The binding constraints are **time and skill** | supported — users "almost always hobbyists"; biowork is time-consuming *and* time-sensitive | **[M]** [@delange2022biolabs] |
| Named barriers to using the robots labs already own | difficulty of **setup, use, and maintenance**; lack of bench space | **[M]** [@delange2022biolabs] |
| Community biolabs are this proposal's primary beneficiary | **we do not claim this.** The proposal is scoped to unattended, multi-day, protocol-driven work on Jubilee-derived instruments, wherever it occurs | **[D]** |

This is a survey of eleven labs and sixteen participants and it is the best evidence available;
it is also the *only* such evidence, and it should not be over-read. But it runs against the
frugality motivation that open lab-automation work reflexively adopts, and we have rewritten our
own motivation to match it rather than around it (Section 10, and Threats to Validity in
Section 50).

## Software

| Quantity | Value | Grade |
|---|---|---|
| `science-jubilee` tests | **1** (93-byte import check), against 59 open issues | **[M]** |
| PyLabRobot tests | **1,779** | **[M]** |
| Jubilee hardware, last commit to `main` | **January 2023**; 62 open issues | **[M]** |
| `tandem` repo | CC BY 4.0; last push December 2024; 4 stars | **[M]** |
| Shared labware schema | both projects consume **Opentrons schema v2** | **[M]** |

## Firmware and controller (verified against RRF source, not prose docs)

| Claim | Finding | Grade |
|---|---|---|
| Object-model **subscription** in standalone RRF | **does not exist.** DWC polls `GET rr_model` on a 250 ms timer (`PollConnector.ts`); the websocket path (`RestConnector.ts`) requires DuetWebServer, i.e. **SBC mode** | **[M]** (Duet3D `Connectors` source) |
| Push subscription mechanism | DSF over the DCS socket, `"mode": "Subscribe"` with patch deltas and per-update acknowledge; wrapped by `dsf-python` | **[M]** |
| `M950 J` general-purpose input | **digital only** — `GpInputPort::GetState()` calls `port.ReadDigital()`; `sensors.gpIn[].value` is 0 or 1 | **[M]** (`src/GPIO/GpInPort.cpp`) |
| Analogue-capable pins, Duet 3 Mini 5+ | `io3.in`, `io6.in`, `temp0–2` only; all other `ioN.in` are digital | **[M]** (`Pins_Duet3Mini.h`) |
| Mini 5+ driver count vs Jubilee motor count | **5 drivers** vs **6 motors** (X, Y, 3×Z, U tool-lock) — U must go on an expansion board | **[M]** |
| CAN limitation | main-board endstops cannot control expansion-board motors | **[M]** (Duet CAN limitations doc) |
| Mini 5+ can power an attached Pi | **no** — unlike the 6HC, the Pi needs its own supply | **[M]** (SBC setup doc) |
| Raspberry Pi 5 support under DSF | **unconfirmed**; Pi 5 moved GPIO/SPI behind the RP1 southbridge. Pi 4 is the documented path | **[N]** |

**A second claim we corrected during drafting.** Earlier versions specified the transport as a
"websocket subscription to the Duet object model," on the strength of a commented-out import in
`Machine.py`. Checked against RepRapFirmware and Duet's own connector library, **standalone RRF
has no such subscription** --- it has HTTP polling. The subscription is real, but it lives in
DuetSoftwareFramework and requires an attached Raspberry Pi. WP1 therefore acquires a hardware
prerequisite it did not previously declare, and the bill of materials acquires a Pi (Appendix 91).
Had we not checked, the single largest software claim in the proposal would have failed in its
first week.

## Liquid-handling physics

| Quantity | Value | Grade |
|---|---|---|
| pLLD detection latency | $<$ 10 ms; **independent of vessel size** | **[M]** |
| cLLD vs pLLD disagreement | $\approx$ 0.5 mm at 100 mm/s descent — used as a bubble detector | **[M]** |
| Opentrons P300 GEN2 | ±4\% / 2.5\% CV at 20 µL; ±0.6\% / 0.3\% CV at 300 µL | **[M]** |
| Opentrons Flex, 1 µL | ±8.0\% / 7.0\% CV — **nothing in the range beats ±8\% below ~5 µL** | **[M]** |
| Air-displacement viscosity rating | $<$ 100 cP; MOBO reaches 5\% error at 1275 cP | **[M]** |
| Hydrostatic phantom volume, 40 mm column in a 1000 µL tip | $\approx$ 390 Pa $\approx$ 0.39\% atm $\approx$ **4 µL** — about half the ISO tolerance for a P1000 | **[D]** |
| Glycerol 99\% vs 62\% alcohol, tip withdrawal | **2 mm/s vs 20 mm/s** — the parameters are *anti-correlated* | **[M]** |
| Digital Pipette | \$80, printed, **validated to ISO 8655-2 permissible error** | **[M]** |

## A negative result, obtained by systematic search

We swept the MIT Center for Bits and Atoms corpus --- the News & Notes archive for 2022 through
2026 (thirteen issues), the complete papers index, and the theses list --- for published work on:

| Searched for | Found |
|---|---|
| Tool changers, modular end effectors | **none** |
| Tool-seating verification | **none** |
| Liquid handling | **none** |
| Self-driving laboratories / automated science | **none** |
| Reproducibility or verification in fabrication | **none** |
| Machine positioning characterisation (ISO 230, error budgets, ballbar) | **none** |

The nearest adjacents are the CBA/NIST **Open Metrology** workshop (August 2022), which frames
metrology *access* as an open-source problem, and a 2019 melt-electrowriting paper performing
*post-hoc* machine-learning metrology on a fabricated scaffold --- verification of the **product**,
offline, rather than of the **machine**, in-process. The only tool-changing artefact in the entire
corpus is a *purchased* desktop mill listed under new equipment.

**This absence is not a gap in the search; it is the finding.** The lineage that produced
Jubilee's motion architecture possesses the sensing substrate [@read2023maxl], the
self-characterisation technique [@read2024online], the assertion abstraction [@oleary2024tandem],
and a published account of why measurement matters [@warren2025metrology]. Every component of
the answer exists. None has been pointed at a laboratory machine.

## Citation verification

Every reference here has been checked against its primary source. Four were initially drafted
from recall and then verified; **one of those four was wrong, and is recorded rather than
quietly corrected** — a document arguing for verification should be willing to show its own.

| Reference | Outcome |
|---|---|
| Jones et al., *RepRap*, Robotica **29**(1):177--191, 2011 | **Confirmed exactly** — author list, volume, pages, DOI |
| Peek, *Making Machines that Make*, MIT, 2016 | **Confirmed**; refined to PhD, Program in Media Arts and Sciences, Sept 2016, supervised by **Neil Gershenfeld** (Center for Bits and Atoms) |
| Barthels et al., *FINDUS*, SLAS Technology **25**(2):190--199, 2020 | **Confirmed** — and it *publishes accuracy*: under \$400, relative pipetting error **below 0.3\%** |
| Read, *The End of GCode* --- drafted as a "PhD thesis proposal, Dec 2024" | **Superseded.** The thesis was **filed**: PhD, MIT, **May 2026**, 512 pp, supervised by Gershenfeld, committee **Peek** and Seppala (NIST). Verified from the CBA-hosted PDF. Upgraded from non-archival proposal to archival dissertation, and its argument is now the central prior work rather than a supporting remark. |
| Read, Peek & Gershenfeld, *MAXL*, SCF '23 | **Confirmed** from the CBA-hosted PDF, including the author list and affiliations (MIT CBA $\times$ UW Machine Agency) |
| Moyer et al., *Cantilevered DeltaXY*, CHI 2026 | **Partially verified.** Title, authors, venue, DOI and Best Paper status confirmed via the ACM record, NSF PAR, and the author's project page. **The full text could not be obtained** (ACM DL blocks automated access; NSF PAR returned no manuscript). We therefore make **no claim about its contents** beyond its abstract and project page, and in particular do *not* assert that it omits repeatability data. |
| *(as drafted)* "Kucewicz et al., Considerations for Sterilization of 3D Printed Devices, 3D Print. Med. **7**:19" | **WRONG — withdrawn.** PMC8193021 is in fact **Luchini et al.**, *"Sterilization and Sanitizing of 3D-Printed PPE Using Polypropylene and a Single Wall Design,"* 3D Print. Med. **7**:16 (2021), DOI 10.1186/s41205-021-00106-8. The author name and article number were misremembered. |

The *substance* of the withdrawn citation survives, and is better supported than first claimed:
Luchini et al. **measured** significant bacterial growth in **all** PLA samples after
re-sterilisation, *regardless of method* — isopropanol, bleach, and hydrogen peroxide all failed,
$p < 0.05$ — attributing it to infill crypts that cleaning solutions cannot reach. The corrected
claim is stronger than the one it replaced.

## Claims we could not substantiate, and therefore do not make

- Any ISO 230-2 test of any open CoreXY machine.
- Hamilton's frequently-quoted "carryover $<1\times10^{-5}$" — we could not source it. Their
  *published* carryover argument is architectural (aerosol-free tip release via CO-RE).
- Pipettin' Bot's "~1\% relative error" — stated without a volume, a %CV, or a method. Not
  credible across three decades of volume; not repeated here.
- A µm/°C thermal-drift figure for the Duet Scanning Z Probe specifically. The ~12 µm/°C figure
  is derived from a BTT Eddy user's temperature-calibration table and should be treated as
  order-of-magnitude.
