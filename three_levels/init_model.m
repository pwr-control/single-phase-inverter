%[text] # single\_phase\_ttype\_inverter: model initialization (param structure by subsystem)
% Rev. 01, 2026-10-24. Replaces the flat-workspace init_model.m (kept as init_model_legacy.m, which no longer
% runs with the current library: four-argument lithium_ion_battery_setup, grid_fault_generator called as a
% script). Model single_phase_ttype_inverter.slx: three-level T-type single-phase inverter, 225 kW, 690 V
% application, SiC MOSFET bridge with thermal model (danfoss_SKM1700MB20R4S2I4), fPWM = 20 kHz, fed by the
% lithium-ion battery battery_1 on the split DC link (dclink), output transformer and RL load; control in a
% virtual dq frame (FHT, SOGI or phase-shift filter) with dq PI or resonant PI, 400 Hz output. The AFE and
% the grid emulator of the shared template are in the model but commented out.
% Same convention as the other models of the projects (afe_dq_three_phase, sst_cllc_dcx): everything the
% model needs is in the struct "param", one group per subsystem:
%   param.sim         simulation settings (stop time, Simscape iterations, thermal model flags, library used)
%   param.time        timing settings shared by all stages, and the PWM data of the stages not in this model
%   param.glb_time    timing_setup object (built from param.time and param.spinv.pwm)
%   param.spinv       single-phase inverter: application_voltage, pwr_nom, .pwm, operating point (frequency_set,
%                     omega_set, system_identification_enable, rpi_enable), .impl (variants), .ref (current
%                     references), .hw (hardware object, ./private/single_phase_inverter_hwdata.m), .pres_ctrl
%                     (resonant PI), .sogi, .dqvector_pi, .ctrl (ctrl_single_phase_inverter_setup object),
%                     .mosfet, .ideal_switch
%   param.grid        grid inputs;                       param.grid.emu  grid_three_phase_emulator object
%   param.afe         param.afe.ctrl  ctrl_afe_setup object (the phase generator of the inverter reads its FHT data)
%   param.battery     battery inputs;                    param.battery.pack_1  lithium_ion_battery_setup struct
%   param.trafo_load  output transformer and RL load;    .output_transformer  single_phase_transformer_setup object
%   param.meas        ADC end scale and quantization
%   param.ctrl        control settings common to all modules (time alignment, filters, PI clip release)
%   param.thermal     heatsink inputs;                   param.thermal.heatsink  liquid_cooled_plate_2kw_setup object
%   param.dev         names of the semiconductor datasets
%
% Naming rule: the leaf name of the old workspace variable is kept (kp_align -> param.ctrl.kp_align,
% frequency_set -> param.spinv.frequency_set); library objects keep their name as a field:
% hwdata.single_phase_inverter -> param.spinv.hw, single_phase_inverter_ctrl -> param.spinv.ctrl,
% mosfet.inv -> param.spinv.mosfet, grid_emu -> param.grid.emu, afe_ctrl -> param.afe.ctrl,
% lithium_ion_battery_1 -> param.battery.pack_1, output_transformer -> param.trafo_load.output_transformer,
% heatsink -> param.thermal.heatsink, glb_time -> param.glb_time.
%
% Local parameterization and library. The first command, library_setup (./private/library_setup.m), adds the
% library to the path with its subfolders: the copy already on the path, else the folder "library" next to this
% repository (or the one named by the environment variable PWR_CONTROL_LIBRARY), cloned from
% https://github.com/pwr-control/library when neither exists. The functions in ./private take precedence over
% the library, for the files of this folder only: a library function copied there with the same name is the
% local parameterization of this model (./private/single_phase_inverter_hwdata.m: the hardware of the T-type
% inverter), and whatever is not in ./private comes from the library (setup classes and algorithms, device
% datasets, blocks). The overrides are listed at every run. The Simscape models (.ssc) always come from the
% library: check_ssc_from_library (./private) stops the init when the model would take a component from a
% local copy, and no .ssc file goes in ./private.
%
% The other stages of the shared template (three-phase inverter and machines, DAB, PSFBC, CLLC, ISOP rail,
% UPQC, diode rectifier, second battery) are not in this model, not even commented: they are not built here
% (init_model_legacy.m has them). The data of the commented AFE and grid emulator (hwdata.afe, frt_data,
% igbt.afe...) are built only with param.sim.build_template_extras = true.
%
% The last code section ("Transition: legacy workspace names") exports the old names still read by
% single_phase_ttype_inverter.slx. Once the model is rewritten to param.* (tools/migrate_model_to_param of
% modelization-and-control), set export_legacy_names = false and delete that section.

clear;
lib_root = library_setup;   % pwr-control/library on the path, cloned next to this repository when missing (./private/library_setup.m)
[model, options] = init_environment('single_phase_ttype_inverter');
s = tf('s');
param = struct();
param.sim.library_root = lib_root;          % library used by this run (and by the Simscape check of Model setup)
clear lib_root

% local parameterization: the functions in ./private take precedence over the library ones
private_files = dir(fullfile(fileparts(mfilename('fullpath')), 'private', '*.m'));
library_files = dir(fullfile(param.sim.library_root, '**', '*.m'));
is_override = ismember({private_files.name}, {library_files.name});
fprintf('%s init: library %s\n', model, param.sim.library_root);
fprintf('%s init: private/ overrides of the library: %s; local helpers: %s\n', model, ...
    strjoin({private_files(is_override).name}, ', '), strjoin({private_files(~is_override).name}, ', '));
clear private_files library_files is_override

% save('sim_results_xx.mat', '-v7.3', '-regexp', '_sim$', '^param$');
%[text] ## Simulation
param.sim.simlength = 1.25;                 % [s] model StopTime (variable step ode23tb, MaxStep glb_time.tc)

% power stage model: the T-type bridge with MOSFETs and thermal model is the active one in the .slx (the
% ideal-switch bridge is commented out); the two flags set the nonlinear iterations of the Simscape solver
% (Solver Configuration of battery_1, local solver at glb_time.tc)
param.sim.use_mosfet_thermal_model = 1;
param.sim.use_thermal_model = 0;

param.sim.nonlinear_iterations = 3;
if (param.sim.use_mosfet_thermal_model || param.sim.use_thermal_model)
    param.sim.nonlinear_iterations = 5;
end

% template settings not read by single_phase_ttype_inverter.slx, kept with the same names as in the other models
param.sim.load_step_time = 1.25;            % [s]
param.sim.transmission_delay = 125e-6*2;    % [s]
param.sim.sst_num_of_modules = 2;
param.sim.number_of_modules = 1;
param.sim.enable_two_modules = param.sim.number_of_modules;
param.sim.time_aux_power_supply_fault = 1e3;    % [s] never, in this run (brake of the commented AFE)

% data of the commented AFE and grid emulator: see add_template_extras at the end
param.sim.build_template_extras = false;
%[text] ## Timing
param.time.fpwm = 20e3;                             % [Hz] base PWM frequency, the same for all the stages
param.time.t_measure = param.sim.simlength;         % [s] logged window: the whole run
param.time.tc_factor = 100;                         % tc = ts_afe/tc_factor = 0.5 us (logging base, MaxStep, Simscape step)
param.time.tc_decimation = 1;
param.time.delay_pwm = 0;
param.time.trgo_th_generator = 0.025;

% trgo: 1 double update (ts = 1/(2 fPWM)), 0 single update (ts = 1/fPWM). AFE and inverters at 0 as in the
% legacy runs (the legacy comments said "double update" on those lines)
% AFE clock domain: the AFE is commented out, but ts_afe is the base of tc and the sample time of the
% moving average filter of impedance_measure
param.time.fpwm_afe = param.time.fpwm;
param.time.trgo_afe = 0;                            % single update: ts_afe = 50 us
param.time.dead_time_afe = 0.3e-6;
% DAB clock domain: sample time of the Kalman SOC observer of battery_1 (ts_dab)
param.time.fpwm_dab = param.time.fpwm;
param.time.trgo_dab = 1;                            % double update: ts_dab = 25 us
param.time.dead_time_dab = 2e-6;
% stages not in this model, needed by the shared timing object only
param.time.fpwm_psfbc = param.time.fpwm;
param.time.trgo_psfbc = 1;                          % double update
param.time.dead_time_psfbc = 3e-6;
param.time.fpwm_isop_rail = param.time.fpwm;
param.time.trgo_isop_rail = 1;                      % double update
param.time.dead_time_isop_rail = 3e-6;
param.time.fpwm_cllc = param.time.fpwm;
param.time.trgo_cllc = 1;                           % double update
param.time.dead_time_cllc = 2e-6;
%[text] ### Single-phase inverter PWM
% the T-type inverter uses two clock domains of the timing object, set here with the same PWM: INV (modulator
% fPWM_INV and dead_time_INV, current control ts_inv, logging Ns_inv) and SINGLE_PHASE_INV (phase generator and
% time alignment, ts_single_phase_inv)
param.spinv.pwm.fpwm = param.time.fpwm;             % [Hz]
param.spinv.pwm.trgo = 0;                           % single update: ts_inv = ts_single_phase_inv = 50 us
param.spinv.pwm.dead_time = 0.3e-6;                 % [s]
%[text] ### Global timing object
t = param.time;
p = param.spinv.pwm;
param.glb_time = timing_setup(t.fpwm_afe, t.trgo_afe, p.fpwm, p.trgo, p.fpwm, p.trgo, t.fpwm_dab, t.trgo_dab, ...
    t.fpwm_psfbc, t.trgo_psfbc, t.fpwm_isop_rail, t.trgo_isop_rail, t.fpwm_cllc, t.trgo_cllc, ...
    t.t_measure, t.tc_factor, t.tc_decimation, t.delay_pwm, t.dead_time_afe, p.dead_time, ...
    p.dead_time, t.dead_time_dab, t.dead_time_psfbc, t.dead_time_isop_rail, t.dead_time_cllc);
clear t p
%[text] ## Single-phase inverter: operating point and variants
param.spinv.application_voltage = 690;      % [V] 690, 480 or 400: hardware set and grid data
param.spinv.pwr_nom = 225e3;                % [W]

% global behaviour: system identification versus normal operation, operating frequency
param.spinv.system_identification_enable = 0;       % (variant)
param.spinv.frequency_set = 400;                    % [Hz] (variant) default
if param.spinv.system_identification_enable
    param.spinv.frequency_set = 300;
end
param.spinv.omega_set = param.spinv.frequency_set*2*pi;    % [rad/s]
%[text] ### Implementation (Simulink or C-caller) and quadrature signal generator
%[text] Flags marked (variant) drive Variant Subsystem conditions in the model.
param.spinv.rpi_enable = 0;                 % (variant) 1: resonant PI, 0: dq PI
param.spinv.impl.use_current_controller_from_ccaller_mod1 = 1;     % (variant)
param.spinv.impl.use_phase_shift_filter_from_ccaller_mod1 = 1;
param.spinv.impl.use_sogi_from_ccaller_mod1 = 1;

param.spinv.impl.use_single_phase_inverter_based_FHT = 1;              % (variant)
param.spinv.impl.use_single_phase_inverter_based_SOGI = 0;             % (variant)
param.spinv.impl.use_single_phase_inverter_based_PHSH = 0;             % (variant)
param.spinv.impl.use_single_phase_inverter_based_SOGI_ccaller = 0;     % (variant)
param.spinv.impl.use_single_phase_inverter_based_PHSH_ccaller = 0;     % (variant)

% system identification mode (sistem_identification subsystem, commented out in the model)
param.spinv.impl.use_system_identification_based_FHT = 0;
param.spinv.impl.use_system_identification_based_SOGI = 0;
param.spinv.impl.use_system_identification_based_PHSH = 0;
param.spinv.impl.use_system_identification_based_SOGI_ccaller = 0;
param.spinv.impl.use_system_identification_based_PHSH_ccaller = 1;
%[text] ### Current references
% steps of the output current reference [pu] (inverter_current_output_pu_reference)
param.spinv.ref.iph_grid_pu_ref_1 = 1/3;
param.spinv.ref.iph_grid_pu_ref_2 = 1/3;
param.spinv.ref.iph_grid_pu_ref_3 = 1/3;
param.spinv.ref.time_step_ref_1 = 0.025;    % [s]
param.spinv.ref.time_step_ref_2 = 0.5;      % [s]
param.spinv.ref.time_step_ref_3 = 1;        % [s]
%[text] ## Grid
% The grid emulator is commented out in the model; the phase generator of the inverter control reads its
% nominal frequency and voltage base (grid_emu.fgrid_nom, .u2bez) and the FHT data of the AFE control
% (afe_ctrl.fht_grid), built from the same grid.
param.grid.grid_nominal_power = 1000e3;             % [W]
param.grid.application_voltage = param.spinv.application_voltage;     % [V]
param.grid.grid_nominal_current = param.grid.grid_nominal_power/param.grid.application_voltage/sqrt(3);

% coupling transformer Dyn11
param.grid.delta_star = 1;

if param.grid.application_voltage == 690
    param.grid.us1 = 690; param.grid.us2 = 690; param.grid.fgrid = 50;
    param.grid.eta = 95; param.grid.ucc = 5;
    param.grid.p_iron = 1800;
elseif param.grid.application_voltage == 480
    param.grid.us1 = 480; param.grid.us2 = 480; param.grid.fgrid = 60;
    param.grid.eta = 95; param.grid.ucc = 5;
    param.grid.p_iron = 1400;
else
    param.grid.us1 = 400; param.grid.us2 = 400; param.grid.fgrid = 50;
    param.grid.eta = 95; param.grid.ucc = 5;
    param.grid.p_iron = 1000;
end

param.grid.n2 = 14;
param.grid.n1 = floor(param.grid.n2*sqrt(3));
param.grid.core_area = 0.05;                        % [m^2]
param.grid.core_length = 2.5;                       % [m]
param.grid.mu0 = 4*pi*1e-7;
param.grid.mur = 10e3;

% magnetizing inductance from the core geometry, no-load current from it
param.grid.Lm1 = (param.grid.n1^2 * param.grid.mu0 * param.grid.mur * param.grid.core_area) / param.grid.core_length;
param.grid.i1m = param.grid.us1/sqrt(3)/param.grid.Lm1/(2*pi*param.grid.fgrid);

% reference for the voltage sequences
param.grid.up_xi_pu_ref = 1;
param.grid.up_eta_pu_ref = 0;
param.grid.un_xi_pu_ref = 0;
param.grid.un_eta_pu_ref = 0;

% grid impedance (ucc_factor can be preset only if the clear at the top is removed, e.g. in a sweep)
param.grid.Lgrid_base = param.grid.us1/sqrt(3)*param.grid.ucc/100/2/pi/param.grid.fgrid/param.grid.grid_nominal_current;
if exist('ucc_factor', 'var')
    param.grid.ucc_factor = ucc_factor;
else
    param.grid.ucc_factor = 1;
end
param.grid.eq_grid_inductance = param.grid.Lgrid_base*param.grid.ucc_factor;    % [H]
param.grid.eq_grid_resistance = 2e-3;                                             % [Ohm]

g = param.grid;
param.grid.emu = grid_three_phase_emulator('Dyn11', g.delta_star, g.grid_nominal_power, g.application_voltage, ...
    g.us1, g.us2, g.fgrid, g.eq_grid_inductance, g.eq_grid_resistance, g.eta, g.ucc, g.i1m, g.p_iron, ...
    g.n1, g.n2, g.core_area, g.core_length, g.mur, ...
    g.up_xi_pu_ref, g.up_eta_pu_ref, g.un_xi_pu_ref, g.un_eta_pu_ref);
clear g
%[text] ### AFE control (with sequences)
% only its FHT data (fht_grid) are read by the active model; the gains below are those of the commented AFE
param.afe.ctrl = ctrl_afe_setup(param.glb_time.ts_afe, param.grid.emu.omega_grid_nom);
param.afe.ctrl.kp_udc_ctrl = 2;

% resonant PI gains for weak grids
% param.afe.ctrl.res_pi.kp_rpi = 0.5;
% param.afe.ctrl.res_pi.ki_rpi = 18;

% resonant PI gains for LVRT
param.afe.ctrl.res_pi.kp_rpi = 0.6;
param.afe.ctrl.res_pi.ki_rpi = 35;
%[text] ## Single-phase inverter: hardware
% DC link (two banks CFi1, CFi2 of the three-level bridge), output LC filter, normalization (ubez, ibez,
% norm.Xbez). single_phase_inverter_hwdata is the local copy in ./private (the numbers of this model), it
% returns the hw_single_phase_inverter_setup object of the library.
param.spinv.hw = single_phase_inverter_hwdata(param.spinv.application_voltage, param.spinv.pwr_nom, param.glb_time.fPWM_INV);
h = param.spinv.hw;
fprintf(['T-type inverter: %.0f kW, %.1f V / %.1f A rms, udc_nom = %.1f V, CFi1 = CFi2 = %.1f mF, ' ...
    'LFu = %.0f uH, CFu = %.0f uF\n'], h.pwr_nom/1e3, h.us_nom, h.is_nom, h.udc_nom, h.CFi1*1e3, ...
    h.LFu*1e6, h.CFu*1e6);
clear h
%[text] ## Single-phase inverter: control
%[text] ### Resonant PI
ts = param.glb_time.ts_inv;
param.spinv.pres_ctrl.kp_rpi = 0.75;
param.spinv.pres_ctrl.ki_rpi = 45;
param.spinv.pres_ctrl.delta_rpi = 0.025;
param.spinv.pres_ctrl.omega_set = param.spinv.omega_set;
w = param.spinv.pres_ctrl.omega_set;
dr = param.spinv.pres_ctrl.delta_rpi;
param.spinv.pres_ctrl.res_nom = s/(s^2 + 2*dr*w*s + w^2);
param.spinv.pres_ctrl.Ares_nom = [0 1; -w^2 -2*dr*w];
param.spinv.pres_ctrl.Aresd_nom = eye(2) + param.spinv.pres_ctrl.Ares_nom*ts;
param.spinv.pres_ctrl.a11d = 1;
param.spinv.pres_ctrl.a12d = ts;
param.spinv.pres_ctrl.a21d = -w^2*ts;
param.spinv.pres_ctrl.a22d = 1 - 2*dr*w*ts;         % the legacy init writes it to apres_ctrl (typo)
param.spinv.pres_ctrl.Bres = [0; 1];
param.spinv.pres_ctrl.Cres = [0 1];
param.spinv.pres_ctrl.Bresd = param.spinv.pres_ctrl.Bres*ts;
param.spinv.pres_ctrl.Cresd = param.spinv.pres_ctrl.Cres;
clear w dr
%[text] ### SOGI (second order generalized integrator)
param.spinv.sogi_delta = 1;
param.spinv.kepsilon = 2;
param.spinv.sogi = sogi_filter(param.spinv.omega_set, param.spinv.sogi_delta, param.spinv.kepsilon, param.glb_time.ts_afe);
%[text] ### Current control parameters DQ PI
param.spinv.dqvector_pi.kp_inv = 0.5;
param.spinv.dqvector_pi.ki_inv = 45;
param.spinv.dqvector_pi.pi_ctrl = param.spinv.dqvector_pi.kp_inv + param.spinv.dqvector_pi.ki_inv/s;
param.spinv.dqvector_pi.pid_ctrl = c2d(param.spinv.dqvector_pi.pi_ctrl, ts);
param.spinv.dqvector_pi.plant = 1/(s*param.grid.emu.trafo.Ld1 + 1);     % as in the legacy init
param.spinv.dqvector_pi.plantd = c2d(param.spinv.dqvector_pi.plant, ts);
param.spinv.dqvector_pi.G = param.spinv.sogi.fltd.alpha * param.spinv.dqvector_pi.pid_ctrl * param.spinv.dqvector_pi.plantd;
figure; margin(param.spinv.dqvector_pi.G, options); grid on
%[text] ### Single-phase inverter control object (resonant PI and virtual dq)
param.spinv.ctrl = ctrl_single_phase_inverter_setup(ts, param.spinv.pres_ctrl.omega_set, ...
    param.spinv.dqvector_pi.kp_inv, param.spinv.dqvector_pi.ki_inv, param.spinv.pres_ctrl.kp_rpi, ...
    param.spinv.pres_ctrl.ki_rpi, param.spinv.pres_ctrl.delta_rpi);
clear ts
%[text] ## Power semiconductors
param.dev.used_device_mosfet = 'danfoss_SKM1700MB20R4S2I4';
param.dev.used_device_ideal_switch = 'silicon_high_power_ideal_switch';
param.dev.used_device_igbt = 'mitsubishi_CM1200DW_24T';        % IGBT of the commented AFE (template extras)

% T-type bridge (mosfet_based_three_level_inverter_ttype). The DC voltage enters only the ZVS snubber fields
% (Csnubber_zvs, Rsnubber_zvs), not read by the bridge: the legacy init passed the three-phase inverter one
% (hwdata.inv.udc_nom = 1070 V), here it is the DC link of this inverter
param.spinv.mosfet = device_mosfet_setup(param.dev.used_device_mosfet, param.glb_time.fPWM_INV, param.spinv.hw.udc_nom);

% ideal switch: the ideal-switch bridge of the model (commented out) has its numbers in the block mask
param.spinv.ideal_switch = device_ideal_switch_setting(param.dev.used_device_ideal_switch, param.glb_time.fPWM_INV, param.spinv.hw.udc_nom);
%[text] ## Battery
% battery_1 feeds the DC link. Same pack as in the legacy init: 1200 V, the DC voltage that the legacy init
% took from the DAB data set of the template (hwdata.dab.udc1_bez for the 690 V application), 250 kW.
% The lithium_ion_battery block of the library reads param.battery.nominal_battery_voltage_1 for the initial
% voltage of its terminal capacitor (mask parameter battery_voltage_init_m, library default).
param.battery.nominal_battery_voltage_1 = 1200;     % [V]
param.battery.nominal_battery_power = 250e3;        % [W]
param.battery.initial_battery_soc = 0.85;
% lithium_ion_battery_setup takes the charge capacity [Ah] as third argument (the legacy init used the old
% four-argument signature, where the library fixed it at 50 Ah): 50 Ah keeps the legacy runs
param.battery.charge_capacity_1 = 50;               % [Ah]

% Kalman sample time of the SOC observer: ts_dab, as the block (ts_battery = glb_time.ts_dab)
b = param.battery;
param.battery.pack_1 = lithium_ion_battery_setup(b.nominal_battery_voltage_1, b.nominal_battery_power, ...
    b.charge_capacity_1, b.initial_battery_soc, param.glb_time.ts_dab);
clear b

% special settings for simulation
param.battery.pack_1.R0 = param.battery.pack_1.R0/2;
param.battery.pack_1.R1 = param.battery.pack_1.R1/2;
param.battery.pack_1.C1 = param.battery.pack_1.C1/200;
%[text] ## Output transformer and load
param.trafo_load.name = 'Load Single Phase Transformer';
param.trafo_load.pwr_nom = 225e3;                   % [W]
param.trafo_load.u1_nom = 400;                      % [V]
param.trafo_load.n1 = 50;
param.trafo_load.n2 = 1;
param.trafo_load.u2_nom = param.trafo_load.u1_nom/param.trafo_load.n1*param.trafo_load.n2;    % [V]
param.trafo_load.f_nom = param.spinv.frequency_set;     % [Hz] alternative: 50
param.trafo_load.eta = 98;                          % [%]
param.trafo_load.ucc = 5;                           % [%]
param.trafo_load.i1m = 10;                          % [A]
param.trafo_load.p_iron = 2e3;                      % [W]

tl = param.trafo_load;
param.trafo_load.output_transformer = single_phase_transformer_setup(tl.name, tl.pwr_nom, tl.u1_nom, ...
    tl.u2_nom, tl.n1, tl.n2, tl.f_nom, tl.eta, tl.ucc, tl.i1m, tl.p_iron);
clear tl

% RL load on the secondary side
param.trafo_load.uload = 6;                         % [V]
param.trafo_load.rload = param.trafo_load.uload / param.trafo_load.output_transformer.i2_nom;     % [Ohm]
param.trafo_load.lload = 250e-6 / param.trafo_load.output_transformer.n12^2;                       % [H]
% param.trafo_load.rload = 0.86/param.trafo_load.output_transformer.n12^2;
% param.trafo_load.lload = 3e-3/param.trafo_load.output_transformer.n12^2;
%[text] ## Sensors end scale and quantization
param.meas.adc_quantization = 1/2^11;
param.meas.adc12_quantization = param.meas.adc_quantization;
param.meas.adc16_quantization = 1/2^15;

param.meas.Imax_adc = 1049.835;             % [A]
param.meas.CurrentQuantization = param.meas.Imax_adc/2^11;

param.meas.Umax_adc = 1500;                 % [V]
param.meas.VoltageQuantization = param.meas.Umax_adc/2^11;
%[text] ## Control settings common to all modules
% local time alignment to master time (phase_compensation_1 of the inverter control)
param.ctrl.kp_align = 0.25;
param.ctrl.ki_align = 18;
param.ctrl.lim_up_align = 0.05;
param.ctrl.lim_down_align = -0.05;

% filters and moving average settings of the commented AFE and grid emulator, PI clip release of the template
% (not read by the active model)
param.ctrl.CTRPIFF_CLIP_RELEASE = 0.001;
param.ctrl.mavarage_filter_frequency_base_order = 2;   % 2 means 100 Hz, 1 means 50 Hz
param.ctrl.dmavg_filter_enable_time = 0.025;           % [s]
param.ctrl.filters = setup_global_filters(param.glb_time.ts_afe, param.glb_time.ts_inv, param.glb_time.ts_dab, param.glb_time.tc);
%[text] ## Thermal model
% aluminium plate, liquid cooled, sized for PrimePACK2; liquid flow > 28 l/min
% "A" (ambient) is the water: HA is the temperature rise from water to heatsink surface;
% water in/out rise max 5 K with 2 kW total losses
param.thermal.weight = 0.150;                                   % [kg]
param.thermal.no_weight = 0.150/10;                             % [kg] /10: thermal inertia not accounted
param.thermal.cp_al = 900;                                      % [J/(kg K)] specific heat, aluminium
param.thermal.heat_capacity_hs = param.thermal.cp_al * param.thermal.weight;   % [J/K]
param.thermal.thermal_conductivity_al = 160;                    % [W/(m K)] aluminium
param.thermal.Rth_switch_HA = 15/1000;                          % [K/W]
param.thermal.Rth_mosfet_HA = param.thermal.Rth_switch_HA;      % [K/W]
param.thermal.Rth_diode_HA = param.thermal.Rth_switch_HA;       % [K/W]
param.thermal.Tambient = 40;                                    % [degC] water temperature
param.thermal.DThs_init = 0;                                    % [K]

t = param.thermal;
param.thermal.heatsink = liquid_cooled_plate_2kw_setup(t.weight, t.no_weight, t.cp_al, t.heat_capacity_hs, ...
    t.thermal_conductivity_al, t.Rth_switch_HA, t.Rth_mosfet_HA, t.Rth_diode_HA, t.Tambient, t.DThs_init);
clear t
%[text] ## Template extras (commented AFE and grid emulator)
if param.sim.build_template_extras
    param = add_template_extras(param);
end
%[text] ## Model setup
open_system(model);
%[text] ### Simscape models from the library
% the .ssc components of the model must be those of the library, not local copies (./private/check_ssc_from_library.m)
check_ssc_from_library(model, param.sim.library_root);
%[text] ### C-Caller types
ctypes = {'mavgflt_output_t', 'dsmavgflt_output_t', 'mavgflts_output_t', 'bemf_obsv_output_t', ...
    'bemf_obsv_load_est_output_t', 'dqvector_pi_output_t', 'sv_pwm_output_t', 'sv_pwm_cm_output_t', ...
    'global_state_machine_output_t', 'first_harmonic_tracker_output_t', 'dqpll_thyr_output_t', ...
    'dqpll_grid_output_t', 'rpi_output_t', 'phase_shift_flt_output_t', 'sogi_flt_output_t', ...
    'linear_double_integrator_observer_output_t'};
for k = 1:numel(ctypes)
    Simulink.importExternalCTypes(model, 'Names', ctypes(k));
end
clear ctypes k
%[text] ### Scopes closed at start
open_scopes = find_system(model, 'BlockType', 'Scope');
for k = 1:numel(open_scopes)
    set_param(open_scopes{k}, 'Open', 'off');
end
clear open_scopes k
%[text] ## Transition: legacy workspace names
% names read by single_phase_ttype_inverter.slx (listed from the .slx on 2026-10-24, library links included)
export_legacy_names = true;
if export_legacy_names
    % model configuration: StopTime = simlength, MaxStep = glb_time.tc, FixedStep = tc (not used, ode23tb);
    % tc and Nc also in power_losses_calculation.m and spectrum.m
    simlength = param.sim.simlength;
    tc = param.glb_time.tc;
    Nc = param.glb_time.Nc;

    % Solver Configuration of battery_1
    nonlinear_iterations = param.sim.nonlinear_iterations;

    % timing: clocks, modulator, control sample times, logging (Nc, Ns_inv, decimation_tc), battery observer
    glb_time = param.glb_time;

    % variant conditions of the inverter control
    system_identification_enable = param.spinv.system_identification_enable;
    frequency_set = param.spinv.frequency_set;
    rpi_enable = param.spinv.rpi_enable;
    use_current_controller_from_ccaller_mod1 = param.spinv.impl.use_current_controller_from_ccaller_mod1;
    use_single_phase_inverter_based_FHT = param.spinv.impl.use_single_phase_inverter_based_FHT;
    use_single_phase_inverter_based_SOGI = param.spinv.impl.use_single_phase_inverter_based_SOGI;
    use_single_phase_inverter_based_PHSH = param.spinv.impl.use_single_phase_inverter_based_PHSH;
    use_single_phase_inverter_based_SOGI_ccaller = param.spinv.impl.use_single_phase_inverter_based_SOGI_ccaller;
    use_single_phase_inverter_based_PHSH_ccaller = param.spinv.impl.use_single_phase_inverter_based_PHSH_ccaller;

    % inverter control: references, current controllers, SOGI, phase generator, time alignment, acquisition
    iph_grid_pu_ref_1 = param.spinv.ref.iph_grid_pu_ref_1;
    iph_grid_pu_ref_2 = param.spinv.ref.iph_grid_pu_ref_2;
    iph_grid_pu_ref_3 = param.spinv.ref.iph_grid_pu_ref_3;
    time_step_ref_1 = param.spinv.ref.time_step_ref_1;
    time_step_ref_2 = param.spinv.ref.time_step_ref_2;
    time_step_ref_3 = param.spinv.ref.time_step_ref_3;
    omega_set = param.spinv.omega_set;
    single_phase_inverter_ctrl = param.spinv.ctrl;
    sogi = param.spinv.sogi;
    kepsilon = param.spinv.kepsilon;
    afe_ctrl = param.afe.ctrl;                  % phase generator: fht_grid
    grid_emu = param.grid.emu;                  % phase generator: fgrid_nom, u2bez
    kp_align = param.ctrl.kp_align;             % mask of .../phase_compensation_1/alignment PI
    ki_align = param.ctrl.ki_align;
    lim_up_align = param.ctrl.lim_up_align;
    lim_down_align = param.ctrl.lim_down_align;
    adc12_quantization = param.meas.adc12_quantization;

    % power stage: DC link and T-type MOSFET bridge (its instance mask reads Tambient, DThs_init and
    % Rth_mosfet_HA directly)
    hwdata.single_phase_inverter = param.spinv.hw;
    mosfet.inv = param.spinv.mosfet;
    heatsink = param.thermal.heatsink;
    Tambient = param.thermal.Tambient;
    DThs_init = param.thermal.DThs_init;
    Rth_mosfet_HA = param.thermal.Rth_mosfet_HA;

    % battery, output transformer and load
    lithium_ion_battery_1 = param.battery.pack_1;
    output_transformer = param.trafo_load.output_transformer;
    rload = param.trafo_load.rload;
    lload = param.trafo_load.lload;

    % commented AFE and grid emulator, when their data are built
    if param.sim.build_template_extras
        hwdata.afe = param.afe.hw;
        frt_data = param.frt.data;
        filters = param.ctrl.filters;
        igbt.afe = param.afe.igbt;
        ideal_switch = param.afe.ideal_switch;  % the ideal-switch AFE bridge reads ideal_switch.* (no .afe)
        adc_quantization = param.meas.adc_quantization;
        afe_pwm_phase_shift_mod1 = param.afe.behav.pwm_phase_shift_mod1;
        dmavg_filter_enable_time = param.ctrl.dmavg_filter_enable_time;
        mavarage_filter_frequency_base_order = param.ctrl.mavarage_filter_frequency_base_order;
        time_aux_power_supply_fault = param.sim.time_aux_power_supply_fault;
        use_dq_pll_mode1 = param.afe.pll.use_dq_pll_mode1;
        use_dq_pll_mode2 = param.afe.pll.use_dq_pll_mode2;
        use_dq_pll_mode3 = param.afe.pll.use_dq_pll_mode3;
        use_dq_pll_mode4 = param.afe.pll.use_dq_pll_mode4;
        use_moving_average_from_ccaller_mod1 = param.afe.impl.use_moving_average_from_ccaller_mod1;
    end
end
%[text] ## Local functions
function param = add_template_extras(param)
% Data of the AFE and of the grid emulator of the shared template, commented out in
% single_phase_ttype_inverter.slx, so that the two subsystems can be uncommented. Enabled by
% param.sim.build_template_extras = true. The grid emulator object (param.grid.emu), the AFE control
% (param.afe.ctrl), the filters (param.ctrl.filters) and the heatsink are already built by the main script.

% ---------------------------------------------------------------- AFE hardware
param.afe.pwr_nom = 250e3;                          % [W]
param.afe.hw = three_phase_afe_hwdata(param.grid.application_voltage, param.afe.pwr_nom, param.glb_time.fPWM_AFE);

% ---------------------------------------------------------------- FRT
param.frt.test_index = 25;                  % type of fault: index
param.frt.test_subindex = 4;                % type of fault: subindex
param.frt.enable_frt_1 = 0;                 % faults generated from abc
param.frt.enable_frt_2 = 0;                 % faults generated from xi_eta_pos and xi_eta_neg
param.frt.start_time_LVRT = 0.75;           % [s]
param.frt.asymmetric_error_type = 1;        % 0: variant C (two-phase), 1: variant D (single-phase)
param.frt.deepPOSxi = 1;
param.frt.deepPOSeta = -0.4;
param.frt.deepNEGxi = 0.4;
param.frt.deepNEGeta = 0.4;

f = param.frt;
param.frt.data = frt_settings(f.test_index, f.test_subindex, f.asymmetric_error_type, ...
    f.enable_frt_1, f.enable_frt_2, f.start_time_LVRT, f.deepPOSxi, f.deepPOSeta, f.deepNEGxi, f.deepNEGeta);

% grid_fault_generator is a function: it returns the fault waveform data (amplitudes, phase shift,
% error_length, end_time_LVRT, t_ramp, k_lvrt, load levels), merged here into param.frt.data
frt_gen = grid_fault_generator(param.frt.data, f.start_time_LVRT);
for fn = fieldnames(frt_gen)'
    param.frt.data.(fn{1}) = frt_gen.(fn{1});
end

% ---------------------------------------------------------------- AFE dqPLL and implementation variants
param.afe.pll.use_dq_pll_fht_pll = 1;
param.afe.pll.use_dq_pll_fht_simulink_pll = 0;
param.afe.pll.use_dq_pll_mod1 = 0;
param.afe.pll.use_dq_pll_ccaller_mod1 = 0;
param.afe.pll.use_dq_pll_ccaller_mod2 = 0;
param.afe.pll.use_dq_pll_mode1 = param.afe.pll.use_dq_pll_mod1;                 % (variant) simulink dqPLL
param.afe.pll.use_dq_pll_mode2 = param.afe.pll.use_dq_pll_ccaller_mod1;         % (variant) ccaller dqPLL
param.afe.pll.use_dq_pll_mode3 = param.afe.pll.use_dq_pll_fht_simulink_pll;     % (variant) fht simulink dqPLL
param.afe.pll.use_dq_pll_mode4 = param.afe.pll.use_dq_pll_fht_pll;              % (variant) fht ccaller dqPLL

param.afe.impl.use_moving_average_from_ccaller_mod1 = 1;                        % (variant)
param.afe.impl.use_moving_average_from_ccaller_mod2 = 0;
param.afe.impl.use_moving_average_from_ccaller_mod3 = 0;
param.afe.impl.use_moving_average_from_ccaller_mod4 = 0;

% ---------------------------------------------------------------- AFE module behaviour
param.afe.behav.pwm_phase_shift_mod1 = 0;
param.afe.behav.white_noise_power_pwm_phase_shift_mod1 = 0.0;

% ---------------------------------------------------------------- AFE devices
dev = param.dev;
param.afe.igbt = device_igbt_setup(dev.used_device_igbt, param.glb_time.fPWM_AFE, param.afe.hw.udc_nom);
param.afe.mosfet = device_mosfet_setup(dev.used_device_mosfet, param.glb_time.fPWM_AFE, param.afe.hw.udc_nom);
param.afe.ideal_switch = device_ideal_switch_setting(dev.used_device_ideal_switch, param.glb_time.fPWM_AFE, param.afe.hw.udc_nom);
end

%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"onright","rightPanelPercent":38.2}
%---
