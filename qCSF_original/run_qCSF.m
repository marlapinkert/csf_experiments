%%%%%%%%%%%%%%%%%%%
% qCSF EXPERIMENT %
%%%%%%%%%%%%%%%%%%%

close('all'); clc;
clear all;
qcsf_dir = '/data1/projects/dumoulinlab/Lab_members/Marcus/programs/Experiments/vdncsf_protocol/qCSF_original';
ncsf_dir = '/data1/projects/dumoulinlab/Lab_members/Marcus/programs/Experiments/vdncsf_protocol/CSF_10bit';
peri_dir = '/data1/projects/dumoulinlab/Lab_members/Marcus/programs/Experiments/vdncsf_protocol/Perimetry';
cd(qcsf_dir);
rmpath(genpath(ncsf_dir))
rmpath(genpath(peri_dir))

rootDir = pwd;

initials = input('>>>>>>>> Participant ID (eg, S1): ','s');
expCond  = input('>>>>>>>> experimental condition (eg, L_2D): ','s');

ListenChar(2); HideCursor

linearize          = 1;
isforwardmask      = 1;
stimsize           = 5; %degrees radius please
stimduration       = .3; %in seconds
maskduration       = .15; %in seconds

resolution         = [1920 1080]; % in pix
dispSize           = [69.84 39.29]; %in cm
dispDist           = 220; % in cm
imageSizeperdegree = mean([resolution(1)/dispSize(1) resolution(2)/dispSize(2)])./(57/dispDist); % about 106.10 ppd
% imageSizeperdegree = 106.107;%287.85; % pixel per degree
scale_factor       = 60/imageSizeperdegree;
frame_rate         = 120;    % for the actual exp: SET THIS AND MONITOR TO 120!!!!!!!

%% DEFINE TASK
nAFC               = 2; %2 or 4
angle_ref          = 0;

if nAFC==4
    angle_offset   = 30;
elseif nAFC==2
    angle_offset   = 30;
end
n_trials           = 50;% # trials for qCSF

feedback           = 1; % feedback?


Hor_eccentr         = 0;
Ver_eccentr         = 0;
V_ecc_fix           = 0;
H_ecc_fix           = 0;

fixcolor = 0;
l = round(.25.*imageSizeperdegree); % fixation cross half-length


%background            = 127.5;   % background intensity, in gray scale untis
background            = .5;
Screen('Preference', 'SkipSyncTests', 1);
KbName('UnifyKeyNames')

% n_staircases                    = length(coherance_set)*n_staircases;
% cycle                           = ISI/(1000/frame_rate);
count   = zeros(1,1);
results = zeros(n_trials,1);

V_ecc_fix = V_ecc_fix*60/scale_factor;
Ver_eccentr=Ver_eccentr*-1;

stimulus_radius  = 60*stimsize/scale_factor;
H_ecc_stim       = Hor_eccentr;  H_ecc_stim = round(H_ecc_stim*60/scale_factor);
H_ecc_fix        = H_ecc_fix*60/scale_factor;
V_ecc_stim       = Ver_eccentr;  V_ecc_stim = V_ecc_stim*60/scale_factor;

max_SF    = ceil(scale_factor)*2; %this gets us to arcmin/cycle
max_SF    = 60/max_SF; %Now we've got maximum SF for this setup at a given distance (safely calculated using ceilings)
qcsf      = setupQCSF(max_SF,nAFC);
numTrials = n_trials;    % Setup the number of trials for the experiment or simulation.

%         'For the quick CSF initial priors,', 'enter the best guess for peak sensitivity (5-1000):'),...
%         'Enter the best guess for peak frequency (.5-10 cpd):',...
%         'Enter the best guess for bandwidth (1.5-6 octaves)',.
%         'Enter the best guess for low-frequency truncation (.05-1.5 log10 units)'};
qcsf = setupPriors(qcsf,[50 2 3 .5]);

% make the spatial envelope
stimulus_radius = round(stimulus_radius);
for ii=1:max(size(stimulus_radius))
    [x,y] = meshgrid(-stimulus_radius(ii):stimulus_radius(ii),-stimulus_radius(ii):stimulus_radius(ii));
    bps   = (stimulus_radius(ii))*2+1;circle=((stimulus_radius(ii))^2-(x.^2+y.^2));
    for i=1:bps
        for j =1:bps
            if circle(i,j) < 0; circle(i,j) = 0;
            else
                circle(i,j) = 1;
            end
        end
    end
    circle = CreateCircularAperture2(size(x,1),.5.*imageSizeperdegree,2,size(x,1));
    Env(ii).x1 = x;Env(ii).y1 = y;Env(ii).circle1 = circle;BPS(ii) = bps;
end

%make temporal envelope
n_frames    = round(stimduration*frame_rate);
tempenv     = horzcat(ones(1,n_frames));

%open screen windows,
% oldVisualDebugLevel   = Screen('Preference', 'VisualDebugLevel', 3);
% oldSupressAllWarnings = Screen('Preference', 'SuppressAllWarnings', 1);
screens      = Screen('Screens');
screenNumber = 0%max(screens); % MD EDIT TO BE 2

% High bit depth (bit stealing) using MONO++
PsychDefaultSetup(2)
PsychImaging('PrepareConfiguration');
PsychImaging('AddTask','General','EnablePseudoGrayOutput');
PsychImaging('AddTask','General','FloatingPoint32Bit');

% May 2025 -> commented out these 2 lines (no longer BITS!!) 
% but it worked.... -> 
PsychImaging('AddTask','FinalFormatting','DisplayColorCorrection','ClampOnly');
PsychImaging('AddTask','General','EnableBits++Mono++Output');

[w originalrect] = PsychImaging('OpenWindow', screenNumber);

centerx = floor((originalrect(3) - originalrect(1))/2);
centery = floor((originalrect(4) - originalrect(2))/2);

screen_rect  = Screen('Rect',w);

% if linearize
%     load 'gamma_linear.mat'   %   load 'calibrationmatrix.mat'
%     Screen('LoadNormalizedGammaTable',screenNumber,gt);%,HP_widescreen_CRT);
% end

% RGBbackground    = Screen('Maketexture',w,background.*ones(originalrect(4),originalrect(3),3));
RGBbackground    = Screen('Maketexture',w,background.*ones(originalrect(4),originalrect(3),1));
Screen('Drawtexture',w,RGBbackground);     % clear Screen
Screen('TextSize',w,30);Screen('TextFont',w,'Charcoal');
Screen('Flip',w);

sr_hor   = round(screen_rect(3)/2);
sr_ver   = round(screen_rect(4)/2);
fix_hor  = sr_hor+H_ecc_fix;
fix_ver  = sr_ver+V_ecc_fix;
fix_rect = SetRect(0, 0, 2*scale_factor, 2*scale_factor);
fix_rect = CenterRectOnPoint(fix_rect,fix_hor,fix_ver);

movie_rect(:,ii)   = [0,0,BPS(ii),BPS(ii)];
scr_left_middle    = fix(screen_rect(3)/2)-round(BPS(ii)/2);
scr_top            = fix(screen_rect(4)/2)-round(BPS(ii)/2);
screen_rect_middle = movie_rect(:,ii)' + [scr_left_middle, scr_top, scr_left_middle, scr_top];
screen_patch(:,ii) = screen_rect_middle+[H_ecc_stim(ii),V_ecc_stim(ii),H_ecc_stim(ii),V_ecc_stim(ii)];

total_trials=numTrials;

perm                            = randperm(total_trials);
perm                            = mod(perm,1)+1;

Screen('Drawtexture',w,RGBbackground);     % clear Screen
Screen(w,'DrawLine',fixcolor,sr_hor-l+H_ecc_fix,sr_ver+V_ecc_fix,sr_hor+l+H_ecc_fix,sr_ver+V_ecc_fix,4);
Screen(w,'DrawLine',fixcolor,sr_hor+H_ecc_fix,sr_ver-l+V_ecc_fix,sr_hor+H_ecc_fix,sr_ver+l+V_ecc_fix,4);
Screen('Flip', w);
KbWait;

trial = 1;
% try
while trial <= total_trials
    t1 = GetSecs;
    
    count(perm(trial)) = count(perm(trial))+1;
    
    % define orientation
    %         orientation=round(rand);
    orientation=randperm(nAFC);
    orientation=orientation(1);
    
    if nAFC==4
        switch orientation
            case 1
                angle_deviation=angle_ref+angle_offset.*(orientation-1);
                correct   = 'q';%'1';
            case 2
                angle_deviation=angle_ref+angle_offset.*(orientation-1);
                correct   = 'w';%'2';
            case 3
                angle_deviation=angle_ref+angle_offset.*(orientation-1);
                correct   = 'e';%'3';
            case 4
                angle_deviation=angle_ref+angle_offset.*(orientation-1);
                correct   = 'r';%'4';
        end
    elseif nAFC==2
        switch orientation
            case 1
                angle_deviation=angle_ref-angle_offset;
                correct   = '1!';%'r';%'left'%'1';
                incorrect = '2@';%'t';%'right'%'1';

            case 2
                angle_deviation=angle_ref+angle_offset;
                correct   = '2@';%'RightArrow';%'right';%'2';
                incorrect = '1!';%'LeftArrow';%'left'%'1';

        end
    end
    
    % define qCSF
    qcsf.data.trial=trial;
    [qcsf,nextFrequency,nextContrast]=runQCSF(qcsf,'pretrial');
        
    amplitude = background*nextContrast; %  stim contrast
    f=(nextFrequency*scale_factor/60)*2*pi; %  stim SF
    randPhase = rand.*pi; % stim phase
    a=cos(deg2rad(angle_deviation))*f; b=sin(deg2rad(angle_deviation))*f;
    
    %grating
    mv_length = round(stimduration.*frame_rate);
    for i = 1:mv_length
        ramp_amp     = amplitude;%*tempenv(i);
        movie{i}     = ((sin(a*x+b*y+randPhase).*circle*ramp_amp)+background);
        movie_play{i}=Screen('MakeTexture',w,movie{i});
    end
    %(max(movie{i}(:)) - min(movie{i}(:)))./255
    %mask
    mk_length = round(maskduration.*frame_rate);
    whitenoise = randn(size(x));

    if isforwardmask
    for i = 1:mk_length
        ramp_amp = amplitude;%*tempenv(i);
%         movie_mask{i} = round((randn(size(x)).*circle*background)+background);
         movie_fwdmask{i} = ((whitenoise.*circle*background)+background);
        movie_play_fwdmask{i}=Screen('MakeTexture',w,movie_fwdmask{i});
    end
    end
    
    whitenoise = randn(size(x));
    for i = 1:mk_length
        ramp_amp = amplitude;%*tempenv(i);
%         movie_mask{i} = round((randn(size(x)).*circle*background)+background);
         movie_bwdmask{i} = ((whitenoise.*circle*background)+background);
                movie_play_bwdmask{i}=Screen('MakeTexture',w,movie_bwdmask{i});

    end
    
    %isi
%     isi_length = round(isiduration.*frame_rate);
    
%  initiate trial
    t2 = GetSecs - t1;
    FlushEvents('keyDown');
        Screen('Drawtexture',w,RGBbackground);     % clear Screen
        Screen(w,'DrawLine',fixcolor,sr_hor-l+H_ecc_fix,sr_ver+V_ecc_fix,sr_hor+l+H_ecc_fix,sr_ver+V_ecc_fix,4);
        Screen(w,'DrawLine',fixcolor,sr_hor+H_ecc_fix,sr_ver-l+V_ecc_fix,sr_hor+H_ecc_fix,sr_ver+l+V_ecc_fix,4);
    Screen('Flip', w);
    WaitSecs(.025);
    
    mm = round(imageSizeperdegree);
    for i=0:4
        nn = mm-i.*(.15.*round(imageSizeperdegree));
        Screen('Drawtexture',w,RGBbackground);     % clear Screen
        Screen('FrameOval', w,.33,[fix_hor-nn, fix_ver-nn, fix_hor+nn, fix_ver+nn],2,2)
        Screen('Flip', w);
        WaitSecs(0.025);
    end

    Screen('Drawtexture',w,RGBbackground);     % clear Screen
    Screen('Flip', w);
    
    %Wait for fixation
    %Beeper(1000,.5,.1);
    
    % play the movie
    priorityLevel = MaxPriority(w);Priority(priorityLevel);
    blah          = GetSecs;
    if isforwardmask
        for i = 1:ceil(mk_length)
            Screen('Drawtexture',w,RGBbackground);     % clear Screen
            Screen('DrawTexture', w, movie_play_fwdmask{i},movie_rect,screen_patch);
            tFwdMaskOn(i) = Screen('Flip',w);
        end
    end
    
    for i = 1:ceil(mv_length)
        Screen('Drawtexture',w,RGBbackground);     % clear Screen
        Screen('DrawTexture', w, movie_play{i},movie_rect,screen_patch);
        tStimOn(i) = Screen('Flip',w);
    end
    
    for i = 1:ceil(mk_length)
        Screen('Drawtexture',w,RGBbackground);     % clear Screen
        Screen('DrawTexture', w, movie_play_bwdmask{i},movie_rect,screen_patch);
        tBwdMaskOn(i) = Screen('Flip',w);
    end
    
    Screen('Drawtexture',w,RGBbackground);     % clear Screen
    tMaskOff = Screen('Flip', w);

    Priority(0);
    if isforwardmask
    fwdmaskDur(trial) =  tStimOn(1)   - tFwdMaskOn(1);
    end
    stimDur(trial) =  tBwdMaskOn(1) - tStimOn(1);
    maskDur(trial) =  tMaskOff   - tBwdMaskOn(1);
    
    % Get the response
    FlushEvents('keyDown');
    validKey = 0;
    
    %         while ~validKey
    %             [secs, keyCode, deltaSecs] = KbWait;
    %             if keyCode(KbName(incorrect))
    %                 rs=0;
    %                 validKey = 1;
    %                 if feedback
    %                     Beeper(600,.5,.1); Beeper(400,.5,.15);
    %                 end
    %             elseif keyCode(KbName(correct))
    %                 rs=1;
    %                 validKey = 1;
    %                 results(count(perm(trial)),perm(trial)) = 1;
    %                 if feedback
    %                     Beeper(1100,.5,.1);
    %                 end
    %             elseif keyCode(KbName('Escape'));
    %                 Screen('CloseAll')
    %                 clear mex
    %             end
    %         end
    while ~validKey
        
        [secs, keyCode, deltaSecs] = KbWait;
        %disp(KbName(correct))

        if keyCode(KbName('ESCAPE'))
            Screen('CloseAll')
            clear mex
        elseif nAFC==2
           
            if keyCode(KbName(correct))
               
                rs=1;
                validKey = 1;
                results(count(perm(trial)),perm(trial)) = 1;
                if feedback
                    %Beeper(1100,.5,.1);
                end
            elseif keyCode(KbName(incorrect))
               
                rs=0;
                validKey = 1;
                if feedback
                    beep%Beeper(600,.5,.1); Beeper(400,.5,.15);
                end
            end
        elseif nAFC==4
            if keyCode(KbName(correct))
                rs=1;
                validKey = 1;
                results(count(perm(trial)),perm(trial)) = 1;
                if feedback
                    %Beeper(1100,.5,.1);
                end
                
            else
                rs=0;
                validKey = 1;
                if feedback
                    beep%Beeper(600,.5,.1); Beeper(400,.5,.15);
                end
            end
        end
    end
    
    % update qCSF
    qcsf.data.history(trial,:) = [trial nextFrequency nextContrast rs];% updating the experimental history
    qcsf=runQCSF(qcsf,'posttrial',nextFrequency,nextContrast,rs);
    
    disp(['TRIAL ' num2str(trial)...
        ' : SF = ' num2str(nextFrequency)...
        ' CONTRAST = ' num2str(nextContrast)...
        ' CORRECT = ' num2str(rs)]) 
    
    trial = trial+1;

    Screen('Drawtexture',w,RGBbackground);     % clear Screen
    Screen(w,'DrawLine',fixcolor,sr_hor-l+H_ecc_fix,sr_ver+V_ecc_fix,sr_hor+l+H_ecc_fix,sr_ver+V_ecc_fix,4);
    Screen(w,'DrawLine',fixcolor,sr_hor+H_ecc_fix,sr_ver-l+V_ecc_fix,sr_hor+H_ecc_fix,sr_ver+l+V_ecc_fix,4);
    Screen('Flip', w);
    end


Screen('CloseAll');

mkdir('Data',initials);
dir = ['./Data/' num2str(initials) '/']

cd(dir)
tme                             = clock;
filename=strcat(initials,'_',expCond,'_qCSF_',int2str(tme(1)),'_',int2str(tme(2)),'_',int2str(tme(3)),'_',int2str(tme(4)),'_',int2str(tme(5)));
save(filename);
cd(rootDir)

% plot the results
qcsf=runQCSF(qcsf,'plot experiment');

ListenChar(0);
clear mex

% catch
%
%     psychrethrow(lasterror);
%     ShowCursor;
%     Screen('CloseAll');
%     Screen('Preference', 'VisualDebugLevel', oldVisualDebugLevel);
%     Screen('Preference', 'SuppressAllWarnings', oldSupressAllWarnings);
%     Priority(0);
%
%     psychrethrow(psychlasterror)
%     Priority(0);
% end
