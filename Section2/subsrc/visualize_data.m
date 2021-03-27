
%%% Author: Seitaro Iwama 
%%% 2021.3
%#ok<*PROP>
%#ok<*PROPLC>
classdef visualize_data
    properties
       Font_def 
       flag_box
       
    end
    methods (Static)
        %% Static
        function f = fig
            f = figure;
            hold on;
            set(f,'color',[1 1 1])
        end
        
               
        function setPos(num_case,varargin)
            if ~exist('num_case','var')
                num_case = 2;
            elseif isempty(num_case)
                num_case = 2;
            end
            szmax = get(0,'ScreenSize');
            try
                switch num_case
                    case 1
                        %%% large
                        set(gcf,'Position',szmax*0.95);
                    case 2
                        %%% TF,Topo
                        set(gcf,'Position',[680   296   898   682]);
                    case 3
                        %%% middle
                        set(gcf,'Position',[8 172 953 747]);
                    case 4
                        %%% for Presentation
                        set(gcf,'Position',[680 467 1112 461]);
                    case 5 %for stat vis
                        set(gcf,'Position',[680 467 350 350]);
                    case 'tile'
                        poslist_tile = varargin{1};
                        set(gcf,'Position',poslist_tile(varargin{2},:));
                end
            catch
                set(gcf,'Position',num_case);
            end
            
        end
            
        function setPos_ppt(num_case)
            if ~exist('num_case','var')
                num_case = 2;
            elseif isempty(num_case)
                num_case = 2;
            end
            try
                switch num_case
                    case 1
                        %%% 1 up
                        set(gcf,'Position',[1  1   814   380]);
                    case 2
                        %%% 2 up
                        set(gcf,'Position',[1   1  440 380]);
                    case 3
                        %%% 2 up (trim)
                        set(gcf,'Position',[1   1  500 380]);
                end
            catch
                set(gcf,'Position',num_case);
            end
        end
        
        function poslist = getPosList(x_start,y_start,sz_x,sz_y)
            %%todo
        end
        
        function plotLine(data,t,colN)
            if nargin < 2
                t = 1 : size(data,1);
            end
            if nargin < 3 
                plot(t,data,'LineWidth',1.5,'Color','k');
            elseif isempty(colN)
                plot(t,data,'LineWidth',1.5,'Color','k');
            elseif numel(colN) == 3
                plot(t,data,'LineWidth',1.5,'Color',colN);
            elseif numel(colN) == 1
                colorPalette;
                idx = mod(colN,size(col4,2));
                idx(idx==0) = 1;
                plot(t,data,'LineWidth',1.5,'Color',col4(:,idx));
            end
        end
        
        function str = cleanName(str,flag_inv)
            if nargin < 2
                str(isspace(str))     = '_';
                str(strfind(str,'-')) = '_';
                str(strfind(str,':')) = '_';
            else
                if flag_inv == 99
                    str(strfind(str,'_')) = '-';
                else
                    str(strfind(str,'_')) = ' ';
                end
            end
        end
    end
    
    methods (Access = public)
        
        function setFig(visualize_data,num_case,size_font)
            if nargin < 3
                size_font = 10;
            end
            if nargin < 2
                num_case = 4;
            end
            if isempty(visualize_data.flag_box) || visualize_data.flag_box == 1
                box('on');
            end
            size_font = ceil(size_font*35/19);
            set(gca,'FontWeight','bold');
            set(gca,'Fontsize',size_font,'FontName',visualize_data.Font_def);
            set(gca,'linewidth',2)
            set(gcf,'color',[1 1 1]);
            if num_case == 1
                %%% Amplitude-Time (2D)
                xlabel('Time [s]');
                ylabel('Amplitude [µV]')
            elseif num_case == 2
                %%% imagesc_TF
                colormap('jet')
                xlabel('Time [s]')
                ylabel('Frequency [Hz]');
                axis xy
            elseif num_case == 3 % imagesc_topo
                colormap('jet')
                axis xy
            elseif num_case == 4
                % skip
            elseif num_case == 5
                %%% remove ticks
                xticklabels(cell(numel(xticklabels),1));
                yticklabels(cell(numel(xticklabels),1));
            elseif num_case == 6
                %%% PSD
                xlabel('Frequency [Hz]');
                ylabel('Power [µV^2]')
            end
        end
           
        function formatlist = saveGCF(visualize_data,str,format)
            %% saveGCF(str,format)
            % 1: fig
            % 2: pdf
            % 3: tiffn
            % 4: jpg
            % 5: all
            [~,dirname,~] = fileparts(cd);
            dirname = [dirname,'_',datestr(now,'yyyymmddHHMMSS')];
            
            if ~exist('str','var')
               str = dirname;
            else
                str = visualize_data.cleanName(str);
            end
            if ~exist('format','var')
                format = 4;
            end
            formatlist = {'fig';'pdf';'tiffn';'jpg'};
            num_format = numel(formatlist);
            
            if sum(format > num_format) > 0
                format = 1 : num_format;
            end
            
            for i_format =  1 : numel(format)
                fi = formatlist{format(i_format)};
                try
                    saveas(gcf,str,fi);
                catch
                    saveas(gcf,dirname,fi);
                end
            end
        end
    end
    
    methods (Static)
        %% colorbar
        function cb = setCB(num_case,size_font,N)
            labelName={'ERSP, %';'t-value';'ERSP [dB]'};
            getN = [50,15,5,NaN];
            if ~exist('num_case','var')
                num_case = 3;
            elseif isempty(num_case)
                num_case = 3;
            elseif ischar(num_case)
                label_cb = num_case;
                num_case = 4;
            end
            
            if ~exist('N','var')
                N = getN(num_case);
            elseif isempty(N)
                N = getN(num_case);
            end
            
            if ~exist('size_font','var')
                size_font = 24;
            elseif isempty(size_font)
                size_font = 24;
            end
            size_font = ceil(size_font*35/19);
            cb = colorbar;
            set(cb,'FontSize',size_font);
            if num_case == 1
                try
                    N2 = max(-N,-100);
                    caxis([N2, N])
                    set(cb,'Fontweight','bold',...
                        'Ticks',linspace(-N2,N,5));
                catch
                    N = caxis;
                    caxis([N(1) N(2)])
                    set(cb,'Fontweight','bold',...
                        'Ticks',linspace(N(1),N(2),5));
                end
                
                ylabel(cb,labelName{num_case,1},'FontWeight','bold','Fontsize',size_font)
            elseif num_case ~= 4
                if sign(N) == 1
                    caxis([-N N])
                else
                    N = -N;
                    caxis([0 N])
                end
                set(cb,'Fontweight','bold',...
                    'Ticks',linspace(-N,N,5));
                ylabel(cb,labelName{num_case,1},'FontWeight','bold','Fontsize',size_font)
            else
                try
                    if sign(N) == 1
                        caxis([-N N])
                    else
                        N = -N;
                        caxis([0 N])
                    end
                catch
                    N = caxis;
                    caxis([N(1) N(2)])
                end
                ylabel(cb,label_cb,'FontWeight','bold','Fontsize',size_font)
                set(cb,'Fontweight','bold',...
                    'Ticks',linspace(-N,N,5));
            end
        end
    end
    methods (Access = public)
        %% initilaize
        function out = visualize_data(Font_def)
            if nargin < 1
                Font_def = 'Arial';
            end
            set(groot,'defaultAxesFontName',Font_def);
            set(groot,'defaultTextFontName',    Font_def);
            set(groot,'defaultLegendFontName',  Font_def);
            set(groot,'defaultColorbarFontName',Font_def);
            out.Font_def = Font_def;
        end
    end
end

