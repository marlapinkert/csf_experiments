function [stimulus otherSequence] = makeRetinotopyStimulus_attention(params)
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

blanksAfterPass=1;  %1 (True) puts blanks after horizontal bars have passed. 0 (false) puts blanks within the bar pass
blankTime=30;       %Blank time (in seconds) will be rounded up to the nearest TR
numDiffStim= params.numDiffStim;
blanksBetween = params.ISIframes;
framesStimOn = params.StimOnFrames;

switch params.experiment
    case {'8 bars with blanks Checks Together (90) 2.5d/s','8 bars with blanks Checks Together (90) 5d/s'};
        sineChecks=0;
        softEdgeWindow=0;
    case {'8 bars with blanks (attention)', '8 bars with blanks (attention bar psychophysics)', '8 bars with blanks (attention fixation psychophysics)'};
        sineChecks=1;
        softEdgeWindow=1;
    otherwise,
        sineChecks=0;
        softEdgeWindow=0;
end
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
    numMotSteps = params.numDiffStim;
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
    orientations = orientations([3 2 5 4 7 6 1 8]);  %[3 2 5 4 7 6 1 8]   [6 3 8 5 2 7 4 1]);
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
    images=zeros(m,n,halfNumImages*numMotSteps,'uint8');
    for imgNum=1:halfNumImages
        
        if remake_xy(imgNum) >=0,
            x = original_x .* cos(remake_xy(imgNum)) - original_y .* sin(remake_xy(imgNum));
            y = original_x .* sin(remake_xy(imgNum)) + original_y .* cos(remake_xy(imgNum));
            
            
            % Calculate checkerboard.
            % Wedges alternating between -1 and 1 within stimulus window.
            % The computational contortions are to avoid sign=0 for sin zero-crossings
            
            
            wedges    = sign(round((cos((y+step_startx)*numSubRings*(2*pi/ringWidth)))./2+.5).*2-1);
            
            posWedges = find(wedges== 1);
            negWedges = find(wedges==-1);
            rings     = zeros(size(wedges));
            %
            checks    = zeros(size(rings,1),size(rings,2),numMotSteps);
            
            
            %Bandpass filtered noise
            %                     f1=((1+sin(linspace(0,1,size(rings,1))*2*pi*8))/2);
            %                     matrix1=meshgrid(f1,1:size(rings,1));
            %                     [newmat,imaginarymat,powmat]=randphase2(matrix1,1,0,[],0,0);
            %                     %rms normalizing
            %                     [checkfactor,checksIn,contrastout]=rmsscale(newmat,params.rmscontrast, [0 1]);%variable rms
            %                     contrastinfo=sprintf('\n [image:%d] rms:%3.3f%% michelson:%3.3f%%',imgNum,contrastout.rms,contrastout.michelson);
            %                     disp(contrastinfo);
            %
            % 1/f noise
            checksIn=oneoverf(1, n);
            %checksIn=ones(size(checksIn));
            
            contrast=1;
            
            %This is the contrast bit
            for ii=1:numDiffStim
                if ii==1
                    checks(:,:,ii)=(checksIn-.5).*contrast + 0.5;
                else
                    if imgNum==1
                        checks(:,:,ii)=(flipdim(checksIn,2)-.5).*contrast + 0.5;
                    elseif imgNum==41
                        checks(:,:,ii)=(flipdim(checksIn,1)-.5).*contrast + 0.5;
                    elseif imgNum==21
                        checks(:,:,ii)=(permute(checksIn, [2 1])-.5).*contrast + 0.5;
                    elseif imgNum==61
                        checks(:,:,ii)=(permute(flipdim(flipdim(checksIn, 2), 1), [2 1])-.5).*contrast + 0.5;
                    end
                end
                
                
            end
            
            
            
            
            
            % reset starting point
            loX = step_startx - step_x;
        end;
        
        
        
        switch params.type;
            case 'bar'
                loEcc = innerRad;
                hiEcc = outerRad;
                loX   = loX + step_x;
                hiX   = loX + ringWidth;
            otherwise,
                error('Unknown stimulus type!');
                
        end
        
        % This isn't as bad as it looks
        % Can fiddle with this to clip the edges of an expanding ring -
        % want the ring to completely  q
        % disappear from view before it re-appears again in the middle.
        
        % Can we do this just be removing the second | from the window
        % expression? so...
        %window = ( (x>=loX & x<=hiX) & r<outerRad);
        
        % yet another loop to be able to move the checks...
        
        % defining window.
        
        if softEdgeWindow>0
            loXin=loX+(softEdgeWindow);
            hiXin=hiX-(softEdgeWindow);
            %outerRadIn=outerRad-(softEdgeWindow);
            loXout=loXin-softEdgeWindow;
            hiXout=hiXin+softEdgeWindow;
            %outerRadOut=outerRadIn+softEdgeWindow;
            window=( (x>=loXout & x<=hiXout));
            
            tmpvar=zeros(m,n);
            tmpvar(window) = 1;
            loXfade=(x<loXin & x>loXout).*(cos((x-loXin)*pi/softEdgeWindow)./2+.5);
            hiXfade=(x>hiXin & x<hiXout).*(cos((hiXin-x)*pi/softEdgeWindow)./2+.5);
            %outerRadFade=(r>outerRadIn & r<outerRadOut).*(cos((r-outerRadIn)*pi/softEdgeWindow)./2+.5);
            tmpvar(loXfade>0)=tmpvar(loXfade>0).*loXfade(loXfade>0);
            tmpvar(hiXfade>0)=tmpvar(hiXfade>0).*hiXfade(hiXfade>0);
            %tmpvar(outerRadFade>0)=tmpvar(outerRadFade>0).*outerRadFade(outerRadFade>0);
            tmpvarwin = tmpvar;
            
            winexp = 1;
            loXin=loX+(softEdgeWindow.*winexp);
            hiXin=hiX-(softEdgeWindow.*winexp);
            outerRadIn=outerRad-(softEdgeWindow.*winexp);
            loXout=loXin-softEdgeWindow.*winexp;
            hiXout=hiXin+softEdgeWindow.*winexp;
            outerRadOut=outerRadIn+softEdgeWindow.*winexp;
            window=( (x>=loXout & x<=hiXout) & r<=outerRadOut);
            tmpvar=zeros(m,n);
            tmpvar(window) = 1;
            loXfade=(x<loXin & x>loXout).*(cos((x-loXin)*pi/(softEdgeWindow.*winexp))./2+.5);
            hiXfade=(x>hiXin & x<hiXout).*(cos((hiXin-x)*pi/(softEdgeWindow.*winexp))./2+.5);
            outerRadFade=(r>outerRadIn & r<outerRadOut).*(cos((r-outerRadIn)*pi/(softEdgeWindow.*winexp))./2+.5);
            tmpvar(loXfade>0)=tmpvar(loXfade>0).*loXfade(loXfade>0);
            tmpvar(hiXfade>0)=tmpvar(hiXfade>0).*hiXfade(hiXfade>0);
            tmpvar(outerRadFade>0)=tmpvar(outerRadFade>0).*outerRadFade(outerRadFade>0);
            
            % define region mask
            region.mask = single(tmpvarwin);
            region.orientationBPinDeg = single(30);
            
            img = zeros(size(tmpvar,1),size(tmpvar,2),size(checks,3));
            for jj=1:size(checks,3)
                %Actual code
                % unscaledContours=synthetic_contours(n, params.radius*2, contourSF, contourOrientation-(remake_ori/(2*pi)*360), contourBandpass, 0, region);
                
                %unscaledContours=synthetic_contours_edge(n, params.radius*2, contourSF, contourOrientation-(remake_ori/(2*pi)*360), contourBandpass, 0, region);
                img(:,:,jj)=minCmapVal+ceil((maxCmapVal-minCmapVal) * (((checks(:,:,jj)-0.5).*(tmpvar))+0.5));
                
                %                 %Code to produce window apature for modelling. Usually
                %                 %commented out
                %                 unscaledContours(:,:,jj)=255;
                %                 unscaledContours(:,:,jj)=unscaledContours(:,:,jj)-128;
                %                 checks(:,:,jj)=unscaledContours(:,:,jj).*tmpvar;
                %                 checks(:,:,jj)=checks(:,:,jj)+128;
                %                 img(:,:,jj)=checks(:,:,jj);
                %                   %img(:,:,jj)=tmpvar;
            end
        else
            window = ( (x>=loX & x<=hiX) & r<outerRad);
            tmpvar = zeros(m,n);
            tmpvar(window) = 1;
            
            img = zeros(size(tmpvar,1),size(tmpvar,2),size(checks,3));
            for jj=1:size(checks,3)
                img(:,:,jj)=minCmapVal+ceil((maxCmapVal-minCmapVal) * (((checks(:,:,jj)-0.5).*(tmpvar))+0.5));
            end
            
            %                     tmpvar = repmat(tmpvar,[1 1 size(checks, 3)]);
            %                     window = tmpvar == 1;
            %                     img         = bk*ones(size(checks));
            %                     img(window) = checks(window);
        end
        
        images(:,:,(imgNum-1)*numMotSteps+1:imgNum*numMotSteps) = uint8(img);
        
        
        
        fprintf('.');drawnow;
    end
    fprintf('Done.\n');
end;



% Now we compile the actual sequence
% make stimulus sequence, make half and then add the rest as a flipped
% version of the first half
sequence = ...
    ones(barPassFrames./2./halfNumImages,1)*...
    [1:numMotSteps:numMotSteps*halfNumImages];
sequence = sequence(:);
if params.insertBlanks.do,
    if params.insertBlanks.phaseLock, % keep 1 cycle and repeat
        completeCycle = sequence;
        sequence = [completeCycle;...
                    completeCycle(1:round(end/2));...
                    completeCycle;...
                    completeCycle(1:round(end/2));...
                    completeCycle;...
                    completeCycle(1:round(end/2));...
                    completeCycle;...
                    completeCycle(1:round(end/2))];
    else,
        sequence = repmat(sequence,params.ncycles,1);
    end;
else,
    sequence = repmat(sequence,params.ncycles,1);
end;

% we make only half so we need to flip the rest
sep   = round(linspace(1,length(sequence)+1,5));
rev = []; 
for n=1:4,
    rev = [rev; flipud(sequence(sep(n):sep(n+1)-1))];
end;
sequence = [sequence; rev];


halfTR=floor(0.5*params.tr./duration.stimframe);
fullTR=uint16(params.tr./duration.stimframe);
numTRs=length(sequence)/fullTR;
params.framesTR = fullTR;

motionSeq = zeros(fullTR,1);

for a = 1:numDiffStim;
    motionSeq(((((a-1)*framesStimOn)+((a-1)*blanksBetween))+1):((((a-1)*framesStimOn)+((a-1)*blanksBetween))+framesStimOn)) = a;
end

motionSeq = repmat(motionSeq,numTRs,1);

shouldChange = find(motionSeq == 0);


 sequence=sequence+motionSeq-1;
sequence(shouldChange) = size(images,3)+1;

% insert blanks (always of for 12 seconds)
if params.insertBlanks.do,
    if blanksAfterPass==1
        blankCycleFrames=length(sequence)/(params.insertBlanks.freq*2);
        offTime   = ceil(blankTime./params.tr).*params.tr; % make sure it's a multiple of the tr
        offPeriod = ceil(offTime./duration.stimframe);
        
        images(:,:,size(images,3)+1)   = uint8(ones(size(images,1),size(images,2)).*bk);
        blankInsert=ones(offPeriod,1).*size(images,3);
        sequence=cat(1,sequence(1:blankCycleFrames), blankInsert, sequence(blankCycleFrames+1:3*blankCycleFrames), blankInsert, sequence(blankCycleFrames*3+1:5*blankCycleFrames),blankInsert, sequence(blankCycleFrames*5+1:7*blankCycleFrames), blankInsert, sequence(blankCycleFrames*7+1:end));
    else
        seq2      = zeros(size(sequence));
        oneCycle  = length(seq2)/params.insertBlanks.freq;
        offTime   = ceil(blankTime./params.tr).*params.tr; % make sure it's a multiple of the tr
        offPeriod = ceil(offTime./duration.stimframe);
        onPeriod  = oneCycle-offPeriod;
        oneBlankCycle = [false(onPeriod,1); true(offPeriod,1)]; % blanks at the end
        oneBlankCycle = [oneBlankCycle(oneCycle/2+1:end); oneBlankCycle(1:oneCycle/2)]; % blanks half way
        seq2      = repmat(oneBlankCycle,params.insertBlanks.freq,1);
        add       = size(images,3)+1;
        if isempty(params.loadMatrix),
            sequence(seq2)    = add;
            images(:,:,add)   = uint8(ones(size(images,1),size(images,2)).*bk);
        end;
        clear seq2;
        disp(sprintf('[%s]:Stimulus on for %.1f and off for %.1f seconds.',...
            mfilename,onPeriod*duration.stimframe,offPeriod*duration.stimframe));
    end
end;
        

% fixation dot sequence
% change on the fastest every 6 seconds
minsec = 1.8./duration.stimframe;
fixSeq = ones(minsec,1)*round(rand(1,ceil(length(sequence)/minsec)));
fixSeq = fixSeq(:)+1;
fixSeq = fixSeq(1:length(sequence));
% force binary
fixSeq(fixSeq>2)=2; 
fixSeq(fixSeq<1)=1;


% Insert the preappend images by copying some images from the
% end of the seq and tacking them on at the beginning
sequence = [sequence(length(sequence)+1-duration.prescan.stimframes:end); sequence];
timing   = [0:length(sequence)-1]'.*duration.stimframe;
cmap     = params.display.gammaTable;
fixSeq   = [fixSeq(length(fixSeq)+1-duration.prescan.stimframes:end); fixSeq];
fixSeq   = ones(size(fixSeq));


otherSequence = [];



% make stimulus structure for output
stimulus = createStimulusStruct(images,cmap,sequence,[],timing,fixSeq);

% save matrix if requested
if ~isempty(params.saveMatrix),
    save(params.saveMatrix,'images');
end;

