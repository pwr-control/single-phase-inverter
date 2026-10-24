function single_phase_inverter = single_phase_inverter_hwdata(application_voltage, pwr_nom, fpwm)
%SINGLE_PHASE_INVERTER_HWDATA  Hardware of the two-level full bridge of single_phase_inverter.slx (two_levels/private).
%
%   hw = single_phase_inverter_hwdata(application_voltage, pwr_nom, fpwm)
%
%   application_voltage : [V] 400, 480 or 690 (any other value takes the 690 V set)
%   pwr_nom             : [W] nominal power
%   fpwm                : [Hz] switching frequency
%   hw                  : hw_single_phase_inverter_setup object of the library (normalization ubez, ibez, norm.Xbez)
%
%   Local parameterization of this model: init_model.m calls single_phase_inverter_hwdata and MATLAB takes
%   this copy, being in ./private, before the library one (only for the files of two_levels); the setup
%   class hw_single_phase_inverter_setup and everything that is not in ./private still come from the
%   library. Edit the numbers of this model here.
%
%   Copied on 2026-10-24 from library/setup_files/simulink_models_initialization/single_phase_inverter_hwdata.m.
%   Changes with respect to the library version: none in the numbers (the ones of the legacy runs), this
%   header added. The 690 V set is the one in use (application_voltage = 690 in init_model.m):
%   u_nom = 592.8 V, i_nom = 379.6 A at 225 kW, udc_nom = 1239.4 V, CFi = 6 mF, RCFi = 1 mOhm.
%   single_phase_inverter.slx reads CFi and RCFi (capacitor CFi_dc of dclink) and the normalization
%   (ubez, ibez, udc_bez, udc_nom, norm.Xbez); udc_nom scales the DC voltage measure, the DC link itself
%   is the battery voltage. The model has no output LC filter (the bridge feeds the output transformer):
%   LFu, CFu and the split banks CFi1, CFi2 of the three-level bridge are not used here.
%
%   Quantities of each set:
%   u_nom [V rms] output voltage (application_voltage*1.35*0.9/sqrt(2)); i_nom [A rms] = pwr_nom/u_nom;
%   udc_nom [V] DC link (2/sqrt(3)*1.1*application_voltage*sqrt(2)); f_nom [Hz] output frequency of the
%   data set (the operating frequency of the model is param.spinv.frequency_set);
%   CFi [F] DC link, split for the three-level bridge in the two banks CFi1, CFi2 (upper and lower half);
%   RCFi, RCFi1, RCFi2 [Ohm] their ESR; LFu [H] output filter inductor, LFu_cm [H] common-mode inductor,
%   RLFu, RLFu_cm [Ohm] their resistance (5 % of the reactance at 25 Hz); CFu [F] output filter capacitor,
%   RCFu [Ohm] its damping resistor; Rbrake [Ohm] DC link brake resistor.

    %% dclink for three level is splitted into two parts CFi1, CFi2

  if (application_voltage == 400)
    %% Single Phase Inverter 400V application
    u_nom = application_voltage*1.35*0.9/sqrt(2);
    i_nom = pwr_nom/u_nom;
    udc_nom = 2/sqrt(3)*1.1*application_voltage*sqrt(2);
    f_nom = 50;
    CFi = 1500e-6 * 4; CFi1 = 2*CFi; CFi2 = 2*CFi;
    RCFi = 1e-3; RCFi1 = RCFi/2; RCFi2 = RCFi/2;
    LFu = 500e-6; LFu_cm = 500e-6;
    RLFu = 157*0.05*LFu; RLFu_cm = 157*0.05*LFu_cm;
    CFu = 200e-6;
    RCFu = 50e-3;
    Rbrake = 2.5;
  elseif (application_voltage == 480)
    %% Single Phase Inverter 480V application
    u_nom = application_voltage*1.35*0.9/sqrt(2);
    i_nom = pwr_nom/u_nom;
    udc_nom = 2/sqrt(3)*1.1*application_voltage*sqrt(2);
    f_nom = 60;
    CFi = 1500e-6 * 4; CFi1 = 2*CFi; CFi2 = 2*CFi;
    RCFi = 1e-3; RCFi1 = RCFi/2; RCFi2 = RCFi/2;
    LFu = 500e-6; LFu_cm = 500e-6;
    RLFu = 157*0.05*LFu; RLFu_cm = 157*0.05*LFu_cm;
    CFu = 200e-6;
    RCFu = 50e-3;
    Rbrake = 2.5;
  else
    %% Single Phase Inverter 690V application
    u_nom = application_voltage*1.35*0.9/sqrt(2);
    i_nom = pwr_nom/u_nom;
    udc_nom = 2/sqrt(3)*1.1*application_voltage*sqrt(2);
    f_nom = 50;
    CFi = 1500e-6 * 4; CFi1 = 2*CFi; CFi2 = 2*CFi;
    RCFi = 1e-3; RCFi1 = RCFi/2; RCFi2 = RCFi/2;
    LFu = 500e-6; LFu_cm = 500e-6;
    RLFu = 157*0.05*LFu; RLFu_cm = 157*0.05*LFu_cm;
    CFu = 200e-6;
    RCFu = 50e-3;
    Rbrake = 4;
  end


    single_phase_inverter = hw_single_phase_inverter_setup(application_voltage, pwr_nom, u_nom, i_nom, f_nom, udc_nom, fpwm, CFi, ...
        RCFi, CFi1, RCFi1, CFi2, RCFi2, LFu, RLFu, LFu_cm, RLFu_cm, CFu, RCFu, Rbrake);

end
