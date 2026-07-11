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

## Software

| Quantity | Value | Grade |
|---|---|---|
| `science-jubilee` tests | **1** (93-byte import check), against 59 open issues | **[M]** |
| PyLabRobot tests | **1,779** | **[M]** |
| Jubilee hardware, last commit to `main` | **January 2023**; 62 open issues | **[M]** |
| `tandem` repo | CC BY 4.0; last push December 2024; 4 stars | **[M]** |
| Shared labware schema | both projects consume **Opentrons schema v2** | **[M]** |

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

## Citation verification

Every reference here has been checked against its primary source. Four were initially drafted
from recall and then verified; **one of those four was wrong, and is recorded rather than
quietly corrected** — a document arguing for verification should be willing to show its own.

| Reference | Outcome |
|---|---|
| Jones et al., *RepRap*, Robotica **29**(1):177--191, 2011 | **Confirmed exactly** — author list, volume, pages, DOI |
| Peek, *Making Machines that Make*, MIT, 2016 | **Confirmed**; refined to PhD, Program in Media Arts and Sciences, Sept 2016, supervised by **Neil Gershenfeld** (Center for Bits and Atoms) |
| Barthels et al., *FINDUS*, SLAS Technology **25**(2):190--199, 2020 | **Confirmed** — and it *publishes accuracy*: under \$400, relative pipetting error **below 0.3\%** |
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
