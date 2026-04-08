function [response, timing, quitProg, stimulus] = showScanStimulusTiming(display, params, t0, stimulus)
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


% quit key
try 
    quitProgKey = display.quitProgKey;
catch
    quitProgKey = KbName('q');
end;
respKey=KbName('z');


% some variables
%if strcmp(params.experiment, 'Dots Scaled pRF') || strcmp(params.experiment, 'Dots Scaled pRF full blanks') || strcmp(params.experiment, 'Dots Scaled pRF short') || strcmp(params.experiment, 'Dots Scaled pRF full blanks short') || strcmp(params.experiment,'Dots Area pRF full blanks TR=1.5, nTRs=3') || strcmp(params.experiment,'Dots Size pRF full blanks TR=1.5, nTRs=3') || strcmp(params.experiment,'Dots Circumference pRF full blanks TR=1.5, nTRs=3') || strcmp(params.experiment,'Dots Dense pRF full blanks TR=1.5, nTRs=3') ||  strcmp(params.experiment,'Dots Shapes pRF full blanks TR=1.5, nTRs=3') || strcmp(params.experiment,'Dots Size pRF full blanks ECoG TR=1.5, nTRs=3')  || strcmp(params.experiment,'Dots Size pRF ECoG long random order')||strcmp(params.experiment,'One Dot Sizes pRF full blanks TR=1.5, nTRs=3') || strcmp(params.experiment,'Numbers Size pRF full blanks TR=1.5, nTRs=3') || strcmp(params.experiment,'Dots Size pRF full blanks TR=2.1, nTRs=2') || strcmp(params.experiment,'Number Symbols pRF full blanks TR=2.1, nTRs=2')
    nTRsPerDots=1;
    params.tr=params.tr*nTRsPerDots;
% else
%     nTRsPerDots=2;
%     params.tr=params.tr*nTRsPerDots;
%     nTRsPerDots=1;
% end
fps=20;
windowPositions = round(params.period/params.tr);%size(stimulus.seq, 3);
stimFrame       = 1./fps;
framesPerPosition=params.tr/stimFrame;

seqTiming=0:stimFrame:params.period*params.ncycles-stimFrame;


HideCursor;
nGamma = size(params.display.gammaTable,3);
response.keyCode = zeros(framesPerPosition*windowPositions*params.ncycles,2); % get 1 buttons max 
response.secs = zeros(framesPerPosition*windowPositions*params.ncycles,1);        % timing
quitProg = 0; 

rect=Screen('Rect', display.windowPtr);
% if strcmp(params.experiment,'Dots Size pRF full blanks ECoG TR=1.5, nTRs=3')
%     display.Rect=[475; 232; 549;306

if ~isfield(display, 'Rect');
    tmp1=round((display.numPixels(1)-display.numPixels(2))/2);
    display.Rect=[tmp1; 0; tmp1+display.numPixels(2); display.numPixels(2)];    
    n=display.numPixels(2);
else
    n=display.Rect(4)-display.Rect(2);

end

%n=display.numPixels(2);%size(stimulus.seq,1);
ppd=n./(params.radius*2);
fRate=1/stimFrame;
%speedPixPerFrame = params.stimSpeed * ppd / fRate;

stimulus.makeMovie=0;
if isfield(stimulus, 'makeMovie') && stimulus.makeMovie==1
    %aviobj = avifile('dotsMovie.avi', 'FPS', fRate);
    recordingFrames=windowPositions*framesPerPosition;
    aviobj = avifile('checkMovie.avi', 'FPS', fRate);
%     aviobjA = avifile('checkMovieA.avi', 'FPS', fRate);
%     aviobjB = avifile('checkMovieB.avi', 'FPS', fRate);
%     aviobjC = avifile('checkMovieC.avi', 'FPS', fRate);
%     aviobjD = avifile('checkMovieD.avi', 'FPS', fRate);
%     recordingFrames=recordingFrames/4;
%     movie=[];
end


recheckDist=1.5;
switch params.experiment
    case {'Timing pRF TR=2.1, Constant Event Number', 'Timing pRF TR=2.1, Duration Constant Frequency','Timing pRF TR=2.1, Constant Event Duration', 'Timing pRF TR=2.1, Event Number Constant Frequency','Timing pRF TR=2.1, Constant Set Duration'} 
        %params.equalArea=1;

            %Separate lens setup
            dotSize = params.dotSize;
            recheckDist=1.6;
            switch params.experiment
                case {'Dots Area pRF full blanks 4degree high numbers TR=2.1, nTRs=2'}
                    dotSize = params.dotSize;
                    recheckDist=1.42;
                case {'Dots Area pRF full blanks 4degree low numbers TR=2.1, nTRs=2'}
                    dotSize = params.dotSize;
                    recheckDist=1.6;
            end

        %Fixed lens setup
        if strcmp(params.calibration, '7T_UMC_1024x768FixedLens')
            dotSize=dotSize.*1.5;
        elseif strcmp(params.calibration, '7T_DLP_1600x900')
                dotSize=dotSize*0.87;
        end
        
        dotColors = [0 0 0; 255 255 255];

        params.eventDuration=repmat(params.eventDuration, [1, params.ncycles]);
        params.setsPerTR=repmat(params.setsPerTR, [1, params.ncycles]);
        params.eventNumber=repmat(params.eventNumber, [1, params.ncycles]);
        params.isi=repmat(params.isi, [1, params.ncycles]);
        params.interEventInterval=repmat(params.interEventInterval, [1, params.ncycles]);
        
        stimulus.fixResponse=ones(sum(params.setsPerTR),1);
        
        %Convert from milliseconds to seconds
        params.eventDuration=params.eventDuration./1000;
        params.isi=params.isi./1000;
        params.interEventInterval=params.interEventInterval/1000;
        params.stimTR=params.stimTR/1000;
        
        seq=logical([]);
        newSet=seq;
        if strcmp(params.experiment,'Timing pRF TR=2.1, Constant Set Duration')
            for eventCounter=1:length(params.eventDuration)
               insert=zeros([1, round(params.stimTR./stimFrame)]);
               newSet=[newSet 1 insert(2:end)];
               %insertTimes=0:stimFrame:(params.stimTR-stimFrame-params.isi);
               onTimes=1+round([0 cumsum(repmat(params.eventDuration(eventCounter),[1,params.eventNumber(eventCounter)-1])+params.interEventInterval(eventCounter))]./stimFrame);
               offTimes=1+round((cumsum(repmat(params.eventDuration(eventCounter),[1,params.eventNumber(eventCounter)])+params.interEventInterval(eventCounter))-params.interEventInterval(eventCounter))./stimFrame);
               for insertCounter=1:length(onTimes)
                  insert(onTimes(insertCounter):offTimes(insertCounter))=1; 
               end
               seq=[seq insert];
            end
        elseif strcmp(params.experiment,'Timing pRF TR=2.1, Constant Event Number')
            params.timingDrift=params.timingDrift./1000;
            params.timingDrift=repmat(params.timingDrift, [1, params.ncycles]);
            for eventCounter=1:length(params.eventDuration)
               insert=zeros([1, round((params.stimTR-params.timingDrift(eventCounter))./stimFrame)]);
               newSetInsert=insert;
               %insertTimes=0:stimFrame:(params.stimTR-stimFrame-params.isi);
               onTimes=1+round([0 cumsum(repmat(params.eventDuration(eventCounter),[1,params.setsPerTR(eventCounter)-1])+params.isi(eventCounter)/params.setsPerTR(eventCounter))]./stimFrame);
               offTimes=onTimes+round(params.eventDuration(eventCounter)./stimFrame)-1;
               for insertCounter=1:length(onTimes)
                  insert(onTimes(insertCounter):offTimes(insertCounter))=1;
                    newSetInsert(onTimes(insertCounter))=1;
               end
               seq=[seq insert];
               newSet=[newSet newSetInsert];
            end
            
        elseif strcmp(params.experiment,'Timing pRF TR=2.1, Constant Event Duration')
            params.timingDrift=params.timingDrift./1000;
            params.timingDrift=repmat(params.timingDrift, [1, params.ncycles]);
            for eventCounter=1:length(params.eventDuration)
               insert=zeros([1, round((params.stimTR-params.timingDrift(eventCounter))./stimFrame)]);
               newSetInsert=insert;
               %insertTimes=0:stimFrame:(params.stimTR-stimFrame-params.isi);
               onTimes=([0 cumsum(repmat([repmat((params.eventDuration(eventCounter)+params.interEventInterval(eventCounter)),[1,params.eventNumber(eventCounter)])], [1,params.setsPerTR(eventCounter)]))]);
               onTimes=onTimes(1:end-1);
               isiSplitCounter=0;
               for onTimesCounter=1:length(onTimes)
                   if mod(onTimesCounter-1, params.eventNumber(eventCounter))==0
                       isiSplitCounter=isiSplitCounter+1;
                       onTimes(onTimesCounter:(onTimesCounter+params.eventNumber(eventCounter)-1))=onTimes(onTimesCounter:(onTimesCounter+params.eventNumber(eventCounter)-1))+(isiSplitCounter*(params.isi(eventCounter)/params.setsPerTR(eventCounter)));
                   end
               end
               onTimes=1+round(onTimes./stimFrame);
               offTimes=onTimes+round(params.eventDuration(eventCounter)./stimFrame)-1;
               for insertCounter=1:length(onTimes)
                  insert(onTimes(insertCounter):offTimes(insertCounter))=1;
                  if mod(insertCounter-1, params.eventNumber(eventCounter))==0
                      newSetInsert(onTimes(insertCounter))=1;
                  end
               end
               trackof(eventCounter)=sum(insert);
               seq=[seq insert];
               newSet=[newSet newSetInsert];
            end
        else
            for eventCounter=1:length(params.eventDuration)
                %            seq=[seq repmat([ones([1, round(params.eventDuration(eventCounter)/stimFrame)]) zeros([1,round(params.isi/stimFrame)])], [1, params.setsPerTR(eventCounter)])];
                %            newSet=[newSet repmat([ones([1,1]) zeros(1,round((params.eventDuration(eventCounter)+params.isi)/stimFrame)-1)],[1, params.setsPerTR(eventCounter)])];
                
                seq=[seq repmat([repmat([ones([1, round(params.eventDuration(eventCounter)/stimFrame)]) zeros([1,round(params.interEventInterval(eventCounter)/stimFrame)])], [1,params.eventNumber(eventCounter)-1]) ones([1, round(params.eventDuration(eventCounter)/stimFrame)]) zeros([1,round(params.isi(eventCounter)/stimFrame)])], [1, params.setsPerTR(eventCounter)])];
                newSet=[newSet repmat([ones([1,1]) zeros(1,round((params.eventDuration(eventCounter)*params.eventNumber(eventCounter)+((params.eventNumber(eventCounter)-1)*params.interEventInterval(eventCounter))+params.isi(eventCounter))/stimFrame)-1)],[1, params.setsPerTR(eventCounter)])];
            end
        end
        
        oneBackFrequency=0.2; %actually contrast reversal frequency
%         stimulus.fixSeq=ones(sum(params.setsPerTR,1));
%         fixSeqCounter=0;
         fixSeqAdder=1;
        
        colorEvents=[];
        responses=[];

end

dotGroup=[0 0];
        
% go
disp(sprintf('[%s]:Running. Hit %s to quit.',mfilename,KbName(quitProgKey)));
if params.prescanDuration>0
    prescanFrames=round(params.prescanDuration/stimFrame);
    seqTiming=[seqTiming seqTiming(end)+cumsum(zeros(1,prescanFrames)+stimFrame)];
    seq=[seq(end-(prescanFrames-1):end) seq];
    newSet=[newSet(end-(prescanFrames-1):end) newSet];
end
seqTiming=round(seqTiming*fps)./fps;

eventCounter=0;
frameCounter=0;
newTR=0;
randTmp=0.05;

Screen('FillRect', display.windowPtr, [128 128 128], rect );

for winPos = 1:length(seqTiming);
    frameCounter=frameCounter+1;
    
    if mod(seqTiming(frameCounter), params.tr)==0
        newTR=1;
    end
        
    
    %generates new dot position if needed
    if newSet(frameCounter)==1
        if frameCounter==1
            dotGroup=newDotPattern(params, 1,n, dotSize, recheckDist);
        else
            dotGroup=newDotPattern(params, 1,n, dotSize, recheckDist, dotGroup);
        end
        
        if newTR==1
            newTR=0;
            randTmp=rand(1);
            if randTmp<oneBackFrequency && fixSeqAdder==1
                fixSeqAdder=2;%3-fixSeqAdder;
                colorEvents=[colorEvents GetSecs-t0];
            else
                fixSeqAdder=1;
            end
        else
            fixSeqAdder=1;
        end
        
    elseif frameCounter==1
        dotGroup=newDotPattern(params, 1,n, dotSize, recheckDist);
        Screen('FillRect', display.windowPtr, [128 128 128], rect);
    elseif seq(frameCounter)<seq(frameCounter-1)
        Screen('FillRect', display.windowPtr, [128 128 128], rect);
    end
    
    if seq(frameCounter)==1
        if dotSize<=62
            Screen('DrawDots',display.windowPtr, double(dotGroup'), double(dotSize), double(dotColors(fixSeqAdder,:)), [display.Rect(1) display.Rect(2)],1);
        else
            Screen('FillOval', display.windowPtr, double(dotColors(fixSeqAdder,:)), [display.Rect(1)+double(dotGroup(:,1)')-dotSize/2 display.Rect(2)+double(dotGroup(:,2)')-dotSize/2 display.Rect(1)+double(dotGroup(:,1)')+dotSize/2 display.Rect(2)+double(dotGroup(:,2)')+dotSize/2]);
        end
    end
    
    
    drawFixation(display,1);
    
    %CONTINUES WAITING UNTIL THE NEXT FRAME WHILE LOOKING FOR RESPONSES
    %AND OTHER INPUTS
    %waitTime =
    %(GetSecs-t0)-(stimulus.seqtiming(winPos)+(stimFrame*frame));
    waitTime = (GetSecs-t0)-(seqTiming(frameCounter));
    %waitTime=0;
    %--- get inputs (subject or experimentor)
    if waitTime>0
        waitTime
    end
    while(waitTime<0),
        % Scan the UMC device for subject response
        [ssKeyCode,ssSecs] = deviceUMC('response_and_trigger',display.devices.UMCport);
        if ssKeyCode(1)==65 || ssKeyCode(1)==66 || ssKeyCode(1)==67 || ssKeyCode(1)==68
            responses=[responses GetSecs-t0];
        end;
        % scan the keyboard for experimentor input
        [exKeyIsDown exSecs exKeyCode] = KbCheck(display.devices.keyInputInternal);
        if(exKeyIsDown)
            if(exKeyCode(quitProgKey)),
                quitProg = 1;
                break;% out of while loop
            elseif(exKeyCode(respKey))
                responses=[responses GetSecs-t0];
            end;
        end;
        
        % if there is time release cpu
        if(waitTime<-0.02),
            WaitSecs(0.01);
        end;
        
        % timing
        waitTime = (GetSecs-t0)-(seqTiming(frameCounter));
    end;
    
    %--- stop?
    if quitProg,
        disp(sprintf('[%s]:Quit signal recieved.',mfilename));
        break;
    end;
    
    %DRAWS CONTENTS OF THE FRAME BUFFER TO THE DISPLAY
    Screen('Flip',display.windowPtr);
    
    %
    if isfield(stimulus, 'makeMovie') && stimulus.makeMovie==1 && ((winPos-1)*framesPerPosition)+frame<=recordingFrames;
        if isfield(display, 'Rect')
            imageArray=Screen('GetImage', display.windowPtr, [512-37 269-37 512+37 269+37]);%[384 141 1024-384 538-141]);%, display.Rect);
        else
            imageArray=Screen('GetImage', display.windowPtr);
        end
        aviobj = addframe(aviobj,imageArray);
        %movie=cat(3, movie, imageArray);
        if ((winPos-1)*framesPerPosition)+frame==recordingFrames
            aviobj = close(aviobj);
            clear aviobj;
            %save('movie.mat', 'movie')
        end
        
    end
    %          if isfield(stimulus, 'makeMovie') && stimulus.makeMovie==1
    %          if ((winPos-1)*framesPerPosition)+frame<=recordingFrames;
    %             if isfield(display, 'Rect')
    %                 imageArray=Screen('GetImage', display.windowPtr);%, display.Rect);
    %             else
    %                 imageArray=Screen('GetImage', display.windowPtr);%, [256 192 768 576]);
    %             end
    %             aviobjA = addframe(aviobjA,imageArray);
    %
    %             if ((winPos-1)*framesPerPosition)+frame==recordingFrames;
    %                 aviobjA = close(aviobjA);
    %                 clear aviobjA;
    %             end
    %          elseif ((winPos-1)*framesPerPosition)+frame<=recordingFrames*2;
    %             if isfield(display, 'Rect')
    %                 imageArray=Screen('GetImage', display.windowPtr, display.Rect);
    %             else
    %                 imageArray=Screen('GetImage', display.windowPtr);%, [256 192 768 576]);
    %             end
    %             aviobjB = addframe(aviobjB,imageArray);
    %
    %             if ((winPos-1)*framesPerPosition)+frame==recordingFrames*2;
    %                 aviobjB = close(aviobjB);
    %                 clear aviobjB;
    %             end
    %          elseif ((winPos-1)*framesPerPosition)+frame<=recordingFrames*3;
    %             if isfield(display, 'Rect')
    %                 imageArray=Screen('GetImage', display.windowPtr, display.Rect);
    %             else
    %                 imageArray=Screen('GetImage', display.windowPtr);%, [256 192 768 576]);
    %             end
    %             aviobjC = addframe(aviobjC,imageArray);
    %
    %             if ((winPos-1)*framesPerPosition)+frame==recordingFrames*3;
    %                 aviobjC = close(aviobjC);
    %                 clear aviobjC;
    %             end
    %          elseif ((winPos-1)*framesPerPosition)+frame<=recordingFrames*4;
    %             if isfield(display, 'Rect')
    %                 imageArray=Screen('GetImage', display.windowPtr, display.Rect);
    %             else
    %                 imageArray=Screen('GetImage', display.windowPtr);%, [256 192 768 576]);
    %             end
    %             aviobjD = addframe(aviobjD,imageArray);
    %
    %             if ((winPos-1)*framesPerPosition)+frame==recordingFrames*4;
    %                 aviobjD = close(aviobjD);
    %                 clear aviobjD;
    %             end
    %          end
    %          end
end

% 
% if quitProg,
%     disp(sprintf('[%s]:Quit signal recieved.',mfilename));
%     break;
% end;

%end

% that's it
ShowCursor;
% timing = GetSecs-t0;
% disp(sprintf('[%s]:Stimulus run time: %f seconds [should be: %f].',mfilename,timing,max(stimulus.seqtiming)));

stimulus.seqtiming   = seqTiming;%[0:(framesPerPosition*windowPositions*params.ncycles-1)]'.*stimFrame + params.prescanDuration;
%stimulus.fixSeq=ones(size(stimulus.seqtiming));

timing = GetSecs-t0;
disp(sprintf('[%s]:Stimulus run time: %f seconds [should be: %f].',mfilename,timing,max(stimulus.seqtiming)));

% respNeeded=stimulus.fixSeq==2;
% respGiven=stimulus.fixResponse==2;
% try
%     
% if size(respNeeded, 1)<size(respGiven, 1)
%    respGiven=respGiven(1:size(respNeeded, 1));
% end
% correct=respNeeded & respGiven;
% 
% respGiven=respGiven(2:end);
% respGiven(end+1)=1;
% 
% % if size(respNeeded, 1)<size(respGiven, 1)
% %    respGiven=respGiven(1:size(respNeeded, 1));
% % end
% correctLater=respNeeded & respGiven;
% 
% correctAll=correct | correctLater;
% correctPercent=100*sum(correctAll)/sum(respNeeded);
% 
% disp(sprintf('[%s]:Task performance: %d / %d correct, %.1f%%.',mfilename,sum(correctAll),sum(respNeeded), correctPercent));
% catch
%   size(respNeeded)
%   size(respGiven)
% end

params.colorEvents=colorEvents;
params.responses=responses;
acceptedResponseTime=1.5;
count=[0 0];
for n=1:length(colorEvents)
   tmp=find(responses>colorEvents(n) & responses<(colorEvents(n)+acceptedResponseTime));
   if sum(tmp)>0,
       count(1) = count(1)+1;
       count(2) = count(2)+responses(tmp(1))-colorEvents(n);
   end
end
pc = count(1)/length(colorEvents).*100;
if count(1)>0,
    rc = count(2)/count(1);
end;

disp(sprintf('[%s]:Task performance: %d / %d correct, %.1f%%.',mfilename,count(1),length(colorEvents), pc));

end

function dotGroup=newDotPattern(params, ndots,n, dotSize, recheckDistance, oldDotPattern)
    recheckCounter=1000;
    recheck=0;
    while recheckCounter==1000
        if ~exist('oldDotPattern', 'var') || isempty(oldDotPattern)
            
            tempDotPattern = rand(1,2)*n;
            while sqrt((tempDotPattern(1,1)-0.5*n)^2+(tempDotPattern(1,2)-0.5*n)^2)>0.5*n-dotSize/2
                tempDotPattern = rand(1,2)*n;
            end
            dotGroup = tempDotPattern;
        else
            dotGroup=oldDotPattern;
        end
        
        for rdots=1:ndots
            tempDotPattern = rand(1,2)*n;
            while sqrt((tempDotPattern(1,1)-0.5*n)^2+(tempDotPattern(1,2)-0.5*n)^2)>0.5*n-dotSize/2
                tempDotPattern = rand(1,2)*n;
            end
            A = tempDotPattern(1,1);
            B = tempDotPattern(1,2);
            
            
            recheck = 1;
            recheckCounter=1;
            while recheck == 1;
                recheck = 0;
                for storedDots = 1:size(dotGroup,1);
                    if recheck == 0;
                        xDist = dotGroup(storedDots,1)-A;
                        yDist = dotGroup(storedDots,2)-B;
                        totalDist = sqrt(xDist^2 + yDist^2);
                        if totalDist < (dotSize * recheckDistance);
                            recheck = 1;
                        end
                    end
                end
                
                if recheck == 0;
                    dotGroup(rdots,1) = A;
                    dotGroup(rdots,2) = B;
                else
                    tempDotPattern = rand(1,2)*n;
                    
                    while sqrt((tempDotPattern(1,1)-0.5*n)^2+(tempDotPattern(1,2)-0.5*n)^2)>0.5*n-dotSize/2
                        tempDotPattern = rand(1,2)*n;
                    end
                    
                    A = tempDotPattern(1,1);
                    B = tempDotPattern(1,2);
                    recheckCounter=recheckCounter+1;
                    if recheckCounter==1000
                        %dotGroup(rdots,:)=dotGroup(rdots-1,:);
                        break;
                    end
                end
            end
        end
    end
end





