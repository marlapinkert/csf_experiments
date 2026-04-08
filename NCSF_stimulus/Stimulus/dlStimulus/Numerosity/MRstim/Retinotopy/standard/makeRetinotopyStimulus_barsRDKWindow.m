function [stimulus otherSequence] = makeRetinotopyStimulus_barsRDK(params)
% makeRetinotopyStimulus - make various retinotopy stimuli
%
% stimulus = makeRetinotopyStimulus_bars(params)
%
% Matlab code to generate various retinotopy stimuli
% Generates one full cycle, as well as the sequence for the entire scan.
%
% 99.09.15 RFD: I fixed the sequence generation algorithm so that
%   timing is now frame-accurate.  The algorithm now keeps track
%   of timing error that accumulates due to rounding to the nearest
%   frame and corrects for that error when it gets to be more than 
%   half a frame.  
%   The algorithm also randomely reverses the drift direction, rather
%   than reversing every half-an image duration.
% 2005.06.15 SOD: changed for OSX - stimulus presentation will now be 
%                 time-based rather than frame based. Because of bugs
%                 with framerate estimations.


% various time measurements:
duration.stimframe          = 1./params.temporal.frequency./params.temporal.motionSteps;
duration.scan.seconds       = params.ncycles*params.period;
duration.scan.stimframes    = params.ncycles*params.period./duration.stimframe;
duration.cycle.seconds      = params.period;
duration.cycle.stimframes   = params.period./duration.stimframe;
duration.prescan.seconds    = params.prescanDuration;
duration.prescan.stimframes = params.prescanDuration./duration.stimframe;

dotRadiusInDeg              =0.25;  %This will be rounded to the nearest pixel
dotDiameterInDeg            =dotRadiusInDeg*2;
orientationInDeg            =params.RDK.orientationInDeg;
orientationBPinDeg          =0;
dotSpeed                    =params.RDK.dotSpeed;   %in degrees per second
dotSpeedBPinDeg             =0;   %in degrees per second
dotDensity                  =1/(dotRadiusInDeg^2*pi);                        %7.5;    %in dots per square degree
dotLifeTime                 =1;%0.15;   %in seconds. Must be multiple of 0.05. For unlimited lifetime, set to zero

reversalMin                 =params.tr/4;
reversalMax                 =params.tr/2;

blanksAfterPass=1;
blankTime=30;

if blanksAfterPass==1;
    totalBlankTime   = 4.*ceil(blankTime./params.tr).*params.tr;
    barPassTime=duration.cycle.seconds-totalBlankTime;
    numBarImages=params.numImages-(totalBlankTime./params.tr);
    barPassFrames=barPassTime/duration.stimframe;
else
    barPassTime=duration.cycle.seconds;
    numBarImages=params.numImages;
    barPassFrames=duration.cycle.stimframes;
end




% load matrix or make it
if ~isempty(params.loadMatrix),
    % we should really put some checks that the matrix loaded is
    % appropriate etc.
    load(params.loadMatrix);
    halfNumImages = params.numImages./2;
    disp(sprintf('[%s]:loading images from %s.',mfilename,params.loadMatrix));
%    disp(sprintf('[%s]:size stimulus: %dx%d pixels.',mfilename,n,m));
else
    outerRad = params.radius;
    innerRad = params.innerRad;
    wedgeWidth = params.wedgeWidth;
    ringWidth = params.ringWidth;

    halfNumImages = numBarImages./2;
    numMotSteps = params.temporal.motionSteps;
    numSubRings = params.numSubRings;
    numSubWedges = params.numSubWedges;

    %%% Set check colormap indices %%%
    %bk = findName(params.display.reservedColor,'background');
    %minCmapVal = max([params.display.reservedColor(:).fbVal])+1;
    %maxCmapVal = params.display.numColors-1;
    bk = params.display.backColorIndex;
    
    minCmapVal = min([params.display.stimRgbRange]);
    maxCmapVal = max([params.display.stimRgbRange]);


    %%% Initialize image template %%%
    m=angle2pix(params.display,2*outerRad); 
    n=angle2pix(params.display,2*outerRad);
    
    % should really do something more intelligent, like outerRad-fix
    switch(lower(params.display.fixType))
        case 'left disk',
            [x,y]=meshgrid(linspace( 0,outerRad*2,n),linspace(outerRad,-outerRad,m));
            outerRad = outerRad.*2;
        case 'right disk',
            [x,y]=meshgrid(linspace(-outerRad*2,0,n),linspace(outerRad,-outerRad,m));
            outerRad = outerRad.*2;
        otherwise,
            [x,y]=meshgrid(linspace(-outerRad,outerRad,n),linspace(outerRad,-outerRad,m));
    end;
    
    % here we crop the image if it is larger than the screen 
    % seems that you have to have a square matrix, bug either in my or
    % psychtoolbox' code - so we make it square
    if m>params.display.numPixels(2),
        start  = round((m-params.display.numPixels(2))/2);
        len    = params.display.numPixels(2);
        y = y(start+1:start+len, start+1:start+len);
        x = x(start+1:start+len, start+1:start+len);
        m = len;
        n = len;
    end;
    disp(sprintf('[%s]:size stimulus: %dx%d pixels.',mfilename,n,m));

    % r = eccentricity; theta = polar angle
    r = sqrt (x.^2  + y.^2);
    theta = atan2 (y, x);					% atan2 returns values between -pi and pi
    theta(theta<0) = theta(theta<0)+2*pi;	% correct range to be between 0 and 2*pi

    
    % loop over different orientations and make checkerboard
    % first define which orientations
    orientations = (0:45:360)./360*(2*pi); % degrees -> rad
    orientations = orientations([3 2 5 4 7 6 1 8]);  %[6 3 8 5 2 7 4 1]);
    remake_xy    = zeros(1,numBarImages)-1;
    remake_xy(1:length(remake_xy)/length(orientations):length(remake_xy)) = orientations;
    original_x   = x;
    original_y   = y;
    % step size of the bar
    step_nx      = barPassTime./params.tr/8;
    step_x       = (2*outerRad) ./ step_nx;
    step_startx  = (step_nx-1)./2.*-step_x - (ringWidth./2);
    %[0:step_nx-1].*step_x+step_startx+ringWidth./2
    disp(sprintf('[%s]:stepsize: %f degrees.',mfilename,step_x));
    
    %Dot pattern stimulus parameters (to avoid repeated recalculation)
    ppd=n./(params.radius*2);
    dotDiameterInPix = round(dotDiameterInDeg .*ppd);
    fRate=1/duration.stimframe;
    dotSpeedInPix = dotSpeed * ppd / fRate; 
    dotSpeedBPinPix=dotSpeedBPinDeg*ppd/fRate;
    ndots=round((params.radius*2)^2.*dotDensity);
    directionReversalMin=round(reversalMin*fRate);
    directionReversalMax=round(reversalMax*fRate);
    dotColors = uint8(255.*round(rand(ndots,1)));
    dotColors = transpose(repmat(dotColors, [1 3]));
    dotDuration=barPassFrames/(8*step_nx);
    windowFrame=(ndots*dotDuration/step_nx);
    dotLifeTime=dotLifeTime*fRate;
    
    dotDisplayParams.size=dotDiameterInPix;
    dotDisplayParams.colors=dotColors;
    
    maxSignalDotsList=[];%[20 47 64 75 84 86 99 99 99 100];%[11 27 36 42 46 48 50 53 54 55];%[20 47 64 75 84 86 99 99 99 100];%[20 25 31 34 36 38 39 40 41 42];
    maxSignalDotsList=[maxSignalDotsList fliplr(maxSignalDotsList)];
    
    % if we create colored bars we want to make the edges soft.
    switch params.experiment,
        case {'8 bars (LMS) with blanks'}
            edgewidth = 25; % .25cpd on a 600 pixel(3deg screen)
            softmask  = makecircle(m-2*edgewidth,m,edgewidth);
        otherwise,
            softmask = ones(m);
    end;

    % Loop that creates the final images
    fprintf('[%s]:Creating %d images:',mfilename,halfNumImages);
    %images=zeros(m,n,halfNumImages*params.temporal.motionSteps,'uint8');
    dots=[];
    dotsAll=[];
    windowCounter=0;
    warning('off', 'MATLAB:concatenation:integerInteraction');

    for imgNum=1:halfNumImages
        
        if remake_xy(imgNum) >=0,
            loX = step_startx - step_x;
        end;


        loEcc = innerRad;
        hiEcc = outerRad;
        loX   = loX + step_x;
        hiX   = loX + ringWidth;

        % This isn't as bad as it looks
        % Can fiddle with this to clip the edges of an expanding ring - want the ring to completely 
        % disappear from view before it re-appears again in the middle.

        % Can we do this just be removing the second | from the window
        % expression? so...
              
        if remake_xy(imgNum) >=0,
            x = original_x .* cos(remake_xy(imgNum)) - original_y .* sin(remake_xy(imgNum));
            y = original_x .* sin(remake_xy(imgNum)) + original_y .* cos(remake_xy(imgNum));
            % Calculate checkerboard.
            % Wedges alternating between -1 and 1 within stimulus window.
            % The computational contortions are to avoid sign=0 for sin zero-crossings
            if orientationInDeg==999;
                absoluteOrientation=999;
            else
                absoluteOrientation=90+orientationInDeg+(remake_xy(imgNum)/(2*pi)*360);
            end
            stepNumber=0;
        end;
        
        stepNumber=stepNumber+1;
        
        window = ( (x>=loX & x<=hiX) & r<outerRad);
        [windowx windowy]=find(window==1);
        window2=uint16([windowx windowy]);
        
        dots=dotPattern(n, absoluteOrientation,orientationBPinDeg, dotSpeedInPix, dotSpeedBPinPix, dotDuration, ndots, directionReversalMin, directionReversalMax, dotLifeTime, 100, window2, maxSignalDotsList, stepNumber);

        dots=reshape(transpose(dots), 2, ndots, dotDuration);
        dotsAll=cat(3, dotsAll, dots);
        
%                 for indexFrame=1+((imgNum-1)*(dotDuration/step_nx)):(imgNum)*(dotDuration/step_nx)
%                     indexFrame
%                     for indexDot=1:size(dots,2)
%                         if uint8(window(dots(1, indexDot, indexFrame), dots(2,indexDot, indexFrame)))==0
%                             dots(:,indexDot, indexFrame)=55555;
%                             %dots(2,indexDot, indexFrame)=55555;
%                         end
%                     end
%                 end
                                                       
        fprintf('.');drawnow;
    end
    fprintf('Done.\n');
end;

if windowCounter>0
    dots(window4==0,:)=55555;
    dots=reshape(transpose(dots), 2, ndots, dotDuration);
    dotsAll=cat(3, dotsAll, dots);
end
clear dots
clear window


% insert blanks (always of for 12 seconds)
if params.insertBlanks.do,

    blankCycleFrames=size(dotsAll, 3)/4;
    
    if blanksAfterPass==1
        offTime   = ceil(blankTime./params.tr).*params.tr; % make sure it's a multiple of the tr
        offPeriod = ceil(offTime./duration.stimframe);
    
        blankInsert=ones(size(dotsAll(:,:,1:offPeriod))).*55555;
        dotsAll=cat(3, dotsAll(:,:,1:blankCycleFrames), blankInsert, dotsAll(:,:,blankCycleFrames+1:3*blankCycleFrames),blankInsert,dotsAll(:,:,3*blankCycleFrames+1:end));
    else
        offTime   = ceil(10./params.tr).*params.tr; % make sure it's a multiple of the tr
        offPeriod = ceil(offTime./duration.stimframe);
    
        for index=1:4;
            if uint8(index/2)~=index/2
                dotsAll(:,:,(index*blankCycleFrames)-offPeriod+1:(index*blankCycleFrames))=55555;
            end
        end
    end
    
    disp(sprintf('[%s]:Stimulus on for %.1f and off for %.1f seconds.',...
        mfilename,duration.scan.seconds/4-offPeriod*duration.stimframe,offPeriod*duration.stimframe));
 end;

rev=dotsAll;
rev(rev<55555)=n-rev(rev<55555);
dotsAll=cat(3, dotsAll,rev);
        

% fixation dot sequence
% change on the fastest every 6 seconds
minsec = 1.8./duration.stimframe;
fixSeq = ones(minsec,1)*round(rand(1,ceil(size(dotsAll, 3)/minsec)));
fixSeq = fixSeq(:)+1;
fixSeq = fixSeq(1:size(dotsAll, 3));
% force binary 
fixSeq(fixSeq>2)=2; 
fixSeq(fixSeq<1)=1;


% Insert the preappend images by copying some images from the
% end of the seq and tacking them on at the beginning

dotsAll=cat(3, dotsAll(:,:,size(dotsAll, 3)+1-duration.prescan.stimframes:end), dotsAll);
timing   = [0:size(dotsAll, 3)-1]'.*duration.stimframe;
%sequence = [sequence(length(sequence)+1-duration.prescan.stimframes:end); sequence];
%timing   = [0:length(sequence)-1]'.*duration.stimframe;
cmap     = params.display.gammaTable;
fixSeq   = [fixSeq(length(fixSeq)+1-duration.prescan.stimframes:end); fixSeq];





% make stimulus structure for output
stimulus = createStimulusStructRDK(dotsAll,cmap,dotDisplayParams,[],timing,fixSeq);

% save matrix if requested
  if ~isempty(params.saveMatrix),
    save(params.saveMatrix,'images');
end;

