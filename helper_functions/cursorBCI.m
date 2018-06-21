function cursorBCI(trials,trialPauseLength,blocks,blockPauseLength,gravity,left_chan,saving_file_name,BP,threshold)
% Clear the workspace and the screen
sca;
close all;
ampdeinit;
clear ampsrv;
clear mex;
clear KbCheck

%Set up the Keys to watch for
KbName('UnifyKeyNames');
esc = KbName('escape');
left = KbName('LeftArrow');
right = KbName('RightArrow');
space = KbName('space');
up = KbName('UpArrow');
down = KbName('DownArrow');
devices = PsychHID('Devices');
kboard = 0;
for i = 1: length(devices)
    if(devices(i).totalElements == 349)
        kboard = i;
        break;
    end
end

% Here we call some default settings for setting up Psychtoolbox
PsychDefaultSetup(2);

% Seed the random number generator. Here we use the an older way to be
% compatible with older systems. 
rand('seed', sum(100 * clock));

%Setup base values to launch Psychtoolbox properly and to prepare to draw
%stuff properly on the screen (i.e. 2 rectangle and one white ball)
screens = Screen('Preference', 'SkipSyncTests', 1);
screenNumber = 0
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, black);
[screenXpixels, screenYpixels] = Screen('WindowSize', window);
[xCenter, yCenter] = RectCenter(windowRect);
baseRect = [0 0 screenXpixels/2 200];
goodRect = [0 1 0];
badRect = [1 0 0];
leftRect = CenterRectOnPointd(baseRect, screenXpixels/4, screenYpixels - screenYpixels/10);
rightRect = CenterRectOnPointd(baseRect, screenXpixels - screenXpixels/4, screenYpixels - screenYpixels/10);
dotColor = [255 255 255];
dotYpos = 0;
dotXpos = screenXpixels/2;
offset = 0;
sign = 1;
leftColor = badRect;
rightColor = goodRect;
baseOval = [0 0 100 100];
maxDiameter = max(baseOval) * 1.01;
green_pos = randperm(2)
green_pos = green_pos(1,1);
           
if(green_pos == 1) %If 1 means that green is left
    leftColor = goodRect;
    rightColor = badRect;
else %If 2 means that green is right
    leftColor = badRect;
    rightColor = goodRect;
end

midline = screenXpixels/2;
currentBlock = 1;
sampling_freq = 250;
baseline_EEG = [];
continue_looping =  1;
threshold_offset = 1;
show_debug = 0;
ListenChar(1)
[a,b,keyCode] = KbCheck(kboard);

% Here we setup the saving structure
experiment = create_db(trials,blocks);

% There is two while loop in this part of the code:
% One for the block and one for the trials
while (~any(keyCode(esc))  && currentBlock <= blocks)
    if(currentBlock == 1)
        %Start up the amplifier at the beggining
        ampinit('10.10.10.51');
        ampon;
        ampstart;
        baseline_EEG = pause_countdown(window,5,'Starting')
        %Wait and get a baseline
        left_baseline_EEG = baseline_EEG(:,left_chan);
        left_baseline_mu = getMuRhythm(left_baseline_EEG,0,BP);
    else
        %Wait in between block and get a baseline
        baseline_EEG = pause_countdown(window,blockPauseLength,'Block Pause')
        left_baseline_EEG = baseline_EEG(:,left_chan);
        left_baseline_mu = getMuRhythm(left_baseline_EEG,0,BP);
    end
    
    %Reset Trial variables
    currentTrial = 1;
    new_EEG = [];
    new_avg_mu = [];
    %Trial While loop
    while(~any(keyCode(esc)) && currentTrial <= trials)
        [a,b,keyCode] = KbCheck(kboard); %Code to get keyboard input

        %If we are offscreen we stop the trial
        if(dotYpos > screenYpixels || dotXpos < 0 || dotXpos > screenXpixels)
            
            %Check if we have a success
            if((green_pos == 1 && dotXpos < midline) || (green_pos == 2 && dotXpos > midline))
               new_success = 1; 
            else
               new_success = 0;
            end
            
            %Here it means relax
            if(green_pos == 1)
                isMotor = 0;
            else %Here it means imagery
                isMotor = 1;
            end
            
            %Reset some values and save the trial
            dotYpos = 0;
            dotXpos = screenXpixels/2;
            offset = 0;
            experiment = save_in_db(experiment,currentTrial,currentBlock,new_EEG,new_success,threshold,isMotor,new_avg_mu,mean(new_avg_mu));
            green_pos = randperm(2)
            green_pos = green_pos(1,1);
            
            if(green_pos == 1) %If 1 means that green is left
                leftColor = goodRect;
                rightColor = badRect;
            else %If 2 means that green is right
                leftColor = badRect;
                rightColor = goodRect;
            end
            
            %Redraw the shapes
            % Draw the rect to the screen
            Screen('FillRect', window, dotColor, leftRect);
            % Draw the rect to the screen
            Screen('FillRect', window, dotColor, rightRect);
            Screen('Flip', window);
            pause(trialPauseLength);
            currentTrial = currentTrial + 1;
            new_EEG = [];
            new_avg_mu = [];
        end
        
        %Collect the EEG data
        temp_EEG = ampcollect(sampling_freq);
        new_EEG = [new_EEG; temp_EEG]; %Concatenate the data into one continuous data stream
        left_EEG = temp_EEG(:,left_chan);
        
        %Bandpass filter it and get the mu rhythm
        left_EEG = bpfilter(3,50,1000,left_EEG);
        left_mu = getMuRhythm(left_EEG,0,BP);
        
        new_avg_mu = [new_avg_mu; left_mu];

        % Code to adjust the threshold or the threshold offset 
        % Left is reducing the threshold
        % Right is increasing the threshold
        % Up is increasing the threshold offset
        % Down is decreasing the threshold offset
        % Space is showing useful information for adjusting the threshold
        if(any(keyCode(left)))
            threshold = threshold - threshold_offset;
            if(threshold < 0)
               threshold = 0; 
            end
        elseif(any(keyCode(right)))
            threshold = threshold + threshold_offset;
        elseif(any(keyCode(up)))
            threshold_offset = threshold_offset*2;
        elseif(any(keyCode(down)))
            threshold_offset = threshold_offset/2;
        elseif(any(keyCode(space)))
            if(show_debug == 0)
               show_debug = 1; 
            else
                show_debug = 0;
            end
        end    
        
        % Calculate the pixel offset of where to move the ball
        if(left_mu < threshold)
           offset = (threshold - left_mu); %this should be positive
        else
           offset = (threshold - left_mu);
        end
        
        % Rule based change in the ball movement.
        % Some people have high mu some have low mu, this is in an effort
        % to not get the ball off the screen and to not get the ball stuck
        % in the middle.
        if(left_mu<3)
            offset = offset*50; 
        elseif(left_mu<6)
            offset = offset*15;
        elseif(left_mu<10)
            offset = offset*2.5;
        elseif(left_mu < 20)
            offset = offset;
        elseif(left_mu < 50)
            offset = offset*0.5;
        elseif(left_mu < 100)
            offset = offset*0.25;
        else
            offset = offset*0.125;
        end
        
        %Calculate the position of the ball and draw everything on the
        %screen
        dotXpos = dotXpos + offset;
        dotYpos = dotYpos + gravity;
        centeredOval = CenterRectOnPointd(baseOval, dotXpos, dotYpos);
        Screen('FillRect', window, leftColor, leftRect);
        Screen('FillRect', window, rightColor, rightRect);
        Screen('FillOval', window, dotColor, centeredOval, maxDiameter);
        
        % Debug stuff to draw
        if(show_debug == 1)
            Ypos_debug = 100;
            Xpos_debug = screenXpixels - 300;
            %Here we want to display debugging information:
            %1) Current mu value
            %2) Threshold
            %3) Threshold offset
            debug_message = strcat('Current Mu: ',num2str(left_mu),'\n','Threshold Mu: ',num2str(threshold),'\n','Threshold Offset: ',num2str(threshold_offset),'\n');
            debug_color = [255 255 255];
            DrawFormattedText(window, debug_message, Xpos_debug, Ypos_debug, debug_color);
        end
        
        Screen('Flip', window);
    end
    currentBlock = currentBlock+1;
end

%Save the file at the end
save(saving_file_name, 'experiment');
sca;
end

%Helper functions

%Function to take a break in between block while at the same time
%collecting EEG data
function baseline_EEG = pause_countdown(window,length_pause,message)
    nominalFrameRate = Screen('NominalFrameRate', window);
    color = [255 255 255];
    [screenXpixels, screenYpixels] = Screen('WindowSize', window);
    Ypos = (screenYpixels/2) - 100;
    Xpos = screenXpixels/2 -50;

    baseline_EEG = [];
    % Here is our drawing loop where we draw the countdown
    for i = length_pause:-1:1

        % Convert our current number to display into a string
        numberString = num2str(i);
        DrawFormattedText(window, message, Xpos, Ypos, color);
        DrawFormattedText(window, numberString, 'center', 'center', color);
        Screen('Flip', window);

        %Collect data
        temp_EEG = ampcollect(1000);
        baseline_EEG = [baseline_EEG; temp_EEG];

    end
end

% Create the initial database where we store all the relevant data point
function experiment = create_db(trials,blocks)
    experiment = struct();
    trial.EEG = [];
    trial.success = [];
    trial.isMotor = [];
    trial.left_mu = [];
    trial.avgMu = [];
    trial.threshold = -1;
    block.trial = trial;
    for i = 1:blocks
        experiment.block(i) = block;
        for j = 1:trials
            experiment.block(i).trial(j) = trial;
        end
    end
end

% Save a new trial in the database at the right place
function experiment = save_in_db(experiment,curr_trial,curr_block,new_EEG,new_success,threshold,isMotor,left_mu,avgMu)
    experiment.block(curr_block).trial(curr_trial).EEG = new_EEG;
    experiment.block(curr_block).trial(curr_trial).success = new_success;
    experiment.block(curr_block).trial(curr_trial).threshold = threshold;
    experiment.block(curr_block).trial(curr_trial).isMotor = isMotor;
    experiment.block(curr_block).trial(curr_trial).left_mu = left_mu;
    experiment.block(curr_block).trial(curr_trial).avgMu = avgMu;
end