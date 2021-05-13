clear;
close all;
addpath('subsrc/');
data_EEG = analysis_EEG(setPara);
data_EEG = data_EEG.loadEEG(1);
data_EEG = data_EEG.epochEEG;
data_EEG = data_EEG.preproc;
data_EEG = data_EEG.filtfilt_IIR;
%%
COI      = 36;
f        = data_EEG.chkRawWave(COI,4);
data_EEG.setPos_ppt(1);
data_EEG.saveGCF('Example2',4);
%%
f = data_EEG.chkRawWave_wHil(COI,4);
data_EEG.setPos_ppt(1);



for i = 1 : 2
    subplot(2,1,i);
    xlim([0 10])
end