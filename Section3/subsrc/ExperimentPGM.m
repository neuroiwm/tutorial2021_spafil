%#ok<*PROPLC>

classdef ExperimentPGM < Atom_iwm
    properties
        expdate
        para
        para_task
        color
        figs
    end
    
    methods(Static)              
        
        function para_task = setSequence(para_task)
            sequence = para_task.sequence_perod;
            num_seq  = numel(sequence);
            
            time_period = zeros(num_seq,1);
            DIN_out     = NaN(num_seq,1);
            for i_seq = 1 : num_seq
                time_period(i_seq) = para_task.(sprintf('time_%s',sequence{i_seq}));
                tmpDIN             = para_task.(sprintf('DIN_%s',sequence{i_seq}));
                if ~isempty(tmpDIN)
                DIN_out(i_seq)     = tmpDIN;
                end
            end
            para_task.num_seq       = num_seq;
            para_task.time_period   = time_period;
            para_task.DIN_out       = DIN_out;
        end
        
        function [str2,disp2] = generateFixation(pos2,fsize)
            %%% generateFixation
            disp2 = figure(102);
            clf(disp2);
            set(disp2,'color',[0 0 0],'position',pos2,'menu','none','toolbar','none');
            str2 = text(2,1,'+','fontsize',fsize,'fontname','Arial','color','w',...
                'HorizontalAlignment','center');
            axis tight;
            axis off;
            xlim([0 4]); ylim([0 2]);
        end
        
        function obj = changeStr(obj,str,col)
            set(obj,'string',str);
            if nargin == 3
                set(obj,'color',col);
            end
            drawnow limitrate
        end
        
    end
    
    methods (Access = private)
       
        function expData = setPara(expData)
            DispPos     =  get(groot,'MonitorPositions');
            Disp_exp    =  size(DispPos,1);
            list_que    =  {'Rest';'Ready';'Task';' '};
            fsize       = 100;
            varlist     = who;
            varlist(strcmp(varlist,'expData')) = [];
            expData.para = expData.generateStruct(varlist,2);
        end
        
        function expData = generateFigure(expData)
            sz_fig = expData.para.DispPos(expData.para.Disp_exp,:);
            pos1   = [sz_fig(1),sz_fig(2)+sz_fig(4)*2/3, sz_fig(3),sz_fig(4)*1/3]; 
            pos2   = [sz_fig(1),sz_fig(2), sz_fig(3),sz_fig(4)*2/3];
            %%% fig1
            disp1  = figure(101);
            clf(disp1);
            set(disp1,'color',[0 0 0],'position',pos1,'menu','none','toolbar','none');
            str = text(1,1,'wait','HorizontalAlignment','center',...
                'fontsize',expData.para.fsize,'fontname','Arial','color',expData.color.color_ready,'FontWeight','bold');
            axis off; axis tight; xlim([0 2]); ylim([0 2]);
            %%% fig2
            [fixation,disp2] = expData.generateFixation(pos2,150);
            drawnow;
            figure(101);
            
            varlist = who;
            varlist(strcmp(varlist,'expData')) = [];
            expData.figs = expData.generateStruct(varlist,2);
        end
        
        function expData = setPara_task(expData,idx_side)
            ExpConfig;
            varlist = who;
            varlist(strcmp(varlist,'expData')) = [];
            para_task         = expData.generateStruct(varlist,2);
            expData.para_task = expData.setSequence(para_task);
        end
        
         function color = setColor(expData)
            color_rest     = [93, 167, 151]/255;
            color_ready    = [251 179 5]/255;
            color_task     = [167, 93, 93]/255;
            colList(1:3,:) = [color_rest;color_ready;color_task];
            colt           = [0 149	249]/255;
            colList(1:3,:) = [color_rest;color_ready;colt];
            colList(4,:)   = 0;
            latcol         = [1,174,226;255,79,65]'/255;
            
            varlist        =  who;
            color          =  expData.generateStruct(varlist,2);
         end
        
    end
    
    methods (Access = public)
        
    end
    
    methods (Access = public)
        %% init
        function expData = ExperimentPGM(idx_side)
            fprintf('Startup Experiment\n')
            expData.expdate     = expData.datenow;
            expData             = expData.setPara;
            expData.color       = expData.setColor;
            expData             = expData.generateFigure;
            expData             = expData.setPara_task(idx_side);
        end
        
        function expData = initExp(expData,DAQ)
            fprintf('Session Started\n');
            %% loadPara
            eD        = expData; %abbrv and backup
            para_task = eD.para_task;
            %% mainloop            
            DAQ.sendCommand(para_task.DIN_start);%%% initSign
            for i_trl = 1 : para_task.num_trl 
                
                for i_state = 1 : para_task.num_seq
                    if para_task.time_period(i_state) == 0
                        continue
                    else
                        fprintf('%s %02d ',eD.para.list_que{i_state},i_trl);
                    end
                    
                    eD.figs.str = eD.changeStr(eD.figs.str,...
                        eD.para.list_que{i_state},...
                        eD.color.colList(i_state,:));
                    DAQ.sendCommand(para_task.DIN_out(i_state));
                    pause(para_task.time_period(i_state));
                end
                
                %%% reset
            end
            DAQ.sendCommand(para_task.DIN_finish);
            fprintf('Session Finished\n');
            %% postProc
            eD.generateFigure; %reset
        end
    end
end