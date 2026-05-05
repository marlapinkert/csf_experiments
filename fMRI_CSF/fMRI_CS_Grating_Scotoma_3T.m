%% Initialize randomness & keycodes
SetupRand;
SetupKeyCodes;

%% Calibrate the eye
dummymode = 0; % 0 = NO, 1 = YES

% If Calibration
if Parameters.CalibrateFirst
    FixationDots;
end

%% Set-up Gabor parameters and Make default grating structure

maxCPD = Parameters.PixelPerDg/4; % As 1 cycle = 1 black (2px) + 1 white (2px)
disp([newline 'Maximum vertical (top to bottom screen) dVA achievable = ' num2str(round(Parameters.HeightDg,1)) ' dVA' ...
    newline 'Number of cycles displayed (top to bottom screen): ' num2str(Parameters.SF*round(Parameters.HeightDg,1)) ' cycles' ...
    newline newline 'Highest number of cycles per degree achievable = ' num2str(floor(maxCPD)) ' cpd'])

Gabor = struct();

% Gabor Parameters
Gabor.Shape = StimulusShape{Parameters.Shape};
Gabor.SFcpd = Parameters.SF; % cycles per degree
Gabor.SFcpp = Gabor.SFcpd/Parameters.PixelPerDg; % in cycles degree per pixels
Gabor.SFRad = Parameters.SF*(pi/180); % cycles per radian
Gabor.SFRadperPixel = Gabor.SFRad/Parameters.PixelPerRad;%  in cycles per radian per pixels
Gabor.Orientation = Parameters.Orientation; % Only used if the grating is not circular
Gabor.Phase = 0;
Gabor.EccDegVA = 0; % Degrees of visual angle for the distance of gabor patch from the center (e.g., 6.5deg = [-6.5 6.5])
Gabor.EccPx = (Gabor.EccDegVA)./(Parameters.DgPerPixel); % Conversion of gabor patch distance to pixels

if Parameters.Scotoma
    Gabor.InnerRing_Deg = Parameters.RingCondition(1);
    Gabor.OuterRing_Deg = Parameters.RingCondition(2);
    Gabor.InnerRing_pix = Gabor.InnerRing_Deg*Parameters.PixelPerDg;
    Gabor.OuterRing_pix = Gabor.OuterRing_Deg*Parameters.PixelPerDg;
    DrawInnerRing_Pix = [Rect(3)/2-Gabor.InnerRing_pix Rect(4)/2-Gabor.InnerRing_pix Rect(3)/2+Gabor.InnerRing_pix Rect(4)/2+Gabor.InnerRing_pix];
    DrawOuterRing_Pix = [Rect(3)/2-Gabor.OuterRing_pix Rect(4)/2-Gabor.OuterRing_pix Rect(3)/2+Gabor.OuterRing_pix Rect(4)/2+Gabor.OuterRing_pix];
end

% Create the mesh grid (black/white)
height = Rect(4);  % Height of the screen (not the width as width > height)
fringe = 0;  % Width of the ramped fringe
height = height - fringe;
WidthArray=[-height/2:-1 1:height/2];
[Gabor.x,Gabor.y] = meshgrid(WidthArray, WidthArray);

% SD of Gaussian Hull:
% Space constant (sigma of Gaussian envelope) = the point at which the magnitude of the function
% falls to 1/e, or approximately 36.8%, of the peak
if isnan(Parameters.SDGaussianHull)
    Gabor.sigmadeg = Parameters.WidthDg+500; % Spatial constant takes whole screen
else
    Gabor.sigmadeg = Parameters.SDGaussianHull;
end
Gabor.sigmapx = Gabor.sigmadeg*Parameters.WidthPx/Parameters.WidthDg; % 2.53deg in pixel;
disp(['SD of Gaussian hull:' num2str(Gabor.sigmadeg) 'deg'])

% Define which type of grating (circular/concentric or stripped pattern)
% Creates variable "Stimulus"
if Parameters.Shape ~= 1
    NonCircularGrating()
else
    CircularGrating()
end

%% TASK 1: Define the contrast threshold (Threshold) and the contrasts that will be used in the fMRI task
TIMESTAMP = strrep(strrep(datestr(now),' ','_'),':','_');
SaveName = sprintf('%s/%s_%s',FolderName,Parameters.Session_name, num2str(TIMESTAMP));

if Parameters.Run == 1 && Parameters.SkipThreshold == 0
    while 1
        filename = fullfile(FolderName,...
            [Parameters.Subj_ID '_SF' num2str(Parameters.SF) '_TF' num2str(Parameters.TF) '_Session' num2str(Parameters.Subj_Session) '_ThresholdContrast.mat']);
        
        TaskContrastThreshold()
        % Save output of interest: Threshold
        save(filename,'Threshold')
        
        answer = questdlg('Do you want to run the threshold step again?', ...
            'Accept Threshold', ...
            'Yes', 'No', 'Yes');
        % Handle response
        switch answer
            case 'Yes'
                
            case 'No'
                break
        end
    end
elseif Parameters.Run ~= 1 && Parameters.SkipThreshold == 0
    filename = fullfile('../../BehaviourData',Parameters.Subj_ID,'CSF',...
        [Parameters.Subj_ID '_SF' num2str(Parameters.SF) '_TF' num2str(Parameters.TF) '_Session' num2str(1) '_ThresholdContrast.mat']);
    
    load(filename)
elseif Parameters.SkipThreshold == 1
    Threshold = NaN;
end
Gabor.Threshold = Threshold;

%% Define the contrasts for the fMRI task based on the threshold
%%%% V1: Contrast levels determined based on threshold
% Gabor.Contrast = round([1/2*Threshold, 3/4*Threshold, ... % 2 contrast level below threshold
%     Threshold, ...
%     (Threshold+(1-Threshold)*0.005), (Threshold+(1-Threshold)*0.01), ... % 2 contrast level above threshold (very close)
%     (Threshold+(1-Threshold)*0.05), (Threshold+(1-Threshold)*0.1)],3); % 1 contrast level above threshold (further away)
if Parameters.C_Config == 1
    %%%% V2: Log10 spaced normalised contrast levels between 0.1% and 100%:
    Gabor.Contrast = round([logspace(log10(0.1),log10(100),9)]/100,3);
    %%%% V3: Replace 100% by 80% :
    Gabor.Contrast(end) = 0.8;
elseif Parameters.C_Config == 2
    %%%% V5: Same as V3 with added contrast levels
    Gabor.Contrast = [0.1,0.2,0.6,1.3,3.2,7.5,17.8,42.2,60,80,100]/100;
elseif Parameters.C_Config == 3
    %%%% V5: Reduce the number of contrast levels
    Gabor.Contrast = [3.2,7.5,17.8,42.2,60,80,100]/100;
    %     Gabor.Contrast = [17.8,42.2,60,80,100]/100; % Patient
end

% n values of MC corresponding to n levels of contrasts
colStim = nan(length(Gabor.Contrast),size(Stimulus,1),size(Stimulus,1),3,2);
% NContrast x Rect(4) x Rect(4) x RGB(3) x Nreversal(2)

for c = 1:length(Gabor.Contrast)
    MC = Gabor.Contrast(c);
    % Define the theoretical color values at a certain level of Michelson
    % Contrast (on a nornalised scale of 0-1, with 1 = 255)
    chosenCols = MichelsonContrast(MC, white, black, grey,[]);
    Gabor.WhiteStripes(c,:) = chosenCols(1,:);
    Gabor.BlackStripes(c,:) = chosenCols(2,:);
    
    % Replace colors by desired colors (chosenCols)
    for i = 1:length(Parameters.Background) % RGB
        for j = 1:size(Stimulus,3) % Contrast Reversals
            tmp = Stimulus(:,:,j);
            
            % Define which pixels tend towards white or black, or corresponds
            % to the background.
            pix1 = tmp(:,:) > Parameters.Background(i);
            pix2 = tmp(:,:) < Parameters.Background(i);
            pix3 = tmp(:,:) == Parameters.Background(i);
            
            % Contrast modulation: contrast is defined as amount of grey to
            % modulate the initial pixel colors with. For instance, if contrast =
            % 50%, we need to inject 50% of grey). This is done by computing
            % the difference between the pixel color value and the grey value,
            % and multiplying the difference by the amount of grey to inject.
            tmp(pix1) = Parameters.Background(i) + (tmp(pix1)-grey)*MC; % for pixels going towards white
            tmp(pix2) = Parameters.Background(i) + (tmp(pix2)-grey)*MC; % for pixels going towards black
            tmp(pix3) = Parameters.Background(i);
            
            % At high SF, there is a very noticeable interference between
            % the grating pattern and the colour of the spiderweb overlayed
            % on top of it. The following sets the pixels on the middle
            % line  to the same colours as the spiderweb.
            %             tmp(size(tmp,1)/2,:) = Parameters.Spider_Web;
            
            colStim(c,:,:,i,j) = tmp;
        end
    end
end
Gabor.Stimulus = colStim;

MC = []; % Reset MC for later

figure('Position',[0 0 Rect(3) Rect(4)/3.5]);
set(gcf,'Color',[1 1 1])
colormap(gray);
lines = size(Gabor.Stimulus,5);
column = size(Gabor.Stimulus,1);
idx = column;
for i = 1:column
    subplot(lines,column,i);
    imagesc(squeeze(Gabor.Stimulus(i,:,:,:,1)));
    title([num2str(Gabor.Contrast(i)*100) '% - Configuration 1'])
    idx = idx+1;
    subplot(lines,column,idx);
    imagesc(squeeze(Gabor.Stimulus(i,:,:,:,2)));
    title([num2str(Gabor.Contrast(i)*100) '% - Configuration 2'])
end
if Parameters.Run == 1
    NamePlot = sprintf('%s/%s_%s_%s',FolderName,Parameters.Session_name, num2str(TIMESTAMP),'Stimulus_Contrast');
    saveas(gcf,NamePlot,'png')
end

%% Building the run structure (RunStructure & Visible)
% TOTAL/RUN (for 5 contrast levels): 473 volumes (TR = 1s) ~ 7min49s.
% 1) 20s of mid-grey backgroung
% 2) 13s ON/3s OFF
% 3) 1/5 of trials = baseline
% 4) Ends with 20s of mid-grey background

% Patients: Stimulus is presented monocularly.
% If 3 runs per eye -> total both eyes: 2814s ~ 57min.
% If 4 runs per eye -> total both eyes: 3752s ~ 63min.
% Then also need MPRAGE (~6min) + Alignment scan (~2min)
% Functional session: ~1h10-1h15 in total

Parameters.BlankVolumes = 20; % Number of blank volumes to start or end the run with
Parameters.Block_per_Run = 3;  % Number of blocks per runs
Parameters.SubBlock_per_Block = [length(Gabor.Contrast) length(Gabor.Contrast)];  % N*Grating, N*GreyBackground
if Parameters.P_Config == 2 || Parameters.P_Config == 3
    [Q,R] = quorem(sym(length(Gabor.Contrast)),sym(Parameters.Block_per_Run));
    if R > 0
        NbaselinePerSubblock = double(Q+1);
    else
       NbaselinePerSubblock = double(Q); 
    end
end

if Parameters.P_Config == 1
    NtotSubblock = Parameters.SubBlock_per_Block(1)+Parameters.SubBlock_per_Block(2)+1; %(+1 is for 13s additional grey between blocks)
    Parameters.ContrastDuration = [13 13]; % 13s of the same contrast condition = 13 Volumes
else
    if Parameters.P_Config == 2
        NtotSubblock = Parameters.SubBlock_per_Block(1)+NbaselinePerSubblock; % N subblock/block = N*16s+N*basline
        Parameters.ContrastDuration = [13 2 15]; % 13s of the same contrast condition = 13 Volumes
    elseif Parameters.P_Config == 3
        NtotSubblock = Parameters.SubBlock_per_Block(1)+Parameters.SubBlock_per_Block(2)+NbaselinePerSubblock; % N subblock/block = N*13s+N*3s+N*basline
        Parameters.ContrastDuration = [12:14 1:3 15]; % 13s of the same contrast condition = 13 Volumes
    end
end

% % Ramp vector generation
% Parameters.nFramesRamp = 3;
% stimDuration_secs = Parameters.ContrastDuration+(2*Parameters.nFramesRamp)/Parameters.ScreenFrameRate;
% Parameters.RampVector = getSquaredCosineWindow(Parameters.ScreenFrameRate, stimDuration_secs, Parameters.nFramesRamp/Parameters.ScreenFrameRate);

BlockStructure = NaN(Parameters.Block_per_Run,NtotSubblock); % Define Block Structure
RunStructure = [];
RunStructure = zeros(Parameters.BlankVolumes,1); % Starts with 20s Trigger

if Parameters.P_Config == 1 || Parameters.P_Config == 3
    for block = 1:Parameters.Block_per_Run % For each block (each line)
        
        % Initial configuration: 13s/13s ON/OFF
        if Parameters.P_Config == 1
            order = randperm(Parameters.SubBlock_per_Block(1)); % Random order for contrast levels
            
            idx = 1;
            for i = 1:2:length(BlockStructure(block,:))-1 % Skips even subblock number (i.e., grey background)
                BlockStructure(block,i) = order(idx);
                idx = idx+1;
            end
            
            if block > 1 % If it is not the first block
                % Find if last condition (i.e., sub-block) from the previous block is repeated as the
                % first one for the following block
                diffblock = BlockStructure(block-1,end-1)-BlockStructure(block,1);
                
                % Find if two consecutive blocks (i.e., lines) are the same
                repblock = BlockStructure(block-1,:)-BlockStructure(block,:);
                
                % Avoid having the last condition from the previous block being repeated as the first one in
                % the following block, or that two consecutive blocks (i.e., lines) are the same, or
                % having two consecutive grey conditions or the first condition of
                % the new block to be a grey condition
                while find(diffblock == 0 | all(repblock == 0))
                    order = randperm(Parameters.SubBlock_per_Block(1)); % Random order for contrast levels
                    
                    idx = 1;
                    for i = 1:2:length(BlockStructure(block,:))
                        BlockStructure(block,i) = order(idx);
                        idx = idx+1;
                    end
                    diffblock = BlockStructure(block-1,end)-BlockStructure(block,1);
                    repblock = BlockStructure(block-1,:)-BlockStructure(block,:);
                end
                
            end
            for subblock = 1:length(BlockStructure(block,:))
                % Replicate the contrast condition (subblock) value 13 times (i.e.,
                % 13 volumes = 13s)
                RunStructure = [RunStructure; repmat(BlockStructure(block,subblock),Parameters.ContrastDuration(1),1)];
            end
            
            % Full Randomisation
        elseif Parameters.P_Config == 3
            [Labels,order] = Shuffle([Gabor.Contrast,NaN(1,NbaselinePerSubblock)]);
            while isnan(Labels(1))
                [Labels,order] = Shuffle([Gabor.Contrast,NaN(1,NbaselinePerSubblock)]);
            end
            order(isnan(Labels)) = NaN;
            
            idx = 0;
            for i = 1:length(order) % Skips even subblock number (i.e., grey background)
                idx = idx+1;
                if ~isnan(order(i))
                    BlockStructure(block,idx) = order(i);
                    idx = idx+1;
                    BlockStructure(block,idx) = 0;
                end
            end
            
            for subblock = 1:length(BlockStructure(block,:))
                % Replicate the contrast condition (subblock) value 13 times (i.e.,
                % 13 volumes = 13s)
                if BlockStructure(block,subblock) > 0
                    RunStructure = [RunStructure; repmat(BlockStructure(block,subblock),datasample(Parameters.ContrastDuration(1:3),1),1)];
                elseif BlockStructure(block,subblock) == 0
                    RunStructure = [RunStructure; repmat(BlockStructure(block,subblock),datasample(Parameters.ContrastDuration(4:6),1),1)];
                elseif isnan(BlockStructure(block,subblock))
                    RunStructure = [RunStructure; repmat(0,datasample(Parameters.ContrastDuration(end),1),1)];
                end
            end
        end
    end
elseif Parameters.P_Config == 2
    Sequences = []; SequenceChoice = [];
    Sequences = [5,4,1,5,0,2,3,7,6,2,7,3,0,5,6,0,4,0,6,7,0,1,0,2,0,1,3,4;...
        3,0,1,0,7,3,1,5,7,0,2,6,2,0,4,5,0,6,0,4,2,6,5,4,0,1,3,7;...
        2,7,3,5,0,1,0,1,5,6,2,0,6,0,4,0,3,0,4,7,0,1,7,6,5,2,3,4]';
    SequenceChoice = Sequences(:,Parameters.Seq_Choice);
    
    BlockStructure = SequenceChoice';
    
    for subblock = 1:length(SequenceChoice)
        if SequenceChoice(subblock) > 0
            RunStructure = [RunStructure; repmat(SequenceChoice(subblock),datasample(Parameters.ContrastDuration(1),1),1)];
            RunStructure = [RunStructure; repmat(0,datasample(Parameters.ContrastDuration(2),1),1)];
        elseif SequenceChoice(subblock) == 0
            RunStructure = [RunStructure; repmat(SequenceChoice(subblock),datasample(Parameters.ContrastDuration(3),1),1)];
        end
    end
end

% Configuration 2: 13s+3s stimulus + Semi-Random baseline position

% Add zero padding at the end (finishes with 20s baseline)
if Parameters.P_Config == 1
    RunStructure(isnan(RunStructure)) = 0; % fill up the remaining NaN that corresponds to "pure" baseline trials
end
RunStructure = [RunStructure; zeros(Parameters.BlankVolumes,1)]; % Structure for the trial (Finishes with 20s blank)

% Define Gabor orientation structure for all volumes
OriStructure = zeros(length(RunStructure),1);
if Parameters.ChangeGaborOri
    for i = find(mod(1:length(RunStructure),5)==0)
        OriStructure(i) = datasample([-45,0,45,90],1);
        while OriStructure(i-1) == OriStructure(i)
            OriStructure(i) = datasample([-45,0,45,90],1);
        end
        OriStructure(i:i+5) = OriStructure(i);
    end
end

NumSeqVols = length(RunStructure); % Should be equal to the number of task trials + 20 triggers + 20 blank end

disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')
disp(BlockStructure) % Displays the BlockStrucutre in the command window
disp('Presented contrast levels:')
disp(Gabor.Contrast'*100) % Displays the different contrast levels in the command window
disp('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%')

% Indexing when the task is on or off.
% Main structure = 20 volumes of mid-grey background, 3 blocks of N
% contrast levels (13s ON + 13s OFF - depend on number of contrast levels),
% additional 13s of mid-grey after each block, 20 volumes of mid-grey
% background.
Visible = RunStructure;
Visible(RunStructure>0) = 1;

%% Intialise Stimulus Display parameters
% Get the size stimulus in screen coords
StimRect = [0 0 repmat(size(Gabor.Stimulus,2), 1, 2)];

% Load Mask Aperture Texture
CircAperture = Screen('MakeTexture', Win, grey* ones(Rect([4 3])),[],[],2);

% Set Spiderweb Coordinates
% Stripes
Ix = []; Iy = []; Ox = []; Oy = [];
[Ix, Iy] = pol2cart([45:90:315]/180*pi, Parameters.Fixation_Width(2)./2);
[Ox, Oy] = pol2cart([45:90:315]/180*pi, Rect(3)/2);
% If we want the full 6-lines ([0:45:315]): Because the horizontal line of
% the spiderweb interacts with the stimulus at high SF -> Remove the
% horizontal line.
% Ix([1 5]) = [];Iy([1 5]) = [];
% Ox([1 5]) = [];Oy([1 5]) = [];

Rc = Rect(3) - 0;
Sc = round(Rc / 4);
Wc = 0 : Sc : Rect(3);
Wa = Parameters.Spider_Web;

% Define how fast the reversal flip is happening (Explanation for logic)
% 1 reversal flip = 1 alternation of configuration 1: B-W + configuration 2: W-B = 1 cycle
% If SF = 1cpd, and TF = 1Hz (cycles/s)
% If Velocity = TF/SF = 1 deg/s, this equals Velocity = 1 reversal flip per second <=> 1 reversal = 1/2 seconds
% If TF = 2Hz and SF = 1cpd => Velocity = 2deg/s = 2 reversal flips per second, meaning that 1 configuration = 250ms.
% If SF increases, velocity will decrease.
Velocity = Parameters.TF/Parameters.SF;
Parameters.Reversal = 2*Parameters.TF;
Parameters.SecsPerReversal = 1/Parameters.Reversal;

%% Initialise saved aperture file
if Parameters.SaveAps
    ApFrm = zeros(size(Gabor.Stimulus,2), size(Gabor.Stimulus,3), length(Visible));
end

%% Set Up Volume Parameters
CurrVoltime = nan(length(Visible),1); % keeps track of when new stimulus is presented (changes per TR/volume)
CurrVolume = 1 ; %current volume
PrevVolume = 0;
ReversalVoltime = nan;
ReversalFrame = 1; %current frame within a contrast reversal cycle of size Parameters.SecsPerReversal
CurrReversal = 1; %current contrast reversal stim

%% Initialise Behavioural data
% Event timings: randomly defining when each event will be presented and saves in into an Event variable
Events = [];
for e = Parameters.TR : Parameters.Event_Duration : length(Visible)
    if rand < Parameters.Prob_of_Event
        Events = [Events; e];
    end
end
% Add a dummy event at the end of the Universe
Events = [Events; Inf];

Behaviour = struct;
Behaviour.EventTime = Events;
Behaviour.Response = [];
Behaviour.ResponseTime = [];
Behaviour.hits = [];
Behaviour.false_alarms = [];

%% Start experiment
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%% start experiment %%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Initialise eye tracker
if Parameters.Eye_tracker
    
    dummymode = 0;
    elparam.edffilename = 'Test.edf';
    if Eyelink('Initialize') ~= 0
        error('Problem initialising the eyetracker!');
    end
    Eye_params = EyelinkInitDefaults(Win);
    
    % Set parser
    % Sets up columns of eyelink file
    Eyelink('command', 'file_event_filter = LEFT,RIGHT,FIXATION,SACCADE,BLINK,MESSAGE,BUTTON');
    Eyelink('command', 'file_sample_data = LEFT,RIGHT,GAZE,AREA');
    Eyelink('command', 'link_event_filter = LEFT,RIGHT,FIXATION,SACCADE,BLINK,MESSAGE,BUTTON');
    Eyelink('command', 'link_sample_data  = LEFT,RIGHT,GAZE,AREA');
    
    Eyelink('command', 'heuristic_filter = 1 1');
    
    % Set pupil Tracking model in camera setup screen  (no = centroid. yes = ellipse)
    Eyelink('command', 'use_ellipse_fitter =  NO');
    
    % set sample rate in camera setup screen
    Eyelink('command', 'sample_rate = %d',1000);
    
    % Experiment descriptions into the edf-file :
    Eyelink('message', 'START OF DESCRIPTIONS');
    %Eyelink('message', '%s', fName);
    Eyelink('message', '** fMRI Contrast Sensitivity **');
    Eyelink('message', 'END OF DESCRIPTIONS');
    
    if ~EyelinkInit(dummymode)
        fprintf('Eyelink Init aborted.\n');
        cleanup;  % cleanup function
        return;
    end
    
    Eyelink('Openfile', elparam.edffilename);  % Open a file on the eyetracker
    Eyelink('StartRecording');  % Start recording to the file
    Eye_error = Eyelink('CheckRecording');
    if Eyelink('NewFloatSampleAvailable') > 0
        Eye_used = Eyelink('EyeAvailable'); % Get eye that's tracked
        if Eye_used == Eye_params.BINOCULAR
            % If both eyes are tracked use right
            Eye_used = Eye_params.RIGHT_EYE;
        end
    end
    
    % make sure we're still connected.
    if Eyelink('IsConnected')~=1 && dummymode == 0
        fprintf('not connected, clean up\n');
        Eyelink( 'Shutdown');
        Screen('CloseAll');
        return;
    end
    
    % Clear tracker display
    Eyelink('Command', 'clear_screen %d', 0);
    WaitSecs(0.1);
    % Display Fixation area on EyeLink computer
    Eyelink('command', 'draw_box %d %d %d %d 15', Rect(3)/2-round(Parameters.Fixation_Width(1)), Rect(4)/2-round(Parameters.Fixation_Width(1)), Rect(3)/2+round(Parameters.Fixation_Width(1)), Rect(4)/2+round(Parameters.Fixation_Width(1)));
end

%% Standby screen
% Displayed texts parameters
% Welcome message (Story: Space-Ship and zapped into different universe, with different ones according to points)
Parameters.Welcome = 'Welcome to Zip-Zap game!\n';
Parameters.Instruction2 = 'Keep fixating the central\ndot at all time!!! \n\nPress a button as soon \n as the central dot \n changes color.';  % Instruction for standard dimming task

Screen('TextFont', Win, Parameters.FontName);
Screen('TextSize', Win, Parameters.FontSize);
Screen('FillRect', Win, Parameters.Background, Rect);
DrawFormattedText(Win, [Parameters.Welcome '\n' Parameters.Instruction2 '\n' ], 'center', 'center', Parameters.Text,Parameters.FontSize);
Screen('Flip', Win);

% Display condition parameters in command window
if Parameters.Scotoma
    disp([ newline StimulusShape{Parameters.Shape} ' Grating: ' ...
        'SF = ' num2str(Parameters.SF) 'cpd'...
        ', TF = ' num2str(Parameters.TF) 'Hz'...
        ', Orientation = ' num2str(Parameters.Orientation) 'deg' ...
        ', Scotoma Simulated: ' num2str(Parameters.RingCondition(1)) '-'  num2str(Parameters.RingCondition(2)) 'deg'])
else
    disp([ newline StimulusShape{Parameters.Shape} ' Grating: ' ...
        'SF = ' num2str(Parameters.SF) 'cpd'...
        ', TF = ' num2str(Parameters.TF) 'Hz'...
        ', Orientation = ' num2str(Parameters.Orientation) 'deg'])
end
commandwindow;

%% wait for scanner
fprintf('Number of volumes to acquire (incl. %d dummies): %d volumes\n',(Parameters.StartTrig-1),length(Visible)+(Parameters.StartTrig-1))

if Emulate
    WaitSecs(0.1);
    pause();
    %KbWait();
    [bkp, ~, bk] = KbCheck;
else
    %%% CHANGE THIS TO WHATEVER CODE YOU USE TO TRIGGER YOUR SCRIPT!!! %%%
    %     Parameters.StartTrig = 5; % Will start the experiment at 5th pulse
    waitforpulses_3T(Parameters.StartTrig,TriggerKeyboard) % It will start the experiment at the StartTrig pulse (e.g., if StartTrig = 5, then start at 5th pulse)
end

% Eye Tracker and Behavioural data: Start Experiment tag
k = 0;
% Added - 13/12/2022 - Changed from KbCheck (KeyTime -> KeyTimetmp)
KbQueueCreate(Parameters.KeyBoardIdx(strcmp(Parameters.productnames,ResponseKeyboard)))
KbQueueStart(Parameters.KeyBoardIdx(strcmp(Parameters.productnames,ResponseKeyboard)))

if Parameters.Eye_tracker
    Eyelink('Message', 'STARTEXP'); % zero-time
end

Behaviour.TrialOnset = GetSecs;
Behaviour.TrialOffset = NaN;
% EyeTracker data will be stored in EyeTrack structure
EyeTracker.Eye = [];

% Main experiment
% 20 dummy volumes, 156x3 (468) volumes of task (13s contrast on/ 13s contrast off), 20 dummy volumes (as defined in Visible variable)
Start_of_Expmt = Screen('Flip', Win);

tic
while CurrVolume <= length(Visible)
    if Parameters.Eye_tracker
        Eyelink('Message', ['VOLUME ' num2str(CurrVolume)]);
    end
    
    % Checkerboard Reversal if the current frame is more than the defined
    % changing frame for the checkerboard reversal (e.g., more than 0.125ms)
    if Parameters.TF > 0
        if round(GetSecs-Start_of_Expmt,3) > ReversalFrame*Parameters.SecsPerReversal
            ReversalFrame = ReversalFrame+1;
            CurrReversal = CurrReversal + 1; % Change the Checkerboard Reversal defined by the last dimension of stimulus
        end
        if CurrReversal > size(Gabor.Stimulus, length(size(Gabor.Stimulus))) % last dimension of stimulus = reversal configuration
            CurrReversal = 1; % Re-initialise the checkerboard reversal count
        end
    else
        CurrReversal = 1;
    end
    
    if Visible(CurrVolume) % If we are in the non-blank periods of the experiment structure
        % Retrieving current stimulus color parameters from the
        % Gabor.Stimulus variable defined few steps above
        MC = Gabor.Contrast(RunStructure(CurrVolume));
        if PrevVolume ~= CurrVolume
            toc
            disp(['Volume ' num2str(CurrVolume) ', Contrast: ' num2str(MC*100) '%'])
            tic
        end
        CurrentStimulus = squeeze(Gabor.Stimulus(RunStructure(CurrVolume),:,:,:,:));
        
        % Load Stimulus Condition Texture (Reversal configuration)
        StimCondTex = Screen('MakeTexture', Win, CurrentStimulus(:,:,:,CurrReversal),[],[],2);
        if Parameters.Shape ~= 1 % Stripped
            % Draw Stimulus
            Screen('DrawTexture', Win, StimCondTex, StimRect, CenterRect([0 0 Rect(4) Rect(4)], Rect),OriStructure(CurrVolume)+Parameters.Orientation,[],[],[],[]);
        elseif Parameters.Shape == 1 % Concentric/Circular
            % Draw Stimulus
            Screen('DrawTexture', Win, StimCondTex, StimRect, CenterRect([0 0 Rect(4) Rect(4)], Rect));
        end
    else % Dummy Volumes (20s before and after the task)
        if PrevVolume ~= CurrVolume
            toc
            disp(['Volume ' num2str(CurrVolume) ', Grey Background'])
            tic
        end
    end
    
    % Draw spiderweb spokes
    for s = 1:length(Ix)
        Screen('DrawLines', Win, [[Ix(1,s);Iy(1,s)] [Ox(1,s);Oy(1,s)]], 1, [0 0 0 Wa], Rect(3:4)/2);
    end
    
    % Add a smooth oval across the fixation
    if Parameters.FixationOval
        SmoothOval(Win, Parameters.Background, CenterRect([0 0 Parameters.Fixation_Width(2) Parameters.Fixation_Width(2)], Rect), Parameters.Fringe);
    end
    
    % Draw fixation depending on event or not
    CurrEvents = (GetSecs - Start_of_Expmt) - Events;
    if sum(CurrEvents > 0 & CurrEvents < Parameters.Event_Duration)
        % This is an event
        Screen('FillOval', Win, Parameters.Event_Color, CenterRect([0 0 Parameters.Fixation_Width(1) Parameters.Fixation_Width(1)], Rect));
    else
        % This is not an event
        Screen('FillOval', Win, Parameters.Fixation_Color, CenterRect([0 0 Parameters.Fixation_Width(1) Parameters.Fixation_Width(1)], Rect));
    end
    
    % Check whether the refractory period of key press has passed
    if k ~= 0 && GetSecs-KeyTime(1) >= 2*Parameters.Event_Duration
        k = 0;
    end
    
    % Display the stimulus
    tt = Screen('Flip',Win);
    
    % Get volume onset timing parameters
    if PrevVolume ~= CurrVolume
        CurrVoltime(CurrVolume) = tt-Start_of_Expmt;
        ReversalVoltime = tt;
    end
    PrevVolume = CurrVolume;
    
    % Check for Behavioural response
    if k == 0
        % Added - 13/12/2022 - Changed from KbCheck (KeyTime -> KeyTimetmp)
        [Keypr, KeyTime, Key] = KbQueueCheck(Parameters.KeyBoardIdx(strcmp(Parameters.productnames,ResponseKeyboard)));
        if Keypr
            k = 1;
            random_key = KbName(KeyTime);
            KeyTime = KeyTime(find(KeyTime));
            Behaviour.Response = [Behaviour.Response; str2double(random_key(1))];
            Behaviour.ResponseTime = [Behaviour.ResponseTime; KeyTime(1) - Start_of_Expmt];
        end
    end
    
    % Record eye data
    if Parameters.Eye_tracker
        if Eyelink( 'NewFloatSampleAvailable') > 0
            Eye = Eyelink('NewestFloatSample');
            ex = Eye.gx(Eye_used+1);
            ey = Eye.gy(Eye_used+1);
            ep = Eye.pa(Eye_used+1);
            % Store if data is valid
            if ex ~= Eye_params.MISSING_DATA && ey ~= Eye_params.MISSING_DATA && ep > 0
                EyeTracker.Eye = [EyeTracker.Eye; GetSecs-Start_of_Expmt ex ey ep];
            end
        end
    end
    
    if Parameters.SaveAps % [optional] Get frame for video
        CurApImg = Screen('GetImage', Win, CenterRect([0 0 Rect(4) Rect(4)], Rect), 'backBuffer',1);
        CurApImg = rgb2gray(CurApImg);
        CurApImg = imresize(CurApImg, [size(Gabor.Stimulus,2) size(Gabor.Stimulus,3)]);
        ApFrm(:,:,CurrVolume) = CurApImg;
    end
    
    %     % Abort if Escape was pressed
    %     AbortCode();
    %     if Aborted
    %         return;
    %     end
    
    % Determine volume for next run through loop (TR-dependant)
    CurrVolume = floor((GetSecs - Start_of_Expmt) / Parameters.TR) + 1;
end
% Added - 13/12/2022
KbQueueStop;
KbQueueRelease;

Behaviour.EyeMotionPos = EyeMotionPos;

%% End of while loop
% Finish the experiment
% Clock after experiment
End_of_Expmt = GetSecs;
if Parameters.Eye_tracker
    Eyelink('Message', 'ENDEXP'); % end-time
end
disp('End Experiment Sequence!!')

End_Experiment();
