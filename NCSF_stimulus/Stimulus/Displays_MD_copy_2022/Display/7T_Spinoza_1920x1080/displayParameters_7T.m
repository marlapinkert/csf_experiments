function params=displayParameters_7T(gamma)

params.screenNum = 0; %set 1 for device

%% set gamma values;
% gamma = load('/7T_DLP_1600x900/gamma.mat');

Screen('LoadNormalizedGammaTable', params.screenNum, gamma.gamma);

%% set display parameters
params.res = [1920 1080]; %[1920 1080];%[ 800 600 ];
params.screenSize = [69.84  39.29];%[12.9 22.9];%[50.5 28]; % SIZE of screen in cm
%params.screenNum = 1;
params.vDist = 220; %DISTANCE from screen in cm
params.degperpix=2*((atan(params.screenSize./(2*params.vDist))).*(180/pi))./params.res; %visual angle for 1 pixel 
params.pixperdeg = 1./params.degperpix; %n of pixels for 1 visual angle;
params.pixperdeg = ceil(mean(params.pixperdeg));
params.backgroundColor = [ 127 127 127 ];
params.fixationColor = [255 0 0];
ResDiff = ceil((params.res(1) - params.res(2))/2);
params.LineEnds = [ ResDiff, 0, (params.res(1) - ResDiff), params.res(2)];
%params.rectangle = [ 0 0 params.res(1) params.res(2) ];
params.fixationSize = params.pixperdeg*0.5;
params.rect = [ 0 0 params.res ];

%% Open a display window
params.wPtr = Screen('OpenWindow',params.screenNum, ...
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