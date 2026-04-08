 function [response, timing, quitProg, display] = showScanStimulus(display,stimulus, t0)
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
catch
    quitProgKey = KbName('q');
end;

leftKey = KbName('LeftArrow');
rightKey = KbName('RightArrow');
upKey = KbName('UpArrow');
downKey = KbName('DownArrow');
   
% some variables
nFrames = length(stimulus.seq);
HideCursor;
nGamma = size(stimulus.cmap,3);
nImages = length(stimulus.textures);
response.keyCode = zeros(length(stimulus.seq),1); % get 1 buttons max
response.secs = zeros(size(stimulus.seq));        % timing
quitProg = 0;

screendump = 0;
display.vbl = 0;
startFrame = 100;

if isfield(stimulus, 'pictures')
    pictureCounter=0;
    nImages=nImages-length(stimulus.pictures).*2;
end

% go
disp(sprintf('[%s]:Running. Hit %s to quit.',mfilename,KbName(quitProgKey)));

% In the interleave case we want to randomly select which eye to draw first
% on each 1:nFrams 'ribbon' pass
firstEye = round(rand);

for frame = 1:nFrames
    %--- update display
    % If the sequence number is positive, draw the stimulus and the
    % fixation.  If the sequence number is negative, draw only the
    % fixation.
    % put in an image
    imgNum = mod(stimulus.seq(frame)-1,nImages)+1;
    for ii = 0:display.stereoFlag
        Screen('SelectStereoDrawBuffer', display.windowPtr, ii);
        if ii % right eye
            % angle2pix(display,.25)
            display.disparityOffset = -angle2pix(display,display.disparity/2).*display.disparityMatrix;
        else
            display.disparityOffset = angle2pix(display,display.disparity/2).*display.disparityMatrix;
        end
        %destPlusDisp = stimulus.destRect + display.disparityOffset;
        srcPlusDisp = stimulus.srcRect;% + display.disparityOffset;
        
        display.fixLeftX = display.fixX - display.horizontalOffset;
        display.fixRightX = display.fixX + display.horizontalOffset; 
        
        thisDestRect = OffsetRect(stimulus.destRect,(2*ii-1)*display.horizontalOffset,0) + display.disparityOffset;
        
        if stimulus.seq(frame)>0
            % Draw the ribbon
            if display.temporalInterleave
                if firstEye % Ugly but works for randomizing eye order
                    if mod(frame, 2)<1 % Temporal interleave at 6 frames (10 Hz at 60 Hz refresh) % if mod(frame, 20)<10 % Temporal interleave at 10 frames (6 Hz at 60 Hz refresh) % if mod(frame, 30)<15 % Temporal interleave at 15 frames (4 Hz at 60 Hz refresh)
                        if ii % Draw right eye
                            Screen('DrawTexture', display.windowPtr, stimulus.textures(imgNum), srcPlusDisp, thisDestRect, 2*(ii-.5)*display.screenRotation);
                        end
                    else
                        if ~ii % Draw left eye
                            Screen('DrawTexture', display.windowPtr, stimulus.textures(imgNum), srcPlusDisp, thisDestRect, 2*(ii-.5)*display.screenRotation);
                        end
                     end
                else
                    if ~(mod(frame, 2)<1) % Temporal interleave at 6 frames (10 Hz at 60 Hz refresh) % if mod(frame, 20)<10 % Temporal interleave at 10 frames (6 Hz at 60 Hz refresh) % if mod(frame, 30)<15 % Temporal interleave at 15 frames (4 Hz at 60 Hz refresh)
                        if ii % Draw right eye
                            Screen('DrawTexture', display.windowPtr, stimulus.textures(imgNum), srcPlusDisp, thisDestRect, 2*(ii-.5)*display.screenRotation);
                        end
                    else
                        if ~ii % Draw left eye
                            Screen('DrawTexture', display.windowPtr, stimulus.textures(imgNum), srcPlusDisp, thisDestRect, 2*(ii-.5)*display.screenRotation);
                        end
                    end
                end
            else % We are not temporally interleaving
                Screen('DrawTexture', display.windowPtr, stimulus.textures(imgNum), srcPlusDisp, thisDestRect, 2*(ii-.5)*display.screenRotation);
            end
            drawBackground(display,stimulus ,ii); % 1/f noise background
            drawFixation(display,stimulus.fixSeq(frame),ii);
         
        elseif stimulus.seq(frame)<0
            % put in a color table
            gammaNum = mod(-stimulus.seq(frame)-1,nGamma)+1;
            % The second argument is the color index.  This apparently changed
            % in recent times (07.14.2008). So, for now we set it to 1.  It may
            % be that this hsould be
            drawBackground(display,stimulus,ii); % 1/f noise background
            drawFixation(display,stimulus.fixSeq(frame));
            Screen('LoadNormalizedGammaTable', display.windowPtr, stimulus.cmap(:,:,gammaNum));
        end
    end
    
    %--- timing
    waitTime = (GetSecs-t0)-stimulus.seqtiming(frame);
    
    %--- get inputs (subject or experimentor)
    while(waitTime<0),
        % Scan the UMC device for subject response
        [ssKeyCode,ssSecs] = deviceUMC('response',display.devices.UMCport);
        
        %            kc = find(ssKeyCode);
        %            response.keyCode(frame) = kc(1); % binary response for now
        
        if ssKeyCode==65 && display.calibrate
            display.horizontalOffset = display.horizontalOffset + 5;
        elseif ssKeyCode==68 && display.calibrate
            display.horizontalOffset = display.horizontalOffset - 5;        
        elseif ssKeyCode==66 && display.calibrate
            display.screenRotation=display.screenRotation+2.25;
        elseif ssKeyCode==67 && display.calibrate
            display.screenRotation=display.screenRotation-2.25;
            
        elseif ssKeyCode==66
            display.screenRotation=display.screenRotation+0.25;
        elseif ssKeyCode==67
            display.screenRotation=display.screenRotation-0.25;            
            
        elseif(ssKeyCode(1)~=0)
            response.keyCode(frame) = ssKeyCode(end);
            response.secs(frame)    = ssSecs - t0;
        end
        
        % scan the keyboard for experimentor input
        [exKeyIsDown,exSecs,exKeyCode] = KbCheck(display.devices.keyInputInternal);
        if(exKeyIsDown)
            if exKeyCode(upKey) && display.calibrate
                display.horizontalOffset = display.horizontalOffset + 1;
            elseif exKeyCode(downKey) && display.calibrate
                display.horizontalOffset = display.horizontalOffset - 1;        
            elseif exKeyCode(leftKey) && display.calibrate
                display.screenRotation=display.screenRotation+0.25;
            elseif exKeyCode(rightKey) && display.calibrate
                display.screenRotation=display.screenRotation-0.25;

            elseif exKeyCode(leftKey)
                display.screenRotation=display.screenRotation+0.25;
            elseif exKeyCode(rightKey)
                display.screenRotation=display.screenRotation-0.25;            

            elseif exKeyCode(upKey)
                response.keyCode(frame) = 65;%ssKeyCode(end);
                response.secs(frame)    = ssSecs - t0;
            elseif exKeyCode(downKey)
                response.keyCode(frame) = 68;%ssKeyCode(end);
                response.secs(frame)    = ssSecs - t0;                
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
        disp(sprintf('[%s]:Quit signal recieved.',mfilename));
        
        % disp(sprintf('[%s]:Final screen rotation was: %f' ,mfilename, display.screenRotation));
        % save screenRotation -STRUCT display screenRotation;
        break;
    end;
    
    %--- update screen
    if screendump  %Save movie frame
        display.vbl=Screen('Flip', display.windowPtr, display.vbl+(1/30));
        %ds.vbl = ds.vbl;% + (1/30);
        %         if ~exist('iframe','var')
        %             iframe = 1;
        %         end
        
       % iframe = iframe +1;
        startFrame = startFrame + 1;
        rect = [display.viewableRect(1) display.viewableRect(2) display.viewableRect(3) display.viewableRect(4)];
        M = Screen('GetImage', display.windowPtr,rect,[],0,3);
        try
            imwrite(M,['~/Desktop/Stimulus movies/BarInDepth-RG/cyclopotopy-frame_',num2str(startFrame),'.bmp']);
        catch
            fprintf(1,'***\n***\n*** imwrite in showScanStimulus failed\n');
        end;
    else
        Screen('Flip',display.windowPtr);
    end
end;

ShowCursor;
timing = GetSecs-t0;
disp(sprintf('[%s]:Stimulus run time: %f seconds [should be: %f].',mfilename,timing,max(stimulus.seqtiming)));

return;
