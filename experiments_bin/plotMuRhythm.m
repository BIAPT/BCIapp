function [h] = plotMuRhythm(mu_rhythm)
%PLOTMURHYTHM Summary of this function goes here
%   Detailed explanation goes here

figure
h=bar(mu_rhythm);
xlabel('Brain Side') % x-axis label
ylabel('mu Rhythm Amplitude') % y-axis label
title('Mu Rhythm Amplitude Comparison')
set(gca, 'XTickLabel', {'left motor','right motor'})


end

