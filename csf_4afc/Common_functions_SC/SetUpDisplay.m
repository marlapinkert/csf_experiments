PsychDefaultSetup(0);
if Parameters.DebuggingMode 
    Screen('Preference', 'SkipSyncTests', 1);
end
Screen('Preference', 'VisualDebugLevel', 0);
% Assure the demo is running under PTB-3:
AssertOpenGL;

% Retrieve screen number, resolution (pixel), and measure (cm) information
Parameters.scrnNum = max(Screen('Screens'));
Parameters.ScreenRes = Screen('Resolution',Parameters.scrnNum);
if Parameters.Projector == 0
    [width, height]=Screen('DisplaySize',Parameters.scrnNum); % in mm
elseif Parameters.Projector == 1
    width = 347; height = 217; % in mm (Epson projector at 3.2m with long-range lens)
end

if Parameters.DebuggingMode
    Parameters.ScreenRes.width = Parameters.ScreenRes.width/4;
    Parameters.ScreenRes.height = Parameters.ScreenRes.height/4;
    width = single(width/4);
    height = single(height/4);
end
Parameters.ScreenCM = single([width,height]/10); % in cm
% Hugo MacBook (Debug Mode): 28.5 17.9
% Room B04: 37.5 30.5
% White BOLD: 51.8 32.4
% Epson projector at 3.2m with long-range lens: 35 22

% Conversion of units
Parameters.ScreenWidthpix = single(Parameters.ScreenRes.width);
Parameters.ScreenWidthdeg = 2*rad2deg(atan(Parameters.ScreenCM(1)/(2*Parameters.ViewingDistance)));
Parameters.ScreenHeightpix = single(Parameters.ScreenRes.height);
Parameters.ScreenHeightdeg = 2*rad2deg(atan(Parameters.ScreenCM(2)/(2*Parameters.ViewingDistance)));
Parameters.pixperdeg = Parameters.ScreenWidthpix/Parameters.ScreenWidthdeg;
Parameters.degperpix = 1./Parameters.pixperdeg;

% Check if Gabor.SF is adequate for the screen
% i.e., How much cycles (4pixels) can we fit within 1dVA?
% Parameters.pixperdeg gives us the number of pixels per dVA
MaxCPDperdeg = floor(Parameters.pixperdeg/4);
checkidx = find(Gabor.SFcpd > MaxCPDperdeg, 1);
if ~isempty(checkidx)
    STR = sprintf('\nERROR: Maximum displayable spatial frequency = %s cpd\n',num2str(MaxCPDperdeg));
    disp(STR)
    answer = inputdlg('SPATIAL FREQ. TO TEST (cpd)','Experimental parameters',[1 85],{'0.5,1,3,6,12,20'});
    Gabor.SFcpd = single(str2num(answer{1}));
end

%% Openning the screen window
Parameters.Background = ones(1,3)*0.5; % Grey background

PsychImaging('PrepareConfiguration');
% Enable 32-bit Floating point (increase precision)
PsychImaging('AddTask', 'General', 'FloatingPoint32Bit'); 
if Parameters.Projector == 0 
    % Enable bit stealing - allows more than 256 gray levels (1786+)
    PsychImaging('AddTask', 'General', 'EnablePseudoGrayOutput');
elseif Parameters.Projector == 1 || contains(Parameters.SetUp,'DisplayPlusPlus')
    % Enable 10-bit framebuffer
    PsychImaging('AddTask', 'General', 'EnableNative10BitFramebuffer');
end
aliasingfactor = 10; % > 0 to minimise aliasing: jagged or blocky pattern when representing a high-resolution signal at a lower resolution

if Parameters.DebuggingMode
    NewRes = double([0 0 Parameters.ScreenWidthpix Parameters.ScreenHeightpix]);
    [w, ScreenRect] = PsychImaging('OpenWindow', Parameters.scrnNum, 0, NewRes,[],[],[],aliasingfactor);
elseif ~Parameters.DebuggingMode
    [w, ScreenRect] = PsychImaging('OpenWindow', Parameters.scrnNum, 0,[],[],[],[],aliasingfactor);
end
Screen('BlendFunction', w, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
Priority(MaxPriority(w));
clear aliasingfactor

% Set color range from 0-255 to 0-1 (normalised)
% With clamping of negative values to 0, and values larger to 1 to 1
maximumvalue = 1;
clampcolors = 1; 
applyToDoubleInputMakeTexture = 0;
Screen('ColorRange',w,maximumvalue,clampcolors,applyToDoubleInputMakeTexture);
Screen('FillRect',w,Parameters.Background);
Screen('Flip',w);
clear maximumvalue clampcolors checkidx applyToDoubleInputMakeTexture

% Apply Gamma correction
oldtable = Screen('ReadNormalizedGammaTable', Parameters.scrnNum);  % oldtable will be used in the end to restore the default gamma table
Screen('LoadNormalizedGammaTable', Parameters.scrnNum, gammaTable);

% Get the frame rate
Parameters.FrameRate_hz  = Screen('NominalFrameRate',w);
if ~Parameters.FrameRate_hz
    Parameters.FrameRate_hz = 60;
end
ifi = 1/Parameters.FrameRate_hz;

% Font edit
Screen('TextFont', w, 'Arial');
Screen('TextSize', w, round((3*0.1*ScreenRect(4))/4));

% Fixation point
if Parameters.Subj_Patient==1
    Parameters.FixationSize_Deg = 1.5; % default = 0.19deg diameter
elseif Parameters.Subj_Patient==0
    Parameters.FixationSize_Deg = 0.5; % default = 0.19deg diameter
end
Parameters.FixationSize_Pix = Parameters.FixationSize_Deg*Parameters.pixperdeg/2; % size of fixation point (radius in pixels) -  initially: 5 (which is wrong!)
Parameters.FixationPos = double([ScreenRect(3)/2-Parameters.FixationSize_Pix ScreenRect(4)/2-Parameters.FixationSize_Pix ScreenRect(3)/2+Parameters.FixationSize_Pix ScreenRect(4)/2+Parameters.FixationSize_Pix]);

clear width height MaxCPDperdeg ans STR
