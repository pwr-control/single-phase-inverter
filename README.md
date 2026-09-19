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

## How to use

1. Run `init_model.m` in `two_levels/` or `three_levels/`: it sets timing, hardware data,
   control gains and the device set, then opens the model.
2. Simulate the `.slx`.
3. Post-process with the scripts in the same folder. Results (`.mat`) and figures (EPS) are
   ignored by git.

Main switches in `init_model.m`:

- `use_single_phase_inverter_based_FHT / _SOGI / _PHSH` (and `_ccaller` variants) — which
  quadrature-signal generator feeds the virtual dq transformation, and whether it runs as a
  Simulink block or as C-Caller code;
- `system_identification_enable` and `use_system_identification_based_*` — identification
  mode at `frequency_set = 300 Hz`;
- `frequency_set` — operating frequency of the AC side (50 Hz, 80 Hz or 400 Hz runs are
  stored as separate plotting scripts);
- `use_mosfet_thermal_model`, `use_thermal_model` — device model with losses and
  temperatures (`danfoss_SKM1700MB20R4S2I4` SiC MOSFET, `mitsubishi_CM1200DW_24T` IGBT) or
  ideal switch.

## Repository layout

| Folder | Content |
|---|---|
| [`two_levels`](two_levels) | Two-level full-bridge inverter, `fPWM = 10 kHz`, runs at 50 / 80 / 400 Hz |
| [`three_levels`](three_levels) | Three-level T-type inverter, `fPWM = 20 kHz`, MOSFET thermal model on, 400 Hz default |

Each folder has its own README.
