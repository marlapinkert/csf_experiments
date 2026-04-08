clear all;

subjName = input('Enter subject: ','s');

if isempty(subjName)
    error('Enter subject name to start experiment');
else
    pa.subject = subjName;
end

% GO!
ListenChar(2); HideCursor;

disp('Adding toolboxes & gamma tables to path...');
addpath(genpath([pwd '/Toolboxes']));

% Get display info
ds = SetupDisplay();
kb = SetupKeyboard();

% Get parameters
pa = SetupParameters(ds,pa);

% Preload mex files
GetSecs; KbCheck;

% Create background texture to help vergence
ds = MakeTextures(pa,ds);%MakeBgTexture(ds,pa);

Screen('TextSize',ds.w,14);
Screen('TextStyle',ds.w,1); % 1=bold,2=italic
Screen('TextColor',ds.w,[255 255 255]);

% Waiting screen
DrawBackground(ds);

DrawFixationDot(ds,pa);

Screen('SelectStereoDrawBuffer',ds.w,0);
Screen('DrawText',ds.w,'Press any key to start.',ds.textCoords(1)-100,ds.textCoords(2)-50);
Screen('SelectStereoDrawBuffer',ds.w,1);
Screen('DrawText',ds.w,'Press any key to start.',ds.textCoords(1)-100,ds.textCoords(2)-50);

Screen('Flip',ds.w);

kb.keyIsDown = 0;

while ~kb.keyIsDown
    [kb.keyIsDown] = KbCheck(kb.ID);
    
end

% Run experiment (press 'q' to quit)
pa.deltaT = 0;
stop = 0;

t0=GetSecs;
ds.vbl = t0;
vbls = ds.vbl;

data = nan(pa.numberOfTrials,7);

for trialii = 1:pa.numberOfTrials
    
    pa.trial = pa.design(trialii,:);
    
%     if pa.conditions(pa.trial(4))==2
%         pa.numberOfDots = ceil(pa.totalOfDots/2);
%     else
%         pa.numberOfDots = pa.totalOfDots;
%     end
    
    % Center textures on holes in swiss cheese texture
    [x, y] = pol2cart(d2r(pa.thetaDirs(pa.trial(1))), ds.ppd.*pa.rDirs(pa.trial(2)));
    dstRect = CenterRect([0 0 pa.apertureRadius pa.apertureRadius], ds.windowRect);

    dstRect = OffsetRect(dstRect,x,-y);  % NOTE: -y because pol2cart and OffsetRect differ on what is up & down

    [ds.dstCenter(1), ds.dstCenter(2)] = RectCenter(dstRect);        
    
    % Get new dots
    pa.dots = [];
    pa.dotKillTime = [];
    pa.distanceBeforeKill = [];
    
    pa.dotKillTime(1:pa.numberOfDots,1) = ((2*pa.disparityLimit)/pa.speed)*rand + ds.vbl; % random 'kill' time in seconds for new set of dots between ds.vbl (0) and ds.vbl+maxtime (will be used to determine the z location)    
    
    pa.distanceBeforeKill = pa.speed*(pa.dotKillTime-ds.vbl); % how far the dot will travel in deg.
    
    pa = NewDots(ds,pa,1:pa.numberOfDots); % optimized code
    
    %pa.dots(:,3) = 0; % set dots to 0 disparity initially
    
    tStart = GetSecs;
    
    pa.deltaT = 0;
    
    preStimDur = pa.preStimDuration + rand*pa.preStimDuration;
    
    while ds.vbl < tStart + preStimDur
        DrawBackground(ds);
        
        DrawFixationDot(ds,pa);
                
        ds.vbl = Screen('Flip',ds.w);
        vbls(end+1) = ds.vbl;
        pa.deltaT = vbls(end) - vbls(end-1);    
    end
    
    while ds.vbl < tStart + (preStimDur + pa.stimDuration)
        pa.xoffset = pa.deltaT * pa.speed;
        
        if pa.conditions(pa.trial(4))==2 % CD
            pos = pa.dots(:,3);
            pa = NewDots(ds,pa,1:pa.numberOfDots);
            pa.dots(:,3) = pos;
        end
        
        pa = UpdateDotPositions(pa,ds);
        
        DrawDots(ds,pa);
        
        DrawBackground(ds);
        
        DrawFixationDot(ds,pa);
                
        ds.vbl = Screen('Flip',ds.w);
        vbls(end+1) = ds.vbl;
        pa.deltaT = vbls(end) - vbls(end-1);
        
    end
    
    % Wait for response    
    kb.keyIsDown = 0;
    
    while ~kb.keyIsDown
        [kb,stop] = CheckKeyboard(kb);                
        
        DrawBackground(ds);
        DrawFixationDot(ds,pa);
        ds.vbl = Screen('Flip',ds.w);
        vbls(end+1) = ds.vbl;
    end
    
    if stop, break; end 
    
    if ~pa.demorun
        data(trialii,:) = [trialii kb.resp 0 pa.directions(pa.trial(3)) pa.thetaDirs(pa.trial(1)) pa.rDirs(pa.trial(2)) pa.conditions(pa.trial(4))];       
    else
        correct_resp = (kb.resp==1 && pa.directions(pa.trial(3))==-1) || (kb.resp==2 && pa.directions(pa.trial(3))==1);
        demodata(trialii,:) = [trialii pa.conditions(pa.trial(4)) correct_resp];
    end
    
    if ~pa.demorun && mod(trialii,20)==0 % Save data every 20 trials
        save(pa.filename,'pa','ds','data');
    end
end

if ~pa.demorun
    save(pa.filename,'pa','ds','data');
else
   
    disp('Performance:');
    
    conds = unique(demodata(:,2));
    
    for cii = 1:length(conds)
        pcorrect = sum(demodata( demodata(:,2) == conds(cii), 3))./size(demodata,1);
        
        disp([pa.conditionNames{conds(cii)} ': ' num2str(pcorrect*100) '%']);
    end
    
    
end

% Restore gamma table
if isfield(ds,'oldgamma')
    Screen('LoadNormalizedGammaTable',ds.w, ds.oldgamma);
end

ListenChar(0); ShowCursor; sca;
