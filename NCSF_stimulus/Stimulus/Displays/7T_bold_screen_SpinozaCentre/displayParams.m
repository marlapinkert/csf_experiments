function params=displayParams(gamma)

params.screenNumber = 0; %set 1 for device

%% set gamma values;
% gamma = load('/data1/projects/dumoulinlab/Lab_members/Marcus/programs/Experiments/vdncsf_protocol/CSF_10bit/Stimulus/Displays/7T_bold_screen_SpinozaCentre/gamma.mat');
params.screenNumber = 0; %max(Screen('Screens')); %set 2 for BOLD screen psychophysics room.
                                               % Set to 0 for 7T BOLD
                                               % screen
                                               
% Screen('LoadNormalizedGammaTable', params.screenNumber, gamma.gamma);

%% set display parameters
params.numPixels = [1920 1080];
params.dimensions = [69.84  39.29];
params.distance = 220;
params.degperpix=2*((atan(params.dimensions./(2*params.distance))).*(180/pi))./params.numPixels; %visual angle for 1 pixel 
params.pixperdeg = 1./params.degperpix; %n of pixels for 1 visual angle;
params.pixperdeg = ceil(mean(params.pixperdeg));
params.backgroundColor = [ 127 127 127 ];
params.fixationColor = [255 0 0];
ResDiff = ceil((params.numPixels(1) - params.numPixels(2))/2);
params.LineEnds = [ ResDiff, 0, (params.numPixels(1) - ResDiff), params.numPixels(2)];
%params.rectangle = [ 0 0 params.numPixels(1) params.numPixels(2) ];
params.fixationSize = params.pixperdeg*0.5;
params.rect = [ 0 0 params.numPixels ];
params.frameRate = 120;
params.cmapDepth = 12; %8;

%% Open a display window
params.wPtr = Screen('OpenWindow',params.screenNumber, ...
params.backgroundColor, params.rect, [], 2);
params.monitorFlipInterval = Screen('GetFlipInterval',params.wPtr);
params.screenFrameRate = ceil(1/params.monitorFlipInterval);

params.fixationRect = [ params.rect(3)/2 - params.fixationSize/2 ...
    params.rect(4)/2 - params.fixationSize/2 ...
    params.rect(3)/2 + params.fixationSize/2 ...
    params.rect(4)/2 + params.fixationSize/2 ];

%% fill the screen with a color
Screen('FillRect', params.wPtr, params.backgroundColor )
%Screen('FillOval', params.wPtr, params.fixationColor, params.fixationRect )

Screen('Flip', params.wPtr )