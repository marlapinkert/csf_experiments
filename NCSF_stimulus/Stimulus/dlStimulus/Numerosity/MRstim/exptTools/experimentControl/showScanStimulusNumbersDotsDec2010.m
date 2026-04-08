function [response, timing, quitProg, stimulus] = showScanStimulusNumbersDots(display, params, t0)
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

% some variables
windowPositions = params.period/params.tr;%size(stimulus.seq, 3);
stimFrame       = 1./params.temporal.frequency./params.temporal.motionSteps;
framesPerPosition=params.tr/stimFrame;

seqTiming=0:params. tr:params.period*params.ncycles-params.tr;

HideCursor;
nGamma = size(params.display.gammaTable,3);
response.keyCode = zeros(framesPerPosition*windowPositions,1); % get 1 buttons max 
response.secs = zeros(framesPerPosition*windowPositions,1);        % timing
quitProg = 0; 

rect=Screen('Rect', display.windowPtr);
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
    aviobj = avifile('dotsMovie.avi', 'FPS', fRate);
    recordingFrames=600;%windowPositions*framesPerPosition;
end

%minCmapVal = min([params.display.stimRgbRange]);
%maxCmapVal = max([params.display.stimRgbRange]);
%stimulus.images=stimulus.images{1};

% cornerPositionX=(rand(1)*(size(stimulus.images,1)-n));
% cornerPositionY=(rand(1)*(size(stimulus.images,1)-n));
% if speedPixPerFrame==0;
%     cornerPositionX=1;
%     cornerPositionY=1;
% end

% movingFixation=0;
% movingFixationPeriod=1;     %seconds
% movingFixationAmplitude=0.1;  %degrees either side of fixation
% if movingFixation==1;
%     originalFixX=display.fixX;
%     originalFixY=display.fixY;
%     movingFixationPeriod=movingFixationPeriod*fRate;
%     movingFixationAmplitude=movingFixationAmplitude*ppd;
%     sines=linspace(0, 2*pi, movingFixationPeriod);
%     sines=sin(sines);
%     sines=sines.*movingFixationAmplitude;
%     movingFixationCounter=0;
% end

%params.equalArea = 0; %1 = on, 0 = off. Decreases dotSize with increasing amounts of dots
if params.equalArea ==1;
    dotSizeIn = 18; %30;% diameter On 7T: 215 pixels = 3 deg
    dotSizeIn = 3*(dotSizeIn/2)^2*pi;
end


dotSize = 18;
charWidth = (dotSize*2)/4.5;
charHeight=  (dotSize*2)/3;
oldTextSize = Screen('TextSize', display.windowPtr, dotSize*2);
nDotsMax=6;
nTRsPerDots=2;
%params.whichStim = 'dots';% 'dotsandnumbers' 'dots' ' numbers' 
stimColor = 'black'; % 'black' 'white' 

switch lower(stimColor);
    case {'white'}
        dotColors = [255 255 255];
    case {'black'}
        dotColors = [0 0 0];
end

dotRefresh = 0.5;
framesPerPattern = dotRefresh/stimFrame;

grayTime = 0.2;
grayFrames = grayTime/stimFrame;


% go
disp(sprintf('[%s]:Running. Hit %s to quit.',mfilename,KbName(quitProgKey)));
for cycle=1:params.ncycles;
    for winPos = 1:windowPositions;

        %     cornerPositionX=(rand(1)*(size(stimulus.images,1)-n));
        %     cornerPositionY=(rand(1)*(size(stimulus.images,1)-n));
        %     if rand(1)>0.5
        %         stimulus.orientations(winPos)=stimulus.orientations(winPos)-180;
        %     end
        
        %CALCULATES HOW MANY DOTS ARE NEEDED THIS TR
        ndots=floor((mod(winPos, nDotsMax*nTRsPerDots)+(nTRsPerDots-1))/nTRsPerDots);
        if ndots==0
            ndots=nDotsMax;
        end
        
        if params.equalArea ==1;
            dotSize = round(2*(sqrt((dotSizeIn/ndots)/pi)));
        end

        %THIS LOOP GENERATES A NEW DOT PATTERN FOR EACH TR
        dotPattern=newDotPattern(ndots,n, dotSize);


        %stimulus.orientations(winPos)
        
        
        %COPYS THE DOT PATTERN TO THE FRAME BUFFER FOR THE NUMBER OF FRAMES IN EACH TR
        for frame=1:framesPerPosition;

            Screen('FillRect', display.windowPtr, [128 128 128], rect );

            switch lower(params.whichStim)
                case {'dotsandnumbers'}
                    
                    if mod(frame,framesPerPattern)==1;
                        dotPattern=newDotPattern(ndots,n, dotSize);
                        Screen('DrawDots',display.windowPtr, double(dotPattern'), double(dotSize), double(dotColors), [display.Rect(1) display.Rect(2)],1);
                    elseif mod(frame,framesPerPattern) <= framesPerPattern - grayFrames && mod(frame,framesPerPattern)> 0;
                        Screen('DrawDots',display.windowPtr, double(dotPattern'), double(dotSize), double(dotColors), [display.Rect(1) display.Rect(2)],1);
                    else
                        Screen('DrawText', display.windowPtr, num2str(ndots), display.Rect(1)+(display.Rect(3)-display.Rect(1))/2-charWidth, display.Rect(2)+(display.Rect(4)-display.Rect(2))/2-charHeight, double(dotColors));
                    end

                case 'dots'
                    if mod(frame,framesPerPattern)==1;
                        dotPattern=newDotPattern(ndots,n, dotSize);
                        Screen('DrawDots',display.windowPtr, double(dotPattern'), double(dotSize), double(dotColors), [display.Rect(1) display.Rect(2)],1);
                    elseif mod(frame,framesPerPattern) <= framesPerPattern - grayFrames && mod(frame,framesPerPattern)> 0;
                        Screen('DrawDots',display.windowPtr, double(dotPattern'), double(dotSize), double(dotColors), [display.Rect(1) display.Rect(2)],1);
                    else
                        %Screen('DrawDots',display.windowPtr, double(dotPattern'), double(dotSize), double(dotColors), [display.Rect(1) display.Rect(2)],1);
                        %Screen('DrawText', display.windowPtr, num2str(ndots), display.Rect(1)+(display.Rect(3)-display.Rect(1))/2-charWidth, display.Rect(2)+(display.Rect(4)-display.Rect(2))/2-charHeight, double(dotColors));
                    end

                case 'numbers'
                    if mod(frame,framesPerPattern) <= framesPerPattern - grayFrames && mod(frame,framesPerPattern)> 0;
                        %                Screen('DrawDots',display.windowPtr, double(dotPattern'), double(dotSize), double(dotColors), [display.Rect(1) display.Rect(2)],1);
                        Screen('DrawText', display.windowPtr, num2str(ndots), display.Rect(1)+(display.Rect(3)-display.Rect(1))/2-charWidth, display.Rect(2)+(display.Rect(4)-display.Rect(2))/2-charHeight, double(dotColors));
                    else
                        %Screen('DrawText', display.windowPtr, num2str(ndots), display.Rect(1)+(display.Rect(3)-display.Rect(1))/2-charWidth, display.Rect(2)+(display.Rect(4)-display.Rect(2))/2-charHeight, double(dotColors));
                    end

                otherwise
                    error('unknown option');
                    %end
            end

            %Screen('DrawTexture', display.windowPtr, stimulus.textures(imgNum), stimulus.srcRect, stimulus.destRect);


            %drawFixation(display,stimulus.fixSeq(((winPos-1)*framesPerPosition)+frame));

            %CONTINUES WAITING UNTIL THE NEXT FRAME WHILE LOOKING FOR RESPONSES
            %AND OTHER INPUTS
            %waitTime =
            %(GetSecs-t0)-(stimulus.seqtiming(winPos)+(stimFrame*frame));
            waitTime = (GetSecs-t0)-(seqTiming(winPos+((cycle-1)*windowPositions))+(stimFrame*frame));
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
                [exKeyIsDown exSecs exKeyCode] = KbCheck(display.devices.keyInputInternal);
                if(exKeyIsDown)
                    if(exKeyCode(quitProgKey)),
                        quitProg = 1;
                        break;% out of while loop
                    end;
                end;

                % if there is time release cpu
                if(waitTime<-0.02),
                    WaitSecs(0.01);
                end;

                % timing
                waitTime = (GetSecs-t0)-(seqTiming(winPos+((cycle-1)*windowPositions))+(stimFrame*frame));
            end;

            %--- stop?
            if quitProg,
                disp(sprintf('[%s]:Quit signal recieved.',mfilename));
                break;
            end;

            %DRAWS CONTENTS OF THE FRAME BUFFER TO THE DISPLAY
            Screen('Flip',display.windowPtr);
        end
        %
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
    if quitProg,
        disp(sprintf('[%s]:Quit signal recieved.',mfilename));
        break;
    end;
end;
%end

% that's it
ShowCursor;
% timing = GetSecs-t0;
% disp(sprintf('[%s]:Stimulus run time: %f seconds [should be: %f].',mfilename,timing,max(stimulus.seqtiming)));

stimulus.seqtiming   = [0:(framesPerPosition*windowPositions*params.ncycles)]'.*stimFrame;
stimulus.fixSeq=ones(size(stimulus.seqtiming));

timing = GetSecs-t0;
disp(sprintf('[%s]:Stimulus run time: %f seconds [should be: %f].',mfilename,timing,max(stimulus.seqtiming)));
Screen('TextSize', display.windowPtr, oldTextSize);
end

function dotPattern=newDotPattern(ndots,n, dotSize)
    for rdots = 1:ndots;
        tempDotPattern = rand(1,2)*n;
        A = tempDotPattern(1,1);
        B = tempDotPattern(1,2);

        if rdots == 1;
            dotPattern = tempDotPattern;
        else
            recheck = 1;
            while recheck == 1;
                recheck = 0;
                for storedDots = 1:rdots-1;
                    if recheck == 0;
                        xDist = dotPattern(storedDots,1)-A;
                        yDist = dotPattern(storedDots,2)-B;
                        totalDist = sqrt(xDist^2 + yDist^2);
                        if totalDist < dotSize * 2;
                            recheck = 1;
                        end
                    end
                end


                if recheck == 0;

                    dotPattern(rdots,1) = A;
                    dotPattern(rdots,2) = B;
                else
                    tempDotPattern = rand(1,2)*n;
                    A = tempDotPattern(1,1);
                    B = tempDotPattern(1,2);
                end
            end
        end
    end
end

