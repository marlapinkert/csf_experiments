function [response, timing, quitProg, stimulus] = showScanStimulusNumbersDotsShapes(display, params, t0, stimulus)
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
if strcmp(params.experiment, 'Dots Scaled pRF') || strcmp(params.experiment, 'Dots Scaled pRF full blanks') || strcmp(params.experiment, 'Dots Scaled pRF short') || strcmp(params.experiment, 'Dots Scaled pRF full blanks short') || strcmp(params.experiment,'Dots Area pRF full blanks TR=1.5, nTRs=3') || strcmp(params.experiment,'Dots Size pRF full blanks TR=1.5, nTRs=3') || strcmp(params.experiment,'Dots Circumference pRF full blanks TR=1.5, nTRs=3') || strcmp(params.experiment,'Dots Dense pRF full blanks TR=1.5, nTRs=3') || strcmp(params.experiment,'Dots Scaled pRF full blanks TR=2, nTRs=2') || strcmp(params.experiment,'Dots Shapes pRF full blanks TR=1.5, nTRs=3')
    nTRsPerDots=1;
    params.tr=params.tr*nTRsPerDots;
else
    nTRsPerDots=2;
    params.tr=params.tr*nTRsPerDots;
    nTRsPerDots=1;
end
windowPositions = params.period/params.tr;%size(stimulus.seq, 3);
stimFrame       = 1./params.temporal.frequency./params.temporal.motionSteps;
framesPerPosition=params.tr/stimFrame;


seqTiming=0:params.tr:params.period*params.ncycles-params.tr;

HideCursor;
nGamma = size(params.display.gammaTable,3);
response.keyCode = zeros(framesPerPosition*windowPositions*params.ncycles,2); % get 1 buttons max 
response.secs = zeros(framesPerPosition*windowPositions*params.ncycles,1);        % timing
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
    recordingFrames=720;%windowPositions*framesPerPosition;
end


recheckDist=1.5;
switch params.experiment
    case {'Dots Scaled pRF', 'Dots Scaled pRF full blanks'}
        dotSize = 8;
        dotColors = [0 0 0; 255 255 255];
        dotRefresh = 1;
        grayTime = 0.7;
        oneBackFrequency=0.1; %actually contrast reversal frequency
        stimulus.fixSeq=zeros(framesPerPosition*windowPositions*params.ncycles,1);
        fixSeqCounter=0;
        fixSeqAdder=1;
        
    case {'Dots Scaled pRF short', 'Dots Scaled pRF full blanks short', 'Dots Area pRF full blanks TR=1.5, nTRs=3','Dots Size pRF full blanks TR=1.5, nTRs=3','Dots Circumference pRF full blanks TR=1.5, nTRs=3', 'Dots Dense pRF full blanks TR=1.5, nTRs=3', 'Dots Shapes pRF full blanks TR=1.5, nTRs=3'}
        if params.equalArea ==1;
            dotSize = 8;
            recheckDist=3;
        elseif params.equalArea==2
            dotSize = 21;
            recheckDist=3;
        elseif params.equalArea ==3;
            dotSize = 8;
            recheckDist=1.2 ;
        else
            dotSize = 8;
            recheckDist=1.4;
        end
        dotColors = [0 0 0; 255 255 255];
        dotRefresh = 0.75;
        grayTime = 0.45;
        oneBackFrequency=0.1; %actually contrast reversal frequency
        stimulus.fixSeq=ones(params.tr/dotRefresh*windowPositions*params.ncycles,1);
        fixSeqCounter=0;
        fixSeqAdder=1;
        
        stimulus.fixResponse=ones(params.tr/dotRefresh*windowPositions*params.ncycles, 1);

    case {'Dots In Noise pRF full blanks TR=1.5, nTRs=3'}
        if params.equalArea ==1;
            dotSize = 8;
            recheckDist=3;
        elseif params.equalArea==2
            dotSize = 21;
            recheckDist=3;
        elseif params.equalArea ==3;
            dotSize = 8;
            recheckDist=1.2 ;
        else
            dotSize = 8;
            recheckDist=1.4;
        end
        dotColors = [128 128 128; 104 104 104; 152 152 152];
        dotRefresh = 0.75;
        grayTime = 0.45;
        oneBackFrequency=0.1; %actually contrast reversal frequency
        stimulus.fixSeq=ones(params.tr/dotRefresh*windowPositions*params.ncycles,1);
        fixSeqCounter=0;
        fixSeqAdder=1;
        
        stimulus.fixResponse=ones(params.tr/dotRefresh*windowPositions*params.ncycles, 1);
        
    case {'Dots Scaled pRF full blanks TR=2, nTRs=2'}
        if params.equalArea ==1;
            dotSize = 8;
            recheckDist=3;
        elseif params.equalArea==2
            dotSize = 21;
            recheckDist=3;
        else
            dotSize = 8;
        end
        dotColors = [0 0 0; 255 255 255];
        dotRefresh = 0.80;
        grayTime = 0.50;
        oneBackFrequency=0.1; %actually contrast reversal frequency
        stimulus.fixSeq=zeros(framesPerPosition*windowPositions*params.ncycles,1);
        fixSeqCounter=0;
        fixSeqAdder=1;
        
    otherwise
        dotSize = 18;
        dotColors = [0 0 0; 255 255 255];
        dotRefresh = 0.5;
        grayTime = 0.2;
        oneBackFrequency=0.05;%0.05;
        stimulus.fixSeq=zeros(framesPerPosition*windowPositions*params.ncycles,1);
        fixSeqCounter=0;
        fixSeqAdder=1;
end
nDotsMax=6;
textSize = 27;
charWidth = (dotSize*2)/4.5;
charHeight=  (dotSize*2)/3;

framesPerPattern = dotRefresh/stimFrame;
framesOn=(dotRefresh-grayTime)/stimFrame;
grayFrames = grayTime/stimFrame;
%params.whichStim = 'dots';% 'dotsandnumbers' 'dots' ' numbers'

%Normalized dot size, on which others are based to keep area or
%circumference equal. 
if params.equalArea ==1 || params.equalArea==3;
    dotSizeIn = 3*(dotSize/2)^2*pi;
elseif params.equalArea==2
    dotSizeIn = dotSize*pi*3;
end

if strcmp(params.experiment,'Dots Shapes pRF full blanks TR=1.5, nTRs=3')
    unicodesIn=[9650, 9632, 9644, 9679, 10006, 8902, 10033];%, 11039, 11042, 11052];
    unicodesSizesIn=[17 15 16 17 12 21 12];% 27 27 27 27 27 34 19];
    uniXoffsetIn=[5 4.5 5 5 4.5 6 4];
    uniYoffsetIn=[12 10 11 12 9 17 9];
    oldFont=Screen('TextFont', display.windowPtr,'Arial Unicode MS');
    oldTextSize=Screen('TextSize', display.windowPtr, textSize);
    Screen('Preference', 'TextRenderer', 1);
    Screen('Preference', 'TextAntiAliasing', 1);
end

lastNumberBlank=false;

% go
disp(sprintf('[%s]:Running. Hit %s to quit.',mfilename,KbName(quitProgKey)));
if params.prescanDuration>0
    for winPos=1:params.prescanDuration/params.tr
        cycle=1;
        ndots=params.dotOrder(end);
        if params.equalArea ==1 && ndots>0;
            dotSize =(2*(sqrt((dotSizeIn/ndots)/pi)));
        elseif params.equalArea ==3 && ndots>0;
            dotSize =(2*(sqrt((dotSizeIn/ndots)/pi)));
        elseif params.equalArea ==2 && ndots>0;
            dotSize = dotSizeIn/ndots/pi;
        end
        if params.equalArea==3
            dotGroup=newDotPatternDense(ndots,n, dotSize, recheckDist);
        else
            dotGroup=newDotPattern(params, ndots,n, dotSize, recheckDist);
        end

        DrawTheDots;
    end
    seqTiming=seqTiming+params.prescanDuration;
end
for cycle=1:params.ncycles;
    for winPos = 1:windowPositions;

        
        ndots=params.dotOrder(winPos);
        
        %useful for testing, as we can examine the interaction between dot
        %size and random placement
        %ndots=6;
        %ndots=ceil(rand(1)*6);
        %ndots=round(rand(1))+5;
        
        if params.equalArea ==1;
            dotSize =(2*(sqrt((dotSizeIn/ndots)/pi)));
            if ndots==2 
                recheckDist=5;
            elseif ndots==3 
                recheckDist=5;
            elseif ndots==4
                recheckDist=4.8;
            elseif ndots==5
                recheckDist=4.5;
            elseif ndots==6
                recheckDist=4.2;
            elseif ndots==7
                recheckDist=4;
            else
                recheckDist=3;
            end
%             tic;
%             dotGroup=newDotPattern(params, ndots,n, dotSize, recheckDist)
%             toc
        elseif params.equalArea ==2;
            dotSize = dotSizeIn/ndots/pi;
            if ndots==2 
                recheckDist=1.15;
            elseif ndots==3 
                recheckDist=1.5;
            elseif ndots==4
                recheckDist=1.9;
            elseif ndots==5
                recheckDist=2.1;
            elseif ndots==6
                recheckDist=2.3;
            elseif ndots==7
                recheckDist=2.5;
            else
                recheckDist=3;
            end
        elseif params.equalArea ==0;
             if ndots==2 
                recheckDist=6;
            elseif ndots==3 
                recheckDist=5;
            elseif ndots==4
                recheckDist=4;
            elseif ndots==5
                recheckDist=3.5;
            elseif ndots==6
                recheckDist=3;
            elseif ndots==7
                recheckDist=2.8;
            else
                recheckDist=1.4;
             end     
        elseif params.equalArea ==3;
            dotSize =(2*(sqrt((dotSizeIn/ndots)/pi)));
            if ndots==2 
                recheckDist=1.15;%2.5 at n=n/2;
            elseif ndots==3 
                recheckDist=1.15;%2.2
            elseif ndots==4
                recheckDist=1.15;%2
            elseif ndots==5
                recheckDist=1.2;%2
            elseif ndots==6
                recheckDist=1.2;%2
            elseif ndots==7
                recheckDist=1.2;%2
            else
                recheckDist=1.2;%2
            end
%             tic;
%             dotGroup=newDotPatternDense(ndots,n, dotSize, recheckDist)
%             toc
        end

%         %THIS LOOP GENERATES A NEW DOT PATTERN FOR EACH TR
%         if params.equalArea==3
%             dotGroup=newDotPatternDense(ndots,n, dotSize, recheckDist);
%         else
%             dotGroup=newDotPattern(params, ndots,n, dotSize, recheckDist);%2);
%         end


        %stimulus.orientations(winPos)
        
        
        %COPYS THE DOT PATTERN TO THE FRAME BUFFER FOR THE NUMBER OF FRAMES IN EACH TR
        for frame=1:framesPerPosition;
            if strcmp(params.experiment, 'Dots In Noise pRF full blanks TR=1.5, nTRs=3')
                Screen('DrawTexture', display.windowPtr, stimulus.texturesBG(1));%mod(ceil(((((winPos-1)+((cycle-1)*windowPositions))*framesPerPosition)+frame-framesOn)/framesPerPattern),10)+1));%,[],rect); 
            else
                Screen('FillRect', display.windowPtr, [128 128 128], rect );
            end
            %ndots=ceil(rand(1)*6);
            
            %switch lower(params.whichStim)
            
            %case 'dots'
            if ndots>0
                
                %Generates new dot patterns when refresh is needed
                if uint8(mod(frame,framesPerPattern))==1;
                    fixSeqCounter=fixSeqCounter+1;
                    if params.equalArea==3
                        dotGroup=newDotPatternDense(ndots,n, dotSize, recheckDist);
                    else
                        %dotGroup=[37 5; 37 15; 37 25; 37 35; 37 45; 37 55; 37 65];
                        dotGroup=newDotPattern(params, ndots,n, dotSize, recheckDist);%2);
                    end
                    randTmp=rand(1);
                    if randTmp<oneBackFrequency && fixSeqAdder==1
                        fixSeqAdder=2;%3-fixSeqAdder;
                        stimulus.fixSeq(fixSeqCounter)=fixSeqAdder;
                    else
                        fixSeqAdder=1;
                    end
                    if strcmp(params.experiment,'Dots Shapes pRF full blanks TR=1.5, nTRs=3')
                        %ndots=7; %For testing
                        if ndots<8
                            [unicodes, index]=shuffle(unicodesIn);
                            unicodesSizes=unicodesSizesIn(index);
                            uniXoffset=uniXoffsetIn(index);
                            uniYoffset=uniYoffsetIn(index);
                            
%                             unicodes=unicodesIn;
%                             unicodesSizes=unicodesSizesIn;
%                             uniXoffset=uniXoffsetIn;
%                             uniYoffset=uniYoffsetIn;
                            
                        else
                            [unicodes, index]=shuffle([unicodesIn unicodesIn unicodesIn]);
                            tmp=[unicodesSizesIn unicodesSizesIn unicodesSizesIn];
                            unicodesSizes=tmp(index);
                            tmp=[uniXoffsetIn uniXoffsetIn uniXoffsetIn];
                            uniXoffset=tmp(index);
                            tmp=[uniYoffsetIn uniYoffsetIn uniYoffsetIn];
                            uniYoffset=tmp(index);
                        end
                        uniAngles=floor(rand(ndots,1).*4).*90;     %ones(ndots,1).*45; %                   
                        for shapeCounter=1:ndots
                            Screen('glTranslate', display.windowPtr, dotGroup(shapeCounter,1)+display.Rect(1), dotGroup(shapeCounter,2)+display.Rect(2));
                            Screen('glRotate', display.windowPtr, uniAngles(shapeCounter));
                            Screen('TextSize', display.windowPtr, unicodesSizes(shapeCounter));
                            Screen('DrawText', display.windowPtr, unicodes(shapeCounter), -uniXoffset(shapeCounter), -uniYoffset(shapeCounter), double(dotColors(fixSeqAdder,:)));
                            Screen('glRotate', display.windowPtr, 0-uniAngles(shapeCounter));
                            Screen('glTranslate', display.windowPtr, -(dotGroup(shapeCounter,1)+display.Rect(1)), -(dotGroup(shapeCounter,2)+display.Rect(2)));                 
                        end
                        %Screen('DrawDots',display.windowPtr, double(dotGroup'), 8, [255 255 255], [display.Rect(1) display.Rect(2)],1);
                    else
                        Screen('DrawDots',display.windowPtr, double(dotGroup'), double(dotSize), double(dotColors(fixSeqAdder,:)), [display.Rect(1) display.Rect(2)],1);
                    end
                elseif uint8(mod(frame,framesPerPattern)) <= framesPerPattern - grayFrames && mod(frame,framesPerPattern)> 0;
                    if strcmp(params.experiment,'Dots Shapes pRF full blanks TR=1.5, nTRs=3')
                        %Screen('DrawDots',display.windowPtr, double(dotGroup'), 8, [255 255 255], [display.Rect(1) display.Rect(2)],1); 
                        for shapeCounter=1:ndots
                            Screen('glTranslate', display.windowPtr, dotGroup(shapeCounter,1)+display.Rect(1), dotGroup(shapeCounter,2)+display.Rect(2));
                            Screen('glRotate', display.windowPtr, uniAngles(shapeCounter));
                            Screen('TextSize', display.windowPtr, unicodesSizes(shapeCounter));
                            Screen('DrawText', display.windowPtr, unicodes(shapeCounter), -uniXoffset(shapeCounter), -uniYoffset(shapeCounter), double(dotColors(fixSeqAdder,:)));
                            Screen('glRotate', display.windowPtr, 0-uniAngles(shapeCounter));
                            Screen('glTranslate', display.windowPtr, -(dotGroup(shapeCounter,1)+display.Rect(1)), -(dotGroup(shapeCounter,2)+display.Rect(2)));                 
                        end

                    else
                        Screen('DrawDots',display.windowPtr, double(dotGroup'), double(dotSize), double(dotColors(fixSeqAdder,:)), [display.Rect(1) display.Rect(2)],1);
                    end
                end
            else
                if uint8(mod(frame,framesPerPattern))==1;
                    fixSeqCounter=fixSeqCounter+1;
                end
            end
                        
            drawFixation(display,1);

            %CONTINUES WAITING UNTIL THE NEXT FRAME WHILE LOOKING FOR RESPONSES
            %AND OTHER INPUTS
            %waitTime =
            %(GetSecs-t0)-(stimulus.seqtiming(winPos)+(stimFrame*frame));
            waitTime = (GetSecs-t0)-(seqTiming(winPos+((cycle-1)*windowPositions))+(stimFrame*frame));
            %--- get inputs (subject or experimentor)
            if waitTime>0
                waitTime
                ndots
            end
            while(waitTime<0),
                % Scan the UMC device for subject response
                [ssKeyCode,ssSecs] = deviceUMC('response_and_trigger',display.devices.UMCport);
                if ssKeyCode(1)==65 || ssKeyCode(1)==66 || ssKeyCode(1)==67 || ssKeyCode(1)==68
                        stimulus.fixResponse(fixSeqCounter)=2;
                end;
                % scan the keyboard for experimentor input
                [exKeyIsDown exSecs exKeyCode] = KbCheck(display.devices.keyInputInternal);
                if(exKeyIsDown)
                    if(exKeyCode(quitProgKey)),
                        quitProg = 1;
                        break;% out of while loop
                    elseif(exKeyCode(respKey))
                        stimulus.fixResponse(fixSeqCounter)=2;
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
        
        %
                if isfield(stimulus, 'makeMovie') && stimulus.makeMovie==1 && ((winPos-1)*framesPerPosition)+frame<=recordingFrames;
                    if isfield(display, 'Rect')
                        imageArray=Screen('GetImage', display.windowPtr, display.Rect);
                    else
                        imageArray=Screen('GetImage', display.windowPtr);
                    end
                    aviobj = addframe(aviobj,imageArray);
                    if ((winPos-1)*framesPerPosition)+frame==recordingFrames
                        aviobj = close(aviobj);
                    end

                end
        end

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

stimulus.seqtiming   = [0:(framesPerPosition*windowPositions*params.ncycles-1)]'.*stimFrame + params.prescanDuration;
%stimulus.fixSeq=ones(size(stimulus.seqtiming));

timing = GetSecs-t0;
disp(sprintf('[%s]:Stimulus run time: %f seconds [should be: %f].',mfilename,timing,max(stimulus.seqtiming)));

respNeeded=stimulus.fixSeq==2;
respGiven=stimulus.fixResponse==2;
correct=respNeeded & respGiven;

respGiven=respGiven(2:end);
respGiven(end+1)=1;
correctLater=respNeeded & respGiven;

correctAll=correct | correctLater;
correctPercent=100*sum(correctAll)/sum(respNeeded);

disp(sprintf('[%s]:Task performance: %d / %d correct, %.1f%%.',mfilename,sum(correctAll),sum(respNeeded), correctPercent));

if strcmp(params.experiment,'Dots Shapes pRF full blanks TR=1.5, nTRs=3')
    Screen('TextSize', display.windowPtr, oldTextSize);
    Screen('TextFont', display.windowPtr, oldFont);
end
end

function dotGroup=newDotPattern(params, ndots,n, dotSize, recheckDistance)
if ndots >0;
    recheckCounter=1000;
    while recheckCounter==1000
    for rdots = 1:ndots;
        tempDotPattern = rand(1,2)*n;
        if strcmp(params.experiment, 'Dots Gaussian')
            while sqrt((tempDotPattern(1,1)-0.5*n)^2+(tempDotPattern(1,2)-0.5*n)^2)>0.5*n-dotSize/2 || sqrt((tempDotPattern(1,1)-0.5*n)^2+(tempDotPattern(1,2)-0.5*n)^2)<0.125*n+dotSize/2
                tempDotPattern = rand(1,2)*n;
            end
        else
            while sqrt((tempDotPattern(1,1)-0.5*n)^2+(tempDotPattern(1,2)-0.5*n)^2)>0.5*n-dotSize/2
                tempDotPattern = rand(1,2)*n;
            end
        end
        A = tempDotPattern(1,1);
        B = tempDotPattern(1,2);


        if rdots == 1;
            dotGroup = tempDotPattern;
            recheckCounter=1;
        else
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
                    if strcmp(params.experiment, 'Dots Gaussian')
                        while sqrt((tempDotPattern(1,1)-0.5*n)^2+(tempDotPattern(1,2)-0.5*n)^2)>0.5*n-dotSize/2 || sqrt((tempDotPattern(1,1)-0.5*n)^2+(tempDotPattern(1,2)-0.5*n)^2)<0.125*n+dotSize/2
                            tempDotPattern = rand(1,2)*n;
                        end
                    else
                        while sqrt((tempDotPattern(1,1)-0.5*n)^2+(tempDotPattern(1,2)-0.5*n)^2)>0.5*n-dotSize/2
                            tempDotPattern = rand(1,2)*n;
                        end

                    end
                    A = tempDotPattern(1,1);
                    B = tempDotPattern(1,2);
                    recheckCounter=recheckCounter+1;
                    if recheckCounter==1000
                        dotGroup(rdots,:)=dotGroup(rdots-1,:);
                        break;
                    end
                end
            end
        end
    end
    end
else dotGroup = [];
end

end

function dotGroup=newDotPatternDense(ndots, n, dotSize, recheckDistance)

newn=n/3;
center=rand(1,2)*(n-newn)+newn/2;
while sqrt((center(1,1)-0.5*n)^2+(center(1,2)-0.5*n)^2)>0.5*(n-newn)-dotSize/2
    center = rand(1,2)*(n-newn)+newn/2;
end
n=newn;
if ndots >0;
    recheckCounter=1000;
    while recheckCounter==1000
    for rdots = 1:ndots;
        tempDotPattern = rand(1,2)*n+center-[n/2, n/2];

        while sqrt((tempDotPattern(1,1)-center(1))^2+(tempDotPattern(1,2)-center(2))^2)>0.5*n-dotSize/2
            tempDotPattern = rand(1,2)*n+center-[n/2, n/2];
        end
        A = tempDotPattern(1,1);
        B = tempDotPattern(1,2);


        if rdots == 1;
            dotGroup = tempDotPattern;
            recheckCounter=1;
        else
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
                    
                    while sqrt((tempDotPattern(1,1)-center(1))^2+(tempDotPattern(1,2)-center(2))^2)>0.5*n-dotSize/2
                        tempDotPattern = rand(1,2)*n+center-[n/2, n/2];
                    end
                    
                    A = tempDotPattern(1,1);
                    B = tempDotPattern(1,2);
                    recheckCounter=recheckCounter+1;
                    if recheckCounter==1000
                        dotGroup(rdots,:)=dotGroup(rdots-1,:);
                        break;
                    end
                end
            end
        end
    end
    end
else dotGroup = [];
end

end

function DrawGaussians(display, dotGroup, DestRect, loGaussian, textureIndex)
    for index=1:size(dotGroup, 2)
        Screen('DrawTexture', display.windowPtr, textureIndex, [], [display.Rect(1)+dotGroup(1,index)-floor(0.5*size(loGaussian, 1)) display.Rect(2)+dotGroup(2,index)-floor(0.5*size(loGaussian, 2))  display.Rect(1)+dotGroup(1,index)+ceil(0.5*size(loGaussian, 1)), display.Rect(2)+dotGroup(2,index)+ceil(0.5*size(loGaussian, 2))]);
    end
end


