function para = setPara
path_EEGData= 'dataDir';
time_rest   = 5;
time_task   = 15;
time_blank  = 3;
num_trl     = 15;

varlist     = who;

para        = generateStruct(varlist,2);
end

