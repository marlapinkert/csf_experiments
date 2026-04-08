function [response, timing, quitProg, success] = showScanStimulusAttentionFixation(display,params,stimulus, t0)
% [response, timing] = showStimulus(display,stimulus, time0)
%
% t0 is the time the scan started and the stimulus timing should be
% relative to t0. If t0 does not exist it is created at the start of
% this program.
%
% HISTORY:
% 2005.02.23 RFD: ported from showStimulus.
% 2005.06.15 SOD: modified for OSX. Use internal clock for timing rather
% than framesyncing because getting framerate does not always work. Using
% the internal clock will also allow some "catching up" if stimulus is
% delayed for whatever reason. Loading mex functions is slow, so this
% should be done before callling this program.

% input checks
if nargin < 2,
    help(mfilename);
    return;
end;
if nargin < 3 || isempty(t0),
    t0 = GetSecs; % "time 0" to keep timing going
end;

% some more checks
if ~isfield(stimulus,'textures')
    % Generate textures for each image
    disp('WARNING: Creating textures before stimulus presentation.');
    disp(['         This should be done before calling ' mfilename ' for']);
    disp('         accurate timing.  See "makeTextures" for help.');
    stimulus = makeTextures(display,stimulus);
end;

% quit key
try
    quitProgKey = display.quitProgKey;
catch ME
    quitProgKey = KbName('q'); %#ok<NASGU>
    rethrow(ME);
end;

firstKey=KbName('z');
secondKey=KbName('x');

% some variables
nFrames = length(stimulus.seq);
HideCursor;
nGamma = size(stimulus.cmap,3);
nImages = length(stimulus.textures);
response.keyCode = zeros(length(stimulus.seq),2); % get 1 buttons max
response.secs = zeros(size(stimulus.seq));        % timing
quitProg = 0;
fullTR = params.tr./(1./(params.temporal.frequency*params.temporal.motionSteps));
realTR = ((length(stimulus.seq)./1./(params.temporal.frequency*params.temporal.motionSteps))./params.tr);
saveAlphas = ones(realTR,1).*3;
saveQuantiles = ones(realTR,1).*3;
saveResponses = ones(realTR,1).*3;


if isfield(stimulus, 'pictures')
    pictureCounter=0;
    nImages=nImages-length(stimulus.pictures).*2;
end

stimulus.makeMovie=0;
recordingStartFrame=0; %Where to start recording the movie. Set to zero for movie start
recordingFrames=nFrames; %Set to nFrames for whole stimulus, or frameRate*30 for first 30 seconds sample (better for presentations)
% if isfield(stimulus, 'makeMovie') && stimulus.makeMovie==1 && recordingFrames==nFrames; %If recording a movie of the whole stimulus, split the movie into 4 parts to avoid filling memory
%     aviobjA = avifile('checkMovieA.avi', 'FPS', 20);
%     aviobjB = avifile('checkMovieB.avi', 'FPS', 20);
%     aviobjC = avifile('checkMovieC.avi', 'FPS', 20);
%     aviobjD = avifile('checkMovieD.avi', 'FPS', 20);
%     recordingFrames=nFrames/4;
if isfield(stimulus, 'makeMovie') && stimulus.makeMovie==1; %If recording a movie of a short part of the stimulus, keep it as one file
    aviobj = avifile('CheckMovie.avi', 'FPS', 20);
end

params.randomIntervalBar=Shuffle(repmat([1 2]',(ceil(realTR/2)), 1));
params.randomIntervalFixation=Shuffle(repmat([1 2]', (ceil(realTR/2)), 1));
params.randomIntervalBar = params.randomIntervalBar(1:realTR);
params.randomIntervalFixation = params.randomIntervalFixation(1:realTR);

params.psychResponse=ones(realTR, 1);
barPeriods=[1:28 49:88 109:148 169:208 229:248];

rotationAngles=rand(2, realTR).*360;

alphaLevelBar=0.5;
alphaLevelFixation=0.6;
blendBar = 0;
blendFix = 1;
horSize = 30;
verSize = 30;
eyeTracker=0;
success='';

pThreshold=0.75;    %Threshold percentage
gamma=1/2;          %Chance performance
StartingPoint=alphaLevelFixation;   %Starting point of staircase, a guess of performance
PerformanceSD=0.8;   %Standard

beta=3.5;           %Wiebull function parameters, better not to change these
delta=0.01;
t=[];
sd=[];

q=QuestCreate(StartingPoint,PerformanceSD,pThreshold,beta,delta,gamma);
alphaLevelFixation = QuestQuantile(q)
if alphaLevelFixation>0.75;
    alphaLevelFixation=0.75;
elseif alphaLevelFixation<0
    alphaLevelFixation=0;
end
responseGiven=0;

% go
fprintf('[%s]:Running. Hit %s to quit.\n',mfilename,KbName(quitProgKey));
for frame = 1:nFrames
    
     
    whichTR=ceil(frame/fullTR);
    whichFrame=mod(frame, fullTR);
    if whichFrame==0
        whichFrame=fullTR;
    end
    saveAlphas(whichTR) = alphaLevelBar;
    saveQuantiles(whichTR) = QuestQuantile(q);
    %--- update display
    % If the sequence number is positive, draw the stimulus and the
    % fixation.  If the sequence number is negative, draw only the
    % fixation.
    
    if stimulus.seq(frame)>0
        % put in an image
        imgNum = mod(stimulus.seq(frame)-1,nImages)+1;
        
        Screen('DrawTexture', display.windowPtr, stimulus.textures(imgNum), stimulus.srcRect, stimulus.destRect);
        
        if blendBar ==1;
            if params.randomIntervalBar(whichTR) == 1 && whichFrame <= params.StimOnFrames;
                Screen('DrawTexture', display.windowPtr, stimulus.textures(length(stimulus.textures)), stimulus.srcRect, stimulus.destRect, [], [], alphaLevelBar);
            elseif params.randomIntervalBar(whichTR)==2 && whichFrame > (params.StimOnFrames + params.ISIframes) && whichFrame <= (2*params.StimOnFrames + params.ISIframes);
                Screen('DrawTexture', display.windowPtr, stimulus.textures(length(stimulus.textures)), stimulus.srcRect, stimulus.destRect, [], [], alphaLevelBar);
            end
        end
        
        
        if whichFrame <= params.StimOnFrames || (whichFrame > (params.StimOnFrames + params.ISIframes) && whichFrame <= (2*params.StimOnFrames + params.ISIframes));
            
            
            Screen('gluDisk', display.windowPtr, [128 128 128], display.fixX, display.fixY, angle2pix(params.display, 1/2));
            drawFixation(display,stimulus.fixSeq(frame));
            if whichFrame <= params.StimOnFrames
                Screen('DrawTexture', display.windowPtr, stimulus.fixationTexture(mod(whichTR,10)+1), stimulus.srcRect,stimulus.destRect, rotationAngles(1,whichTR));
            elseif whichFrame > (params.StimOnFrames + params.ISIframes) && whichFrame <= (2*params.StimOnFrames + params.ISIframes)
                Screen('DrawTexture', display.windowPtr, stimulus.fixationTexture(mod(whichTR,10)+1), stimulus.srcRect,stimulus.destRect, rotationAngles(2,whichTR));
            end
            
            
            if blendFix ==1;
                
                %                 if params.randomIntervalFixation(whichTR) == 1&& whichFrame <= params.StimOnFrames;
                %                     Screen('DrawTexture', display.windowPtr, stimulus.textures(length(stimulus.textures)), stimulus.srcRect,[display.fixX-horSize display.fixY-verSize display.fixX+horSize display.fixY+verSize], [], [], alphaLevel);
                %                 elseif params.randomIntervalFixation(whichTR)==2 && whichFrame > (params.StimOnFrames + params.ISIframes) && whichFrame <= (2*params.StimOnFrames + params.ISIframes);
                %                     Screen('DrawTexture', display.windowPtr, stimulus.textures(length(stimulus.textures)), stimulus.srcRect,[display.fixX-horSize display.fixY-verSize display.fixX+horSize display.fixY+verSize], [], [], alphaLevel);
                %                 end
                if params.randomIntervalFixation(whichTR) == 1&& whichFrame <= params.StimOnFrames;
                    Screen('DrawTexture', display.windowPtr, stimulus.alphaTexture, stimulus.srcRect,stimulus.destRect, [], [], alphaLevelFixation);
                elseif params.randomIntervalFixation(whichTR)==2 && whichFrame > (params.StimOnFrames + params.ISIframes) && whichFrame <= (2*params.StimOnFrames + params.ISIframes);
                    Screen('DrawTexture', display.windowPtr, stimulus.alphaTexture, stimulus.srcRect,stimulus.destRect, [], [], alphaLevelFixation);
                end
            end
        else
            drawFixation(display,stimulus.fixSeq(frame));
        end
        
        
    elseif stimulus.seq(frame)<0
        % put in a color table
        gammaNum = mod(-stimulus.seq(frame)-1,nGamma)+1;
        % The second argument is the color index.  This apparently changed
        % in recent times (07.14.2008). So, for now we set it to 1.  It may
        % be that this hsould be
        drawFixation(display,stimulus.fixSeq(frame));
        Screen('LoadNormalizedGammaTable', display.windowPtr, stimulus.cmap(:,:,gammaNum));
    end;
    
    %--- timing
    waitTime = (GetSecs-t0)-stimulus.seqtiming(frame);
    
    %%USEFUL FOR CHECKING FOR DROPPED FRAMES
    if waitTime>0
        waitTime
    end
    if eyeTracker==1;
        error=EYELINK('checkrecording');
        if(error~=0)
            success='EYL_RECORDING_INTERRUPT';
            return;
        end
    end
    
    %--- get inputs (subject or experimentor)
    while(waitTime<0),
        % Scan the UMC device for subject response
        if display.devices.UMCport==2
            [ssKeyCode,ssSecs] = deviceUMC('response_and_trigger',display.devices.UMCport);
            
            if ssKeyCode==66 || ssKeyCode==68
                params.psychResponse(whichTR)=1;
            elseif ssKeyCode==65 || ssKeyCode==67
                params.psychResponse(whichTR)=2;
            elseif any(ssKeyCode)
                response.keyCode(frame,:) = ssKeyCode;
                response.secs(frame)    = ssSecs - t0;
            end
        end
        % scan the keyboard for experimentor input
        [exKeyIsDown,tmp,exKeyCode] = KbCheck();
        if(exKeyIsDown)
            if(exKeyCode(quitProgKey)),
                quitProg = 1;
                break; % out of while loop
            elseif (exKeyCode(firstKey)) && (whichFrame>=params.StimOnFrames+params.ISIframes)
                params.psychResponse(whichTR)=1;
                responseGiven=1;
            elseif (exKeyCode(secondKey)) && (whichFrame>=params.StimOnFrames+params.ISIframes)
                params.psychResponse(whichTR)=2;
                responseGiven=1;
            end;
        end;
        
        
        
        % if there is time release cpu
        if(waitTime<-0.02),
            WaitSecs(0.01);
        end;
        
        % timing
        waitTime = (GetSecs-t0)-stimulus.seqtiming(frame);
    end;
    
    if whichFrame==fullTR && responseGiven==1;
        responseGiven=0;
        %Allows experimenter to choose to give a correct or incorrect
        %answer for debugging
        %         if params.psychResponse(whichTR)==1
        %             params.psychResponse(whichTR)=params.randomIntervalFixation(whichTR);
        %         elseif params.psychResponse(whichTR)==2
        %             params.psychResponse(whichTR)=3-params.randomIntervalFixation(whichTR);
        %         end
        correct=params.psychResponse(whichTR)==params.randomIntervalFixation(whichTR)
        q=QuestUpdate(q,alphaLevelFixation,correct);
        saveResponses(whichTR) = correct;
        alphaLevelFixation = QuestQuantile(q)
        if alphaLevelFixation>0.75;
            alphaLevelFixation=0.75;
        elseif alphaLevelFixation<0
            alphaLevelFixation=0;
        end
    end
    if whichFrame==fullTR
        if whichTR==(realTR)*.25 || whichTR==(realTR)*.5 || whichTR==(realTR)*.75 || whichTR==(realTR)
            t=[t QuestMean(q)];
            sd=[sd QuestSd(q)];
            disp(sprintf('Final threshold estimate (mean +- sd) is %.2f% +- %.2f%\n',t(end),sd(end)));
            if whichTR==(realTR)
                t
                sd
            else
                q=QuestCreate(StartingPoint,PerformanceSD,pThreshold,beta,delta,gamma);
                alphaLevelFixation = QuestQuantile(q);
                if alphaLevelFixation>0.75;
                    alphaLevelFixation=0.75;
                elseif alphaLevelFixation<0
                    alphaLevelFixation=0;
                end
            end
        end
    end
    
    %--- stop?
    if quitProg,
        fprintf('[%s]:Quit signal recieved.\n',mfilename);
        break;
    end;
    
    %--- update screen
    Screen('Flip',display.windowPtr);
    
    
end
save('savesFixation','saveResponses','saveAlphas','saveQuantiles');

correctResponses=100*(sum(params.randomIntervalFixation==params.psychResponse)./248);
disp(sprintf('[%s]:Fixation psychophysics task percentage correct: %f' ,mfilename, correctResponses));

% that's it
ShowCursor;
timing = GetSecs-t0;
t=QuestMean(q);		
sd=QuestSd(q);
disp(sprintf('Final threshold estimate (mean +- sd) is %.2f% +- %.2f%\n',t,sd));
fprintf('[%s]:Stimulus run time: %f seconds [should be: %f].\n',mfilename,timing,max(stimulus.seqtiming));

if eyeTracker==1;
    success = 'EYL_RECORDING_COMPLETE';
    EYELINK('message', 'Stimulus Started');
    Eyelink('StopRecording');
end

return;
