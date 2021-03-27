%% ExpAnalysis_tutorial

%{
Readme
Tutorial for analysis of experiment data
After experiment (more than 3 sessions for each hand), please configure
.mat file converted by netstation tools in ExpData directory
%}

clear;
close all;

ExpDir = dir('./ExpData/*.mat');
addpath('./subsrc');
addpath('../Section2/subsrc');

data_EEG = analysis_EEG_tutorial(setPara_Section3);
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

num_fil      = 4;
for i_side = 1 : numel(data_EEG)
    tmp = data_EEG(i_side);
    tmp.COI = sort([tmp.spaPara.CAR,36]);
    
    close all
    for i_fil = 1 : num_fil
        tmp.flag_spa = i_fil-1;
        tmp = tmp.spafilEEG;
        tmp = tmp.fftEEG(tmp.signal_EEG_spafil);
        tmp = tmp.calcERSP;
        [f,tf_median] = tmp.drawTF(tmp.ERSP);
        title(sprintf('%s',tmp.spaPara.filtername));
        tmp.setPos('tile', poslist1, i_fil);
        tmp.saveGCF(sprintf('plot_TF_%s',tmp.spaPara.filtername),4);
        tmp = tmp.findFOI(tf_median);
        
        [f,topo_median]  = tmp.drawTopo(tmp.ERSP);
        tmp = tmp.findCOI(topo_median(:,2));
        
        sgtitle(sprintf('%s',tmp.spaPara.filtername),'FontSize',24);
        tmp.setPos('tile', poslist2, i_fil);
        tmp.saveGCF(sprintf('plot_Topo_%s',tmp.spaPara.filtername),4);
    end
    
    movefile('*.jpg',['Figure_tutorial_section3_',num2str(i_side)]);
end
%%

function data_EEG = batch_preproc(data_EEG)
for i_data = 1 : numel(data_EEG)
    data_EEG(i_data) = data_EEG(i_data).epochEEG;
    data_EEG(i_data) = data_EEG(i_data).preproc;
    data_EEG(i_data) = data_EEG(i_data).chkImpedance;
end
end

