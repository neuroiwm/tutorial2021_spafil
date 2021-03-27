classdef Atom_iwm
    properties
    
    end
    
    methods(Static)
        %% staticFunctions
        function str = datenow
            str = datestr(now,'yyyymmdd_HHMMSS');
        end
        
        
        function out = generateStruct(varlist,flag_place)
            place_list = {'base';'caller'};
            if nargin < 2
                flag_place = 1;
            end
            out = struct;
            for i_var = 1 : numel(varlist)
                out.(varlist{i_var}) = evalin(place_list{flag_place},sprintf('%s',varlist{i_var}));
            end
        end

    end
    
    methods (Access = private)
        
    end
    
    methods (Access = public)
        
    end
    methods (Access = public)
        %% init
        function atomFunc = Atom_iwm
            
        end
        
    end
end