%% tutorial 1-1
clear;
close all;
NoiseLv = 0.3;
K       = 4;
S       = 2;
for i_noise = 1 : 10
    NoiseLv = 0.1*i_noise;
    cup     = double(imread('cup.png'));
    %%% fill this line     
    cup     = cup.addNoise;
    cup     = cup.lapfil;
    cup.img_show;   
    saveas(gcf,sprintf('Tutorial1_1_NoiseLv%02d',i_noise),'jpg')
    close all
end
