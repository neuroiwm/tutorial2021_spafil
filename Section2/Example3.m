clear;
close all;
addpath('subsrc/');
data_EEG = analysis_EEG(setPara);
data_EEG = data_EEG.loadEEG;
data_EEG = batch_preproc(data_EEG);
%%

poslist =...
    [1 90 814 380
    1 549 814 380
    818 549 814 380
    822 91 814 380];
num_fil     = 4;
idx_run     = 4;
idx_trl_save= 3;
for i_trl = 1 : size(data_EEG(1, 1).signal_EEG,3)
for i_fil = 1 : num_fil
    data_EEG(idx_run).flag_spa = i_fil-1;
    data_EEG(idx_run)   = data_EEG(idx_run).spafilEEG;
    f                   = data_EEG(idx_run).chkSpafilWave(i_trl);
    data_EEG(idx_run).setPos('tile',poslist,i_fil);
    if i_trl == idx_trl_save
        data_EEG(idx_run).saveGCF(sprintf('plot_rawwave_%s',data_EEG(idx_run).spaPara.filtername),4);
    end
end
uiwait(gcf);
close all
end

movefile('*.jpg','Figure_Raw');
%%

function data_EEG = batch_preproc(data_EEG)
for i_data = 1 : numel(data_EEG)
    data_EEG(i_data) = data_EEG(i_data).epochEEG;
    data_EEG(i_data) = data_EEG(i_data).preproc;
    data_EEG(i_data) = data_EEG(i_data).filtfilt_IIR(3,[22 28]);
    data_EEG(i_data) = data_EEG(i_data).chkImpedance;
end
end