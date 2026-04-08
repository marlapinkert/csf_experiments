function params=displayParams(gamma)

params.screenNumber = 0; %set 1 for device

%% set gamma values;
params.screenNumber = 0; %max(Screen('Screens')); %set 1 for BOLD screen psychophysics room.
                                               % Set to 0 for 7T BOLD
                                               % screen
                                               % 
                                               
% Screen('LoadNormalizedGammaTable', params.screenNumber, gamma.gamma);

%% set display parameters
params.numPixels = [1920 1080];
params.dimensions = [69.84  39.29];
params.distance = 196;
params.degperpix=2*((atan(params.dimensions./(2*params.distance))).*(180/pi))./params.numPixels; %visual angle for 1 pixel 
params.pixperdeg = 1./params.degperpix; %n of pixels for 1 visual angle;
params.pixperdeg = ceil(mean(params.pixperdeg));

params.backgroundColor = 0.5; %[32768 32768 32768];%[ 511 511 511 ]; % 127 127 127
params.fixationColor = 1; %[65536 0 0]; %1023,  255

ResDiff = ceil((params.numPixels(1) - params.numPixels(2))/2);
params.LineEnds = [ ResDiff, 0, (params.numPixels(1) - ResDiff), params.numPixels(2)];
%params.rectangle = [ 0 0 params.numPixels(1) params.numPixels(2) ];
params.fixationSize = params.pixperdeg*0.5;
params.rect = [ 0 0 params.numPixels ];
params.frameRate = 120;
params.cmapDepth = 16; %10; %8

%% Prepare to open window, 16 bit
% Make sure that PTB is installed correctly, and set up for use at feature
% level 2
PsychDefaultSetup(2)

% Setup imaging pipeline
PsychImaging('PrepareConfiguration');

% Require a 32 bpc float framebuffer: This would be default, but just to be
% explicit:
PsychImaging('AddTask','General','FloatingPoint32Bit');

% Make sure we run with our default color correction mode for this test: 
% 'ClampOnly' is the default, but set it here explicitly, so no state from
% previously running scripts can bleed through:
PsychImaging('AddTask','FinalFormatting','DisplayColorCorrection','ClampOnly');

% Use Mono++ mode without overlay:
PsychImaging('AddTask','General','EnableBits++Mono++Output');

%% Open a display window
% params.wPtr = Screen('OpenWindow',params.screenNumber, ...
% params.backgroundColor, params.rect, [], 2);
% Open window, assign a gray background
% params.wPtr = PsychImaging('OpenWindow',params.screenNumber,params.backgroundColor);

params.monitorFlipInterval = 120; %Screen('GetFlipInterval',params.wPtr);
params.screenFrameRate = ceil(1/params.monitorFlipInterval);

params.fixationRect = [ params.rect(3)/2 - params.fixationSize/2 ...
    params.rect(4)/2 - params.fixationSize/2 ...
    params.rect(3)/2 + params.fixationSize/2 ...
    params.rect(4)/2 + params.fixationSize/2 ];

%% fill the screen with a color
% % Screen('FillRect', params.wPtr, params.backgroundColor )
% % %Screen('FillOval', params.wPtr, params.fixationColor, params.fixationRect )

% Screen('Flip', params.wPtr )