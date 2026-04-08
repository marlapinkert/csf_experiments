function [response, timing, quitProg, params] = showScanStimulusAttentionPsychophysics(display,params,stimulus, t0, subject, n, typeExp)
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

% You might want to change the switch at about line 85 to something which
% you think is useful to set the experiment to the desired condition. The
% switch sets it using the typeExp variable. Subject and n variable are
% only used in the save command at the bottom of this script. 

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
numStairsFinished = 0;
nFrames = length(stimulus.seq);
HideCursor;
nGamma = size(stimulus.cmap,3);
nImages = length(stimulus.textures);
response.keyCode = zeros(length(stimulus.seq),2); % get 1 buttons max
response.secs = zeros(size(stimulus.seq));        % timing
quitProg = 0;
fullTR = params.tr./(1./(params.temporal.frequency*params.temporal.motionSteps));
realTR = ((length(stimulus.seq)./1./(params.temporal.frequency*params.temporal.motionSteps))./params.tr);

if isfield(stimulus, 'pictures')
    pictureCounter=0;
    nImages=nImages-length(stimulus.pictures).*2;
end

stimulus.makeMovie=1;
recordingStartFrame=0; %Where to start recording the movie. Set to zero for movie start
recordingFrames=nFrames; %Set to nFrames for whole stimulus, or frameRate*30 for first 30 seconds sample (better for presentations)
% if isfield(stimulus, 'makeMovie') && stimulus.makeMovie==1 && recordingFrames==nFrames; %If recording a movie of the whole stimulus, split the movie into 4 parts to avoid filling memory
%     aviobjA = avifile('checkMovieA.avi', 'FPS', 20);
%     aviobjB = avifile('checkMovieB.avi', 'FPS', 20);
%     aviobjC = avifile('checkMovieC.avi', 'FPS', 20);
%     aviobjD = avifile('checkMovieD.avi', 'FPS', 20);
%     recordingFrames=nFrames/4;
if isfield(stimulus, 'makeMovie') && stimulus.makeMovie==1; %If recording a movie of a short part of the stimulus, keep it as one file
    aviobj = avifile('bras8.avi', 'FPS', 30,'Quality',100);
end

params.randomInterval(:,1)=Shuffle(repmat([1 2]',(ceil(realTR/2)), 1));
params.randomInterval(:,2)=Shuffle(repmat([1 2]', (ceil(realTR/2)), 1));
params.randomInterval(:,3)=Shuffle(repmat([1 2]', (ceil(realTR/2)), 1));
params.randomInterval(:,4)=Shuffle(repmat([1 2]', (ceil(realTR/2)), 1));
params.psychResponse=zeros(realTR, 1);
barPeriods=[1:28 49:88 109:148 169:208 229:248];
rotationAngles=rand(6, realTR).*360;
switch lower(typeExp)
    case {'bar'}
        condition = 1; %1 = bar, 2= fixation center, 3=fixation left, 4=fixation right
    case {'fix'}
        condition = 2;
    case {'fixleft'}
        condition = 3;
    case {'fixright'}
        condition = 4;
end
maxContrastBar=0.5;
maxContrastFixation=0.5;
maxContrastFixation2=0.5;
alphaLevels = [maxContrastBar/2,maxContrastFixation/2,maxContrastFixation2/2,maxContrastFixation2/2];
maxContrasts = [maxContrastBar,maxContrastFixation,maxContrastFixation2,maxContrastFixation];
meanContrasts = maxContrasts./2;

blendBar = 1;
blendFix = 1;
eyeTracker=0;
success='';

pThreshold=0.75;    %Threshold percentage
gamma=1/2;          %Chance performance
StartingPoint=alphaLevels(condition);   %Starting point of staircase, a guess of performance
PerformanceSD=0.8;   %Standard 

beta=3.5;           %Wiebull function parameters, better not to change these
delta=0.01;
t=[];
sd=[];

q=QuestCreate(StartingPoint,PerformanceSD,pThreshold,beta,delta,gamma);
alphaLevels(condition) = QuestQuantile(q);
if alphaLevels(condition)>maxContrasts(condition)/2;
    alphaLevels(condition)=maxContrasts(condition)/2;
elseif alphaLevels(condition)<0
    alphaLevels(condition)=0;
end
responseGiven=0;
responseCounter=0;
staircaseLength=30;

% go
fprintf('[%s]:Running. Hit %s to quit.\n',mfilename,KbName(quitProgKey));
for frame = 1:nFrames
    
    
    whichTR=ceil(frame/fullTR);
    whichFrame=mod(frame, fullTR);
    if whichFrame==0
        whichFrame=fullTR;
    end
    %--- update display
    % If the sequence number is positive, draw the stimulus and the
    % fixation.  If the sequence number is negative, draw only the
    % fixation.

    if stimulus.seq(frame)>0
        % put in an image
        imgNum = mod(stimulus.seq(frame)-1,nImages)+1;
        
        Screen('DrawTexture', display.windowPtr, stimulus.textures(imgNum), stimulus.srcRect, stimulus.destRect);
        
        if blendBar ==1;
            if params.randomInterval(whichTR,1) == 1
                if whichFrame <= params.StimOnFrames;
                    Screen('DrawTexture', display.windowPtr, stimulus.textures(length(stimulus.textures)), stimulus.srcRect, stimulus.destRect, [], [], meanContrasts(1)+alphaLevels(1));
                elseif whichFrame > (params.StimOnFrames + params.ISIframes) && whichFrame <= (2*params.StimOnFrames + params.ISIframes)
                    Screen('DrawTexture', display.windowPtr, stimulus.textures(length(stimulus.textures)), stimulus.srcRect, stimulus.destRect, [], [], meanContrasts(1)-alphaLevels(1));
                end
            elseif params.randomInterval(whichTR,1)==2
                if whichFrame <= params.StimOnFrames;
                    Screen('DrawTexture', display.windowPtr, stimulus.textures(length(stimulus.textures)), stimulus.srcRect, stimulus.destRect, [], [], meanContrasts(1)-alphaLevels(1));
                elseif whichFrame > (params.StimOnFrames + params.ISIframes) && whichFrame <= (2*params.StimOnFrames + params.ISIframes)
                    Screen('DrawTexture', display.windowPtr, stimulus.textures(length(stimulus.textures)), stimulus.srcRect, stimulus.destRect, [], [], meanContrasts(1)+alphaLevels(1));
                end
            end
        end
        
        if ismember(whichTR,barPeriods)
            if whichFrame <= params.StimOnFrames || (whichFrame > (params.StimOnFrames + params.ISIframes) && whichFrame <= (2*params.StimOnFrames + params.ISIframes));
                
                
                Screen('gluDisk', display.windowPtr, [128 128 128], display.fixX,display.fixY, angle2pix(params.display, stimulus.sizeGludiskC));
                Screen('gluDisk', display.windowPtr, [128 128 128], display.fixX+stimulus.distFromCenter, display.fixY, angle2pix(params.display, stimulus.sizeGludiskLR));
                Screen('gluDisk', display.windowPtr, [128 128 128], display.fixX-stimulus.distFromCenter, display.fixY, angle2pix(params.display, stimulus.sizeGludiskLR));
                drawFixation(display,stimulus.fixSeq(frame));
                if whichFrame <= params.StimOnFrames
                    Screen('DrawTexture', display.windowPtr, stimulus.fixationTexture(mod(whichTR,10)+1,1), stimulus.srcFixRect,stimulus.destFixRect1, rotationAngles(1,whichTR));
                    Screen('DrawTexture', display.windowPtr, stimulus.fixationTexture(mod(whichTR,10)+1,2), stimulus.srcFixRect,stimulus.destFixRect2, rotationAngles(3,whichTR));
                    Screen('DrawTexture', display.windowPtr, stimulus.fixationTexture(mod(whichTR,10)+1,3), stimulus.srcFixRect,stimulus.destFixRect3, rotationAngles(5,whichTR));
                elseif whichFrame > (params.StimOnFrames + params.ISIframes) && whichFrame <= (2*params.StimOnFrames + params.ISIframes)
                    Screen('DrawTexture', display.windowPtr, stimulus.fixationTexture(mod(whichTR,10)+1,1), stimulus.srcFixRect,stimulus.destFixRect1, rotationAngles(2,whichTR));
                    Screen('DrawTexture', display.windowPtr, stimulus.fixationTexture(mod(whichTR,10)+1,2), stimulus.srcFixRect,stimulus.destFixRect2, rotationAngles(4,whichTR));
                    Screen('DrawTexture', display.windowPtr, stimulus.fixationTexture(mod(whichTR,10)+1,3), stimulus.srcFixRect,stimulus.destFixRect3, rotationAngles(6,whichTR));
                end
                
                
                if blendFix ==1;
                    
                    %                 if params.randomIntervalFixation(whichTR) == 1&& whichFrame <= params.StimOnFrames;
                    %                     Screen('DrawTexture', display.windowPtr, stimulus.textures(length(stimulus.textures)), stimulus.srcRect,[display.fixX-horSize display.fixY-verSize display.fixX+horSize display.fixY+verSize], [], [], alphaLevel);
                    %                 elseif params.randomIntervalFixation(whichTR)==2 && whichFrame > (params.StimOnFrames + params.ISIframes) && whichFrame <= (2*params.StimOnFrames + params.ISIframes);
                    %                     Screen('DrawTexture', display.windowPtr, stimulus.textures(length(stimulus.textures)), stimulus.srcRect,[display.fixX-horSize display.fixY-verSize display.fixX+horSize display.fixY+verSize], [], [], alphaLevel);
                    %                 end
                    if params.randomInterval(whichTR,2) == 1
                        if whichFrame <= params.StimOnFrames;
                            Screen('DrawTexture', display.windowPtr, stimulus.alphaTexture, stimulus.srcFixRect,stimulus.destFixRect1, [], [], meanContrasts(2)+alphaLevels(2));
                        elseif whichFrame > (params.StimOnFrames + params.ISIframes) && whichFrame <= (2*params.StimOnFrames + params.ISIframes)
                            Screen('DrawTexture', display.windowPtr, stimulus.alphaTexture, stimulus.srcFixRect,stimulus.destFixRect1, [], [], meanContrasts(2)-alphaLevels(2));
                        end
                    elseif params.randomInterval(whichTR,2)==2
                        if whichFrame <= params.StimOnFrames;
                            Screen('DrawTexture', display.windowPtr, stimulus.alphaTexture, stimulus.srcFixRect,stimulus.destFixRect1, [], [], meanContrasts(2)-alphaLevels(2));
                        elseif whichFrame > (params.StimOnFrames + params.ISIframes) && whichFrame <= (2*params.StimOnFrames + params.ISIframes)
                            Screen('DrawTexture', display.windowPtr, stimulus.alphaTexture, stimulus.srcFixRect,stimulus.destFixRect1, [], [], meanContrasts(2)+alphaLevels(2));
                            
                        end
                    end
                    if params.randomInterval(whichTR,3) == 1
                        if whichFrame <= params.StimOnFrames;
                            Screen('DrawTexture', display.windowPtr, stimulus.alphaTexture2, stimulus.srcFixRect,stimulus.destFixRect2, [], [], meanContrasts(3)+alphaLevels(3));
                        elseif whichFrame > (params.StimOnFrames + params.ISIframes) && whichFrame <= (2*params.StimOnFrames + params.ISIframes)
                            Screen('DrawTexture', display.windowPtr, stimulus.alphaTexture2, stimulus.srcFixRect,stimulus.destFixRect2, [], [], meanContrasts(3)-alphaLevels(3));
                        end
                    elseif params.randomInterval(whichTR,3)==2
                        if whichFrame <= params.StimOnFrames;
                            Screen('DrawTexture', display.windowPtr, stimulus.alphaTexture2, stimulus.srcFixRect,stimulus.destFixRect2, [], [], meanContrasts(3)-alphaLevels(3));
                        elseif whichFrame > (params.StimOnFrames + params.ISIframes) && whichFrame <= (2*params.StimOnFrames + params.ISIframes)
                            Screen('DrawTexture', display.windowPtr, stimulus.alphaTexture2, stimulus.srcFixRect,stimulus.destFixRect2, [], [], meanContrasts(3)+alphaLevels(3));
                            
                        end
                    end
                    
                    if params.randomInterval(whichTR,4) == 1
                        if whichFrame <= params.StimOnFrames;
                            Screen('DrawTexture', display.windowPtr, stimulus.alphaTexture2, stimulus.srcFixRect,stimulus.destFixRect3, [], [], meanContrasts(4)+alphaLevels(4));
                        elseif whichFrame > (params.StimOnFrames + params.ISIframes) && whichFrame <= (2*params.StimOnFrames + params.ISIframes)
                            Screen('DrawTexture', display.windowPtr, stimulus.alphaTexture2, stimulus.srcFixRect,stimulus.destFixRect3, [], [], meanContrasts(4)-alphaLevels(4));
                        end
                    elseif params.randomInterval(whichTR,4)==2
                        if whichFrame <= params.StimOnFrames;
                            Screen('DrawTexture', display.windowPtr, stimulus.alphaTexture2, stimulus.srcFixRect,stimulus.destFixRect3, [], [], meanContrasts(4)-alphaLevels(4));
                        elseif whichFrame > (params.StimOnFrames + params.ISIframes) && whichFrame <= (2*params.StimOnFrames + params.ISIframes)
                            Screen('DrawTexture', display.windowPtr, stimulus.alphaTexture2, stimulus.srcFixRect,stimulus.destFixRect3, [], [], meanContrasts(4)+alphaLevels(4));
                            
                        end
                    end
                end
            else
                drawFixation(display,stimulus.fixSeq(frame));
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
        waitTime;
    end
    
    if isfield(stimulus, 'makeMovie') && stimulus.makeMovie==1;
        if (whichFrame == 3 || whichFrame == 18) && ismember(whichTR,barPeriods);
            screenimage = Screen('getimage',display.windowPtr,[243 0 782 539]);
            screenframe = im2frame(screenimage);
            aviobj = addframe(aviobj,screenframe);
        end
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
                responseGiven=1;
            elseif ssKeyCode==65 || ssKeyCode==67
                params.psychResponse(whichTR)=2;
                responseGiven=1;
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
                params.psychResponse(whichTR)=2;
                responseGiven=1;
          
            elseif (exKeyCode(secondKey)) && (whichFrame>=params.StimOnFrames+params.ISIframes)
                params.psychResponse(whichTR)=1;
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
        responseCounter=responseCounter+1;
        responseGiven=0;
        %Allows experimenter to choose to give a correct or incorrect
        %answer for debugging
%         if params.psychResponse(whichTR)==1
%             params.psychResponse(whichTR)=params.randomIntervalBar(whichTR);
%         elseif params.psychResponse(whichTR)==2
%             params.psychResponse(whichTR)=3-params.randomIntervalBar(whichTR);            
%         end
        correct=params.psychResponse(whichTR)==params.randomInterval(whichTR,condition);
        q=QuestUpdate(q,alphaLevels(condition),correct);
        alphaLevels(condition)=QuestQuantile(q);
        if alphaLevels(condition)>maxContrasts(condition)/2;
            alphaLevels(condition)=maxContrasts(condition)/2;
        elseif alphaLevels(condition)<0
            alphaLevels(condition)=0;
        end
    end
    if whichFrame==fullTR
        if responseCounter == staircaseLength
            numStairsFinished = numStairsFinished +1;
            responseCounter=0;
            %         [tmp1, listMember, tmp2]=intersect(barPeriods, whichTR);
            %         if listMember==length(barPeriods)*.25 | listMember==length(barPeriods)*.5 | listMember==length(barPeriods)*.75 | listMember==length(barPeriods)
            %OK for fixation
            %whichTR==248*.25 || whichTR==248*.5 || whichTR==248*.75 || whichTR==248
            t=[t QuestMean(q)];
            sd=[sd QuestSd(q)];
            respAndInt(1,:,numStairsFinished)= q.intensity(1:staircaseLength);
            respAndInt(2,:,numStairsFinished)= q.response(1:staircaseLength);
            disp(sprintf('Final threshold estimate (mean +- sd) is %.2f +- %.2f\n',t(end),sd(end)));
            %if listMember==length(barPeriods)
            q=QuestCreate(StartingPoint,PerformanceSD,pThreshold,beta,delta,gamma);
            alphaLevels(condition)=QuestQuantile(q);
            if alphaLevels(condition)>maxContrasts(condition)/2;
                alphaLevels(condition)=maxContrasts(condition)/2;
            elseif alphaLevels(condition)<0
                alphaLevels(condition)=0;
            end
        end
        if whichTR==realTR
            t=[t QuestMean(q) responseCounter];
            sd=[sd QuestSd(q) responseCounter];
            t
            sd
            params.t=t;
            params.sd=sd;
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
if isfield(stimulus, 'makeMovie') && stimulus.makeMovie==1;
    aviobj = close(aviobj);
end
% correctResponses=100*(sum(params.randomIntervalBar(barPeriods)==params.psychResponse(barPeriods))./length(barPeriods));
% correctResponses2=100*(sum(sum(respAndInt(2,:,:)))/(numStairsFinished*staircaseLength));
% disp(sprintf('[%s]:Bar psychophysics whole task percentage correct: %f' ,mfilename, correctResponses));
% disp(sprintf('[%s]:Bar psychophysics task finished staircases only percentage correct: %f' ,mfilename, correctResponses2));

% that's it
ShowCursor;
timing = GetSecs-t0;
fprintf('[%s]:Stimulus run time: %f seconds [should be: %f].\n',mfilename,timing,max(stimulus.seqtiming));

% t=QuestMean(q);		
% sd=QuestSd(q);
if responseCounter>=25
% disp(sprintf('Final threshold estimate (mean +- sd) is %.2f +- %.2f\n',mean(t(1:end-1)),mean(sd(1:end-1))));
else
%     disp(sprintf('Final threshold estimate (mean +- sd) is %.2f +- %.2f\n',mean(t(1:end-2)),mean(sd(1:end-2))));
end
%disp(sprintf('Final performance is %.0f correct responses out of %.0f trials, %.2f%% correct\n',sum(Responses),trialCounter, sum(Responses)/trialCounter));
%disp(sprintf('Mean reaction time %.3f s', mean(RT(RT~=0))));

if eyeTracker==1;
    success = 'EYL_RECORDING_COMPLETE';
    EYELINK('message', 'Stimulus Started');
    Eyelink('StopRecording');
end

save([subject typeExp num2str(n) datestr(now)],'t','sd','respAndInt');
return;
