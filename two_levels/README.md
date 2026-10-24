# Two-level single-phase inverter

Full-bridge two-level inverter, 225 kW, 690 V application, `fPWM = 10 kHz` (single update,
`ts = 100 µs`), Simscape step `ts/200 = 0.5 µs`, SiC MOSFET bridge with thermal model
(`danfoss_SKM1700MB20R4S2I4`) and 50 Hz as default operating frequency
(`param.spinv.frequency_set = 50`); FHT-based virtual dq frame.

## Model `single_phase_inverter.slx`

Root: `battery_1` (library block `lithium_ion_battery`, 1070 V, 250 kW, 50 Ah, and the Solver
Configuration: local solver at `glb_time.tc`), `dclink` (capacitor `CFi_dc`, `CFi` and `RCFi` of the
hardware data), `single_phase_inverter` (library bridge `full_bridge_mosfet_based_with_thermal_model`;
control with phase generator, virtual dq current control fed by FHT, SOGI or phase-shift filter, dq PI
or resonant PI, system identification and impedance measure, modulator `single_phase_pwm_modulator`
with global TRGO), `output_transformer` (library `single_phase_transformer`), `load` (RL),
`global timing`, `scopes`, `data_storage` (the `*_sim` variables at `tc`). The `grid` (grid emulator,
power meter) and `rectifier` (diode rectifier with its H5 and H7 filters) subsystems of the shared
template are commented out.

## How to run

1. `init_model.m`: first puts the companion library on the path (`private/library_setup.m`: the copy
   already on the path, else the folder `library` next to this repository or the one named by the
   environment variable `PWR_CONTROL_LIBRARY`, cloned from GitHub when it does not exist; for this
   session only, `savepath` to keep it), prints the library in use and the functions of `private/`,
   builds `param` (one group per subsystem), checks that the Simscape models come from the library,
   opens the model.
2. Simulate: 1.25 s (`param.sim.simlength`), logged at `tc` for the whole run.
3. Post-process with `power_losses_calculation.m`, `spectrum.m` (they read `Nc`, `Ns_inv`, `tc`,
   `ts_inv` and `decimation_tc`, exported by the init) or the plotting scripts of the stored runs (they
   load the `.mat` of the run and read `glb_time`, `frequency_set` and `grid_emu`, which the commented
   `save(...)` line of `init_model.m` stores with the `*_sim` variables and `param`). Results (`.mat`)
   and figures (EPS) are ignored by git.

Main switches in `init_model.m`:

- `param.spinv.impl.use_single_phase_inverter_based_FHT / _SOGI / _PHSH` (and `_ccaller`): which
  quadrature-signal generator feeds the virtual dq transformation, Simulink block or C-Caller code;
- `param.spinv.rpi_enable`: resonant PI (1) or dq PI (0);
- `param.spinv.system_identification_enable` and `param.spinv.impl.use_system_identification_based_*`:
  identification mode at `frequency_set = 300 Hz`;
- `param.spinv.frequency_set`: operating frequency of the AC side (stored runs at 50, 80 and 400 Hz);
  compared with `grid_emu.fgrid_nom`, it also selects the variant of the phase generator;
- `param.sim.use_mosfet_thermal_model`, `param.sim.use_thermal_model`: nonlinear iterations of the
  Simscape solver (the bridge of the model is the one with thermal model);
- `param.sim.build_template_extras`: builds the data of the commented diode rectifier
  (`diode.rectifier`, `igbt.inv`), to uncomment it. Its H5 and H7 filters also read `C5`, `L5`, `C7`,
  `L7`, and the commented `acquisition_and_scaling_current` reads `adc11_quantization`: no init defines
  them, the legacy one included.

## Local parameterization (`private/`) and library

The functions in `private/` take precedence over the library ones, for the files of this folder only:
a library function copied there with the same name is the local parameterization of this model, and
whatever is not in `private/` comes from the library (setup classes and algorithms, device datasets,
blocks). Each copy states in its header where it comes from and what was changed; `init_model.m`
lists the overrides at every run.

| File | Content |
|---|---|
| `private/single_phase_inverter_hwdata.m` | hardware of the full bridge (690 V set: `udc_nom` = 1239 V, `CFi` = 6 mF, `RCFi` = 1 mΩ; the model reads the DC link and the normalization, it has no output LC filter): local copy of the library function, same numbers, returns the library object `hw_single_phase_inverter_setup` |
| `private/library_setup.m` | adds the library to the path (clones it when missing); same file as in `three_levels/private` |
| `private/check_ssc_from_library.m` | the Simscape models always come from the library: every non-MathWorks component of the model (`lithium_ion_cell` of the battery, `saturable_single_phase_transformer` of the output transformer, and `single_phase_transformer` in the commented grid emulator) must resolve inside the library clone, otherwise the init stops with the list of the local copies to remove |

The `.ssc` files are never copied into `private/`: Simscape does not see package folders there, and a
copy of a `+package` folder here or elsewhere on the path is caught by the check above.

## `param` and the legacy names

`init_model.m` builds everything in the struct `param` (`param.sim`, `param.time`, `param.glb_time`,
`param.spinv`, `param.grid`, `param.afe`, `param.battery`, `param.trafo_load`, `param.meas`,
`param.ctrl`, `param.thermal`, `param.dev`, and `param.rectifier` with the template extras), the same
convention as `three_levels` and the other projects. The `lithium_ion_battery` block of the current
library reads `param.battery.nominal_battery_voltage_1` (initial voltage of its terminal capacitor).
The model still reads the old flat names: the last section of the init ("Transition: legacy workspace
names") exports exactly those (listed from the `.slx`, library links included), plus the timing
names of the post-processing scripts. After rewriting the model to `param.*`
(`tools/migrate_model_to_param` of modelization-and-control), set `export_legacy_names = false` and
delete that section.

`init_model_legacy.m` is the previous flat init, kept for reference: it no longer runs with the
current library (four-argument `lithium_ion_battery_setup`, `grid_fault_generator` called as a
script). Differences of the new init: the battery capacity is passed explicitly (50 Ah, the value the
old library fixed) and its voltage is written as a number (1070 V, the DC voltage of the 690 V AFE data
set that the legacy init used), the second battery and the stages of the shared template that are not
in this model (three-phase inverter and machines, AFE, DAB, PSFBC, CLLC, ISOP rail, UPQC) are not
built, the MOSFET dataset is set up with the DC link of this inverter (it changes only the ZVS snubber
fields, not read by the bridge), and the `set_param` block of another model (`afe_inv_psm`), commented
out at the end of the legacy init, is dropped.

## Files

| File | Content |
|---|---|
| `single_phase_inverter.slx` | Simulink/Simscape model |
| `init_model.m` | builds `param`, checks the Simscape models, opens the model, exports the legacy names |
| `init_model_legacy.m` | previous flat init (reference only) |
| `private/` | local parameterization and helpers (see above) |
| `plotting_results_sim_results_50Hz_10kHz_1.m`, `_80Hz_10kHz_1.m`, `_400Hz_10kHz_1.m` | grid currents and voltages, inverter output current, MOSFET Q1/Q2 losses and temperatures, device current and voltage, DC-link voltage, for the three stored operating points; EPS output into `figures/` |
| `power_losses_calculation.m` | mean device losses over the last 0.8 s, RMS output current and voltage, first-harmonic voltage from the controller outputs, filter capacitor current, grid power, junction-to-heatsink temperature rise, rectifier diode current |
| `spectrum.m` | FFT of the output current |
| `plant_estimator.m` | stand-alone check of the RL plant in the dq frame (steady-state `id`, `iq` for a given `R`, `XL`) |
| `virtual_phase_shift_filter_analysis.m` | stand-alone study of the alpha/beta components obtained from a three-phase set and of the virtual phase-shift filter |
