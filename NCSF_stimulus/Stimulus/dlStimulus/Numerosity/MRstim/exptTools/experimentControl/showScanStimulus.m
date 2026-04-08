function [response, timing, quitProg, storeFlips] = showScanStimulus(display,stimulus, t0)
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
% if nargin < 3 || isempty(t0),
%     t0 = GetSecs; % "time 0" to keep timing going
% end;

 response.respframe = []; % Added for debugging. Remove when done! 281119

%stimulus.seq=ones(size(stimulus.seq)).*20;

storeFlips = zeros( 1,length(stimulus.seq) );

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


if nargin < 3 || isempty(t0)
    t0 = GetSecs; % "time 0" to keep timing going
end

% some variables
nFrames = length(stimulus.seq); % Now in terms of when the stimulus changes, not per frame anymore
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
recordingFrames=nFrames; %nFrames; %Set to nFrames for whole stimulus, or frameRate*30 for first 30 seconds sample (better for presentations)
if isfield(stimulus, 'makeMovie') && stimulus.makeMovie==1 && recordingFrames==nFrames; %If recording a movie of the whole stimulus, split the movie into 4 parts to avoid filling memory
    aviobjA = avifile('checkMovieA.avi', 'FPS', 20);
    aviobjB = avifile('checkMovieB.avi', 'FPS', 20);
     aviobjC = avifile('checkMovieC.avi', 'FPS', 20);
     aviobjD = avifile('checkMovieD.avi', 'FPS', 20);
    recordingFrames=nFrames/4;
elseif isfield(stimulus, 'makeMovie') && stimulus.makeMovie==1; %If recording a movie of a short part of the stimulus, keep it as one file
    aviobj = avifile('CheckMovie.avi', 'FPS', 30);
end

% go
fprintf('[%s]:Running. Hit %s to quit.\n',mfilename,KbName(quitProgKey));
for frame = 1:nFrames % Now in terms of timing when the stimulus changes, not in flips anymore. Solves timing and response coding issues
    
    %--- update display
    % If the sequence number is positive, draw the stimulus and the
    % fixation.  If the sequence number is negative, draw only the
    % fixation.

    if stimulus.seq(frame)>0
        % put in an image
		imgNum = mod(stimulus.seq(frame)-1,nImages)+1;
        if isfield(stimulus, 'pictures')
            if stimulus.seq(frame)==2
                if frame==1
                    pictureCounter=pictureCounter+1;
                    randomizer=round(rand(1));
                elseif stimulus.seq(frame-1)~=2
                    pictureCounter=pictureCounter+1;
                    randomizer=round(rand(1));                    
                end
                if nImages+pictureCounter>length(stimulus.textures)
                    pictureCounter=1;
                end
                if randomizer==0;
                    Screen('DrawTexture', display.windowPtr, stimulus.textures(nImages+pictureCounter), stimulus.srcRect, stimulus.destRect); 
                else
                    Screen('DrawTexture', display.windowPtr, stimulus.textures(nImages+pictureCounter+1), stimulus.srcRect, stimulus.destRect); 
                end
            elseif stimulus.seq(frame)==3
                if stimulus.seq(frame-1)~=3
                    pictureCounter=pictureCounter+1;
                end
                if randomizer==0;
                    Screen('DrawTexture', display.windowPtr, stimulus.textures(nImages+pictureCounter), stimulus.srcRect, stimulus.destRect); 
                else
                    Screen('DrawTexture', display.windowPtr, stimulus.textures(nImages+pictureCounter-1), stimulus.srcRect, stimulus.destRect); 
                end
            else
                Screen('DrawTexture', display.windowPtr, stimulus.textures(nImages), stimulus.srcRect, stimulus.destRect)
            end
        elseif isfield(stimulus, 'cmap_original')
            cmap=stimulus.cmap;
            %cmap(2:end,:)=cmap(randperm(size(cmap, 1)-1)+1,:);
            
            cmap(4:end,1)=cmap(randperm(size(cmap,1)-3)+3,1);
            cmap(4:end,2)=cmap(randperm(size(cmap,1)-3)+3,2);
            cmap(4:end,3)=cmap(randperm(size(cmap,1)-3)+3,3);
            
            Screen('FillRect', display.windowPtr, [0 0 0]);
%             Screen('LoadNormalizedGammaTable', display.windowPtr, cmap);
            Screen('DrawTexture', display.windowPtr, stimulus.textures(imgNum), stimulus.srcRect, stimulus.destRect);

            %Screen('LoadNormalizedGammaTable', display.windowPtr, stimulus.cmap_original);
        else
            Screen('DrawTexture', display.windowPtr, stimulus.textures(imgNum), stimulus.srcRect, stimulus.destRect);
        end
        drawFixation(display,stimulus.fixSeq(frame));
    elseif stimulus.seq(frame)<0
        % put in a color table
% 		gammaNum = mod(-stimulus.seq(frame)-1,nGamma)+1;
        % The second argument is the color index.  This apparently changed
        % in recent times (07.14.2008). So, for now we set it to 1.  It may
        % be that this hsould be 
        drawFixation(display,stimulus.fixSeq(frame));
% 		Screen('LoadNormalizedGammaTable', display.windowPtr, stimulus.cmap(:,:,gammaNum));
    end;
    
    %--- timing
    waitTime = (GetSecs-t0)-stimulus.seqtiming(frame); %-(2.*0.0439)% Gynormous hack! REMOVE! somehow
    response.waitTime(frame) = waitTime;
    %%USEFUL FOR CHECKING FOR DROPPED FRAMES
%     if waitTime>0
%         waitTime
%     end
    
    %--- get inputs (subject or experimentor)
    while(waitTime<0)
        % Scan the UMC device for subject response
%         [ssKeyCode,ssSecs] = deviceUMC('response_and_trigger',display.devices.UMCport);
        [ssKeyCode,ssSecs] = KbCheck(-3);
        
        if(ssKeyCode(end)~=0)
            response.keyCode(frame,:) = ssKeyCode(end); 
            response.secs(frame)    = ssSecs - t0;
            response.respframe =  [response.respframe frame]; % 281119 Added for debugging
            if ssKeyCode(end) == quitProgKey
                quitProg = 1;
                break; % out of while loop
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
        waitTime = (GetSecs-t0)-stimulus.seqtiming(frame); %-(2.*0.0439); % Gynormous hack! REMOVE! somehow
    end;
    
    %--- stop?
    if quitProg,
        fprintf('[%s]:Quit signal recieved.\n',mfilename);
        break;
    end;

    %--- update screen
     storeFlips(frame) = Screen('Flip',display.windowPtr);
    

    if isfield(stimulus, 'makeMovie') && stimulus.makeMovie==1 && recordingFrames==nFrames/4
        if frame<=recordingFrames;
            if isfield(display, 'Rect')
                imageArray=Screen('GetImage', display.windowPtr);%, display.Rect);
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
                imageArray=Screen('GetImage', display.windowPtr);%, display.Rect);
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
                imageArray=Screen('GetImage', display.windowPtr);%, display.Rect);
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
                imageArray=Screen('GetImage', display.windowPtr);%, display.Rect);
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

% that's it
ShowCursor;
timing = GetSecs-t0;
fprintf('[%s]:Stimulus run time: %f seconds [should be: %f].\n',mfilename,timing,max(stimulus.seqtiming));

return;
