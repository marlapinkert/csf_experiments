function [response, timing, quitProg, stimulus] = showScanStimulusNumbersHeavy(display, params, t0, stimulus)
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
responseKeyboard=[KbName('z') KbName('x')];


% some variables
if strcmp(params.experiment, 'Dots Scaled pRF') || strcmp(params.experiment, 'Dots Scaled pRF full blanks') || strcmp(params.experiment, 'Dots Scaled pRF short') || strcmp(params.experiment, 'Dots Scaled pRF full blanks short') || strcmp(params.experiment,'Dots Area pRF full blanks TR=1.5, nTRs=3') || strcmp(params.experiment,'Dots Size pRF full blanks TR=1.5, nTRs=3') || strcmp(params.experiment,'Dots Circumference pRF full blanks TR=1.5, nTRs=3') || strcmp(params.experiment,'Dots Dense pRF full blanks TR=1.5, nTRs=3') || strcmp(params.experiment,'Dots Scaled pRF full blanks TR=2, nTRs=2')
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

recheckDist=1.5;
switch params.experiment
    case {'Dots Small'}
        dotSize = 5;%2.25;
        dotColors = [0 0 0; 255 255 255];
        dotRefresh = 0.5;
        grayTime = 0.2;
        oneBackFrequency=0.05; %actually contrast reversal frequency
        stimulus.fixSeq=zeros(framesPerPosition*windowPositions*params.ncycles,1);
        fixSeqCounter=0;
        fixSeqAdder=1;
        
    case {'Dots Scaled pRF', 'Dots Scaled pRF full blanks'}
        dotSize = 8;
        dotColors = [0 0 0; 255 255 255];
        dotRefresh = 1;
        grayTime = 0.7;
        oneBackFrequency=0.1; %actually contrast reversal frequency
        stimulus.fixSeq=zeros(framesPerPosition*windowPositions*params.ncycles,1);
        fixSeqCounter=0;
        fixSeqAdder=1;
        
    case {'Dots Scaled pRF short', 'Dots Scaled pRF full blanks short', 'Dots Area pRF full blanks TR=1.5, nTRs=3','Dots Size pRF full blanks TR=1.5, nTRs=3','Dots Circumference pRF full blanks TR=1.5, nTRs=3', 'Dots Dense pRF full blanks TR=1.5, nTRs=3'}
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
        stimulus.fixSeq=zeros(framesPerPosition*windowPositions*params.ncycles,1);
        fixSeqCounter=0;
        fixSeqAdder=1;
        
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
        
    case {'Dots Gaussian'}
        contrast=1;
        contrast=128*contrast;
        dotSize = 19;
        dotColors = [0 0 0; 255 255 255];
        dotRefresh = 0.5;
        grayTime = 0.2;
        loGaussian = fspecial('log', dotSize, 0.14*dotSize);
        loGaussian=-loGaussian/min(loGaussian(:));
        loGaussianReverse=loGaussian.*-contrast+128;
        loGaussian=loGaussian.*contrast+128;
        textureIndex(1)=Screen('MakeTexture', display.windowPtr, loGaussian);
        textureIndex(2)=Screen('MakeTexture', display.windowPtr, loGaussianReverse);
        oneBackFrequency=0.05;
        stimulus.fixSeq=zeros(framesPerPosition*windowPositions*params.ncycles,1);
        fixSeqCounter=0;
        fixSeqAdder=1;
    case {'Dots Attention'}
        dotSize=11.784;
        stimColor = 'black';
        dotRefresh = 1.2;   %In this situation, dotRefresh is the whole 2AFC cycle. Each stimulus is shown for (dotRefresh-grayTime-isi)/2
        grayTime = 0.4;     %In this situation, grayTime is the inter-trial interval
        isi=0.2;            %Inter-stimulus interval within a trial
        eachStim=(dotRefresh-grayTime-isi)/2;
        eachStimFrames=eachStim/stimFrame;
        isiFrames = isi/stimFrame;
        
        %response structures
        whiteStims=ones((params.period*params.ncycles)/dotRefresh,1);
        whiteStims=whiteStims+round(rand(size(whiteStims)));
        blackStims=ones((params.period*params.ncycles)/dotRefresh,1);
        blackStims=blackStims+round(rand(size(blackStims)));
        responses=zeros(size(whiteStims));
        currentStim=0;
        currentResponse=0;
        blackContrastChange=10;
        whiteContrastChange=20;
        
        responseKeys=[67 68];
        respondForGray=true;
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
oldTextSize = Screen('TextSize', display.windowPtr, textSize);
framesPerPattern = dotRefresh/stimFrame;
grayFrames = grayTime/stimFrame;
%params.whichStim = 'dots';% 'dotsandnumbers' 'dots' ' numbers'

%amounts of dots
if params.equalArea ==1 || params.equalArea==3;
    dotSizeIn = 3*(dotSize/2)^2*pi;
elseif params.equalArea==2
    dotSizeIn = dotSize*pi*3;
end



lastNumberBlank=false;

% if ~ischar(stimColor)
%     dotColors=[stimColor stimColor stimColor];
% else
%     switch lower(stimColor);
%         case {'white'}
%             dotColors = [255 255 255];
%         case {'black'}
%             dotColors = [0 0 0]; 
%     end
% end

if strcmpi(params.whichStim,'dotsandnumbers') || strcmpi(params.whichStim,'numbers');
    fontList{1}='Arial'; 
    fontList{2}='Andale Mono';
    fontList{3}='AppleGothic'; 
    fontList{4}='American Typewriter';
    fontList{5}='AppleGothic';
    fontList{6}='Lucida Grande';
    fontList{7}='Helvetica Neue Light';
    fontList{8}='Helvetica Neue';
    fontList{9}='Arial Italic';
    fontList{10}='Helvetica Neue Black Condensed';
    fontList{11}='American Typewriter Condensed';
    fontList{12}='Arial Bold';
    fontNumber=0;
    oneBackFrequency=0.05;
    stimulus.fixSeq=zeros(framesPerPosition*windowPositions*params.ncycles,1);
    fixSeqCounter=0;
    fixSeqAdder=1;
else
    stimulus.fixSeq=ones(framesPerPosition*windowPositions*params.ncycles,1);
end;


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
 
        %     cornerPositionX=(rand(1)*(size(stimulus.images,1)-n));
        %     cornerPositionY=(rand(1)*(size(stimulus.images,1)-n));
        %     if rand(1)>0.5
        %         stimulus.orientations(winPos)=stimulus.orientations(winPos)-180;
        %     end
        
        %CALCULATES HOW MANY DOTS ARE NEEDED THIS TR
        switch params.experiment
            case {'Dots Scaled pRF', 'Dots Scaled pRF full blanks','Dots Scaled pRF short', 'Dots Scaled pRF full blanks short', 'Dots Area pRF full blanks TR=1.5, nTRs=3','Dots Size pRF full blanks TR=1.5, nTRs=3','Dots Circumference pRF full blanks TR=1.5, nTRs=3', 'Dots Dense pRF full blanks TR=1.5, nTRs=3', 'Dots Scaled pRF full blanks TR=2, nTRs=2'}
                ndots=params.dotOrder(winPos);
            otherwise
                ndots=floor((mod(winPos, nDotsMax*nTRsPerDots)+(nTRsPerDots-1))/nTRsPerDots);
                if ndots==0 && lastNumberBlank==false
                    ndots=nDotsMax;
                end
                if params.reverseDirection==true && lastNumberBlank==false
                    ndots=nDotsMax+1-ndots;
                elseif params.reverseDirection==true
                    if ndots>0
                        ndots=nDotsMax-ndots;
                    end
                end
        end
        
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

        %THIS LOOP GENERATES A NEW DOT PATTERN FOR EACH TR
        if strcmp(params.experiment, 'Dots Attention')
            %dotGroup=newDotPattern(params, 7,n, dotSize, 2);
        elseif strcmp(params.experiment, 'Dots Gaussian')
            dotGroup=newDotPattern(params, ndots,n, dotSize, 1);%sqrt(2));
        elseif params.equalArea==3
            dotGroup=newDotPatternDense(ndots,n, dotSize, recheckDist);
        else
            dotGroup=newDotPattern(params, ndots,n, dotSize, recheckDist);%2);
        end


        %stimulus.orientations(winPos)
        
        
        %COPYS THE DOT PATTERN TO THE FRAME BUFFER FOR THE NUMBER OF FRAMES IN EACH TR
        for frame=1:framesPerPosition;
                        
            Screen('FillRect', display.windowPtr, [128 128 128], rect );
            %ndots=ceil(rand(1)*6);
            
            switch lower(params.whichStim)
                case {'dotsandnumbers'}
                    
                    if uint8(mod(frame,framesPerPattern))==1;
                        dotGroup=newDotPattern(params, ndots,n, dotSize, 2);
                        fontNumberOld=fontNumber;
                        while fontNumberOld==fontNumber;
                            fontNumber=ceil(length(fontList)*rand(1));
                        end                       
                        Screen('DrawDots',display.windowPtr, double(dotGroup'), double(dotSize), double(dotColors), [display.Rect(1) display.Rect(2)],1);
                    elseif mod(frame,framesPerPattern) <= framesPerPattern - grayFrames && mod(frame,framesPerPattern)> 0;
                        Screen('DrawDots',display.windowPtr, double(dotGroup'), double(dotSize), double(dotColors), [display.Rect(1) display.Rect(2)],1);
                    else
                        Screen('DrawText', display.windowPtr, num2str(ndots), display.Rect(1)+(display.Rect(3)-display.Rect(1))/2-charWidth, display.Rect(2)+(display.Rect(4)-display.Rect(2))/2-charHeight, double(dotColors));
                    end

                case 'dots'
                     if ndots>0
                        if strcmp(params.experiment, 'Dots Attention') %These trials are complicated because of the attentional task
                            if uint8(mod(frame,framesPerPattern))==1;
                                dotGroup=newDotPattern(params, 7,n, dotSize, 2);
                                currentStim=currentStim+1;
                                if blackStims(currentStim)==1
                                    Screen('DrawDots',display.windowPtr, double(dotGroup(1:ndots,:)'), double(dotSize), double([0 0 0]), [display.Rect(1) display.Rect(2)],1);
                                else
                                    Screen('DrawDots',display.windowPtr, double(dotGroup(1:ndots,:)'), double(dotSize), double([blackContrastChange blackContrastChange blackContrastChange]), [display.Rect(1) display.Rect(2)],1);
                                end
                                if whiteStims(currentStim)==1
                                    Screen('DrawDots',display.windowPtr, double(dotGroup(ndots+1:end,:)'), double(dotSize), double([255 255 255]), [display.Rect(1) display.Rect(2)],1);
                                else
                                    Screen('DrawDots',display.windowPtr, double(dotGroup(ndots+1:end,:)'), double(dotSize), double([255-whiteContrastChange 255-whiteContrastChange 255-whiteContrastChange]), [display.Rect(1) display.Rect(2)],1);
                                end
                            elseif uint8(mod(frame,framesPerPattern))==uint8(eachStimFrames+isiFrames+1);
                                dotGroup=newDotPattern(params, 7,n, dotSize, 2);
                                currentResponse=currentResponse+1;  %Allows response to previous trial until both stimuli in next trial are shown
                                if blackStims(currentStim)==2
                                    Screen('DrawDots',display.windowPtr, double(dotGroup(1:ndots,:)'), double(dotSize), double([0 0 0]), [display.Rect(1) display.Rect(2)],1);
                                else
                                    Screen('DrawDots',display.windowPtr, double(dotGroup(1:ndots,:)'), double(dotSize), double([blackContrastChange blackContrastChange blackContrastChange]), [display.Rect(1) display.Rect(2)],1);
                                end  
                                if whiteStims(currentStim)==2
                                    Screen('DrawDots',display.windowPtr, double(dotGroup(ndots+1:end,:)'), double(dotSize), double([255 255 255]), [display.Rect(1) display.Rect(2)],1);
                                else
                                    Screen('DrawDots',display.windowPtr, double(dotGroup(ndots+1:end,:)'), double(dotSize), double([255-whiteContrastChange 255-whiteContrastChange 255-whiteContrastChange]), [display.Rect(1) display.Rect(2)],1);
                                end                              
                            elseif mod(frame,framesPerPattern)<eachStimFrames+1 && mod(frame,framesPerPattern)> 0;%keep current frame
                                if blackStims(currentStim)==1
                                    Screen('DrawDots',display.windowPtr, double(dotGroup(1:ndots,:)'), double(dotSize), double([0 0 0]), [display.Rect(1) display.Rect(2)],1);
                                else
                                    Screen('DrawDots',display.windowPtr, double(dotGroup(1:ndots,:)'), double(dotSize), double([blackContrastChange blackContrastChange blackContrastChange]), [display.Rect(1) display.Rect(2)],1);
                                end
                                if whiteStims(currentStim)==1
                                    Screen('DrawDots',display.windowPtr, double(dotGroup(ndots+1:end,:)'), double(dotSize), double([255 255 255]), [display.Rect(1) display.Rect(2)],1);
                                else
                                    Screen('DrawDots',display.windowPtr, double(dotGroup(ndots+1:end,:)'), double(dotSize), double([255-whiteContrastChange 255-whiteContrastChange 255-whiteContrastChange]), [display.Rect(1) display.Rect(2)],1);
                                end
                            elseif mod(frame,framesPerPattern)>eachStimFrames+isiFrames+1 && mod(frame,framesPerPattern)<eachStimFrames*2+isiFrames+1
                                if blackStims(currentStim)==2
                                    Screen('DrawDots',display.windowPtr, double(dotGroup(1:ndots,:)'), double(dotSize), double([0 0 0]), [display.Rect(1) display.Rect(2)],1);
                                else
                                    Screen('DrawDots',display.windowPtr, double(dotGroup(1:ndots,:)'), double(dotSize), double([blackContrastChange blackContrastChange blackContrastChange]), [display.Rect(1) display.Rect(2)],1);
                                end  
                                if whiteStims(currentStim)==2
                                    Screen('DrawDots',display.windowPtr, double(dotGroup(ndots+1:end,:)'), double(dotSize), double([255 255 255]), [display.Rect(1) display.Rect(2)],1);
                                else
                                    Screen('DrawDots',display.windowPtr, double(dotGroup(ndots+1:end,:)'), double(dotSize), double([255-whiteContrastChange 255-whiteContrastChange 255-whiteContrastChange]), [display.Rect(1) display.Rect(2)],1);
                                end
                            end
                        elseif strcmp(params.experiment, 'Dots Gaussian')
                            fixSeqCounter=fixSeqCounter+1;
                            if uint8(mod(frame,framesPerPattern))==1;
                                dotGroup=newDotPattern(params, ndots,n, dotSize, 1);%sqrt(2));                                
                                randTmp=rand(1);      
                                if randTmp<oneBackFrequency
                                    fixSeqAdder=3-fixSeqAdder;
                                end
                                DrawGaussians(display, double(dotGroup'), [display.Rect(1) display.Rect(2)], loGaussian, textureIndex(fixSeqAdder));
                            elseif uint8(mod(frame,framesPerPattern)) <= framesPerPattern - grayFrames && mod(frame,framesPerPattern)> 0;
                                DrawGaussians(display, double(dotGroup'), [display.Rect(1) display.Rect(2)], loGaussian, textureIndex(fixSeqAdder));
                            end
                            stimulus.fixSeq(fixSeqCounter)=fixSeqAdder;
                        else
                            fixSeqCounter=fixSeqCounter+1;
                            if uint8(mod(frame,framesPerPattern))==1;
                                if params.equalArea==3
                                    dotGroup=newDotPatternDense(ndots,n, dotSize, recheckDist);
                                else
                                    dotGroup=newDotPattern(params, ndots,n, dotSize, recheckDist);%2);
                                end
                                randTmp=rand(1);
                                if randTmp<oneBackFrequency && frame>1 && fixSeqAdder==1
                                    fixSeqAdder=2;%3-fixSeqAdder;
                                else
                                    fixSeqAdder=1;
                                end
                                Screen('DrawDots',display.windowPtr, double(dotGroup'), double(dotSize), double(dotColors(fixSeqAdder,:)), [display.Rect(1) display.Rect(2)],1);
                            elseif uint8(mod(frame,framesPerPattern)) <= framesPerPattern - grayFrames && mod(frame,framesPerPattern)> 0;
                                Screen('DrawDots',display.windowPtr, double(dotGroup'), double(dotSize), double(dotColors(fixSeqAdder,:)), [display.Rect(1) display.Rect(2)],1);
                            end
                            stimulus.fixSeq(fixSeqCounter)=fixSeqAdder;
                        end
                        
                        
                        
                        
                        
                        
%                         if mod(frame,framesPerPattern)==1;
%                             if strcmp(params.experiment, 'Dots Attention')
%                                 dotGroup=newDotPattern(params, 7,n, dotSize, 2);
%                                 Screen('DrawDots',display.windowPtr, double(dotGroup(1:ndots,:)'), double(dotSize), double([0 0 0]), [display.Rect(1) display.Rect(2)],1);
%                                 Screen('DrawDots',display.windowPtr, double(dotGroup(ndots+1:end,:)'), double(dotSize), double([255 255 255]), [display.Rect(1) display.Rect(2)],1);
%                             else
%                                 dotGroup=newDotPattern(params, ndots,n, dotSize, 2);
%                                 Screen('DrawDots',display.windowPtr, double(dotGroup'), double(dotSize), double(dotColors), [display.Rect(1) display.Rect(2)],1);
% 
%                             end
%                         elseif mod(frame,framesPerPattern) <= framesPerPattern - grayFrames && mod(frame,framesPerPattern)> 0;
%                             if strcmp(params.experiment, 'Dots Attention')
%                                 Screen('DrawDots',display.windowPtr, double(dotGroup(1:ndots,:)'), double(dotSize), double([0 0 0]), [display.Rect(1) display.Rect(2)],1);
%                                 Screen('DrawDots',display.windowPtr, double(dotGroup(ndots+1:end,:)'), double(dotSize), double([255 255 255]), [display.Rect(1) display.Rect(2)],1);
%                             else
%                                 Screen('DrawDots',display.windowPtr, double(dotGroup'), double(dotSize), double(dotColors), [display.Rect(1) display.Rect(2)],1);
% 
%                             end
%                         else
%                             %Screen('DrawDots',display.windowPtr, double(dotGroup'), double(dotSize), double(dotColors), [display.Rect(1) display.Rect(2)],1);
%                             %Screen('DrawText', display.windowPtr, num2str(ndots), display.Rect(1)+(display.Rect(3)-display.Rect(1))/2-charWidth, display.Rect(2)+(display.Rect(4)-display.Rect(2))/2-charHeight, double(dotColors));
%                         end
                     else
                        fixSeqCounter=fixSeqCounter+1;
                     end

                case 'numbers'
                    fixSeqCounter=fixSeqCounter+1;
                    if mod(frame,framesPerPattern)==1;
                        fontNumberOld=fontNumber;
                        randTmp=rand(1);
                        if frame==1 || randTmp>oneBackFrequency
                            while fontNumberOld==fontNumber;
                                fontNumber=ceil(length(fontList)*rand(1));
                            end
                        elseif randTmp<oneBackFrequency
                            fixSeqAdder=3-fixSeqAdder;
                        end
                        oldFontName=Screen('TextFont', display.windowPtr, fontList{fontNumber});
                        Screen('DrawText', display.windowPtr, num2str(ndots), display.Rect(1)+(display.Rect(3)-display.Rect(1))/2-charWidth, display.Rect(2)+(display.Rect(4)-display.Rect(2))/2-charHeight, double(dotColors));
                    elseif mod(frame,framesPerPattern) <= framesPerPattern - grayFrames && mod(frame,framesPerPattern)> 0;
                        %                Screen('DrawDots',display.windowPtr, double(dotGroup'), double(dotSize), double(dotColors), [display.Rect(1) display.Rect(2)],1);
                        Screen('DrawText', display.windowPtr, num2str(ndots), display.Rect(1)+(display.Rect(3)-display.Rect(1))/2-charWidth, display.Rect(2)+(display.Rect(4)-display.Rect(2))/2-charHeight, double(dotColors));
                    else
                        %Screen('DrawText', display.windowPtr, num2str(ndots), display.Rect(1)+(display.Rect(3)-display.Rect(1))/2-charWidth, display.Rect(2)+(display.Rect(4)-display.Rect(2))/2-charHeight, double(dotColors));
                    end
                    stimulus.fixSeq(fixSeqCounter)=fixSeqAdder;

                otherwise
                    error('unknown option');
                    %end
            end

            %Screen('DrawTexture', display.windowPtr, stimulus.textures(imgNum), stimulus.srcRect, stimulus.destRect);


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
                if any(ssKeyCode)
                    if strcmp(params.experiment, 'Dots Attention')
                        if sum(ismember(responseKeys,ssKeyCode)) && responses(currentResponse)==0;
                            responses(currentResponse)=find(ismember(responseKeys, ssKeyCode));
                        end
                    else
                        %kc = find(ssKeyCode);
                        %            response.keyCode(frame) = kc(1); %
                        %            binary response for now
                        response.keyCode(((cycle-1)*(framesPerPosition*windowPositions))+(winPos-1)*framesPerPosition+frame,:) = ssKeyCode;
                        response.secs((cycle-1)*(framesPerPosition*windowPositions)+(winPos-1)*framesPerPosition+frame)    = ssSecs - t0;
                    end
                end;
                % scan the keyboard for experimentor input
                [exKeyIsDown exSecs exKeyCode] = KbCheck(display.devices.keyInputInternal);
                if(exKeyIsDown)
                    if(exKeyCode(quitProgKey)),
                        quitProg = 1;
                        break;% out of while loop
                    elseif strcmp(params.experiment, 'Dots Attention')
                        if(exKeyCode(responseKeyboard(1)))
                            if responses(currentResponse)==0;
                                responses(currentResponse)=1;
                            end
                        elseif(exKeyCode(responseKeyboard(2)))
                            if responses(currentResponse)==0;
                                responses(currentResponse)=2;  
                            end
                        end
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

if strcmp(params.experiment, 'Dots Attention')
    if respondForGray; responses=3-responses; end %if subject was choosing grayest alternative (instead of most contrast) reverse responses
    blackCorrect=100*(sum(responses==blackStims)/length(blackStims))
    whiteCorrect=100*(sum(responses==whiteStims)/length(whiteStims))
end

Screen('TextSize', display.windowPtr, oldTextSize);
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


