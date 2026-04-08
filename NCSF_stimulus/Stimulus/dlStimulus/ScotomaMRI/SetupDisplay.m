function [dv] = SetupDisplay
% Initialize display for stereo viewing
% 
% [dtype] selects display being used. When a gamma correction has been defined for that display,
% will also load corrected gamma table.  Otherwise, just specifies screen size and viewing distance
% for calculating visual degrees.
% 
 
debugFlag = false; % Gets set to true for specific environments below, if needed

% defarg('dv.StereoMode',4);
dv.StereoMode = 4; % Free fusion (lefteye=left, righteye=right)

AssertOpenGL;
dv.multiSample = 8; % Num of samples for aliasing 

% Get the list of Screens and choose the one with the highest screen
% number, as a best guess about where you want the stimulus displayed
dv.scrnNum = max(Screen('Screens'));

% Adjust stimulus position for interocular distance
dv.IOD = 0;


    systemInfo = Screen('Computer');
    if ~isfield(systemInfo,'MACAddress') % Windows does not give much info
        [dummy, output] = system('getmac');
        % colons =  find(output=='-');
        systemInfo.MACAddress = output(160:160+16);
    end    
    
    switch systemInfo.MACAddress

        case 'E8:06:88:CF:81:FF' % Stereoscope in Madison
            dv.widthcm = 2*39.5;
            dv.viewdist = 75;
            dv.StereoMode = 4;
            dv.multiSample = 8;

            % Load gamma table
            %load AvgGammaTable_NEC.mat; OLD
            load FP2141SBgamma_130528.mat;
            dv.gamma = FP2141SBgammatable*[1 1 1];

            dv.IOD = 0;

        case '00:17:F2:01:25:DE' % Stereoscope in Utrecht
            dv.widthcm = 81;
            dv.viewdist = 75;        
            dv.StereoMode = 4;
            load gammaUtrecht.mat;
            dv.gamma = gammaTable*[1 1 1];
            dv.multiSample = 8;  % 8 = max for this computer            
            
        case {'50:E5:49:53:23:86','10:DD:B1:A1:88:E0'} % Martijns laptop
            dv.widthcm = 40;
            dv.viewdist = 45;        
            dv.StereoMode = 4;
            debugFlag = true;
            %dv.multiSample = 1;
            dv.IOD = 0;   
        otherwise 
            fprintf('[%s]: Defaulting to generic display settings',mfilename);
            dv.widthcm = 50;
            dv.viewdist = 90;
            dv.StereoMode = 4;%8;%4;
    end



% Open double-buffered onscreen window with the requested stereo mode:
if debugFlag 
    screenWindow = [50 400 1650 1000];%[0 0 1600 600];%[0 0 1024 384];%[0 0 800 400];
    Screen('Preference', 'SkipSyncTests',1);
else
    screenWindow = [];
    Screen('Preference', 'SkipSyncTests',0);
end

if (dv.StereoMode == 10) || (dv.StereoMode > 5) 
    dv.width = atand((dv.widthcm)/dv.viewdist);
else
    dv.width = atand((dv.widthcm/2)/dv.viewdist);
end

% Define some colors
dv.white=WhiteIndex(dv.scrnNum);
dv.black=BlackIndex(dv.scrnNum);
dv.gray= round((dv.white+dv.black)/2);

if round(dv.gray)==dv.white
    dv.gray=dv.black;
end
dv.inc=dv.white-dv.gray;
dv.backgroundColor = dv.gray; %[0 0 0]; % [100 100 100];

PsychImaging('PrepareConfiguration'); % Start PsychImaging pipeline
%PsychImaging('AddTask', 'AllViews', 'RestrictProcessing', CenterRect([0 0 512 512], Screen('Rect', dv.scrnNum))); % Does not seem to do anything currently?
% PsychImaging('AddTask', 'General', 'SideBySideCompressedStereo');

% dv.StereoMode = 6; % Hardcode stereomode, for debugging
if dv.StereoMode == 10
    Screen('OpenWindow',dv.scrnNum-1, dv.backgroundColor, screenWindow, [], [], dv.StereoMode, multiSample);
else
    [dv.w, dv.windowRect]=PsychImaging('OpenWindow', dv.scrnNum, dv.backgroundColor, screenWindow, [], [], dv.StereoMode, dv.multiSample);
    % SetStereoSideBySideParameters(dv.w, [0.25, 0.25], [0.75, 0.5], [1, 0.25], [0.75, 0.5]);
%     [dv.w, dv.windowRect]=PsychImaging('OpenWindow', dv.scrnNum, dv.backgroundColor, [0 0 800 600], [], [], dv.StereoMode, dv.multiSample);
%     [dv.w, dv.windowRect]=Screen('OpenWindow', dv.scrnNum, dv.backgroundColor, screenWindow, [], [], dv.StereoMode, dv.multiSample);
end

% if exist('gamtrig','var')
%     dv.oldgamma = Screen('LoadNormalizedGammaTable',dv.w,dv.gamma);
% else
%     dv.oldgamma = Screen('ReadNormalizedGammaTable',dv.w);
% end

if isfield(dv,'gamma')
    disp('Loading gamma table');
    dv.oldgamma = Screen('LoadNormalizedGammaTable',dv.w, dv.gamma);
end

% calculate pixels per degree
dv.ppd = dv.windowRect(3)/dv.width;

% if ~isempty(screenWindow)
%     dv.ppd = 1.5 * dv.ppd;
% end

dv.windowCenter = [dv.windowRect(3)./2 dv.windowRect(4)./2];

% text position
if(dv.StereoMode < 6)
    textX = dv.windowRect(3) - 10*dv.ppd;
else
    textX = dv.windowRect(3)/2;
end

textY = (dv.windowRect(4)/2) - 2*dv.ppd;
%dv.textCoords = [textX textY];
dv.textCoords = dv.windowCenter;

% Fixation position
dv.fixationCrosshairs = dv.ppd .* [-0.6 -0.225 0   0   0.6 0.225   0    0; 0   0   0.6 0.225  0   0   -0.6 -0.225];
dv.outerCrossHairs = dv.ppd .* [-10.5 -8.5 0 0 10.5 8.5 0 0; 0 0 10.5 8.5 0 0 -10.5 -8.5];
dv.fixationSquare = dv.ppd .* 8 .* [-1 -0.75 0.75 1 1 1    1     1  1  0.75 -0.75 -1 -1 -1    -1 -1;  1  1      1  1 1 0.75 -0.75 -1 -1 -1     -1  -1 -1 -0.75 0.75 1];
dv.fixationCrosshairColors = [0 0 0; 0 0 0; 128 0 0; 128 0 0]';
dv.lineWidth = 4;
dv.fixationDotSize = .15 .* dv.ppd;

% get frame rate of display
% dv.frate = Screen('FrameRate',dv.w);
dv.frate = 1/Screen('GetFlipInterval',dv.w);

dv.ltheta = 0.00*pi; % Screen rotation to adjust for mirrors
dv.scr_rot = 0; % Screen Rotation for opponency conditions

% Set up alpha-blending for smooth (anti-aliased) drawing of dots:
Screen('BlendFunction', dv.w, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
% Screen('BlendFunction', dv.w, 'GL_SRC_ALPHA', 'GL_ONE'); % This is the blend function gaborium.m uses,
% This seems to just blend all layers together without regard to alpha?

% glEnable(GL.DEPTH_TEST);

%rand('seed',now);
p.randSeed = sum(100*clock);
%RandStream.setGlobalStream(RandStream.create('mt19937ar','seed',p.randSeed));

dv.vbl = Screen('Flip', dv.w);
dv.t = dv.vbl;
dv.ifi=Screen('GetFlipInterval', dv.w);

end
