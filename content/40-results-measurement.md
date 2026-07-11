---
category: research
section: results
weight: 40
status: draft
title: "The Measurements the Field Is Missing"
slide_summary: |
  ### Published positional repeatability, in the entire field

  | Machine | Repeatability |
  |---|---|
  | Jubilee | **none** |
  | Prusa XL | **none** (the "±0.015 mm" is an SEO fabrication) |
  | StealthChanger / TapChanger | **none** |
  | Opentrons OT-2 **and** Flex | **none** |
  | **E3D ToolChanger** | **$\sigma$ = 0.026 mm** --- *the only one* |

  **Not a gap in our knowledge. A gap in the literature --- and cheap to close.**
---

This proposal makes a claim that ought to be embarrassing to the field, so we state it precisely
and invite correction. **There is no published positional-repeatability figure for the Jubilee,
the Prusa XL, StealthChanger, TapChanger, LumenPnP, the Opentrons OT-2, or the Opentrons Flex.**
The sole independently measured toolchanger dataset in open-source 3D printing is the E3D
ToolChanger review cited throughout this document [@e3d_toolchanger_review]. No ISO 230-2 test
has been run on any open CoreXY machine that we can find.

A cautionary note for anyone tempted to fill the gap by citation: the "±0.015 mm" docking
repeatability figure that circulates for the Prusa XL traces to a single search-optimised page
of apparently synthetic origin. Prusa publish no such specification. **It should not be
repeated.**

Closing this gap is cheap, and it is the first result we propose to deliver.

## Protocol 1 --- Tool-change repeatability

*The number every reviewer will ask for, which does not exist.*

**Cheap version (zero cost, one afternoon).** Run TAMV --- Jubilee's existing upward-camera
tool-alignment utility --- twice, one week apart, and difference the resulting tool offsets. This
yields a genuine drift-and-repeatability figure for a real machine in a real laboratory.

**Rigorous version.** Mount a dial indicator (or a calibrated upward camera with a fiducial
target) at a fixed point in the workspace. For each tool, execute 100 park--pickup cycles,
measuring $\Delta x$, $\Delta y$, and $\Delta z$ at the tool tip after each. Report mean, standard
deviation, and $3\sigma$ per axis, per tool. Repeat at two acceleration settings for the dock
approach, to test the dynamic-racking hypothesis of Section 41.

**Interpretation.** Benchmark against $\sigma \approx 26\,\mu\mathrm{m}$ (E3D, measured) and
Jubilee's own alignment guidance of 0.02 mm. **A result inside $\approx 20\,\mu\mathrm{m}$ means
a well-built Jubilee is at commercial-toolchanger parity, and the mechanical-upgrade discourse
surrounding these machines is largely misdirected.** That is a publishable finding, and it is a
*more* useful one than a poor result would be.

## Protocol 2 --- Liquid-handling accuracy and precision

*Currently asserted by reference to another vendor's datasheet.*

Governing standard: **ISO 23783** for automated systems [@iso23783] --- not ISO 8655, which
addresses hand-held piston apparatus. Report **systematic error** ($e_s = \bar{V} - V_s$) and
**random error** (%CV) *separately*; they are orthogonal, and conflating them is the field's most
common reporting error.

- **Gravimetric**, per the reference method: 1 µg balance resolution below 20 µL,
  $20 \pm 3^\circ$C, drift $\le 0.5$ K, buoyancy-corrected Z-factor, evaporation trap below
  ~50 µL.
- **Photometric**, ratiometric dual-dye [@bradshaw2005mvs]: the better instrument here, because
  it measures every well *in the destination plate, in the real protocol geometry*, and can
  therefore find a single bad channel — which gravimetry cannot do without one weighing per
  channel.
- **Volume points** at 10\%, 50\%, and 100\% of nominal, per the 2022 revision's proportional
  MPE.
- **Three liquid classes**: water, glycerol (viscous), ethanol (volatile). This is the minimum
  set that exposes the anti-correlated parameter problem — the viscous liquid wants a slow tip
  withdrawal, the volatile one wants a withdrawal an order of magnitude faster.

**Benchmark:** the Digital Pipette, an \$80 printed tool, met ISO 8655-2 permissible error
[@yoshikawa2023digitalpipette]. That is the bar. It is not a high one, and clearing it would put
Jubilee's liquid handling on an evidentiary footing it has never had.

## Protocol 3 --- Assertion efficacy

*Does the verification layer actually catch anything?*

This is the experiment that tests the proposal's central claim, and it is a fault-injection
study.

Deliberately induce each of the following, $n = 20$ each, with assertions **disabled** and then
**enabled**, and measure the detection rate and the recovery rate:

| Injected fault | How |
|---|---|
| Tool mis-seat | foul a parking post; shim a wedge plate |
| Stale tool state | issue a manual `T` command mid-protocol |
| Motion desync | flood the command queue without `M400` |
| Labware displacement | shift a plate by 1.0 mm in its slot |
| Aspiration failure | introduce an air bubble; partially occlude a tip |
| Wrong tool | swap two tools between docks |

**The headline result of this proposal will be a single table**: for each fault, the fraction
detected and the fraction recovered, with and without the assertion layer. The prediction is
that the "disabled" column reads close to zero across the board --- which is, precisely, the
current state of the art.

## Protocol 4 --- End-to-end reproduction

Re-run the DuckBot growth assay [@subbaraman2024duckbot] --- four genotypes, four salinities,
four replicates, ten days --- with the full stack, and report:

- every assertion discharged, with its measured value (the provenance record);
- dispensed-volume verification for the media transfers;
- **transfer success rate by species, with an $n$ and a confidence interval** --- which the
  original paper, by its own account, did not measure; and
- a significance test, which the original explicitly did not perform.

The goal is not to criticise the original work, which was clear about being an extensibility
contribution rather than a metrological one. The goal is to demonstrate that the same machine,
with a verification layer, produces a result that can carry a statistical claim.
