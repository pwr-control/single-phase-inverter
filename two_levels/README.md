# Two-level single-phase inverter

Full-bridge two-level inverter, 225 kW, 690 V application, `fPWM = 10 kHz` with double update,
Simscape step `ts/200`. Default operating frequency 50 Hz; FHT-based virtual dq frame.

## Files

- `init_model.m` — initialization (`init_environment('single_phase_inverter')`), see the root
  README for the flags.
- `single_phase_inverter.slx` — the model (grid, LCL filter, bridge, controller, metering).
- `plotting_results_sim_results_50Hz_10kHz_1.m`, `_80Hz_10kHz_1.m`, `_400Hz_10kHz_1.m` —
  grid currents/voltages, inverter output current, MOSFET Q1/Q2 losses and temperatures,
  device current/voltage, DC-link voltage, for the three stored operating points; EPS output
  into `figures/`.
- `power_losses_calculation.m` — mean device losses over the last 0.8 s, RMS output current
  and voltage, first-harmonic voltage from the controller outputs, filter capacitor current,
  grid power, junction-to-heatsink temperature rise, rectifier diode current.
- `spectrum.m` — FFT of the output current.
- `plant_estimator.m` — stand-alone check of the RL plant in the dq frame (steady-state
  `id`, `iq` for a given `R`, `XL`).
- `virtual_phase_shift_filter_analysis.m` — stand-alone study of the alpha/beta components
  obtained from a three-phase set and of the virtual phase-shift filter.
