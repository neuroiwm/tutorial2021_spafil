%% renameFile_forAnonymization
[path_file,num_file] = fullPath(dir('*.mat'));
hdl_anonymization = @ (x) fcn_anonymization(x,'testData');
cellfun(hdl_anonymization,path_file,'UniformOutput',false)

function fcn_anonymization(in,prefix)
if nargin < 2
prefix = 'testData';
end
suffix = ceil(rand(1,1) * 100);
S = load(in);
fname = fieldnames(S);
for i_fname = 1 : numel(fname)
    if contains(fname{i_fname},'mff')
        name    = fname{i_fname};
        idx_mff = strfind(name,'mff');
        S.(sprintf('%s%03d%s',prefix,suffix,name(idx_mff:end))) = S.(name);
        S = rmfield(S,name);
    end
end
save(sprintf('%s%03d',prefix,suffix),'-struct','S');
end
    

function [in,num_in] = fullPath(in)
in        = fullfile({in.folder},{in.name})';
num_in    = numel(in);
end





