%% Behavioural CSF task - 4 alternative forced choice (4IFC) - Quest algorithm
% This script will display a 6� diameter Grating patch, at one of the
% pre-defined locations across the visual field. These locations are spaced
% 6��from each other. The contrast of the Gabor in the patch is defined
% using a Quest algorithm. Participants have to judge the orientation of
% the Gabor displayed in the patch out of 4 options (4AFC: horizontal,
% vertical, positive and negative diagonals.

% Tested: 20 presentations per locations = 23.33 minutes

%% INITIALISATION AND PATH DEFINITION ================================
clc; clear all; close all;
commandwindow;

format longG % Display numbers in full digits, not with scientific notation

% Get initial start time for the integrality of the script
time1 = clock; 

% Get the paths
RootDirectory = pwd;
[pathstr, ~, ~] = fileparts(which('CSF_4IFC_Quest_20260402'));
cd(pathstr)
addpath(genpath('resources_SC'));
addpath(genpath('Common_functions_SC'));

disp('%%%%%%%%% Welcome to Contrast Sensivity Task: Quest+ algorithm %%%%%%%%%')

%% GENERAL EXPERIMENTAL PARAMETERS ================================
DateToday = datetime(floor(now),'ConvertFrom','datenum','Format','dd-MMM-yy');

prompt = {'SUBJECT ID (001)','DOB (DD-MMM-YYYY)','TESTING DATE (DD-MMM-YYYY)',...
    'PATIENT (0/1)?','CHILD (0/1)?','EYE TESTED (LE: 1/ RE: 2/ BINOCULAR: 3)', ...
    'PRACTICE (0/1)','VIEWING DISTANCE (cm)','PROJECTOR (0/1)?',...
    'EYETRACKER (0/1)','SET-UP (BOLD, DisplayPlusPlus, EPSON)','DEBUG MODE (0/1)?'};
definput = {'Test','01-Jan-2000',datestr(DateToday),...
    '0','0','3',...
    '0','34','0',...
    '0','DisplayPlusPlus','0'};
answer = inputdlg(prompt,'Experimental parameters',[1 85],definput);
Parameters.Subj_ID = answer{1};
Parameters.Subj_DOB = answer{2};
Parameters.Subj_ScanDate = answer{3};
Parameters.Subj_Patient = single(str2double(answer{4}));
Parameters.Subj_AgeGroup = single(str2double(answer{5}));
EyeTestedLabels = {'LE','RE','BINOCULAR'};
Parameters.Subj_EyeTested = single(str2double(answer{6}));
Parameters.Practice = single(str2double(answer{7}));
Parameters.ViewingDistance = single(str2double(answer{8}));
Parameters.Projector = single(str2double(answer{9}));
Parameters.EyeTrack = single(str2double(answer{10}));
Parameters.SetUp = answer{11};
Parameters.DebuggingMode = single(str2double(answer{12}));

if strcmp(Parameters.SetUp,'EPSON')
    rmpath(genpath('Common_functions_SC/optim'))
end

if Parameters.EyeTrack
   answer = input('WHICH EYE TO TRACK (1=LE, 2=RE)? ','s');
   Parameters.EyeToTrack = single(str2num(answer));
end
    
clear answer prompt definput DateToday

% Create participant's folder
FolderName = sprintf('../data/%s',Parameters.Subj_ID);
if ~exist(FolderName,'dir')
    mkdir(FolderName);
end

%% SCREEN GAMMA CALIBRATION ================================
if contains(Parameters.SetUp,'DisplayPlusPlus')
    load(fullfile(pathstr,'John_CalDataDisplayPlusPlus.mat'),'inCorrected_Spline');
elseif contains(Parameters.SetUp,'BOLD')
    load(fullfile(pathstr,'Luminances_BOLDWhite_Calib_255Steps_20201207_211703.mat'),'inCorrected_Spline');
elseif contains(Parameters.SetUp,'EPSON')
    load(fullfile(pathstr,'Luminances_EPSON_EBL1100U_HalfCalib_512Steps_20210902_210946.mat'),'inCorrected_Spline');
end
gammaTable = inCorrected_Spline;
if size(gammaTable,2) ~= 3
    gammaTable = inCorrected_Spline*[1 1 1];
end
clear inCorrected_Spline;

%% GABOR PARAMETERS ================================
prompt = {'RUN NUMBER','SPATIAL FREQ. TO TEST (cpd)','NUMBER OF TRIALS PER LOCATION', ...
    'SD GAUSSIAN HULL (deg - NaN = no Gaussian Hull)',...
    'TEMPORAL FREQ. (Hz)','PATCH SIZE (deg diameter)'};
definput = {'1','1','5','NaN','2','6'};
answer = inputdlg(prompt,'Experimental parameters',[1 100],definput);

Gabor.RunNumber = single(str2num(answer{1}));
Gabor.SFcpd = single(str2num(answer{2}));
Gabor.nTrials = single(str2num(answer{3}));
Gabor.SpacialConstant_Deg = single(str2num(answer{4}));
Gabor.TF = single(str2num(answer{5}));
Gabor.PatchSize = single(str2num(answer{6}));
Gabor.AllowedOri = [-45 0 45 90]; % 6 7 8 9

clear answer prompt definput

%% SCREEN, SOUND DRIVER & KEYBOARD INITIALISATION =======================
SetUpDisplay
SetUpSound

[KeyBoardIdx, productNames] = GetKeyboardIndices(); % idx 1 = external keyboard, idx 2 = Mac keyboard

if strcmp(Parameters.SetUp,'DisplayPlusPlus')
    ResponsePad = single(KeyBoardIdx(~contains(productNames,'Apple')));
elseif contains(productNames,'Apple Keyboard')
    ResponsePad = single(KeyBoardIdx(contains(productNames,'Apple Keyboard')));
else
    if length(KeyBoardIdx) >= 2 % External keyboard is connected
        disp('%%%%%%%%%%%%%%%% KEYBOARD OPTIONS: %%%%%%%%%%%%%%%%')
        disp(char(productNames))
        ExperimenterKeyboard = input('EXPERIMENTER KEYBOARD (c/p keyboard name)? ','s');
        TriggerKeyboard = input('TRIGGER KEYBOARD (c/p keyboard name)? ','s');
        ResponseKeyboard = input('RESPONSE KEYBOARD (c/p keyboard name)? ','s');
    else
        disp('%%%%%%%%%%%%%%%% KEYBOARD OPTIONS: %%%%%%%%%%%%%%%%')
        disp(char(productNames))
        ExperimenterKeyboard = input('EXPERIMENTER KEYBOARD (c/p keyboard name)? ','s');
        TriggerKeyboard = ExperimenterKeyboard;
        ResponseKeyboard = ExperimenterKeyboard;
    end
    ExperimenterPad = single(KeyBoardIdx(strcmp(productNames,ExperimenterKeyboard)));
    TriggerPad = single(KeyBoardIdx(strcmp(productNames,TriggerKeyboard)));
    ResponsePad = single(KeyBoardIdx(strcmp(productNames,ResponseKeyboard)));
end

escapeKey = KbName('q');
if length(KeyBoardIdx) < 2
    AllowedKey = {'6^','7&','8*','9('}; %5,6,7,8,9
else
    AllowedKey = {'7','8','9','4'}; % postive diagonal, horizontal, negative diagonal, vertical
end
minKey = min(str2double(AllowedKey));
SubsResp = minKey-1;
clear productNames

% Set random seed
rSeed = RandStream('mt19937ar','Seed','shuffle');
RandStream.setGlobalStream(rSeed); %To reproduce the same RandStream::: rSeed rSeed.NormalTransform = 'Ziggurat'; reset(rSeed,1757208590); RandStream.setGlobalStream(rSeed);
clear rSeed

%% Create a list of tested Gabor centres
% Define number of degree in pixel between 2 point centres
degdiff = round(6*Parameters.pixperdeg); 

% Define x-y positions for patch centres
rangex = [-18:6:18]*Parameters.pixperdeg;
rangey = rangex;

% Replicate each y coordinate for existing rangex values
ypos = []; 
for i = 1:length(rangey)
   ypos = [ypos, repmat(rangey(i),1,length(rangex))];
end

% Combine x-y coordinates for full range of testing locations
Gabor.x_ycoords = [repmat([rangex],1,length(rangey));ypos]; 
               
% Convert x-y positions to polar and eccentricity 
[Gabor.Polar,Gabor.ECC] = cart2pol(Gabor.x_ycoords(1,:),Gabor.x_ycoords(2,:)); % Polar = rad, ECC = pixel

% Get rid of the four corner positions
Gabor.x_ycoords(:,Gabor.ECC>ScreenRect(4)/2) = [];
Gabor.Polar(Gabor.ECC>ScreenRect(4)/2) = [];
Gabor.ECC(Gabor.ECC>ScreenRect(4)/2) = [];

fprintf('\nNUMBER OF POINTS TESTED: %s\n',num2str(size(Gabor.x_ycoords,2)))

% Set up filename for saving
TIMESTAMP = strrep(strrep(datestr(now),' ','_'),':','');
if Parameters.Practice == 1
    SaveName = sprintf('%s/Practice_%s_%s_Quest_%scpd_%s',FolderName,Parameters.Subj_ID,EyeTestedLabels{Parameters.Subj_EyeTested},num2str(Gabor.SFcpd),num2str(TIMESTAMP));
elseif Parameters.Practice == 0
    SaveName = sprintf('%s/%s_%s_Quest_%scpd_%s_R%s',FolderName,Parameters.Subj_ID,EyeTestedLabels{Parameters.Subj_EyeTested},num2str(Gabor.SFcpd),num2str(TIMESTAMP),num2str(Gabor.RunNumber));
end

%% GABOR PATCH INITIALISATION =============================================
Gabor_Initialisation
Stimulus = single(Stimulus);

%% SHUFFLE: SPATIAL FREQUENCY, ECCENTRICTY CENTRE, GAUSSIAN HULL ==========
Freq = Gabor.SFcpd; % Frequency(ies) to test
[Freq,idxFreq] = Shuffle(Freq);
[Gabor.SCShuffle,idxSCSize]= Shuffle(Gabor.sigmapx);

%% EYELINK PARAMETERS SET-UP & INITIALISATION =============================
if Parameters.EyeTrack
    
    elparam.expName      = '4AFC_CSF_Quest';            % experiment name.
    elparam.eyeMvt       = 1;                           % control eye movement,                             0 = NO   , 1 = YES
    elparam.TEST         = 0;                           % Dummy/test mode or not,                           0 = NO   , 1 = YES
    elparam.viewEL       = 0;                           % View eye position                                 0 = NO   , 1 = YES
    elparam.expStart     = 1;                           % Start of a recording exp                          0 = NO   , 1 = YES
    
    elparam.calibFlag    = 0;                           % Luminance gamma linearisation calibration         0 = NO   , 1 = YES
    elparam.calibType    = 2;                           % There are 2 types of gamma calibration            1 = Gray linearized;    2 = RGB linearized
    elparam.mkVideo      = 0;                           % Make a video of one trial                         0 = NO   , 1 = YES
    elparam.expTraining  = 0;                           % Training of the current experiment                0 = NO   , 1 = YES
    elparam.feedbackTask = 0;                           % Training of the current experiment                0 = NO   , 1 = YES
    elparam.EyeTest      = Parameters.EyeToTrack;       % Need to pass this to CheckEyePos (1 = LE, 2 = RE)
    
    if Parameters.Subj_Patient == 1
        elparam.CalTarRadVal   = Parameters.FixationSize_Deg;%VAToPix(sp.ViewDist, sp.PixelScale, elparam.CalTarRadDeg);
        elparam.CalTarWidthVal = 0.375; %VAToPix(sp.ViewDist, sp.PixelScale, elparam.CalTarWidthDeg);
    elseif Parameters.Subj_Patient == 0
        elparam.CalTarRadVal   = Parameters.FixationSize_Deg;%VAToPix(sp.ViewDist, sp.PixelScale, elparam.CalTarRadDeg);
        elparam.CalTarWidthVal = 0.25; %VAToPix(sp.ViewDist, sp.PixelScale, elparam.CalTarWidthDeg);
    end
    
    elparam.timeCalibMin = 10; %every 10 mins it will initialise re-calibration
    elparam.timeCalib    = elparam.timeCalibMin*60; %converts to secs (system requirement)
    elparam.timeFixSec   = 5; %maximum time allowed for non-fixation during trial (in seconds)
    
    if Parameters.Subj_Patient == 1
        elparam.FixRadDeg = 5;%2; %radius of the zone around fixation where we tolerate eye positions (degrees)
    elseif Parameters.Subj_Patient == 0
        elparam.FixRadDeg = 2;%2; %radius of the zone around fixation where we tolerate eye positions (degrees)
    end
    elparam.FixRadPix = elparam.FixRadDeg*Parameters.pixperdeg; %convert to pixels
    elparam.MaxInvTrials = 20; % maximum invalid trials allowed
    
    % Initialise Eyelink
    InitialiseEyeLink_2IFC;
    
else %no eye tracking - set up blank arrays
    el = [];
    elparam = [];
end

%% EXPERIMENT =========================================================
close all
try    
    %% EYE TRACKER CALIBRATION
    if Parameters.EyeTrack
        disp('.............. Calibration Time ..............')
        % First EyeLink Calibration
        eyeLinkClearScreen(0); %clear to grey screen
       
        % First calibration :
        if ~elparam.TEST
            eyeLinkClearScreen(0);
            eyeLinkDrawText(ScreenRect(3)/2,ScreenRect(4)/2,el.txtCol,'1st Calibration instruction');
            calibresult = EyelinkDoTrackerSetup(el); %what runs the calibration, eyelink command
            if calibresult==el.TERMINATE_KEY %checks whether you've pressed el.TERMINATE_KEY (key you pres to exit calibration)
                return
            end
        end
    end
    
    % Draw a blank screen
    pause(0.5); %just a brief pause to wait for the key press above to be cleared
    Screen('Flip', w);

    %% INITIALISE TIMING PARAMETERS
    timeStamp = [GetSecs 0];
    
    % Presentation timings
    if Parameters.Practice == 1
        Gabor.stimDuration_secs = single(1);
        Parameters.ISILim = single([0.5 1]); % Inter-Trial Stimulus interval in seconds
    elseif Parameters.Practice == 0
        Gabor.stimDuration_secs = single(0.5);
        Parameters.ISILim = single([0.3 0.5]); % Inter-Trial Stimulus interval in seconds
    end
    Gabor.stimDuration_Frame = single(Gabor.stimDuration_secs/ifi);  % Number of corresponding frames
    
    % Ramp vector generation
    Gabor.nFramesRamp = single(3);
    Gabor.stimDurationWithRamp_secs = single(Gabor.stimDuration_secs); % +(2*Gabor.nFramesRamp*ifi);
    Gabor.stimDurationWithRamp_Frame = single(Gabor.stimDurationWithRamp_secs/ifi);
    Gabor.RampVector = getSquaredCosineWindow(Parameters.FrameRate_hz, Gabor.stimDurationWithRamp_secs+0.1, ifi*Gabor.nFramesRamp);
    
    % Phase-reversing flipping generation
    Gabor.FlipReversalIndex = single([ones(1,Gabor.stimDurationWithRamp_Frame/2),repmat(2,1,Gabor.stimDurationWithRamp_Frame/2)]);
    Gabor.FlipReversalRate = single(1/Gabor.TF/size(Stimulus,5)); % in s: 1 cycle = 2 reversals (if there are 2 reversals)
    if Gabor.TF > 0
        Gabor.nFlips = Gabor.nFramesRamp:Gabor.FlipReversalRate*Parameters.FrameRate_hz:(Gabor.nFramesRamp+Gabor.stimDuration_secs*Parameters.FrameRate_hz);
        Gabor.nFlips(1) = 1;
    end
    
    % Define the stimulus texture at full contrast and centre of screen
    [gaborid,dstRect] = MakeGaborContrast(double(Stimulus),1,XYLoc_px_gabor,Parameters,w,ScreenRect,idxFreq,1,idxSCSize,1); %Gabor patch presentation
    
    clear i j
    
    %% QUEST INITIALISATION FOR EACH TESTED LOCATION
    questHandles = struct();
    tGuess = 0.5; % Initial guess for threshold (1%)
    tGuessSd = 0.2; % Standard deviation of guess (5%)
    gamma = 0.25; % Guess rate (1/4 for 4AFC)
    pThreshold = gamma^gamma; % Threshold performance level (~70.7%)
    beta = 3.5; % Slope of psychometric function
    lambda = 0.01; % Lapse rate (1%)
    minSd = 0.005; % Minimum standard deviation (0.5%)
    decayRate = 0.25; % Decay rate per run
    fprintf('\n============= INITIAL GUESS =============\n')

    if Gabor.RunNumber == 1

        for iLoc = 1:size(Gabor.x_ycoords,2) % For each tested location
            questHandles(iLoc).q = QuestCreate(tGuess,tGuessSd,pThreshold,beta,lambda,gamma);
        end

        % Display in command window
        fprintf('Threshold = %s�%s%%, Slope = %s\n\n', ...
            num2str(tGuess*100),num2str(tGuessSd*100),num2str(beta))
    else % Run > 1
        % Load the questHandles structure from previous runs
        pathname = uigetdir();
        d = dir(pathname); 
        filename = {d.name};
        idxFile = listdlg('PromptString','Select a file:',...
            'SelectionMode','multiple',...
            'ListString',filename);
        prevData = struct(); % Initialise previous data structure
        for run = 1:length(idxFile)
            PrevHandles = load([pathname filesep filename{idxFile(run)}],'questHandles','RawData','thresholds','slopes','ResponseProp','tGuessSd');
            % Retrive tested contrast levels from previous run
            for iLoc = 1:size(Gabor.x_ycoords,2) % For each tested location
                prevData(iLoc).Intensity(:,run) = PrevHandles.questHandles(iLoc).q.intensity(1:PrevHandles.questHandles(iLoc).q.trialCount);
                prevData(iLoc).Slopes(run) = PrevHandles.slopes(iLoc);
                prevData(iLoc).Thresholds(run) = PrevHandles.thresholds(iLoc);
                prevData(iLoc).ResponseProp(run) = PrevHandles.ResponseProp(iLoc);
                prevData(iLoc).tGuessSd(run) = PrevHandles.questHandles(iLoc).q.tGuessSd;
            end
        end

        for iLoc = 1:size(Gabor.x_ycoords,2) % For each tested location

            % Find the last run with proportion of response higher or equal
            % to performance threshold (pThreshold)
            idxRunToKeep = find([prevData(iLoc).ResponseProp] >= pThreshold*100);

            % If the previous run has more than 25% response correct,
            % the threshold and slope will be reduced. If
            % not, it will take the values from the last run with more than
            % 25% response correct. In the case of the first run being bad,
            % tGuess will be increased by 50% with a max tGuess of 100%
            % contrast.
            if ~isempty(idxRunToKeep)
                % Estimate standard deviation of thresholds and slope as
                % average of slopes from previous runs at this location
                % prevThresholdStd = std([prevData(iLoc).Thresholds]);
                if max(idxRunToKeep) == Gabor.RunNumber-1
                    tGuess = prevData(iLoc).Thresholds(end)*0.5; % Half the threshold from LAST run
                    beta = mean([prevData(iLoc).Slopes]); % mean of slopes from ALL PREVIOUS runs
                    tGuessSd = max(minSd, tGuess * decayRate); % Narrower threshold
                else
                    tGuess = prevData(iLoc).Thresholds(max(idxRunToKeep)); % From the last run with more or equal to 25% correct responses
                    beta = mean(prevData(iLoc).Slopes(min(idxRunToKeep):max(idxRunToKeep))); % From all previous runs with more or equal to 25% correct responses
                    tGuessSd = max(minSd, tGuess * decayRate/(Gabor.RunNumber-max(idxRunToKeep))); % Narrower threshold
                end
            else % This is for the case that the first run is bad (less than 25% correct response)
                % Increase the tGuess by 50%, keep the rest to default
                % (tGuessSd = 0.2, beta = 3.5)
                tGuess = min(tGuess * 1.5,1); % limited to 100% contrast
                tGuessStd = 0.2;
            end

            % Estimate 
            questHandles(iLoc).q = QuestCreate(tGuess,tGuessSd,pThreshold,beta,lambda,gamma);

            % Display in command window
            fprintf('Location: %s, Threshold = %s�%s%%, Slope = %s\n', ...
                num2str(iLoc), num2str(tGuess*100),num2str(tGuessSd*100),num2str(beta))
        end
    end
    
    numTrialsPerLocation = Gabor.nTrials;
    
    %% WELCOME SCREEN
    % Load the instruction image
    if length(KeyBoardIdx)  < 2
        instructionImage = imread('resources_SC/Instructions_single_keyboard.png');
    else 
        instructionImage = imread('resources_SC/Instructions.png');
    end

    clear KeyBoardIdx
    % Convert the image to a Psychtoolbox texture
    instructionTexture = Screen('MakeTexture', w, instructionImage);
    % Draw the instruction image
    Screen('DrawTexture', w, instructionTexture, [], ScreenRect, 0);
    % Flip to display the image
    Screen('Flip', w);

    % Figure: Tested position and achromatic Gabor at full 100% contrast (two phases)
    figure('Color','white','Position',[0 100 ScreenRect(3) ScreenRect(4)/2]);
    subplot(1,3,1); polarscatter(Gabor.Polar,Gabor.ECC,50,'filled'); set(gca,'LineWidth',2);
    for i = 2:3
        subplot(1,3,i); imagesc(squeeze(Stimulus(:,:,:,:,i-1))); axis square;
    end
    colormap gray;

    % Wait for a key press to continue
    pause(0.5);
    KbWait(); close all; clear Stimulus;
        
    %% Display all locations (tagged with X-Y coords) with an circle outline of 20deg radius
    Screen('TextSize', w, 16);   % set font size

    for i = 1:size(Gabor.x_ycoords,2)
        % Compute screen centered coordinates
        xpos = double(ScreenRect(3)/2 + Gabor.x_ycoords(1,i));
        ypos = double(ScreenRect(4)/2 + Gabor.x_ycoords(2,i));
        % Draw the Gabor
        Screen('DrawTexture', w, gaborid(1), [], ...
            double(CenterRectOnPoint([0 0 Gabor.Size_px Gabor.Size_px], xpos, ypos)), ...
            0, [], 0.8, [], [], []);
        % Add overlay text with x-y coordinates
        coordText = sprintf('(%.0f, %.0f)', Gabor.x_ycoords(1,i), Gabor.x_ycoords(2,i));
        DrawFormattedText(w, coordText, xpos-25, ypos, [0 0 0]);

    end
    % Circle outline of 20deg radius
    Screen('FrameOval', w, [0 0 0], ...
    double([ScreenRect(3)/2 - 20*Parameters.pixperdeg, ScreenRect(4)/2 - 20*Parameters.pixperdeg, ...
     ScreenRect(3)/2 + 20*Parameters.pixperdeg, ScreenRect(4)/2 + 20*Parameters.pixperdeg]),2);
    Screen('Flip', w);
    KbWait(); 
    clear xpos ypos coordText

    %% DECOUNT BEFORE STARTING THE MAIN TASK
    Screen('TextSize', w, 64);   % set font size
    DecountStart = 5;
    
    while DecountStart >=0
        text = sprintf('Starting in ...\n\n%s',num2str(DecountStart));
        DrawFormattedText(w, text, 'center', 'center', [0 0 0]);
        Screen('Flip', w);
        WaitSecs(1);
        DecountStart = DecountStart-1;
    end
    clear DecountStart     
    
    %% ACTUAL EXPERIMENT MODULE
    TrialCounter = 0;
    tmpData = single(NaN(size(Gabor.x_ycoords,2)*numTrialsPerLocation,7)); % Trial Number, X-Coord, Y-Coord, Contrast, Orientation, Response, isTrial
    ResponseFbk = {'Incorrect','Correct'};

    for trial = 1:numTrialsPerLocation
        %% TASK 
            % Randomize location
            locIdx = Shuffle(1:size(Gabor.x_ycoords,2));
        for i = locIdx
            %% Update parameters
            TrialCounter = TrialCounter + 1;
            
            % Randomize orientation
            oriIdx = randi(numel(Gabor.AllowedOri));
            targetOri = Gabor.AllowedOri(oriIdx);
            correctResponse = oriIdx;
            
            % Get contrast from QUEST for this location
            targContrast = QuestQuantile(questHandles(i).q);
            if targContrast > 1 % Cap it to 100% contrast
                targContrast = 1;
            end

            % Populate tmpData
            tmpData(TrialCounter,1:5) = [TrialCounter,Gabor.x_ycoords(1,i),Gabor.x_ycoords(2,i),targContrast,targetOri];
            
            %% ISI presentation
            if Parameters.EyeTrack
                Eyelink('message', 'ISI_START');
            end
            % Draw fixation point
            Screen('FillOval', w, [0.4 0.4 0.4], Parameters.FixationPos); 
            % Calculate ISI
            ISITime = Parameters.ISILim(1) + (Parameters.ISILim(2)-Parameters.ISILim(1)).*rand(1,1);
            % ISI timestamp
            timeStamp(end+1,1) = GetSecs;
            ISION = timeStamp(end,1);
            % Present ISI
            while ISION-timeStamp(end,1)< ISITime
                ISION = Screen('Flip', w,[],1);
            end
            if Parameters.EyeTrack
                Eyelink('message', 'ISI_END %d', TrialCounter-1);
                if Parameters.Practice
                    Eyelink('message', 'PRACTICE_TRIAL %d', TrialCounter);
                else
                    Eyelink('message', 'TRIAL_START %d', TrialCounter);
                    Eyelink('message', 'VALID_TRIAL %d', ValidTrialCounter);
                end
            end
            
            %% Stimulus presentation with phase flicker
            validTrial = 1; %assume the trial is valid to begin with
            fprintf('Trial: %s; Contrast: %s%% \n' ,num2str(TrialCounter), num2str(targContrast*100))
            
            % Gabor presentation ~ 500ms - Initialise
            CurrentFrame = 1; revs = 1;
            frm = 1;
            % Calculate when to flip
            FlipReversalTime = 0:Gabor.FlipReversalRate:Gabor.stimDurationWithRamp_secs;
            FlipReversalIndex = repmat([1,2],1,length(FlipReversalTime));
            
            timeStamp(end+1,1) = GetSecs;
            GratingOn = timeStamp(end,1);
            while GratingOn-timeStamp(end,1) <= Gabor.stimDurationWithRamp_secs
                % Check the closest FlipReversalTime in order to get the FlipReversalIndex
                [~,closestIndex] = min(abs(FlipReversalTime-(GratingOn-timeStamp(end,1))));
                
                % Draw fixation point only if not presented at centre
                Screen('FillOval', w, [0.4 0 0], Parameters.FixationPos);
                % Draw the Gabor
                Screen('DrawTexture', w, gaborid(FlipReversalIndex(closestIndex)), [], ...
                    double(CenterRectOnPoint([0 0 Gabor.Size_px Gabor.Size_px], ...
                    ScreenRect(3)/2 + Gabor.x_ycoords(1,i), ...
                    ScreenRect(4)/2 + Gabor.x_ycoords(2,i))), ...
                    0+targetOri, [], abs(targContrast), [], [], []);
                GratingOn = Screen('Flip', w);
                
                if Parameters.EyeTrack && validTrial
                    if frm==1
                        Eyelink('message', 'STIMULUS_START');
                    end
                    [x,y]=CheckEyePos(w,elparam); %gives estimate of eye position
                    [inside] = CheckFixRad(x,y,[ScreenRect(3)/2 ScreenRect(4)/2], elparam.FixRadPix);
                    if ~inside && validTrial
                        Eyelink('message', 'FIXATION_BREAK');
                        validTrial = 0;
                        NumInvalid = NumInvalid+1;
                        PsychPortAudio('FillBuffer', pahandle, double(EyeBeep));
                        PsychPortAudio('Start', pahandle);
                        PsychPortAudio('Stop', pahandle,1);
                        Screen('FillRect', w, [1,0,0], Parameters.FixationPos); %fixation point
                        Screen('Flip',w);
                        %             break;
                    end
                elseif Parameters.EyeTrack && ~validTrial
                    Screen('FillRect', w, [1,0,0], Parameters.FixationPos); %fixation point
                    Screen('Flip',w);
                end
                frm = frm+1;
            end
            
            if validTrial==1
                if Parameters.EyeTrack
                    Eyelink('message', 'TRIAL_END %d',TrialCounter);
                end
            else
                if Parameters.EyeTrack
                    Eyelink('message', 'TRIAL_END_BROKEN %d',TrialCounter);
                end
            end
            
            % If there are more than elparam.MaxInvTrials then you will
            % re-calibrate before the next trial
            if Parameters.EyeTrack
                if NumInvalid== elparam.MaxInvTrials
                    calibReq = 1;
                end
            end
            
            % Display fixation point
            Screen('FillOval', w, [0.6 0.6 0.6], Parameters.FixationPos);
            Screen('Flip', w);
            
            %% RESPONSE & QUEST UPDATE
            if validTrial==1
                if Parameters.EyeTrack
                    Eyelink('message', 'RESP_START');
                end
                % Get participant's response
                respTimeStart = GetSecs;
                timeStamp(end+1,1) = respTimeStart;
                keyIsDown = 0;
                while ~keyIsDown
                    [keyIsDown, secs, keyCode] = KbCheck(double(ResponsePad));
                    reply = KbName(keyCode);
                    if keyIsDown
                        if ismember(reply,AllowedKey)
                            switch reply
                                case AllowedKey{1}
                                    response = 1;
                                case AllowedKey{2}
                                    response = 2;
                                case AllowedKey{3}
                                    response = 3;
                                case AllowedKey{4}
                                    response = 4;
                            end
                            respTimeEnd = GetSecs;
                            break
                        else
                            keyIsDown = 0;
                        end
                    end
                end
                timeStamp(end+1,1) = respTimeEnd;
                respDuration(TrialCounter) = single(respTimeEnd - respTimeStart);
                
                % Participant's response in tmpData matrix
                tmpData(TrialCounter,6) = Gabor.AllowedOri(single(response));
                
                %% Check correctness and update QUEST
                isCorrect = (response == correctResponse);
                questHandles(i).q = QuestUpdate(questHandles(i).q,targContrast,isCorrect);
                
%                 % Give audio & visual feedbacks
%                 if isCorrect
%                     % Play sound for correct answer
%                     sound(yCorr,FsCorr);
%                 else
%                     % Play sound for wrong answer
%                     sound(yWrong,FsWrong);
%                 end
                
                % Display feedback for experimenter
                fprintf('Target Contrast: %s%%, Target Ori: %s�, Response: %s� (%ss) - %s\n\n', ...
                    num2str(targContrast*100),...
                    num2str(targetOri),...
                    num2str(tmpData(TrialCounter,6)),...
                    num2str(round(respDuration(TrialCounter)+0.5,3)), ResponseFbk{isCorrect+1});
            end
        end
    end
 
    %% THANK YOU SCREEN
    Screen('FillOval', w, [1 1 1], Parameters.FixationPos);
    Screen('Flip', w);
    WaitSecs(5);

    % End Message
    Screen('TextSize', w, 64);   % set font size
    text = sprintf('Thank you ... Run %s done!\n\n%s',num2str(Gabor.RunNumber));
    DrawFormattedText(w, text, 'center', 'center', [0 0 0]);
    Screen('Flip', w);

    %% FOR EACH LOCATION: ESTIMATE THRESHOLD, EXTRACT QUEST DATA & PLOT PSYCHOMETRIC FUNCTION ===============================
    pThreshold = gamma^gamma;
    thresholds = zeros(1,size(Gabor.x_ycoords,2)); % To store estimated contrast thresholds
    slopes = zeros(1,size(Gabor.x_ycoords,2)); % To store estimated contrast thresholds
    ResponseProp = zeros(1,size(Gabor.x_ycoords,2)); % To store proportions of correct responses
    contrasts = linspace(0,1,1000); % Range of contrast levels
    proportions = zeros(size(Gabor.x_ycoords,2),100); % To store predicted proportions for each location
    
    for iLoc = 1:size(Gabor.x_ycoords,2)
        % Percentage of Correct Response at each location
        ResponseProp(iLoc) = sum(questHandles(iLoc).q.response(1:Gabor.nTrials))/Gabor.nTrials*100;
        thresholds(iLoc) = QuestMean(questHandles(iLoc).q);
        slopes(iLoc) = QuestBetaAnalysis(questHandles(iLoc).q);

        % If the current run has more than 25% response correct,
        % the threshold and slope to plot will be for the current one. If
        % not, it will take the values from the last run with more than
        % 25% response correct.
        % Estimate standard deviation of thresholds and slope as
        % average of slopes from previous runs at this location
        % prevThresholdStd = std([prevData(iLoc).Thresholds]);
        if ResponseProp(iLoc) >= pThreshold*100
            thresholdsPlot(iLoc) = thresholds(iLoc);
            slopesPlot(iLoc) = slopes(iLoc);
        else
            if Gabor.RunNumber ~= 1
                % Find the last run with response > guessrate (25%)
                idxRunToKeep = find([prevData(iLoc).ResponseProp] >= pThreshold*100);

                % Get the slope and threshold from that run
                thresholdsPlot(iLoc) = prevData(iLoc).Thresholds(max(idxRunToKeep)); % From the last run with more or equal to 25% correct responses
                slopesPlot(iLoc) = prevData(iLoc).Slopes(max(idxRunToKeep)); % From all previous runs with more or equal to 25% correct responses
            else
                thresholdsPlot(iLoc) = thresholds(iLoc);
                slopesPlot(iLoc) = slopes(iLoc);
            end
        end

        % Weibull Psychometric Function
        for c = 1:length(contrasts)
            proportions(iLoc,c) = lambda*gamma+(1-lambda)*(1-(1-gamma)*exp(-10.^(slopesPlot(iLoc)*(contrasts(c)-thresholdsPlot(iLoc)))));
        end

        % Define the contrast needed for pThreshold performance
        [~, idx] = min(abs(proportions(iLoc,:) - pThreshold));
        contrastsPerf(iLoc) = contrasts(idx);
    end
    
    clc;
    for iLoc = 1:size(Gabor.x_ycoords,2)
        fprintf('Location %d: Estimated threshold at %.1f%% performance = %.1f%%, Slope = %.3f\n', ...
            iLoc, pThreshold*100, contrastsPerf(iLoc)*100,slopesPlot(iLoc)); % In percentage
    end
   
    %% PLOT DATA ========================================================
    close all;
    figure('Color','white','Position',[0 0 ScreenRect(3) ScreenRect(4)/2]); hold on;
    colors2 = parula(101);

    % Assign each location in Gabor.x_ycoords a color based on its distance
    % from the center, so colors change smoothly from center to periphery.
    distNorm = (Gabor.ECC - min(Gabor.ECC)) ./ (max(Gabor.ECC) - min(Gabor.ECC));
    cmap = turbo(256);
    colors = cmap( round(distNorm * 255) + 1 , : );

    for iLoc = 1:size(Gabor.x_ycoords,2)
        % Tested Locations
        subplot(2,3,1);
        hold on; scatter(Gabor.x_ycoords(1,iLoc),Gabor.x_ycoords(2,iLoc),200,...
            'filled','MarkerFaceColor',colors(iLoc,:),'MarkerEdgeColor','k');
        title('Tested Locations');
        axis([-ScreenRect(3)/2 ScreenRect(3)/2 -ScreenRect(4)/2 ScreenRect(4)/2 ]);
        set(gca,'FontSize',20,'LineWidth',2,'YDir','reverse')

        % Psychometric Function at each location
        subplot(2,3,2); hold on;
        plot(contrasts, proportions(iLoc,:), 'Color',colors(iLoc,:), 'LineWidth',2);
        plot(contrasts, ones(1,length(contrasts))*pThreshold,'k--','LineWidth',1);
        xlabel('Contrast'); ylabel({'Proportion','Correct'}); grid on; axis square;
        title({'Psychometric Functions','by Location'});
        axis([0 0.5 0 1])
        set(gca,'FontSize',20,'LineWidth',2)        
    end

    % Heat plot for % Correct Response
    subplot(2,3,3); hold on;
    scatter(Gabor.x_ycoords(1,:), Gabor.x_ycoords(2,:), 200, ResponseProp, ...
        'filled','MarkerEdgeColor','k');
    colormap(parula);colorbar; caxis([0 100]); ylabel(colorbar,'% Correct Response');
    title('% Correct Responses');
    axis([-ScreenRect(3)/2 ScreenRect(3)/2 -ScreenRect(4)/2 ScreenRect(4)/2 ]);
    set(gca,'FontSize',20,'LineWidth',2,'YDir','reverse')

    % Heat plot for Slopes
    subplot(2,3,4); hold on;
    scatter(Gabor.x_ycoords(1,:), Gabor.x_ycoords(2,:), 200, slopesPlot, ...
        'filled', 'MarkerEdgeColor','k');
    colormap(parula);colorbar; caxis([3 5]); ylabel(colorbar,'Slope');
    title('Slopes');
    axis([-ScreenRect(3)/2 ScreenRect(3)/2 -ScreenRect(4)/2 ScreenRect(4)/2 ]);
    set(gca,'FontSize',20,'LineWidth',2,'YDir','reverse')

    % Heat plot for Contrast Sensitivity = 1/Threshold (Smaller threshold =
    % higher sensitivity)
    subplot(2,3,5); hold on;
    scatter(Gabor.x_ycoords(1,:), Gabor.x_ycoords(2,:), 200, 1./contrastsPerf,...
        'filled', 'MarkerEdgeColor','k');
    colormap(parula);colorbar; caxis([floor(min(1./contrastsPerf)), ceil(max(1./contrastsPerf))]); 
    ylabel(colorbar,'CS = 1/Threshold');
    title(sprintf('Contrast Sensitivity at %.1f%%',pThreshold*100));
    axis([-ScreenRect(3)/2 ScreenRect(3)/2 -ScreenRect(4)/2 ScreenRect(4)/2 ]);
    set(gca,'FontSize',20,'LineWidth',2,'YDir','reverse')

    %% CLEAN UP AND DATA SAVING
    WaitSecs(5);
    
    disp('Writing RawData');
    RawData = struct('SF',[],'SC',[],'Run',[],'RespDuration',[]);
    RawData.SF = Freq;
    RawData.SC = Gabor.SpacialConstant_Deg(idxSCSize);
    RawData.Run = [RawData.Run; tmpData]; % X-coord, Y-coord, Contrast, Orientation, Response, isValid
    RawData.RespDuration = [RawData.RespDuration; respDuration];
        
    for i = 1:length(timeStamp)
        if i > 1
            timeStamp(i,2) =   timeStamp(i)-timeStamp(i-1);
        end
    end
    
    Priority(0);
    
    disp('Saving temporary mat file...')
    if Parameters.Practice
        SaveNameTmp = sprintf('%s/Practice_%s_%s_%s',FolderName,Parameters.Subj_ID,Parameters.Subj_ScanDate,'tmp');
    else
        SaveNameTmp = sprintf('%s/%s_%s_%s',FolderName,Parameters.Subj_ID,Parameters.Subj_ScanDate,'tmp');
    end
    save(SaveNameTmp);
    
catch ME
    rethrow(ME)
    Priority(0);
    Screen('CloseAll');
    Screen('LoadNormalizedGammaTable', Parameters.scrnNum, oldtable); % oldtable will be used in the end to restore the default gamma table
    PsychPortAudio('Close', pahandle);
end

%% Save data & Close screen
% Close screen
sca

time2 = clock;
Parameters.TimeTakenMins = etime(time2,time1)/60; %how much time taken in minutes for total trials
fprintf('Time spent: %s minutes\n',num2str(Parameters.TimeTakenMins,'%0.2f'))
% Restore original gamma & close PsychPortAudio
Screen('LoadNormalizedGammaTable', Parameters.scrnNum, oldtable); % oldtable will be used in the end to restore the default gamma table
PsychPortAudio('Close', pahandle);

fprintf('\n')

disp('Saving temporary mat file...')
if Parameters.Practice
    SaveNameTmp = sprintf('%s/Practice_%s_%s_%s',FolderName,Parameters.Subj_ID,Parameters.Subj_ScanDate,'tmp');
else
    SaveNameTmp = sprintf('%s/%s_%s_%s',FolderName,Parameters.Subj_ID,Parameters.Subj_ScanDate,'tmp');
end
save(SaveNameTmp);

%% Save output

% CSVSaveName = sprintf('%s/%s_%s.csv',FolderName,Parameters.Subj_ID,num2str(TIMESTAMP));
disp('Renaming workspace ...')
movefile([SaveNameTmp '.mat'],[SaveName '.mat']); % Rename the tmp save mat file

if Parameters.EyeTrack
    disp('Renaming EDF file ...')
    oldDir = sprintf('%s/%s_%s_%s.edf',FolderName,Parameters.Subj_ID,Parameters.Subj_ScanDate,'tmp');
    newDir = [SaveName '.edf'];
    movefile(oldDir,newDir);
end

disp('Done')
