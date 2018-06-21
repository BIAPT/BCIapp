function [ channels_subset ] = getSubsetChannels( EEG,subset)
%GETSUBSETCHANNELS Summary of this function goes here
%   Detailed explanation goes here
if(strcmp(subset,'left motor'))
    left_motor = EEG(:,1);
    left_motor = left_motor - mean(left_motor);
    channels_subset = left_motor;
elseif(strcmp(subset,'right motor'))
    right_motor = EEG(:,2);
    right_motor = right_motor - mean(right_motor); 
    channels_subset = right_motor;
else
    display('ERROR!Not supported subset!');
end
end

