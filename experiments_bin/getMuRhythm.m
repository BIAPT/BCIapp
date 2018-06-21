function [ muRhythm ] = getMuRhythm(EEG,isPlot,BP)
%GETMURHYTHM Summary of this function goes here
%   Detailed explanation goes here

%% Instructions
%{
mu-rhythm.  
1) gathering the data from the electrodes over the left and right motor cortex; 
2) calculating an FFT; 
3) translating the magnitude of the power between 8-12 Hz into left or right cursor/ball movement on the screen; 
4) creating a GUI that presented targets for the user to “aim” for with the BCI.  
%}
%% Constant Variables
SRATE = 1000;
%% Get Our Data 
%(Right now its sample data)
EEG_length = size(EEG,1);

%% Calculate the FTT                      
%Same result using periodogram but with data scaled

freq=(1:EEG_length/2)*SRATE/EEG_length;
psdx = periodogram(EEG,rectwin(length(EEG)),length(EEG),SRATE);

freq_index_start = BP(1,1)*(EEG_length/SRATE);
freq_index_stop = BP(1,2)*(EEG_length/SRATE);
POI = psdx(freq_index_start:freq_index_stop);

if(isPlot)
   assignin('base','freq',freq);
   assignin('base','psdx',psdx);
   figure;
   freq = 1:50;
   for i = 1:128
    if(ismember(i,[7,13,29,30,31,35,36,37,41,42,47,80,87,93,98,103,104,105,106,110,111,112]))            
        plot(freq,psdx(1:length(freq),i));
        hold on;
    end
   end
   title('Power Spectra');
end

% Here we need to calculate a value that will be used for comparison
mean_amplitude_power = mean(POI);
muRhythm = mean_amplitude_power;

end

