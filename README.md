# single-phase-inverter

Simulink/Simscape models of a grid-connected single-phase inverter, 225 kW, 690 V application
voltage, in two power-stage versions: a two-level full bridge and a three-level T-type bridge.
The control is the single-phase scheme used across the other repositories: virtual dq frame
built with a first-harmonic tracker (FHT), SOGI or phase-shift filter, resonant PI current
control, and a system-identification mode that injects a test frequency instead of running
the normal regulation.

## Prerequisites

- MATLAB with Simulink, Simscape and Simscape Electrical.
- The companion [library](https://github.com/pwr-control/library) repository on the MATLAB
  path **with subfolders** (setup functions `init_environment`, `timing_setup`,
  `single_phase_inverter_hwdata`, `device_*_setup`; Simscape device models; C-Caller code).
  The `init_model.m` of each folder adds it by itself (`private/library_setup.m`): clone
  the two repositories side by side (or set the environment variable `PWR_CONTROL_LIBRARY` to
  the library folder); the library is cloned next to this repository when it is missing.

## How to use

1. Run `init_model.m` in `two_levels/` or `three_levels/`: it sets timing, hardware data,
   control gains and the device set, then opens the model. Everything is in the struct `param`,
   and the local parameterization of each model is in the `private/` folder next to its init
   (functions with the name of a library one take precedence over it, the rest comes from the
   library; the Simscape models always come from the library): see the README of the folder.
2. Simulate the `.slx`.
3. Post-process with the scripts in the same folder. Results (`.mat`) and figures (EPS) are
   ignored by git.

Main switches in `init_model.m` (fields of `param`, e.g.
`param.spinv.impl.use_single_phase_inverter_based_FHT`, `param.spinv.frequency_set`):

- `use_single_phase_inverter_based_FHT / _SOGI / _PHSH` (and `_ccaller` variants) — which
  quadrature-signal generator feeds the virtual dq transformation, and whether it runs as a
  Simulink block or as C-Caller code;
- `system_identification_enable` and `use_system_identification_based_*` — identification
  mode at `frequency_set = 300 Hz`;
- `frequency_set` — operating frequency of the AC side (50 Hz, 80 Hz or 400 Hz runs are
  stored as separate plotting scripts);
- `use_mosfet_thermal_model`, `use_thermal_model` — nonlinear iterations of the Simscape
  solver; the bridge itself (`danfoss_SKM1700MB20R4S2I4` SiC MOSFET with losses and
  temperatures, or the ideal switch commented out in `three_levels/`) is chosen in the model.

## Repository layout

| Folder | Content |
|---|---|
| [`two_levels`](two_levels) | Two-level full-bridge inverter, `fPWM = 10 kHz`, runs at 50 / 80 / 400 Hz; `param` init with local parameterization in `private/` |
| [`three_levels`](three_levels) | Three-level T-type inverter, `fPWM = 20 kHz`, MOSFET thermal model on, 400 Hz default; `param` init with local parameterization in `private/` |

Each folder has its own README.
