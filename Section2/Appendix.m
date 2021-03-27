%% CompareSpafil_TFandTopo
clear;
close all;
addpath('subsrc/');
data_EEG = analysis_EEG(setPara);
data_EEG = data_EEG.loadEEG;
data_EEG = batch_preproc(data_EEG);
data_EEG = data_EEG(1).integrateSession(data_EEG);
%%
poslist1 = ...
    [  1    90   560   420
    1   549   560   420
    562   549   560   420
    562    91   560   420];

poslist2 =...
    [1462 925 1099 415
    1 510 1099 415
    562 95 1099 415
    1462 91 1099 415];

data_EEG.COI = sort([data_EEG.spaPara.CAR,36]);
num_fil      = 4;
close all
for i_fil = 1 : num_fil
    data_EEG.flag_spa = i_fil-1;
    data_EEG = data_EEG.spafilEEG;
    data_EEG = data_EEG.fftEEG(data_EEG.signal_EEG_spafil);
    data_EEG = data_EEG.calcERSP;
    %%
    [f,tf_median] = data_EEG.drawTF(data_EEG.ERSP);
    title(sprintf('%s',data_EEG.spaPara.filtername));
    data_EEG.setPos('tile', poslist1, i_fil);
    data_EEG.saveGCF(sprintf('plot_TF_%s',data_EEG.spaPara.filtername),4);
    data_EEG = data_EEG.findFOI(tf_median);
    
    [f,topo_median]  = data_EEG.drawTopo(data_EEG.ERSP);
    
    sgtitle(sprintf('%s',data_EEG.spaPara.filtername),'FontSize',24);
    data_EEG.setPos('tile', poslist2, i_fil);    
    data_EEG.saveGCF(sprintf('plot_Topo_%s',data_EEG.spaPara.filtername),4);
end

movefile('*.jpg','Figure_Appendix');
%% 
function data_EEG = batch_preproc(data_EEG)
for i_data = 1 : numel(data_EEG)
    data_EEG(i_data) = data_EEG(i_data).epochEEG;
    data_EEG(i_data) = data_EEG(i_data).preproc;
    data_EEG(i_data) = data_EEG(i_data).chkImpedance;
end
end

