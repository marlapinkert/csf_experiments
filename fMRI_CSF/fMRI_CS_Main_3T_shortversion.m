%--------------------------
% fMRI CSF experiment - Short version - Hugo Chow-Wing-Bom, 17th August 2023
% Stimulus condition: Grating (Can be circular or non-circular)
%--------------------------
% 4 contrast levels (7.5, 42.2, 60, 100%)
% Paradigm = '13s/2s fixed + 15s baseline' - 3 run sequences (Paradigm 2)
% Two SF tested in 1 run
%--------------------------
% Scanning time = 8min40s per run
%
% Left (pinky-thumb): 01234
% Right (thumb to pinky): 56789

%% Initialisation of Matlab 
clc;
clear all; 
close all; 
commandwindow;

% gammapath = '~/CVL Dropbox/Hugo Chow-Wing-Bom/LHON_ION/Projects/Calibration/Calibration_Data'; % '/Users/Hugo/Documents/Calibration/Calibration_Data';
gammapath = '~/Documents/Calibration/Calibration_Data';

%% Adding paths
addpath('../Common_Functions');
format longG % Display numbers in full digits, not with scientific notation

%% Participant Parameters annd Initial Set-ups
DateToday = datetime(floor(now),'ConvertFrom','datenum','Format','dd-MMM-yy');

prompt = {'SUBJECT ID (YYMMDDInIn)','DOB (dd-mmm-yyyy)','SCAN DATE (dd-mmm-yyyy)','SESSION: BASELINE, 6 MONTHS, > 1 YEAR (1/2/3)?',...
          'RUN NUMBER','PATIENT (0/1)?','CHILD (0/1)?','EYE-TRACKER (0/1)?:','CALIBRATE EYE (0/1)?',...
          'EMULATE TRIGGER (0 = SCANNER/ 1 = KEYPRESS)?', 'VIEWING DISTANCE (cm)', ...
          'SAVE STIMULUS VIDEO (0/1)?','PROJECTOR (0/1)?','SKIP THRESHOLD (0/1)?'};
dltitle = 'EXPERIMENTAL PARAMETERS';
dims = [1 85];
definput = {'241114DB','13-Jun-2001',datestr(DateToday),'1',...
            '1','1','0','1','1',...
            '0','34',...
            '0','1','1'};
answer_ExptParam = inputdlg(prompt,dltitle,dims,definput);

Parameters.Subj_ID = answer_ExptParam{1};
Parameters.Subj_DOB = answer_ExptParam{2};
Parameters.Subj_ScanDate = answer_ExptParam{3};
Parameters.Subj_Session = str2double(answer_ExptParam{4});
Parameters.Run = str2double(answer_ExptParam{5});
Parameters.Subj_Patient = str2double(answer_ExptParam{6});
Parameters.Subj_AgeGroup = str2double(answer_ExptParam{7});

% Intial inputs for eye-tracking
Parameters.Eye_tracker = str2double(answer_ExptParam{8});
EyeTrack.Subj_ID = Parameters.Subj_ID;
EyeTrack.Subj_ScanDate =  Parameters.Subj_ScanDate;
EyeTrack.EyeTested = 'RE';
EyeTrack.EyeIdx = 1; % 1 = RE

Parameters.CalibrateFirst = str2double(answer_ExptParam{9});
Emulate = str2double(answer_ExptParam{10});
Parameters.ViewingDistance = str2double(answer_ExptParam{11});
Parameters.SaveAps = str2double(answer_ExptParam{12});
Parameters.Projector = str2double(answer_ExptParam{13});
Parameters.SkipThreshold = str2double(answer_ExptParam{14});

FolderName = sprintf('../../BehaviourData/%s/%s',Parameters.Subj_ID,'CSF');
if ~exist(FolderName)
    mkdir(FolderName);
end

%% Stimulus Parameters
% % Display configuration modes for contrast levels and presentation mode
% msgtext = 'Contrast levels configuration modes:\n... 1: %s\n... 2: %s\n... 3: %s\n\n Presentation configuration modes:\n... 1: %s\n... 2: %s\n... 3: %s\n\n';
% f = helpdlg(sprintf(msgtext,...
%     num2str([0.1,0.2,0.6,1.3,3.2,7.5,17.8,42.2,80]),...
%     num2str([0.1,0.2,0.6,1.3,3.2,7.5,17.8,42.2,60,80,100]),...
%     num2str([3.2,7.5,17.8,42.2,60,80,100]),...
%     'Initial Configuration: 13/13s ON/OFF block',...
%     '13s/2s fixed + 15s baseline',...
%     'Randomised stimulus (11-13s and aftereffect mid-gray (3-5s) + 1/5 baseline)'));
% set(f, 'position', [1 440 450 250]); %makes box bigger

% Get parameters for grating
prompt = {'SPATIAL FREQ. (cpd)', 'TEMPORAL FREQ. (Hz)', ...
    'PATTERN: CIRCULAR OR STRIPE (1/2)?', 'ORIENTATION (ONLY IF STRIPE PATTERN - DEFAULT: 0deg = HORIZONTAL)','CHANGE GABOR ORIENTATION (0/1)'...
    'GAUSSIAN HULL SD (deg)',...
    'CONFIGURATION FOR CONTRAST LEVELS (1, 2, or 3)','PARADIGM MODE (1, 2, or 3)','SEQUENCE CHOICE (1, 2, or 3) - only if 2nd paradigm',...
    'SIMULATE SCOTOMA (0/1)','DEGREE RADIUS OF EYE MOTION','EYE TESTED (LE, RE, or BIN)'};
dltitle = 'GRATING & PARADIGM';
dims = [1 100];
definput = {'0.3 1','2',...
            '2','0','1',...
            'NaN',...
            '3','2','1','0','0','RE'};
answer_StimParm = inputdlg(prompt,dltitle,dims,definput);
% close(f)

StimulusShape = {'Circular', 'Striped'};
Parameters.Shape = str2double(answer_StimParm{3}); % Circular or Stripe
Parameters.SF = str2num(answer_StimParm{1});  % Spatial Frequency (cpd)
Parameters.TF = str2double(answer_StimParm{2});  % Temporal Frequency: flickering (Hz)
if strcmp(StimulusShape{Parameters.Shape},StimulusShape{1})
    Parameters.Orientation = NaN;
elseif strcmp(StimulusShape{Parameters.Shape},StimulusShape{2})
    Parameters.Orientation =  str2double(answer_StimParm{4});
end
Parameters.ChangeGaborOri = str2double(answer_StimParm{5});
Parameters.SDGaussianHull = str2double(answer_StimParm{6}); % SD of Gaussian hull in deg (spatial constant, default = whole-screen)
Parameters.C_Config = str2double(answer_StimParm{7}); % Contrast levels option
Parameters.P_Config = str2double(answer_StimParm{8}); % Presentation option: block 13s ON/13s OFF (1); 13s/2s + 15s baseline (2); total randomisation (3)
Parameters.Seq_Choice = str2double(answer_StimParm{9});
Parameters.Scotoma = str2double(answer_StimParm{10});
Parameters.EyeMotion = str2num(answer_StimParm{11});
Parameters.EyeTested = answer_StimParm{12};

if Parameters.Scotoma
    answer = input('Enter Ring inner border (deg): ','s');
    Parameters.RingCondition(1) = single(str2num(answer));
    answer = input('Enter Ring outer border (deg): ','s');
    Parameters.RingCondition(2) = single(str2num(answer));
    Parameters.RingConditionLabels = ['ScotomaSim_' num2str(Parameters.RingCondition(1)) '_' num2str(Parameters.RingCondition(2)) 'deg'];
    disp(['Selected condition: ' Parameters.RingConditionLabels])
end

%% Load Calibration data
% disp('Choose calibration matrix...')
if Parameters.Projector == 1
    file = 'Luminances_EPSON_EBL1100U_HalfCalib_512Steps_20210902_210946.mat';
elseif Parameters.Projector == 0
    file = 'Luminances_BOLDWhite_Calib_255Steps_20201207_211703.mat';
end
load(fullfile(gammapath,file)); clear file gammapath;

answer = 'SPLINE';
% Handle response
switch answer
    case 'SPLINE'
        gammaTable = inCorrected_Spline;
    case 'POWER'
        gammaTable = Cal_Power{1,1}.gammaTable';
end

%% Scanning Parameters
Parameters.StartTrig = 5; % Will start the experiment at 5th pulse
Parameters.TR = 1; % second
Parameters.Overrun = 0;   % Dummy volumes at end
Aborted = 0; % To later check if the screen has been aborted by the user or not, so that you know this when aborting the while loop

Parameters.Fringe = 1; % Width of ramped fringe of aperture in pixels
Parameters.Spider_Web = 0.4;  % The alpha of black spiderweb (higher is darker)

% Get indices for Keyboard
[Parameters.KeyBoardIdx, Parameters.productnames, ~] = GetKeyboardIndices();
if length(Parameters.KeyBoardIdx)>1
    disp('%%%%%%%%%%%%%%%% KEYBOARD OPTIONS: %%%%%%%%%%%%%%%%')
    disp(char(Parameters.productnames))
    ExperimenterKeyboard = input('EXPERIMENTER KEYBOARD (c/p keyboard name)? ','s');
    TriggerKeyboard = input('TRIGGER KEYBOARD (c/p keyboard name)? ','s');
    ResponseKeyboard = input('BUTTON PRESS KEYBOARD (c/p keyboard name)? ','s');
else
    disp('%%%%%%%%%%%%%%%% KEYBOARD OPTIONS: %%%%%%%%%%%%%%%%')
    disp(char(Parameters.productnames))
    ExperimenterKeyboard = input('EXPERIMENTER KEYBOARD (c/p keyboard name)? ','s');
    TriggerKeyboard = ExperimenterKeyboard;
    ResponseKeyboard = ExperimenterKeyboard;
end
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')

%% Screen Parameters
% Initialisation of the display
AssertOpenGL
Screen('Preference', 'SkipSyncTests', 1);
Screen('Preference', 'VisualDebugLevel', 0);
Screen('Preference', 'SuppressAllWarnings', 1);

screens = Screen('Screens');
whichScreen = max(screens);
Parameters.ScreenRes = Screen('Resolution',whichScreen); % EPSON: 1920x1200
if Parameters.Projector == 0
    [width, height]=Screen('DisplaySize',whichScreen); % in mm
elseif Parameters.Projector == 1
    width = 432; height = 270; % in mm - Close-up screen Hugo
end
% [width, height]=Screen('DisplaySize',whichScreen);
Parameters.ScreenCM = [width,height]/10; % in cm
% Hugo MacBook (Debug Mode): 28.5 17.9 

% Room B04: 51.8 32.4 (DELL U2412M LCD Monitor, Display Resolution Maximum:
% 1920x1200, Frequency: 60Hz, Image Aspect Ratio: 16:10, Image Brightness:
% 300 cd/m2, Native 8-bit colour resolution) 

% White BOLD: 51.8 32.4 (CRS LCD BOLD Monitor, Display Resolution Maximum:
% 1920 x 1200, Frequency: 60Hz, Image Aspect Ratio: 16:10, Image Brightness:
% up to 800 cd/m2, Native 8-bit colour resolution)

% Epson projector at 3.2m with long-range lens: 35 22

% Conversion of units
Parameters.WidthPx = Parameters.ScreenRes.width;
Parameters.WidthDg = 2*rad2deg(atan(Parameters.ScreenCM(1)/(2*Parameters.ViewingDistance)));
Parameters.WidthPxPerCm = Parameters.WidthPx/Parameters.ScreenCM(1);
Parameters.HeightPx = Parameters.ScreenRes.height;
Parameters.HeightDg = 2*rad2deg(atan(Parameters.ScreenCM(2)/(2*Parameters.ViewingDistance)));
Parameters.HeightPxPerCm = Parameters.HeightPx/Parameters.ScreenCM(2);

Parameters.SizePixCM = 1/Parameters.HeightPxPerCm;
Parameters.PixelPerDg = Parameters.HeightPx/Parameters.HeightDg;
Parameters.PixelPerRad = Parameters.PixelPerDg*180/pi;
Parameters.DgPerPixel = 1./Parameters.PixelPerDg;

PsychImaging('PrepareConfiguration');
% Enable better precision (32-bit floating points
PsychImaging('AddTask', 'General', 'FloatingPoint32BitIfPossible');
if Parameters.Projector == 0
    PsychImaging('AddTask', 'General', 'EnablePseudoGrayOutput');
elseif Parameters.Projector == 1
    PsychImaging('AddTask', 'General', 'EnableNative10BitFramebuffer');
end

aliasingfactor = 10; % > 0 to minimise aliasing: jagged or blocky pattern when representing a high-resolution signal at a lower resolution

if length(screens) == 1
    NewRes = [0 0 800 500]; % in pixels
    [Win, Rect] = PsychImaging('OpenWindow', whichScreen, 0, NewRes,[],[],[],aliasingfactor);
else
    [Win, Rect] = PsychImaging('OpenWindow', whichScreen, 0,[],[],[],[],aliasingfactor);
end
Priority(MaxPriority(Win));
Screen('BlendFunction', Win, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

% Change color range from 0-256 to 0-1
% Set or return the maximum color component value that PTB should allow for
% provided color values when drawing into a window ?windowPtr? or its associated
% Offscreen windows. ?maximumvalue? is the optional new setting for the maximum
% allowed color component value: PTB expects the values of provided color
% components (red, green, blue, alpha or intensity) to be in the range 0 to
% maximumvalue.
% A maximumvalue == 1.0 has special meaning: A maximumvalue of 1.0 will enable PTB
% to pass color values in OpenGL?s native floating point color range of 0.0 to
% 1.0: This has two advantages: First, your color values are independent of
% display device depth, i.e. no need to rewrite your code when running it on
% higher resolution hardware. Second, PTB can skip any color range remapping
% operations - this can speed up drawing significantly in some cases.
maximumvalue = 1;
clampcolors = 1; 
applyToDoubleInputMakeTexture = 0;
Screen('ColorRange',Win,maximumvalue,clampcolors,applyToDoubleInputMakeTexture);
Parameters.Background = ones(1,3).*[0.5 0.5 0.5];
Screen('FillRect',Win,Parameters.Background)
Screen('Flip',Win);

% Black, White, Grey definition
white = WhiteIndex(whichScreen);
black = BlackIndex(whichScreen);
grey = white/2;

% Apply Gamma correction
oldtable = Screen('ReadNormalizedGammaTable', whichScreen);
Screen('LoadNormalizedGammaTable', whichScreen, gammaTable*[1 1 1]); % oldtable will be used in the end to restore the default gamma table

% Define other screen parameters
Parameters.ScreenFrameRate = Screen('NominalFrameRate',Win,1);
if ~Parameters.ScreenFrameRate
    Parameters.ScreenFrameRate = 60;
end

% Parameters for Text to display
Parameters.Text=[0 0 0];
Parameters.FontSize = round((3*0.1*Rect(4))/4);   % FontSize in point: 1pt = 4/3 pixels, and we want the size to be 10% of Y screen resolution
Parameters.FontName = 'Arial';  % Font to use 

% Fixation
Parameters.FixationOval = 1; % add a smooth oval across the fixation
Parameters.Fixation_Color = ones(1,3)*white;    % [0 0 0]% Width of fixation spot/surrounding gap in pixels
if Parameters.Subj_Patient == 1
    Parameters.Fixation_Deg = 2; % diameter = Goldmann Size V
else
    Parameters.Fixation_Deg = 0.5; % diameter = Goldmann Size III
end
% [Deg Fixation Point, Deg Fixation oval surrounding the point]
Parameters.Fixation_Width = [Parameters.Fixation_Deg*Parameters.PixelPerDg (Parameters.Fixation_Deg*1.5)*Parameters.PixelPerDg]; % diameters

% Black-dot Events 
Parameters.Event_Color = ones(1,3)*black; %[75 75 75] Parameters.col2;
Parameters.Prob_of_Event = 0.04;  % Probability of a target event
Parameters.Event_Duration = 0.2;  % Duration of a target event

% Set random seed
rSeed = RandStream('mt19937ar','Seed','shuffle');
RandStream.setGlobalStream(rSeed); %To reproduce the same RandStream::: rSeed rSeed.NormalTransform = 'Ziggurat'; reset(rSeed,1757208590); RandStream.setGlobalStream(rSeed);

%% Run Experiment (Circular Grating)
clc
fprintf('\n%%%%%%%%%% fMRI Contrast Sensitivity Task %%%%%%%%%%\n')
disp([ newline StimulusShape{Parameters.Shape} ' Grating: ' ...
    'SF = ' num2str(Parameters.SF) 'cpd'...
    ', TF = ' num2str(Parameters.TF) 'Hz'...
    ', Orientation = ' num2str(Parameters.Orientation) 'deg'])

if Parameters.Scotoma == 1
    Parameters.Session_name = [Parameters.Subj_ID '_SF' num2str(Parameters.SF) '_TF' num2str(Parameters.TF) '_' Parameters.RingConditionLabels '_' Parameters.EyeTested '_Session' num2str(Parameters.Subj_Session) '_Run' num2str(Parameters.Run)];
    disp(['Running Session: ' Parameters.Session_name newline])
    fMRI_CS_Grating_Scotoma_3T();
else
    if length(Parameters.SF) == 1
        Parameters.Session_name = [Parameters.Subj_ID '_SF' num2str(Parameters.SF) '_TF' num2str(Parameters.TF) '_' Parameters.EyeTested '_Session' num2str(Parameters.Subj_Session) '_Run' num2str(Parameters.Run)];
    else
        Parameters.Session_name = [Parameters.Subj_ID '_SF' num2str(Parameters.SF(1)) '-' num2str(Parameters.SF(2)) '_TF' num2str(Parameters.TF) '_' Parameters.EyeTested '_Session' num2str(Parameters.Subj_Session) '_Run' num2str(Parameters.Run)];
    end
    disp(['Running Session: ' Parameters.Session_name newline])
    fMRI_CS_Grating_3T_shortversion();
end

%% Display 'remain still' and Clean-up screen
ShowCursor;
Screen('DrawText', Win, 'Please remain still', Rect(3)/10,Rect(4)/5, [0, 0, 0, 255]); % Top-left
Screen('DrawText', Win, 'Please remain still', Rect(3)/2-100,Rect(4)/10, [0, 0, 0, 255]); % Top
% Screen('DrawText', Win, 'Please remain still', Rect(3)-Rect(3)/5,Rect(4)/5, [0, 0, 0, 255]); % Top-right

Screen('DrawText', Win, 'Please remain still', Rect(3)/10,Rect(4)-Rect(4)/4, [0, 0, 0, 255]); % Bottom-left
Screen('DrawText', Win, 'Please remain still', Rect(3)/2-100,Rect(4)-Rect(4)/10, [0, 0, 0, 255]); % Bottom
% Screen('DrawText', Win, 'Please remain still', Rect(3)-Rect(3)/5,Rect(4)-Rect(4)/4, [0, 0, 0, 255]); % Bottom-right

% Screen('DrawText', Win, 'Please remain still', Rect(3)/10,Rect(4)/2, [0, 0, 0, 255]); %Centre-left
% Screen('DrawText', Win, 'Please remain still', Rect(3)-Rect(3)/5,Rect(4)/2, [0, 0, 0, 255]); % Centre-right

DrawFormattedText(Win,'Please remain still', 'center', 'center', Parameters.Text); % Centre
Screen('Flip', Win);

WaitSecs(5); % Waits 5 seconds before closing the screen
sca
close all
Screen('LoadNormalizedGammaTable', whichScreen, oldtable); % oldtable will be used in the end to restore the default gamma table

%%  Movie and Stimulus (Only do it if Test)
if Parameters.SaveAps == 1 && strcmp(Parameters.Subj_ID,'Test')
    SaveVideo()
    disp('Video Stimulus saved')
end

% % TEST GRATING ONLY
% CurrVolume = 258;
% CurrReversal = 1; 
% CurrentStimulus = squeeze(Gabor.Stimulus(RunStructure(CurrVolume),:,:,:,:));
% StimCondTex = Screen('MakeTexture', Win, CurrentStimulus(:,:,:,CurrReversal),[],[],2,90);
% % Draw Stimulus
% Screen('DrawTexture', Win, StimCondTex, StimRect, CenterRect([0 0 Rect(4) Rect(4)], Rect),90+Parameters.Orientation,[],[],[],[],kPsychDontDoRotation);
% Screen('Flip',Win)