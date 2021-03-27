%% ExpPGM_tutorial
close all
addpath('subsrc');
DevID   = 'Dev2'; %6F
DAQ     = DAQclass(DevID);
DAQ     = DAQ.init_output;

idx_side        = input('Right or Left (Right:0, Left:1)->');
Exp_tutorial    = ExperimentPGM(idx_side);
Exp_tutorial    = Exp_tutorial.initExp(DAQ);
pause(0.1);
DAQ.stop_output;
