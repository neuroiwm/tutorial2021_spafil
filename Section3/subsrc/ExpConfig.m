DIN_task    = [2,3];
num_trl     = 15;
time_rest   = 5;
time_ready  = 0;
time_task   = 5;
time_blank  = 3;

DIN_start   = 1;
DIN_rest    = [];
DIN_ready   = [];
DIN_task    = DIN_task(idx_side+1); %right: 2, left: 3
DIN_blank   = [];
DIN_finish  = 4;


sequence_perod = {'rest','ready','task','blank'};