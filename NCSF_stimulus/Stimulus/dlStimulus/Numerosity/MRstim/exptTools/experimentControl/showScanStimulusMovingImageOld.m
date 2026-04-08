function [response, timing, quitProg, stimulus] = showScanStimulusMovingImage(display,stimulus, params, t0)
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
catch ME
    quitProgKey = KbName('q'); %#ok<NASGU>
    rethrow(ME);
end;

% some variables
windowPositions = size(stimulus.seq, 3);
stimFrame       = 1./params.temporal.frequency./params.temporal.motionSteps;
framesPerPosition=params.tr/stimFrame;
reversalMin=0.50; %in seconds
reversalMax=0.75;
reversalMin=round(reversalMin/stimFrame);
reversalMax=round(reversalMax/stimFrame);

HideCursor;
nGamma = size(stimulus.cmap,3);
response.keyCode = zeros(framesPerPosition*windowPositions,1); % get 1 buttons max 
response.secs = zeros(framesPerPosition*windowPositions,1);        % timing
quitProg = 0; 

rect=Screen('Rect', display.windowPtr);
if ~isfield(display, 'Rect');
    tmp1=round((display.numPixels(1)-display.numPixels(2))/2);
    display.Rect=[tmp1; 0; tmp1+display.numPixels(2); display.numPixels(2)];    
end

n=size(stimulus.seq,1);
ppd=n./(params.radius*2);
fRate=1/stimFrame;
speedPixPerFrame = params.stimSpeed * ppd / fRate;

stimulus.makeMovie=0;
if isfield(stimulus, 'makeMovie') && stimulus.makeMovie==1
    aviobj = avifile('dotsMovie.avi', 'FPS', fRate);
    recordingFrames=600;%windowPositions*framesPerPosition;
end

minCmapVal = min([params.display.stimRgbRange]);
maxCmapVal = max([params.display.stimRgbRange]);
stimulus.images=stimulus.images{1};

movingFixation=0;
movingFixationPeriod=1;     %seconds
movingFixationAmplitude=0.1;  %degrees either side of fixation
if movingFixation==1;
    originalFixX=display.fixX;
    originalFixY=display.fixY;
    movingFixationPeriod=movingFixationPeriod*fRate;
    movingFixationAmplitude=movingFixationAmplitude*ppd;
    sines=linspace(0, 2*pi, movingFixationPeriod);
    sines=sin(sines);
    sines=sines.*movingFixationAmplitude;
    movingFixationCounter=0;
end

cornerPositions=params.cornerPositions;
% go
disp(sprintf('[%s]:Running. Hit %s to quit.',mfilename,KbName(quitProgKey)));
for winPos = 1:windowPositions
    
%     cornerPositionX=(rand(1)*(size(stimulus.images,1)-n));
%     cornerPositionY=(rand(1)*(size(stimulus.images,1)-n));
%     if rand(1)>0.5
%         stimulus.orientations(winPos)=stimulus.orientations(winPos)-180; 
%     end
    %stimulus.orientations(winPos)
    for frame=1:framesPerPosition;
         
        imageToPut=stimulus.images(round(cornerPositions(winPos, frame, 1)):round(cornerPositions(winPos, frame, 1))+n-1, round(cornerPositions(winPos, frame, 2)):round(cornerPositions(winPos, frame, 2))+n-1);

        imageToPut(stimulus.seq(:,:,winPos)==0)=128;
        
        Screen('FillRect', display.windowPtr, display.backColorRgb );
        Screen('PutImage',display.windowPtr, imageToPut, display.Rect);

        
        %Screen('DrawTexture', display.windowPtr, stimulus.textures(imgNum), stimulus.srcRect, stimulus.destRect);
        
        
        %%Code for moving fixation. Removed for speed
%         if movingFixation==1;
%             movingFixationCounter=movingFixationCounter+1;
%             if movingFixationCounter==length(sines)+1
%                 movingFixationCounter=1;
%             end
%             display.fixX=round(originalFixX+sines(movingFixationCounter));
%         end
            
        drawFixation(display,stimulus.fixSeq(((winPos-1)*framesPerPosition)+frame));
        %     elseif stimulus.seq(frame)<0
        %         % put in a color table
        % 		gammaNum = mod(-stimulus.seq(frame)-1,nGamma)+1;
        %         % The second argument is the color index.  This apparently changed
        %         % in recent times (07.14.2008). So, for now we set it to 1.  It may
        %         % be that this hsould be
        %         drawFixation(display,stimulus.fixSeq(frame));
        % 		Screen('LoadNormalizedGammaTable', display.windowPtr, stimulus.cmap(:,:,gammaNum));
        %     end;
        
        %--- timing
        waitTime = (GetSecs-t0)-(stimulus.seqtiming(winPos)+(stimFrame*frame))
        
        %--- get inputs (subject or experimentor)
        while(waitTime<0),
            % Scan the UMC device for subject response
            [ssKeyCode,ssSecs] = deviceUMC('response',display.devices.UMCport);
            if(ssKeyCode(1)~=0)
                %            kc = find(ssKeyCode);
                %            response.keyCode(frame) = kc(1); % binary response for now
                response.keyCode(frame) = ssKeyCode(end);
                response.secs(frame)    = ssSecs - t0;
            end;
            % scan the keyboard for experimentor input
            [exKeyIsDown,~,exKeyCode] = KbCheck(display.devices.keyInputInternal);
            if(exKeyIsDown)
                if(exKeyCode(quitProgKey)),
                    quitProg = 1;
                    break;
                end;
            end;
            
            % if there is time release cpu
            if(waitTime<-0.02),
                WaitSecs(0.01);
            end;
            
            % timing
            waitTime = (GetSecs-t0)-(stimulus.seqtiming(winPos)+(stimFrame*frame));
        end;
        
        %--- stop?
        if quitProg,
            fprintf(sprintf('[%s]:Quit signal recieved.',mfilename));
            break;
        end;
        
        %--- update screen
        Screen('Flip',display.windowPtr);
           
        %%Code to make movie output. Commented out for speed
%         if isfield(stimulus, 'makeMovie') && stimulus.makeMovie==1 && ((winPos-1)*framesPerPosition)+frame<=recordingFrames;
%             if isfield(display, 'Rect')
%                 imageArray=Screen('GetImage', display.windowPtr, display.Rect);
%             else
%                 imageArray=Screen('GetImage', display.windowPtr);
%             end
%             aviobj = addframe(aviobj,imageArray);
%             if ((winPos-1)*framesPerPosition)+frame==recordingFrames
%                 aviobj = close(aviobj);
%             end
%         end

        %     if frame==200
        %         save 'dotimg.mat' imageArray
        %     end
    end

end;

% that's it
ShowCursor;
timing = GetSecs-t0;
fprintf(sprintf('[%s]:Stimulus run time: %f seconds [should be: %f].',mfilename,timing,max(stimulus.seqtiming)));

stimulus.seqtiming   = [0:(framesPerPosition*windowPositions)]'.*stimFrame;

return;
