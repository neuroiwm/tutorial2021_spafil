%%% Author: Seitaro Iwama
%%% 2021.3
%#ok<*PROP>
%#ok<*PROPLC>
classdef analysis_EEG < visualize_data
    properties
        para
        filtPara
        spaPara
        fftPara
        signal_EEG
        signal_EEG_spafil
        impedances
        DinEvents
        Fs
        COI
        flag_spa
        tbl_fft
        ERSP
        FOI
        legend_band
    end
    
    methods (Static)        
        function tmp = fcn_loadEEG(path,para)
            load(path);
            eeg = who('*mff');
            imp = who('Impedances*');
            din = who('evt_*');
            Fs  = who('EEGSamplingRate*');
            tmp = analysis_EEG(para);
            tmp.signal_EEG = eval(eeg{1,1});
            tmp.impedances = eval(imp{1,1});
            tmp.DinEvents  = eval(din{1,1});
            tmp.Fs         = eval(Fs{1,1});
        end
        
        function para = setPara_spa(rjct_car)
            if nargin < 1
                rjct_car = [];
            end
            rjct_car = [rjct_car;36];
            %%% configured for C3 channel in EGI netstation
            COI_spafil = 36;
            SmallLap = [30 35 37 41];
            LargeLap = [13 34 54 46];
            
            CAR             = 1:129;
            CAR(rjct_car)   = [];
            
            filterlist  =  {'Default';'Small Laplacian';'Large Laplacian';'Common Average'};
            filtername  = filterlist{1};
            
            varlist     = who;
            para        = generateStruct(varlist,2);
        end
        
        function para = setPara_fft
            frq     = 50;
            ovrlp   = 0.9;            
            varlist = who;
            para    = generateStruct(varlist,2);
        end
        
        function out = cutBlank(in,time_blank)
            out = in(1:end-time_blank,:,:);
        end
        
        function out = integrateSession(in)
            fprintf('Integrate\n')
            num_run = numel(in);
            out = in(1); %template
            signal_EEG = zeros([size(out.signal_EEG),num_run]);
            rjct_car   = [];
            for i_run = 1 : num_run
                rjct_car = [rjct_car;in(i_run).spaPara.rjct_car];
                signal_EEG(:,:,:,i_run) = in(i_run).signal_EEG;
            end
            out.signal_EEG       = signal_EEG;
            out.spaPara          = out.setPara_spa(unique(rjct_car));
        end
        
        function [eeg,sz_pad] = padEEG(eeg,Fs,sz_win)
            
            if numel(size(eeg))==2
                [time,num_ch] = size(eeg);
                sz_pad = sz_win/2;
                zeropad = zeros(sz_pad,num_ch);
                eeg = [zeropad;eeg;zeropad];
            elseif numel(size(eeg))==3
                [time,num_ch,num_trl] = size(eeg);
                sz_pad = sz_win/2;
                zeropad = zeros(sz_pad,num_ch,num_trl);
                eeg = [zeropad;eeg;zeropad];
            elseif numel(size(eeg))==4
                [time,num_ch,num_trl,num_run] = size(eeg);
                sz_pad = sz_win/2;
                zeropad = zeros(sz_pad,num_ch,num_trl,num_run);
                eeg = [zeropad;eeg;zeropad];
            end
            
        end
        
    end
    
    methods (Access = private)        
        function time_trl = getTrialTime(data_EEG)
            para  = data_EEG(1).para;
            fname = fieldnames(para);
            time_trl = 0;
            idx_time = find(contains(fname,'time'));
            
            for i_time = 1 : numel(idx_time)
                time_trl = time_trl + para.(fname{idx_time(i_time)});
            end
        end
        
      

    end
    
    methods (Access = public)
        %% 
        function data_EEG = loadEEG(data_EEG,idx_run)
            fprintf('loadEEG\n');
            dir_EEG = dir(fullfile(data_EEG.para.path_EEGData,'*.mat'));
            
            if nargin == 2 
                if numel(idx_run) >= idx_run
                    dir_EEG = dir_EEG(idx_run);
                end
            end
                
            out_EEG = analysis_EEG(data_EEG.para);
            for i_file = 1 : numel(dir_EEG)
                tmppath = fullfile(dir_EEG(i_file).folder,dir_EEG(i_file).name);
                out_EEG(i_file)= data_EEG.fcn_loadEEG(tmppath,data_EEG.para);
            end
            data_EEG = out_EEG';
        end
        
        function data_EEG = epochEEG(data_EEG)
            fprintf('epochEEG\n');
            
            time_trl   = data_EEG.getTrialTime;
            time_blank = data_EEG.para.time_blank;
            num_trl    = data_EEG.para.num_trl;
            Fs         = data_EEG.Fs;
            
            signal_EEG = data_EEG.signal_EEG;
            DinEvents  = data_EEG.DinEvents;
            Din_start  = DinEvents{2,1};
            
            signal_EEG = signal_EEG(:,Din_start+1:end);
            signal_EEG = signal_EEG(:,1:time_trl*Fs*num_trl);
            signal_EEG = reshape(signal_EEG,size(signal_EEG,1),time_trl*Fs,[]);
            signal_EEG = double(permute(signal_EEG,[2, 1, 3]));
            signal_EEG = data_EEG.cutBlank(signal_EEG,time_blank*data_EEG.Fs);
            
            data_EEG.signal_EEG     = signal_EEG;
            data_EEG.para.time_trl  = time_trl-time_blank;
        end
        
        function data_EEG = preproc(data_EEG)
            fprintf('preproc\n');
            signal_EEG = data_EEG.signal_EEG;
            signal_EEG = detrend(signal_EEG);
            signal_EEG = filtEEG(signal_EEG,data_EEG.Fs,4,1);
            data_EEG.signal_EEG = signal_EEG;
        end
        
        function data_EEG = filtfilt_IIR(data_EEG,ord,Wn)
            fprintf('filtfilt_IIR\n');
            if nargin < 2
                ord = 3;
            end
            if nargin < 3
                Wn = [8 30];
            end
            Fs = data_EEG.Fs;
            [bpb,bpa] = butter(ord,Wn/(Fs/2));
            varlist = who;
            
            data_EEG.signal_EEG = filtfilt(bpb,bpa,data_EEG.signal_EEG);
            data_EEG.filtPara   = generateStruct(varlist,2);
            
        end
        
        function data_EEG = spafilEEG(data_EEG)
            fprintf('spafilEEG\n');
            COI = data_EEG.COI;
            COI(isempty(COI)) = 36;
            
            signal_EEG_spafil = data_EEG.signal_EEG;
            switch data_EEG.flag_spa
                case 0
                    % default
                    fil = [];
                case 1
                    % small lap
                    fil =  data_EEG.spaPara.SmallLap;
                case 2
                    % large lap
                    fil =  data_EEG.spaPara.LargeLap;
                case 3
                    % car
                    fil =  data_EEG.spaPara.CAR;
            end
            ref             = nanmean(signal_EEG_spafil(:,fil,:,:),2);
            ref(isnan(ref)) = 0;
            signal_EEG_spafil(:,COI,:,:) = signal_EEG_spafil(:,COI,:,:) - ref;
            signal_EEG_spafil          = squeeze(signal_EEG_spafil(:,COI,:,:));
            data_EEG.signal_EEG_spafil = signal_EEG_spafil;
            
            namelist = data_EEG.spaPara.filterlist;
            data_EEG.spaPara.filtername = namelist{data_EEG.flag_spa+1};
        end
        
        function data_EEG = chkImpedance(data_EEG,th)
            fprintf('chkImpedance\n');
            if nargin < 2
                th = 50;
            end
            data_EEG.spaPara.rjct_car = find(data_EEG.impedances > th);
        end
    end
    
    methods (Access = public)
        %% Apendix
        function data_EEG = fftEEG(data_EEG,in)
            fprintf('fftEEG\n');
            if nargin < 2
                in = data_EEG.signal_EEG;
            end
            Fs = data_EEG.Fs;
            in = data_EEG.padEEG(in,Fs,Fs);
            data_EEG.tbl_fft = fftEEG(in,Fs,data_EEG.fftPara.frq,Fs,data_EEG.fftPara.ovrlp);
        end
        
        function data_EEG = calcERSP(data_EEG,ref_win)
            fprintf('calcERSP\n');
            if nargin < 2
                ovrlp   = 1-data_EEG.fftPara.ovrlp;
                ref_win = ceil(1+1/ovrlp : data_EEG.para.time_rest/(ovrlp)+1);
            end
            tmp = data_EEG.tbl_fft;
            ref = nanmedian(tmp(ref_win,:,:,:,:),1);
            tmp = 100*(tmp-ref) ./ ref;
            data_EEG.ERSP = tmp;
        end
        
        function data_EEG = findFOI(data_EEG,tmp,range_task,flag_minmax)
            if nargin < 3
                range_task = data_EEG.getRange_task;
            end
            if nargin < 4
                flag_minmax = 1;
            end
            
            fprintf('findFOI\n');
            [FOI,legend_band] = fcn_findFOI(tmp,range_task,flag_minmax);
            data_EEG.FOI = FOI;
            data_EEG.legend_band = legend_band;
        end
                
        function range_task = getRange_task(data_EEG)
            ovrlp       = data_EEG.fftPara.ovrlp;
            range_task  = data_EEG.para.time_rest/(1-ovrlp) + 1 : data_EEG.para.time_trl/(1-ovrlp);
            range_task  = ceil(range_task);
        end
        
    end
    
    methods (Access = public)
        %% visualization
        function f = chkRawWave(data_EEG,COI,trl,col)
            fprintf('chkRawWave\n');
            if nargin < 2 || isempty(COI)
                COI = data_EEG.COI;
                COI(isempty(COI)) = 36;
            end
            if nargin < 3
                trl = 1;
            elseif isempty(trl)
                trl = 1;
            end
            if nargin < 4    
                col = [];
            end
            Fs   = data_EEG.Fs;
            data = squeeze(data_EEG.signal_EEG(:,COI,:));
            data = data(1:end-data_EEG.para.time_blank*Fs,trl);
            t = 1/Fs : 1/Fs : size(data,1)/Fs;
            f = data_EEG.fig;
            data_EEG.plotLine(data,t,col);
            data_EEG.setFig(1,10)
            title(sprintf('Channel:%02d, Trial:%02d',COI,trl));
        end
        
        function f = chkSpafilWave(data_EEG,trl)
            fprintf('chkSpafilWave\n');
            
            if isempty(trl)
                trl = 1;
            end
            Fs   = data_EEG.Fs;
            data = squeeze(data_EEG.signal_EEG_spafil);
            data = data(1:end-data_EEG.para.time_blank*Fs,trl);
            t = 1/Fs : 1/Fs : size(data,1)/Fs;
            f = data_EEG.fig;
            data_EEG.plotLine(data,t);
            data_EEG.setFig(1,10)
            title(sprintf('%s, Trial:%02d',data_EEG.spaPara.filtername,trl));
        end
        
        function [f,tf_median]      = drawTF(visualize_data,data)
            %%% %drawTF(tbl_ERSP[time,frq,ch,trl],coi,ovrlp,num_run,flag_mm)
            fprintf('drawTF\n');
            ovrlp = visualize_data.fftPara.ovrlp;
            frq   = visualize_data.fftPara.frq;
            if numel(visualize_data.COI) > 2 || isempty(visualize_data.COI)
                COI = 36;
                data = squeeze(data(:,:,find(visualize_data.COI==COI),:,:));
            end

            tf_median = nanmedian(nanmedian(data,3),4)';
            f = visualize_data.fcn_drawTF(tf_median,[1 size(tf_median,2)*(1-ovrlp)],[1 frq]);
        end
        
        function [f,topo_median]    = drawTopo(visualize_data,data,range_task,FOI)
            fprintf('drawTopo\n');
            if nargin < 4 && isempty(visualize_data.FOI)
                FOI = [8 13;14 30];
            elseif ~exist('FOI','var')
                FOI = visualize_data.FOI;
            elseif isempty(FOI) 
                FOI = visualize_data.FOI;
            end
            COI = visualize_data.spaPara.COI_spafil;
            COI(isempty(COI)) = 36;
            
            if nargin < 3
                range_task = visualize_data.getRange_task;
            end
            
            num_band = size(FOI,2);
            topo_median = [];
            f = figure;
            for i_band = 1 : num_band
                subplot(1,num_band,i_band);
                tmp_topo_median = squeeze(nanmedian(nanmedian(nanmean(nanmedian(data(range_task,FOI(i_band,1):FOI(i_band,2),:,:),1),2),4),5));
                %f{i_band} = figure;
                fcn_drawTopo(tmp_topo_median,1:numel(tmp_topo_median),COI);
                visualize_data.setFig(3,10);
                visualize_data.setCB(1,10,100);
                title(sprintf('%s, %d-%d [Hz]',visualize_data.legend_band{i_band},FOI(i_band,1),FOI(i_band,2)));
                topo_median = [topo_median,tmp_topo_median];
            end
            
        end
        
        
        function f = chkRawWave_wHil(data_EEG,COI,trl,col)
            fprintf('chkRawWave\n');
            if nargin < 2 || isempty(COI)
                COI = data_EEG.COI;
                COI(isempty(COI)) = 36;
            end
            if nargin < 3
                trl = 1;
            elseif isempty(trl)
                trl = 1;
            end
            if nargin < 4    
                col = [];
            end
            Fs   = data_EEG.Fs;
            data = squeeze(data_EEG.signal_EEG(:,COI,:));
            data = data(1:end-data_EEG.para.time_blank*Fs,trl);
            data_hil = abs(hilbert(data));
            data_erd = 100*(data_hil-nanmean(data_hil(1:5*Fs))) ./ nanmean(data_hil(1:5*Fs));
            [lpb,lpa]= butter(3,[0.2]/(Fs/2));
            data_erd_lpf = filtfilt(lpb,lpa,data_erd);
            
            t = 1/Fs : 1/Fs : size(data,1)/Fs;
            f = data_EEG.fig;
            subplot(2,1,1);
            data_EEG.plotLine(data,t,col);
            data_EEG.setFig(1,10)
            subplot(2,1,2);
            data_EEG.plotLine(data_erd_lpf,t,1);
            data_EEG.setFig(1,10); 
            setLabel('Time [s]', 'ERSP, %');
            title(sprintf('Channel:%02d, Trial:%02d',COI,trl));
        end
    end
    
    methods (Access = public)
        %% initialize
        function data_EEG = analysis_EEG(para)
            data_EEG.para       = para;
            data_EEG.spaPara    = data_EEG.setPara_spa;
            data_EEG.fftPara    = data_EEG.setPara_fft;
        end
        
    end
end

