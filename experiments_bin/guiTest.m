% Clear the workspace and the screen
sca;
close all;
clearvars;

% Here we call some default settings for setting up Psychtoolbox
PsychDefaultSetup(2);

% Seed the random number generator. Here we use the an older way to be
% compatible with older systems. Newer syntax would be rng('shuffle').
% For help see: help rand
rand('seed', sum(100 * clock));

% Get the screen numbers. This gives us a number for each of the screens
% attached to our computer. For help see: Screen Screens?
screens = Screen('Preference', 'SkipSyncTests', 1);

% Draw we select the maximum of these numbers. So in a situation where we
% have two screens attached to our monitor we will draw to the external
% screen. When only one screen is attached to the monitor we will draw to
% this. For help see: help max
screenNumber = 0

% Define black and white (white will be 1 and black 0). This is because
% luminace values are (in general) defined between 0 and 1.
% For help see: help WhiteIndex and help BlackIndex
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);

% Open an on screen window and color it black.
% For help see: Screen OpenWindow?
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, black);

% Get the size of the on screen window in pixels.
% For help see: Screen WindowSize?
[screenXpixels, screenYpixels] = Screen('WindowSize', window);

% Get the centre coordinate of the window in pixels
% For help see: help RectCenter
[xCenter, yCenter] = RectCenter(windowRect);

% Enable alpha blending for anti-aliasing
% For help see: Screen BlendFunction?
% Also see: Chapter 6 of the OpenGL programming guide
Screen('BlendFunction', window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

%Rectangle drawing:
% Make a base Rect of 200 by 200 pixels
baseRect = [0 0 screenXpixels/2 200];
% Set the color of the rect to red
rectColor = [1 0 0];

goodRect = [0 1 0];

badRect = [1 0 0];
leftRect = CenterRectOnPointd(baseRect, screenXpixels/4, screenYpixels - screenYpixels/10);
rightRect = CenterRectOnPointd(baseRect, screenXpixels - screenXpixels/4, screenYpixels - screenYpixels/10);
% Set the color of our dot to full red. Color is defined by red green
% and blue components (RGB). So we have three numbers which
% define our RGB values. The maximum number for each is 1 and the minimum
% 0. So, "full red" is [1 0 0]. "Full green" [0 1 0] and "full blue" [0 0
% 1]. Play around with these numbers and see the result.
dotColor = [255 255 255];
% Dot size in pixels
dotSizePix = 20;

gravity = 13;
dotYpos = 0;
dotXpos = screenXpixels/2;
offset = 0;
sign = 1;
leftColor = badRect;
rightColor = goodRect;

% Make a base Rect of 200 by 250 pixels
baseOval = [0 0 100 100];

% For Ovals we set a miximum diameter up to which it is perfect for
maxDiameter = max(baseOval) * 1.01;

%pause length
trials = 4;
blocks = 2;

blockPauseLength = 5;
trialPauseLength = 1 %seconds
currentBlock = 1;
while (~KbCheck && currentBlock <= blocks)
    if(currentBlock == 1)
        pause_countdown(window,10,'Starting')
    else
        pause_countdown(window,blockPauseLength,'Block Pause')
    end
    currentTrial = 1;
    while(~KbCheck && currentTrial <= trials)
        if(dotYpos > screenYpixels || dotXpos < 0 || dotXpos > screenXpixels)
            dotYpos = 0;
            dotXpos = screenXpixels/2;
            offset = 0;
            if(sign == 1)
               sign = -1;
            else
                sign = 1;
            end

            if(leftColor == goodRect)
                leftColor = badRect;
                rightColor = goodRect;
            else
                leftColor = goodRect;
                rightColor = badRect;
            end
            % Draw the rect to the screen
            Screen('FillRect', window, dotColor, leftRect);
            % Draw the rect to the screen
            Screen('FillRect', window, dotColor, rightRect);
            Screen('Flip', window);
            pause(trialPauseLength);
            currentTrial = currentTrial + 1;
        end
        offset = sign*rand*4;
        % Determine a random X and Y position for our dot. NOTE: As dot position is
        % randomised each time you run the script the output picture will show the
        % dot in a different position. Similarly, when you run the script the
        % position of the dot will be randomised each time. NOTE also, that if the
        % dot is drawn at the edge of the screen some of it might not be visible.
        %Starting position of the dot
        dotXpos = dotXpos + offset;
        dotYpos = dotYpos + gravity;
        % Center the rectangle on the centre of the screen
        centeredOval = CenterRectOnPointd(baseOval, dotXpos, dotYpos);

        % Draw the rect to the screen
        Screen('FillRect', window, leftColor, leftRect);
        % Draw the rect to the screen
        Screen('FillRect', window, rightColor, rightRect);

        % Draw the dot to the screen. For information on the command used in
        % this line type "Screen DrawDots?" at the command line (without the
        % brackets) and press enter. Here we used good antialiasing to get nice
        % smooth edges
        %Screen('DrawDots', window, [dotXpos dotYpos], dotSizePix, dotColor, [], 2);
        Screen('FillOval', window, dotColor, centeredOval, maxDiameter);
        % Flip to the screen. This command basically draws all of our previous
        % commands onto the screen. See later demos in the animation section on more
        % timing details. And how to demos in this section on how to draw multiple
        % rects at once.
        % For help see: Screen Flip?
        Screen('Flip', window);
    end
    currentBlock = currentBlock+1;
end


% Clear the screen. "sca" is short hand for "Screen CloseAll". This clears
% all features related to PTB. Note: we leave the variables in the
% workspace so you can have a look at them if you want.
% For help see: help sca
sca;

function pause_countdown(window,length_pause,message)
    % Get the nominal framerate of the monitor. For this simple timer we are
% going to change the counterdown number every second. This means we
% present each number for "frameRate" amount of frames. This is because
% "framerate" amount of frames is equal to one second. Note: this is only
% for a very simple timer to demonstarte the principle. You can make more
% accurate sub-second timers based on this.
nominalFrameRate = Screen('NominalFrameRate', window);


% Our timer is going to start at 10 and count down to 0. Here we make a
% list of the number we are going to present on each frame. This way of
% doing things is just for you to see what is going on more easily. You
% could eliminate this step completely by simply keeping track of the time
% and updating the clock appropriately, or by clever use of the Screen Flip command
% However, for this simple demo, this should work fine


% Randomise a start color
color = [255 255 255];
% Get the size of the on screen window in pixels.
% For help see: Screen WindowSize?
[screenXpixels, screenYpixels] = Screen('WindowSize', window);
Ypos = (screenYpixels/2) - 100;
Xpos = screenXpixels/2 -50;

% Here is our drawing loop
for i = length_pause:-1:1

    % Convert our current number to display into a string
    numberString = num2str(i);

    
    DrawFormattedText(window, message, Xpos, Ypos, color);
    % Draw our number to the screen
    DrawFormattedText(window, numberString, 'center', 'center', color);

    % Flip to the screen
    Screen('Flip', window);

    pause(1);

end
end