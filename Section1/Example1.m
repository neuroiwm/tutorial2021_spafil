clear;
close all;
NoiseLv = 0.3;
K       = 4;
S       = 2;
cup     = double(imread('cup.png'));
cup     = spafil_image(cup,K,S,NoiseLv);
cup     = cup.addNoise;
%cup     = cup.lapfil;
cup     = cup.avefil;
cup.img_show;
saveas(gcf,'Example1','jpg')
