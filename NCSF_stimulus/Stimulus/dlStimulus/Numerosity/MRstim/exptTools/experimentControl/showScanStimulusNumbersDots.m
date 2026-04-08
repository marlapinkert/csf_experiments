function [response, timing, quitProg, stimulus] = showScanStimulusNumbersDots(display, params, t0, stimulus)
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
%respKey=KbName('z');
triggerKey=KbName('t');


% some variables
%if strcmp(params.experiment, 'Dots Scaled pRF') || strcmp(params.experiment, 'Dots Scaled pRF full blanks') || strcmp(params.experiment, 'Dots Scaled pRF short') || strcmp(params.experiment, 'Dots Scaled pRF full blanks short') || strcmp(params.experiment,'Dots Area pRF full blanks TR=1.5, nTRs=3') || strcmp(params.experiment,'Dots Size pRF full blanks TR=1.5, nTRs=3') || strcmp(params.experiment,'Dots Circumference pRF full blanks TR=1.5, nTRs=3') || strcmp(params.experiment,'Dots Dense pRF full blanks TR=1.5, nTRs=3') ||  strcmp(params.experiment,'Dots Shapes pRF full blanks TR=1.5, nTRs=3') || strcmp(params.experiment,'Dots Size pRF full blanks ECoG TR=1.5, nTRs=3')  || strcmp(params.experiment,'Dots Size pRF ECoG long random order')||strcmp(params.experiment,'One Dot Sizes pRF full blanks TR=1.5, nTRs=3') || strcmp(params.experiment,'Numbers Size pRF full blanks TR=1.5, nTRs=3') || strcmp(params.experiment,'Dots Size pRF full blanks TR=2.1, nTRs=2') || strcmp(params.experiment,'Number Symbols pRF full blanks TR=2.1, nTRs=2')
    nTRsPerDots=1;
    params.tr=params.tr*nTRsPerDots;
% else
%     nTRsPerDots=2;
%     params.tr=params.tr*nTRsPerDots;
%     nTRsPerDots=1;
% end
windowPositions = round(params.period/params.tr);%size(stimulus.seq, 3);
stimFrame       = 1./params.temporal.frequency./params.temporal.motionSteps;
framesPerPosition=params.tr/stimFrame;
% sca;
% Screen('Close All');


seqTiming=0:params.tr:params.period*params.ncycles-params.tr;

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
%    aviobj = avifile('checkMovie.avi', 'FPS', fRate);
    aviobj = VideoWriter('checkMovie', 'MPEG-4');
    aviobj.FrameRate=fRate;
    open(aviobj);
%     aviobjA = avifile('checkMovieA.avi', 'FPS', fRate);
%     aviobjB = avifile('checkMovieB.avi', 'FPS', fRate);
%     aviobjC = avifile('checkMovieC.avi', 'FPS', fRate);
%     aviobjD = avifile('checkMovieD.avi', 'FPS', fRate);
%     recordingFrames=recordingFrames/4;
%     movie=[];
end

responses=[];
colorEvents=[];

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
        
    case {'Dots Scaled pRF short', 'Dots Scaled pRF full blanks short', 'Dots Area pRF full blanks TR=1.5, nTRs=3','Dots Size pRF full blanks TR=1.5, nTRs=3','Dots Circumference pRF full blanks TR=1.5, nTRs=3', 'Dots Dense pRF full blanks TR=1.5, nTRs=3', 'Dots Shapes pRF full blanks TR=1.5, nTRs=3', 'Dots Size pRF full blanks ECoG TR=1.5, nTRs=3','One Dot Sizes pRF full blanks TR=1.5, nTRs=3','Numbers Size pRF full blanks TR=1.5, nTRs=3'}
        if params.equalArea ==1;
            %Separate lens setup
            dotSize = 8;
            recheckDist=3;
        elseif params.equalArea==2
            dotSize = 21;
            recheckDist=3;
        elseif params.equalArea ==3;
            dotSize = 8;
            recheckDist=1.8;
        else
            dotSize = 8;
            recheckDist=1.4;
        end
        if strcmp(params.calibration, '7T_UMC_1024x768FixedLens')
            dotSize=dotSize.*1.5;
        elseif strcmp(params.calibration, '7T_DLP_1600x900')
            dotSize=dotSize*0.87;
        elseif strcmp(params.calibration, '7T_Spinoza_1920x1080')
            dotSize=dotSize.*2.158;
        elseif strcmp(params.calibration, 'Grid_IEMU_Display')
            dotSize=dotSize./1.106;
        elseif strcmp(params.calibration, '3T_Spinoza_1920x1080')
            dotSize=dotSize.*2.0572;
        end
        
        dotColors = [0 0 0; 255 255 255];
        dotRefresh = 0.75;
        grayTime = 0.45;
        oneBackFrequency=0.1; %actually contrast reversal frequency
        stimulus.fixSeq=ones(params.tr/dotRefresh*windowPositions*params.ncycles,1);
        fixSeqCounter=0;
        fixSeqAdder=1;
        
        stimulus.fixResponse=ones(params.tr/dotRefresh*windowPositions*params.ncycles, 1);
        
    case {'Dots Area pRF full blanks TR=2.1, nTRs=2', 'Dots Size pRF full blanks TR=2.1, nTRs=2', 'Dots Circumference pRF full blanks TR=2.1, nTRs=2', 'Dots Dense pRF full blanks TR=2.1, nTRs=2', 'Dots Shapes pRF full blanks TR=2.1, nTRs=2', 'One Dot Sizes pRF full blanks TR=2.1, nTRs=2', 'One Dot Sizes Constant Step pRF full blanks TR=2.1, nTRs=2', 'One Dot Double Sizes pRF full blanks TR=2.1, nTRs=2','One Line Size Random Orientation pRF full blanks TR=2.1, nTRs=2', 'One Dot Luminance pRF full blanks TR=2.1, nTRs=2', 'Dots Area pRF full blanks 4degree low numbers TR=1.95, nTRs=2', 'Dots Area pRF full blanks 4degree high numbers TR=1.95, nTRs=2'}%,'Dots Circumference pRF full blanks TR=1.5, nTRs=3', 'Dots Dense pRF full blanks TR=1.5, nTRs=3', 'Dots Shapes pRF full blanks TR=1.5, nTRs=3', 'Dots Size pRF full blanks ECoG TR=1.5, nTRs=3','One Dot Sizes pRF full blanks TR=1.5, nTRs=3','Numbers Size pRF full blanks TR=1.5, nTRs=3'}
        %params.equalArea=1;
        if params.equalArea ==1;
            %Separate lens setup
            dotSize = 8;
            recheckDist=3;
            switch params.experiment
                case {'Dots Area pRF full blanks 4degree high numbers TR=1.95, nTRs=2'}
                    dotSize = params.dotSize;
                    recheckDist=1.42;
                case {'Dots Area pRF full blanks 4degree low numbers TR=1.95, nTRs=2'}
                    dotSize = params.dotSize;
                    recheckDist=1.6;
            end
        elseif params.equalArea==2
            dotSize = 21;
            recheckDist=3;
        elseif params.equalArea ==3;
            dotSize = 8;
            recheckDist=1.8;
        else
            dotSize = 8;
            recheckDist=1.4;
        end
        %Fixed lens setup
        if strcmp(params.calibration, '7T_UMC_1024x768FixedLens')
            dotSize=dotSize.*1.5;
            if strcmp(params.experiment, 'One Dot Sizes pRF full blanks TR=2.1, nTRs=2') ||  strcmp(params.experiment, 'One Dot Sizes Constant Step pRF full blanks TR=2.1, nTRs=2') || strcmp(params.experiment, 'One Line Size Random Orientation pRF full blanks TR=2.1, nTRs=2');
                params.dotOrder=params.dotOrder.*1.5;
            end
        elseif strcmp(params.calibration, '7T_Spinoza_1920x1080')
            if strcmp(params.experiment,'Dots Area pRF full blanks 4degree low numbers TR=1.95, nTRs=2') || strcmp(params.experiment,'Dots Area pRF full blanks 4degree high numbers TR=1.95, nTRs=2')
                dotSize=dotSize*2.5;
            end
            
        elseif strcmp(params.calibration, '7T_DLP_1600x900')
            if ~strcmp(params.experiment,'Dots Area pRF full blanks 4degree low numbers TR=1.95, nTRs=2') && ~strcmp(params.experiment,'Dots Area pRF full blanks 4degree high numbers TR=1.95, nTRs=2')
                dotSize=dotSize*0.87;
            elseif strcmp(params.experiment, 'One Dot Sizes pRF full blanks TR=2.1, nTRs=2') ||  strcmp(params.experiment, 'One Dot Sizes Constant Step pRF full blanks TR=2.1, nTRs=2') || strcmp(params.experiment, 'One Line Size Random Orientation pRF full blanks TR=2.1, nTRs=2') || strcmp(params.experiment, 'One Dot Luminance pRF full blanks TR=2.1, nTRs=2');
                params.dotOrder=params.dotOrder.*0.87;
            end
        end
        
        dotColors = [0 0 0; 255 255 255];
        if strcmp(params.experiment,'Dots Area pRF full blanks 4degree low numbers TR=1.95, nTRs=2') || strcmp(params.experiment,'Dots Area pRF full blanks 4degree high numbers TR=1.95, nTRs=2')
            dotRefresh = 0.65;
            grayTime = 0.35;
        else
            dotRefresh = 0.70;
            grayTime = 0.40;
        end
        oneBackFrequency=0.1; %actually contrast reversal frequency
                
        stimulus.fixSeq=ones(params.tr/dotRefresh*windowPositions*params.ncycles,1);
        fixSeqCounter=0;
        fixSeqAdder=1;
        
        stimulus.fixResponse=ones(params.tr/dotRefresh*windowPositions*params.ncycles, 1);    
                
    case {'Number Symbols pRF full blanks TR=2.1, nTRs=2'}%,'Dots Circumference pRF full blanks TR=1.5, nTRs=3', 'Dots Dense pRF full blanks TR=1.5, nTRs=3', 'Dots Shapes pRF full blanks TR=1.5, nTRs=3', 'Dots Size pRF full blanks ECoG TR=1.5, nTRs=3','One Dot Sizes pRF full blanks TR=1.5, nTRs=3','Numbers Size pRF full blanks TR=1.5, nTRs=3'}
        params.equalArea=0;
        dotSize=18;
        
        dotColors = [0 0 0; 255 255 255];
        dotRefresh = 0.70;
        grayTime = 0.40;
        oneBackFrequency=0.1; %actually contrast reversal frequency
        stimulus.fixSeq=ones(params.tr/dotRefresh*windowPositions*params.ncycles,1);
        stimulus.letterSeq=zeros(params.tr/dotRefresh*windowPositions*params.ncycles,1);
        fixSeqCounter=0;
        fixSeqAdder=1;
        
        stimulus.fixResponse=ones(params.tr/dotRefresh*windowPositions*params.ncycles, 1);        

    case {'Dots Size pRF ECoG long random order'}
        if params.equalArea ==1;
            dotSize = 8;
            recheckDist=3;
        elseif params.equalArea==2
            dotSize = 21;
            recheckDist=3;
        elseif params.equalArea ==3;
            dotSize = 8;
            recheckDist=1.8;
        else
            dotSize = 8;
            recheckDist=1.4;
        end
        dotColors = [0 0 0; 255 255 255];
        dotRefresh = 3;
        grayTime = 1;
        oneBackFrequency=0; %actually contrast reversal frequency
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
            recheckDist=6;
        elseif params.equalArea ==3;
            dotSize = 8;
            recheckDist=1.2 ;
        elseif n==66
            dotSize = 7;
            recheckDist=1.4;
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
        
    case {'Dots Size pRF full blanks TR=2.25, nTRs=2'}
        if params.equalArea ==1;
            dotSize = 8;
            recheckDist=3;
        elseif params.equalArea==2
            dotSize = 21;
            recheckDist=3;
        else
            dotSize = 7;
        end
        dotColors = [0 0 0; 255 255 255];
        dotRefresh = 0.75;
        grayTime = 0.45;
        oneBackFrequency=0.1; %actually contrast reversal frequency
        
        stimulus.fixSeq=ones(params.tr/dotRefresh*windowPositions*params.ncycles,1);
        fixSeqCounter=0;
        fixSeqAdder=1;
        
        stimulus.fixResponse=ones(params.tr/dotRefresh*windowPositions*params.ncycles, 1);
        
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

if strcmp(params.experiment,'Dots Size pRF ECoG long random order')
    randomOrder=1;
else
    randomOrder=0;
end
    
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

if strcmp(params.experiment,'Dots Shapes pRF full blanks TR=1.5, nTRs=3') || strcmp(params.experiment,'Dots Shapes pRF full blanks TR=2.1, nTRs=2') || strcmp(params.experiment,'Dots Size pRF ECoG long random order')
    unicodesIn=[9650, 9632, 9644, 9679, 10006, 8902, 10033];%, 11039, 11042, 11052];
    unicodesSizesIn=[17 15 16 17 12 21 12];% 27 27 27 27 27 34 19];
    uniXoffsetIn=[5 4.5 5 5 4.5 6 4];
    uniYoffsetIn=[12 10 11 12 9 17 9];
    
    if strcmp(params.calibration, '7T_UMC_1024x768FixedLens')
        unicodesSizesIn=unicodesSizesIn.*1.5;
        uniXoffsetIn=uniXoffsetIn.*1.5;
        uniYoffsetIn=uniYoffsetIn.*1.5;
    end
    
    oldFont=Screen('TextFont', display.windowPtr,'Arial Unicode MS');
    oldTextSize=Screen('TextSize', display.windowPtr, textSize);
    Screen('Preference', 'TextRenderer', 1);
    Screen('Preference', 'TextAntiAliasing', 1);
elseif strcmp(params.experiment,'Numbers Size pRF full blanks TR=1.5, nTRs=3') || strcmp(params.experiment,'Number Symbols pRF full blanks TR=2.1, nTRs=2')
    letterList={'F', 'G', 'H', 'J', 'K', 'N', 'P', 'R', 'T', 'U', 'W', 'Y'};
    letterIndex=0;
    dotSize=36;
    if strcmp(params.calibration, '7T_UMC_1024x768FixedLens')
         dotSize=dotSize.*1.5;
    end
    oldFont=Screen('TextFont', display.windowPtr,'Arial Unicode MS');
    oldTextSize=Screen('TextSize', display.windowPtr, round(dotSize*1.45));
    Screen('Preference', 'TextRenderer', 1);
    Screen('Preference', 'TextAntiAliasing', 1);
end

lastNumberBlank=false;
dontDisplay=0;
dotGroup=[0 0];
        
% go
disp(sprintf('[%s]:Running. Hit %s to quit.',mfilename,KbName(quitProgKey)));
if params.prescanDuration>0
    for winPos=1:params.prescanDuration/params.tr
        %dotGroup=[0 0];
        cycle=1;
        ndots=params.dotOrder(end);
        if params.equalArea ==1 && ndots>0;
            dotSize =(2*(sqrt((dotSizeIn/ndots)/pi)));
        elseif params.equalArea ==3 && ndots>0;
            dotSize =(2*(sqrt((dotSizeIn/ndots)/pi)));
        elseif params.equalArea ==2 && ndots>0;
            dotSize = dotSizeIn/ndots/pi;
        elseif params.equalArea ==4
            if ndots>0;  
                dotSize = ndots;
                ndots=1;
            else
                Screen('FillRect', display.windowPtr, [0 0 0], rect );
            end
        end
        
        if params.equalArea==3
            dotGroup=newDotPatternDense(ndots,n, dotSize, recheckDist);
        elseif strcmp(params.experiment,'Numbers Size pRF full blanks TR=1.5, nTRs=3') || strcmp(params.experiment,'Number Symbols pRF full blanks TR=2.1, nTRs=2')
            center=rand(1,2)*n;
            while sqrt((center(1)-0.5*n)^2+(center(2)-0.5*n)^2)>0.5*n-dotSize/2
                center = rand(1,2)*n;
            end
        elseif strcmp(params.experiment,'One Dot Sizes Constant Step pRF full blanks TR=2.1, nTRs=2')
            distance=5.5;
            dotGroup=newDotPatternConstantStep(params, ndots,n, dotSize, dotGroup, distance);
            
%         elseif strcmp(params.experiment,'One Dot Luminance pRF full blanks TR=2.1, nTRs=2')
%             distance=5.5;
%             dotGroup=newDotPattern(params, ndots,n, dotSize, 0);
        else
            %dotGroup=[37 5; 37 15; 37 25; 37 35; 37 45; 37 55; 37 65];
            dotGroup=newDotPattern(params, ndots,n, dotSize, recheckDist);%2);
            lineDirection=rand(1)*2*pi;
        end

        DrawTheDots;
    end
    seqTiming=seqTiming+params.prescanDuration;
end
patternCounter=0;

% if strcmp(params.experiment,'One Dot Sizes Constant Step pRF full blanks TR=2.1, nTRs=2') || strcmp(params.experiment,'One Dot Sizes pRF full blanks TR=2.1, nTRs=2')
%     %Contrast/luminance distributions
% %     params.sizeLuminance=uint32(zeros(n+180,n+180,15));
% %     params.sizeContrast=uint32(zeros(n+180,n+180,15));
%     %Images of dots    
%     params.sizeLuminance=uint32(zeros(n+180,n+180,windowPositions*3));
%     params.sizeContrast=uint32(zeros(n+180,n+180,windowPositions*3));
% else
%     params.numberLuminance=uint32(zeros(n,n,8));
%     params.numberContrast=uint32(zeros(n,n,8));
% end
%tic
winPos2=(params.prescanDuration/params.tr)*(uint16(framesPerPosition)/uint16(framesPerPattern));

for cycle=1:params.ncycles;
%     cycle
%     toc
    for winPos = 1:windowPositions;


        
        ndots=params.dotOrder(winPos);
        if randomOrder==1
            if params.conditionOrder(winPos)==1;
                params.experiment='Dots Area pRF full blanks TR=1.5, nTRs=3';
                params.equalArea = 1;
                dotSizeIn = 3*(7/2)^2*pi;
                dotColors = [0 0 0; 0 0 0];
            elseif params.conditionOrder(winPos)==2;
                params.experiment='Dots Size pRF full blanks TR=1.5, nTRs=3';
                params.equalArea = 0;
                dotSize = 7;
                dotColors = [0 0 0; 0 0 0];
            elseif params.conditionOrder(winPos)==3;
                params.experiment='Dots Circumference pRF full blanks TR=1.5, nTRs=3';
                params.equalArea = 2;
                dotSizeIn = 19*pi*3;
                dotColors = [0 0 0; 0 0 0];
            elseif params.conditionOrder(winPos)==4;
                params.experiment='Dots Dense pRF full blanks TR=1.5, nTRs=3';
                params.equalArea = 3;
                dotSizeIn = 3*(7/2)^2*pi;
                dotColors = [0 0 0; 0 0 0];  
            elseif params.conditionOrder(winPos)==5;    
                params.experiment='Dots Shapes pRF full blanks TR=1.5, nTRs=3';
                params.equalArea = 0;
                dotSize = 7;
                dotColors = [0 0 0; 0 0 0];                
            elseif params.conditionOrder(winPos)==6;
                params.experiment='Dots Size pRF full blanks TR=1.5, nTRs=3';
                params.equalArea = 0;
                dotSize = 7;
                dotColors = [255 255 255; 255 255 255];
            end
            dotSize=dotSize/1.106;
            dotSizeIn=dotSizeIn/1.106;
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
            % case for larger dot sizes experiments
            switch params.experiment
                case {'Dots Area pRF full blanks 4degree high numbers TR=1.95, nTRs=2', 'Dots Area pRF full blanks 4degree low numbers TR=1.95, nTRs=2'}
                    if ndots==2
                        recheckDist=1.6; % Higher = Always same distance between dots
                    elseif ndots==3
                        recheckDist=1.6; % Higher = sloppy
                    elseif ndots==4  
                        recheckDist=1.6; % Higher = sloppy
                    elseif ndots==5
                        recheckDist=1.6; % Higher = sloppy
                    elseif ndots==6
                        recheckDist=1.6; % Higher = sloppy
                    elseif ndots==7
                        recheckDist=1.6; % Higher = sloppy
                    elseif ndots==8
                        recheckDist=1.6; % Higher = sloppy
                    elseif ndots==9;
                        recheckDist=1.6; % Higher = sloppy
                    elseif ndots==16;
                        recheckDist=1.6; % Higher = sloppy
                    elseif ndots==25;
                        recheckDist=1.6; % Higher = sloppy
                    elseif ndots==32;
                        recheckDist=1.6; % Higher = sloppy
                    elseif ndots==36;
                        recheckDist=1.6; % Higher = sloppy
                    elseif ndots==49;
                        recheckDist=1.6; % Higher = sloppy
                    elseif ndots==64;
                        recheckDist=1.6; % Higher = sloppy
                    elseif ndots==400;
                        recheckDist=1.44; % Higher = sloppy
                    elseif ndots==512;
                        recheckDist=1.42; % Higher = sloppy
                    elseif ndots==20;
                        recheckDist=1.6; % Higher = sloppy
                    else 
                        recheckDist=1.5;
                    end
            end
%             tic;
%             dotGroup=newDotPattern(params, ndots,n, dotSize, recheckDist)
%             toc
        elseif params.equalArea ==2;
            dotSize = dotSizeIn/ndots/pi;
%             if strcmp(params.experiment,'Dots Size pRF full blanks TR=1.95, nTRs=2')
%                 if ndots==2
%                     recheckDist=1.15/0.7;
%                 elseif ndots==3
%                     recheckDist=1.5/0.7;
%                 elseif ndots==4
%                     recheckDist=1.9/0.7;
%                 elseif ndots==5
%                     recheckDist=2.1/0.8;
%                 elseif ndots==6
%                     recheckDist=2.3/0.8;
%                 elseif ndots==7
%                     recheckDist=2.5/0.8;
%                 else
%                     recheckDist=4.25;
%                 end
%             else
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
            %end
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
                recheckDist=2.4;%1.15;%2.5 at n=n/2;
            elseif ndots==3 
                recheckDist=2.2;%1.15;%2.2
            elseif ndots==4
                recheckDist=2;%1.15;%2
            elseif ndots==5
                recheckDist=2;%1.2;%2
            elseif ndots==6
                recheckDist=2;%1.2;%2
            elseif ndots==7
                recheckDist=2;%1.2;%2
            else
                recheckDist=1.8;%1.2;%2
            end
        elseif params.equalArea ==4
            if ndots>0;
                if strcmp(params.experiment,'One Dot Luminance pRF full blanks TR=2.1, nTRs=2')
                    if ndots==max(params.dotOrder)
                        dotSize=ndots;
                        dotLum=1;
                    else
                        dotSize=params.dotOrder(14);
                        dotLum=ndots^2./params.dotOrder(14)^2;
                        if dotLum<(1/127); 
                            dotLum=(1/127);
                        end
                    end
                else
                    dotSize = ndots;
                 end
                ndots=1;
            end


%             tic;
%             dotGroup=newDotPatternDense(ndots,n, dotSize, recheckDist)
%             toc
        end

%         %THIS LOOP GENER
%         if params.equalArea==3ATES A NEW DOT PATTERN FOR EACH TR
%             dotGroup=newDotPatternDense(ndots,n, dotSize, recheckDist);
%         else
%             dotGroup=newDotPattern(params, ndots,n, dotSize, recheckDist);%2);
%         end


        %stimulus.orientations(winPos)
        
        
        %COPYS THE DOT PATTERN TO THE FRAME BUFFER FOR THE NUMBER OF FRAMES IN EACH TR
        for frame=1:framesPerPosition;
%             if strcmp(params.experiment, 'Dots In Noise pRF full blanks TR=1.5, nTRs=3')
%                 Screen('DrawTexture', display.windowPtr, stimulus.texturesBG(1));%mod(ceil(((((winPos-1)+((cycle-1)*windowPositions))*framesPerPosition)+frame-framesOn)/framesPerPattern),10)+1));%,[],rect); 
%             else
%                 if strcmp(params.calibration, '7T_UMC_1024x768')
%                     Screen('FillRect', display.windowPtr, [0 0 0], [0 0 1024 768]);
%                     Screen('FillRect', display.windowPtr, [128 128 128], [171 0 1024-171 512]);
%                 elseif strcmp(params.calibration, '7T_DLP_1600x900')
%                     Screen('FillRect', display.windowPtr, [0 0 0], [0 0 1600 900]);
%                     %Screen('FillRect', display.windowPtr, [128 128 128], [800-296 0 800+296 444]);
%                     Screen('FillRect', display.windowPtr, [128 128 128], [800-344 0 800+344 516]);
%                 else
%                     Screen('FillRect', display.windowPtr, [128 128 128], rect );
%                 end
%             end
            %ndots=ceil(rand(1)*6);
            
            %switch lower(params.whichStim)
            
            %case 'dots'
            if ndots>0
                
                %Generates new dot patterns when refresh is needed
                if uint8(mod(frame,framesPerPattern))==1;
                    fixSeqCounter=fixSeqCounter+1;
                    if params.equalArea==3
                        dotGroup=newDotPatternDense(ndots,n, dotSize, recheckDist);
                    elseif strcmp(params.experiment,'Numbers Size pRF full blanks TR=1.5, nTRs=3') || strcmp(params.experiment,'Number Symbols pRF full blanks TR=2.1, nTRs=2')
                        center=rand(1,2)*n;
                        while sqrt((center(1)-0.5*n)^2+(center(2)-0.5*n)^2)>0.5*n-dotSize/2
                            center = rand(1,2)*n;
                        end
                    elseif strcmp(params.experiment,'One Dot Sizes Constant Step pRF full blanks TR=2.1, nTRs=2')
                        distance=5.5;
                        dotGroup=newDotPatternConstantStep(params, ndots,n, dotSize, dotGroup, distance);
                        %if frame==1
                        %    dontDisplay=1;
                        %else
                            %dontDisplay=0;
                        %end
%                     elseif strcmp(params.experiment,'One Dot Luminance pRF full blanks TR=2.1, nTRs=2')
%                         %if dotSize==max(params.dotOrder)
%                             dotGroup=newDotPattern(params, ndots,n, dotSize, 0);
% %                         else
% %                             dotGroup=newDotPattern(params, ndots,n, dotSize, 0);
% %                         end
                    else
                        %dotGroup=[37 5; 37 15; 37 25; 37 35; 37 45; 37 55; 37 65];
                        dotGroup=newDotPattern(params, ndots,n, dotSize, recheckDist);%2);
                        lineDirection=rand(1)*2*pi;
                    end
                    patternCounter=patternCounter+1;
                    % params.convexHull(patternCounter)=convexHull(dotGroup, dotSize);
                    %
                    %                     if strcmp(params.experiment,'One Dot Sizes Constant Step pRF full blanks TR=2.1, nTRs=2') || strcmp(params.experiment,'One Dot Sizes pRF full blanks TR=2.1, nTRs=2')
                    %                         if dotSize==180
                    %                             patternIndex=15;
                    %                         else
                    %                             patternIndex=uint8(round(dotSize+2)/5);
                    %                         end
                    %                         Screen('FillRect', display.windowPtr, [0 0 0], rect );
                    %                         if dotSize<=62
                    %                             Screen('DrawDots',display.windowPtr, double(dotGroup'), double(dotSize), double([1 1 1]), [display.Rect(1) display.Rect(2)],1);
                    %                         else
                    %                             Screen('FillOval', display.windowPtr, double([1 1 1]), [display.Rect(1)+double(dotGroup(:,1)')-dotSize/2 display.Rect(2)+double(dotGroup(:,2)')-dotSize/2 display.Rect(1)+double(dotGroup(:,1)')+dotSize/2 display.Rect(2)+double(dotGroup(:,2)')+dotSize/2]);
                    %                         end
                    %                         Screen('Flip',display.windowPtr);
                    %                         imageArray=Screen('GetImage', display.windowPtr, display.Rect+[-90 -90 +90 +90]');
                    %                         params.sizeLuminance(:,:,patternIndex)=params.sizeLuminance(:,:,patternIndex)+uint32(imageArray(:,:,1));
                    %
                    %                         Screen('FillRect', display.windowPtr, [0 0 0], rect );
                    %                         if dotSize<=62
                    %                             Screen('DrawDots',display.windowPtr, double(dotGroup'), double(dotSize+1), double([1 1 1]), [display.Rect(1) display.Rect(2)],1);
                    %                             Screen('DrawDots',display.windowPtr, double(dotGroup'), double(dotSize-1), double([0 0 0]), [display.Rect(1) display.Rect(2)],1);
                    %                         else
                    %                             Screen('FillOval', display.windowPtr, double([1 1 1]), [display.Rect(1)+double(dotGroup(:,1)')-dotSize/2-1 display.Rect(2)+double(dotGroup(:,2)')-dotSize/2-1 display.Rect(1)+double(dotGroup(:,1)')+dotSize/2+1 display.Rect(2)+double(dotGroup(:,2)')+dotSize/2+1]);
                    %                             Screen('FillOval', display.windowPtr, double([0 0 0]), [display.Rect(1)+double(dotGroup(:,1)')-dotSize/2+1 display.Rect(2)+double(dotGroup(:,2)')-dotSize/2+1 display.Rect(1)+double(dotGroup(:,1)')+dotSize/2-1 display.Rect(2)+double(dotGroup(:,2)')+dotSize/2-1]);
                    %                         end
                    %                         Screen('Flip',display.windowPtr);
                    %                         imageArray=Screen('GetImage', display.windowPtr, display.Rect+[-90 -90 +90 +90]');
                    %                         params.sizeContrast(:,:,patternIndex)=params.sizeContrast(:,:,patternIndex)+uint32(imageArray(:,:,1));
                    %                     else
                    %                         if ndots==20
                    %                             patternIndex=8;
                    %                         else
                    %                             patternIndex=ndots;
                    %                         end
                    %                         Screen('FillRect', display.windowPtr, [0 0 0], rect );
                    %                         if dotSize<=62
                    %                             Screen('DrawDots',display.windowPtr, double(dotGroup'), double(dotSize), double([1 1 1]), [display.Rect(1) display.Rect(2)],1);
                    %                         else
                    %                             Screen('FillOval', display.windowPtr, double([1 1 1]), [display.Rect(1)+double(dotGroup(:,1)')-dotSize/2 display.Rect(2)+double(dotGroup(:,2)')-dotSize/2 display.Rect(1)+double(dotGroup(:,1)')+dotSize/2 display.Rect(2)+double(dotGroup(:,2)')+dotSize/2]);
                    %                         end
                    %                         Screen('Flip',display.windowPtr);
                    %                         imageArray=Screen('GetImage', display.windowPtr, display.Rect);
                    %                         params.numberLuminance(:,:,patternIndex)=params.numberLuminance(:,:,patternIndex)+uint32(imageArray(:,:,1));
                    %
                    %                         Screen('FillRect', display.windowPtr, [0 0 0], rect );
                    %                         if dotSize<=62
                    %                             Screen('DrawDots',display.windowPtr, double(dotGroup'), double(dotSize+1), double([1 1 1]), [display.Rect(1) display.Rect(2)],1);
                    %                             Screen('DrawDots',display.windowPtr, double(dotGroup'), double(dotSize-1), double([0 0 0]), [display.Rect(1) display.Rect(2)],1);
                    %                         else
                    %                             Screen('FillOval', display.windowPtr, double([1 1 1]), [display.Rect(1)+double(dotGroup(:,1)')-dotSize/2-1 display.Rect(2)+double(dotGroup(:,2)')-dotSize/2-1 display.Rect(1)+double(dotGroup(:,1)')+dotSize/2+1 display.Rect(2)+double(dotGroup(:,2)')+dotSize/2+1]);
                    %                             Screen('FillOval', display.windowPtr, double([0 0 0]), [display.Rect(1)+double(dotGroup(:,1)')-dotSize/2+1 display.Rect(2)+double(dotGroup(:,2)')-dotSize/2+1 display.Rect(1)+double(dotGroup(:,1)')+dotSize/2-1 display.Rect(2)+double(dotGroup(:,2)')+dotSize/2-1]);
                    %                         end
                    %                         Screen('Flip',display.windowPtr);
                    %                         imageArray=Screen('GetImage', display.windowPtr, display.Rect);
                    %                         params.numberContrast(:,:,patternIndex)=params.numberContrast(:,:,patternIndex)+uint32(imageArray(:,:,1));
                    %                     end
%                     if strcmp(params.experiment,'One Dot Sizes Constant Step pRF full blanks TR=2.1, nTRs=2') || strcmp(params.experiment,'One Dot Sizes pRF full blanks TR=2.1, nTRs=2')
% %                         if dotSize==180
% %                             patternIndex=15;
% %                         else
% %                             patternIndex=uint8(round(dotSize+2)/5);
% %                         end
%                         Screen('FillRect', display.windowPtr, [0 0 0], rect );
%                         patternIndex=(floor(frame/framesPerPattern)+1)+(winPos-1)*3;%-mod(winPos,6)+1;
%                         
%                         if dotSize<=62
%                             Screen('DrawDots',display.windowPtr, double(dotGroup'), double(dotSize), double([1 1 1]), [display.Rect(1) display.Rect(2)],1);
%                         else
%                             Screen('FillOval', display.windowPtr, double([1 1 1]), [display.Rect(1)+double(dotGroup(:,1)')-dotSize/2 display.Rect(2)+double(dotGroup(:,2)')-dotSize/2 display.Rect(1)+double(dotGroup(:,1)')+dotSize/2 display.Rect(2)+double(dotGroup(:,2)')+dotSize/2]);
%                         end
%                         Screen('Flip',display.windowPtr);
%                         imageArray=Screen('GetImage', display.windowPtr, display.Rect+[-90 -90 +90 +90]');
%                         params.sizeLuminance(:,:,patternIndex)=params.sizeLuminance(:,:,patternIndex)+uint32(imageArray(:,:,1));
%                         
% %                         Screen('FillRect', display.windowPtr, [0 0 0], rect );
% %                         if dotSize<=62
% %                             Screen('DrawDots',display.windowPtr, double(dotGroup'), double(dotSize+1), double([1 1 1]), [display.Rect(1) display.Rect(2)],1);
% %                             Screen('DrawDots',display.windowPtr, double(dotGroup'), double(dotSize-1), double([0 0 0]), [display.Rect(1) display.Rect(2)],1);
% %                         else
% %                             Screen('FillOval', display.windowPtr, double([1 1 1]), [display.Rect(1)+double(dotGroup(:,1)')-dotSize/2-1 display.Rect(2)+double(dotGroup(:,2)')-dotSize/2-1 display.Rect(1)+double(dotGroup(:,1)')+dotSize/2+1 display.Rect(2)+double(dotGroup(:,2)')+dotSize/2+1]);
% %                             Screen('FillOval', display.windowPtr, double([0 0 0]), [display.Rect(1)+double(dotGroup(:,1)')-dotSize/2+1 display.Rect(2)+double(dotGroup(:,2)')-dotSize/2+1 display.Rect(1)+double(dotGroup(:,1)')+dotSize/2-1 display.Rect(2)+double(dotGroup(:,2)')+dotSize/2-1]);
% %                         end
% %                         Screen('Flip',display.windowPtr);
% %                         imageArray=Screen('GetImage', display.windowPtr, display.Rect+[-90 -90 +90 +90]');
% %                         params.sizeContrast(:,:,patternIndex)=params.sizeContrast(:,:,patternIndex)+uint32(imageArray(:,:,1));
%                     end

                    randTmp=rand(1);
                    if randTmp<oneBackFrequency && fixSeqAdder==1
                        fixSeqAdder=2;%3-fixSeqAdder;
                        %stimulus.fixSeq(fixSeqCounter)=fixSeqAdder;
                        colorEvents=[colorEvents GetSecs-t0];
                    else
                        fixSeqAdder=1;
                    end
                    if strcmp(params.experiment,'Dots Shapes pRF full blanks TR=1.5, nTRs=3') || strcmp(params.experiment,'Dots Shapes pRF full blanks TR=2.1, nTRs=2')
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
                        
                        %quantifyShapes;
                        
                        %Screen('DrawDots',display.windowPtr, double(dotGroup'), 8, [255 255 255], [display.Rect(1) display.Rect(2)],1);
                    elseif strcmp(params.experiment,'Numbers Size pRF full blanks TR=1.5, nTRs=3')
                        %Screen('DrawDots',display.windowPtr, double(center'), double(dotSize), 255-double(dotColors(fixSeqAdder,:)), [display.Rect(1) display.Rect(2)],1);
                        if ndots>10
                            Screen('DrawText', display.windowPtr, num2str(ndots), double(center(1)+display.Rect(1)-dotSize*.8), double(center(2)+display.Rect(2)-dotSize*1.05), double(dotColors(fixSeqAdder,:))); 
                        else    
                            Screen('DrawText', display.windowPtr, num2str(ndots), double(center(1)+display.Rect(1)-dotSize*.4), double(center(2)+display.Rect(2)-dotSize*1.05), double(dotColors(fixSeqAdder,:))); 
                        end
                    elseif strcmp(params.experiment,'Number Symbols pRF full blanks TR=2.1, nTRs=2')
                        if uint8(mod(winPos, 2))==1 && frame==1
                            oldLetterIndex=letterIndex;
                            while letterIndex==oldLetterIndex;
                                letterIndex=ceil(rand*length(letterList));
                            end
                        end
                        if ndots<10
                            Screen('DrawText', display.windowPtr, num2str(ndots), double(center(1)+display.Rect(1)-dotSize*.4), double(center(2)+display.Rect(2)-dotSize*1.05), double(dotColors(fixSeqAdder,:)));
                        else
                            stimulus.letterSeq(fixSeqCounter)=letterIndex;
                            Screen('DrawText', display.windowPtr, letterList{letterIndex}, double(center(1)+display.Rect(1)-dotSize*.4), double(center(2)+display.Rect(2)-dotSize*1.05), double(dotColors(fixSeqAdder,:)));
                        end
                    elseif strcmp(params.experiment,'One Line Size Random Orientation pRF full blanks TR=2.1, nTRs=2')  
                        Screen('DrawLines',display.windowPtr, [double(dotGroup')+[sin(lineDirection); cos(lineDirection)].*(dotSize/2) double(dotGroup')-[sin(lineDirection); cos(lineDirection)].*(dotSize/2)], double(3), double(dotColors(fixSeqAdder,:)), [display.Rect(1) display.Rect(2)],1);
                    
                    elseif strcmp(params.experiment,'One Dot Luminance pRF full blanks TR=2.1, nTRs=2')
                        if dotSize<=62
                            Screen('DrawDots',display.windowPtr, double(dotGroup'), double(dotSize), (double(dotColors(fixSeqAdder,:))-128).*dotLum+128, [display.Rect(1) display.Rect(2)],1);
                        else
                            Screen('FillOval', display.windowPtr, (double(dotColors(fixSeqAdder,:))-128).*dotLum+128, [display.Rect(1)+double(dotGroup(:,1)')-dotSize/2 display.Rect(2)+double(dotGroup(:,2)')-dotSize/2 display.Rect(1)+double(dotGroup(:,1)')+dotSize/2 display.Rect(2)+double(dotGroup(:,2)')+dotSize/2]);      
                        end   
                    else
                        if dotSize<=62
                            Screen('DrawDots',display.windowPtr, double(dotGroup'), double(dotSize), double(dotColors(fixSeqAdder,:)), [display.Rect(1) display.Rect(2)],1);
                        else
                            Screen('FillOval', display.windowPtr, double(dotColors(fixSeqAdder,:)), [display.Rect(1)+double(dotGroup(:,1))-dotSize/2 display.Rect(2)+double(dotGroup(:,2))-dotSize/2 display.Rect(1)+double(dotGroup(:,1))+dotSize/2 display.Rect(2)+double(dotGroup(:,2))+dotSize/2]');      
                        end
                    end
                    
                    %Save dot positions
                    response.dotPositions{(cycle-1)*windowPositions*uint16(framesPerPosition)/uint16(framesPerPattern)+winPos2+(winPos-1)*(params.tr./dotRefresh)+uint16(frame)/uint16(framesPerPattern)+1}=dotGroup;
                    %Analyse images
                    %fourierContrastEnergy;
                    
                elseif uint8(mod(frame,framesPerPattern)) <= framesPerPattern - grayFrames && mod(frame,framesPerPattern)> 0;
                    if strcmp(params.experiment,'Dots Shapes pRF full blanks TR=1.5, nTRs=3') || strcmp(params.experiment,'Dots Shapes pRF full blanks TR=2.1, nTRs=2')
                        %Screen('DrawDots',display.windowPtr, double(dotGroup'), 8, [255 255 255], [display.Rect(1) display.Rect(2)],1); 
                        for shapeCounter=1:ndots
                            Screen('glTranslate', display.windowPtr, dotGroup(shapeCounter,1)+display.Rect(1), dotGroup(shapeCounter,2)+display.Rect(2));
                            Screen('glRotate', display.windowPtr, uniAngles(shapeCounter));
                            Screen('TextSize', display.windowPtr, unicodesSizes(shapeCounter));
                            Screen('DrawText', display.windowPtr, unicodes(shapeCounter), -uniXoffset(shapeCounter), -uniYoffset(shapeCounter), double(dotColors(fixSeqAdder,:)));
                            Screen('glRotate', display.windowPtr, 0-uniAngles(shapeCounter));
                            Screen('glTranslate', display.windowPtr, -(dotGroup(shapeCounter,1)+display.Rect(1)), -(dotGroup(shapeCounter,2)+display.Rect(2)));                 
                        end
                    elseif strcmp(params.experiment,'Numbers Size pRF full blanks TR=1.5, nTRs=3')
                        %Screen('DrawDots',display.windowPtr, double(center'), double(dotSize), 255-double(dotColors(fixSeqAdder,:)), [display.Rect(1) display.Rect(2)],1);
                        if ndots>10
                            Screen('DrawText', display.windowPtr, num2str(ndots), double(center(1)+display.Rect(1)-dotSize*.8), double(center(2)+display.Rect(2)-dotSize*1.05), double(dotColors(fixSeqAdder,:))); 
                        else    
                            Screen('DrawText', display.windowPtr, num2str(ndots), double(center(1)+display.Rect(1)-dotSize*.4), double(center(2)+display.Rect(2)-dotSize*1.05), double(dotColors(fixSeqAdder,:))); 
                        end
                    elseif strcmp(params.experiment,'Number Symbols pRF full blanks TR=2.1, nTRs=2')
                            if ndots<10
                                Screen('DrawText', display.windowPtr, num2str(ndots), double(center(1)+display.Rect(1)-dotSize*.4), double(center(2)+display.Rect(2)-dotSize*1.05), double(dotColors(fixSeqAdder,:)));
                            else
                                Screen('DrawText', display.windowPtr, letterList{letterIndex}, double(center(1)+display.Rect(1)-dotSize*.4), double(center(2)+display.Rect(2)-dotSize*1.05), double(dotColors(fixSeqAdder,:)));
                            end
                    elseif strcmp(params.experiment,'One Line Size Random Orientation pRF full blanks TR=2.1, nTRs=2')  
                        Screen('DrawLines',display.windowPtr, [double(dotGroup')+[sin(lineDirection); cos(lineDirection)].*(dotSize/2) double(dotGroup')-[sin(lineDirection); cos(lineDirection)].*(dotSize/2)], double(3), double(dotColors(fixSeqAdder,:)), [display.Rect(1) display.Rect(2)],1);
                    elseif strcmp(params.experiment,'One Dot Luminance pRF full blanks TR=2.1, nTRs=2')
                        if dotSize<=62
                            Screen('DrawDots',display.windowPtr, double(dotGroup'), double(dotSize), (double(dotColors(fixSeqAdder,:))-128).*dotLum+128, [display.Rect(1) display.Rect(2)],1);
                        else
                            Screen('FillOval', display.windowPtr, (double(dotColors(fixSeqAdder,:))-128).*dotLum+128, [display.Rect(1)+double(dotGroup(:,1)')-dotSize/2 display.Rect(2)+double(dotGroup(:,2)')-dotSize/2 display.Rect(1)+double(dotGroup(:,1)')+dotSize/2 display.Rect(2)+double(dotGroup(:,2)')+dotSize/2]);      
                        end
                    else
                        if dotSize<=62
                            Screen('DrawDots',display.windowPtr, double(dotGroup'), double(dotSize), double(dotColors(fixSeqAdder,:)), [display.Rect(1) display.Rect(2)],1);
                        else
                            Screen('FillOval', display.windowPtr, double(dotColors(fixSeqAdder,:)), [display.Rect(1)+double(dotGroup(:,1))-dotSize/2 display.Rect(2)+double(dotGroup(:,2))-dotSize/2 display.Rect(1)+double(dotGroup(:,1))+dotSize/2 display.Rect(2)+double(dotGroup(:,2))+dotSize/2]');      
                        end
                    end
                end
            else
                if uint8(mod(frame,framesPerPattern))==1;
                    fixSeqCounter=fixSeqCounter+1;
                    randTmp=rand(1);
                    if randTmp<oneBackFrequency && fixSeqAdder==1
                        fixSeqAdder=2;%3-fixSeqAdder;
                        %stimulus.fixSeq(fixSeqCounter)=fixSeqAdder;
                        colorEvents=[colorEvents GetSecs-t0];
                    else
                        fixSeqAdder=1;
                    end
                end
                if uint8(mod(frame,framesPerPattern)) <= framesPerPattern - grayFrames && mod(frame,framesPerPattern)> 0 && params.equalArea ==4;
                    Screen('FillRect', display.windowPtr, double(dotColors(fixSeqAdder,:)), rect );
                end
            end
            
            
            drawFixation(display,1);

            %CONTINUES WAITING UNTIL THE NEXT FRAME WHILE LOOKING FOR RESPONSES
            %AND OTHER INPUTS
            %waitTime =
            %(GetSecs-t0)-(stimulus.seqtiming(winPos)+(stimFrame*frame));
            waitTime = (GetSecs-t0)-(seqTiming(winPos+((cycle-1)*windowPositions))+(stimFrame*frame));
            %waitTime=0;
            %--- get inputs (subject or experimentor)
            if waitTime>0
                waitTime
                ndots
            end
            while(waitTime<0),
                % Scan the UMC device for subject response
%                 [ssKeyCode,ssSecs] = deviceUMC('response_and_trigger',display.devices.UMCport);
%                 
%                 if ssKeyCode(1)==65 || ssKeyCode(1)==66 || ssKeyCode(1)==67 || ssKeyCode(1)==68
%                         %stimulus.fixResponse(fixSeqCounter)=2;
%                         responses=[responses GetSecs-t0];
%                 end;
                
                % scan the keyboard for experimentor input
                [exKeyIsDown exSecs exKeyCode] = KbCheck(display.devices.keyInputInternal);
                if(exKeyIsDown)
                    if(exKeyCode(quitProgKey)),
                        quitProg = 1;
                        break;% out of while loop
                    elseif(~exKeyCode(triggerKey))
                        %stimulus.fixResponse(fixSeqCounter)=2;
                        responses=[responses GetSecs-t0];
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
%                     if isfield(display, 'Rect')
%                         imageArray=Screen('GetImage', display.windowPtr, [512-37 269-37 512+37 269+37]);%[384 141 1024-384 538-141]);%, display.Rect);
%                     else
                        imageArray=Screen('GetImage', display.windowPtr);
%                    end
                    writeVideo(aviobj,imageArray);
                    %movie=cat(3, movie, imageArray);
                    if ((winPos-1)*framesPerPosition)+frame==recordingFrames
                        close(aviobj);
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

% respNeeded=stimulus.fixSeq==2;
% respGiven=stimulus.fixResponse==2;
% 
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
response.colorEvents=colorEvents;
response.responses=responses;
acceptedResponseTime=3;
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

if strcmp(params.experiment,'Dots Shapes pRF full blanks TR=1.5, nTRs=3') || strcmp(params.experiment,'Dots Shapes pRF full blanks TR=2.1, nTRs=2')
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
        elseif dotSize>=n
            while sqrt((tempDotPattern(1,1)-0.5*n)^2+(tempDotPattern(1,2)-0.5*n)^2)>0.5*n
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
                        % Check whether there is an incorretc number of dots drawn
                        if params.devices.UMCport == -1
                            incorrectNumberDots(ndots, numel(dotGroup(:,1)));
                        end
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

function incorrectNumberDots(nDots, actualDots)
% Check whether the corretc numbers of dots where drawn
if nDots ~= actualDots
    disp(['incorrect number of dots displayed: ' num2str(actualDots) '/' num2str(nDots)]);
end
end

function dotGroup=newDotPatternConstantStep(params, ndots,n, dotSize, previousPattern, distance)
if ndots >0;
%    recheckCounter=1000;
%    while recheckCounter==1000
    for rdots = 1:ndots;
        if dotSize>=n
            dotSize=68;
        end
        failCounter=0;
        if sum(previousPattern)>0
               randDir=(rand(1)*2*pi)-pi;
               tempDotPattern(1,1)=previousPattern(1,1)+sin(randDir)*distance;
               tempDotPattern(1,2)=previousPattern(1,2)+cos(randDir)*distance;
            while sqrt((tempDotPattern(1,1)-0.5*n)^2+(tempDotPattern(1,2)-0.5*n)^2)>0.5*n-dotSize/2 && failCounter<200
                failCounter=failCounter+1;
               randDir=(rand(1)*2*pi)-pi;
               tempDotPattern(1,1)=previousPattern(1,1)+sin(randDir)*distance;
               tempDotPattern(1,2)=previousPattern(1,2)+cos(randDir)*distance;
            end
        end
        if sum(previousPattern)==0 || failCounter==200
            tempDotPattern = rand(1,2)*n;
            while sqrt((tempDotPattern(1,1)-0.5*n)^2+(tempDotPattern(1,2)-0.5*n)^2)>0.5*n-dotSize/2 || sqrt((tempDotPattern(1,1)-0.5*n)^2+(tempDotPattern(1,2)-0.5*n)^2)<distance/2;
                tempDotPattern = rand(1,2)*n;
            end
        end
            
            dotGroup = tempDotPattern;
    end
%    end
else dotGroup = [];
end

end

function dotGroup=newDotPatternDense(ndots, n, dotSize, recheckDistance)

newn=n/2;
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


