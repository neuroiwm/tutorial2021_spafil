
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