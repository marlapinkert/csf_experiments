function [response, timing, quitProg, params] = showScanStimulusAttentionChecksRSVP(display,params,stimulus, t0, subject, n, typeExp, tValues)
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


% you can savely remove the inputs subject, n typeExp and tValues, set the
% contrast levels manually below (variables called alphaLevel... at line 102 - 106), and
% comment out the save command at line 365.






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
params.randomIntervalFixationC=Shuffle(repmat([1 2]', (ceil(realTR/2)), 1));
params.randomIntervalFixationL=Shuffle(repmat([1 2]', (ceil(realTR/2)), 1));
params.randomIntervalFixationR=Shuffle(repmat([1 2]', (ceil(realTR/2)), 1));
params.psychResponse=zeros(realTR, 1);
barPeriods=[1:248];%1:28 49:88 109:148 169:208 229:248];

% maxContrastFixation=0.5;
% maxContrastBar = 0.5;
% meanContrastFixation=maxContrastFixation/2;
% meanContrastBar=maxContrastBar/2;

%maxContrast: Bar  Fix  Left Right
%maxContrast= [0.5 0.5 0.26 0.26];%BK, 2nd session
maxContrast= [0.5 0.5 0.6 0.6];%BK, 2nd session
%maxContrast= [0.5 0.9 0.7 0.7];%Martijn

meanContrast=maxContrast./2;
%meanContrast= [0.12 0.25 1 1];%SD, bar only

%tValues: Bar  Fix  Left Right
%tValues=[0.12 0.14 0 0]; %SD, bar only  tValues=[0.12 0.14 0 0];
%tValues=[0.11, 0.14 0.25 0.25]; %BOT/SD

%tValues=[0.11, 0.14 0.13 0.13]; %BK, 2nd session
%tValues=[0.11, 0.14 0.25 0.25]; %BK, 2nd session
%tValues=[0.09, 0.15, 0.14, 0.14]; %BK 
%tValues=[0.22, 0.43 0.34 0.34]; %MB
%tValues=[0.09 0.11 0.11 0.11]; %JB
%tValues=[0.09, 0.15, 0.25, 0.25]; %BH 
tValues=[0.09, 0.15, 0.30, 0.30]; %NM

alphaLevelFixationC= tValues(2); %Change these variables to set the contrast level of the center fixation, left fixation, right fixation and bar patterns respectively.
alphaLevelFixationL= tValues(3);
alphaLevelFixationR= tValues(4);
alphaLevelBar=tValues(1);

% alpha.bar.lower = maxContrast(1)/2 - alphaLevelBar;
% alpha.bar.upper = maxContrast(1)/2 + alphaLevelBar;
% alpha.fixationC.lower = maxContrastFixation - alphaLevelFixationC;
% alpha.fixationL.lower = maxContrastFixation - alphaLevelFixationL;
% alpha.fixationR.lower = maxContrastFixation - alphaLevelFixationR;
% alpha.fixationC.upper = maxContrastFixation + alphaLevelFixationC;
% alpha.fixationL.upper = maxContrastFixation + alphaLevelFixationL;
% alpha.fixationR.upper = maxContrastFixation + alphaLevelFixationR;

%blendBar = 1;
blendFix = 1;
eyeTracker=0;
success='';

stimulus.fixSeq=ones(size(stimulus.fixSeq));

textSize = 54;
%unicodesIn=[9650, 9632, 9644, 9679, 10006, 8902, 10033];%, 11039, 11042, 11052];
%unicodesSizesIn=round([17 15 16 17 12 21 12].*2.5);% 27 27 27 27 27 34 19];
unicodesIn=[84 65:83 85:90];
unicodesSizesIn=ones(size(unicodesIn)).*textSize;% round([17 15 16 17 12 21 12].*2.5);
Screen('TextSize', display.windowPtr, unicodesSizesIn(1));
for n=1:length(unicodesIn)
    tBounds=Screen('TextBounds',display.windowPtr,unicodesIn(n));
    uniXoffsetIn(n)=(tBounds(3)-tBounds(1))/2;
    uniYoffsetIn(n)=(tBounds(4)-tBounds(2))/2;
end
%uniXoffsetIn=ones(size(unicodesIn)).*9;%[5 4.5 5 5 4.5 6 4].*unicodesSizesIn(1)/17;
%uniYoffsetIn=ones(size(unicodesIn)).*17;%[12 10 11 12 9 17 9].*unicodesSizesIn(1)/17;
oldFont=Screen('TextFont', display.windowPtr,'Arial Unicode MS');
oldTextSize=Screen('TextSize', display.windowPtr, textSize);
Screen('Preference', 'TextRenderer', 1);
Screen('Preference', 'TextAntiAliasing', 1);

nLetters=20; %for contrast tasks, this is how often the high contrast pattern is shown
frequency=4;%6.666;
fRate=1./stimulus.seqtiming(2);
if round(fRate./frequency)==(fRate./frequency);
    frequency=fRate./frequency;
else
    frequency=round(fRate./frequency);
    disp(sprintf('[%s]:Actual RSVP frequency: %f' ,mfilename, (fRate/frequency)));
end
RSVPlist1=ceil(rand(1,ceil(nFrames./frequency)).*nLetters);
rotationAngles1=rand(size(RSVPlist1)).*360;
RSVPlist1=[repmat(RSVPlist1, [frequency 1])];% zeros(size(RSVPlist1))];
RSVPlist1=RSVPlist1(:)';
RSVPlist2=ceil(rand(1,ceil(nFrames./frequency)).*nLetters);
rotationAngles2=rand(size(RSVPlist2)).*360;
RSVPlist2=[repmat(RSVPlist2, [frequency 1])];% zeros(size(RSVPlist2))];
RSVPlist2=RSVPlist2(:)';
RSVPlist=[RSVPlist1; RSVPlist2];

rotationAngles1=[repmat(rotationAngles1, [frequency 1])];% zeros(size(RSVPlist2))];
rotationAngles2=[repmat(rotationAngles2, [frequency 1])];% zeros(size(RSVPlist2))];
rotationAngles=[rotationAngles1(:)'; rotationAngles2(:)'];



RSVPlistBlink1=[zeros(2,frequency) RSVPlist(:,1:(end-frequency))];
RSVPlistBlink2=[zeros(2,frequency*2) RSVPlist(:,1:(end-frequency*2))];
RSVPlistBlink3=[zeros(2,frequency*3) RSVPlist(:,1:(end-frequency*3))];
blinkers=RSVPlist==1 & (RSVPlistBlink1==1 | RSVPlistBlink2==1 | RSVPlistBlink3==1);

RSVPlist1=ceil(rand(1,ceil(nFrames./frequency)).*nLetters-1)+1;
RSVPlist1=[repmat(RSVPlist1, [frequency 1])];% zeros(size(RSVPlist1))];
RSVPlist1=RSVPlist1(:)';
RSVPlist2=ceil(rand(1,ceil(nFrames./frequency)).*nLetters-1)+1;
RSVPlist2=[repmat(RSVPlist2, [frequency 1])];% zeros(size(RSVPlist2))];
RSVPlist2=RSVPlist2(:)';
RSVPlistFiller=[RSVPlist1; RSVPlist2];
RSVPlist(blinkers)=RSVPlistFiller(blinkers);
respTimes=[];
responded=0;
contrastPatternCounter=1;



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
        
        drawFixation(display,stimulus.fixSeq(frame));
        
        
        %RSVP letter task
%         if RSVPlist(1,frame)>0
%             %Screen('glTranslate', display.windowPtr, display.fixX+stimulus.distFromCenter, display.fixY);
%             Screen('TextSize', display.windowPtr, unicodesSizesIn(RSVPlist(1,frame)));
%             %textWidth=Screen('TextWidth', display.windowPtr, unicodesIn(RSVPlist(1,frame))
%             Screen('DrawText', display.windowPtr, unicodesIn(RSVPlist(1,frame)), display.fixX-stimulus.distFromCenter-uniXoffsetIn(RSVPlist(1,frame)), display.fixY-uniYoffsetIn(RSVPlist(1,frame)), double([0 0 0]));
%             %Screen('glTranslate', display.windowPtr, -display.fixX+stimulus.distFromCenter, -display.fixY); 
%             Screen('TextSize', display.windowPtr, unicodesSizesIn(RSVPlist(2,frame)));
%             Screen('DrawText', display.windowPtr, unicodesIn(RSVPlist(2,frame)), display.fixX+stimulus.distFromCenter-uniXoffsetIn(RSVPlist(2,frame)), display.fixY-uniYoffsetIn(RSVPlist(2,frame)), double([0 0 0]));
%         end
        
        %RSVP contrast discrimination
        if RSVPlist(1,frame)>0
            if responded==1 && RSVPlist(1,frame)~=RSVPlist(1,frame-1)
                contrastPatternCounter=contrastPatternCounter+1;
                responded=0;
                RSVPlist(:,frame:(frame+frequency-1))=2;
            end
            Screen('gluDisk', display.windowPtr, [128 128 128], display.fixX+stimulus.distFromCenter, display.fixY, angle2pix(params.display, stimulus.sizeGludiskLR));
            Screen('gluDisk', display.windowPtr, [128 128 128], display.fixX-stimulus.distFromCenter, display.fixY, angle2pix(params.display, stimulus.sizeGludiskLR)); 
            Screen('DrawTexture', display.windowPtr, stimulus.fixationTexture(mod(contrastPatternCounter,10)+1,2), stimulus.srcFixRect,stimulus.destFixRect2, rotationAngles(1,frame));
            Screen('DrawTexture', display.windowPtr, stimulus.fixationTexture(mod(contrastPatternCounter,10)+1,3), stimulus.srcFixRect,stimulus.destFixRect3, rotationAngles(2,frame));
            if RSVPlist(1,frame)==1
                Screen('DrawTexture',display.windowPtr, stimulus.alphaTexture2, stimulus.srcFixRect,stimulus.destFixRect2, rotationAngles(1,frame), [], meanContrast(3)-alphaLevelFixationL);
            else
                Screen('DrawTexture',display.windowPtr, stimulus.alphaTexture2, stimulus.srcFixRect,stimulus.destFixRect2, rotationAngles(1,frame), [], meanContrast(3)+alphaLevelFixationL);
            end
            if RSVPlist(2,frame)==1
                Screen('DrawTexture',display.windowPtr, stimulus.alphaTexture2, stimulus.srcFixRect,stimulus.destFixRect3, rotationAngles(2,frame), [], meanContrast(4)-alphaLevelFixationR);
            else
                Screen('DrawTexture',display.windowPtr, stimulus.alphaTexture2, stimulus.srcFixRect,stimulus.destFixRect3, rotationAngles(2,frame), [], meanContrast(4)+alphaLevelFixationR);
            end
            
        end
            
            
            
            
        %Slow contrast discrimination task
%         if whichFrame <= params.StimOnFrames || (whichFrame > (params.StimOnFrames + params.ISIframes) && whichFrame <= (2*params.StimOnFrames + params.ISIframes));
%             
%             %Screen('gluDisk', display.windowPtr, [128 128 128], display.fixX,display.fixY, angle2pix(params.display, stimulus.sizeGludiskC));
%             Screen('gluDisk', display.windowPtr, [128 128 128], display.fixX+stimulus.distFromCenter, display.fixY, angle2pix(params.display, stimulus.sizeGludiskLR));
%             Screen('gluDisk', display.windowPtr, [128 128 128], display.fixX-stimulus.distFromCenter, display.fixY, angle2pix(params.display, stimulus.sizeGludiskLR));
%             try
%                 drawFixation(display,stimulus.fixSeq(frame));
%             catch
%                 frame
%             end
%             if whichFrame <= params.StimOnFrames
%                 %Screen('DrawTexture', display.windowPtr, stimulus.fixationTexture(mod(whichTR,10)+1,1), stimulus.srcFixRect,stimulus.destFixRect1, rotationAngles(1,whichTR));
%                 Screen('DrawTexture', display.windowPtr, stimulus.fixationTexture(mod(whichTR,10)+1,2), stimulus.srcFixRect,stimulus.destFixRect2, rotationAngles(3,whichTR));
%                 Screen('DrawTexture', display.windowPtr, stimulus.fixationTexture(mod(whichTR,10)+1,3), stimulus.srcFixRect,stimulus.destFixRect3, rotationAngles(5,whichTR));
%             elseif whichFrame > (params.StimOnFrames + params.ISIframes) && whichFrame <= (2*params.StimOnFrames + params.ISIframes)
%                 %Screen('DrawTexture', display.windowPtr, stimulus.fixationTexture(mod(whichTR,10)+1,1), stimulus.srcFixRect,stimulus.destFixRect1, rotationAngles(2,whichTR));
%                 Screen('DrawTexture', display.windowPtr, stimulus.fixationTexture(mod(whichTR,10)+1,2), stimulus.srcFixRect,stimulus.destFixRect2, rotationAngles(4,whichTR));
%                 Screen('DrawTexture', display.windowPtr, stimulus.fixationTexture(mod(whichTR,10)+1,3), stimulus.srcFixRect,stimulus.destFixRect3, rotationAngles(6,whichTR));
%             end
%             
%             
%             if blendFix ==1;
%                 
%                 
%                 if params.randomIntervalFixationL(whichTR) == 1
%                     if whichFrame <= params.StimOnFrames;
%                         Screen('DrawTexture', display.windowPtr, stimulus.alphaTexture2, stimulus.srcFixRect,stimulus.destFixRect2, rotationAngles(3,whichTR), [], meanContrast(3)+alphaLevelFixationL);
%                     elseif whichFrame > (params.StimOnFrames + params.ISIframes) && whichFrame <= (2*params.StimOnFrames + params.ISIframes)
%                         Screen('DrawTexture', display.windowPtr, stimulus.alphaTexture2, stimulus.srcFixRect,stimulus.destFixRect2, rotationAngles(4,whichTR), [], meanContrast(3)-alphaLevelFixationL);
%                     end
%                 elseif params.randomIntervalFixationL(whichTR)==2
%                     if whichFrame <= params.StimOnFrames;
%                         Screen('DrawTexture', display.windowPtr, stimulus.alphaTexture2, stimulus.srcFixRect,stimulus.destFixRect2, rotationAngles(3,whichTR), [], meanContrast(3)-alphaLevelFixationL);
%                     elseif whichFrame > (params.StimOnFrames + params.ISIframes) && whichFrame <= (2*params.StimOnFrames + params.ISIframes)
%                         Screen('DrawTexture', display.windowPtr, stimulus.alphaTexture2, stimulus.srcFixRect,stimulus.destFixRect2, rotationAngles(4,whichTR), [], meanContrast(3)+alphaLevelFixationL);
%                         
%                     end
%                 end
%                 
%                 
%                 if params.randomIntervalFixationR(whichTR) == 1
%                     if whichFrame <= params.StimOnFrames;
%                         Screen('DrawTexture', display.windowPtr, stimulus.alphaTexture2, stimulus.srcFixRect,stimulus.destFixRect3, rotationAngles(5,whichTR), [], meanContrast(4)+alphaLevelFixationR);
%                     elseif whichFrame > (params.StimOnFrames + params.ISIframes) && whichFrame <= (2*params.StimOnFrames + params.ISIframes)
%                         Screen('DrawTexture', display.windowPtr, stimulus.alphaTexture2, stimulus.srcFixRect,stimulus.destFixRect3, rotationAngles(6,whichTR), [], meanContrast(4)-alphaLevelFixationR);
%                     end
%                 elseif params.randomIntervalFixationR(whichTR)==2
%                     if whichFrame <= params.StimOnFrames;
%                         Screen('DrawTexture', display.windowPtr, stimulus.alphaTexture2, stimulus.srcFixRect,stimulus.destFixRect3, rotationAngles(5,whichTR), [], meanContrast(4)-alphaLevelFixationR);
%                     elseif whichFrame > (params.StimOnFrames + params.ISIframes) && whichFrame <= (2*params.StimOnFrames + params.ISIframes)
%                         Screen('DrawTexture', display.windowPtr, stimulus.alphaTexture2, stimulus.srcFixRect,stimulus.destFixRect3, rotationAngles(6,whichTR), [], meanContrast(4)+alphaLevelFixationR);
%                         
%                     end
%                     
%                 end
%             end
%         else
%             try
%                 drawFixation(display,stimulus.fixSeq(frame));
%             catch
%                 frame
%             end
%         end

        
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
            if ssKeyCode(1)==66 || ssKeyCode(1)==68 || ssKeyCode(1)==65 || ssKeyCode(1)==67
                if isempty(respTimes) || ((GetSecs-t0)-respTimes(end))>0.5
                    respTimes=[respTimes GetSecs-t0];
                    responded=1;
                end
                
            
%             if ssKeyCode(1)==66 || ssKeyCode(1)==68
%                 params.psychResponse(whichTR)=1;
%             elseif ssKeyCode(1)==65 || ssKeyCode(1)==67
%                 params.psychResponse(whichTR)=2;
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
            elseif (exKeyCode(firstKey))
                if isempty(respTimes) || ((GetSecs-t0)-respTimes(end))>0.5;
                    respTimes=[respTimes GetSecs-t0];
                    responded=1;
                end
%             elseif (exKeyCode(firstKey)) && (whichFrame>=params.StimOnFrames+params.ISIframes)
%                 params.psychResponse(whichTR)=2;
%           
%             elseif (exKeyCode(secondKey)) && (whichFrame>=params.StimOnFrames+params.ISIframes)
%                 params.psychResponse(whichTR)=1;

            end;
        end;
        
        
        
        % if there is time release cpu
        if(waitTime<-0.02),
            WaitSecs(0.01);
        end;
        
        % timing
        waitTime = (GetSecs-t0)-stimulus.seqtiming(frame);
    end;
    
    
   
    %--- stop?
    if quitProg,
        fprintf('[%s]:Quit signal recieved.\n',mfilename);
        break;
    end;

    %--- update screen
    Screen('Flip',display.windowPtr);
    
    
end

RTthreshold=1;
changeTimesL=stimulus.seqtiming(RSVPlist(1,1:frame)==1);
changeTimesR=stimulus.seqtiming(RSVPlist(2,1:frame)==1);

params.changeTimesL=changeTimesL;
params.changeTimesR=changeTimesR;
params.respTimes=respTimes;
params.frequency=frequency;

reactionTimesL=nan(size(respTimes));
reactionTimesR=nan(size(respTimes));
for n=1:length(respTimes)
    if any(changeTimesL<respTimes(n))
        reactionTimesL(n)=respTimes(n)-max(changeTimesL(changeTimesL<respTimes(n)));
%     else
%         reactionTimesL(n)=NaN;
    end
    if any(changeTimesR<respTimes(n))
        reactionTimesR(n)=respTimes(n)-max(changeTimesR(changeTimesR<respTimes(n)));
%     else
%         reactionTimesR(n)=NaN;
    end
end
reactionTimesL(reactionTimesL>RTthreshold)=NaN;
reactionTimesR(reactionTimesR>RTthreshold)=NaN;
params.correctResponsesFixationL=mean(reactionTimesL(isfinite(reactionTimesL)));
params.correctResponsesFixationR=mean(reactionTimesR(isfinite(reactionTimesR)));
disp(sprintf('[%s]:Left Fixation psychophysics mean reaction time: %f' ,mfilename, params.correctResponsesFixationL));
disp(sprintf('[%s]:Left Fixation psychophysics changes missed: %f / %f' ,mfilename, length(changeTimesL)./frequency-sum(isfinite(reactionTimesL)), length(changeTimesL)./frequency));
disp(sprintf('[%s]:Right Fixation psychophysics mean reaction time: %f' ,mfilename, params.correctResponsesFixationR));
disp(sprintf('[%s]:Right Fixation psychophysics changes missed: %f / %f' ,mfilename, length(changeTimesR)./frequency-sum(isfinite(reactionTimesR)), length(changeTimesR)./frequency));

% %correctResponsesBar=100*(sum(params.randomIntervalBar(barPeriods)==params.psychResponse(barPeriods))./length(barPeriods));
% %correctResponsesFixationC=100*(sum(params.randomIntervalFixationC(barPeriods)==params.psychResponse(barPeriods))./length(barPeriods));
% correctResponsesFixationL=100*(sum(params.randomIntervalFixationL(barPeriods)==params.psychResponse(barPeriods))./length(barPeriods));
% correctResponsesFixationR=100*(sum(params.randomIntervalFixationR(barPeriods)==params.psychResponse(barPeriods))./length(barPeriods));
% nonResponse = sum(params.psychResponse(barPeriods)==0);
% %disp(sprintf('[%s]:Bar psychophysics task percentage correct: %f' ,mfilename, correctResponsesBar));
% %disp(sprintf('[%s]:Center Fixation psychophysics task percentage correct: %f' ,mfilename, correctResponsesFixationC));
% disp(sprintf('[%s]:Left Fixation psychophysics task percentage correct: %f' ,mfilename, correctResponsesFixationL));
% disp(sprintf('[%s]:Right Fixation psychophysics task percentage correct: %f' ,mfilename, correctResponsesFixationR));
% disp(sprintf('[%s]:TRs no response given: %f' ,mfilename, nonResponse));
% %params.correctResponsesBar=correctResponsesBar;
% %params.correctResponsesFixationC=correctResponsesFixationC;
% params.correctResponsesFixationL=correctResponsesFixationL;
% params.correctResponsesFixationR=correctResponsesFixationR;
% params.nonResponse=nonResponse;
% 
% respGiven=find(params.psychResponse);
% barPeriods2=intersect(barPeriods, respGiven);
% %correctResponsesBar=100*(sum(params.randomIntervalBar(barPeriods2)==params.psychResponse(barPeriods2))./length(barPeriods2));
% %correctResponsesFixationC=100*(sum(params.randomIntervalFixationC(barPeriods2)==params.psychResponse(barPeriods2))./length(barPeriods2));
% correctResponsesFixationL=100*(sum(params.randomIntervalFixationL(barPeriods2)==params.psychResponse(barPeriods2))./length(barPeriods2));
% correctResponsesFixationR=100*(sum(params.randomIntervalFixationR(barPeriods2)==params.psychResponse(barPeriods2))./length(barPeriods2));
% %disp(sprintf('[%s]:Bar psychophysics task percentage correct of given responses: %f' ,mfilename, correctResponsesBar));
% %disp(sprintf('[%s]:Center Fixation psychophysics task percentage correct of given responses: %f' ,mfilename, correctResponsesFixationC));
% disp(sprintf('[%s]:Left Fixation psychophysics task percentage correct of given responses: %f' ,mfilename, correctResponsesFixationL));
% disp(sprintf('[%s]:Right Fixation psychophysics task percentage correct of given responses: %f' ,mfilename, correctResponsesFixationR));
% %params.correctGivenResponsesBar=correctResponsesBar;
% %params.correctGivenResponsesFixationC=correctResponsesFixationC;
% params.correctGivenResponsesFixationL=correctResponsesFixationL;
% params.correctGivenResponsesFixationR=correctResponsesFixationR;



% that's it
ShowCursor;
timing = GetSecs-t0;
fprintf('[%s]:Stimulus run time: %f seconds [should be: %f].\n',mfilename,timing,max(stimulus.seqtiming));



if eyeTracker==1;
    success = 'EYL_RECORDING_COMPLETE';
    EYELINK('message', 'Stimulus Started');
    Eyelink('StopRecording');
end
%save([subject typeExp num2str(n) datestr(now)],'correctResponsesBar','correctResponsesFixationC','correctResponsesFixationL','correctResponsesFixationR','tValues','alpha');

return;
