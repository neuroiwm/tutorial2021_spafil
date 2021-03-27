function para = setPara_Section3
path_EEGData= 'ExpData';
time_rest   = 5;
time_ready  = 0;
time_task   = 5;
time_blank  = 3;
num_trl     = 15;

varlist     = who;

para        = generateStruct(varlist,2);
end

