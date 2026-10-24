# Three-level T-type single-phase inverter

Same application (225 kW, 690 V) with a three-level T-type bridge, `fPWM = 20 kHz` (single update,
`ts = 50 µs`), Simscape step `ts/100 = 0.5 µs`, SiC MOSFET bridge with thermal model
(`danfoss_SKM1700MB20R4S2I4`) and 400 Hz as default operating frequency
(`param.spinv.frequency_set = 400`).

## Model `single_phase_ttype_inverter.slx`

Root: `battery_1` (library block `lithium_ion_battery`, 1200 V, 250 kW, 50 Ah, and the Solver
Configuration: local solver at `glb_time.tc`), `dclink` (library `dclink_for_three_levels`, the two
banks `CFi1`, `CFi2`), `single_phase_inverter` (library bridge `mosfet_based_three_level_inverter_ttype`,
the ideal-switch bridge is commented out; control with phase generator, virtual dq current control fed by
FHT, SOGI or phase-shift filter, dq PI or resonant PI, modulator
`single_phase_three_levels_PWM_generator_with_global_TRGO`), `output_transformer` (library
`single_phase_transformer`), `load` (RL), `global timing`, `scopes`, `data_storage` (the `*_sim`
variables at `tc`). The `afe` and `grid` subsystems of the shared template are commented out.

## How to run

1. `init_model.m`: first puts the companion library on the path (`private/library_setup.m`: the copy
   already on the path, else the folder `library` next to this repository or the one named by the
   environment variable `PWR_CONTROL_LIBRARY`, cloned from GitHub when it does not exist; for this
   session only, `savepath` to keep it), prints the library in use and the functions of `private/`,
   builds `param` (one group per subsystem), checks that the Simscape models come from the library,
   opens the model.
2. Simulate: 1.25 s (`param.sim.simlength`), logged at `tc` for the whole run.
3. Post-process with `power_losses_calculation.m`, `spectrum.m` (they read `Nc` and `tc`, exported by
   the init) or the plotting scripts of the stored runs. Results (`.mat`) and figures (EPS) are ignored
   by git; a run is saved with the commented `save(...)` line of `init_model.m`.

Main switches in `init_model.m`:

- `param.spinv.impl.use_single_phase_inverter_based_FHT / _SOGI / _PHSH` (and `_ccaller`): which
  quadrature-signal generator feeds the virtual dq transformation, Simulink block or C-Caller code;
- `param.spinv.rpi_enable`: resonant PI (1) or dq PI (0);
- `param.spinv.system_identification_enable`: identification mode at `frequency_set = 300 Hz`;
- `param.spinv.frequency_set`: operating frequency of the AC side;
- `param.sim.use_mosfet_thermal_model`, `param.sim.use_thermal_model`: nonlinear iterations of the
  Simscape solver (the bridge itself is chosen in the model);
- `param.sim.build_template_extras`: builds the data of the commented AFE and grid emulator
  (`hwdata.afe`, `frt_data`, `igbt.afe`, dqPLL variants...), to uncomment them.

## Local parameterization (`private/`) and library

The functions in `private/` take precedence over the library ones, for the files of this folder only:
a library function copied there with the same name is the local parameterization of this model, and
whatever is not in `private/` comes from the library (setup classes and algorithms, device datasets,
blocks). Each copy states in its header where it comes from and what was changed; `init_model.m`
lists the overrides at every run.

| File | Content |
|---|---|
| `private/single_phase_inverter_hwdata.m` | hardware of the T-type inverter (DC link, LC filter, brake resistor; 690 V set: `udc_nom` = 1239 V, `CFi1` = `CFi2` = 12 mF, `LFu` = 500 µH, `CFu` = 200 µF): local copy of the library function, same numbers, returns the library object `hw_single_phase_inverter_setup` |
| `private/library_setup.m` | adds the library to the path (clones it when missing); copy of the one of `solid-state-transformers`, without the `.git` folder on the path |
| `private/check_ssc_from_library.m` | the Simscape models always come from the library: every non-MathWorks component of the model (`single_phase_transformer`, `lithium_ion_cell`, and `threephase_inductor`, `saturable_single_phase_transformer` in the commented parts) must resolve inside the library clone, otherwise the init stops with the list of the local copies to remove |

The `.ssc` files are never copied into `private/`: Simscape does not see package folders there, and a
copy of a `+package` folder here or elsewhere on the path is caught by the check above.

## `param` and the legacy names

`init_model.m` builds everything in the struct `param` (`param.sim`, `param.time`, `param.glb_time`,
`param.spinv`, `param.grid`, `param.afe`, `param.battery`, `param.trafo_load`, `param.meas`,
`param.ctrl`, `param.thermal`, `param.dev`), the same convention as the other projects. The
`lithium_ion_battery` block of the current library reads `param.battery.nominal_battery_voltage_1`
(initial voltage of its terminal capacitor). The model still reads the old flat names: the last
section of the init ("Transition: legacy workspace names") exports exactly those (listed from the
`.slx`, library links included). After rewriting the model to `param.*`
(`tools/migrate_model_to_param` of modelization-and-control), set `export_legacy_names = false` and
delete that section.

`init_model_legacy.m` is the previous flat init, kept for reference: it no longer runs with the
current library (four-argument `lithium_ion_battery_setup`, `grid_fault_generator` called as a
script). Differences of the new init: the battery capacity is passed explicitly (50 Ah, the value the
old library fixed), the second battery and the stages of the shared template that are not in this
model (three-phase inverter and machines, DAB, PSFBC, CLLC, ISOP rail, UPQC, diode rectifier) are not
built, the MOSFET dataset is set up with the DC link of this inverter (it changes only the ZVS
snubber fields, not read by the bridge).

## Files

| File | Content |
|---|---|
| `single_phase_ttype_inverter.slx` | Simulink/Simscape model |
| `init_model.m` | builds `param`, checks the Simscape models, opens the model, exports the legacy names |
| `init_model_legacy.m` | previous flat init (reference only) |
| `private/` | local parameterization and helpers (see above) |
| `plotting_results_sim_results_50Hz_10kHz_1.m`, `_400Hz_10kHz_1.m` | plots of the two stored operating points (grid quantities, output current, device losses and temperatures, DC-link voltage) |
| `power_losses_calculation.m`, `spectrum.m`, `plant_estimator.m` | same post-processing as in `two_levels/` |
