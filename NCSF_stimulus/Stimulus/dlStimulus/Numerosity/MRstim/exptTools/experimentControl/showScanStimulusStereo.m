function [response, timing, quitProg] = showScanStimulusStereo(display, params,stimulus, t0)
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
% try 
%     quitProgKey = display.quitProgKey;
% catch ME
    quitProgKey = KbName('q'); %#ok<NASGU>
%    rethrow(ME);
%end;
leftKey=KbName('z');
rightKey=KbName('x');

% some variables
nFrames = length(stimulus.seq);
HideCursor;
nGamma = size(stimulus.cmap,3);
nImages = length(stimulus.textures);
response.keyCode = zeros(length(stimulus.seq),2); % get 1 buttons max
qresponse.secs = zeros(size(stimulus.seq));        % timing
quitProg = 0;

%Set parameters for timing of eye changes and on-off
LeftSideFirst=1;
eyeseq=mod(stimulus.seqtiming, params.period)>=params.period./2;
if LeftSideFirst==0
    eyeseq=1-eyeseq;
end
%Set min and max on and off times is seconds (will be rounded to nearest
%frames
minOnTime=0.5;
maxOnTime=1;
minOffTime=0.2;
maxOffTime=1.5;
%Convert to frames
minOnTime=round(minOnTime*params.temporal.motionSteps);
maxOnTime=round(maxOnTime*params.temporal.motionSteps);
minOffTime=round(minOffTime*params.temporal.motionSteps);
maxOffTime=round(maxOffTime*params.temporal.motionSteps);
OnTimeRange=maxOnTime-minOnTime+1;
OffTimeRange=maxOffTime-minOffTime+1;
nextOn=floor(rand*OnTimeRange)+minOnTime;
nextOff=floor(rand*OffTimeRange)+minOffTime;
onOffBlock=[zeros(1,nextOff) ones(1, nextOn)]; 
onCounter=nextOn+nextOff;



%Setup for recording a movie
stimulus.makeMovie=0;
recordingStartFrame=0; %Where to start recording the movie. Set to zero for movie start
recordingFrames=600; %Set to nFrames for whole stimulus, or frameRate*30 for first 30 seconds sample (better for presentations)
if isfield(stimulus, 'makeMovie') && stimulus.makeMovie==1 && recordingFrames==nFrames; %If recording a movie of the whole stimulus, split the movie into 4 parts to avoid filling memory
    aviobjA = avifile('checkMovieA.avi', 'FPS', 20);
    aviobjB = avifile('checkMovieB.avi', 'FPS', 20);
    aviobjC = avifile('checkMovieC.avi', 'FPS', 20);
    aviobjD = avifile('checkMovieD.avi', 'FPS', 20);
    recordingFrames=nFrames/4;
elseif isfield(stimulus, 'makeMovie') && stimulus.makeMovie==1; %If recording a movie of a short part of the stimulus, keep it as one file
    aviobj = avifile('CheckMovie.avi', 'FPS', 20);
end

% go
fprintf('[%s]:Running. Hit %s to quit.\n',mfilename,KbName(quitProgKey));
for frame = 1:nFrames	
    
    %--- update display
    % If the sequence number is positive, draw the stimulus and the
    % fixation.  If the sequence number is negative, draw only the
    % fixation.
    imgNum = mod(stimulus.seq(frame)-1,nImages)+1;
    for ii = 0:params.display.stereoFlag
        Screen('SelectStereoDrawBuffer', params.display.windowPtr, ii);
%         if ii % right eye
%             % angle2pix(display,.25)
%             params.display.disparityOffset = -angle2pix(params.display,params.display.disparity/2).*[1 0 1 0];
%         else
%             params.display.disparityOffset = angle2pix(params.display,params.display.disparity/2).*[1 0 1 0];
%         end
        % destPlusDisp = stimulus.destRect + display.disparityOffset;
        srcPlusDisp = stimulus.srcRect;% + params.display.disparityOffset;
        if onOffBlock(onCounter)>0;
            
            if eyeseq(frame)==1 % Temporal interleave at 6 frames (10 Hz at 60 Hz refresh) % if mod(frame, 20)<10 % Temporal interleave at 10 frames (6 Hz at 60 Hz refresh) % if mod(frame, 30)<15 % Temporal interleave at 15 frames (4 Hz at 60 Hz refresh)
                if ii % Draw right eye
                    Screen('glPushMatrix', params.display.windowPtr);
                    Screen('glTranslate', params.display.windowPtr, display.fixX, display.fixY);
                    Screen('glRotate', params.display.windowPtr, 2*(ii-.5)*display.screenRotation);
                    Screen('glTranslate', params.display.windowPtr, -display.fixX, -display.fixY);
                    Screen('DrawTexture', params.display.windowPtr, stimulus.textures(imgNum), srcPlusDisp, stimulus.destRect);%, 2*(ii-.5)*display.screenRotation);
                    Screen('glPopMatrix', params.display.windowPtr);
                end
            else
                if ~ii % Draw left eye
                    Screen('glPushMatrix', params.display.windowPtr);
                    Screen('glTranslate', params.display.windowPtr, display.fixX, display.fixY);
                    Screen('glRotate', params.display.windowPtr, 2*(ii-.5)*display.screenRotation);
                    Screen('glTranslate', params.display.windowPtr, -display.fixX, -display.fixY);
                    Screen('DrawTexture', params.display.windowPtr, stimulus.textures(imgNum), srcPlusDisp, stimulus.destRect);%, 2*(ii-.5)*display.screenRotation);
                    Screen('glPopMatrix', params.display.windowPtr);
                end
            end
            
            
            if display.fusionBackground
                drawBackground(display,stimulus,ii);
            end
            drawFixation(display,stimulus.fixSeq(frame));
            
        else
            if display.fusionBackground
                drawBackground(display,stimulus,ii);
            end
            drawFixation(display,stimulus.fixSeq(frame));
        end;

    end
    onCounter=onCounter-1;
    if onCounter==0 || length(eyeseq)>frame && eyeseq(frame+1)~=eyeseq(frame)
        nextOn=floor(rand*OnTimeRange)+minOnTime;
        nextOff=floor(rand*OffTimeRange)+minOffTime;
        onOffBlock=[zeros(1,nextOff) ones(1, nextOn)];
        onCounter=nextOn+nextOff;
    end
    
    %--- timing
    waitTime = (GetSecs-t0)-stimulus.seqtiming(frame);
    
    %%USEFUL FOR CHECKING FOR DROPPED FRAMES
%     if waitTime>0
%         waitTime
%     end
    
    %--- get inputs (subject or experimentor)
    while(waitTime<0),
        % Scan the UMC device for subject response
        [ssKeyCode,ssSecs] = deviceUMC('response',display.devices.UMCport);
        
        %            kc = find(ssKeyCode);
        %            response.keyCode(frame) = kc(1); % binary response for now
        
        % BR: We want to change this code so that during the experiment
        % proper, we do not rotate the screen but use the 66/67 buttons
        % for the near/far fixation task, but how?
        if ssKeyCode==66
            display.screenRotation=display.screenRotation+3.25;
        elseif ssKeyCode==67
            display.screenRotation=display.screenRotation-3.25;
%         elseif ssKeyCode==65
%             display.screenRotation=display.screenRotation+3.25;
%         elseif ssKeyCode==68
%             display.screenRotation=display.screenRotation-3.25;
        elseif(ssKeyCode(1)~=0)
            response.keyCode(frame) = ssKeyCode(end);
            response.secs(frame)    = ssSecs - t0;
        end
        
        % scan the keyboard for experimentor input
        [exKeyIsDown,exSecs,exKeyCode] = KbCheck(display.devices.keyInputInternal);
        if(exKeyIsDown)
            if exKeyCode(leftKey)
                display.screenRotation=display.screenRotation+0.1;
            elseif exKeyCode(rightKey)
                display.screenRotation=display.screenRotation-0.1;
            elseif(exKeyCode(quitProgKey)),
                quitProg = 1;
                break; % out of while loop
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
    

    if isfield(stimulus, 'makeMovie') && stimulus.makeMovie==1 && recordingFrames==nFrames/5
        if frame<=recordingFrames;
            if isfield(display, 'Rect')
                imageArray=Screen('GetImage', display.windowPtr, display.Rect);
            else
                imageArray=Screen('GetImage', display.windowPtr);%, [256 192 768 576]);
            end
            aviobjA = addframe(aviobjA,imageArray);
            
            if frame==recordingFrames;
                aviobjA = close(aviobjA);
                clear aviobjA;
            end
         elseif frame<=recordingFrames*2;
            if isfield(display, 'Rect')
                imageArray=Screen('GetImage', display.windowPtr, display.Rect);
            else
                imageArray=Screen('GetImage', display.windowPtr);%, [256 192 768 576]);
            end
            aviobjB = addframe(aviobjB,imageArray);
            
            if frame==recordingFrames*2;
                aviobjB = close(aviobjB);
                clear aviobjB;
            end    
         elseif frame<=recordingFrames*3;
            if isfield(display, 'Rect')
                imageArray=Screen('GetImage', display.windowPtr, display.Rect);
            else
                imageArray=Screen('GetImage', display.windowPtr);%, [256 192 768 576]);
            end
            aviobjC = addframe(aviobjC,imageArray);
            
            if frame==recordingFrames*3;
                aviobjC = close(aviobjC);
                clear aviobjC;
            end 
         elseif frame<=recordingFrames*4;
            if isfield(display, 'Rect')
                imageArray=Screen('GetImage', display.windowPtr, display.Rect);
            else
                imageArray=Screen('GetImage', display.windowPtr);%, [256 192 768 576]);
            end
            aviobjD = addframe(aviobjD,imageArray);
            
            if frame==recordingFrames*4;
                aviobjD = close(aviobjD);
                clear aviobjD;
            end  
        end
    elseif isfield(stimulus, 'makeMovie') && stimulus.makeMovie==1
        if frame>recordingStartFrame && frame<=recordingStartFrame+recordingFrames
            if isfield(display, 'Rect')
                imageArray=Screen('GetImage', display.windowPtr, display.Rect);
            else
                imageArray=Screen('GetImage', display.windowPtr);%, [256 192 768 576]);
            end
            aviobj = addframe(aviobj,imageArray);
            
            if frame==recordingStartFrame+recordingFrames;
                aviobj = close(aviobj);
                clear aviobj;
            end  
        end
        
    end
    
    
end

disp(sprintf('[%s]:Final screen rotation was: %f' ,mfilename, display.screenRotation));
save /Users/lab/Documents/MATLAB/MRstim/trunk/Displays/Stereo_7T_UMC_1024x768/screenRotation.mat -STRUCT display screenRotation;

% that's it
ShowCursor;
timing = GetSecs-t0;
fprintf('[%s]:Stimulus run time: %f seconds [should be: %f].\n',mfilename,timing,max(stimulus.seqtiming));

return;
