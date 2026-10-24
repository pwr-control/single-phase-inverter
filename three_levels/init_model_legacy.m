clear;
[model, options] = init_environment('single_phase_ttype_inverter');

CTRPIFF_CLIP_RELEASE = 0.001;
s = tf('s');
%[text] ### Global timing
% simulation length
simlength = 1.25;

fpwm = 20e3;

fpwm_afe = fpwm;
trgo_afe = 0; % double update

fpwm_inv = fpwm;
trgo_inv = 0; % double update

fpwm_single_phase_inv = fpwm;
trgo_single_phase_inv = 0; % double update

fpwm_dab = fpwm;
trgo_dab = 1; % double update

fpwm_psfbc = fpwm;
trgo_psfbc = 1; % double update

fpwm_isop_rail = fpwm;
trgo_isop_rail = 1; % double update

fpwm_cllc = fpwm;
trgo_cllc = 1; % double update

t_measure = simlength;
tc_factor = 100; % tc is ts_afe / tc_factor
tc_decimation = 1;
delay_pwm = 0;

dead_time_afe = 0.3e-6;
dead_time_inv = 0.3e-6;
dead_time_single_phase_inv = 0.3e-6;
dead_time_dab = 2e-6;
dead_time_psfbc = 3e-6;
dead_time_isop_rail = 3e-6;
dead_time_cllc = 2e-6;

glb_time = timing_setup(fpwm_afe, trgo_afe, fpwm_inv, trgo_inv, fpwm_single_phase_inv, trgo_single_phase_inv, fpwm_dab, trgo_dab, ...
    fpwm_psfbc, trgo_psfbc, fpwm_isop_rail, trgo_isop_rail, fpwm_cllc, trgo_cllc, t_measure, tc_factor, tc_decimation, delay_pwm, dead_time_afe, ...
    dead_time_inv, dead_time_single_phase_inv, dead_time_dab, dead_time_psfbc, dead_time_isop_rail, dead_time_cllc);
%[text] ## Settings for simulink model initialization and data analysis
%[text] ### Settings Enable devices with thermal model
use_mosfet_thermal_model = 1;
use_thermal_model = 0;

nonlinear_iterations = 3;  % for simscape solver
if (use_mosfet_thermal_model || use_thermal_model)
    nonlinear_iterations = 5; % for simscape solver
end

%[text] ### Enable specific settings for the simulation
load_step_time = 1.25;
transmission_delay = 125e-6*2;
sst_num_of_modules = 2;
%[text] ### Enable one/two modules
number_of_modules = 1;
enable_two_modules = number_of_modules;
%[text] ### Control Mode Settings
use_torque_curve = 1; 
use_speed_control = 1-use_torque_curve; %
use_mtpa = 1; %
use_psm_encoder = 0; % 
use_im_encoder = 1; % 
use_load_estimator = 0; %
use_estimator_from_mb = 0; % mb model based
use_motor_speed_control_mode = 0; 

% advanced dqPLL
use_dq_pll_fht_pll = 1; % 
use_dq_pll_fht_simulink_pll = 0; % 
use_dq_pll_mod1 = 0; % 
use_dq_pll_ccaller_mod1 = 0; % 
use_dq_pll_ccaller_mod2 = 0; % 

% dqPLL
use_dq_pll_mode1 = use_dq_pll_mod1;
use_dq_pll_mode2 = use_dq_pll_ccaller_mod1;
use_dq_pll_mode3 = use_dq_pll_fht_simulink_pll;
use_dq_pll_mode4 = use_dq_pll_fht_pll;

use_dq_pll_mode1_modn = 0; % simulink dqPLL
use_dq_pll_mode2_modn = 0; % ccaller dqPLL
use_dq_pll_mode3_modn = 1; % fht simulink dqPLL
use_dq_pll_mode4_modn = 0; % fht ccaller dqPLL

% single phase inverter
rpi_enable = 0; % use RPI otherwise DQ PI
system_identification_enable = 0;
use_current_controller_from_ccaller_mod1 = 1;
use_phase_shift_filter_from_ccaller_mod1 = 1;
use_sogi_from_ccaller_mod1 = 1;

% four modules in parallel connected to a dc microgrid
ixi_ref_mod1 = -0.85;
ixi_ref_mod2 = -0.85;
ixi_ref_mod3 = -0.85;
ixi_ref_mod4 = -0.85;

% common mode voltage control for hard parallelization
en_parallel_mode = 1;
   u_cm_comp_mod1 = 0;
   u_cm_comp_mod2 = 0;
   u_cm_comp_mod3 = 0;
   u_cm_comp_mod4 = 0;

if en_parallel_mode
   u_cm_comp_mod2 = -1;
   u_cm_comp_mod3 = -1;
   u_cm_comp_mod4 = -1;
end
%[text] ### Settings for CCcaller versus Simulink
use_ekf_bemf_module_1 = 1;
use_ekf_bemf_module_2 = 1;
use_observer_from_simulink_module_1 = 0;
use_observer_from_ccaller_module_1 = 0;
use_observer_from_simulink_module_2 = 0;
use_observer_from_ccaller_module_2 = 0;

% current controllers
use_current_controller_from_simulink_module_1 = 0;
use_current_controller_from_ccaller_module_1 = 1;
use_current_controller_from_simulink_module_2 = 0;
use_current_controller_from_ccaller_module_2 = 0;

% moving average filters
use_moving_average_from_ccaller_mod1 = 1;
use_moving_average_from_ccaller_mod2 = 0;
use_moving_average_from_ccaller_mod3 = 0;
use_moving_average_from_ccaller_mod4 = 0;

use_single_phase_inverter_based_FHT = 1;
use_single_phase_inverter_based_SOGI = 0;
use_single_phase_inverter_based_PHSH = 0;
use_single_phase_inverter_based_SOGI_ccaller = 0;
use_single_phase_inverter_based_PHSH_ccaller = 0;

use_system_identification_based_FHT = 0;
use_system_identification_based_SOGI = 0;
use_system_identification_based_PHSH = 0;
use_system_identification_based_SOGI_ccaller = 0;
use_system_identification_based_PHSH_ccaller = 1;


%[text] ### Single phase inverter control
iph_grid_pu_ref_1 = 1/3;
iph_grid_pu_ref_2 = 1/3.;
iph_grid_pu_ref_3 = 1/3;
time_step_ref_1 = 0.025;
time_step_ref_2 = 0.5;
time_step_ref_3 = 1;
%[text] ### Setting global behavioural (system identification versus normal functioning) and operative frequency
frequency_set = 400; % default
if system_identification_enable
    frequency_set = 300;
end
omega_set = frequency_set*2*pi;
%[text] ### Settings average filters
mavarage_filter_frequency_base_order = 2; % 2 means 100Hz, 1 means 50Hz
dmavg_filter_enable_time = 0.025;
%%
%[text] ### Grid Emulator Settings
grid_nominal_power = 1000e3;
application_voltage = 690;
grid_nominal_current = grid_nominal_power/application_voltage/sqrt(3);

% Transformer Dyn11
delta_star = 1;

if application_voltage == 690
    % trafo data
    us1 = 690; us2 = 690; fgrid = 50;
    eta = 95; ucc = 5;
    p_iron = 1800;
elseif application_voltage == 480
    % trafo data
    us1 = 480; us2 = 480; fgrid = 60;
    eta = 95; ucc = 5;
    p_iron = 1400;
else
    % trafo data
    us1 = 400; us2 = 400; fgrid = 50;
    eta = 95; ucc = 5;
    p_iron = 1000;
end

n2 = 14; n1 = floor(n2*sqrt(3));
core_area = 0.05; core_length = 2.5;
mu0 = 4*pi*1e-7; mur = 10e3;

% two simple calculation:
Lm1 = (n1^2 * mu0 * mur * core_area) / core_length;
% Lm1 = u1_nom/sqrt(3)/i1m/(2*pi*fgrid);
i1m = us1/sqrt(3)/Lm1/(2*pi*fgrid);

% reference for the voltage sequence
up_xi_pu_ref = 1; up_eta_pu_ref = 0; un_xi_pu_ref = 0; un_eta_pu_ref = 0;

% grid impedance
Lgrid_base = us1/sqrt(3)*ucc/100/2/pi/fgrid/grid_nominal_current;
if ~exist('ucc_factor', 'var')
    ucc_factor = 1;
end
eq_grid_inductance = Lgrid_base*ucc_factor; % [H]
eq_grid_resistance = 2e-3; % [Ohm]

grid_emu = grid_three_phase_emulator('Dyn11', delta_star, grid_nominal_power, application_voltage, us1, us2, fgrid, ...
                eq_grid_inductance, eq_grid_resistance, eta, ucc, i1m, p_iron, n1, n2, core_area, core_length, mur, ...
                up_xi_pu_ref, up_eta_pu_ref, un_xi_pu_ref, un_eta_pu_ref);
%[text] ## Global Hardware Settings
%[text] ### Rail Catenary Voltage Model
catenary_nominal_power = 2*5.4e6; % per 12km
catenary_nominal_voltage = 3000;
catenary_maximum_voltage = 4000;
catenary_nominal_current = catenary_nominal_power/catenary_nominal_voltage;

isop_rail_pwr_nom = 250e3; % nominal per system
number_of_systems = 4;
full_bridge_application_voltage = catenary_maximum_voltage/number_of_systems;
hwdata.isop_rail = isop_rail_aux_application(full_bridge_application_voltage, isop_rail_pwr_nom, glb_time.fPWM_ISOP_RAIL);
%[text] ### Hardware Settings
single_phase_inverter_pwr_nom = 225e3;
afe_pwr_nom = 250e3;
inv_pwr_nom = 250e3;
dab_pwr_nom = 250e3;
three_phase_dab_pwr_nom = 3*dab_pwr_nom;
cllc_pwr_nom = 250e3;
psfbc_pwr_nom = 275e3;
fres_dab = glb_time.fPWM_DAB/5;
fres_cllc = glb_time.fPWM_CLLC*1.2;

hwdata.single_phase_inverter = single_phase_inverter_hwdata(application_voltage, single_phase_inverter_pwr_nom, glb_time.fPWM_INV);
hwdata.afe = three_phase_afe_hwdata(application_voltage, afe_pwr_nom, glb_time.fPWM_AFE); %[output:958d272c]
hwdata.inv = three_phase_inverter_hwdata(application_voltage, inv_pwr_nom, glb_time.fPWM_INV); %[output:805d0cf1]
hwdata.dab = single_phase_dab_hwdata(application_voltage, dab_pwr_nom, glb_time.fPWM_DAB, fres_dab); %[output:4b12cb57]
hwdata.psfbc = single_phase_psfbc_hwdata(application_voltage, psfbc_pwr_nom, glb_time.fPWM_PSFBC); %[output:8d186aac]
hwdata.three_phase_dab = three_phase_dab_hwdata(application_voltage, three_phase_dab_pwr_nom, glb_time.fPWM_DAB, fres_dab); %[output:83e1a8be]
hwdata.cllc = single_phase_cllc_hwdata(application_voltage, dab_pwr_nom, glb_time.fPWM_CLLC, fres_cllc); %[output:380f1c08]

% modifications
% hwdata.afe.CFi = 2 * hwdata.psfbc.Cdc_dc1;
%[text] ### Sensors endscale, and quantization
adc_quantization = 1/2^11;
adc12_quantization = adc_quantization;
adc16_quantization = 1/2^15;

Imax_adc = 1049.835;
CurrentQuantization = Imax_adc/2^11;

Umax_adc = 1500;
VoltageQuantization = Umax_adc/2^11;
%[text] ## AFE Settings and Initialization
%[text] ### Behavioural Settings

time_gain_afe_module_1 = 1.0002;
time_gain_afe_module_2 = 1.0015;
time_gain_afe_module_3 = 0.9988;
time_gain_afe_module_4 = 1.0020;

time_gain_inv_module_1 = 1.0005;
time_gain_inv_module_2 = 1.001;
wnp = 0;
white_noise_power_afe_mod1 = wnp;
white_noise_power_inv_mod1 = wnp;
white_noise_power_afe_mod2 = wnp;
white_noise_power_inv_mod2 = wnp;

trgo_th_generator = 0.025;

afe_pwm_phase_shift_mod1 = 0;
white_noise_power_afe_pwm_phase_shift_mod1 = 0.0;
inv_pwm_phase_shift_mod1 = 0;
white_noise_power_inv_pwm_phase_shift_mod1 = 0.0;

afe_pwm_phase_shift_mod2 = 0;
white_noise_power_afe_pwm_phase_shift_mod2 = 0.0;
inv_pwm_phase_shift_mod2 = 0;
white_noise_power_inv_pwm_phase_shift_mod2 = 0.0;

afe_pwm_phase_shift_mod3 = 0;
white_noise_power_afe_pwm_phase_shift_mod3 = 0.0;
inv_pwm_phase_shift_mod3 = 0;
white_noise_power_inv_pwm_phase_shift_mod3 = 0.0;

afe_pwm_phase_shift_mod4 = 0;
white_noise_power_afe_pwm_phase_shift_mod4 = 0.0;
inv_pwm_phase_shift_mod4 = 0;
white_noise_power_inv_pwm_phase_shift_mod4 = 0.0;
%[text] ### FRT Settings
test_index = 25; % type of fault: index
test_subindex = 4; % type of fault: subindex
% test_subindex = 1; % type of fault: subindex
enable_frt_1 = 0; % faults generated from abc
enable_frt_2 = 0; % faults generated from xi_eta_pos and xi_eta_neg
start_time_LVRT = 0.75;
asymmetric_error_type = 1;
deepPOSxi = 1;
deepPOSeta = -0.4;
deepNEGxi = 0.4;
deepNEGeta = 0.4;
frt_data = frt_settings(test_index, test_subindex, asymmetric_error_type, ...
    enable_frt_1, enable_frt_2, start_time_LVRT, deepPOSxi, deepPOSeta, deepNEGxi, deepNEGeta);
grid_fault_generator;
%[text] ### Reactive Current References Settings
% reactive current references 
enable_i_react_pos_steps = 1;
    time_i_react_pos_ref_1 = 0; % default
    time_i_react_pos_ref_2 = 0; % default
    i_react_pos_ref_1 = 0; % default
    i_react_pos_ref_2 = 0; % default
    i_react_pos_ref_3 = 0; % default

if enable_i_react_pos_steps
    time_i_react_pos_ref_1 = start_time_LVRT + error_length + 0.335;
    time_i_react_pos_ref_2 = time_i_react_pos_ref_1 + 0.5;
    i_react_pos_ref_2 = -ixi_ref_mod1*tan(acos(0.95));  % cos(phi) = 0.9
    i_react_pos_ref_3 = ixi_ref_mod1*tan(acos(0.95)); % cos(phi) = 0.9
end
%[text] #### UPQC Series Transformer
name = 'UPQC Series Transformer';
pwr_nom = 3*125e3;
u1_nom = 400;
u2_nom = 690;
f_nom = 50;
eta = 98;
ucc = 4;
p_iron = 5e3;
n12 = u1_nom/u2_nom;
n2 = 8;
n1 = n12*n2;
core_area = 0.04;
core_length = 0.25;
mur = 35e3;

Lm1 = (n1^2 * mu0 * mur * core_area) / core_length;
i1m = u1_nom/sqrt(3)/Lm1/f_nom/2/pi;

delta_star = 0;

upqc_st = three_phase_transformer_setup(name, delta_star, pwr_nom, u1_nom, u2_nom, f_nom, eta, ucc, ...
    i1m, p_iron, n1, n2, core_area, core_length, mur);
upqc_st.Lm1;
upqc_st.Ld1;
upqc_ctrl.kp_p = 1;
upqc_ctrl.ki_p = 35;
upqc_ctrl.kp_n = 1;
upqc_ctrl.ki_n = 35;
upqc_ctrl.lim = 4;
%[text] #### DClink Lstray model (partial loop inductance)
parasitic_dclink_data; %[output:44a127a7]
%%
%[text] ## INVERTER Settings and Initialization
%[text] ### Mode of operation
motor_torque_mode = 1 - use_motor_speed_control_mode; % system uses torque curve for wind application
time_start_motor_control = 0.25;
%[text] ### IM Machine settings
im = im_calculus(); %[output:9976d829]
%[text] ### PSM Machine settings
psm = psm_calculus(); %[output:6a96aee0]
n_sys = psm.number_of_systems;

% load
b = psm.load_friction_m;
% external_load_inertia = 6*psm.Jm_m;
external_load_inertia = 1;
%[text] ### Motor Voltage to Udc Scaling
u_psm_scale = 2/3*hwdata.inv.udc_nom/psm.ubez;
u_im_scale = 2/3*hwdata.inv.udc_nom/im.ubez;

u_psm_scale_ekf = sqrt(3)/2 * 2/3 * hwdata.inv.udc_nom/psm.ubez;
u_im_scale_ekf = (2/3)^2 * hwdata.inv.udc_nom/im.ubez;
%[text] ## **CONTROL Settings and Initialization**
%[text] #### Permanent magnet synchronous motor control with EKF based observer
psm_ctrl = ctrl_pmsm_setup(glb_time.ts_inv, psm.omega_bez, u_psm_scale, psm.Jm_norm);
% psm_ctrl.ekf = ekf_pmsm_setup(psm.Rs_norm, psm.Ls_norm, psm.Jm_norm, glb_time.ts_inv);
psm_ctrl.ekf = ekf_pmsm_setup(psm.Rs_norm, psm.Ls_norm, 1e6, glb_time.ts_inv); %[output:017a5236]
psm_ctrl.kp_i = 0.25;
psm_ctrl.ki_i = 35;
%[text] #### Induction Motor Control
im_ctrl = ctrl_im_setup(glb_time.ts_inv, im.omega_bez, u_im_scale, im.Jm_norm);
im_ctrl.ekf = ekf_im_setup(im.alpha_norm, im.beta_norm, im.gamma_norm, im.sigma_norm, ... %[output:group:8e7b7d9f] %[output:58bfa75a]
        im.mu_norm, im.Lm_norm, im.Jm_norm, glb_time.ts_inv); %[output:group:8e7b7d9f] %[output:58bfa75a]
%[text] #### AFE control (with sequences)
afe_ctrl = ctrl_afe_setup(glb_time.ts_afe, grid_emu.omega_grid_nom);

afe_ctrl.kp_udc_ctrl = 2;

kp_udc = 0.5;
ki_udc = 18.0;
kp_idc = 0.5;
ki_idc = 18.0;

%% gain for weak grids
% afe_ctrl.res_pi.kp_rpi = 0.5;
% afe_ctrl.res_pi.ki_rpi = 18;

%% gains for LVRT
afe_ctrl.res_pi.kp_rpi = 0.6;
afe_ctrl.res_pi.ki_rpi = 35;

%[text] #### DCDC Control
dab_ctrl = ctrl_dab_setup(kp_udc, ki_udc, kp_idc, ki_idc);
psfbc_ctrl = ctrl_dab_setup(kp_udc, ki_udc, kp_idc, ki_idc);
cllc_ctrl = ctrl_cllc_setup(kp_udc, ki_udc, kp_idc, ki_idc);

% special settings
psfbc_ctrl.kp_idc = 1;
dab_ctrl.ki_udc = 35;

isop_rail_ctrl = ctrl_isop_rail_setup(kp_udc, ki_udc, kp_idc, ki_idc);
dab_ctrl.kp_idc = 0.02;
dab_ctrl.ki_idc = 1.0;
%[text] ### 
%[text] #### Resonant PI settings
pres_ctrl.kp_rpi = 0.75;
pres_ctrl.ki_rpi = 45;
pres_ctrl.delta_rpi = 0.025;
pres_ctrl.omega_set = omega_set;
pres_ctrl.res_nom = s/(s^2 + 2*pres_ctrl.delta_rpi*pres_ctrl.omega_set*s + (pres_ctrl.omega_set)^2);

pres_ctrl.Ares_nom = [0 1; -omega_set^2 -2*pres_ctrl.delta_rpi*pres_ctrl.omega_set];
pres_ctrl.Aresd_nom = eye(2) + pres_ctrl.Ares_nom*glb_time.ts_inv;
pres_ctrl.a11d = 1;
pres_ctrl.a12d = glb_time.ts_inv;
pres_ctrl.a21d = -pres_ctrl.omega_set^2*glb_time.ts_inv;
apres_ctrl.a22d = 1 -2*pres_ctrl.delta_rpi*pres_ctrl.omega_set*glb_time.ts_inv;

pres_ctrl.Bres = [0; 1];
pres_ctrl.Cres = [0 1];
pres_ctrl.Bresd = pres_ctrl.Bres*glb_time.ts_inv;
pres_ctrl.Cresd = pres_ctrl.Cres;
%[text] #### SOGI (second order generalized integrator)
sogi_delta = 1;
kepsilon = 2;
sogi = sogi_filter(omega_set, sogi_delta, kepsilon, glb_time.ts_afe); %[output:188162c1]
%[text] #### Current control parameters DQ PI
dqvector_pi.kp_inv = 0.5;
dqvector_pi.ki_inv = 45;
dqvector_pi.pi_ctrl = dqvector_pi.kp_inv + dqvector_pi.ki_inv/s;
dqvector_pi.pid_ctrl = c2d(dqvector_pi.pi_ctrl, glb_time.ts_inv);
dqvector_pi.plant = 1/(s*grid_emu.trafo.Ld1 + 1);
dqvector_pi.plantd = c2d(dqvector_pi.plant, glb_time.ts_inv);

G = sogi.fltd.alpha * dqvector_pi.pid_ctrl * dqvector_pi.plantd;
figure; margin(G, options);  %[output:334715cf]
grid on %[output:334715cf]
%[text] #### Single phase inverter - with resonant PI and virtual DQ
single_phase_inverter_ctrl = ctrl_single_phase_inverter_setup(glb_time.ts_inv, pres_ctrl.omega_set, ...
    dqvector_pi.kp_inv, dqvector_pi.ki_inv, pres_ctrl.kp_rpi, pres_ctrl.ki_rpi, pres_ctrl.delta_rpi);
%[text] #### 
%[text] ### Local time alignment to master time
kp_align = 0.25;
ki_align = 18;
lim_up_align = 0.05;
lim_down_align = -0.05;
%[text] ### Simulation parameters: speed reference, load torque for energy production application
run('n_sys_generic_1M5W_torque_curve');
torque_overload_factor = 1;
%[text] ### Simulation parameters: speed reference, load torque for driver application
% rpm_sim = 3000;
rpm_sim = 17.8;
% rpm_sim = 15.2;
omega_m_sim = psm.omega_m_bez;
omega_sim = omega_m_sim*psm.number_poles/2;
tau_load_sim = psm.tau_bez/5; %N*m
b_square = 0;
%[text] ### Settings Global Filters
filters = setup_global_filters(glb_time.ts_afe, glb_time.ts_inv, glb_time.ts_dab, glb_time.tc);
%[text] ## Power semiconductors modelization, IGBT, MOSFET,  and snubber data
%[text] ### Diode rectifier
% ABB 5SDF 0131Z0401 (slow recovery)
diode.rectifier.Vf = 0.977;
diode.rectifier.Rdon = 22e-6;
diode.rectifier.Cj = 0;             % F
diode.rectifier.Irm = -75;          % A
diode.rectifier.didt = -30;         % A/us
diode.rectifier.trr = 5;            % us
diode.rectifier.Qrr = 325e-6;       % C
diode.rectifier.Ifm = 2000;         % A
diode.rectifier.Vr = -50;           % V
diode.rectifier.Err = 15e-3;        % J
diode.rectifier.Rth_JC = 0.004;     % W/K
diode.rectifier.Rth_CH = 0.003;     % W/K

diode.rectifier.Rsnubber = 1e4;     % Ohm
diode.rectifier.Csnubber = 1e-12;     % F
%[text] ### HeatSink settings
% Aluminum plate liquid cooled with a size fit for primepack2
% heat exchange made by an aluminum plate with a liquid flow > 28 l/min
% "A" as "ambient" here means water: so HA means delta temperature between water and
% heatsink surface
% moreover the delta temperature between water in and water out is maximum
% 5K assuming a overall power losses of 2kW 

weight = 0.150;                         % kg
no_weight = 0.150/10;                   % kg - when /10 is applied thermal inertia is not accounted 
cp_al = 900;                            % specific heat_capacity J/K/kg - aluminum
heat_capacity_hs = cp_al * weight;      % J/K
thermal_conductivity_al = 160;          % W/(m K) - aluminum
Rth_switch_HA = 15/1000;                % K/W 
Rth_mosfet_HA = Rth_switch_HA;          % K/W
Rth_diode_HA = Rth_switch_HA;           % K/W
Tambient = 40;                          % degC - water temperature
DThs_init = 0;                          % degC

heatsink = liquid_cooled_plate_2kw_setup(weight, no_weight, cp_al, heat_capacity_hs, thermal_conductivity_al, ...
    Rth_switch_HA, Rth_mosfet_HA, Rth_diode_HA, Tambient, DThs_init);
%[text] ### DEVICES settings (IGBT)
used_device = 'mitsubishi_CM1200DW_24T';

igbt.inv = device_igbt_setup(used_device, glb_time.fPWM_INV, hwdata.inv.udc_nom);
igbt.afe = device_igbt_setup(used_device, glb_time.fPWM_AFE, hwdata.afe.udc_nom);
igbt.dab = device_igbt_setup(used_device, glb_time.fPWM_DAB, hwdata.dab.udc1_nom);
igbt.psfbc = device_igbt_setup(used_device, glb_time.fPWM_PSFBC, hwdata.psfbc.udc1_nom);
igbt.cllc = device_igbt_setup(used_device, glb_time.fPWM_CLLC, hwdata.cllc.udc1_nom);
igbt.isop_rail = device_igbt_setup(used_device, glb_time.fPWM_ISOP_RAIL, hwdata.isop_rail.udc1_nom);

%[text] ### DEVICES settings (MOSFET)
used_device = 'danfoss_SKM1700MB20R4S2I4';

mosfet.inv = device_mosfet_setup(used_device, glb_time.fPWM_INV, hwdata.inv.udc_nom);
mosfet.afe = device_mosfet_setup(used_device, glb_time.fPWM_AFE, hwdata.afe.udc_nom);
mosfet.dab = device_mosfet_setup(used_device, glb_time.fPWM_DAB, hwdata.dab.udc1_nom);
mosfet.psfbc = device_mosfet_setup(used_device, glb_time.fPWM_PSFBC, hwdata.psfbc.udc1_nom);
mosfet.cllc = device_mosfet_setup(used_device, glb_time.fPWM_CLLC, hwdata.cllc.udc1_nom);
mosfet.isop_rail = device_mosfet_setup(used_device, glb_time.fPWM_ISOP_RAIL, hwdata.isop_rail.udc1_nom);
%[text] ### 
%[text] ### DEVICES settings (Ideal switch)
used_device = 'silicon_high_power_ideal_switch';
ideal_switch = device_ideal_switch_setting(used_device, glb_time.fPWM_AFE, hwdata.afe.udc_nom);
ideal_switch.afe = device_ideal_switch_setting(used_device, glb_time.fPWM_AFE, hwdata.afe.udc_nom);
ideal_switch.inv = device_ideal_switch_setting(used_device, glb_time.fPWM_INV, hwdata.inv.udc_nom);
ideal_switch.dab = device_ideal_switch_setting(used_device, glb_time.fPWM_DAB, hwdata.dab.udc1_nom);
ideal_switch.psfbc = device_ideal_switch_setting(used_device, glb_time.fPWM_PSFBC, hwdata.psfbc.udc1_nom);
ideal_switch.cllc = device_ideal_switch_setting(used_device, glb_time.fPWM_CLLC, hwdata.cllc.udc1_nom);
ideal_switch.isop_rail = device_ideal_switch_setting(used_device, glb_time.fPWM_ISOP_RAIL, hwdata.isop_rail.udc1_nom);
%[text] ### 
%[text] ### Setting Global Faults
time_aux_power_supply_fault = 1e3;
%[text] ### Lithium Ion Battery
% nominal_battery_voltage_1 = hwdata.cllc.udc1_bez;
nominal_battery_voltage_1 = hwdata.dab.udc1_bez;
% nominal_battery_voltage_1 = hwdata.afe.udc_nom;
% nominal_battery_voltage_2 = hwdata.cllc.udc2_bez;
nominal_battery_voltage_2 = hwdata.dab.udc2_bez;
% nominal_battery_voltage_2 = hwdata.afe.udc_nom;
nominal_battery_power = 250e3;

% nominal_battery_voltage_1 = catenary_nominal_voltage * 1.5;
% nominal_battery_voltage_2 = catenary_nominal_voltage * 1.5;
% nominal_battery_power = catenary_nominal_power;

initial_battery_soc = 0.85;
lithium_ion_battery_1 = lithium_ion_battery_setup(nominal_battery_voltage_1, nominal_battery_power, initial_battery_soc, glb_time.ts_dab); %[output:18005571]
lithium_ion_battery_2 = lithium_ion_battery_setup(nominal_battery_voltage_2, nominal_battery_power, initial_battery_soc, glb_time.ts_dab); %[output:9783d4fc]

% special settings for simulation
lithium_ion_battery_1.R0 = lithium_ion_battery_1.R0/2;
lithium_ion_battery_1.R1 = lithium_ion_battery_1.R1/2;
lithium_ion_battery_2.R0 = lithium_ion_battery_2.R0/2;
lithium_ion_battery_2.R1 = lithium_ion_battery_2.R1/2;
lithium_ion_battery_1.C1 = lithium_ion_battery_1.C1/200;
lithium_ion_battery_2.C1 = lithium_ion_battery_2.C1/200;

%[text] ### Setting for Load Transformer
% special settings
trafo_load_name = 'Load Single Phase Transformer';
trafo_load_pwr_nom = 225e3;
trafo_load_u1_nom = 400;
trafo_load_n1 = 50;
trafo_load_n2 = 1;
trafo_load_u2_nom = trafo_load_u1_nom/trafo_load_n1*trafo_load_n2;
% trafo_load_f_nom = 50;
trafo_load_f_nom = frequency_set;
trafo_load_eta = 98;
trafo_load_ucc = 5;
trafo_load_i1m = 10;
trafo_load_p_iron = 2e3;

output_transformer = single_phase_transformer_setup(trafo_load_name, trafo_load_pwr_nom, trafo_load_u1_nom, ...
    trafo_load_u2_nom, trafo_load_n1, trafo_load_n2, trafo_load_f_nom, trafo_load_eta, trafo_load_ucc, ...
    trafo_load_i1m, trafo_load_p_iron);

uload = 6;
rload = uload / output_transformer.i2_nom;
lload = 250e-6 / output_transformer.n12^2;

% rload = 0.86/m12_load_trafo^2;
% lload = 3e-3/m12_load_trafo^2;
%[text] ### C-Caller Settings
open_system(model);
Simulink.importExternalCTypes(model,'Names',{'mavgflt_output_t'});
Simulink.importExternalCTypes(model,'Names',{'dsmavgflt_output_t'});
Simulink.importExternalCTypes(model,'Names',{'mavgflts_output_t'});
Simulink.importExternalCTypes(model,'Names',{'bemf_obsv_output_t'});
Simulink.importExternalCTypes(model,'Names',{'bemf_obsv_load_est_output_t'});
Simulink.importExternalCTypes(model,'Names',{'dqvector_pi_output_t'});
Simulink.importExternalCTypes(model,'Names',{'sv_pwm_output_t'});
Simulink.importExternalCTypes(model,'Names',{'sv_pwm_cm_output_t'});
Simulink.importExternalCTypes(model,'Names',{'global_state_machine_output_t'});
Simulink.importExternalCTypes(model,'Names',{'first_harmonic_tracker_output_t'});
Simulink.importExternalCTypes(model,'Names',{'dqpll_thyr_output_t'});
Simulink.importExternalCTypes(model,'Names',{'dqpll_grid_output_t'});
Simulink.importExternalCTypes(model,'Names',{'rpi_output_t'});
Simulink.importExternalCTypes(model,'Names',{'phase_shift_flt_output_t'});
Simulink.importExternalCTypes(model,'Names',{'sogi_flt_output_t'});
Simulink.importExternalCTypes(model,'Names',{'linear_double_integrator_observer_output_t'});

%[text] ### **Remove Scopes Opening Automatically**
open_scopes = find_system(model, 'BlockType', 'Scope');
for i = 1:length(open_scopes)
    set_param(open_scopes{i}, 'Open', 'off');
end

%[text] ### Enable/Disable Subsystems



%[appendix]{"version":"1.0"}
%---
%[metadata:view]
%   data: {"layout":"onright","rightPanelPercent":38.2}
%---
%[output:958d272c]
%   data: {"dataType":"text","outputData":{"text":"Device AFE_THREE_PHASE: afe690V\nNominal Voltage: 690 V | Nominal Current: 2.324276e+02 A\nCurrent Normalization Data: 328.70 A\nVoltage Normalization Data: 563.38 V\n---------------------------\n","truncated":false}}
%---
%[output:805d0cf1]
%   data: {"dataType":"text","outputData":{"text":"Device INVERTER: inv690V_250kW\nNominal Voltage: 550 V | Nominal Current: 370 A\nCurrent Normalization Data: 523.26 A\nVoltage Normalization Data: 449.07 V\n---------------------------\n","truncated":false}}
%---
%[output:4b12cb57]
%   data: {"dataType":"text","outputData":{"text":"Single Phase DAB: DAB_1200V\nNominal Power: 250000 [W]\nNormalization Voltage DC1: 1200 [V] | Normalization Current DC1: 250 [A]\nNormalization Voltage DC2: 1200 [V] | Normalization Current DC2: 250 [A]\nInternal Tank Ls: 2.291831e-05 [H] | Internal Tank Cs: 6.907767e-05 [F]\n---------------------------\n","truncated":false}}
%---
%[output:8d186aac]
%   data: {"dataType":"text","outputData":{"text":"Single Phase PSFBC: PSFBC_1200V\nNominal Power: 275000 [W]\nNormalization Voltage DC1: 1200 [V] | Normalization Current DC1: 250 [A]\nNormalization Voltage DC2: 1200 [V] | Normalization Current DC2: 250 [A]\nInternal Tank Ls1: 6.060606e-06 [H] | Internal Tank Ls2: 6.060606e-06 [H]\n---------------------------\n","truncated":false}}
%---
%[output:83e1a8be]
%   data: {"dataType":"text","outputData":{"text":"Single Phase DAB: Three_phase_DAB_1200V\nNominal Power: 750000 [W]\nNormalization Voltage DC1: 1200 [V] | Normalization Current DC1: 750 [A]\nNormalization Voltage DC2: 1200 [V] | Normalization Current DC2: 750 [A]\nInternal Tank Ls: 2.400000e-05 [H] | Internal Tank Cs: 750 [F]\n---------------------------\n","truncated":false}}
%---
%[output:380f1c08]
%   data: {"dataType":"text","outputData":{"text":"Single Phase CLLC: CLLC_1200V\nNominal Power: 250000 [W]\nNormalization Voltage DC1: 1200 [V] | Normalization Current DC1: 250 [A]\nNormalization Voltage DC2: 1200 [V] | Normalization Current DC2: 250 [A]\nInternal Tank Ls: 1.548074e-05 [H] | Internal Tank Cs: 2.840705e-06 [F]\n---------------------------\n","truncated":false}}
%---
%[output:44a127a7]
%   data: {"dataType":"image","outputData":{"dataUri":"data:image\/png;base64,iVBORw0KGgoAAAANSUhEUgAAAS0AAAC1CAYAAAAKoal0AAAQAElEQVR4AeydCbyNVffH11MqlTJnykxRCaFMZUgZyhARDZRemd56pZfbjCKhpEJIRKLwT3gpZSwlyhSlkDEhZYq6kvzvd9dzO45z7r3n3vMM55zlY51n2s8efvuc31177bXXPuOk\/lMEFAFFIIYQOEP0nyKgCCgCMYSAklYMdZZWVRFQBESUtOL8W6DNUwTiDQElrXjrUW2PIhDnCChpxXkHa\/MUgXhDQEkr3npU25NYCCRga5W0ErDTtcmKQCwjoKQVy72ndVcEEhABJa0E7HRtsiIQywgkFmnFck9p3RUBRcAgoKRlYNAPRUARiBUElLRipae0noqAImAQUNIyMOhHMALr1q2Ta665Rq699lq57rrrpEqVKtK2bVv54YcfgpOGvR41apTMnz8\/7PPAB6QrV67cKeU99dRTcuTIETl69Kg8+uijsmHDhsBXQpzrrURAQEkrEXo5k22sVKmSvPfee\/LRRx\/JihUrpHTp0uY6k9ml+9pVV11l8qe8pUuXmvTPPvusnHPOOfLMM89I+fLlzb3MfJw8eVJOnDiRmVf1HZ8hoKTlsw7xa3V+\/\/13OXz4sFx00UVy\/PhxGTx4sNHE0MY45x4yaNAgqVatmtxwww2yatUq0xwIY9KkSUZjq127ttgalHkY5uPcc8+Vu+++W7766ivZtGmTdO7cWdD+fvnlF+nZs6dUr15drr76annuuedMfbj\/wAMPmHt33nmndOrUyaRH2+vWrZs0bdpUli1bJosWLTL1qFmzptx8882yfv16+fHHH6VVq1bSp08foX5olBMnTpT69eub\/BYuXBimlnrbCwSUtLxAPUbK\/Oyzz+TKK6+UUqVKyeWXXy779u0zP\/j3339fdu7cKWhDyP79++Wdd94R7n\/\/\/fdGM+MakqOppGFot2DBAvn444\/l\/PPPl5kzZ\/IoTcmTJ4\/ky5dPICQ74fLly6VMmTKGgCjv22+\/ld27d8trr71mNDGeo5399NNP9itC\/aZMmWLa8sEHHwgE+umnnxpSJA8SHjp0SKpWrWrqV7hwYSHfDz\/8UIYMGWLq+scff5BMxVsETOlKWgYG\/QiFANrMl19+KVu2bDHaDlrIk08+KZ988ok0adJEzjrrLCMNGjSQzz\/\/XJYsWWLuoyVdcMEFRmshX4gE0rj00kvNEHPEiBGyevVqHkUs9erVM3avqVOnmiEjZLh3717ZuHGjoD1ZliVFihSRChUqpOZdt25doT4XXnih9O7d26R94YUX5M0335Q9e\/aYdGiQaI2WZckZZ5xh6n7mmWcKxJmcnCyI6D9fIKCk5Ytu8H8l+AHXqVPH\/Hh\/++03Q1Z2rRkWQmD2dfARQzpkAfkhEE3fvn2Dk512jYaEloW2ZT8cN26cjB49WiDABx980GiADD+xV0E2pOOc4SzngcIkQteuXQUtrE2bNnLfffcFPj7lPK32nJJQL1xHQEnLdchjs0CIgWFe9uzZjS2L2T7ICpk7d67RcrBlcc69AwcOCMNBWovtieEYBAThYTtimMizcEK6V155RS677DJjR7PTMWy76aabhEkCSAgCRLNjSEf9qOf27dsFDdF+xz7+\/PPPRuPCloUGZdfPfq7H2EBASSs2+ikztczyO2vWrJHGjRsbO1aNGjXMsDApKUlat25thk0MF5GiRYtKo0aNpFmzZuY+w7SOHTtKoUKFTB0YPkJoHBmqQRicm4cBHxju7fLIFzLC6B6QxJTdv39\/M3zD5oTN7a233jKGd4iweoqBHveIAgUKBL5mzrGF5c6dW9AYb7\/9dkOIa9euNcNFk0A\/YgIBJa2Y6Cb3K4lNCFsURIALAkZ5DNhoNAydGO7xHOGce5BMv379jH1rxowZMnLkSIGceHb\/\/fcLaRE7fWCrSPfNN98YQzjlrVy5UrCf5ciRQxCGhNQJuxM2NbQqyGn48OEyYMAAQZODUMn\/xRdfNHYphpVdunQRhLKoHzOd5E39IFaID4KcPHlyqkbHjCT14R3KpGzqwLWK9wgoaXnfB1qDKCCAYyokVqtWLcFehduDrelFIXvNwkcIKGn5qDO0KplH4IorrpA5c+aYISyaGrOMmc8tNt5M1FoqaSVqz2u7FYEYRUBJK0Y7TqutCCQqAkpaidrz2m5FIEYR8B1psaqfJSCsBSO6AMI593iWWZz1PUVAEYgPBHxDWjgFMr3evn17s7SCVf3Tp08XhCloCIsZoVmzZsUH8toKRUARyBQCviEtvKVZKjJt2jRhVT7LNFgPhpQsWVIgs\/\/7v\/9LdVjMVGv1JUVAEYh5BHxDWixmxXGQha9EE2AZBw5\/+N5w5BpSw7M65lHXBkQfAc0xYRDwDWkR+oM1aR06dDBxjvBWJo4R69bwch46dKgwhEyYntGGKgKKQEgEfENaLLAlGBsOggwRWaVPsLgWLVqYoHGEEGF1fshW6E1FQBFIGAR8Q1poUQwRWR9GJAFC7GbLls10BMNCrkljbuiHIqAIJBgC\/zTXN6T1T5X0TBFQBBSB8Aj4irQIEEeUAMLlfvfdd8IRQzz3eBa+GfpEEVAEEgUB35AW4XAJX0K8peuvv96EJeHIqn3u8Yw0idIx2k5FQBEIjYBvSOvss88WVurj0hBKeEaa0M3Qu6cioFeKQPwi4BvSIh442tStt95qXB7s5Tss4WE7qmHDhgmxxuO3K7RlioAikBEEfENa+fPnF8Lmzps3z+yZxyahLOtBWHdIY4iAyVFFEVAEEhcB35CW3QUs58H7HRKz7xHvm3s8s+\/pURFIYAQSuum+I62cOXPKsWPHzDZR7LaCvPHGG4KzqRriE\/q7qo1XBAwCviMtnEgHDhwoLOtp27at2X3l+++\/l6efflpwPDW11g9FQBFwFIE\/9m2TXxa\/7mgZmc3cN6TF8I+lOjQEz3h2ViHWNzuvsNsKWz\/xzE7DeUYEL\/qJEycKaxjZdWXChAnCZp72u6VKlRIVxUC\/A6WkZrli0rd2HpnR6FzZ0a2krHuhU7q\/Dft35ObRN6TFkp3Zs2eb7Z5YIE38LBsIzpcsWWKekca+n5HjqlWrhG2iMPBj3GcR9ueff37KqziuOikU5mT+mvcWiQUM\/PY92Lh8oSArn+0gS9sXl0kVdkrHK3NK7aZtpXDfRVJz5vE0caU9XohvSIuZwU6dOskTTzwhc+fOFXZTsf\/63XjjjWaXFRZQkyYSoCAoQt6gqWETwwfsiy++iCSLLKddsGBBlvPQDGIfAT98D+xh374R9xhtCo2KYeC5l9U1RFVs5FbJ3328ZL+8rm8B9w1p2QgVKVJE+v294af915ONOFnOQ0BAO11Gj5s3b5aLL744NXnp0qVl27Ztqde\/XtVRuk\/Z4Kj0nf+To\/k7Xf9Yzb\/ZiNUSLJX6LxNb8vRcJKGE57w3aN4\/35PUL0wMngQTFYT121eLJXfrvqlElbtNH18TVSDsviOtwMpF6xzjfri8\/jwvn0x7b4ls\/OGgY7J131HH8g6s97qtexOynEAMAs9zn\/2HBEvFAtmkcZnsRlbeX0KQmbdkM0fO+zbIZ57x3qB5W+WKvh\/L1q1boyJMKEUrr7Tywbdx66qUek97TrY8XMNoVPsmPyG\/7PxGrDZDxBq8RU70WigHq7WX3ecVz1TbGAWF+005fT\/uSatEiRLC4msbSM7Lly9vX0qOpYPlx4ld5MOHajgmE9oVdyzvwHprOaf24YRO1SSUDGxbWRDCeCNo4hyRB5pUMM94b\/\/QenJXjaJS5eVtcsube4TnWZHAcrKST7h3i+awJN\/2JVJkTm85OfA6OXPRCLmgaDkz3Cs1ZqeUenaZlGz93yy3g\/IZBaX+iFw+iXvSqlGjhqxevVpwTEU4r1Spksswu1McXyY3SkqkcpIalhDIq121QmYoybDRDYwzWgZDvwNT+8kPfesZjYpziApDum2fuqDu3RnNLibS+ZK01q9fL40aNZI6deoIs3333Xef4GSaGUSvuuoqk0\/jxo2lYcOGxsDPvczkpe8kLgKQ15rHU4ZaB5INeXlt74KcMKIjGNLPyl8i1T6V3+eG9Ii\/RUEv+I608NcaPXq09OjRQzDKM5Rr2rSpsKUYz4Lqf8olBnvC2eCT1aRJE4H87AR41J9xxhnGR+vPP\/+0b8fVETuHGw1K1HKK5ckuEFdSw5KCvQuta8f+ZDcgN46eGNC3tLYEgajQoAI1KnvGz63+caXhIQrxHWkxhMNwzhZi1JdQy7g\/EIKZZ9wLJcSYf\/nll4U9ElesWCFdu3aVl156ST777LN0\/bRC5ReL9xJp2BbN\/okUt6SUISPktSNF62Km0Qmti2EfxGQT1YGUIeDxfduEGT+GfUi4Gb9I2xNNLN3Iy3ekhS8Vjqa7d+9Obf+GDRuETS3SWsbDtmMlSpSQsmXLmveIv\/Xzzz8b\/65rrrlGvPTTMhXSj7hCIJTWldUG2kQVaJ8iT4Z7kBRaFUSVLWUoyP1EFd+RFsTETtJ9+\/aVlStXCraof\/\/73\/Lggw8KhBauoy655BJhzWKOHDnk+PHjQjgbIkUwzcysjf1esJ+WfT9ujtoQVxFA65rVrbKgdeHzFanWBVGhRQUSFfapUtNOCkQFYTEMdLVRPi\/Md6QFXmhJLLtZtmyZvP\/++4KtqmLFijxKFbYbw1CPv8h\/\/\/vf1PsbN26UNm3ayLfffmsWWaO1MdxMTRDihDywAzglEKdTeQfma\/xzouRTFJhv8LmWc6rfVpEzD8iMOwpK56tzGVvXDc8vC+n7FPg92DKmR6oP1YH5YyX53Lyp\/lNHmjwZ8v3gfgh37Ub\/8JsJ8VNy5ZZvSIvhHVEdiFiKQEgtWrQQIpdi0+IZaWxU8I5nPSL+ItixTp48KSyM7t69u\/Ts2VNeeeUVQdNiyIhvlv0e5xj37WuO5IEdwClB03Mq78B8tZySmfJBihZu+H5h69r3mxjfrsC+Mf5Tn74oJ3uXMpJtzUzJfVUjQaMyPlRJ0zNV98Ay7PNotcfOL9SR3wy\/HS\/EN6SVJ08ewZA+depUadasmdx7770mkinRTBkuMhuYL1++sBjxV4zF1GPGjJFrr71WMOCTWP20QCG6wpc4ujmGzi0Wywm0dXXo\/LAsf6CGme1jCCgHdv1FUn8P\/bBPhW55WnfTf+YWbunXxJkUviEtSAbNiCPhZ9CwChcuLMjtt98uX375pTHGh4OBNYa4OLRv317Q1BC0s2LFiqmfVjjQ9H5UEUj+arFATtinWo8tKU+f+bb8kK2A9MuTJFOaLxKr8+SolpeomfmGtOwOYMcdZgohIfve3r17DWFBaPa94CNDSGYZGc8ThwtBS4MIIbKlS5ca2xham2VZwa\/HxTU2DjcaouX8g3KgWwJkxTWGdGb6MKTfMvRduaxlF2Prajrhe1m6+eA\/Lzt05lb\/OFT9dLP1HWkRbrlDhw7SrVs3M8xjqNeuXTuBeBhCptuilAQs1cEhFWO9bevC4TRUEMCU5HHz361hQSKXAynZvlM4iN8\/lAAAEABJREFUeaJZ8QVilg\/7FETFue3oyTNmGFkKVOiCbNJs5OoUAtvGbcfErf5xrAHpZOw70qK+aE0Y2SdPnizEh0d7ql+\/Po\/SFYz1gwYNkuRkPJVFVq1aJekFAUw3U02QkAjYBIUGBUEhkBROnqVS7FKITVIZcUsY07KgzOpWOYW0tgpOqW5oXfHYcb4jLUgHWxTLce644w6jYbHvIfd4llYn4J81fPhwwWjPsJC0fggCSD1U\/IMAxIOgMSGQEgIpBQppICiGe2hPNkkx9Mtsa2qXyWWWArEAG62LWGWZzStR3\/MdaTEEZBZx+vTpgrz66qty8803i+3VnlZHzZ8\/X8477zyzb6KdDtsYU8D2dbBz6fwqW83sTuCXNdrnTHNHO0\/N7681eBHjcF9RwS8KIb4Usv\/Pc\/\/yk\/o71hTxphBiTh3rME7wm\/qpeJ0s+U5hZ2KGm+OJQ7ulzSUnZXaHi2XJtz+ZmF2PvLU6y\/mTN8LIhKOTon5aNqOkHDG2oyXhh4WwBhG\/KxY5Hz58OCXFX\/+xV+HLBXg4l\/KFwBGViBDk8Veqvz7POeecv05CfDZYWTJ1Gpq\/pE4IPwAn8tU8T0bed8SVsuXZZSbG1BVPzZVS+ElFKdYUNqVQwh\/PwPu1KpaV9X2vNTG7Rq84KP+Ze1DOzFkoy\/5a2IEDy3HiXP20QpBJ4K2dO3fKrl27Am8JhIbdC\/BwLv3mm28EP60qVapI9erVzUJphpUsC8Kh1H6Z82DnUvuZHhUBLxDAUI9TKmVj6+KoEh4B3w0PAzUotCgE2xYxsHLnzh22JQ0aNEjdOYTIDhAXBvgWLVokTBBAhgNhAYriAy0nimD+nRVOqbO6V5akhiWFNYxZIS+3+ufvqrt+8B1p5c2bV2bNmmVCJKNFIex9iAsDQ8RIEYLsGEay8FqDAEaKnqZ3G4Gkv8Pe1Cqdy5BXpAuw3a6v0+WFyt9XpHXkyBGz0Pmxxx4TdsxB60IY+mG3ItRMqEbY94huivc8BHfo0CHhXftZIgQBxHZht9fJo5bjJLoiaF0j2pU37hFTPt9t3CMiKdGt\/omkTtFM6yvSwj1h7Nix8vXXX8vIkSNl2LBhRvDVYvjHzGK4xv\/xxx8yZMgQadmypbFndenSRV5\/\/XVhj0OGiUSNCLdZa7g89b4i4CUCge4RDBmJlOplffxStq9IC6fSAQMGyPPPP29iYxFi2ZbbbrtNCDMTDji0rP379wtOqJZlCTHm0diIyWW7SxCPq1q1aobIwuUTy\/fdsmVoOe5+S+whI6Vi60pvyOhW\/1AfL8Q3pIXjKITFEY92yIdFz7ak51zKcBDnUjZ1vfLKK+Wuu+6SgwcPSnp+WpLyD2M\/He2U4I7hVN6B+Wo5WzPl6xQLuOHb9WKTXGZPRuLTsx\/jJ2s3hWyvG+3hN5Py0\/Hkv29IC98sNCOiMrDQmQXPgcI90tgoYa\/CwA542LtYZE3gP0LaEBGCGcdHHnnERDFNy0+L\/DD2YwdwSoL9c5wqxw3\/HOqu5XgXt4uYXfuH1pNS+XMIC7CnbrRO8+tyo3\/4zfDb8UJ8Q1qBjYeQ8IpHa7IF7SvQuTTYT4tYW1WrVhXbB4shIbvvFCpUyMxE2vmrn5aNhB5jGQHcI2Yl6DpG35EWO+706NFD2C6sVq1aYgtRGs4666yw37MSJUrIsWPHZNOmTSYNYWqwYaGNrU6QzVoZKprGO\/yh5TgMcLjsg+7XDrOO0a3+CaqOa5e+Iy3IisB\/hKa56aabxBaM9Hi3h0MGgmKY+PjjjxuiI9zyww8\/bLzjIS710wqHnN6PZQRwj7AN9Z98d9C4R4xZfjCWm5Ru3X1HWrg1YLtCU0q39kEJMOKjqRFDi6FhoC1L\/bSCwMrCJXatLLye4VfjrZwMNzwTCSEvlgIRPYJ1jLhHuLWRbCaqm6VXfEdabLrKMhxmCxkSZnT2EHeH8ePHy4QJE8xeh6w7xC6m8bSy9P3Ql2MMAVvrotoZcY8gXayJ70gLLWvGjBnGeL5ixQqxZxCDZw9DAY1NCzcHniUnJwtDRhxWMcqzbpFr9dMCnayJWzaTeCsna6hn\/O0Th3YLhnq86nGPgLyWbo6fIaPvSIsZQmYK7VlD+9ivXz8hThC+WKG6j2El2hlOqMTMmjJlihCmWf20Mue7BGGEEzf8gChby8lc39m4Vc\/3m4nZ1bhMdhPmOZoxu3A1CvU7dOOe70iLGUI0Jvyu2P6LISKhaTDQE3qmf\/\/+BhfcIjCwAx4GePxG2PeQpTq4NXCPkDUs7wm0bZmXgz54F\/uJU6J+Wpnza3LD34g+d6scL74HxOzCtwv3iPc2J8stb+6RXSdyn+bbBQ6RCL+ZoJ+Ra5e+Iy3ICW2LdYQsfG7RooW8+OKLgiG9a9eugu0KdIL9tACxQIECgnOqZVmCzxYLrAsWLGiGmryDQGi2LxfXKrGKgNY7EgSC3SMw1Efyvp\/S+o60AIdNKSApzpETJ04IESDQmrgOJUWLFhVmD9lujOesOcQ+hjbmtZ8W8e6pk9PCkMrpMshfywGFyMUP34NAQz2LsAfN2xZ5Qzx+w3ekhW2KGFjYp\/CzwqZ1zz33GM0JmxbPQ2F2ySWXyN133y2EpqlZs6ZMmjRJCNNcvXp1gbjS8tNiiOmkUF8n87fz5kdhnzt51HJKSWbw9cv3oG7Vy2T9860k+zezzM5A+bpMy3R7aJPb4jvSAoCOHTsK9ikWTeMRP3jwYGnTpo0wXMR5lDTBYlmWec5s46effipvv\/22GbdblmV29Am3WSvDSpUtqVFfFYvEweKHuS+YnYFqViiT6f4P\/h1G8TpsVr4kLRxLR48eLYsXLzY+V6+99prRomgFhnqOKoqAIpB1BHBKxT0i6zm5l4PvSAvb1bBhwwS3BYzuZcuWlfPPP186deok2Kjcg0ZLUgQUAT8i4DlpMVOI+wLC+a+\/\/mqcQlu1aiW4PFxxxRVy\/\/33G62LJTp+BFHrpAgoAu4h4AlpMRs4Z84cwaBLGOVbb71VkBtvvNE4hDI7RSRS3Bq2b98u7GN49OhRE\/nBPWhiqiStrCKQMAi4TloM\/5566inBefTdd9+VwKU6rDmcOXOmXHrppUIwP47jxo2TunXrmn0Ow80cJkxvaUMVAUVAXCctwsswA9ihQwczDAzugxw5cghx4THCM60MiS1ZskT69OmTZoz44Hz0WhFQBOITAddJi6EeM4A4guKLZUdxwLWhXLlyguG9YsWKYt9nCNm8eXMzbOSd+OwGbZUikDYC+vQfBFwnLbtooi4QfYFFzURwGDVqlJklRNOqXbu2QGDTp08XWwgzk97wcNGiRYbsyBfHUgz3xNbC54s1jORL6BpsanY99KgIKAKxhYBnpEXcrF27dpldc4hUWqFCBVm4cKEQOoYhJA6iLHpes2aN5MyZ07g7oKWFg5dF1fhzTZ482ex7iMbGtcbTCoeY3lcEYhMBz0gre\/bswhpDe60g8OGXxZpDfLIYFvbr188QEJ7xuD3gEkG6UEIIGvy42MjCsixBq8JJFfJD80Kzi\/d4WqFw0XuKQLwh4BlpQSD4YrE\/IaFBsGERCwthKQ7+WWktkA7uiOLFi8vu3buNMPzDeA+Rbdy4UQgJYqfHaXXbtm32pR4VgZhE4JfFrwtyYGo\/SUv2jbhHnBQvwPOMtGgsrgyESO7Vq5ewbIfAfWXKlBGGjdx\/+umnzcYUDBuxaV144YW8FlKIBcRehxj3WSS9Z88eYxcLjhUf\/DIzlCqlMrVgVnGLHLeu1S4S5JX6Fwgyo9G58mnzs4xsaW1JRgUiWvdCJ9nwZv80ZdMHk2Tp7Lcck+DfkxvXnpLW2LFjBbsVRvgdO3aYBc+QDjGxMM4TxK9SpUpy6NAhE3YGDSocKGhlDAmJBEGI5UaNGhkXCUiQGFr2e5wHx9NyepEwZTtdhubvn4XOX88eJ2vHPSnLH6ojS9sXl\/lVtqZKrxL75JFq50vz66oaqd20rZS98U4pf8fjUmrayYik5szjkhG55f3fxAl5aGMh8eKfZ6SF\/Wrt2rUycOBAyZUrlwnehzMpy3gwoOPHhZe8Ldi0eCccSAwNCRKIlkYgQaI84G1PmBqv42ktWLAgXLX1fmYQ8OE7aD4\/9K1nNCWODNmO79smZ+UvkUpE1uAt5rzYyK1SuO8iI\/m7jxckd5s+PmyVP6vkGWmhNWGMP++88wwyefPmlddff90s7WFjC+xagYLmhaHdJA7xQRDAm2++2YSwYdjJNdoWsbnSi6cVIju9pQikiQCkBDkxnNvRraT89tViQ0K2tmQTE4SUZkb6MGIEPCOtfPnyCSQ0YcIEs6YQg\/mAAQME8krPHytUKy3LkjvvvFOYLVy+fLn07t1bcGK1LCvNeFqh8orVe6zZdKPuiVoOhm+bqDi3tSgICnED+4yU4Vb\/ZKQuTqTxjLQsy5IHHnjAhKDBHsV6RPy1eqUY5bNly+ZEWzVPRSAiBP5IGd5BTjZRoV1BVAztICnVoiKCM4LEaSd1nbQYFrIch1A0eKwzhMOGRXhkQiVjjyJN2tXWp6EQYAY11P1o34v3ciArCIphH8dgosp+ed1oQxrV\/Nzqn6hWOoLMXCctjOkY1TGwY4PCPwt\/LeSGG24QAgAePXo0giZoUkUg6whAVLZWBVlxjn3K1qj8TlRZRyB2cnCdtLBjYVSfN2+eQFLsU4ibAvLOO+8Y5LBFmRP9iAgBt2wZ8VQO5LTl4RoCUdlalU1WEYHvo8Ru9Y9XTXadtOyGMjRkKAiJ2ffYt5B7PLPv6TE9BP557tawINbLgZwC7VQXFC2X6ooQD3Yqt\/rnn2+eu2eekRaLoI8dO2Y84YlSirzxxhvC2kOW+EQLhpMnT5qdfTTKQ7QQjZ187CFfIEnhooB2FWynip1WaU09I61zzjnHOJYyc4gXfOvWreX7778Xlu4Q5SFaXaNRHqKFpL\/zgYhw8ERsLYohH9c8g6QY9iFqp\/J3X6ZXO9dJi+Ef6wKpGGsJk5KSBCfSTz75RPDTIhoDz+w0nGdFWNKTKFEe3LJluFEO2tGWMT1SF\/tCRAhEhKAxBQrpcfAM9kIPJKlw3yM32hOu7AzcjzhJvLUnGADXSQsfrNmzZ0uXLl0EJ1BixtuV4nzJkiXmGWns+1k5EukhrSgPrAsL\/PI7cX6ydymzvMOJvAPzjJdylrYrJF\/NGCU\/LHpbFi9bI7\/s\/EaSz81r5I\/iVeREr4XCkphA4R5yrMM4OdLkSeGHm1FBw89o2qyki6dyWCyfld9lVt51nbSYGezUqZM88cQTMnfuXKlXr15qhAF240HjwtGUNFlpWOC7DEUDrwPPG6wsaYyw\/EV2SvhxOZV3NPJd3nu3ZESm\/WurREOeb\/m1BEuPuqvElsG158q\/L3\/HSOeLhkrV35+Rqnu7p0qVl7cJcsubewT5z9yDMnWjJRigMyOERsrMe5G+wx\/PSN\/JTHo32sMC\/cDfkZvnrpOW3bgiRdqWVusAABAASURBVIpIv379hOEbACAswXn00UeFrcPsdFk9lihRQojsYOfDeXCUB\/tZoh7bVSsoGZGkhiUkGjKiXXkJFnY5DpQ1j9cQZP\/QehJOeN6uWiEpmie7fLL5gOTpuShVKvVfJs1GrE7ULo3rdntGWg6helq2NWrUEK+jPJxWKYduMHRxKOtTsvVTOZAoBAjhBZIbZEalbSKDxAbN28at08St9pxWsEM34q09wTDFPWklUpQHhhLBHezEdSyUA5kFEhkkNuXz3UYTg8CmfL4nFRq32pNaoMMn8daeYLjinrQsK3GiPAR3rl7\/gwAkxnASgcC6T9kgkNeO\/cn\/JNKzmEDAU9Ji4fTDDz8s+Glhzxo+fLgwgxgTyGklPUEgq4UWS7F\/2QRWLHd2Q1yBWldW89f3nUfAM9LCqXTQoEEmNA3NZGbl+PHjMmTIEOEZ91QiQ8AtW0Y8lAN5MXxMalhS0LrC2bsi6wF\/pHarf7xqrWekRbSHP\/\/800QqZfMJopji5sC6Q555BUgsl+uWLSOeyklKmRGd1a2yDJq3NZa7\/pS6u9U\/pxTq4oVnpMVSHTZfJSa83V6GixAWDqj2PT0qAk4jULtMLoG4mGlcuvmg08Vp\/mkhkIFnnpEWi6Lr168v3bt3F0ItsysPMbZuu+02yUy4Zdq6aNEiIT4Xy3Z69uwpaG2JtGDarWFBPJYDceEy0Wzkaol14nKrf\/jNeSGekRaNbdy4sfzvf\/+TF154wcR355x7PItUdu7cKURAnTx5snz22WdStmxZc60LpiNFMrHT1y6dS\/791obEBsHnrfeUtNCM+vTpIwULFhQilhJ6edy4cZmCbPPmzWajjEKFCollWcIeiBs2bDAbXaB5sRAb7a5atWryxRdfZKoMv7\/kli0jnsvBOE8\/x7I3vVv9A05eiGekxQas7E3I8HD79u3GID9\/\/nxBM8KuFSkYxYsXF\/Y+RIgxz8JriIyhJzOTdn5xtS2+3Sg9RhWBNY\/XkKXfHZSlat+KKq7Ryswz0iIAYI4cOYRopStWrBC0IYzzZ599doZcHtgYg\/0MWW2OPYy\/LnfccYfx+apevboQ2qZcuXLCzGRaC6YBkjywAzglbq3uJ2S1U20IzDcRyul8dS7pMmldRNEiAjEKdR5P3wN+M\/x2vBDPSIvIpUQp\/c9\/\/iPLli0TFjYTI557DOPSA4NF1WhTLLR+7rnnDNExJOQHxSJshprMQpYpUybdBdPkAek5JWh6TuUdmK+WUzJTkR5C4TawbWUplT+HPPdZcqbyDOwX+zxUOfazaB7dKIffTHq\/Uaeee0ZaaD\/9+\/eXdu3ayeDBg4WAgDSSsDRoXJxHIgwLu3btKrt27TKbvzL0bNCggdSsWTNhFkzzxY8Es8ymTZRyejcsKXjLezdMzFwPudU\/matd1t\/yjLSoOuRUsWJFyZs3ryQnJwtxgCAw\/LV4HokULVpU2JKsTZs2UrduXeEabSuRFkxHgpemTR8B3CCSUogrHtwg0m9t7KTwjLRYqoOm1bRpU0EjatmypRAnnpnEXLlyRYygZVnGbYI1jERE7d27txBw0LISZ8E0dpSIgcvEC4lUTlLDEhJrbhBu9U8mvjpRecUz0jpw4IAwS8j+hw899JC88sor8uabbxqNy7KsqDROM1EEooHA8HblhcXVsewGEQ0c\/JKHZ6QVCAAG87179wrRTH\/66SdDZoHPM3auqdyyZSRaOfbiatwgCGfj92+aW\/3jFQ6ekVa+fPmMU+nAgQPN7MzYsWONZzz7H2Lr8goQLVcRCIcA\/ltoXBBXrBnnw7UpFu97RlqWZQmxtB555BHjo8XMH35bhKbJiMtDLILtdJ3dsmUkajloXKlDxZGrxa\/hbNzqH6e\/z+Hy94y0qBChab799lt5\/\/33TfC\/Sy65xCyeZm9EnqsoAgEI+OIU4mKpD1EhCN+M1uVX8vIFYA5UwjPSgphYwjN06FBh2zBb8I4nGGB6bWX28bHHHpN169alJmUtI1Ee8M26\/fbbhaFmIkV5cMuWoeWI4A7BcJHQzZAXYW38QmBu9U\/qD8\/lE89Ii7AxDAexZT3zzDNiS1JSUqqjaTgsWKPYvn17YebRTsNM5Pjx42XChAmGBG+44QZ5+eWXzVrGDz\/80KR97733ZOHChWbbMvs9PSoCWUEAlwjICwkkMJvEiIqalfz13dMROOP0W+7cwW6FwT0zjqQ4oxJ7i0XSgbVlPePBgwfNLZxVKYMlPaxr9DLKw\/XXX2\/q5PSHW7YMLef0nmTYGEhgbGsGie3cn2x2AILEqry8zZyjkSG4UEBq0R5eutU\/p6OQtTsZfdt10jp8+LAQG\/7pp58WCKt58+bSuXNnefTRR43wjDRpNaBy5cpy4403CjOQdjoCB7Zt21YIIkgkhylTppglQkR6uPjii+1kJib9tm3bUq85YfGnk+JGGdQfcuTotGg5pSQtjOtWvUweu62mjO5aX9Y\/30pyvXvvKfLjp1MFWbFojkx7b4kMmfG55OsyzRAa5BaJ8F6wVBv0hcnPvn9R+1HihByp3ZuvtuviOmmdf\/750rFjR+nRo4fgEc9QDwLjGuEZaQKRIIoDXxKiOhDdIfCZfc4CzokTJwpDwO+++054x15IzTpHO13wkfdUtohi4B4GP8x9QZA90x+XHyd2kZ9GtTZC5NSMCpoc0uuWapKetG5cR5yS4N+TG9eukxZx4RnGPfnkk8IQD0O8ZVlC1AYkf\/78QprAxkM+\/KiWLFli0gU+s895TpibYsWKmSCAVatWlZ9\/\/tn4gkFidjrOy5cvb1\/qURGISQTaVSsoSFLDEpKeQG5OiRfguU5azBqiWbFdPZoR0R0wwjMbmBUAWCDNcBPPevJZuXKliWSKdubHbfGZ2STCBUOtDz74gCpHJJo4PhAgui5mDWa7iXDC7yM+WuZcK1wnLWYNGf61atVKiKH1r3\/9y2xAkZ4dKz0I8PG6++67hc7H5WHSpEnC5hYEBIS4iD3fsGFDqVevnhD5Ib38nH6Ob1qXLl2EGGJLly41GDhdpubvPwSOHDliNndhbwNGH0xO+a+W\/qqR66RF84kmytEWthGLVNPCXWL06NFSoUIFk41lWULEiI8++sjEhSeeVsmSJc1QEfcIiIEIEHfeeae5Z17y8AOtkPoRDBESZwG5h9XRoj1CgD\/ikX73Paqqb4r1hLR803qPKsKXlDj22bNnNzWAtImZby70I6EQIATzSy+9JC1atBBGBzhDGwD0IywCZ4R94uADfKeuvPJKM23M8I0tvzimN0PoYJWiljW2NNR8O0O8+3HjYBcgwkEzW8pEQ2AsfPzJ8D2z39Fj7COQke8BBEXgS7a+g7DWrFkjbIUX+613tgWukxYzhMwCMtsXSnhGGmebHf3cCanDhAJLk9Cc7BKwXfHXlKHpW2+9JawAwPkPv7JNmzaZMDykZ0LCfkePsYtApN+Dr7\/+2pgrcMvB5GFZGksuvd53nbTSq1CsPkd7ws3illtuOaUJkHCTJk1MFFXihRUuXFhYJM6kAIEPidaKlskX9pQX9SImEYj0e8AfKxyimUXGXSfQETomAXCh0vFBWi4AlV4RLBPCS79KlSqpSZkZwsBue+5blmWGxNu3bzcBD9G8FixYYLz7U1\/Sk5hGINLvAcNDXF6YQMKx2rJU00rvC6CklR5CWXzOX17sV1nMRl+PcQT0exC9DlTSih6Wp+WEKwPDPhxJeYjhFXvWpZdeyqVKgiCg34PodrSSVnTxPCU3y7KMMyt2LWYR2ZMRj302kD0loV6kg0BsP7Ys\/R5EsweVtKKJZoi82HsROwfuDnjr33vvvWZPxhBJ9VYcI6Dfg+h1rpJW9LA0ObGHIwu8zUXKB3svEtiQvRgxtrKMKOW2\/o9zBPR74FwHK2k5h63mrAgoAhlDIKJUSloRwaWJFQFFwGsElLS87gEtXxFQBCJCQEkrIrg0sSKgCHiNgJKW1z0Qefn6hiKQ0AgoaSV092vjFYHYQ0BJK\/b6TGusCCQ0AkpaCd392ng\/IqB1ShsBJa208dGnioAi4DMElLR81iFeV4f9Iq+++mq57rrrUmXAgAFeVyvL5bMiYfz48UK4IJZTEUE2MFPaPWrUqMBbqecsch82bJiwfjT1pp54hoCSlmfQ+7dgIrCy5MiWxx57LLWyRKogvn3qjRg4gajefffdTMctYwMSwgsRFjwGmhv3VYx50or7HvJJA9FCunXrZnY8WrZsmaxfv16aN28uLARn3z60Eaq6aNEiYQs3NDW2cOvbt6\/8+OOPZms3jqRBy0GzgQCJjU5a8mHfPwiG5+TJLkrXXHONdOrUyWyxhqYzePBg4R7BFon8Chk9+OCDwmYh5I1GhHBuC\/HaicNP5Fj7XrgjWiX1QSpXrizU4ejRo0KwPrZ7O3bsWLhX9b5LCChpuQR0LBVz3333mQirbDRSsWJFWbdunan+\/v37ZcqUKUI8sOHDh8uIESOErdkgjaFDh8rmzZuFTRqmTp0qhOOBJCAh83KID95ls1Kit3788cdC3KmZM2ealGyxhsZHGrScL774Qoi3z8YPixcvFoiNIR8bguzZs0d2795tiI3NIQhdbDL5+4P0l1122d9Xfx0C20g7ISSeoFWiYdJO9uUk5j\/1oi20n9BCpFPxDgElLe+w923JY8aMEXvTkbVr16buLVm3bl1BY9m2bZvww0Yb4Qffrl07+fLLL432VaBAARNK2rIsIdIBQRDDNRTSgRwgwdKlSxsSXL16tUmOlkO8dKJksLclQ1I2B4GQ2NCUcD\/YqNDq2Kh3zZo1snHjRqG84Hhl7C3IfZPx3x+BbaStLVu2\/PuJCLs89+vXT9jgF\/seDyBOtnzTrd5Aw1tR0vIW\/5gsnSESW6JBVPzg2VVo1qxZhjAY8tmN+v3339M0XjPs6t27dypBonX1TRlO2u+bY8AHw0N2rbFvHTx40BBM\/fr1jWbH0LRGjRoCqdlpIj1S\/zfeeEPy588v99xzj9kpJ9I8NL2zCChpOYtvXOZesmRJOXz4sEBW\/MjnzJkjzz\/\/vAluyPCNCK3cRxuD4LJly2Z2I0pOThbuY2MCGLQYtCc0IbSbPn36CMNEnoUSiJJhJ+TFtmz333+\/sHFIpUqVjN0MWxvaX\/C7BQsWNLOGwfdDXTMEpT0MC9Hy7DRoetQ9Z86c9i09eoSAkpZHwMdysdh3evXqJRjTa9WqJewq1KVLF2GYhjsBQ606deoI5MWwjKEc12yXxo5F2L4gMoaPEBFHhp7sBcl5OGxuuukmo\/lgFG\/Tpo20atVKGEJCJPbmv1wHv08Z2OUgneBngdeQIVrWjh07hIkACJAj9jXsZrQFDSzwHT13HwElLfcx93WJRF0NRRyQEmJXHlsSBnQ0pcmTJwv7OVqWJez7uGLFCmPzYngFUViWJWyPhQ3rww8\/lFdffVWeffZZo32hLXEfYaiIdkP51MMui3K5B2kMHDhQcD2gXMqMBiroAAABE0lEQVSyLMvMHEIqzZo1M6Rmv2cfmWlEI0M7Iw\/qS372c46UR114hl0NLRGBkCEq2sr+lVkZelKOSjACkV8raUWOmb7hIwRwo4C80NyqVq0asmYQ1V133SXYvCDRkInSuIk7x6+\/\/ipoi2kk00cuIXCGS+VoMQmIALN+zMI52fSLLrpIZs+ebTS3tLQgZiPxubKsyDdDxYbHUBgt0Mm2aN4ZQ0BJK2M4aSpFQBHwCQJKWj7piIxVQ1MpAoqAkpZ+BxQBRSCmEFDSiqnu0soqAoqAkpZ+BxQB\/yCgNckAAkpaGQBJkygCioB\/EFDS8k9faE0UAUUgAwgoaWUAJE2iCCgC\/kEglknLPyhqTRQBRcA1BP4fAAD\/\/7W1TW4AAAAGSURBVAMAqAIw0oqiC+EAAAAASUVORK5CYII=","height":181,"width":301}}
%---
%[output:9976d829]
%   data: {"dataType":"text","outputData":{"text":"Induction Machine: ABB M3BP 355MLB 6 261kW\nIM Normalization Voltage Factor: 375.6 V | IM Normalization Current Factor: 581.2 A\nRotor Resistance: 0.00274 Ohm\nMagnetization Inductance: 0.00376 H\n---------------------------\n","truncated":false}}
%---
%[output:6a96aee0]
%   data: {"dataType":"text","outputData":{"text":"Permanent Magnet Synchronous Machine: WindGen\nPSM Normalization Voltage Factor: 365.8 V | PSM Normalization Current Factor: 486.0 A\nPer-System Direct Axis Inductance: 0.00624 H\nPer-System Quadrature Axis Inductance: 0.00756 H\n---------------------------\n","truncated":false}}
%---
%[output:017a5236]
%   data: {"dataType":"text","outputData":{"text":"PSM EKF Fully controllable\nPSM EKF is stable.\n","truncated":false}}
%---
%[output:58bfa75a]
%   data: {"dataType":"text","outputData":{"text":"IM EKF Fully controllable\nIM EKF is stable.\n","truncated":false}}
%---
%[output:188162c1]
%   data: {"dataType":"image","outputData":{"dataUri":"data:image\/png;base64,iVBORw0KGgoAAAANSUhEUgAAAS0AAAC1CAYAAAAKoal0AAAQAElEQVR4AezdCbQmRXUH8HojKkiiCLKLGQIiQdQREFCUoERQgcgmB8HECRwWQ0SNIEIiwhFFWY6IO5uCQAISxRghHEwARZKYAMoSiaKCGKKyKBhZjhgzv4Y71PR099ff+9b36DlzX1fXvVV161bVv29VV9e34Lfdv84CnQU6C8whCyxIQ\/x32GGHpd\/\/\/d+vpX322Sf97\/\/+7xBLTOlTn\/pUUd4f\/uEfpp\/97GcD5X3jjTemF73oRUV+6lGlb7mOX\/3qVwcqcxiJh2mDNvqMojx2ZPOchtGmbeqTtzs92qQhE3ags34jH\/E5RX+p6ku5XFVYfvKVfz96VeVVjjMO6STvs846a5l+L65Mwy6\/rE8\/90MFrV4F\/+u\/\/mvaaaedBgaXXuUMi\/\/f\/\/3f6YEHHlianYa+8847l95Pc2CUHX7Y9TawDzzwwOWyveOOO9LWW29dPJiWY044Ql\/42te+tlSLX\/7yl+kb3\/jG0vtpD\/zwhz9MN998c1pvvfXSBhts0FNd7QOkewqWBLQtAASQbFZiz+p2JKClo91www3pBz\/4wVI67bTTCgV1xC984QtFeNr\/0FU9Qs9o6Gc\/+9npd3\/3dyN64teDDz64sPNVV12V1lhjjWX0mfYb4Hr55ZcXar7rXe8q6qHfeMAZUBif\/OQnEznhUdALXvCC9O1vf7so+4\/+6I9aFUE\/lAsDsWENzDzfUYTPPvvsBGjf+MY3plVXXXVpEcYp+wfp\/8Yzgb\/5m7+ZCodjJKClgmVac801awd6oDFERlziqk4qDo8Mkq5cTtxzZ8kE9TvV2H333Yusbr311uLqz09\/+tOiof\/gD\/7A7XJULlPZVTqW5ch4ipEPPfO6kieDH0Q+FBAWH2ndv\/71ry90JeMpGU+6yCfu8ZE08mBfZYtDwuLwkPTiq4ieZIJCnyrZiOOdGDwAKmyOB3zf8573CBb1YPvi5rE\/9IhyXOlI18fYSy9lnaSLuoZ+0kkvH\/JLEzcE\/vEf\/7Hg0jsGNc\/Fg61g1PyxhKFcZdGDPsJBTeX3ks3rEfmV25ladPj3f\/\/3Yjxus802omrpd37nd9I666xTyS+Xx4biCCtDPcNBAfAvfOELU9SPHPnQ07VKV3mVaWygFZ2TAhtuuKFLsb5F0ahYEbnkj05s0GnUJbfFf5UVh1dELPkj3QknnLAktOx\/jWug5rG8ple\/+tWtn9hrr7120aj50zM66kYbbZRnXYTpWi4Tg47qGE9g9SjLkamqh\/SIPBnhIPLKjPtRXOk6LptrH0\/1vB68nnjiC+OxI3uW7aFf0DW3Cf3ZTrog6dgu7mdzNSANemlf8pKXpP3220+wAFf9vLhp8Yce9MlF6ZvXIXjiq2TVkYyr+rOD+yBgUV6SYWf2fv7zn5\/WX3\/9EK285nVdd91109Oe9rRCjo7l8pQtji6FUM0ffHLkc5EqXXN+hEcCWgqHqtAzSAMp1BQgOuC5556byIoPt5RB48kV0wKGe9\/73kesmINLozNLU0RmfxgkGldZ5CJPRjr++OMLsMySVAbXWmuttMoqq6RY1zJYrGd5snpC5InwgJs4uitPuaFfPIH7qYe8gpQZdf7Sl75UgCmeMpUtnJPpYi5Hj\/PPPz95auZyTeF+dB3E5p70MdU2MKO\/ePBU6TeKPlNVTlOc9jXoybzmNa9J+ro2cl\/XJnhlUm\/tpK9o38ijahqGR4asNNLK76wli+j6QDxQq+ToSmfyZC28CwPbcp\/I20Bb6M\/Sy\/eUU04p+hAvydiUB++YTkhYXIzVq5YsV0ScfOhg7LfVVV5VNBLQqioo4qJBDAph8SqmMsKMeOSRRxYDE8h4cqksw+GbMpg6CEsjrXBQTOcYOXjy1EBkAkCEm8h01lP0F7\/4RTI1sSAPwDxt5JendQ8UNJyr+5yvHvLopx55eusOUWdPRk\/InD+KcD+6DmJz60knn3zyclXw4DFokKc6gVH1GXn3Q\/mgA1jaRl+RR9v+RZbnr\/7C8tDOwvo6+wsH4ZFxX9UHTjrppGJNDlCEHNmgaCPTVzoaH3QPfq8rnbQJOX1Znwacb37zm0UVJCyObFn\/QuCxP211fUx8uctIQCtQ1SAO8rRXugrxulQcIIiL6aIwAhi8HOEwtjCD4AkHldOGvHLoodMjTxBpGFvZwr1I3uRz4DS\/X3nllSuTGlzKCooyy8Jt6pGnoUfcA0Q6xP2or210HdTmHj7RT+JBk9dLf2Fb7TaKPpOX1SsMOPOpYQAEj0va6C\/CvSjShFzezhEX15xX1wd4vNH3XKumYPoyHYFs6B5luBqn0RauwMc4wuNd8bKiveWjDGUhYXFkQ0a4itroWpVO3EhAS8ZlUnEkXqPfe++9gq2olwFaZTILoegoykeyKHc0cch0xuASjmlp7saLjzyEp50mpWs8hQ2Y3H6mXQ8++GBrs41Kf4PYA5EiPA+DFeUPKLqahpEZFwH10AHws5\/pJI8qdKAT3TyIeEUR33QFkDFLAUhAr0m+Da+Nrk35jA20yko861nPKtaMxJc7WPmJGuDBaHjSBJXTRjyA1ME03lJ6bAuGJ3vINV25zxodyEZjlz096T194rW9J5U1JfF0pbMwmk09pBsFmeqa8tblPRtdZ2NzYG\/Qe9PEi8n1KU+DeAZVHrg0bJ17YbPRXz5NZNDHelCTnOmXaViTDF6578Y9UKnqZ9JU0d13351iqcUDE\/CTy23iHoghywtsK24QMjbkVx5f7mMMlPPXxm10LafL78cGWiqHFM41ZTjzdPeeWNxFYR3DYrnBrvEs1AZ44FvkU3FhaaQVDgpPSFko4psGR8iUr96UWMPyZJWXAdOrM0XHU49yB++nHmVdhnUfg1mdgLp82TM6knvUj66D2DzXp9yWbI7oY0q8cOHCNIo+I\/82BIgAEtnwZgzQIICBp++28UhiuiWNB5974Tb9jFwVRf\/Di71YwijW4rbddttiQV1cL8r7cYxHY1JYH8rbjAflAeRFlfr0yrtJ16a0IwEtHU2nV4GgcF1VNlzTN73pTcWOZwrik5VOenFvectbkoVKT1gL8OIYyhOdrDTicuJF6VDi8MmhMK5OLz\/8XsQ1NlhCDthWpfXUAsLkTBGVl9dDPJJW+cK96kFmWMQOtgnogAES8hZPV\/akj7gguo7D5nkfCNvRCdGPPp7oAQi5PD653NZ5nxm2rQERQKJTALVwUAxm9x4CHgbCdSQv60Dq4OqeLLuzv3AbMmvRN8nq5\/JDwuKQtjdjMP7oKa6KwqbSo9y28eLAmGRn6fM2ExYXcsJBxrS8PCh76Rpp6q4jAa26wgwODa\/SZICCt20BMuKC8mmWOGAkTjhIR0ZxH1fucVlWY1kjqXNbI235mnfOfMDncurhdbDBFfHqpKEijtel4yi\/rBvZqnpEXrO5srHOU05bZUfll3WSrkqWngg\/p9nanO30gary5a+s\/I1YyNMZP6fTTjstsW\/ECZfzlU6eIdP2qu0sEZDXpgagcE75w8tDwADN+eUwPegT8dFH2T3i2l6POeaYpQ6ANMaa\/ufq\/rzzzkt00if0DXH9EDtq40jDtsYTnSPOtSzHQSnL9NK1F+APFbRUKlzlqqvOqdOpXE5V6aoaTlyeL8MhcXnHlndZ1mcavRoLn5z8pC\/noyxxVXKejHSQFqlTHpfXXd5kgsjmrnJdGeIReWkjT3q5V74yyaCQwwtZ8VXlR5z6qx85FPHyQMpCwuXyyrLlvORXR+W08kfKqkqT140ckkdZVhxekHT92Dry02\/ZUD7lelfJkFO28oSllUfIxjX4ZMr20g7i8OQVaVwjXeQrb2GySFhfcHV\/\/fXXF1sipJM+p7wcslVULl\/6qnRlubIMfi9d6+yrTDRU0JJhR\/UWMM833+d2x3SNtPhYyOc662ziO5q9Bdi0s\/Xs7TfNKTvQGmPreOpwzxXJdTfFAGCxnsGN5k7jdzSYBTpbD2a\/KU1dqDV20Pr1r3+dTj\/99MSjMGC33377dMUVV6Tf\/va3hULz\/Q\/3vMr9FmcqYLDNdxuMq37TaGtetOmP9q6b+o7LPnO1nLGD1oUXXpg+\/OEPp3333TddeumlaauttkqHHHJIuvrqq1P3r7PAtFjAnq+cbrvttnRbHxRpp6U+80mPBeOsjF3w3mLstdde6W1ve1t63vOel7ze3XLLLdNFF12UHnnkkXGq05U1hRaIwV6+VgHGt771rfStEl155ZXpyoy84crJ3qWgj3zkIyno2GOPTTlFfFwjTdtrpJNnhKWlC\/3UZwrNPydUGitoff\/73y9OTfAGYWZmpjDQSiutlLbYYot03XXXLXfA2J\/8yZ+kjmZtg1a2s99mGHT44YenNmQQN1EM8PLVgC8TACiTqVdOZVADFkE5MBadcUR\/ohzl0od+6sIObMb+tj686lWvSptttllB1js32WSThCyjTDONyGy12Y4VtHw6ssIKKyxzUiLNNt5443T\/\/fene+65x+1Ssi+qow3TKG3gCJ5hkNfYbWhp404oEDquuOKKxa5wXzjk5OjhnLyBDLIps4kcDukLCmRfF5D6yU9+koDWQw89VFlj+rC\/MnzK5KWM6+abb55Cr9\/7vd9L7pG3zosXL06f+MQn0j\/90z\/VElCcLb8ubTm+skJjiBwraGlAjWQH7xjq1hUxgAV8ShKkzSJcvtbxDDif3eRUjlu0aFFa1EAGb5kM6jJ541omyw9B733ve1PQO9\/5zoQsUbhaDM\/Jjvucdt1117TrY2SGUKZNN920WNa49tprixdKlj\/Qf\/zHfxRrYLfccksxhfW22LTQFd322PoYQCs30yqrrJIWLlyYtttuu2LDqLDvC5HN2V5cfehDHyoOHzzqqKOSdWLe23333Vcc6meTqyPBXeuoiV\/HK8d7mZAm8G+soNVv\/f7u7\/6uWPuKzjefrzGopuWa29rgzu\/zcB0PEJSBZMcdd0x5XBl8yvcGbZkWLVqUFpVo4cKFxSBfmF1XWWWV4oP8VZZcq\/qdwVwV3yvOg9c3fEDjla98ZfEtpLA4AFVOz4tCvqxAue2EjzjiiHTQQQcV\/RxAq0OeB49QHDu4yiv4rqHP2Wefnd7xjnek0Omqq65K31qy3kemiprqX8eri6\/Kf5RxYwUt+5AcL+KJUK6UaeOTnvSkZaK52DrdE4GWqXh3MzUWCFAATAEIwkCqrCRAAUyA2Rtyn6MEASeEjwJ4pUH6OGCSFphVARjQspTi0xxhsvIp60HnHMSA2Wc\/+9lGECvnMc33CzSAvVPjUNLc\/OGHH05ll9gTytRB441Dj9mU4Qv\/2aSrSzNIfv2kbSPbS6aJX8eri6+zx7jj6\/Qz4AGScWGw++haWFxZR\/0VAAEjIPWBD3wgCS9evDgBE\/xymrr7XJ9VlniH2y2ZGgKlADBxkTa8Lw9\/3qnTIZRPXrkhF1ceV4CY+qiXb2WDX77muuS8uvhcZhzhBWeeeWYxJx5HYbY4+MEIH57GZlLe1DXX7hCQ\/gAAEABJREFUXJNse3jmM585DjVmVcawXeNB8usnbRvZXjJN\/DpeXfysjD+CRKEfkEI8EYPZoA6QMtjzooFQgJR1JV4UkBIHLCLPPE3bcF1aYAXAgBfigUWeHv6mgRdccEG6\/fbb06677lrsgQzdqkBMXdXLW9fwHNU9B+U6XeriQ59xXRdYZ7jsssvSr371q5GXufrqq6c99tgjAcozzjij+GUc58H7gHXPPfdMMzOPboMYhSJdnp0FwgIGrkEKnIAU4okYzCHjmoMUTyYHKfxxUw5gOXjRg+6xTcQiP90XL15cgBi96Q\/ExJMPYgt1Z4scxOQXMtN2XeAcKCg9DtBSeYb0RHOEhSeDvVunnnpq8hYGv6POAsO2gIEZIKXvASmDVFxelgG9aNGi4mWBQW6w555ULjvJcICXlzbAy33ow\/sCQgAsgCfqZeypEwJgKNLFla2kDzu58sTEh8ykr2NdiFfZJz\/5yemAAw5IDiQDWJdccknxWjdN+b9hz+cHya+ftG1ke8k08et4dfHjaGYDDBlsBl0OUjGQQw8D2vQuQMrV4AZeIdP2Okid+0mby263ZO3LtBEtXPL2NHQFXqaAOXgFT52BnXq2mUoCMTZ8wxvekNgURV6TuI4dtCZRya7M+W+Bn\/zkJ4nnxIMywJDBVgdS+++\/f7GvitfBm5oNSE2TVXlbPCfgldelCbxCfyC2ePGjU0kg5gRSeeX5kLVPjE1RTCXt08MbJ40MtHhSr33ta5f7NMebyrl4ysOwFyEHya+ftG1ke8k08et4dfHD6tw8qQCpGEAAS1xehgFp8BmEvKgAKRtIc7lhhAepcz9pm2SBlzeKvcCrKQ8nsASIhb3Yr2wjbVD3c3pl2WHeLxjFWpa9WN5oVP3ai927Ok93ysMwm3H+52WAACTAVJ7ylWsPqIY15SvnPVfu24CXBfte9QlbAjFeGBADYOwrrS1MruOkBR\/\/+MeHVp659i677JJe\/OIXp\/xQ\/ShgLp\/yoG5Rj2FcB8mvn7RtZHvJNPHreHXxbW0HpEztrJ+UQUp8nk8MLNO8GFjCPKxcLg8Pql+eV4QHybOftG1kQ6YJvEzzrHmVwSvSRr3iKp6tARj7srXpZ\/BHe3089wUf\/ehH0zHHHJPsVn88enYhBnrrW9+aTj755OTNYDkXC+8+mvb91szMo9sbmk55KKef5P36668\/1OIHya+ftG1ke8k08et4dfF1RqwCKWBlYDWBFK\/d098giqd\/XRl5fL\/65WnrwoPk2U\/aNrJlGWOzbtrIxjl4ldNGfevigz+u64Kddtqp+F4JeAxaqM2hO+ywQ5LnRhtttFx2AMvnOquuuuoyPJ8mVJ3yQMiRHBC+ox+muW6DH\/\/4x0vrYM3TdM\/ObEezWDivAykf2DtdweI5cLLz3AfPNis\/4xnPWJrnXLfPOPT\/+c9\/nhx74ygcX6EYY4jHBLz8dqHz9dvoYmxKO25a4LfZ7rrrrvSb3\/xm5GV7mnrboBO2LcyX5BC+o\/WXfsE\/F23hoWj91A5u+\/L8fJb1Ka\/lfcaV9wdTkEWLHt8v9fnPfz4dd9xxyeI5b2ou1n\/adHas98EHH1x8qL0w2yrhV6kt7fhqhRPSpLexmbfbuMILfHxpN3r5LKtxKTBXyvHkGaaug+TXO+3jmraR7SXTxK\/j8aRM68prUp7m4h\/XMKUySJnumfZZOwFeueywwnV6D5L\/IHn2k7aNbC+Z4Js2Wlj3tjEHL+tcpozaixfGLpFGeJJUgJaOtdpqq7XW46tf\/WriGgYddthhrdJaN\/Nm0Yee5QSmjeVTHsoy3f30WoAXDYz0JdM8npSrTi8+13wSIJWX34WXt0AOXmZDIZGDl++EI36S1wX\/93\/\/lz73uc+lBQvab9l6xStekRxkFnT00Ue3qsNcPuWBm9yqki2FBsmvn7RtZHvJVPEDpEz3gFPTmlSAlIVgHtQ4PKlezVBVp15pevEHybOftG1ke8nU8YGXM9J4X8JRZ+Bl2njllVem8LyCN+7rgu22264AIAt0bQt\/6lOfmvwUUtDTn\/70VkktnM7VUx5aVXAeCwVIhSfVBqR0\/BykgNaopnvz2PRVVRt5nKmiKaM2zMHLQ8q0cZLgtcAv4FggdR21JebyKQ\/Dns8Pkl8\/advIVskAKW\/3LJb3ersXnpQOHiB16KGHplGuSQ3aV6vqPMk8+9GnjWwvmSZ+zlu4ZJE+wCufNgZ4TeIhtMCbGQfye3U8aKO1Sa8jm07MtVMe6tzpNnWukhkkv37StpElk4OU9uFJASzA1evtXtV0T55V9Z6WuFHoN0ie\/aRtI9tLpolfxQNepo0+tM49Lz8CMu42XeBXQjxJTfmGWbjXqdDYFDLPd66e8pDXYT6Em0DqW6WzxXlSthrYIxWelKsH0CSetPPB\/nO1DpaTeF4BXn5oY9x1WWBxzc8XDatgi\/Ove93rEgR+7nOfm\/bee+9i81\/kP4EPpqPoga65yzxQRo8lHiS\/ftKGbA5S5Q+Me4GUzZwAC3CVQSryf6xaSy918UsFJhwYhX6D5NlP2jayvWSa+HW8PD7AS78ad1Mu8Bttwyr0+uuvT4ccckjyU0Nf\/vKX06c\/\/eniTYM4G1iV030wzQqjJR0Jmdo5JbYMUuXSbfYFSICJB2W6JyyuDFLltN19Z4FxW6D9Pocemjnz\/fzzz0\/Pec5zkrUQv4zrF3Pf\/\/73J59vcCPn8gfTVfP8HiZpZA+SXzktgOIt5W\/2Yk2K3cuKlKd71jWbQKpcXp5fHa8uPk87yfAo9Bskz37StpHtJdPEr+PVxY+7HYcGWt5A+rbQk9n2\/6jIeuutl9wbWHP5g+mozzRc2ZIXlYOUxfOqjZz0zUHKl\/nzzZNSx46eOBZY8Fd\/9VfJtG7Qbw8dBvaxj30secOQm++OO+5I9oBZgAdqdr7388F0ntckw\/l8fhh69JNfgBQPFjiFF1UFUgDKg8PUzlTvrLPOSjlIVeneS5cmfh2vLr6q\/EnEjUK\/QfLsJ20b2V4yTfw6Xl38uNtvwXe\/+93kM5xBvz2cmZlJwCjfy2Fa6ENXH8vaRW\/w4VtDaVtRnwox1qRJXYapQ1N+vts799xz01\/\/9V8nb3YDpHhXpoG57djSKRk2bpriWTS3R8opCLaxNJUT9ekl08Sv41XFV8WFDuO+jkKXQfLsJ20b2V4yTfw6Xjne2Mz74rjCC6w57bzzzkP9+a54Q+i45TvvvLP4GaOqo2raVNKX5ObSkyagO0wdIj+Ajv7rv\/6r+P3J\/fbbL\/luzwK69aiqPVK8KADFk7Ie5cc63\/72tyfxZR2jnHJ8ft9Lpolfx6uK94ImL3eS4Sr9BtVnkDz7SdtGtpdME7+OV443NtuM4YFlShks0NEvvvjiZCG9xKu9bfpg2hPTU\/6DH\/xgUklbKl72spcVeXUfTKfE2+Qt8Zpiqpd7UoWhsj+me9ooQCqf6pkGZqJdsLPAE8ICxSGAJ510UurnlAdgZD9WUHwwbc3qwAMPTKaaPsJ2lHO+pWIufzANjGfTI4AUgCovmlufAl7lPHOQAlAIYAGuAKl+dGkj20umiV\/Hq4sv13dS96PQb5A8+0nbRraXTBO\/jlcXP+42LI5b9usb\/RwLY\/e8ne5BPpjmqfmVHRUw0HhXMzOPHqksDj0RPpgOkAJK4UkJ1y2a5yBVfrOHx24ddRboLPC4BYa25cFvon39619Pzn\/3ptCJqDk5i2cufzBtveNxsz0eqgMp3lXZkwJCvKX8w2IAH57U47k2h+p0KVKV\/rSR7SXTxK\/j1cWX1JvY7Sj0GyTPftK2ke0l08Sv49XFj7sRhwZadrw7Z8cu+K233jqVydswlfO9Gg9krn0wTXcAhQAS76m807wKpEzrgJJFcwDlygbAS54ddRboLNCfBYYGWnbAX3vttckbhSryATXVeGEHHHBA8lrfZtNLLrmkALg0hf8AFCCyHhVbD4a1aD7I+kA\/advI9pJp4tfx6uKnpZlHod8gefaTto1sL5kmfh2vLn7cbTo00Bq34qMoD0iFF8UbBFCu1qPKWw+Ub7oXnlR5ParzpFioo+FboMtxqKAV+7Ms7Nt45hc\/7Li3Iz5MXZbZfvvtkwFvIT9kxnWtAinTPsDFw8r1AFCACEiZ4tHZdM\/UT1wu2yY8yPpAP2nbyPaSaeLX8eri29hmHDKj0G+QPPtJ20a2l0wTv45XFz+O9srLWGA3vF3xwwCNOMFh7733TpdddlkCWP\/wD\/+QDGw\/aKHgkNl3333TpZdemrbaaqviZIirr746jfpfDlJt1qOAVL5oDqzURfyode3y7yzQWaDaAgu++MUvJmtMFtKrRdrFejv4la98JdlY+pd\/+ZcpztLyLeLNN9+c5D\/OUx4AFG+J12SKVwapcq14UjwmoASceFGusWg+7Pn8IPn1k7aNbC+ZJn4dry6+bPdJ3Y9Cv0Hy7CdtG9leMk38Ol5d\/LjbcIEfZfQjmBbIBymcJ+WXfXhOMzOP78+yh8uU8OGHH04W3m1AtS1iZuZRGZ+wbLHFFum6665LtkjMVocAKYvmQOrR9ah3FMfkAK9yvlUgBbAAV+dJla3V3XcWmB4LFIcA8rQcHzOIWvZg\/e3f\/m3yvaF8TDe\/853vJFsbgIDvzgDWsE55AFK8KGtQOUhZNC+DFIBCAAkwldej6EfnJhr2fH6Q\/PpJ20a2l0wTv45XF99k43HyRqHfIHn2k7aNbC+ZJn4dry5+nO2mrAX+DJtuvPHGBAh22mmnxMPyMS+PCtDM9pQHWyTs9ZrtyQdOPzB1tSufm9vRD4tjsMdph\/IpAeMsuytr+O3tZduwsaNNfiMBLUel+Kj6M5\/5TAJSf\/Znf5Ys9rdRKGQC4A466KA07JMPPDH6JXr1m6ZJfpD8+knbRraXTBO\/jlcV76VGk01mwUuzTVOl32zzinSD5NlP2jayvWSa+HW8crz9mOLGTbMCLYAEZYO8gcwVtz5muugXO0444YRkrcsnPv2c8mA65yNuU8A8b2G\/0Wjh34fZP\/3pT9O\/\/du\/FefR\/\/mf\/3nafffdU+g1zKutGdOSXz+6tJHtJdPEr+NVxWu7YdpwkLyq9BskP2kHybOftG1ke8k08et4VfHadNw0K9CqOuXBlgW\/6mMal1fCWtnTnva0ZDG+31MeAJe8XGM9yls9AKicG264If3nf\/5n7S58T4KOftDZ5wedDUY5DozRcdKsQKvqlIc111wzibf4nlfAWoLNpRtuuGGynrT22msnbywt1JPjMV1zzTVpyy23LM6SFxdky0F50RyABb+7dhboLDC\/LVBVu1mBVlVG5vU77LBDOvnkk9M555xTLPKed955yZ4ti\/K2Qpgy7rHHHsmpnGeccUayYH\/kkUemW2+9Ne25557LnZ7aAVTq\/nUW6CxQssDQQMtWhne\/+90F+Jx44onJ\/NfppTvuuGPygxfWs5Rts6YtCrZC7LrrrsXerVNPPTVtuumm2B11FpsHCm4AABAASURBVOgs0Fmg0QJDAy2leFP4nve8p\/CgzKF5Uk41tcEUH1mkty\/MmpTNptN8ygN9O+os0FlguiwwVNCarqo98bTpatxZ4IlggTkNWs7v4sk9ERpqvtfRCxnLC9Y+N99882SrjDfO873e87l+fonL4Qna1PHrjmMfRpvOSdBytLMd7occckh64IEH5nO7P2Hq5mN7lbV15sorr0w33XRT8lZZXEdz0wJAypq2H8D50pe+VOwa+N73vjdwZSYKWn4FqLwxVY2gsQrHuVwW9W19iG0SfoTDR9a77bYb8Y6myAKzbdPbbrut+G7VmqeXNr6qKG+fmaJqTkaVCZU62za10fv1r399sSvA53zGr7YdtBoTAy37t5ynVVWBXmdu2bBqe4VpRFX6Lm4yFhikTX3I7gsKmvvky0PKVhn3HU3OAoO0qUNAn\/KUp6R99tknbbvttsmR7MPYxjR20HJ+lx+9cDwNg5SbY5xnbpXL7u5nZ4FhtanjjWyFWbx4cTr00EOLAyJnp1GXalALDKtN7Sg4\/\/zzk\/VnX7BcddVVg6qWxg5a9mPZFmEvl13y5RrYBuEIG6A2MzPcM7fKZXX3w7HAMNrUoq0nspMgrG\/tsssuxbRiOBp2ufRrgUHb9Ec\/+lE66qijUkzxzY44KzaS96tLWX7soOVEU0fWmN4961nPKuuTAJaNqquuuuoyPGsc999\/f\/Hr1csw6m66+LFZYBhtakng5S9\/eTr22GOX+5xrbBXpClpqgUHb9L777ks8Z6cWW8vyKZ9z7qxTLy1kloGxg1YvPeNImipA65W240+nBXq16UMPPVScXHvBBRck61rWP5DPwKazRp1WvdqU43H44YenL3zhC2mbbbZJO++8czJ72myzzQY23tSBVj81YgRvNvpJ08lOnwVWXHHF4nvVb37zm8VrcR\/UIz9+Mn3adhq1tcA666yTrGfZuvKNb3wjOdZ9ZubRJZ+2eVTJTR1oeSXKreRelhWG3rY7lOO7++m2wGjadLrrPN+1m2SbTh1o9Xvm1nzvHPOhfl2bzodWXLYOk2zTqQOtfs\/cWtaU3d00WqBr02lslcF0mmSbTh1o9Xvm1mCm71KPwwJdm47DyuMtYwxtWluhqQMtmtpc2J25xRLzh7o2nT9tGTWZVJtODLRip2zV2z+nmR5\/\/PHFnix7PG655ZbiUwA\/HoBsQnQqQBhvGFdnfznjXv5+uGOQPH\/2s58Vr+7lVUVl\/X1\/Sa4cP4gO40r7qU99aukPibzwhS9MPo61UbTcPr4pHPY5alG2bRJs3rbOYW82r0orL\/H4ymibb8gNsy9FnnFlV\/2EbmeddVaKPuu+igbty03jdBRtGvVsuk4MtJqU6sUzMGxQ1bl6yU4jf67rz6YxeBwh4z4n9QNggw6YPM9hhfUZB1BGfnfccUfyeUncT\/vVp282bK633nppgw026KnugQcemGYDvAHsAFJb9yxojAJTDVq2\/etQTkEN8m0a++hsNq4JTzP50j10d33Xu95VqDtk\/Ys8x\/kHMCFlahN1Q44g8Tpc\/Pve974EJIRHQQcffHDxS0O+Z1tjjTVaFaHPsH0uXPUzdTl\/msJnn312+uUvf5ne+MY3pvyrkbwNtINxY\/zQ3S9YjbIdlDFOmmrQqjKEX\/2JQVHme6KUXeSqp70nhydIyJoK+P3Ecn7uc1efPHdcHN5syO7g0L\/qOyznSClDWYie9M3LiqcgflBVPavsIS7PS1jayMeVPXp18hjoBgaSD\/Jl\/1ve8hbB9Itf\/CLldpWnvJURVFU\/iekZMq7uo96RRhyePOUtXROxo02rZJ7\/\/OcnJMzz6pUeXznKU27o4h6xobyqqJes\/pS3ufyijnl+dKCr\/qMf5bxy2LTO5s5yvHu6KiNIveSN5+oeuLv3YMq95ra6SjsqmnOgZWetJw2D5B9c6xhVUxXuMR55pFFMLTWGe+TJSy7yFYd0TucB5fHC4jQ8mWESnXRWZUS+4uhmwCH86FAh40qGvsJInavsIQ6PDBKWVjiIPV796lcXZ\/1HXN3VVMWUJeeHB\/Ttb387ATE8nV2e8nYfpH4GIH7EqQc9497VfVW98doSPelLXh9AwnTimQi3oSpd2JDe5fTiy3qLi\/7jqj\/lbS4PdqGf\/uoe0ZGuwNavX4mrI+kAHP66666b\/Pao8CDt3Y+uyhoVTTVoaTgoH08EVx2GMUyzfMYjzJjRMcRzj5GpGT4eGWHpNbxwuNTKsUYgLsgg+uQnP1ncykd+SFjkbKc+daArT1SlP\/1QPuiq5HgRgI3ul19+uexS1DHXXWfWqdmEbQhGfgYGz8kg8jJEfvhl8uO54sgZdNoGVQ1ceciLLDurC31iKikenxzdw+70oA9Z+ilvEArbh6cCLIXlGZ6jcC+Shu70Uhd1kqZqGoZHhqw00pK1iK6+UW6VnH6q\/uTJSiO83377JZ6UcBAgZP8gtpNevqecckoh36a9gdtVV12Vop\/Lhw7GWltdQ6dRXacatJoqHR0kb0wG9n1TpNPRNZp7BjdQDVj3GkVDCFsPcVyOcJBpjcGkk735zW+O6CQsTofQmEsZNQGgEB3JFWgSpRcdhIPKcQEMwee18F4MAN5MxMfVCRnl46d1Zp2VjDe10uqU6hzT07xcg8GgIM8rAZTCZWI79i3Hq596oijXoEVk2VnZwuoTU8koKwcWb5HpQ1a7al\/h2ZB+AtSlDU+FtyIsTr\/QP4R7EY+R7uTUxfqScFWfwCODn5fnHpXbRFxO0UbagY20lQd5LtMUppM+SCbykkf0PfZt097St9WV7ChpqkFLJwUMBloQz4FBNIYBYpAarOLM4TWCMPLU4BoLew1PVhjlU0v35bWyaGDAlXsSwuKkCRnhfki9nBkVnTnS0pXOcV\/WSbzBZ4oIFIKiU+Ij6VZZZRXBggBXyJoeFJFL\/oT+bEmnkCG\/hF0s+AJv4SoCnNpFG0lflpEP4IpygD3dcrloBzbNy6J\/LqtdtW+etp9wDHppnCAhPyQsjg3UQ7gXlR8mUYeqdDlPeVV1YKOwvWvexyLPAHNHu5T7DRnjQlsEqUu0Cc+VBxvtoK54ykLaSR7lNhBXpja6ltMM+36qQauqsoyN8Dwd77rrLsFW5ElqcbiV8JCEPNGiI8XVl+86cL9F0N86B68FAJhuyLPs8ejUQDHslJcD4Cy0yiuPHySsLupEF2QARX483Ai3ucbAaiPbj0wMemk87AxWJCwO9aurNIOS6XSARvQV7csbirw9qHiJ2pynH\/FNV20SHhQwUv8m+Ta8Nrq2yWdQmTkHWuUKr7zyyomHIp43pYGFEc8q98IWLlyYPMHxyoPDU17j4uWk8+hEBmOZeBq57KjDAMdTkk7WrGKKUq4LPXTaHEgMCPFIHp7Ewgi4uS\/Xz71pIJmc2Di8PVf3Od\/0hY4RF94G+7JzxLuG7gYkzypkPVxyWWVoX2n6JQBtOaFXOg9Bsr3kQueQi\/uoQ8T3uvpVqdDLg8f0Sxr1Vn9hpP8hU1lTTHGDUL\/trSx2aaMr2VHTnAMtjYcYhqsMiOKJIv7cc8\/FKshT1AB1w6XngUjjHgBwdYU1iIV14aBYpJWebMR72nhCe0XN5Y74cV51aB1bmXQAYMJB6kVHJCzegOCZGVjuEZu4shsSRqaQ0tZ5ZAAxpjnSIemC2Ivd3AMhgwS5Z2f2Fqa7qYtwDMiwO4CLxXl87VouR3wbAsihD3AAxjkFoJMh2ytPOtOdnKt7YQ9EwCvcLwXwSRd7sYRReICmsmwvrhcB+Vi41+bsOtv2LpfVpGtZdhT3Uw1aOqmntgEUFK60hghXmTcQHQ9QhazBw2h4ZIR12vAC5EXWgNJh8YN4MbFInOcpTCZfjHU\/DtLx1NuAtu5Bd1f3eflsVq5jLqu+iE3YRtqwBbmwW76ITCanKjtKi8JGyrCAbqBZVKc7O4snF7qLxyfH7myrrLz9I0\/x\/VIMeuWwYTl9DGbxBjoPXbiO2JvueR3I5i8Z3Pcip\/PmD1H5obC\/9MCHB1inOxmUt5889AH2w2NPdp1Ne8tDXsC8l67KGgdNNWjVGUCnN0fXECHDkzCQ4j6u4vDinrf1+c9\/PsWgFi8\/Uykdw32Q6V\/ZO8GzZpPnKW4cpL4nn3zyMkXRBYkECDq8OtataQEpdQUQ0qhHpHeP2EG91d99FSnDW0j2reLLMy+H7jzC3O7SuReP7x7RqZyve7rjpz7+8OoMeknCmxPOyaCkhzhv6G6\/\/XbBWirrEvYCCrWJahjHHHNM0v+CLQwoXMU5clq7BvCI64e0A3tGGmFxce8a+uftzSEQjx\/US1fTR\/YO+VFdpxK0GDZ338vhfDDkhmH0sqy4XEY4BlzIyk8nie0EeeczmCI+5HO+\/MqU568uZX75noy86RFgQiYvO8p0JRvkHsV91Fc+8ov4uCpL3jnl6cmpr7Jzmbqw8qQpkzzLaXK7hDzgE1+WLefLYyuvaYVMXR7ylDe+8tiDXcTnlMuou2lxpFFGLhthdpQnkia3l7A4vLIdIl3oQh9hskiYPq7ur7\/++uJTJemi7Ljm5ZCtonL50orLZekqL7wg9+JDTppeurIZ3SOPUV2nErRGVdku3+m3gDU40xtkbS005n0g9\/2s7ZDvaH5ZoAOt+dWec742PF6kIqa6wAtZsxFnGjebaaK0Hc0VCzTr2YFWs3067pgtUJ6CxPQkruOagpSrbdqjbHrUTRnLabr70VigA63R2LXLtbNAZ4ERWWCqQcuRy8OiD33oQ2m29NnPfjZ9tg\/yir0X+bXdJvJjmHU0or7QZdtZYE5YYKpBq2lQ98vrBSJNfJv9+qE24NgLjO2RqqNXvvKV6XF6PPyKV7wiVdFLX\/rSlJP9NjltttlmqUy2AQRtsskmKaeNNtooIWtNHf3+0uOmn6i2GDfSTTVoPfLII2mttdZqTeM23rSVt8IKK6QqWnHFFVNO1o1yesYznpHKtNpqq6Ugu7xz8tkU8tt3QVtttVXKyeZLdNBBByV09NFHJzvGXT\/xiU8kZKEdXXPNNQlZL+roB8UWh7lih0mMgakGLd8N2rDWlq644oo0KNWVZUd2He\/DH\/5wakNHHHFECtp\/\/\/2XhiPOhr4msnMb2dXtGrRo0aK0qIIAvl3XrmiUHaw8lQ1PODxYnipgdA1PNLzN8CjDe4x7\/JD97GPTc\/lF3oPUx6kPg6SvSjtInv2kbSPbS6aJX8eri6+yxSjjphq0RlnxurwN7irKB3+ZXwUYVXEBMq5l4BG3ePHitLiBAtzKgFcHmEA2B9sqQC\/LlPNSZpRXBlQ6Rz3y+rIPe9XZuFd8ACBwAlII2CEgBsxQHcgFwEmPepU35fxOvZIFOtAqGaTudhhf1+d5D5JfP2l7yQIY61uuKAcfYcBkN7prGVAB2nHHHVd4jDnYAUKfSgVIukcANOSkRTkQKkOZiC65vZrCZZADbgiwIeAW3hvQA2q2Lwwb0HrZuqkO\/aS9LvdpAAAQAElEQVRtI9tLpolfx6uLb6rXKHgdaI3Cql2ey1gAACHeF0BCAArlQAjEAtSAXBn0gkcuwE4e8pP\/MoWWbgLYcq+tDtCGDWYlVbrbAS3QgVZLAw57Pj9Ifv2kbSPbS6aJX8eri29p7mXEABICTghQBdgBMGAWIOeKxOEBN\/LSLZNpdlMGtBzMhHlmbYBskDr3k7aNbC+ZJn4dry4+M+VYgvMNtEZmtGG7xoPk10\/aNrK9ZJr4dby6+JE10GMZAzcEpIAVcANeQCz33NwDNET2seTLXIAZsIqpZkwzgRhaRnjJzSB17idtG9leMk38Ol5d\/JKqj\/V\/B1pjNXdX2DRYIEANoCEABtDCQwNkqArMABkQQzmIAbdpqNsTQYcOtJ4IrdzVsZUFqsAMkKFeIGYamYNYqwI7oVlZYOyg9etf\/zqdfvrpyRsrO4i33377Ym\/Vb3\/721lVYFyJhj2fHyS\/ftK2ke0l08Sv49XFD9pew0rfVj9AhsoeGRBDZX3CE8sBTFxZrnzfVh\/p2sj2kmni1\/Hq4uk0Tho7aF144YXFRsx99903XXrppcUu6kMOOSRdffXVqfvXWWAuWCBADJDFtBKAbbzxxsuoD6xMI2O7RdU62DIJuptWFhgraN17773J8bF77bVXetvb3pae97znJedqb7nllumiiy5KPttppfUEhIa9CDlIfv2kbSPbS6aJX8eri59A01UWOUz9AsT8wEVMJb0EyAsOAMs9sJzfjz5tZHvJNPHreHXxeT3GER4raH3\/+99PPs1xdOvMzExRv5VWWiltscUW6brrrkvl86V1httuuy3dNgvyizWzpUKx7k9ngVlYQJ\/lgXlj2QvAeGC8r24RPzN0i+BYQQtg+aB31VVXXUY1bvX999+f7rnnnmXid9xxx8S9ng195CMfSbOlY489NvVLfnCiDfkJMnTqqacm1zL5qaw6uvjii9PFS+icc84prsJBjikuk+OJ\/\/7v\/z65BvnJq5ysU3z9619PrnXUxK\/jVcX\/+Mc\/biynrvxRxFfpN2g55TwffPDB5Lx5MwtfA\/iAXF+PTh7el0X83XbbLZ1yyinJj3D00qNcTpV8L5kmfh2vHG9NOuoyzutYQUsjOV3AzuhxVnIcZfmppzbk9wrRz3\/+8+RaJt5oHfmhAaSTuubk14nKdNlllyU\/jOAa5FSFnADgP\/\/zPydXBOTK5MSBr33tawn5Kamg22+\/Pf3mN79Jrvfdd18KmpmZKX7taGZmJj3zmc9MphXo2c9+9tKw+0mSI3yGXX5Tnl48vf3tb0\/5FJJXFn3TrMAvIPmln6OOOir5zKhOv6ZyIk0vmSZ+Ha8cr1+E\/uO8jhW0+q2YQejpVEWeYMOiRYsWVZ6SsKghfuHChWlhS1pllVWKY1lWqbn2a5dRyhs8Zbotm56bygQZWEEGXNDZZ5+91EPm7YbXChTdB4WcdFdeeWW68jGSf5RJl1HWdxJ5AytTSNNHZBE\/18PDnW2sf5k++vQo5z\/Rw2MFLb+jxmX2RC4b3rTxSU960jLRfsm2Dji22267tN2QqAoUe8XpaG3JS4cmeu9735uaqDbt296WqnSo0r0K4Mu2LYNwDrLLNMwAN0AoKIAJSF111VWFd+EKxAxaBOCOfWy6LozEk6kCuQFUm0jSADBvIbVleQFfXX3k3a1\/Pd48YwUtB8Y9\/PDDSad9XIWUbrnlluSQOQ2Yx09T2JRsmPr0k18OHsKmlq6oDDTuczByhpX7KoAPcHNCqbBBk1OA5R\/\/8R8vB6rB88s4eRr5oBe96EXFeg6wVD7SxgsXLkwLlxDd+7WnfoOAXQ50AMzgRjnAuccLcJNOeuX2Y3\/ybWiQPKXlfeUL+Pl4CO\/L+tcb3vCGxANjgzq95FfHE9\/Er+PVxctvnDRW0LLFYe211y7WRmIzqXUgp1ba9mD9Y5yV78qavQWADrJGCYSCgBMCWgGUQAx5sRIAB\/Ry79I9Cj55gIfkh5ShzDZaAycgZWDz3hAQ46kBNut67nNAa5PvOGSA1eLFi5OpI2KTvNy77767mH4DMB4YTwyI5TLzOTxW0Fp99dXTHnvskc4888x0xhlnJG+xjjzyyGQauOeee6aZmZmptbUFzmEqN0h+\/aRtI9tLpolfx6uLr7MhMEKACQGp7bbbLm23hAAYMngBW4CdMBKPD+CQ9KiuLPEelkANmCEABsyAmvBswKzfOtMjqDptSgFgpo9VAMYDs+ZFZ2tgQAyAVS3BRFmudeU18ZrSSDcuGitoqZQniCfEaaedlnbdddfkTZnX\/5tuuil2R50FWlsAyCEAtWjRogLggBwQQzm4uQdoaOHChWnhEqoqKDw0QIaAASBDgAzQVaUbR1wVgInLywZidDbGchADbLncXA6PHbSe\/OQnpwMOOKDYjwKwLrnkkrT11lunaf837Pn8IPn1k7aNbC+ZJn4dry5+Eu0cwAbQEADbdttti3W68NSAGaoCM0CGAsTCIwNipp9Rp0Hq3E9assBq8eJlp5Cvec1rQpWl1wAxU8gAMYBmT1iu+9IESwLyX3JZ7n9d\/HKCI44YO2iNuD4jy37YrvEg+fWTto1sL5kmfh2vLn5kDdRnxqFfFaDx0IBZTDnrgAyIWegPELNfbbaeWOjTphpl2QAwi\/j5NJL3Wc4PiAEregOvHMhMK1Hd1LJcbjnvcd3PI9Aal8m6cp4IFgBmBv12S9bUeGYBZLwxVLZB7olNeioZIJafE6YOSJ3KugeQmVaiOjADdqicftz3HWiN2+JdeXPWAoAMiKEcxMqe2DQBGGMHiJlOAjIL+giIoSogk64KzMqA5u0x2XHSrEDL91Gvfe1rl\/vAmeK+cXvd616XNthgg2T\/j7mzDaV4qDtPixVSGmR9oJ+0bWR7yTTx63h18Y\/WfvJ\/h6FfgJiBD8TsWSt7YVUAJq5sgX70aSPbJAPEjEkghgBZTCuFTYutj9WBGd0D0FZeeWW3Y6W+QUtlL7jggvTAAw8sp+h3v\/vd4siZddZZp\/ig1zdUn\/nMZ9KJJ56YYl9Wd57WcmbrItpZYOqleB1lLwywheLAyjqY6SOykB+8abgCM0AFtKyPAbAczPbff\/8EoHNAs1l83Lq3Bi3Ivcsuu6QXv\/jFyca8KkW5nDaIHn\/88ekFL3hB2nvvvdM73\/nOdPnllydf+HfnaT1utfXXX\/\/xmz5D\/aRtI9tLpolfx6uL77OqIxMfhX55nsAKgFnQR3UeWL6I37ayeTl1aXrJNPHLvAAzv3\/JM8sBDRDX6TCq+NagpRHe+ta3Jsev2F9VVsgbB4t0L33pS5NNpMG3MxrvpptuKvZkOZ6m7XlakUd37Swwly1g7AAwU8gmAAvva7ZvIOeyjfrRvTVo8aB22GGHtNNOO6WNNtpouTIAk0P8HD+SM322I63XwQDLh9Ftz9OSjzN7eHmTpvJZQoPqM0h+\/aRtI9tLpolfx6uK520Pardhpa\/Sb9C82+Tpu1Hf4Fr\/8kD3PaZ+jngtpo\/e4HEOLr744uKrkbJebcrpJdPEr+OV441Neg+L2ubTGrR6ZQi0fBqhQepkLd6Z9\/dznpYze7irk6byWUKD6jNIfv2kbSPbS6aJX8erivdAG9Ruw0pfpd+gefeTp+UTM5aDDz64WAc2feSRxdgxlpyXZinG+WYe+qFfm3J6yTTx63jleGMz9B3ndWigNU6lu7I6C8wnCwAr00dTRwTA8vqFBxbrX9O2gJ\/rOo7wcqDlyF5uX9Bhhx3WSo8VV1wxPfWpTy1O46xK4POdfs\/Tqsqni+ssMJ8tEABm\/Qt4eZuX17cKwMTlMvM9vBxocQHttQo6+uijW9lgtdVWS6Z9\/\/M\/\/7OMvHvbIxxLY+roFWnZyN15WsuYrOeNNY6eQo8JtJHtJdPEr+PVxT+m1sQvo9BvkDyr0vK+bD8I76tuE6sFfMQDi0X8qvxyozfx63h18Xm+4wgvB1q8pTXWWCMFPf3pT2+lh8V2Z2I5ItliYyT6l3\/5lwTQgBayMO+s8di3Ze7enacV1uqunQWWt0B4X\/ZIATAL+HUAZhHfNNJaWA5iy+c6d2OWA63ZVmVmZiY5E8sbIr9l6Kys008\/vTjI3xlatkEg4e48rVT8wMNsbW1Btm3aNrK9ZJr4dby6+LZ6j1puFPoNkmfbtADMAn4AGE\/MNLJsL85AvIkEYuGJBZA1lVfHq4svlz3q+6GBFkWdifXRj340eavAsM7M+ou\/+ItkQxo+Evb9Eh4Zx9N052mxTEedBTILtAgCMGteppHWwHhhAGxhxVlhlmSAGOKNATEExFBMK1sUO3GRWYGW17QqbwpZroGzsZyRBYx8o+jsLIvwIScsDo8MWWmCP63XYc\/nB8mvn7RtZHvJNPHreHXx09K+o9BvkDz7SVsnC8QAGC\/sT\/\/0T5dupagDsTKQhUfmtzgBGcrBrK7ccbfprEBr3EpOQ3nDdo0Hya+ftG1ke8k08et4dfHT0JZ0GIV+g+TZT9o2smRyEAtPLKaTVUDGLoDMb3FyShCvLMDMfjHncAEzlAOatOOiDrTGZemunM4CE7YAEIvpJG8sgEzYtBKvCcwAmk\/1gBkCaH6sZNzVmh+gNW6rdeV1FpgnFgBkgMq0khcGwMpgBtDIVFWZV1YVP8q4vkDL3q04K+u5z31ucYpDeZ6by3TnadU3Xdlu9ZLLc\/pJ20a2l0wTv45XF798bSYTMwr9Bsmzn7RtZHvJNPHxcjADaMDMOlkZ0HyaN+4WbA1a119\/fTrkkEOS78e+\/OUvp09\/+tOJuyjurrvuKvTuztMqzND96Swwry2QA9rUgpaNoOeff356znOek\/yqxyabbJJe9apXpfe\/\/\/3FOVk2lKYl\/7rztJYYoeV\/C6UtRZcT6ydtG9leMk38Ol5d\/HKVaRUxfKFR6DdInv2kbSPbS6aJX8erix9+6zTn2MrT+tWvfpUcK2Ohzs73yHK99dZL7qGtUx4s0nXnaYV1umvZAttvv305qrvvLNC3BVqBlnOgP\/axjxWnkOYl3HHHHcknO\/ZeAa1RnKeVlzfJsA\/Ih1n+IPn1k7aNbC+ZJn4dry5+mDYcJK9R6DdInv2kbSPbS6aJX8erix+kHWaTthVozczMJAf3OQsrCvG5znHHHZdWWmml5CNroOXTAR9Fh0z5yiOThw+ry7y6e4aaBqLfMPUYJL9+0raR7SXTxK\/jVcVXxQ3Tpv3kNQpdBsmzn7RtZHvJNPHreFXx4oZAfWXRCrTyHOPXdPwaz5133pkcfl91kmmeZrZhnwN19IPis6jODp0dprUPzHZ8zzbdcqDVdJ6WV6F77bVX+uAHP1h4V74kf9nLXlaU3Z2nVZih+9NZoLPAiC2wHGiZ6tlrFRTnaVmIP\/DAA9M999yTPve5z6WPf\/zjad11112qnuNnTPucn7U0cknA\/Xw4T2tJVbr\/nQU6C0yBBZYDrarztGx5cMwMfW1r4F3NzMy4XUreInbnaS01xygDVBHHNQAABLdJREFUXd6dBZ7QFlgOtKqscffddye\/xOGnv7wp9JYwJwvwMzPz+zytKrt0cZ0FOguM3wKtQMuOd7vf7YJ3jEyZzj333ELz7jytwgzdn84CnQVGaIFWoGUH\/LXXXlv7Fsv5WqEjQHNGlrOynJnl7CzeWfCFxeGRIStN8Pu50inW3PpJ18lOnwV46+9+97vTVlttlTbffPN0wgknJG+qp0\/T0Ws0X0qwu2Dvvfcu2tSSkiWmYbRpK9CaNiOarn7gAx8ovoW0yD9t+nX69G+Br3zlK0Wiq6++Ojmr6aabbkp+O6CI7P7MSQsAKUfXeKnnHC6\/DfG9731v4LpMFLROOumkVPUTZdBYhV\/ykpckGwZ9\/nHFFVckLwTU+ElPelLaYost0m677ea2oymywGzb1IFy9v7xxP3U3MYbb5y+853vTFHNnriqzLZNd9999+S4m5mZmeRXuIxfbTuoJScGWvZ8XXrppZX6X3jhhcWm1X333TeRMWVwmoSncFryz5vKHXbYoZhGLLnt\/k+JBQZp0yOOOCI5t0lVnBbiIeVbV\/cdTc4Cg7SpX9F+ylOekvbZZ5+07bbbJstMa6211sCVGTtoffGLX0zWsLyJZJByDe6999503nnnJZtYHdTvZ8f8uo\/tFBdddFF65JFHlknS3UzeAsNq0wcffDD5wRM\/fnLooYcWayGTr90TU4NhtanP9pwQY\/35hhtuSE48HdSiYwctbxiB0Iknnpg23HDD5fS3OG8jK1CbmXl0L5jvG00Hr7vuumSrxXKJuoiJWmAYbWrR1hPZN63Wt3bZZZc0M\/No+0+0ck\/Qwgdt0x\/96EfpqKOOWjrFNzvirNx6660DW3TsoOXE05122imZ3tlBX64BwFphhRWKD7RznjWO+++\/v9iRn8d34clbYBhtakng5S9\/efIjCjr45Gv1xNZg0DZ1gALP+eabby7Wop0G4+gq69SDWnbsoNVL4dmcBNErz44\/WQv0atOHHnoo8aIvuOCCYl3L+geyTJAmq3pXeo0FerUpx+Pwww9Pvk\/eZptt0s4775zMnjbbbLOaHNtHTx1otVc9FUbwZqOfNJ3s9FnAx\/bnnHNO+uY3v5m8Fg\/yImb6tO00amuBddZZJ1nPsnXF6cZvetObhjLlnzrQ8kqUW8m9LBsHetvuUI7v7qfbAl2bTnf7zEa7Sbbp1IGWQwTt6fDZUG7MW265Ja255pppGK9M83y78Ogt0LXp6G087hKG16b9az51oGWLw9prr11ME2xGUyWfeHAxbXvoFmlZZG5R16Zzq73aaDvJNp060Fp99dXTHnvskc4888x0xhlnpBtvvDEdeeSRyavSPffccyhz4jaN0skMzwJdmw7PltOS0yTbdOpAS6PYXPiOd7yj2Gi46667Jnu3Tj311GTvCH5Hc88CixcvTl2bzr12a9J4Um06MdCKnbJVb\/98fzaskyCajD73eNOtcdem090+s9FuGtt0YqA1GwN2aToLdBboLNCBVtcHOgt0FphTFuhAa041V6fsPLdAV70WFuhAq4WROpHOAp0FpscCHWhNT1t0mnQW6CzQwgIdaLUwUifSWaCzwPRYYC6D1vRYsdOks0BngbFZ4P8BAAD\/\/88\/khsAAAAGSURBVAMA16MnDXKrx68AAAAASUVORK5CYII=","height":181,"width":301}}
%---
%[output:334715cf]
%   data: {"dataType":"image","outputData":{"dataUri":"data:image\/png;base64,iVBORw0KGgoAAAANSUhEUgAAAS0AAAC1CAYAAAAKoal0AAAQAElEQVR4AeydC7xN1dbAx9LjujefcHugPE4epUsRpzy7qJtS9FDq9JDqEj2lcioKIVFKRUpPEeVWSi9SSZFHhCiJ8kq41\/W6uZ1I9zv\/6cxj7W2tvdda9t5n7b3n+Z2x11pzjjHnmGOtPfaYY405Zqn\/mT8jASMBI4E0kkApMX9GAkYCRgJpJAGjtNLoZhlWjQSMBESM0srwp0APb8mSJXLaaadJixYt5PTTT5eGDRvKZZddJj\/99JNGiXt86qmn5MMPP4yLBwJ4J5xwQkR\/999\/v\/z888+yc+dOueeee2TZsmWgGjAS8CUBo7R8iSu9kevXry\/vv\/++fPrppzJv3jypUaOGuk7WqE455RTVPv3NnDlTdfPggw\/KH\/7wB3nggQekTp06qizIR6ELRvbs2ROE1NCkuQSM0krzGxiU\/V27dsmOHTvkqKOOkt27d8vQoUOVJYY1xjllwJAhQyQ3N1f+9re\/yZdffqm6Q2GMGzdOWWzNmzcXbUGpSpePP\/7xj9K5c2f5+uuvZcWKFXL99dcL1t9\/\/vMf6dmzpzRu3FhOPfVUefjhhxU\/lN9yyy2q7Morr5QuXboofKy9G264Qdq1ayezZ8+W6dOnKz6aNm0q5513nixdulT++c9\/SocOHaRv374Cf1iUL730krRu3Vq19\/HHH7twaYrTQQJGaaXDXUoQj3PmzJGTTjpJjjvuOPnLX\/4i\/\/rXv9QXfsqUKbJu3TrBGgK2bNkib7zxhlD+448\/KsuMa5QcrIDD1O6jjz6Szz77TA477DB56623qIoJFSpUkCOOOEJQSBpx7ty5UrNmTaWA6G\/58uWyYcMGee6555QlRj3W2ebNmzWJwN+ECRPUWD744ANBgX7++edKKdIGiNu3b5dGjRop\/ipXriy0O23aNHnooYcUr7\/99hto6Q9ZOAKjtLLopmPNfPXVV\/LDDz8oawcr5L777pNZs2ZJ27Zt5ZBDDlFw5plnyhdffCEzZsxQ5VhJ\/\/d\/\/6esFsSFIkFpHH\/88WqKOXLkSFm4cCFVvqFVq1bK7zVx4kQ1ZUQZbtq0Sb777jvBerIsS4455hipV69ecdstW7YU+Clbtqz06tVL4T766KPy8ssvy8aNGxUeFiRWo2VZUqpUKcX7QQcdJCjOgoICAcT8paUEjNJKy9t24EzzBf7rX\/+qvry\/\/PKLUla6VaaFKDB9HX3EkY6yQPkBKJp+\/fpFo+13jYWElYW1pSuff\/55efrppwUFeNtttykLkOkn\/iqUDXicM53l3A68ROjevbtghXXs2FG6du1qr444jzWeCERzEXoJGKUV+luUHAZRDEzzSpcurXxZvO1DWQHvvfeesnLwZXFO2datW4XpINzge2I6hgJC4eE7YppInRuAN2rUKDnxxBOVH03jMW0799xzhZcEKCEUIJYdUzr4g881a9YIFqKm0cd\/\/\/vfyuLCl4UFpfnT9eaYmRLILqWVmffQ86gWLVok55xzjvJjNWnSRE0L8\/Pz5ZJLLlHTJqaLQJUqVeTss8+W9u3bq3Kmaddee61UqlRJ9cX0EYXGkakaCoNzVWn7wHGv+6NdlBFOdxuK6nvgwIFq+obPCZ\/bK6+8ohzvKMLGhQ56wiOOPvpoO5k6xxdWvnx5wWK8\/PLLlUJcvHixmi4qBPORkRIwSisjb+v+g8InhC8KRUAIAk55HNhYNEydmO5RD3BOGUqmf\/\/+yr81adIkefLJJwXlRN3NN98s4AIa394reN9++61yhNPfggULBP9ZmTJlBGBKCE\/4nfCpYVWhnEaMGCGDBg0SLDkUKu0\/9thjyi\/FtLJbt24C0Bf88aaTtuEPxYriQ0GOHz++2KLjjST8QEOf9A0PXBtIPwkYpZV+9ywrOCYwFSXWrFkzwV9F2IO29LJCAGaQrhIwSstVNKaiJCVQt25deffdd9UUFkuNt4zx+TEY2SABo7Sy4S6bMRoJZJAEjNLKoJtphmIkkA0SMEorG+6yGaORQGZIQI3CKC0lBvNhJGAkkC4SMEorXe6U4dNIwEhAScCX0iIXEgtnWUFPTiaAc8qoUy2aDyMBIwEjgSRKwJPSYikFQYmdOnVSC1LJhfTaa68JQOAeCos4msmTJyeRVdO0TwkYdCOBjJSAJ6XFGjMW2P7jH\/8QchmxuJVV9EBOTo6gzF5\/\/fXiZR4ZKSkzKCMBI4FQSMCT0iIFCMstSBdCDiYWv7JMgohljlyj1FiPFopRGSaMBIwEMlYCnpQWCdNYyX\/11Ver7JCs8SL7I6v9WRv2yCOPCFPIjJWSGZiRQAglkK0seVJapCUhhS3LKpgiktuIFLsXXHCBSrVL4jVyGmWrEM24jQSMBFInAU9KCyuKKSKr6sm\/xMYEBx98sOKSaSHX4KiCBH6QFtjAcSo9spGDkYP9Gbj99ttdnws2FCFHGSmF7DTJOk\/gV95TU56UlqeWkoREZkw\/QCI4P\/iw7QcfXL99hJ3GyOAHRKDSUHOvvEJJPgekoHbjk7f6zIKGDRvma0wIwa1Nt3JoUg2elRZMk1uJTQa+\/\/574YgjnjLqUs243\/7c8Hnw3OqypdzIQIqzspbUPV+7pUDaj1woFXpOV8d4fEQnU4yH76U+XZ4DT0qLTQRI+kaWyjPOOEMlc+NIriPKqAPHi2CSjUMIRhj7CMJXqmiCyCtVvKWqn5KWwYQvNsrarQWyqE8Tmfn9NuFa8xREBn\/60580ecYdPSmtQw89VMhvREiDE1AHjhfp8Cayd+\/eag878PGFsScdbyLJODlmzBizCSeCMZBVEhgydZXkt8mRqhVKS15uRZkwb0PM8fPGPiZCBld6UlrsooI1dfHFF6uQB718hyU8bOI5fPhwtdV5PDmxeQKBqFOnTi1GJY84KXIpY\/djQinYvqoYwefJqlWrfFL4Rw\/SR5hp\/EtAJHTjsQ0iCG82cs+nQfpxo9HKis5H5tVR1tbMldu4DCTr\/\/73v4o2Ez88Ka0jjzxS2GwAxYKSQrmwrAdg3SGCIW84x1jw5z\/\/WVB81apVK0ZDQRG4ygYFTDGx5ObPn19cb06MBDJdAviy8nL3bhqix4oSm\/BFbGtL42bb0ZPS0kJhOQ\/R7ygxXcYuKZRRp8vcjg0aNJCzzjpL2KBA46xcuVKOPfZYfak2\/1y9enXxNa9p+XXyChB6xQXvxx9\/VL9knHsFv33QbphpjAxWSUnK4Id\/\/SzNK+6OeA6vPaWM4Ndye3YuvPDCCHzwNBA3yfPGFmu6zMvRrwz4btJPqsGX0jr88MPl119\/VZtrskcdMHbsWCHYFCvJzjzBqGztxMDuuOMOe9V+58R57VdYVMCbyZycHEkWoDCT1Xa6tGtkkKN+OEvift363jY57sgy0uzkWhHP+C1t9+6ovX5P+YhyLzxWrFhRcMQzs\/GCr3H8Pgd8N4u+pik47OvCl9JCuQwePFhwpl922WVqzzq084ABA4TA033Nitq+acaMGSpOhEwQ9jr7efXq1YUQCl3GeZ06dfSl7yO\/KL6JfBIE6SPMND6Hr9DDPJ4gvKlB+fwI0k80DW8KexU64J26bl6jXKG1tUFZVNH18RzxWe\/TYvqnTc6yZcsK+9GxQwr71bFHHf4ohKpxOPcKbBq6cOFCYXoJcF6\/fn2v5AbPSCBtJTBk6mrBd9W8ZjnHMUy+sUGh0troWJfNhZ4sLZbsvP3222qTTBZIkz9LC41zLCo20ARHl3s9suSAaSQ7Ebdp00bYKooyr\/TReJi60WWJvg7SR5hpgsgnzOMJwltJyGDWyq0S7YB34oMpolN5rDKmh7Hq07nOk9LizWCXLl3k3nvvlffee08pFnxVAI51LC4WUIMTTxjs7MsOv+z0C65lWSofFzsMs6swyQQty6LKQGAJGMKwS4BwBoJJ89tUj8kqlph5ixgpIk9KS5Ow3ql\/\/\/5CmAJOOABFw3IeEgJqvJI8RvsMksFLkD7CTBNERmEeTxDeUi2DoVNXSdXypeN2u6hPk0BTxKz3acWVrEEwEjAS8CwB1hnigMdn5ZUIGq+4mY7ny9JKB2Gkwp8RpI8w0wS5r2EeTxDeUikD4q+Y9nntE1xobPhxT7PepxVXQgbBSMBIwJMEsJjwUeW7hDk4NdKsRjlZu+UXp6qsLPNtaS1dulTOPvts4Y0f6wS7du0qBJmGRXqp8GcE6SPMNEHuXZjHE4S3VMlg3jd718bm5Vb03OXxh\/+m\/FooPK9ExqdVJCnitXjz16NHD8EpTxBou3bthC3FqCtCcz18\/vnnQkobMjq0bdtWUIAmy4OruExFBkrg6bnbBMvJz9Da1Smj0Gd9v00d+UhGPi3aTQfwZWkR\/ElUPFuIMThSLRNXRQpm6ihzA\/LMP\/HEE0J0\/Lx586R79+7y+OOPy5w5cySRWR4c\/BluLAUuD9JHmGmCCCLM4wnCW6pksGB9gafYLDs\/jAfLbObKrfbimOfGp1UkHtYXEmi6YcOGohKRZcuWCZtaRC\/jKUYoOmHrserVq0utWrVUCTm4WNBJjJfJ8qBEYj4yXAI3TlgmLM1xi4CPNfzmNcurKaLGibeMR+Nl4tGXpYViIvizX79+smDBAiGK\/aabbpLbbrtNUGixBFS7dm1h3SLBpbt37xZS2pAtgrWLLNTUtDVq1BB7lgdd7vWYCn9GkD7CTONVtna8MI8nCG\/2sXk999sPbwA7nRw\/Niu6f\/rB0qKcNjjGA+PTskkIC2nq1Kkye\/ZsmTJliuCnOvnkk20Ye0\/dsjyw4WvHjh1l+fLlwkJrLDemnHup9v8k6p6b5hVQgl5xwfOLb2hWqQW8YZIb98QOYeTt7lcWSuWyB8vR\/9us5GfnN965Hg\/0UxatU\/QkLXCjYw1wQUGBMJNxw3Eq1\/041TmV8d3c\/xub\/BJPlhZTO7I6kLEU4M0hu32QuRSfFnXg2NklQp41iUTN48fSDvcbb7xRcCKOGjVKsLSYMpLZQdNyjoNfX0PPnN4rtGjRwlcqD6w8r21rPL99QBdmGiODnECpafzc06fnbZPe59YSPzQ8N4Cm+evxR8jby35Wz3evXr3UkfpoIDVNhQoVJKtT0yAAnOgTJ06U9u3by3XXXacymZLNlOkibwLtif20wrEf0eIsqB49erS6cTjxqTdZHpCCgUyXAAGieooXdKz4tYLSZhKdJ0sLBYNVxBHTEwurcuXKAlx++eXy1VdfKWd8LMGsXLlShTiQIx5rDcBCq1q1qor5wj+WiCwPmLGx+EhEXZA+wkwTRCZhHk8Q3pIpA9Ip6zCHILxpGq308GvFc8RnlE8r6uZ4Ulqahh13eFOIAtJlmzZtUgoLhabLnI5MI3nTSF55cnEBWGooQxSZyfLgJDVTlu4S0Nkc2KwiEWNBcfkJfUhEn2Frw5fSIt3y1VdfLTfccIOa4jHXzsvLU6llmEKGYXDM75PNR5A+wkwTRF5hHk8Q3pIlg6FTV0UEkwbhTdPoiHgsrYE\/NpD6A2cLiQSdeDdxWjapHWaW+AAAEABJREFUYDHhYB8\/fryQHx7LqXXr1jYMc2okYCSABBJpZaGwbpqwLCJWizL2S2T6SX\/ZAr4sLd4Q4odiKc4VV1yhLCy2FKOMujAITc\/\/k8lLkD5SRrNq79q2ZI6ftsM8niC8MSa\/EK+faCuL9uPRgBMN0LCEh3Q20XVcU471xbkG49MqkgRTQN4ivvbaawI888wzct5554mOaC9CMwcjgayXAFYWyiQvaj\/DoIKZMG\/fKhSnNrC4nMozscyXpYWzHcc5MVgAaxCJufr9999lx44doZCPnv8nk5kgfYSZJoiswjyeILwlUgZM27Cy8nIrSvOoTSuC8AYNCtAPj8anFUNa69atk\/Xr18fAMFVGAtklAaZy5H\/PS5CVhfSI8+IoYj59WVr2pTmE8AP4ttg9R28j5iZSIuLHjRsnpKVp2rSpXHrppWo5AuUvvfSSKm\/evLmMGTNG9uzZ49ZM3HLm\/3GRDhAhSB9hpgkijjCPJwhviZQBUznisqKtLPoIwhs08ZIGRitI49NC2oXAsoDJkyerzVVZXgOQpYGcWkwRC1Fc\/4nteueddwR6aC666CIhOv7LL79MaGoaVwZMhZFAiiSAlRVPyfhlJY+pZg3n\/RGxwvLj7Orjt78w43u2tNjfkEXOvXv3VlkYsLqAb7\/9Vu644w61ODPWQFnmc\/fdd8vRRx+t0LZs2aLO2dlHO\/LJFJGbmyvz589XOEE+mP8HofNDE6SPMNP4GbvGDfN4gvCmx+Xn6NRPhZ7TVb4sFIlTW040Tnj2Mk3DRhj5bXLUBq+6fa4X9WliR1fnxqdVKAaUy7PPPivffPONPPnkkzJ8+HAFxGqdeeaZwpvFQjTXf6aPZIP46KOPhPQzTBXZMxEL7Nhjjy2mo2716tXF10xBMY+Dwd6MBLFoWRMZqz4b6owMVkkiZHD1M1+oTA4da\/9PuT6S8ezQ9qQrKgrAl+SPe\/6zX18stWN6mNVZHhAOQaWDBg2SYcOGqbxYpFjWgH+KFDPgacAKIxsESgdLTJej4MjkkJ+fL0OGDBFya8VKTcMUlF8ar0A\/XnHBQ2Fy9AN++6DtMNMYGQTL8hB9Txdv+k2eurKea\/aFRD8HJBRcvv3g\/fojywO84c6hT6\/g9zngu0k\/qYZSXjokcBSFxRFFQwQ8C541OAWXEhIxY8YMYWCkpmFtIW3Qn2VZ0rBhQ\/n111+lUqVKykdGOYBCs6emocyAkUDYJaCnhU7O92Tx3iwqm2my+glbu56UFrFZ+LLIyMAiZxY724EycGINjqynX3\/9tVpczRtDMp+i2YmuX7hwoZBjHuC8fv36sZqKWcevSkyEBFQG6SPMNEFEEpLxOLIehDfHhuIU6n5YA4ijPN+DM1zTxGk6otqNRvu1iAuLICi8MD6tQiHof6Z9RMXfc889ogHrK15wKWER5N0iHxc5tMjNRWBqo0aNEpqaRvNpjkYCyZYAygKFRT+JyuJAW14BRQnuLNsuPVxnOniytLQQsIR69OghbBfWrFkz0UDs1SGHHKLRHI+WZQkJA0nPzA48OOLJx2VZllrDyPSROnAsy3Jsw0shzk8veAeCE6SPMNMEkUWYxxOEN78yGDJ1taCweHMHeKUPwlssGhSXU6oaHPFeeUo3PF9KC2WFoiE1zbnnnisacNIz\/Uu3wRt+jQT8SID1hFpZsUv09ac6x035afNAcZtnuF\/LST6+lBZhDfiuSObn1FgYytzm\/4nkzd4HDzHA9lCx4OE5BRKr3qkuVTT9PtwcWt5KQgaketGANYWTHWj\/5EJBWeXlVhKsq8GXNfD9WNmfHa\/EsWjyciuqZpiqqpOiD+PTKhLE1q1bhakdbwuZEsZ6e1hEkhEHHgiUCg8yD68GHmgeYgC\/wrotBZKO8NOO39KS70TK2i6DKhVKi4a8QgW15ZFWogFl5cXhnsoHH4d8dGqaVPaf6r58WVpYWZMmTVIhCvPmzRP9BtHL28NUDSzW\/N8vDzwIKCYApcQrZh7eBTdXVw8xD7AdiFh2g8falhO3OrfyVNGMvqhiaHkrCRngVNcQS0EFedaSQdOsRjlZu+WXiMfb+LSKxMEbQt4U6reG+ti\/f38hgymBokWoaX3AstJTPh4IFBXKKdYDHIYBGx6yUwLZ5tfyZWnxhpCAUDa3IGyBKSKpaXDQsz3YwIEDPT01xGKxyJrwCWK2EpnlIdb83wtzKCssK6Z8KCt+caPpgvQRZpro8Xm5DvN4gvDmZczROEH6SQZNXpFfy86f8WkVSQPlhLX10EMPCUqHDVsfe+wx2bVrl3Tv3l22bNlShOl+0FH17IALVliyPGjrCmWV3yZHOVrhz4CRQDpIgCU9+F3TgdcD5dGXpUVnKBuUFOcAua\/IAME23VzHAqaPI0aMEIJM8Y+By0LsRGZ5COIzsFtXXqaBQfoIMw33wS+EeTxBePM7fvCD9HNANHTqAnmnVip8s7mxuNb4tIpEQcgDke28PbzrrrtURPw111wjRLXj06K+CNXx8OGHHwpmK5thaIR4WR40XqKPM1duU9svNXxideHN3lDsWE90P6Y9I4FUSEBPEXmuU9FfSfbh29K69tprBR8Ui6aJiB86dKh07NhRTRf79OlTPBb8VfYsD6T+mDJlinTt2lXINV+MWHjiluWh4ITzpXLb2+TuVxZ6htFztylc0oTY4W\/DZgugwxWIuRk7e53knVBKpfngF9ArFLK8XzqQeLRhpuHexOM\/uj7M4wnCWybIoOExpeWZ6SuE1DTIIOtT0yAEgMDSp59+Wj755BMhA+lzzz0nnTt3pkpw1KuTwo\/oLA8kC8RZT3aHxo0bq3gvLC4i6cnsUEii\/jnXWR52VW0qRzXtKO+vLPANpAnZuutg0VC7cjkBcK5rWNqvhdzxt6r7pfbAWZpNwML1bBqv01gzQQbTbm8iby\/7WUhNw4wmq1PTKG1S+IHvavjw4SqJH073WrVqyWGHHSZdunQR7aMqRHP8J48WaWoAAlRRXNOmTROc+QtdsjyU\/SBfOcTxM3kFkqMp3D5NImKPeAsIODLnsxCrwyeJsszCSuOXL\/CNDCS095T4QuPT4iktBARBSuQOHToIIQ9169aVm2++WbC6WExdiOL7Hx8Z08hzzjlH2rRpI61atRLKfDdkCIwEjASEt4iTvwnHdn7Juh2+fFpM5Xh7uGnTJjnqqKNkzZo1yj+1c+dOlfnBK5PQjh8\/XrVhWYnN8oDp75WPoHhB+ggzTRA5hHk8QXjLFBmMyKsjK\/7zB1nyyxFBhpQWNL6UlrayRo0aJWzU+vzzz0vLli2V8on35jAtpGGYTCMJGFadJMA6xPk3VZPT\/vxfp+qMKPOltBgx0zfSJ5P7\/a233hJSKvft21eic8SDWxLg19dC5lS\/fPrtg\/bDTGNkIJJpMsCVw3PnB4LIwE\/7icL1pLSIYr\/ssstEZ3XQRwZ5\/vnnS15enoCTKKbs7aAc\/QA8+cGnLz\/44PrtI+w0RgbHIQLhPvmBsD4HF198sRBeRAiSn\/EgBD\/44EKTavCktGCK5TulS5dW4Q3sAv3aa6+JBtIvJ2N6yJtGAz+ozUGMHIwcvD4DLI17\/fXXhe36vNIcCB76IQng2qQnpUU4AzFWI0eOVPvDYXWxLdiiRYvk8MMPV+EO0QGjrj2aCiMBIwEjgQOQgCelRfsoJeKy7rvvPhUYSjoa4q2IjCfsAUsMPANGAkYCRgLJlIBnpWVn4vfffxcvC6TtNObcSMBIwEggERLwrLTI5rBixQq5\/\/77pWnTpjJgwAAhqv3jjz8WfFply5ZNBD+mjWASMFRGAlkjAU9KizeD5M8iowNrtEivTNhD\/fr1Zfv27erNIUota6RmBmokYCRQYhLwpLTgDkuqVKlS8uKLL8rVV18tvFbVgE+LtYjgGTASMBIwEkimBDwpLd4eYl3pjSyij9SBk0xGTdtGAtksATP2fRLwpLT2oZszIwEjASOBkpWAUVolK3\/Tu5GAkYBPCRil5VNgBt1IwEigZCWQkUqrZEVqejcSMBJIpgRCrbRYkGngON8LeY3MsltmJ554okqkyTEVz0IyFZRT2zGVFktz2KAC4NypAbcyIuZ79+4tS5YsKUaZPn26yhRBcOrll18uP\/30k8TbrNXvQk6\/i0RhLtl90L5fvlJJY2TwAyLwvTA9rPf0nXfeUfuQsn8Dz5FXQAhecTUeNKmG\/ZQWQaLvvvuuyi9EXncdi3XWWWcJG1FQB04sRtkqrFOnTjJ16tRiNOK4XnjhBRkzZozaEIO2iKRnRTq54sF9\/\/33hQh79kIsJjQnRgLREjDXWS2BUvbRs3EFy3Q2b94sb775psybN090TBaLoydNmiRYXbfeequdbL9zdgFB2VWrVi2i7tdff5Vt27apMtI2kwkVBXXaaadJ+fLlhevc3FyZP3++wgny4TfVLr+Wfvvx2wfth5nGyEBUGhfukx8I8z1lNx4\/YwE3yHMAXaohQmmRA57EYUS8o0CimSlTpoywlOexxx6Lroq4btCggWCZHXHEvjzV5Nsipc2ll16qdvOZMGGCSh4Ya7PWHWcNkSO6\/UPq9vssaXDOc2vitk3W0UyGIHv+ZZo8MkkG7HtI5tKs2PeQ9DPsXchaQxSMzlCqjyiiYcOGqfWGEVrKwwVzYDZ5ZQrI3obk42L9Ir4vt81aD137udx5Ya5c1aSKZ2h3QhnPuLR7Yd3DY+KTRvrhOQUReyMy3JycnIiyeNdhpmE9aTz+o+vDPJ4gvGWSDNj3EBkw44m+b7Gu\/cqA7zT9JB5itxhhaWlUpmpM2UijzBIdrKKzzz5bbWKBQPr166dRPR8Z4NFHHy1Vq1YVy7KkUaNGwi8B7aHEdEOc16lTR12W\/vYtyW9T3Rd0Pa1cQvGb1Sgn67YUKH7Mh5GAkUDJS8BRaW3dulXWr18vV111lVSuXFmOOeYYueWWWwRnOm\/+sD78sl6lShWVDYLtx6BdsGCBynjKnocLFy4U9k0EOCd7BDhBgF+SIHRuNM1rlpeZ3+\/1w2mcIH2EmUaPy88xzOMJwpufsWvcIP2kiiaIT0uPK+xHR6VFLngc5VrBMAimjDjod+3aJQBlfqB27drSuXNnIdQBxTdu3Djp2bOnysmF4jKbtfqRpsE1EsheCTgqLZzw7CKNpdWiRQsVW4UDHeBt4kknnRRXYjjtn376aalXr57CtSxLyMkF\/eeffy6vvvqq8glZliWER8ycOVMov\/LKK9X0UREF+MBBHIDMlYTpYXRlkD6SRxPJXZB+IlvwdhWknzDTeBt1JFaYx4MjPpLbzLlyVFoMr2XLlkJc1Z133ikon4kTJwrWEG8Pu3btCkpWAJtfMtAKPafLWuPbQhQGjARKVAKuSuvZZ58V3vA99dRTQjR8jx49hDd\/QfxZqRxhEJ9BPP62PNJKocwq8m0F6SPMNGpwPj\/CPJ4gvPkcvkIP0k+qaLLOp4XDffHixTJ48GApV66cmsaNGDFCBSOYNwQAABAASURBVJxSJ1n4py2uLBy6GXLJSsD0HiUBR0uLZTo44+3aGj8XMVzEVUW1EarLIH4GrwOYuXKrQg3SR5hp1KB8foR5PEF48zl8hR6kn1TRZJ1Pi0h20iezTvCXX36R7777TgYNGiQEqxHZru5Yln04OeSzTARmuEYCoZCAo6VlWZaKy6pRo4ba35D1iMRr4ZTPRp+WvlM6yDRVfolU9aPH5+eYKt5S1Y+fsWtcN94mfLFRbpywTOoPnC28wLHDhS9vlCFTV+smPB3d+olFbJ8lxcJLx7oIpcW0kHgsFkUT6EkUPOktiKkivgqrC5wQDzRprDkFmSatM9Nw2kkARdV+5EKlpIZMXaX4z2+TI7zEsUNebiWZ8MUGhYdSU4jmw5cEIpQWTna2AyNDw3nnnafis4jXAkglM3z4cNm5c6evDlKNHMRn4JfHIH2Emcbv+MEP83iC8MaY\/AL9YDWhfFBUVSqUVkpqUZ8mMjKvjuTlVtyvyY61\/yfUA1XLl1bKaz+kqAL6iSqKe5k1Pi38WKw1JLcVSooQh88++0yAN954QwkKZ7w6SdBHvCSACermgJvRDyCm\/ui5kct6Drhx00BaSUBbVQ2fWK2sJhQQgKLyOhDeRk++sYE0r1FOKa6ZK80z5VV2EZaWJmJqyFQQJabLWOxMGXW6LBHHRCcBDDL\/9zoOzHxM\/vdXFqgHbe8vrDf\/RBC+UkXjdfx2vFTxFt2PnQe38yA0bm3pciwq+\/TPblVpHC\/HaN5QXDxXN72yzJU8msYV0VaRNT4tPebDDz9cSNhHJDwpkYGxY8eqNYeEPmi8RBwTnQQwETzFaiO\/TXVl3vOg5RX6J2at3KoUGBYYgCLj4cYRy4OuIVabpq7kJYD1zD0DuH8A91MDfii7ovJjVXkdHc+KV9xsxnO0tMhvRWApMVnk1brkkkuEJGkDBgwQEgUmUmArV64U8vjoNnljuXr1an2pNnVgTu8VmMp6xQWPcXH0A7oP\/BOPtS0nC26uXgzn1Cwt5Q\/9Tb77aZt8uHSDjJ29rvBt0aoIxaa\/CGE5Ms0JCy8lwUfdfp\/JpKXbZcbyzeq+cf8A+32ddEVFuaNxabE\/J\/o5sJfFO3ejufaUMuo5mbV4RUQftOdGQ50TkAQQ\/zSpn5zq3cr8fhfYNENK4C9CaTH9Y8DwUbZsWcnPz1fplmfNmqXitMizRZ3G4TwRgJJ0a4c8XJjHXgEF6BUXPL\/48WgGX9ZAxnTJlWm3N1GwtF8L5ZzlC4B15gcMTSv1Y+BHZuD6lRv36P3rqglH7hv3D+Bex4JEPju3tK0n+LnGf\/ObWoFi79dvP+SoIzicuEp7O\/HO\/fbDd9Ptexu43ANhhNIiBuvtt9+Wbt26ydy5c4Wc8boNzmfMmKHqwNHlB3qsXr26kPhPt8O5TgKoy\/wcuTF+8IPgBukjzDRGBkEkIEq5+KWM9Rzkt8kpdOxv3K\/JWDT7IRcVZI1PizeDXbp0kXvvvVfee+89adWqlZqeYQaSahmLi0BTcIpkc8CHJk2aCIn\/cPADnB9IEsADZsg0YCRQQhLIy62orC3eTpYQC2nRbYSlpTkmU2n\/\/v0FJzkmIECuq3vuuUeOOuoojZaQ4ymnnCKJTALIfD0hjMVoJEgfYaaJMVTXqjCPJwhvrgONURGkn3g0WFu8DLB3G4\/GjqvPsyZOSw84lUfLSmwSwFTyXuJ9GQYyTgJYWwzKWFtIwRkcLS1n1PQoDTL\/9zuyIH2Emcbv+MEP83iC8MaY\/EKQfrzQRFtbXmiiec8an1b0wM21kYCRQOolkN+muvJtmbgtZ9m7WlosnL7rrruEOC38WSQB5A2iczPhKQ0y\/\/fLfZA+wkzjd\/zgh3k8QXhjTH4hSD9eaVgWNGTqKmF5j1caO\/9Z59MiqHTIkCFCoCeCIH5j9+7d8tBDD6lUNZQZMBIwEkiuBFiXOLQoY0Rye0qv1h0tLaJpf\/\/9dznjjDOkVKlSQqAaYQ6EJFAX5iEGmf\/7HU+QPsJM43f84Id5PEF4Y0x+IUg\/fmhYl8iem7e+538xddb5tFiqc9BBB4ndxGS6iMIiANXvzTX4RgJGAsEkMPmGBoLiYpoYrIXMo3K0tFgU3bp1a7nxxhtVqmV25SHHFvsehjfd8t6bE2T+v5fS+2eQPsJM433k+zDDPJ4gvO0bmfezIP34pWles5z0O\/MIaf\/kQvGjuOwGh\/cRpQemo9KCdfY4fOedd+TRRx+VK6+8UjinjDovgF+sd+\/esmTJkmL06dOnq8SCTZs2FTKhkj0iXfJpFQ\/CnBgJpFgC7eqUUXm3SF9j9t4UcVVaKJi+ffsKiy\/JWErq5eeff97T7frwww+lU6dOMnXq1GJ8ppZs\/spmGSwHIsngE088IemUT0sPxo9fIh1oNI9+jkYGiV976CZ\/ZI1\/i0ynN01wz7tlp886n9b27dvl1VdfVdPDNWvWKIc8iggFg\/KxC8fpnNXlTCerVasWUU2Orm3btqmygoICYRrKUqHTTjtNyCDBdW5ursyfP1\/hmA8jAZsEsv4UxbV2a4GQ6yubhVHKafAolzJlygjZSufNmycoFZzzhx56qKeQhwYNGggLrNmKTLePL4yYL\/xihFJMmDBB8vLyJF4+LU3v9ejXZ+C1XTtekD7CTGMfm9fzMI8nCG9ex23HC9LPgdIs6tNEcMzHCzzNOp8WmUt37dolt956q8yePVtIH0OOeMqwhuw3jnMc9WSCYOEzO\/lQFg0sun7ppZeEvPOkn4Hm4YcfVkrQLZ\/WhRdeKLfffrsMHTrUFXgIAI1DjnuuAV0W66gTn9lxoAXsZfZz+tDX4AH6miPXAOca7DS6jCN4AOcauAbcaDQeR\/AAzgFouAa4jgfgIQM7HmWAvSz6nH4oAw\/gXAPXgL7WR02jrzmCB3CugWuAaycayjWAB+hrjownuoxyJwAPsPfDNeCEby+DBjzAXs41YC\/T59Doc47gAZxr4BrQ19E0d1X8QthI49bBowU8QONyJN8dMxmSB3IdC6AFwNH9cA1QFgv4bkZ\/z1Nx7WhpoUQGDhyoLCGYLlu2rOKFtDRYXOrC9oHyQSmRb8stCwT1WG5Vq1YVy7KkUaNGQmZFfGYoMd0c5zqf1qRJk2TYsGHSq1cvV8jJyVF5jTTO3Xffra4p12WxjgTORuNyDbjR0YeuAw\/Q1xy5BjjXYKfRZRzBAzjXwDXgRqPxOIIHcA5AwzXAdTwADxnY8SgD7GXR5\/RDGXgA5xq4BvS1Pmoafc0RPIBzDVwDXDvRUK4BPEBfc2zRooV6BjiPB9ACzAI0LteAvnY7wht4gB2Ha8Beps+h0eccwQM418A1oK+jaSgn8HTsv2qpcdpxqeM7xcwGOXAdC6AFwNEy4BqgLBbw3dTf20QcvbbhqLQgRjmdfPLJgn8KrY0AUGDEa1HvF6pUqSLQbtq0SZEuWLBA2DgD64wcWgSuApybfFpKRObDSMBVAvi3UFzZ6N9yVFqEK2BptWvXTs4880y56KKLhDzxaPBy5cq5CjJWRe3ataVz584q1IGQh3HjxknPnj2lcePGguIinKJNmzYq8SA5tmK1FasOszZWfSLqgvQRZpogMgnzeILwlo4y6NUmR\/m3ZjpsP5Z1Pq2tW7cKbwkJWWDeOmrUKHn55ZcFi8uyLE\/3F0c+u\/nUq1dP4VuWJSjBTz\/9VFiAzdtJTFDLMvm0lIDMh5GATwk0r1lO8gsVF4GnPknTGt3R0rKPiGU7TOnIZrp582alzOz1YTtHESabpyB9JJrGbYxB+nFrK1Z5kH7CTBNrrG51YRhPflEam+hsp1kXp0WoAlNBthHjxjz77LMqMp4IdnxdbjfRlBsJGAmkXgL5hdYWmU6dpomp5yb5PTpaWpZlCbm0eGtBjFb37t2F6R6paZxCHpLPpvceUuHPCNJHmGm8S3cfZpjHE4S3fSPzfhakn2TQkKIZpzwbymrus86nxcBJTbN8+XKZMmWK2koMR\/p3330n7I1IvQEjASOBJErAZ9O8TcwWa8vR0kIxkeHhkUceEdYJaiA6nmSAPuWZUnSms8nuMEgfYaYJIq8wjycIb5kgA7u1lXU+LeKlmA7iy3rggQdEQ35+vuhA0yA32dAYCRgJJE8C2tpau6UgeZ2EoGVHSwu\/FQ53gkFDwKMvFoL4DHx1UIgcpI8w0xQOyfd\/mMcThDffAigkCNJPsmmqVigts77fFpHAs5DVjPqPUFo7duwQcsMPGDBARa+ff\/75cv311wubtALUgRM6CRiGjASMBJQE8nIrybC5v6rzTP2IUFqHHXaYXHvttdKjRw8hIp50NCgwrgHqwIklDJL6Ee1+6qmnCpHvZHXQvy6ETJD8jzeS5557rixdulTAZyE1+M2bN5cxY8bInj17YnURsy4V\/owgfYSZJqZAXSrDPJ4gvLkMM2ZxkH6STZPfprrief2e8uqYiR8RSou88KSlue+++4R8WDjiLcsSFkEDrBUEJ5YgSDVDltPJkycrJz5LgEaPHq2yORAywfWcOXOkW7du8uKLL6rcWdOmTROi78kA8fHHHws5tmL1YeqMBIwE3CWAQ37uv\/\/ojpDmNRFKi7eGWFZNmjQRrB+c7jjhWYvodZwEphLfRUYHaFgOxDlWFufknrcsS8iESjpmFk5jeSUqCaC26ug7WRCkjzDTBJFTasfjj8MgvPnrYS92kH5SQZN3aiWZ++8\/7WUyAz8jlBZvDZn+dejQQapXry5\/\/\/vfhTI\/fiyUD9khPvroI7VvIlNFEgKSDZVwCXxjJ510klx11VVCFlMsM1KjSNEfCQJXr15ddCVCni5utFfQuZSShU+7fvswNKtU3icjt1WSChlU2\/2D+v6Q+olnzyv45Y3vpuooxR8RSou+2eeQowYia+NZWiT0YwBka9BJAMkOQW4swiRw4CMQglWvu+46+eqrr+SKK64QLDIUGfm7dH\/RR\/Jw4QfwCqTQ8YoLHgqTox\/w2wdth5nGyCBHMkkGLMF7ouFPKq0Uz55X8CsDvpvR39dUXO+ntIJ0ak8CSNT8oEGDVDOWZUnDhg0FPxnBbiT+0wn+mBKiICtVqiQoN0VQ+MG5xim8NP9GAkYCmS8BXyPcT2nhBGf6huXUuHFjwWnOkWu7JeXWC\/FdX3\/9tZARgjeD+KzQ4LSJ8lqxYoUiXbZsmdrYgjZJ\/Mc0FOD8QJIAYgqrDjx+nHHGGR4x96H57QPKMNMYGYjavIX75AfCfE+ZIfkZC7hBngPoUg0RSos3hDNmzBDMPiegDpxYTJLAr23bttK+fXvBoT9x4kSV7A9fF9PIPn36SLNmzYQcXSzKRiGiuNySAKIs\/QCC94PPWPzgg+u3j7DTGBkchwiU\/5R75RXC+hywTynGBmFLXscCHkLg6AegSTVEKK1EdG5ZltrclUR\/CA5HfOXKlVXTdevWlXfffVeFQpBEn7m2ZbknAXRSnKbsB9cfFSMbIxueAb57zz33nPqucZ1z2QZSAAAI5klEQVRsUF\/uFH4kXGmlkPekdvXMM88U745NwOvpp5+u9oFkCpvUjuM3njKMnTt3CtYxW7116dJFKcuUdR6CjgjTYexYVB988EEIOEo9C7hx2PCCoHA2tiEsKvVcRPZolFakPNRLA+LHSBVN1YYNG4SXCwS\/ksP+k08+oTgrgLfGvBRhj0qUONOGrBh40SBJy0QQNNvnzZw5U4X\/FFVlzeHnn39WP9bjx48Xgs7xWZf04I3SiroDhF\/w9pNlRlTxQoGdhLhZTGfXr19PcVYAL054aLNisA6DJGEA95x9QIlfZO8EB7SMLmJmwY9XmAZplFacu7Fr1y4hXEOjYXnp80w\/orDZiIRNc++8886ssjT4orIGtnTp0uo28zaOAGl1keSPMDVPfOXjjz8uF1xwgeCfJiKgpPkrVdIMJLN\/HjymekuWLCnuBj8Fi7hZoM1cnZtCPVH8zNujLYtDDz1ULerWDaTzFGn48OHCIng9FidZMH7kgDywLNjrkunRiSeeKKxy0LTpfCQMh6mOHgMBzgRA5+bmCov2kRFrbLn3PEPgka6JPUA5zwTwIgMUFEHROPVRWIsWLZJ169aV+PAzVmnx4HXq1EktxNZS5gFk0TZKiyysROXzsJJKevHixcK8neSHGp8jaynxaeGAJMaMXYkoTycg9o1MtE899VQx226yOOSQQ5QckAfTIpSYZVnCOV\/k4gbS8ATLkbW0yALLSQ8B3xU\/Xrx14602yS+JwapQoYJwz1kzCz5rcTVNuh79yuCbb74Ry7IEtwnfDcvytoVgMuVTKpmNl2Tb\/CqSqaJatWrFbPDwMb0jNoxCovXxW7BGi2snYEkE6yFxwmNpEMnvhBfmMh42Yufq169fzKYXWRCTR6YP3pwy9pYtWxbTp+MJSpdVGUx37fwTf4h8UNj8KBGiw5Iz7jnxhGxUzDODHO106XjuVwYoan7keYNatWpVtdyppMed9krLTYANGjQQFmpjKWmcTZs2CSY\/TlXKuCGY\/U5Kq3\/\/\/lKvXj31K0MeMXw7I0eOVFH80KYT1KpVS3ixwMoEKfrzIguUFuEe6Tz2ouGqAwHOPBP8WKmCwg8sSabB+jmxLEsFma5Zs0ZQYFheKGzoCtHT\/t+vDJgeEu7BM8D3wLKMpZXyhwAzl1+blHccwg6NLPbeFJ4Hfsz2XmXnZzrJIGMtLadHjykjr3B1qh2OBQUFwhTQCT+Ty4ws9t5drG6mfbyUoATnM\/6s448\/nsusgHSTQVYpLaY7TJF4c8LTyJEEhZjMXGcTpI0sknxTLMuSVq1aCX4t3iISh8fUuWbNmknuOTzNW5aVVjLIKqV18MEHq8XbL7\/8suBQJ9K7Z8+eQnl4HqHUcMKYGbuRhQhZdPnhItyBcA9yvhFQnJo7EY5e0kkGGa20MPtZjoNDXT8avBnCuTp37lz1ap9rXZfpR\/KekZxRj5OxZ6MskAGy0HLgrSHJKnkmcDhjeem6TD2mswwyWmll6gNnxmUkkDkS8D8So7T8yyytKMjSQPQ\/sVYaWFuZVoNwYBar6IUXXhBCFpjSEUxsR2Pc9mBaex2OdlYH4MOyl5vz9JCAUVrpcZ8OiEuiwJn2aGBpk26Qt2WssdPX6XBEUb355psqDi8Ivzk5OSpej3xvQegNTclKwCitkpV\/ifWOFXLDDTdIu3btZPbs2Wrj3PPPP1+tvWNNJtYIzE2fPl1tuouVhuO+X79+wuYlWDccwcHKwbJBAbJGDVyc2uRfQsFQT5ssq+IFCLm5CD3B0mFtI2UEfBJ9jjK67bbb1D6ZtI1FBHCugbe+BAUT\/KnL3I5YlfADEHAMD+QJI2iSNZVksnCjNeXhlIBRWuG8Ly5cBSvu2rWrivJmsTcLoVkgTkss5eENKjFJI0aMECL+yRuF0mD5Dtu7sViWlNmEBKAkUELQOgG0JI0jgvyzzz4T4n\/eeusthcpyKSw+cAjknD9\/vrDmjwW45ChDsTHlI35s48aNwnIrFBuLdFlCohop+gCfBdxFl+pgHyPjRCFRgVWJhck4q1evrnJDwRdjYfyEN4BnIH0kYJRW+tyrwJyOHj1aZR0l7S4LofXbVNYSYrGsXr1a+GJjjfCFJ1sn27wtXbpUiGPjC25ZlvDGiTeyboygdFAOKEHWa6IEWawNPlYOMXK8qaN\/pqQsUEYhkauMkAN8VE2bNhUWsKOsWKhOf9ExUygzymlXg32MjPOiiy7SVcJid5ZlsQ8B\/j0qUJylS5eWbEw3w\/jTGYzSSue7lyDemSKRlgVFxReezAaTJ08WFANTPt0NucWY0unr6CPTrl69ehUrSKwuppPRePqatlhKpK\/ZvBcF07p1axXsydSUzVFQahrH7xH+x44dK0ceeaRcc801ai2p3zYMfrgkYJRWuO5HiXCDY5olTSgrvuRsPjJs2DAhwJLpG1HilGONoeAITMViYgkU5fiYYBwrBusJSwjl07dvX2GaSJ0ToCiZdqK8SA1z8803C4uXyUaBvwxfG9ZfNC3LrmJNU+34TEEZD+lo4FnXYenBOyl3dFkIjoYFDxIwSsuDkDIdhekfmUlxprO9GwGn3bp1U9M0HO5MtdjmDeWF9cVUjmtStpD9AN8XiozpI4qII1NP8lFx7iY\/Mk9YliU4xTt27CgdOnRQqU9QJOyTyVSVKWU0PX3gl0PpRNfZr1GGWFlr164VXgSgADniX8NvxliwwOw05jz8EjBKK\/z36IA4JPLbSXGglADdOL4kHOhYSiRDJFresiwh9xQJE7GymF6hKCzLEtKU4MOaNm2asOnFgw8+KFgyWEuUA0wVKaN\/+NB90S9lKI3BgwerDYHpl74sy1JvDlEq7J1pWfunQuFNIxYZ1hltwC\/t6fY50h+8UIdfDf4BFDKKirGSQ+tApp70YyD1EjBKK\/UyNz3GkADTQpQXlhsJ+5xQUVRXXXWV4PNCiTrhxCojnINMpFiLsfBMXTglUCqcbHniyiClWAK89eMtXDK7JfvE22+\/LVhusawg3kYSc2VZ+1ti8fjDh8dUGCswHq6pD58E\/h8AAP\/\/YpZrVAAAAAZJREFUAwAbz7RoaEnoWwAAAABJRU5ErkJggg==","height":181,"width":301}}
%---
%[output:18005571]
%   data: {"dataType":"image","outputData":{"dataUri":"data:image\/png;base64,iVBORw0KGgoAAAANSUhEUgAAAS0AAAC1CAYAAAAKoal0AAAQAElEQVR4AeydC7xV0\/bHx16SRE9UehydIroJ3UT3E+UiJyXv++GEUqJcufT4VHqouJVIVxLduNTlSuRdksellH8PKbmESqWSQuURivI\/31lzN88++3nOPnuvffY4nzP2mmvOMecc87fWGmvMueYc0\/s9jX8\/\/PDD7\/n5+b\/n5uYGqW\/fvkGJVqxY8ftJJ51keJ5\/\/vkgD3nIaxm3bNnye+vWrYPp5CEv6Rw5J49bBvzkgyccUT55XNlef\/11w0o+8lMu5dtz4uAh3rYjnnLIRxkUzpFzyqBsiDBxa9euNVi4Mtl6yGvJzUN5xHOkDPIiI3Hk5dwS7UVe0iw\/dS9atChivbYuWwb8xFEGZMux6VwD6nH5qJM4y8PRykgZhIl76KGHODVEHZRBPESYOBLhI84S7UaOcPXAGy1PuDRwIz4SIQfy2Po50gb4qY9zS\/DBT1ookcfycQQj2gCfLQdZINIhwqRb4px4S5zbNFsGR+JdWTh388DDOcfQ\/MRD5LFpHOElnnZwnizyJE1\/P\/74o9xwww2ycOHCQhI899xz0q9fv0Jx8PTp0ycYxzl5KePDDz+Utm3byoYNG4LpBRdWrr76aiHNRpLHLQP+W2+9VSjD8tgjcZRPHhvHkbg33niDYFiiTHioH4bilkPeklDBjSJNmjQxmBQ8EKaogodWduzYIS1btjQExmBtEvf\/0F7kR+79UVEPW7dulV69eoltL8yELfaUA8bgQhrENaAewhBldOjQoch9gBwW61dffRVWOfbYY82RPNHqNUxhfoYPH16knrvvvlsmTZoUhntfFDjBs+9s3y+4Eb\/vrPAv9xztBwc3xW2PGx8pTNvJ46aDG3HgauORBXLPbXs4umnwcB4qO+0jnnQoNB9p8JBmiTJC4+Aj3vLY62Wvn40v6dEraQHFzf\/EE0+YG4iHiAfr888\/N+f16tWTAs1cSOFQx+TJk8Xl4QJCU6dONQ\/NpZdeatLh6d+\/v4kjjbyWbBkvvviiVKpUSTZt2iQ\/\/fSTTQ4eKRdyZaNMGGJdACvH2LFjTXuKWw51hVLFihWFNiAXaYSph7BLhx9+uBRYFyZq9erV5rhgwQKDCfHIxA0G1oTBjGtAuZxDJtP+n0MPPTRsveRBIbnl0H4eWOqjHMhNtzjuL1qQgzKom\/KQhXaR\/uijj8q6detkyZIl5nrVrFmTaIEvNI9bb8+ePcXWQ\/zcuXNNPsohQPluPfPmzTMvudA8KHruRe4V7hny2PYQj4KiPEsok9GjRxucKQt+iPrgoT0oNHtOm8GpadOmJAeJcuAlAl7KsPV+9NFHUmBxk2QoHLZcc8qgXTBZWWgDbQEHFD9pEHGkffDBBwLG06ZNI9pcc+omDR4TWfBDu2k\/caTBY+UjnvQCtlL7T5vSAlha1a1bN+EhI1yjRg0pMIHNRediEgdxcSHC8LRo0YKgrFy5Ur788ksT5uZv0KCBQKFvABi4uAXmL0FzYapWrWrC4X6sYnJl40Hg4oRTErYMLmKXLl3sqRS3nGABJQi0atXKPOjcuNygHJGPeIs9WIMn1XANaC9hKzfhaHTuueeaFwVKAUUC9lwHmydcPSgRrkUoDzc914cysCZsergjfJTh5mnXrp2RpWeBwgqXh3YiJ9eQ\/G3atDGWfjheG4fSQgFDF110kbm3uA9RmJbHPfIC5EWIbLTTppEHClU4Nj30iFKClzwQ6VZ+FIur5HgWSIPHWjaEuZ5PPvmkwQRF2alTJ6ENtIV0l+ip2DJps2uRw0caPIQheCgHokyuGXJGwoU8yaS0Ka1kNAKwbDn2jcRNaSmagrH5yurRdhG5+Xn7caTLSHyy2swb9eSTTzYPMwoK3N2HNZF6rDVAGZZ46LAuQ8vhIUUBobRQEKSj6Lgf6NpwHkpYHjy48NBlnTVrlrEkQvnCnfNAopStXBxDlUe4fOmOo6tGe+l+33fffYJVxIsrWXLFwoV7grp4oXBMFqVNadm3AmYwNxQNwiLANAVYLALiIG5OiDA8mLfw5OTkSO3atYkWtxx7sSLdwCZDlB8rm2txFKfMeMvhzcbbC5F4OJLxxuJNS1eQt+GyZcuM9co58VYusAZP6uUagCHheG8yrGHKR1Fh4VAW14YyoHD1YIm57QvHw3XjYQNzlFadOnUoLkg23SoflAgvLRiwKGkLYZes9YKS4wEGB\/f6urw2TFeJ+4x7DyLeKmosNdpLnCUrK+2jnTaevFC8Lw3qpSfAiwa5KSdavaSHErJxLZD\/gQceEBS9vV6hvO65rRt5IdKomxcfYQgeyiUdIg4eXmAWF64B1wK8sWzhSRalTWlhsqKpaTSN4iblnAuOKYpJ6jbSvkktj70B6I5ZAG053DCAxcPklhFvmHzkpxzkgggTR1qyyuFGwrznwbdmNu2Mt3x4ebAj8aP4wQbZOXIOL9062gHW4En7wI5rwTkEXyQKrZfyKYN8lGnzUSaYEUcaPKFdd+QIx4O8XFuUCy8mMLKKnXaQjrzUQbnIRL1WMROGkI0Hadu2bZyajxNWFtJMZMgP8eTh4eReJJnyqYfrhCxu15p0CFlvu+020y2nnfBD5CWd7jc8hKMR9wXlUw\/1UQZHzoknPZg\/RoA85KUMZIrBbpQb9yR8yE0+8lMOcRDPZixcuDbQ0KFDTZnkSxalTWlx8Xg7cgO5jeEmDu3WcVPfeeedQTbykJcyAJC3ADyWgfAzzzxTbLC4KchPOSUpM55y6Ba59YwbN8583bP1hh5pMw9maHy4c7CxNxdHzi0fGIO1Pefo4sq5S+HqtS8ey0dbIM55y2J5hOLIdXTbC0Z01aibfBAKiQ81Vl5r+VnLiHjS4YPfEu3B4uPcKjbCUOPGjeXGG28kaIj66H5ShrVoQvPACE62TZxDnNt6OHcpkmzcr7wsXN5oYcqnHpeHc+LduEhhcEVh2HQwf+mll4QjLxEsepsWeqTNYGnjCUP2nCM8yEPYEufIh5XHdSZPIm225cQ6pk1pIRgPAjcO5r0lwCAtlHjoLA95yGt5uECMcdh0wsSRzk3E+IMbRxrnEGH4Qol40sOVadMol\/JDz92ybFq4cuALTb\/44ouF9tmyKZ8wssBLHm4MW14kvOCDSIeXI+cuEUeaJeq1uFIXdVI3MpAvtF54yWPzkw5xTjxdG64b3V\/GU4jHeuGhoftDmHJDy3HrJB1rioeN7g4PBHHIBB9lWqI9pEFuOu2gPVY2+JEPxUUZEPwQYdJtHspy85HGOfGRyC0Hfsh9eAkThwy0PVI51AOfJc4tL2Hi3Tbbcm2cPYeP9px44onCkXPSwpVBt46xP6xNlBC8HMGeum13nrDNDw\/EOfFgTT1WDuKSSWlVWslsiJblPwQY9KcbT9eCLgZdDbocSMo4FZYY4VjEQ0C3CGUXzUKIVY6mx0YAJWotebqTXDOUO9hjldoXTeySSo8ju5RW6eGoJYdBgAeAbhE3vZtMtyGWleHyE7Zd0b59+xaZw0e6UvIQwGLCunJLxNJlGAYr0o1PRzipSmv27Nlmdro14UMb9PHHH0vz5s3NJ3I0OBRtIBmAMNcxNXnbhpan5\/5HAMWFgqL7YKk43QZbDvcD94X\/W57ZEqK47PXi6Kdn0EPBxENff\/111KvA+MXIkSNl9+7dEfn4gnP22WfLmjVrzKQ3wCjODRyxAk1QBBSBMo+Ah+keD11++eURwWDwbtSoUdK+fXupXLlyRL7169eb2eiBQCAij5uAJaa0b5a\/4hAPDsqT6vsEY8V9ZlMR9rB2YhFffiIpo99\/\/9187aL7lpeXF1XmzZs3yzvvvCN8DTruuOPMeq+NGzdGzRNLNj+m0yA\/yhWPTCr758FeQDx4JYMnkzE\/55xzED+lFNeYVrVq1YRPpOEkY4yBOTnMTi5fvnw4FhO3Z88eMyubchYtWiTM0q5bt65Z2IqlZpj0RxFQBBSBGAjEpbRQLrfcckuRorZv3y733nuv3HzzzXLUUUcVSXcjDjroIBkxYoThxWsAA6vXXXedMJ6WDhPTlU3DioAikBEIGCG9zp07C757fv31V0n0j64d82aYQ0Nfmrk4zC5mjIwy3fK+\/\/57GT9+vJDHxu\/du1fKlSsnFSpUEP1TBBQBRSAeBLyvvvpKevToIXxGZvoB3Ta6cvFkJg\/dQ9uvZ+yLyYSsOaIb6JbheZ7QLZw+fbr8\/PPPxvneY489Joxt1a9f32XN+PCbb76ZsW1Q2VN\/6TIZ89SjJeK99tprxlkd65SwmvhK2KxZM7njjjuEbhsD7cUVjLGqTp06Gc+QdAeZYfvpp5+agfhTTz1Vdu7cKbfffrscfPDBxa1C8ykCikCWIWDGtBiPuuqqqwQFtnz5chk8eLCwOPXaa6+VWPOzXLywvF5++eXgQmUUFRMLe+53zMbYGDOkV61aJZ988olMmDAh5liYW76GE0JAmRWBMomAUVq0jDEtpiMMGjRIhg0bJkwEZWqCjjeBjpIioAj4BQGP6fndu3c3Y1r4+2GMC\/co7733nrGEIs3P8ksDVA5FQBHILgS8rl27mrErxrQWL14s+D9iZjtdu+yCQlurCGQWAtkqrUeXkK8XjGkxiTRbgdB2KwKKQGYg4OHXKDNEVSkVAUVAERAJDsRHAwOn9R07dozGommKgCKgCKQEAQ\/\/3LGIXTx+++23lAhUWpVouYqAIlA2EPDGjBkjsYi5VlWqVCkbLdZWKAKKQEYj4OGhIR566qmnMrqhKrwioAiUDQTiGtMqG03VVpRpBLRxWYOAKq2sudTaUEWgbCCgSqtsXEdthSKQcgSmLflKdue0Eo6prFyVVirR1roUgTKEwLTFm+WnP3aTMXPWpqBVB6owSgt\/WHfddZdxR8NOOTjwwyvpATYNKQKKgCLgDwS8+fPnyyWXXCIzZ84U5mt9++238vTTT0u7du0EB3\/+EFOlUAQUAUVgHwLelClTBH9XLJRmRx38t0+cOFEuvPBC4+Vh165d+zj1VxFQBBQBHyDgbdmyRc444wxh4wkrD55EL7jgAmHLr++++85G6zFjEFBBFYGyi4DHxhK\/\/PJLkRbu3r3bxAUCAXPUH0VAEVAEXAS+2F5Ub7jppRX28Ad\/\/\/33yzfffGPqYIccfMOzNRieS9VdjYFFfxQBRcAnCHi9e\/cWFBNeHNj+i0F5do1lQwv2M8QS84msKoYioAjsQ8BXvznVKqRUHq9SpUpmP0KmObDRBMRWYCySrl27dkqF0coUAUVAEYiFgMduO9Bhhx0mLVq0MFSzZk1h6gObW2BxxSpE0xUBRUARSBUCHvsctmzZUsIRexM2btzYTDplD8NUCaX1KAKKgCIQCQGPTVlRTOz2vHz5clleQHQRc3NzhT0Kp06dKkuXLhV26IlUiM\/jVTxFQBEoQwh4jz76qPTv31\/atGkjbBcGdejQQW6\/\/XZ5\/PHHpUmTJjJkyBBZtmxZGWq2NkURUARKisAX29I05YFxq+rVqxeRnzjSDuZKZwAAEABJREFUfvrpJ2HD1mS7W549e7a0bdtWtm7dWqRujVAEFAF\/I+AqrHrVU\/z18IgjjpC5c+fKnj17gigx+M6axPLlywvLelatWiXJnPrAPLCRI0eKncAarFgDikAxENAs6UUgp\/qhKRXAu\/XWW4VxK7qH\/fr1k4EDB0peXp5Zd9i9e3d5\/\/335bbbbpP27dsnRTAG9EeNGmXKoysaq9AGDRoIhKLLFNq4caNkiqyhcqrsa1N+7TIJc55F6Ix2l8R6dEst3TvllFOMd4crrrjCXCyUFFMf\/vOf\/wieHhiQR6l169atxEJgwTH\/i4XZKMZ4CsRtDoQcmUJ169aVTJE1VE6VPTfl1y6TMOdZhG6686Hg49uqYdVgOBUBj0pQIsx+f\/bZZ+W1114Tum6MY\/Xq1UuYfNqyZctCC6rJUxzC1Q2baNxaYN3R9SxOGZpHEVAE0o\/AgtXbg0KccWwpK61gTfsCHooELw+YfC7xBXH9+vX7uJLwi1NB1jOiHI866qgklKhFKAKKQDoQYBB+\/podpupy33xqjqn88ZiTRRfx7rvvlj\/84Q8ydOhQM4Z12mmnmXEt1iUmQyD67StWrJD8\/HwzRnXRRRcJax2x4lhClIw6tAxFQBEofQQW7FdY1JQWpYV3h+uvv14uvvhiadiwoRx33HHCOQPvzNNiHArhSkpNmzY1nlDpD0Osb2QO2MKFC+Xcc88tafGaXxFQBFKAAFbWTdNWmppyqleQCp+8aMKp\/PGY6uB5npnSULFixaCLGlzWYAnRrRP9yxwEVFJFoJQQQGH12q+wqCK\/xdEcUk4ei6Pffvtt+fXXX+XYY481y3iwrphYitdSlFppSIXl9fLLLwsfAUqjfC1TEVAEkocACuvCB5eJHcvCyhqQVz95FSRQktejRw955JFH5F\/\/+peceeaZ5ush40zEs2A6WWNaCcikrIqAIuATBFBWY+ask1P+\/n9CGLFQWC\/9tRnBtJDHnKz33ntPrrnmGmnUqJFMmTLFTPxk7eHgwYNNtzEtkmmlioAiEAaB1EShoKYt+UqwrsbMWRusFIW1fMifhGMwMsUBb\/z48cLmFvjTom4U17Bhw6R169bGy8P3339PtJIioAhkAQIoKywrlBUD7pzTbJTUgLxcQWFxnk7yZsyYEdzzkH0PLTHRlDGncJtepFNgrVsRUASSiwCKyVhVE5eZbiCWFXHUgrLKb1FL6A4OSNMYFnK45G3atEmYo8WkT5ceeOABY23h7cHNoGFFQBHIbARQSJCxqPYrKqwqO8hO61xlNTG\/cVq7g8jjksdcKeZMMXfKJTw7MK6VTO8ObsWpCWstioAigIKav3qHuNYUA+tYVK6iAimUFUqKbiBHzon3E3l0AZl+4CehVBZFQBEoHgIoKAgFhfV04X5Lyo5RhVNSZzSsKigoFBVEd7B4tacmlzdo0CCJRGPGjBEdiE\/NhdBaFIFEEUA5WQvKVVBYUZyjuMIpKawnFBPjVCipl25qJpwTn6gM6eD3cPYXiXCxvGvXrnTIpXUqAvEgkBU84ZRT9T5vmUFza0GFU1CAgyLCkhpQ8OXPKikUFZZVqr0zIE8yyMNVTCR66qmnRD0yJANmLUMRiI4AiglC+YyZs06wlOjaxaucKN0qKKwmlBLKCcKSGpBXXzJVSdE2lzyW7Lz77rtmwfQJJ5wgrDlkwfRnn33m8mlYEVAESogASsl251zF1HzCvhnntlvHADnKK7RrZ6sPVU5YUNvG\/VmsgkJhobjgs3nK0tF79dVXhSU7devWlbvuukt69+5tNpvA64O6jClLl1rbUtoIuEoJpWOtJZRRqMUUSzEhK0qHrh0KCEWEckIxQVhPxJFWViwo2hxK4c493CoPHDhQmJeFourcubO88MILwpwtthfDp3u4jBqnCGQTAigkKJylFE4pobBQXFhL5IuEFYqpeZ0KZiAcJQShnMJZTign+COVlS3xHp4cTjrppELtDQQCgjfTH374QdhCrFCinigCZRABFItVSCgblA7EuBJKyZId+HYtJfJGggQlA7kWU6himnxpLTPlAKsJQjlFKk\/jRbyCP8ENTSgYLN\/Zu3evBAKB0CQ9VwQyBgEUChRNIYV23VBWKC4oHkspklKiG2fJ7c6pYirZ7eOxMPqOO+6QRYsWmb0PGZhfuXKl\/P3vf5fTTz9djjzyyJLVoLlThkC2VRSqjCYv2hH86oaFZJURVpK1kBJRSODpKiSUDVYS5HbhUEzhlBJ5KUMpuQgYf1r4g7\/66quNq2VcLl9wwQWSk5NjxrUCAbW0kgu5lhYLgVBl5H5pQxmhhKxCcpXRPxfvW6qCdQTFqgelYrttoQoJRRQ6roSygg\/SLlwsdEsv3du9e7eMHj3aWFrsbzh58mRZsGCB3H\/\/\/aIOAEsP+GwrGUUEud20eJWRO36EMqKcaPihjKCSKCTyR6tD09KHgHfZZZcJO+O8\/fbbZo4Wm0zUqlVLx7LSd00yqmYUCIoIYgzIKiK6YaFWERaSaxklWxkxoG2tIywl22ULtZAyViFl1J1ResJ648aNkxNPPFGGDx8uuFfu3r27LFmyxIxvlV61WrKfEUARQVYRoYxQQhCKCKJ7BllFZJWRVUTkiccqAgeUCBTJMoo0fhSqjJg6QHlKZRsBjxnwI0eOFNYZTps2zXQJu3XrZqyusWPHys8\/\/1y2EciC1qGAIJQQhEKBUEIQSghCCbmzs60iggd+CEUExQMbigiKpIywhuKxjHT8KB60s4fHs0096KCDjKLiqyFOAZkhj9sa5mpZHj36BwGUEOQqoXi6ZqWhiAbk5Zp5RlhEULzKCIXmH0RVkkxBwCgtFNMrr7wif\/nLX0xXccCAAcKOPFOmTMncBdOZcgUcOVFCkKuIsHIgLCGI7hgWEUfIVULF6ZpRPcoDwiLq2PhwMzs7EUU0IK++yYNFBFEW5SopAqWBgNelSxc55ZRTpE+fPsIA\/JNPPmm6ingtzc3N1QH5EqCOAoJcJRTJGoqkiOiSQXTJIMqLRyQUB4Qiym9RyyiVAXFYRMPPPdJYTQPyVBHFg7PypB4Br1KlSvLQQw\/JBx98IBMmTBC2FKOrmHpRMqdGFAfkKiOsIQhrqOPUjRJJCSXDGnIVEYPREN0yKFrXTBVR5txjKmlkBDwWSp933nlyyCGHROaKkvL111+bSajHHXecmZzKQmviwmX5+OOPpXnz5tKgQYMg9evXLxxr2uNQShBWDsoIQiFFUkbwQVhDX37\/W1zyYwlBrhIasN8asooonBKK9Ck\/u7pmcUGsTGUQATOmVdx2seRn4sSJcvjhh8uKFStk6dKlpijiSDMnzg9rHM8++2xZs2aN2E00+ELpsKQt6CoolBPjRRDKCmUEoZBiCYgSql25nLiKCAUEYQlB4RQR6dCA\/d0yunSqhGKhrenZiECJlNb27dtNt\/LSSy+VQw89VCpXrizt27cXHAju3LmzCJ7r16+XmjVr+mKczFVS1nqyCiqSckIhRVJGriJ6uUtdUWuoyOXXCEUgKQiUSGmxJ+Lzzz9vxsGQhk0w+ArJWkasL+Jc2rx5s7zzzjuCKxy6k6x33Lhxo8tSJGy7kmvXrpVk0IIPVsltT+3blNIqqdBKsZT4itbjtKrCwDQzrZfeXF+ev6qWjG9fVfq1rGCo5ZE\/C1TnoO2y57vNQfloUzJkTUcZKnty7rNErl0mYW6fR3sMfXaSeB6xKG\/8+PECaKEcxJGGIgpNC3fO2BRfIRm3ysvLK8KyZ88eYWoFy4TwKLFs2TJhLlj\/\/v0lmqNB243kS2ZJ6KAqR8vTnwWEQXIW1roCYkHRHaN7xmTH\/w0\/U6Ze30JGX9lM\/ta+qVx+RmNJpG7alQi\/n3hV9tyErnUyrl0mYW6fR3t0n6NUhb0ZM2bIzJkzZdasWYXo2WefFSaX4lcrHmEYm\/r0008F6wn3zRs2bCiUjS+SI0aMMIP2dCWxxK677jrj2pm3UiHmJJ8wHsV8Jr7c2aJRVAMKBr1f+msz41sbhYXisul6VAQUAX8i4G3atEmYAc9XP5f4qoivLbqAkUTH71bXrl2N4oHn4IMPFr5EopB27NhBVJCw2LDcsOBsJE4Gy5UrJxUqVJDS+GPcys6LIkwdVlkxBjUgr74w2E28kiKgCGQGAl6TJk3kxRdfDH7Ns2bfqlWrhAmmKJVITWEyKl8Escro\/rFO8emnnxbmftWvX79QNjyk0i2cPn26Wc9Il\/Cxxx4z0yRCeQtlLOYJSgrLCqKIUGVFXBkibYoikDUIeHQBmzZtWqwG42+LxdaU0ahRIzPAjmJiVx8UF4qpU6dOMmnSJDMtAouOLiQD8XiU4AsjihELrVgCRMiEwuo1baXQLYQFhfXAlY0Fy4pzJUVAEchcBLwrr7xS6AaGI9IiTRS1TcatDV8MmXuFdcYGrwxOkk43kWVBPXv25NQMvONkEL5PPvnEzMBP9mawKCysKzttAYX1UsG4lXYDzSXQH0Ug4xEwrmnYeScc4bamuDPl04UM1hVE\/VZhceRcSRHIVARU7gMIeHh0GDVqlIQj0pgweoDd3yFrZSEligoLiyPnSoqAIlA2EPDeeuutQlMd3KkPpDG4nglNRWExjmVlHZCXK6qwLBp6VATKDgLeP\/\/5TxkzZkyQ7FyqW2+9VR588MGoEz\/9BMOCNTvEjmMx3wryk3wqiyKgCCQHAY+B83nz5omlxYsXm8XP1157rbRr1y4jnABiZbEkB0iwrrCyCCspAopA2UMg7NpDvvoxaXT+\/PnCPCy\/N5uvhVbG\/BZHa7fQgqFHRaAMIhBWadl2Mp7122\/x+YayeVJ9xMpyvxYOyCs8qTXV8mh9ioAiULoIhB2I\/\/e\/\/y1sJYbFVaVKldKVoISlM5ZlixhQMPhuw3oswwho07IagSID8QzKP\/LII5KTk2P2QvTzPC2sLNs1ZCwrv0WtrL6Y2nhFIBsQCA7Ev\/7662YwnmkOb775pll6U7duXV9jgNKCELJVw6oclBQBRaCMI+CxpKZDhw4yePBg09Rvv\/3WfDW85ZZbBM+kJtKnP3fPWRuULL9gAD54ogFFQBHIYASii242tqhTp46gpGA94ogjBBcy69atM2sDw\/l6hy\/dhIVl52XhAlnXFqb7imj9ikBqEPDWr18vN910k9SrV8\/UiLM+FkEPGTLE7H\/oV2trwZoD\/rryTzvayK4\/ioAiUPYRiDjloXz58rJ7927x65SHaYs3m6ujA\/AGBv1RBLIGAe+YY46R0aNHCx5MbavxMjp16lRjfflxyoPbNcypVjpeTy0W\/j+qhIpAdiFgvDzs2rVLzjzzTGEXHVzUNG\/eXNigom\/fvuLHKQ8oLXuZWh1bzQb1qAgoAlmAgFe7dm3BRTJrEPPz86Vt27by0EMPCVuDsc2XHzFwvxq20qkOfrxEKpMiUGoIeF26dJHVq1cbK6t3794ybNgwYZsvdswptVpLWPAX238xJTCepV8NDRT6UyI53g0AABAASURBVHYR0JaFIOCxVGfr1q0h0f49pWsIIaFaWaCgpAhkFwLe9ddfb3xpPfzww0WcATI7nkXTfoLELo5GJp1QCgpKikB2IeAxqZRNJviC6O57SHj48OFmV2g\/QbJg9fagONo1DEKhAUUgaxDw5s6dW2TPQ7v3IWk1atTwFRjueFYYwTRKEVAEyjgCHluEMaYVjkjbs2ePbyBgLAtCIB3PAgUlRSD7EPAuv\/xyadmyZVgijQXUfoHFKizk0fEsUFBSBLIPAW\/GjBmycOHCsEQaC6j9Aou73tAvMqkcqUVAa1MEvCOPPFJ27txpNrNg\/KpChQqydOlSOfjgg82mFiygThZMdDcZ4GfSKkSYuHjLt4PwOj8rXsSUTxEoewh406dPF3bdYRMLmseSnkmTJslZZ50lS5YsISophIubiRMnCvPCVqxYYRQjBRNHGuFoRNfQuqLR9YbRkNI0RaBsI+DNnDlTRo4caWbC09SjjjpKnnvuOWH+FnsiosSILynh4uaDDz6QSy+9VJhtX7lyZWnfvr189tlnxtJLpHxdb5gIWsqrCGQQAnGI6n333Xdy\/PHHSyAQCLLTJWzTpo1s2bJFSA8mlCBQvXp1s56xRYsWphQ8Sbzyyitm+RDWl4kM89OgQQOBFn98wEtpw8N+lrVr1\/qWNm7c6FvZYuGmsqf+vsokzHkWXQrzyJZ6lFexYkXBS2loTex36HmelCtXTpL9169fPznllFOMJ4m8vLyoxds5Y2t2Hhrkq1XraMnNzfUt4Vvfz\/JFk01lT\/19lUmY2+fRHoMPZQoDHouj8VI6duxY+fTTT41fLbYQwy1N69atpVq15Lt+sXVdffXV0qNHD9mwYUPMJusgfEyIlEERyAoEvG7dugkKCkV1\/vnnG79a99xzj1Emf\/vb3wp1G0uCyMqVK4Vdq5nESjl8nTzvvPPMwPyOHTuIikrBmfDq9O8AThpSBLIQAY\/xq86dO5spD8uXL5dFixYJRwbiUSzJwqRWrVpCl\/PZZ58VZtmzEBs\/XpUqVZL69etHrYYvh1BUJk1UBBSBrECgkI94vujx9RBFluzW083kK+XLL78sjRo1kpNOOskoyLvuuktQXNHqcxWWfjmMhpSmKQJlH4FCSqu0m8suP3wxXLNmjbDfIt5SGRSOVa87E17XHMZCS9PLDgLaknAIpFRphRMg0ThmwyeaR\/kVAUWg7CCQEUrL\/XKoSqvs3HzaEkWgOAh4DIqzhGfEiBEyaNCgQjRmzBhhEmhxCk5mHvvlMJllalmKgCKQmQh4DI6zucXs2bMF5eXSsmXLJFnLeIoLD4PwEPmjrzmEQ0kRUATKOgLeu+++K\/fdd59xTTNv3jxxiYFyvib6BQT9cuiXK6FyKALpQ8Bj8XKseVLpE0\/EWlnIoONZoKCkCGQ3Al6zZs1MtzAe9zDpgMqd7lBPZ8On4xL4pU6VQxEwCHhM8pw2bZrccMMNwlKeWbNmBbcS88MWYl9s+9kIyo9aWqCgpAhkNwIe41ZAwGLpRx55xOyByFdDCH9aP\/74I8lpow3bfjF1o7Agc6I\/ioAikLUIGKXlDr67YRRaugfidbpD1t6b2vAsQyDe5nqMZTHdoWPHjtKhQwfjBnn8+PGCl9F4CylNPjsQn6PjWaUJs5atCGQMAt7zzz8vAwcOlJycHPnhhx9k7969QpcQX1cos3S2ZG\/FI4PV63SHIBQaUASyGgEPf\/DDhg0TqEqVKsJuPMyM79Onjzz++ONGgaULob0Vj0hX1VqvIqAI+BQB4yOe7bxc+QKBgJx66qnG8vrpp5\/cpJSGC1laDaumtG6\/V6byKQLZioDxEb9t27Yi7SeutHzEF6ksQoSrtCKwaLQioAhkGQLGR\/wdd9xhHPL99ttvwuapOOobOnSolJaP+HgxdruHOt0hXtSUTxEo2wh41157rVx55ZXGuwNztbp37y6MZ51zzjnGT3wgcGBrsVRDYS0tFBaU6vq1PkUgbQhoxRER8PADjz\/49957zyyaXrhwoeDdgYH5aPsRRixRExQBRUARKEUEjBPAzz77TAYPHiz5+fly3XXXycMPP2y2EivFeuMq+rcjjzd8OkfLwKA\/ioAiUICAx1ysiy++2OzGw+7PTZo0kZkzZ0q7du3kjTfeKGBJz7+dVErt9apX4KCkCCgCioB4rDe8+eabZc6cOcLOONBrr70m11xzjTz66KNpnadlr09O9UNtMPxRYxUBRSBrEPB2794tZ5xxhgQCBwbc2ULs\/PPPT+s8rS\/2L5TmSuSopQUMSoqAIlCAgHf00UebTVQLwoX+mad12GGHCU4CCyWk6GTD9n3eHahO\/WiBgpIioAiAgHfVVVcZd8vMzfryyy9l69atMnfuXOOihjR2giaO+VtkSBW5llaq6tR6\/IqAyqUIHEDAu\/32241Hh1tuucV0E1u2bCldu3aVTz75RIjjHLr88ssP5EpB6At1\/pcClLUKRSDzEPBmzJgRnJ\/FHK1IBF8qm2ed\/1GnjmmBgpIioAiAgIeTv0qVKsnKlSvN18IXXnhBtmzZIkcccYTUqFEjSPCRIZRwY8MyoBNOOEEaNmwo7du3l\/\/973+hbOb8448\/lubNm0uDBg2C1K9fP5MW6UcVViRkNF4RKDMIJNQQb9OmTXLZZZcJy3eYn8UUiIsuukg6deokjHHFKg3+VatWyTvvvGO6lCitO++803x5DM27bds2Ofvss2XNmjXy+eefGxo7dmwomzm3Hkt1YqmBQ38UAUVgPwLe3XffbSykpUuXml15Fi9ebAbiA4GATJgwQVhEvZ+3yGHnzp3y\/vvvGwWHJcaSoLZt28o333wj69atK8K\/fv16qVmzZqHpFUWY9kfYgfiFixYZq2zt2rWSKbRx48aMkTUUU5U99fdZJmHu9pII739cU3rwUCRYWZUrVw5WXK9ePenbt6+ZJb99+\/ZgfGigYsWKct999xnryaaxJIhw1apVORSizZs3G4uMHYDw4YV3VC5YIaaCE6uwCoLyl\/PbGIssNzdXMoW6dOmSMbKGYqqyp\/4+yyTMbQ\/JHnlGU03er7\/+GrZOPJjiTwsf8mEZCiIDgYBUr15dDjnkENmzZ49Mnz7drGHEa0TdunULOA78k44753PPPde4wWFRNjz9+\/ePOus+R2fDHwBxX0h\/FYGsRsDDqkLZuMoLBcNcLQbjGaSPhRBfHM877zx58sknhTEuLLdA4MAMe\/Izy37EiBHCkiEmrOJBgsXZzAGjiwJPOJoweqjpHmKKZgrRjkyRNVROlb1Byu+3TMcc+VNJ3o033ihvvvmmnHnmmcKXvIEDBwoKCE8PN910U8wZ8Syq7tWrl9nsFX\/zp512Wtgxq++\/\/17Y5cftDrKJRrly5YxfenH+cqpXkG3j\/izLh\/xJNr79uOkeWnNUj58rHvs\/4ui94I97wXl0UxL0Tj75ZHn11VeF2e84AWRgHQeAr7zyiuD1IZoUTHeYMmWKcSB4xRVXCNZUJH66mosKBtWx6phlT97HHntMGNuqX79+2Gwor7AJGqkIlGEEtGnRETD+tKpVq2a6bSzlwcPDoEGDpE6dOtFzFqRiPTGQj4XmdjNQhB9++KEZq2LqxKRJk4TuIF8qUYwMxLNxBl8fmZHPV8eC4vRfEVAEFIGYCBilFZMrAkPt2rXN18BQM52NXps2bWoUFeNcPXv2NCUw8D558mRhXhfLhJhSwVQJk6g\/ioAioAjEgUCJlFYc5SuLIqAIKAJJRSDjlVZS0dDCFAFFwPcIqNLy\/SVSARUBRcBFQJWWi4aGFQFFwPcIqNLy\/SXKcgG1+YpACAKqtEIA0VNFQBHwNwK+U1qsT+zTp4+ZdMq0CVzXuEuM\/ALnW2+9JXh0jeVDjLWbzH+Dl7lsTNh94oknhPh0tCVeuV3ZcF+E9w5WP7jxqQ4nIjs+3XCTxPVhXmA6MQeneGXnXmflCDJzv7DpDPdPuu4XZI9GzLu85JJLjJv2aHzJTPOV0uLC\/OMf\/xAuHK5y5s2bJ+x8\/fTTTyezzSUuC08Wo0aNMn70CTMPbciQIRLOjz4rDO655x7j5of5aQ8++KAwV434EguSYAHIGq\/ctmiuBdvK4QPNxqXjmIjsXIehQ4cK3hPIx1xBVl+kA3OwQoZ4cWfNL0rqxRdfNH7nxo0bZ5a\/rV69mqJ8Q6wZxptx7969w26ME7+giXP6Sml99dVXxvVz586dBVc5zNTv2LGjzJkzR5g9n3jzSifHf\/\/7Xzn++OOlVatWZukSb0O2YuPtHlrj8uXLhdn\/EMucTjzxRLMgd8mSJaGspX6eiNxWGJZpBQIBadasmY1KyzER2VnAj\/eRCy+80FyfJk2ayDPPPCNgnw7hE5Gd1SGsx7V+7Hbs2CGc43UlHbJHqvOjjz4yvvTSMTncV0oL54E82Mccc0wQK8J4UPWT0uKtxwPAzYSgbLXG6gBMZc5dYk3m8OHDg4vIv\/32W2HReDzLpNxykhFORG7qQ+HSJWThPO6HiEsXJSI7FhXOJrt27WocXP7pT3+SBQsWSPny5dMifiKy8yL885\/\/LHl5eUZ2nBH06NFD8MaSFuEjVIqMWI\/XXHNNBI7Si\/aV0sI3PesZ3eZWqVIlpqcJl7+0wyz0Rom69fBAh3N6CA9rLrEaCeOHH7c93IBnnXUWUSmjROVmbPGBBx4QHpp0KFgXmOLI\/vrrrwseTFAYEydOFLq48+fPd4tNSThR2WfPni2s\/501a5bpHt57773CuG44Kz4lDfBhJb5SWrwd7QNusfruu+\/MGFcgUNg\/l01P9RElhFXl1rtr1y7BjMe0d+NtmDGWv\/71r0K3Nz8\/XxjXisdPmc1\/4Fj8UCJyM7bIuFvjxo3NtnLFrzU5OROR3daIq6XWrVsbC\/ePf\/yjnH766UKXxqan6pio7IxpnX\/++QL2gUDAuIkinA6FmyqMEq3HV0oLqwoFgFtm2xC8SLDQOlSZ2fR0HGvVqiUMrvJwUz9dVxQT41ycu4RVxoAwrqnxW0YYJ4guT6rC8cpNe\/gQgoViv74xTnTDDTcYn2upktetJ17ZyYOrI8YYcWbJuaVILxWbXlrHRGQPlYHhEsazUv2SC5XDT+e+UlpYMDgRfPzxxwWfW3g0JczuQHTB\/AJcu3btzAa3fNnkwcBHGDcWLnlCZXzppZfM2MTo0aPNx4XQ9FSexys31gFf3Kz3jhUrVpjpHVhfdFVSKbOtK17Z4afrTVeccSxeLIxxcY71RXqqKRHZ27RpI3QN2W4P2WkDY6VMlUm13H6tz1dKi4FtNtTgMzvzVFBWbG\/GRfcTgHyNuu2224wPskaNGglfhxgzsW9D\/IfhR4zxDCwybkKsMObdWIIn1W1KRO5UyxarvkRk5yPJyJEjhRcFliL7EOAjjmsVq57SSE9AdmFuGQPv3bp1C77s2JIvXbKXBh4lLdNXSovGMM2ByXXMaeINf\/3110u6zHrkCUeBQEDYoIMuE\/OX+JzKIlljAAAAgUlEQVSem5sbZGXeFpYKFgvzbKzF4h7hCWZIUSAQiF9uVyTaQXtosxufynAgkJjsTObFIy+Y0y1Pl5UFRoFA\/LLTHWRjGO4tZKcNtIVy\/EjcE4zD1ahRI2Xi+U5ppazlWpEioAhkJAKqtDLysqnQikD2IpDJSit7r5q2XBHIYgT+HwAA\/\/\/9XD+SAAAABklEQVQDAFJAt0vtdoHgAAAAAElFTkSuQmCC","height":181,"width":301}}
%---
%[output:9783d4fc]
%   data: {"dataType":"image","outputData":{"dataUri":"data:image\/png;base64,iVBORw0KGgoAAAANSUhEUgAAAS0AAAC1CAYAAAAKoal0AAAQAElEQVR4AeydB5wURfbH34D\/0wMDICoqKFnBdHgSVEQ5A4gi6OkJnOkMqGAEdD3QEwMgYEQRVPTEAJhBDjGgCIInAiIoQYIgUTmSiIKI3H+\/5dVQ2zM907O70zOz8\/jwtrurXlW9\/nX3b15VV70u91\/9pwgoAopADiFQTvSfIqAIKAI5hICSVg5dLDVVEVAERJS0yvhdoKenCJQ1BJS0ytoV1fNRBMo4AkpaZfwC6+kpAmUNASWtNF3RCRMmSO3atWXo0KFpaeGLL76QY445Rnr06JGW+t1Kt2zZIp06dZKTTz5Z1q5d62aFtg+OnC\/nHVqjpdAQ9mI3wn7QKgNjHrTCEuphO+fAfV3CqkpcXEmrxBBmRwWQCaQCuXDDp9OqMNviPHhghgwZIg888IAcddRRJPlKqrbxEKbrx4Xr0K9fP6lUqZKMHj1aDjjgAF+7sz0D3E8\/\/XTp3r27cD0yaW9OkhbeBTeaFW48QOQm4aFFuElsPr\/S5Ftxy\/Ogc6OTRz2U4eGgDvbZUi\/58YS60UP4JfK7oLRJWy+++KLxwGiL+tCnHOUR6nPTbfvYwD51WHvRQzi+4IILZMWKFfLJJ59I586dBX3yrNCeWz\/53vqwER0rlLHl7fY\/\/\/mPxGsLG7DNlqUuW4Ytx+RxruDLvj1X8mmLNCsck44MHz7cPPhHH300h+bcsN3q0i7tI6nYRhtgRaUDBgyIesWk27rZcoxOPKFN2kcPYZ808KVurgfXpX379vLdd9\/FVIEuZSiLgJNX6b333jP3DPkuZrTh4sA+aZTHZvS536jf1uveb1dffXWMB+3mU95t79JLL6Vq4XqYnQz9yTnSAsTXX3+9CFzcHFwkm8iN0q1bN3so3JA2n4vnlueGuummm8yDYAsMHjzYPPwcU9cLL7zAboxQJ3XbjB9++EGuu+463y4Ubd1xxx1W3eihTzmbSH3Ua49La8sDX6NGDVm8eLGp8qeffpJVq1bJwQcfLBUqVDAPrIsLSl5cSYsnP\/74o4Ah52fzqYtrxTFbjtnnXMGXfSucL23ZY7b2F52Hevr06VE7yevdu3f0+nBMu7TPOXHsSjLbXF32E9lCvisQBO3Svk1nH+Jct26dTfLdxisPTuBlC1Gfe8\/gcUIs5Htx4F4ljTwrlKUOjsHSvd8gQ8qQh1DvRRddJFwjjhH3fsRTxGvkelAX+ZmQnCItgBo5cqTstddeMmbMGPn666\/l1ltvNbi9\/fbbZssfv\/y1heMxAN6sWTOZM2eOEfa5cAhlEdLIf\/LJJzmUyZMnFyE1ErnhnnnmGXYFPWw577zzjLdDWZMR5w\/2onvaaacJNyg3FOVIox6KuOfCcTLZf\/\/95ZVXXhFICdupZ8899yxSDJ3GjRsL5w+O2EjbLVq0EB72ILhS4X777RfTViQSMQRI29QLltgCbngXbCmLXeSjx7EVztd7zXhw+EWn\/KZNmwQ7OSdwX716tTlX2rH1zZ071zxsXhwiEX\/bsAObsIPrcs0110giW9BzhfYR6sEOhH1w5ceBujkGCwiCLlai8tzT4ABekK3VpR5bN7iAiR8O9vrasrRP2fvvv9\/c79hm06jX6rGdOnWqwZB0937kPqc9ftz4keN6YANlMiE5RVoABWBHHHGE1KpVy+DFA89NwcWyv25u\/oknnmhIjht92bJlQnluNDwPhH1TkfPHPiD8snATOVnRXR50PBXaph4yuDG42BASx16hLuyx6dzY7Ldu3ZqNUI7y1GMSSvlP3bp1zfmDI21bezgGFxe3eLj6mQMhTpo0SUaMGCF4pTwUPBzob9261RCaxQniufzyy8kywsPAteFhbNeunekG8etuMgv\/YBt5hbvmP+UPOugg8+NAO2BPfbNnz4473pXINlOh8yeZLY6q2QVDduz9gm3YQhrkxzaReMtDapwHOFasWNEUdXHjvE1i4R\/aQg\/cISVwSHQvFxaJetnWXvBDyEOsPXi9dA3Zkp5tklOkVVrg8UBCDq5AGKVVf7bWYwnz3XffNd6jS1IlsZmHnfEUbnSIkYeHhy2VOtGnnHtNIG\/7ILl1kc6Dah84Hi7GbfAgXT32i2Obny3Ul03CUAeYg5GLR0ls5IcMj8+9DpAjJGl\/qOki8oNeknZKUjanSAugAIyuwNKlS8152y4WXZ+qVauaNG5+hAO6GPxS8ytVs2ZNM6CLVxbvBkc\/qHhdZffhYFwkSD084Ohx07FlLIObkJuRYwRvjpuF8+W8SSuu4J1CVDNnzjTej\/3FDYqrX7tgjdDFgvx5gKynZctwTDo40d2w6TwMXBubb9Pt1mJkj7luEBREZbsxtPtb+TlWLbrFLgQdP9uscjJbrJ7dWtvoznFeiD036z1b3XhbW95ef+4brj8\/AG73MF5Zxp\/ocvIDfE1htzaV+8PaCy6IrR97eFboJto0d4vXi0fOs4YH6+aFuZ9TpAVQHTt2NP1ub1fCe5NwU3MDQGoASj7lAZwbnF9p8hEeAh4G9IIKNzgPPRcZW6x7Tr1IkHrwfPhlozuEHWw55i2NJRJrK23QVrJ6uQk5dx4gr661GR1uPtpHB1yC4oq+Feqhrb333tt0wbGf8yDN6vBDQt0ck25x4tgK14Z98ilvhYcYHMCEfARbuYa0TV3o0i466KKDkE99iWxDzwp18KORyBara7dcZ4S2sAVhH0+Nfavnt0UHXe5RzgN70aWLabuHHMcTzpUfcFs2yP0BwdEeNtK2bc\/Wz\/0AjmCBPVbABR0cANrkB4DjTElOkRYg8asC+Oxb4ReXX1F7zIW555577KEZrLf5dC3c8lykxx57THgYogUC7nhtod2HH35YIIcgVTCGwet\/V5dj0rGHNz82r2vXrsIDYo+9W+v5edO9x\/bGxOPC87L53nMh3YsraYi3rYYNGwpzeMgDT7oT2IpniAfAGymOyQcj99qQxrWhLfat8GCQbh9O6x2QzxsyWx\/HiMUtVduoH5upA6FNP1vId4XrzPXmnGw6+7wM4PrZNL8tOtx7bvv2vP3K2HTK2h8D0rCZ+5ofOTxa0rxCmUT3FPcdY5KuPdTJvWE9O8pTj7fuMI\/TSlp4Bpdcconwiylx\/o0ePdoMvFpGD+rxQDxun5sbzVs9D5HVAXQ33y3PwCcXi3zqoYzVJ518HkJuUHS84tbFoKi9oN660KMu6nTrsHq0i3Bs89knDWEKAHbYNqiH+qgXfewjH122HJPuFVsung51Ud4K7VOeutC3bdtj9Ejn2JbFJgiFdPYhRn7R+XXnwaKOWbNmUa3QHTE7hX9oi\/qs2GsAnjyctptcqGp+FKjf6rKlvDcPnUS2gQWCndRh26Qujq3YdOr3CvZxTlaXfdLQo21scNNId8VtnzpsW\/HKWoyxjzrQpQxCmpvPMenooIvwHHItuD4Q2xlnnCH8sPBGELJHx2sPdbrp1MtxhsQ0G0NaTB7s0KGDecVM9yeZmFri\/Pnvf\/8rvEb36x9TZOXKlcKcHcBFEl1c9FVyDwEePu4hLOeB4QeKLg2\/5ng5pCcTvEO6s5RLpqv5\/gjQJcQT5AeEfdulZEyR6+RfMrtyYkgLsvn555+lS5cuUlBQkFDQ8TsdGHzatGly0kkn+anImjVrhDEPX4UUMwA+2S9bilWqeikgwK89P0qu4N3wqx6kevTQp54g+qoTHwE8QBwD9zqwb72p+KWyLzWGtCKRiJm4d+qpp8pZZ52VUNCJd0oMAtNX55fVj5R4O8L8HPrI9erVM+M1Y8eOFUgzXp2apggoAooACMSQ1u677y4tW7aU3XbbjfyEwuzoeAp0C3FDmzRpEi\/bpG3fvl14Q9KrVy9ZsGCB9O\/fXwYOHCifffaZyXf\/0KVQqV1k\/C8AHqpfWzFL533CSxb3OQ1rP4a06Bo+9dRTAuHYQfRffvklsD0LFy6Ujz76yCzajUQivuUqV64seGN0H8uXL2\/G0I477jizzCReIdzYXBPOI9dsxl61+2uzRAwswpBcxduvp8X5pFNiSAvviW7am2++abqJLDz+4x\/\/KHfffbfArMm6b8uXL5cpU6ZI06ZNzS89g6d0E90Jk5zQ\/PnzzZo9SJJjKwzQ2n3dKgKKgCLgRSCGtFDA82nQoIH06dNHmD399NNPC28VzzzzTLM+7o033hA\/74tXou6vE\/M8eNXtHexj0JzlArzJ+PXXX82yEuaCMHEQG8qCvP\/++zl5Gmp3uJetuHiHa2X2tBaXtFzz\/u\/\/\/k8gkkGDBsn48eOFGbFMqNu4caOrFmifWefMxWK+CGNeDMITJI2BeMa2evbsKfXr1w9UlyopAopAfiKQlLTwsPCUGHvC02KyIKS17777BkIMDwvvC2X7ytUeM8mN1fB4ZnQpeQGAnooioAgoAn4IxCUtvCgiHjJjlol9eFh4QTNmzBBIqFGjRkIX0q9STVcEFAFFIF0IxJAWXbj27dvLo48+KmwnTpwojGG1adPGLJ9IlyHprlfrVwQUgbKBQAxp8faOKQ8sv2HGO+uSysap6lkoAopAWUAghrRY5Mwq+vXr1yc9P7yypEqqoAgoAopAKSIQQ1rUzeLU++67TxjHSiTooK+iCGQcATUgbxCIIS26h7fccosw25VB+ESCTt4gpSeqCCgCWYFADGn9\/ve\/N2sPky2WtvlZcRZqhCKgCOQNAjGklTdnrieqCCgCOYTALlOVtHZhoXuKgCKQAwgoaeXARVITFQFFYBcCSlq7sNA9RUARCIjA8g3bZEfVw2TK4k3CfsBipaKWkLSYs0VomsMPP1xY6PzBBx\/IbbfdZiI+lErrWkmaENBqFYH0IjB1ySbZ0vxWOefxWdlDWsTNeuihh0wImueff14OPPBA8\/UUvtrx4IMPyo4dO9KLitauCCgCikAcBHw9rXXr1sm8efOEOVuHHnqolCtXTvbYYw+57LLLTDBAFlXHqU+TFAFFQBFIKwK+pOXXKrHjibHll6\/pioAikHYE8roBX9KqWrWqNGzYUO69914TL5voot99950MHTrUhGEmxnteI6cnrwgoAhlBwJe0IpGIMAhPlIeLL77YfHCCUDV0C+ky4nFlxGJtVBFQBDKOQNhvDN0T9iUtlPbcc0+58847zdgWH15ljIs4W+plgY6KIqAIZAIBX9LavHmz+RYhUR4gLt4k3nXXXdHID0Q2XbVqVSZsTrVN1VcEFIE0InBIlT3SWHts1b6khSpvEMeNGycQmD3m82Kk8xWdc889l2QVRUARUARCQ8CXtHhDuH37dvNtQj6q2rdvX7P\/xBNPCJEgBgwYYEIyh2apNqQIKAKKQCECvqTFbHi+xFOrVq1CtV3\/69ata2bEk+\/N26WV2h512a9Zp1ZStRUBEcUgvxDwJS2CATIQTzeQ2fHAwpYBefbxthYvXsxuiYQ6R44cKcSkL1FFWlgRUARCQ2D5hq2hteVtyJe0IKUbbrhBHnnkEWnatKm0aNFCjj\/+eLn99tuFKRDLli0zs+W9FaZ64mJhMwAAEABJREFUPHfuXIEI+a5iqmVVXxFQBDKDwIoN20zDDMIj5iCkP76kRftHHnmk8DFVvs5TUFAgAwcOFD6qykdbDz\/8cHn33XdRK7Zs2bJFGC\/r3LmzMJm12BVpQUVAESi7CHjOLCFp0XVjvInF0o0bN5bDDjtMVqxYIZ06dRI+flGxYkVPdakd0i2sUaOGNGnSJGnB2rVrmzWPS5cuzZntypUrc8ZWF1e1O9x7LNfwrnlkE5myZJN5Zg+pHO50BxpNSFrDhg0TyKpZs2Zi5bzzzpOaNWsK411UUFxZuHChfPTRR4KXFYlEklbz9ddfCwP\/uSTVq1fPOZvBV+2uFep1yzW8Xxi9q4d1Yt3KSZ\/d0lbwJa3vv\/9eJk6cKCNGjJCXXnrJjGMtWrRIrrvuOjniiCPMtIeSGLN8+XLT1WS8DC\/q9ddfNwTWo0ePklSrZRUBRSDNCAx4Z2m0hRPrVIruh7XjS1o\/\/\/yzsYFf3kqVKgkfb926daucc845MmnSJIHUjEIx\/5x22mlmITYeFIIH9+STT8r9999fzBq1mEFA\/ygCaUSASKW2a7jbuq+ked1KaWwtftW+pMXbQxZFM60B0mJsC6EaCMuSGscqioAiUPYRYJH0daPmR090jwVjovth7viSFvO0OnbsaKY1rF69WurUqSPt2rUzUq1aNalSpUqp2omHhfdVqpVqZYqAIlAqCEBYbmjljo2rCZ5WqVSeYiW+pEU9TG2gK8gYFuFoHnjgARk0aJDcd999gheGjooioAiEiUC4bUFW\/d9ZJn+499\/RWPAQ1uCODcI1xGnNl7RYJM0Y008\/\/WQIiu4iE0CPOeYYefnll4U5Vk49uqsIKAJlCAGXrPo7A+8FrWpJJgkLiGNIi8F23hq+9dZb8uqrrwpbIj1YeeONN0w6ZEYFKoqAIlA2EICoRk7\/Vs4ZPMt4Vi5ZMesdsipoVTPjJxtDWnhQRHJgpvo333xjZqz379\/fxNZiSxytiy66SPbbb7+MG68GKAKKQPERgKR4G0j3zxJV15HzoxNHqRmyKij0rj6\/\/XihW0hapiWGtCCjUaNGGQ+re\/fuZjt58mSxwtKdCy+8UCKR5BNCM31yImqBIqAIWATikRSD63hUdhoDuhAVBIVnBVkVZIF3hV1WYkiLD1gQkmbbtm3Svn17Ybt27VpxhXz0bCW6VQQUgexCwBIU3T28J+tJxSMpLPcSFYQFcZGXbRJDWkwiPf\/886PLduzyHXdLPnrZdjJqjyKQbwjEI6cq3SaaMSkICsKCuFxPCowgqeZ1KklBYdfvzS6NBI8qm4kKm63EkNb+++9vZrwzS91PmAaBnq1Et4pAhhDIi2YhJgTyQSAiPKcg5GQBgqTwnCAmS1Jvdm1USFo1MzKr3dpVnG0MabmVEOVh1qxZ5os8rDlkfhZE5uroviKgCJQcAUiJQXFIiYFxLzExT4o0BB2v52QtgJwQl6A2PNhSXE8qE0tvrH2lsU1IWsTS6tq1q+zYsUMaNWpk1goyzjV+\/PjSaFvrUATyAgEICYlHSpDRHx\/9bfKm7c4xMJ6ImAANYqJ755ITxGQFj4q8XCcoztUrvqTFOkPiXfHpsD59+sgVV1xhPmxBQEDSyfdWpseKQL4hABkhlpAgG7whum+I7cJBTvFIibJ+mLnExNgTRETXznpOdO9Is+SEvl9duZoez25f0mKSKR5WLc+HLTgmnfx4FWqaIlBWEIBQXDJyu21+hARhQVx035BEWEAySNsGe5o5UBAQpIR4iamgVU2jUxY9p0QYxcvzJa0KFSoInxGbP39+kXJEuGTdIct6imTogSKQAwhAREgiMsIrsh6S9Y4gI7fbFpSQbBcObygeKdGd631aVbM0Bh1ICckBKDNmoi9pEZn08ssvFyaYEl65Z8+eJkjfVVddJUR\/IApExqzWhhUBDwIQ0erNO8QlI4gGwStyiYj9RGREXZ7qixziHSFeQrKkBBFZsV048pSUisBY7ANf0qLGk08+2cyIb9myJYfSoEEDGTNmjBD9wSTon6xCoCwZA3EgkBBCl8t2zywRQUZ4RAhE1Hb4SnHJiDIIXhF1JcMHIkL8yMjttkFKXkKypEQdydrS\/OIj4EtaGzdulKFDh8qPP\/4oV155pfTt21duvvlmEzu7+M1pyXxGAOJALAlBKF4ignwsCbEPCSEQle2eUQ4iQoLgCYkgJSUj7bYFQTv9Or6kVb58eTPFAa+K4Hy8NYTI0m+StpArCEBASBAS8hIRJIR4iYj6gpw\/JIS4RHR1k0pmbAiPCMEbsgPa7Pt5RkpGQRDPHh1f0tp7771lwIAB8sUXX5igf2zpLl5wwQXywQcfiK49zJ6LWBqWQBZWZq7aJngziJ8nVNokxDlAQohLRIwFIZAQAvn4EVHnppWib9ggIuqi3jIjeiIGAV\/SMrmFf3iDyGfEHnnkEXnllVfMG8W77rrLfOiiMFv\/ZykCloASeUGMCdEFcwmI486vfyt4QUhxPSFggTQQl4QKWv0WRM4SkSUhPyLq2LiaEhFgqkQRSEhaeFNMeejVq5f5oCpxtI488kghphYhbKK16E5aEYhHQHhBkAoC+SAQDgSEsI\/Y8SD0vATEmBB1BzUeAkISkVAyb6jgf\/ONICP1hoIir3ouAr6kRfiZ1q1by7nnnit8eYfQy5988okw9aF69eoaT8tFMYV9SAJxPaDiEBAkRDkE8kGoN6gpkA8CASGQCFJQ6AnZeUMuAfl5QgUeElIiCnoFVK+4CPiSFpNHeWPIWBZfymHtIYPzQRr68ssvBcLjI6zNmzc3H32NV2706NGCjhXGzIjbFU835bSQCkAUiEtCdhyo94R1JnSt6wXh\/SCuB1RSAuJUISDES0B0wxAICLHdMbYIg9MIOggkZGdoKwGBrEq2IeBLWkwuZSyLMa1UjGZNImTXpUsXWbhwoRQUFJhQzWvWrImpZuXKlTJ48GDzlpLoEdkY8sYlJEtGkBCSrBs2dv4WwQNCqCcGAJ8EyAcJSkDqBfkAqcllEgFf0iru2a5YsUJ27twpeFgs92natKkZvF+3bl1MlRBZ1apVY9IzlQCx0N3C83FJyXpFdkwIEkKC2An5IEpAQdBSHUUgOQKlTloNGzYUYszzMVficU2bNs18gowPvLrmMGmVj8DecccdUq9ePRMpdezYsUIZVy+d+5DUlMWbzJsySIpuG4QFcSUiJUgIcYmIrhVCFwyh6zXz+pomjhH73i4Y40cIXTCE+tJ5rmWvbj2jfEXAl7SI4sDAO1sXHI5nzpwpv\/zyi5scs89Y2B\/+8AezdpGxqkqVKhXR2b59u1SsWFF4M7lgwQLThRw4cKB89tlnRfTsAeNeLNYuDZk6e5H8fdQsaTNouln2EY+kDtp7N0EY32FgGnnyvGoCEb3x12qCPNKmkvRotoeRZlW3CnJw+Y2C\/Pr9GqH7Wxr2hl2H2r1UwsQ81\/DmWUTssxn2Noa0mObAm0Mu2gMPPGAuHoPjVr766iuzpCfZ7PijjjpKZs+eLQQStOKeXOXKlc3nyfgALAP8LVq0kOOOO06mT5\/uqkX3GfMiLE5JpPw+B8rLCyPCGrUnPt0kLLC1DeDp4PlYb+nL3icJMvyqxnJDm6OMnN+8gVnGFNQG3rIG1c0mPbW7VkrXuaTXLtfw5llE7LMT9ract0E+WMGHK84++2zBo2LbrFkz031jy4x4CAnS8ZbleMqUKdKjRw8zTYJjGJm5XatWreIwKsz\/YhoF0ymiiYU76YoewSA63T\/GpQqbMf8tUb3pCezfvG5Rr9Ao6x9FQBEIEwHftmJIiw9W8BaPsSgIiy2samXRokXSu3dvM7ger1YmneJhzZkzxyz1YfrDvHnzhDeRrj5vJ4kYQRcU727y5MlmyZBXzy1TnH3GrSAsL1kVtKplxpvwrJSkioOsllEEMoNADGlBIBs2bBDGoBgkZ2Dcdg3tlu4jevFMrl+\/vtxwww1y\/fXXmwF2IkRce+21cuyxx5pvJzK+NWHCBKlRo4ZQf79+\/YweY1tMXKV8vHqLkwZhXTdyvljCwrOyZFXQqmZxqtQyioAikGEEYkiL7iFf3mHsim4iXUKvkI5ePNsjkcIxo7ZtBQ8K74xt28LjSCQi1osjagRlqZfxLvToVtq4XeSVVCxh2beAEBbdQCWrkiKr5RWBzCIQQ1oQy4gRI4RxKLqJEIpXSEcvs6b7t+5HWBCXf6mczlHjFYG8QSCGtMrCmbtTGCAqPCy2ZeHc9BwUgXxHwJe0GL9i\/Im3f14hnfxsBG\/K4k1FxrCUsLLxKqlNikDxEfAlLbp\/dANt13DJkiXy8ccfy9VXXy2EqOEtYfGbTU9J0y0ctevrQY91aCDqYaUHa601XAS0tV0I+JLWLpXf9iKRiLAU55prrhEG6ZNNLv2tVLh\/6RZCXLTKRFGdygASKopA2UIgMGnZ02b5zebNm80cLJuWDVvIyp3awPyrbLBLbVAEFIHSRcCXtJiL1aFDB2F5jStnnHGGmbrgNyO+dM0LXpslLEoUtKrFRkURUATKIAK+pMWMdcaviIflynPPPSfEiCfsTLbggZdF1xB7GMOia8i+iiKgCJQ9BHxJi8ilp5xyihxzzDEmPvxZZ50lrDlkcScLnLMJCktY2KReFiioKAJlFwFf0uKUhw0bJqeffroQOobjDz\/8UJjuMH78eA6zQvCybNdQvaysuCRqhCKQVgR8SYv1h6wRZHY84WOw4pJLLjFfnR45cqQQVpm0TAukZW04sY5GZ7BYlOmtnlxeI+BLWjt27BC6gQcffHARgOrWrSvkEQywSEaGDga8szTacsfGB0b3dUcRUATKJgK+pLXPPvsIg\/GvvfZadHoDER9YAM3HLipUqJBxRPCy7IJoQh\/rvKyMXxI1QBFIOwK+pLX77rubEDOvvvqqEDaZaQ+El+nTp49069bNEFrarUvSwNQlm6IaHZuolxUFQ3cUgZxGILHxvqRFMSI9EDrmhRdeMJ8CGzJkiBCsjzeK5GdaRn66xpigA\/AGBv2jCOQFAr6kxZdymFzKJFNIiikPxL\/CA8sGZNyu4SGV98gGk9QGRUARCAEBX9JiwXSDBg1kxowZoX7WK+g5Q1pW98S6le2ubhUBRaCMI+BLWiyIJr579+7dhQ+uMqZlxXpgmcTGfWuY31MdMnkVtG1FIHwEfEmLN4ddunSRhx9+WO68804zpmWX87C8h\/zwzd3V4vKN28wB41n61tBAoX8UgbxAwJe0WMZDzHbGsrxCOvmZQoiuIUL76mWBgooikD8IxJAWA+98TYfvEtINtF1Cd0s6epmCqchUB51QmqnLoO2Gg4C24kEghrTo9nXq1MkE\/KMbaLuE7pZ09Dx1pXzImFnr1q2FcM7NmzeXiRMnBqrDTnVAme4hWxVFQBHIDwRiSItuH1MbiJcVL8rDCSecIKXRPWTtYt++fYVxs4ULF5oxs\/79+8uaNb\/NvQoCP4SFBNFVHQaAd6YAABAASURBVEVAESgbCMSQlnta6YzysGLFCtm5c6fgYRGbizeULA9at26da0LMPmNZdumOzs+KgUcTFIEyj4AvaaU7ykPDhg1l1KhRUqVKFWFNI5\/fh7yIQ58IdUjL5seZn2WzdKsIKAJlFAFf0iKSQxhRHr744guztpH5YMTqqlSpUlyoGfdaunSpjJuxK6pDnYpbhbRslZUrV2a1fX64qd1LQ71uuYY3zyIS90ENIdGXtMKK8kA01NmzZwtrHK3EO28+ZVarVi2Zu\/63XMayzm\/eQEjLViHKa7balsgutbtWqPdVruHNs4j89iSG\/9eXtFhjyNSHdEV5mDJlivTo0UN+\/vlnc9YwNwu0V61aZY79\/uh4lh8y+ZGuZ6kI+JIW0EAieD\/piPKw3377CR7WnDlzTLwupj\/MmzdPGjduTNNxRcez4sKiiYpAXiGQkLRAgjd66YjyUL9+fROv6\/rrr5d69erJlVdeKddee60Qs4t244lLWnQP4+lomiKgCJRtBJKSVrpOPxKJSNu2bYVIqPSP2XIciUR8m3RnwtfQcDS+OGmGIpCzCAQwPGOkFcC2GJWpizeaNLwsXSRtoNA\/ikDeIZBTpGUjO+TdVdITVgQUgSgCCUlr8+bN8tJLL0nPnj2LCMttyIvWEsIO41kITelMeFBQUQTyEwFf0mIqwq233ipPPvmkWW6TaXgsYWGHzoQHBRHRjSKQhwj4ktb3338vRC\/95z\/\/Kffdd5+wuNkKER\/23nvvjMGlMbQyBr02rAhkHAFf0iLaw7777ptxA60B7ptDm6ZbRUARyD8EfEmLj7ESgmbgwIGyaNEiWbt2bVQIAPjrr7+GipZ9c0ij+uYQFFTKPgJ6hvEQ8CWt9evXy2OPPSbjxo2TVq1aCTG2rJx\/\/vlCfrwK053GdId0t6H1KwKKQPYi4EtafEJs0qRJwsRPr5BOfpinpWsOw0Rb21IEshcBX9LCZOJcETqGgXimOdBNJHY86eSHJTsrVI02pW8Oo1DojiKQlwgkJC0WS19xxRWyZMkSwbsiMCCRH0aMGBEqWDsrBHkhEKpJ2pgioAhkCAFf0iKG+8iRI+XRRx+VPn36CMH5iMGE18U4F1MiwrK5iKdVJ36QwLBs0XYUAUUgswj4ktbWrVuF6KUQlWtijRo1zCGTT81OCH9c0gqhOW1CEVAEshgBX9Laa6+9hM+EEX3Bnd6wePFiYToEEtZ57ah6WLQpne4QhSLfdvR8FQGDgC9pMbm0a9euZiZ8u3bthAH5Cy+80MTAuvjiiw2hmRpC\/KPTHUIEW5tSBLIUAV\/Swl6C\/7377rty2223ybnnnmsC9b311lvCByjID0vsQLwulA4LcW1HEcheBBKSFmazxvCss84SIox26NBBwp6fxUJpHdPiSqgoAmUbgaBnl5C0Vq9eLRBVw4YNpWnTpnL44Ycb8mIZT9AGSlNP52iVJppalyKQmwj4khZvB++++2456KCDTEhk5mp99NFHQsz4e++917xZDOOU8bRsOzqmZZHQrSKQvwj4khbzsDZt2mQ+88WXcyKRiFSrVk1uuukm+fbbb4WJpmHAtmLjtmgzGhc+CoXuKAJ5i4AvafH2kAmleFxedAhZQ743PR3HrqeVjvpztU61WxHIVwR8SYt5WB07dpQ77rhDeGPI+BZLeYhm2qJFC2HyKeFq4gG3cuVKMxZWp04dOfroo4XvJsZbrzh69GipXbt2VHgr6a1z+Yat0SZ0jlYUCt1RBPIWAV\/S2rBhgwwZMkSWL18uLN3pUPjmEAKDvB5\/\/HEhPA3iRQ4yYywMAlq4cKGMGjVKhg8fLtOmTfOqCuQ2ePDgaCSJSZMmxbydXLFhmymn41kGBv2jCOQ9Ar6kxTgWhDN58mRJJF4EWbPIeBjTJMqXLy+8eWS+1+eff+5VlTVr1kjVqrsiOMQoFCboF3gKQdD\/+YeAnrEvAr6kRYlffvlFnnvuOTnttNPMlIe2bduaoIDush70XKlcubLx0A4++GCTTJx53jwyiG8S\/vfnxx9\/FLw2vLd69eqZIINjx44VbzfSjmnpxNL\/AacbRSDPEUhIWs8++6y8\/vrr0q1bNxk2bJjpEt5\/\/\/3yzDPP+MLGlIgqVaoIXtaqVavkxhtvFNYxnnrqqUXKbN++XSpWrCi9evWSBQsWCPG6CO382WefRfWW\/69rSMKnE8fJ0qVLc0ro\/uaazdirdod7n+Ua3nYcmucyE+JLWoxpffDBB4ZM2rRpI0cddZRceumlMnToUCGdfD+D8dCeeuopOeecc+SII46QJ554whCXq49HRjjnk046yRAcg\/vHHXecTJ8+3VWL7t981UVCxIlcEvDKJXutrWp3rVDvtVzD20Yyjj6cIe+U82uPsDSRSEQgF1eH40gk4ju5lO4dnx3jjeOYMWOEz43Fmx5BBFS+qeidUoFX5rZn9x\/td0f0LaNl+ujWeQOZTWnYnk32BLVF7d71RjsoZiXRy2W8sT1s8SWtffbZxxDW+PHjxY5hQUiEqiFkjR+54Oq+99578uCDD0r16tV9z4c6IDXqo34G+4kk0bhx42gZ3hhueLClfH778bLyw+ejbxkt0+v2a8Xka8Ugk89B9GENcceXtHbffXcz+53opXTb6L6x\/pAopoSsiec9YTez5efOnSuMYbm\/PnQrmYPFVIgJEyYIwQQZhO\/Xr58wEM\/YVs+ePaV+\/fpUU0QgryIJeqAIKAJ5i4AvaYEIZMIbPQbk6eYNGjTITH9gCgP58QRPad68eTEewDXXXGPmYDEXi7eRlOWTZMSh55diypQpwncWSVdRBIoioEeKwC4EEpIWarwNhKSYdwXJ4IGRrqIIKAKKQCYQSEpamTBK21QEFAFFwA8BJS0\/ZDRdEVAEwkIgpXaUtFKCS5UVAUUg0whkLWkxvYLoEESJIGIqi7C3bNmSabyKtB\/URqZ0sByKcyHyBYvPWcJUpLIQD4La7ZrE1BcmQWb6GqRi+8cffyzNmzc38\/tat24tX375pXtKoe4HtZuAA6wO4Z7nRdhFF11klruFamzAxlhjfMkll5iP3gQsUipqWUtaLOd56aWXhLlcn376qYk2wZKiUjnrUqokqI08PC+\/\/LI5Fx4c3rBCwt6JtaVkVtJqgtptK2I5FvPuWOlg0zK1DWr7ihUrzGqOhx56SIg2cvbZZwurNJg0nQnbg9rNdKBZs2bJv\/\/9b5kzZ44JvMkHkzNhs1+b\/Agzv\/If\/\/iHML3JTy9d6VlLWhMnTjRf\/WFpCR\/XwDt5\/\/33hYXW6QIj1XqD2siFPeWUU8zSEOa3nXHGGQIR8EuVapsiUuIiQe2mIR5yVi6ccMIJMUuxyA9bgtrOZOVGjRoJcwx32203ufrqq6V3795myVjYNtNeULvRRcCdLXLAAQewyRrhGWTqEuuLuZ\/DNiwrSYsLtmzZMqlbt24UDy4c6x0BLJqYwZ1UbOzUqZMwT82au2jRIuFBysT0kVTsxt4PP\/xQ6BKyjpTjTEoqtuPRbtu2Tc4880yhS863Orl3IpFI6KeQit3MYSQsFBO5WbfLnEe+Nxq60QkaxIlg3uZtt91mVs0kUE1LVlaSFjcbBMVSn7ScdSlUmoqNXGTOBbeaLm\/fvn2lc+fOwlKpUjAlpSpSsZtxNyYW46X87ne\/S6mddCinYjtdWRbf0z0kisiJJ54odMkZM0qHbYnqTMVuhkBYOcJHZOgeMg5KEE6IL1Eb+ZSXlaTFhFbCPXPjuRcD7yQSCf+X0rXB7qdqIyFfiPTKYvKnn37aeAC2rjC3Qe1m4Bhb8VTiLa0K02bbVlDbrT4fGG7QoIH5ghTLyr777jshSKXND2sb1G7GOOlG4tUSj44fOkKef\/PNN0JcurDszfZ2spK06DaxNpGxIAsgNxxuM16LTcvkNhUbGb+6\/vrrTaiecePGCSsMMmV7ULvpSoE\/60NZQ9quXTthITweCwvbM2F\/UNuxjaCTeDjsWylXrpxEIuH\/6AW1mzGiPfbYw5ob3UJ65EUT8nynXLaeP297GOzDQ+FXhikDRE7lBsgWm4Pa+Morr5h1lZdddlnGBoJdzILYza\/8iBEjomtIeYt7+umny9SpU01sNbe+MPeD2I49rGMl7htjQnQJX331VWFgPll4b8qmQ4LYTU\/i+OOPlzfffNO8qMFuQp4Ty46QUOmwKxfrzFrSOvbYY4UBSH7huZBHHnmkMNcmm0BOZGOPHj3MNyMZi1i8eLHwAQ8GhPFaEKJdMHaRifMJYncm7ArSZlDb0bv22mvl8ssvN1+EWr9+vfk6eiQSvqfFeWGP3\/1s7xX0\/vKXv5jw5nTLGc+iy3jzzTdnxEPEnmyUrCWtSCQiTKxjMJKBVD5dhpvsBTGTx5GIv42EpUb49SRCK5EsXMGL3H\/\/\/TNifiSS3G6vYfzaE4EWD8ybF+ZxJBLM9kgkInjmzCfibe0jjzySkTddFptIJJjd3ONXXXWVmaOF3cyP84tdZ+vO1Jb7lygw3Bth2pC1pBUmCNqWIqAI5A4CSlq5c63UUkVAEShEQEmrEAT9n8UIqGmKgAcBJS0PIHqoCCgC2Y2AklZ2Xx+1ThFQBDwIKGl5ANFDRUARCBOB1NtS0kods1BL8BUj5vEEaTQV3SD1WR0maBKXioXfLJ626cm22I1NyfTCzCf0C\/PkWJWQrpn91Ev9CPthnl8+tKWklQ9XuYTnyMLpQw45RAhRE\/Y8LdZAstC8hKdQpPh5550ns2fPTtvMfuYtsXKgWbNmRdrVg9JBQEmrdHAsUS0s4u3WrZvYaJXsk4ZXMGDAAGHlv\/VymMyH14O3QDBBAtuxsDye7vz584VFw8zE5wGiLCQQz1gmYbLigHpdXeolIgX5bL2eFvVRL2Vop02bNkUihEJ4xEIjj\/oJGUP72IztnANtck7UQ314J3z9iXMnHU8PPMCFaJ609fDDD5sYWdYeoiKwKJq6aAd7aSeRUBZc8QYtThdccIGwdCxeOa\/nCDaUp554+pqWHgSUtNKDa0q1staMG5+IlawAYGEvkSCIrcRKADwD1gH+8MMPMmzYMCHcCrPr2SfUDTOnvboEGOzevbv87W9\/M5E7n3nmGRk0aJBMmTIlxjYie7Iw+u9\/\/7ssWbJEXF3qxcOCKNh6PS3qo17KUA+z0AmlwvnQEB7HnXfeaWz405\/+JJANS1NY5fDWW28JEV1ps1evXgJ5rFu3jmKycuVKIcAc8bxYwsU5Ex4HjAj9PHPmzGjEBkiud+\/eQrtgwXlwPthjKkvy57XXXhNmnmNTixYtzPIrSDJJMc3OEAJKWhkC3tssDy5dFpb9sPznpptu8qoIi30JF8M6Nh58vBIILl73iYedZRYsciZCQMOGDU289GnTpsXUi5dy2GGHCREcIpGIoNuqVSuBVGKUPQnooEsZ2sGrIv4W+6iyho7wMBxj908\/\/SR4WYS7gZhr1qxpotGyfGXnzp3COVHuoIMOEtadkg6REa6YMC0WLZb7AAAD7klEQVSQJouHiVfPuaOLJ3rSSSeZKKW0A8EeeuihgodGfjL585\/\/bKLK0hZtYuOyZcuSFdP8DCGgpJUh4N1m8aS6du1qgtThVdBFsd0oVw+iYh0j0QrwgPAOeMBcHbuPp0DIYaJf0mVChg8fLt9++61ViW7pRtIuhGkTIQfIxR7H2+JNffPNN4KuzYdQIBC8JNLcPI6tbN68WfDAGKyGKJ599llDZjYfW2yYFmzGFkIT2Xwi2VasWNEccq5EAaELynlCkkR4oJxRSPLHjZBLm7SdpIhmZxABJa0Mgm+bpltCJAu8FsiKMRnGc4hpZXXYEh6G7tGkSZME7wiPDJIgzyt4DYwv0UWiK4l8\/vnnJk66VxdvB0\/PejlsOa5WrZpXtcgxD3iVKlWESBY2g24di5MhJZsWb\/v444+bZLp5xP4nfK8lOpPh\/Nl3330Fr2rTpk3RVNqBrEjgXLt06RINo4PtM2bMMF1j8pMJsdqsDjG48Fzx2Gya39Yt56eTYrqqB0BASSsASOlWgYQgIDwX2sJ7InIrv\/g8kG63iXweKnRffPFF4zmRT7qri7fz1VdfmfhXkBCkxaAxpIeuKxAm3UYedHTpinHcsmVLVy1mH\/voGv7rX\/8yg9fEf2Jsi7awP6aAJ4G2IDzipeEFQnQce9RMdIYDDzxQnn\/+eaENgiqib\/Ug53feecd0B6mT8\/jrX\/8qeIFWJ9GW7iV1UveQIUOkevXqprvoLUO0Bbw32oAweXHg1dHj9COgpJV+jJO2cMUVV5ixHLp9vEFk8Pr2228XAh5CKBzzEPJ2rFatWkIa3UP2+bLPDTfcIMTmIt3qMiZ0zz33SL9+\/cyHHSAsxpp4G+c1iLEmPgdFdFW6WDfeeKPccsstQrpX13uMV8iYEF084j\/hAeE1QWheXfeY8CuMVdEtZayKevD4eEMHebi6eGC9CwfaeauHPnGpGIOzOpwTGBA7C\/sZhKfrybiZ1Um0pTzXgLppg7ZoE0yJe8ZbQspfeeWVgrfKRye8Nnh10VdJDwJKWunBNaVa+QVnfIo3X3RtiFbJrz2VMMCN18PbQ7prVo9X+u3bt5c+ffoInhqD7q4uY0kMSL\/99tum24Q+b\/YikdggeJFIxASeQwcviTeCri4ESfvUiU2u4N1BQLz1xH7eMEKY6OA9ul8hcutBh\/PkfLGRPLwn2mnSpIngxXBO1INnQ1eUfPSxj3PDm6P9SCQSjZ2F\/dRHPmWDCPOqKEPd2IRtlKN9sMU2jonbPnr0aOE7nHTl77rrLsFecPHqoq+SHgRymbTSg4jWmnUIbN++XZj6wbwuusZ0JyELpifgjWadwWpQWhH4fwAAAP\/\/FJJfwwAAAAZJREFUAwBPHO5TUranPQAAAABJRU5ErkJggg==","height":181,"width":301}}
%---
