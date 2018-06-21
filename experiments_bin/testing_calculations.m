%% Instructions
%{
mu-rhythm.  
1) gathering the data from the electrodes over the left and right motor cortex; 
2) calculating an FFT; 
3) translating the magnitude of the power between 8-12 Hz into left or right cursor/ball movement on the screen; 
4) creating a GUI that presented targets for the user to “aim” for with the BCI.  
%}
%% Constant Variables
BP = [8,12];
SRATE = 500;
SAMPLING_PERIOD = 1/SRATE;
LENGTH_MILLI = 50000;
%% Get Our Data 
%(Right now its sample data)
EEG = load('sample_data_bci_1');
EEG = EEG.d;
EEG_length = size(EEG,1);
nbchan = size(EEG,2);
freq=(1:EEG_length/2)*SRATE/EEG_length;
freq_index_start = BP(1,1)*(EEG_length/SRATE);
freq_index_stop = BP(1,2)*(EEG_length/SRATE);
FOI = freq(freq_index_start:freq_index_stop);
%% Calculate the FTT                     
%Same result using periodogram but with data scaled
freq=(1:EEG_length/2)*SRATE/EEG_length;
for i=1:nbchan
    current_channel = EEG(:,i);
    psdx = periodogram(current_channel,rectwin(EEG_length),EEG_length,SRATE);
    POI(:,i) = psdx(freq_index_start:freq_index_stop);
end
mean_amplitude_power = mean(POI);

figure
plot(mean_amplitude_power)
grid on
title('Periodogram Using FFT')
xlabel('Channels')
ylabel('mean Power/Frequency (dB/Hz)')



