# Three-level T-type single-phase inverter

Same application (225 kW, 690 V) with a three-level T-type bridge, `fPWM = 20 kHz`,
Simscape step `ts/100`, MOSFET thermal model enabled by default and 400 Hz as default
operating frequency (`frequency_set = 400`).

## Files

- `init_model.m` — initialization (`init_environment('single_phase_ttype_inverter')`), see
  the root README for the flags.
- `single_phase_ttype_inverter.slx` — the model.
- `plotting_results_sim_results_50Hz_10kHz_1.m`, `_400Hz_10kHz_1.m` — plots for the two
  stored operating points (grid quantities, output current, device losses and temperatures,
  DC-link voltage).
- `power_losses_calculation.m`, `spectrum.m`, `plant_estimator.m` — same post-processing as
  in `two_levels/`.
