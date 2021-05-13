classdef analysis_EEG_tutorial < analysis_EEG
    properties
        flag_side
    
    end
    
    methods(Static)
        function out_sidebyside = integrateSession_side(in)
            
            fprintf('integrateSession_side\n')
            out = in(1); %template
            
            list_side   = [in(:).flag_side];
            kind_side   = unique(list_side);
            num_side    = numel(kind_side);
            
            out_sidebyside = [];
            for i_side = 1 : num_side
                idx_side    = find(list_side == kind_side(i_side));
                num_run     = numel(idx_side);
                signal_EEG  = zeros([size(out.signal_EEG),num_run]);
                rjct_car    = [];
                
                for i_run   = 1 : num_run
                    rjct_car= [rjct_car;in(idx_side(i_run)).spaPara.rjct_car];
                    signal_EEG(:,:,:,i_run) = in(idx_side(i_run)).signal_EEG;
                end
                
                out.signal_EEG       = signal_EEG;
                out.spaPara          = out.setPara_spa(unique(rjct_car));
                out_sidebyside       = [out_sidebyside;out];
            end
            
        end
    end
    
    methods (Access = private)
        
    end
    
    methods (Access = public)
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
            switch DinEvents{1,2}
                case 'DIN2'
                    data_EEG.flag_side = 0;
                case 'DIN3'
                    data_EEG.flag_side = 1;
            end
        end
    end
    methods (Access = public)
        function data_EEG = analysis_EEG_tutorial(para)
            
        end
    end
end