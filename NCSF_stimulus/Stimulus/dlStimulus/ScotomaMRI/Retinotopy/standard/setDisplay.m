function params = setDisplay(params)
% setDisplay - setup the (OpenGL) display
%
% setDisplay(params)
%
% Gets display properties
%
% 100601 BR wrote it to separate display setup from stimulus setup

%disp('flipping images to simulate 3T projector view');
%params.flipUD = 1;
%params.flipLR = 1;

%--------------------------------------
% background id, you can change this for manual calibration when only
% having three intensities (black, white and gray=bg)
bg = 128;
%bg = 144;
%--------------------------------------

if ~isempty(params.calibration),
    params.display = loadDisplayParams('displayName',params.calibration);
    disp(sprintf('[%s]:loading calibration from: %s.',mfilename,params.calibration));
else,
    params.display.screenNumber   = max(Screen('screens'));
    [width, height]=Screen('WindowSize',params.display.screenNumber);
    params.display.numPixels  = [width height];
    params.display.dimensions = [24.6 18.3];
    params.display.pixelSize  = min(params.display.dimensions./params.display.numPixels);
    params.display.distance   = 43.0474;%40;
    params.display.frameRate  = 60;
    params.display.cmapDepth  =  8;
    params.display.gammaTable = [0:255]'./255*[1 1 1];
    params.display.gamma      = params.display.gammaTable;
    params.display.backColorRgb   = [bg bg bg 255];
    params.display.textColorRgb   = [255 255 255 255];
    params.display.backColorRgb   = bg;
    params.display.backColorIndex = bg;
    params.display.maxRgbValue    = 255;
    params.display.stimRgbRange   = [0 255];
    params.display.bitsPerPixel   = 32;
    disp(sprintf('[%s]:no calibration.',mfilename));    
end;

if max(Screen('screens')) < params.display.screenNumber,
    disp(sprintf('[%s]:resetting screenNumber %d -> %d.',mfilename,...
        params.display.screenNumber,max(Screen('screens'))));
    params.display.screenNumber   = max(Screen('screens'));
end;

% IMPORTANT: Set stereoMode if using stereo display.  This     %
% will affect both the stimulus presentation and the fixation point %
params.display.stereoMode = 4;%4;%6;%4;%4; % Stereo for cross-fusing
if params.display.stereoMode > 0
    params.display.stereoFlag = 1;
else
    params.display.stereoFlag = 0;
end

% check for OpenGL
AssertOpenGL;

% to skip annoying warning message on display (but not terminal)
Screen('Preference','SkipSyncTests', 1);

% Open the screen
params.display                = openScreen(params.display);
params.display.devices        = params.devices;

% to allow blending
Screen('BlendFunction', params.display.windowPtr, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    