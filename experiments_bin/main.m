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

%% Filter the data (Beta Rythm)
filt_eeg = bpfilter(BP(1,1),BP(1,2),SRATE,double(EEG));

%% Discard Channels
% Need to keep left and right motor cortext channels only

% TODO: Should we average the channels across the channels?

left_motor = getSubsetChannels(filt_eeg,'left motor');
right_motor = getSubsetChannels(filt_eeg,'right motor');
mu_rhythm = [getMuRhythm(left_motor) getMuRhythm(right_motor)];
h = plotMuRhythm(mu_rhythm);
set(h,'YDataSource','mu_rhythm');
for i = 1:10
mu_rhythm = [rand()*6 rand()*6]

refreshdata
pause(1)
end