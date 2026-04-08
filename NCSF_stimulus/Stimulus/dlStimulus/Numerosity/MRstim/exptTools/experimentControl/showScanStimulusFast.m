function [response, timing, quitProg] = showScanStimulus(display,stimulus, t0)
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

% some variables
nFrames = length(stimulus.seq);
HideCursor;
nGamma = size(stimulus.cmap,3);
nImages = length(stimulus.textures);
response.keyCode = zeros(length(stimulus.seq),2); % get 1 buttons max
response.secs = zeros(size(stimulus.seq));        % timing
quitProg = 0;

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

Screen('Flip',display.windowPtr);

% go
fprintf('[%s]:Running. Hit %s to quit.\n',mfilename,KbName(quitProgKey));
for frame = 2:nFrames
    
    %--- update display
    % If the sequence number is positive, draw the stimulus and the
    % fixation.  If the sequence number is negative, draw only the
    % fixation.

    if stimulus.seq(frame)>0
        % put in an image
		imgNum = mod(stimulus.seq(frame)-1,nImages)+1;
        
        if stimulus.seq(frame)~=stimulus.seq(frame-1)
            Screen('DrawTexture', display.windowPtr, stimulus.textures(imgNum), stimulus.srcRect, stimulus.destRect);
        end
        Screen('gluDisk', display.windowPtr, display.fixColorRgb(stimulus.fixSeq(frame),:), display.fixX, display.fixY, display.fixSizePixels);
        %drawFixation(display,stimulus.fixSeq(frame));
    end;
    
    %--- timing
    waitTime = (GetSecs-t0)-stimulus.seqtiming(frame);
    
    %%USEFUL FOR CHECKING FOR DROPPED FRAMES
%     if waitTime>0
%         waitTime
%     end
    
    %--- get inputs (subject or experimentor)
    while(waitTime<0),
        % Scan the UMC device for subject response
        if display.devices.UMCport==2
            [ssKeyCode,ssSecs] = deviceUMC('response_and_trigger',display.devices.UMCport);
            if any(ssKeyCode)
                response.keyCode(frame,:) = ssKeyCode;
                response.secs(frame)    = ssSecs - t0;
            end
        end
        % scan the keyboard for experimentor input
        [exKeyIsDown,tmp,exKeyCode] = KbCheck(display.devices.keyInputInternal);
        if(exKeyIsDown)
            if(exKeyCode(quitProgKey)),
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
    if stimulus.seq(frame)~=stimulus.seq(frame-1)
        Screen('Flip',display.windowPtr, 0, 2, 1);
    end

    
end

% profile viewer;
% profile off
% that's it
ShowCursor;
timing = GetSecs-t0;
fprintf('[%s]:Stimulus run time: %f seconds [should be: %f].\n',mfilename,timing,max(stimulus.seqtiming));

return;
