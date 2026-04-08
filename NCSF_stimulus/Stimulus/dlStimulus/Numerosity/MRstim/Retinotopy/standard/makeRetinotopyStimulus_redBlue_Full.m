function stimulus = makeRetinotopyStimulus_redBlue_Full(params)
% makeRetinotopyStimulus - make various retinotopy stimuli
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

%Flag to start stimulus sequence with one block of mean luminance (if set
%to 1) or black (if set to 2)
startWithBlank=0;
fusionSurround=0;
onTime=0.5;
offTime=0.2;


duration.stimframe = 1./params.temporal.frequency./params.temporal.motionSteps;
onFrames=onTime/duration.stimframe;
offFrames=offTime/duration.stimframe;

% load matrix or make it
if ~isempty(params.loadMatrix),
    % we should really put some checks that the matrix loaded is
    % appropriate etc.
    load(params.loadMatrix);
    disp(sprintf('[%s]:loading images from %s.',mfilename,params.loadMatrix));
%    disp(sprintf('[%s]:size stimulus: %dx%d pixels.',mfilename,n,m));
else,
    outerRad = params.radius;
    innerRad = params.innerRad;
    wedgeWidth = params.wedgeWidth;
    ringWidth = params.ringWidth;

    numImages = params.numImages;
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


    
    sSize.pix = fliplr(params.display.numPixels);
    sSize.deg = pix2angle(params.display,sSize.pix);
    

    m=sSize.pix(1);%angle2pix(params.display,2*outerRad); 
    n=sSize.pix(2);

    % here we crop the image if it is larger than the screen 
    % seems that you have to have a square matrix, bug either in my or
    % psychtoolbox' code - so we make it square
%     if m>params.display.numPixels(2),
%         start  = round((m-params.display.numPixels(2))/2);
%         len    = params.display.numPixels(2);
%         y = y(start+1:start+len, start+1:start+len);
%         x = x(start+1:start+len, start+1:start+len);
%         m = len;
%         n = len;
%     end;
    disp(sprintf('[%s]:size stimulus: %dx%d pixels.',mfilename,n,m));
    
    mask = ones(n,m);%makecircle(m*24/28,m);
    
    % r = eccentricity; theta = polar angle
%     r = sqrt (x.^2  + y.^2);
%     theta = atan2 (y, x);					% atan2 returns values between -pi and pi
%     theta(theta<0) = theta(theta<0)+2*pi;	% correct range to be between 0 and 2*pi
% 
%     % Calculate checkerboard.
%     % Wedges alternating between -1 and 1 within stimulus window.
%     % The computational contortions are to avoid sign=0 for sin zero-crossings
%     wedges = sign(2*round((sin(theta*numSubWedges*(2*pi/wedgeWidth))+1)/2)-1);
%     posWedges = find(wedges==1);
%     negWedges = find(wedges==-1);
% 
%     rings = wedges.*0;
%     rings = sign(2*round((sin(r*numSubRings*(2*pi/ringWidth))+1)/2)-1);

%   CREATES RADIAL CHECKERBOARD

    %Make a mesh grid for radial checkboard, adjusted so that the centre is
    %at fixation
    xFixDev=pix2angle(params.display, params.display.fixX-sSize.pix(2)/2);
    yFixDev=pix2angle(params.display, params.display.fixY-sSize.pix(1)/2);
    [x, y] = meshgrid(linspace(-sSize.deg(2)./2-xFixDev,sSize.deg(2)./2-xFixDev,sSize.pix(2)),...
                 linspace(-sSize.deg(1)./2-yFixDev,sSize.deg(1)./2-yFixDev,sSize.pix(1)));
             
    % r = eccentricity; theta = polar angle
    r = sqrt (x.^2  + y.^2);
    theta = atan2 (y, x);					% atan2 returns values between -pi and pi
    theta(theta<0) = theta(theta<0)+2*pi;	% correct range to be between 0 and 2*pi

    % Calculate checkerboard.
    % Wedges alternating between -1 and 1 within stimulus window.
    % The computational contortions are to avoid sign=0 for sin zero-crossings
    wedges = sign(2*round((sin(theta*numSubWedges*(2*pi/wedgeWidth))+1)/2)-1);
    posWedges = find(wedges==1);
    negWedges = find(wedges==-1);

    rings = wedges.*0;
    rings = sign(2*round((sin(r*numSubRings*(2*pi/ringWidth))+1)/2)-1);

    checks    = zeros(size(rings,1),size(rings,2),params.temporal.motionSteps*params.numImages);
     for ii=1:numMotSteps*params.numImages,
%     checks   = zeros(size(rings,1),size(rings,2),params.temporal.motionSteps);
%     for ii=1:numMotSteps,
        tmprings1 = sign(2*round((sin(r*numSubRings*(2*pi/ringWidth)+(ii-1)/numMotSteps*2*pi)+1)/2)-1);
        tmprings2 = sign(2*round((sin(r*numSubRings*(2*pi/ringWidth)-(ii-1)/numMotSteps*2*pi)+1)/2)-1);
        rings(posWedges)=tmprings1(posWedges);
        rings(negWedges)=tmprings2(negWedges);

        checks(:,:,ii)=minCmapVal+ceil((maxCmapVal-minCmapVal) * (wedges.*rings+1)./2);
    end;


%     CREATES SQUARE CHECKERBOARD
%    %Make a mesh grid for square checkboard
%     [x, y] = meshgrid(linspace(-sSize.deg(2)./2,sSize.deg(2)./2,sSize.pix(2)),...
%                 linspace(-sSize.deg(1)./2,sSize.deg(1)./2,sSize.pix(1)));
%     cpd = 0.2;
%     ringWidth=1./cpd;
%     
%     wedges    = sign(round((cos((x)*numSubRings*(2*pi/ringWidth)))./2+.5).*2-1);
%     posWedges = find(wedges== 1);
%     negWedges = find(wedges==-1);
%     rings     = zeros(size(wedges));
%     
%     checks    = zeros(size(rings,1),size(rings,2),params.temporal.motionSteps*params.numImages);
%     for ii=1:numMotSteps*params.numImages,
%         tmprings1 = sign(2*round((cos(y*numSubRings*(2*pi/ringWidth)+(ii-1)/numMotSteps*2*pi)+1)/2)-1);
%         tmprings2 = sign(2*round((cos(y*numSubRings*(2*pi/ringWidth)-(ii-1)/numMotSteps*2*pi)+1)/2)-1);
%         rings(posWedges) = tmprings1(posWedges);
%         rings(negWedges) = tmprings2(negWedges);
%         
%         checks(:,:,ii)=minCmapVal+ceil((maxCmapVal-minCmapVal) * (wedges.*rings+1)./2);
%     end;

    % Loop that creates the final images
    fprintf('[%s]:Creating %d images:',mfilename,numImages);
    images=zeros(sSize.pix(1),sSize.pix(2),numImages*params.temporal.motionSteps,'uint8');


        % Can we do this just be removing the second | from the window expression? so...
        window = ones(m,n);
        window=window==1;
    
%         if isfield(params.display, 'Rect')
%             windowRadius = pix2angle(params.display, (params.display.Rect(4)-params.display.Rect(2)))/2;
%             window=window & r<windowRadius;
%         end

        % yet another loop to be able to move the checks...
        for ii=1:numMotSteps,  
            img = bk*ones(m,n);
            tmpvar = checks(:,:,ii);
            img = tmpvar;	
            images(:,:,ii) = uint8(img);
        end;
        
        images(:,:,numMotSteps+1)=ones(size(images(:,:,ii))).*bk;
        
        for ii=numMotSteps+2:numMotSteps*params.numImages+1,  
            img = bk*ones(m,n);
            tmpvar = checks(:,:,ii-1);
            img = tmpvar;	
            images(:,:,ii) = uint8(img);
        end; 
        

        images(:,:,numMotSteps*params.numImages+2)=ones(size(images(:,:,ii))).*bk;
        
        if startWithBlank==2
            images(:,:,numMotSteps*params.numImages+1)=zeros(size(images(:,:,ii)));
        end
        fprintf('.');drawnow;
    
    fprintf('Done.\n');
end
%save 
%return;


% Now we compile the actual sequence
seq = [];
curCmapFrame = 1;
if params.seqDirection==0
	imSeq = [1:params.numImages];
else
	imSeq = [params.numImages:-1:1];
end

duration.stimframe          = 1./params.temporal.frequency./params.temporal.motionSteps;
duration.scan.seconds       = params.ncycles*params.period;
duration.scan.stimframes    = params.ncycles*params.period./duration.stimframe;
duration.cycle.seconds      = params.period;
duration.cycle.stimframes   = params.period./duration.stimframe;
duration.prescan.seconds    = params.prescanDuration;
duration.prescan.stimframes = params.prescanDuration./duration.stimframe;

% make stimulus sequence
% main wedges/rings
sequence = ...
    ones(1,duration.cycle.stimframes./params.numImages)'*...
    [1:params.temporal.motionSteps:params.temporal.motionSteps*params.numImages];
sequence(:,2)=sequence(:,2)+1;
if params.insertBlanks.do,
    if params.insertBlanks.phaseLock, % keep 1 cycle and repeat
        completeCycle = sequence(:);
        sequence = [completeCycle;...
                    completeCycle(1:round(end/2));...
                    completeCycle;...
                    completeCycle(1:round(end/2));...
                    completeCycle;...
                    completeCycle(1:round(end/2));...
                    completeCycle;...
                    completeCycle(1:round(end/2))];
    else,
        sequence = repmat(sequence(:),params.ncycles,1);
    end;
else,
    sequence = repmat(sequence(:),params.ncycles,1);
end;


% motion frames within wedges/rings - lowpass
nn=15; % this should be a less random choice, ie in seconds
motionSeq = ones(nn,1)*round(rand(1,ceil(length(sequence)/nn)));
motionSeq = motionSeq(:)-0.5;
motionSeq = motionSeq(1:length(sequence));
motionSeq = cumsum(sign(motionSeq));

% wrap
above = find(motionSeq>params.temporal.motionSteps);
while ~isempty(above),
    motionSeq(above)=motionSeq(above)-params.temporal.motionSteps;
    above = find(motionSeq>params.temporal.motionSteps);
end;
below = find(motionSeq<1);
while ~isempty(below),
    motionSeq(below)=motionSeq(below)+params.temporal.motionSteps;
    below = find(motionSeq<1);
end;
sequence=sequence+motionSeq-1;

if offTime>0
    for cycleCounter=1:(params.ncycles*2)
        cycleStart=(cycleCounter-1)*(0.5*params.period./duration.stimframe);
        for offCounter=1:floor(params.period/2)./(onTime+offTime);
            offStart=cycleStart+(offCounter-1)*(onFrames+offFrames)+onFrames;
            if mod(cycleCounter,2)==1
                sequence(offStart+1:offStart+offFrames)=numMotSteps+1;
            else
                sequence(offStart+1:offStart+offFrames)=2*(numMotSteps+1);
            end
        end
    end
end


%If fMRI wants to record a zero condition first (to compare both eye
%conditions to) insert it in the first cycle
if startWithBlank>0
    sequence(1:length(sequence)/params.ncycles)=numMotSteps*params.numImages+1;
end

% fixation dot sequence
fixSeq = ones(nn,1)*round(rand(1,ceil(length(sequence)/nn)));
fixSeq = fixSeq(:)+1;
fixSeq = fixSeq(1:length(sequence));
% force binary
fixSeq(fixSeq>2)=2; 
fixSeq(fixSeq<1)=1;

% direction
if params.seqDirection~=0
	sequence = flipud(sequence);
end

% insert blanks
if params.insertBlanks.do,
    seq2      = zeros(size(sequence));
    oneCycle  = length(seq2)/params.insertBlanks.freq;
    switch params.experiment,
        case {'full-field, on-off (impulse)'},
            onPeriod  = round(params.impulse./duration.stimframe);
            offPeriod = oneCycle-onPeriod;
            seq2      = repmat([zeros(onPeriod,1); ones(offPeriod,1)],params.insertBlanks.freq,1);
%             sequence = ones(duration.scan.stimframes,1).*(params.temporal.motionSteps*params.numImages);
%             impulseInStimframes = round(params.impulse/duration.stimframe);
%             sequence(1:impulseInStimframes) = 1;

        case {'full-field, red/green - red only with blanks','full-field, red/green - green only with blanks'},
            % ugly hack for Yoichiro's exp't
            onPeriod  = oneCycle./24.*4.5;
            offPeriod = oneCycle./24.*7.5;
            seq2      = repmat([zeros(onPeriod,1); ones(offPeriod,1)],params.insertBlanks.freq.*2,1);
        otherwise,
            offPeriod = ceil((duration.cycle.seconds/2)/duration.stimframe);
            onPeriod  = oneCycle-offPeriod;
            seq2      = repmat([zeros(onPeriod,1); ones(offPeriod,1)],params.insertBlanks.freq,1);
    end
    add       = size(images,3)+1;
    if isempty(params.loadMatrix),
        sequence(seq2==1) = add;
        images(:,:,add)   = uint8(ones(size(images,1),size(images,2)).*bk);
    end;
    clear seq2;
    disp(sprintf('[%s]:Stimulus on for %.1f and off for %.1f seconds.',...
        mfilename,onPeriod*duration.stimframe,offPeriod*duration.stimframe));
end;
        
% Insert the preappend images by copying some images from the
% end of the seq and tacking them on at the beginning
sequence = [sequence(length(sequence)+1-duration.prescan.stimframes:end); sequence];
timing   = [0:length(sequence)-1]'.*duration.stimframe;
cmap     = params.display.gammaTable;
fixSeq   = [fixSeq(length(fixSeq)+1-duration.prescan.stimframes:end); fixSeq];


% hack to do red blue experiment
switch params.experiment,
    case {'full-field, red/green', 'Full-field full'},
        resample=1;
        images(images==0)=1;
        images(images==255)=254;
        
        if fusionSurround==1;
            fusionSurroundImage=round(bandpassimage(rand(1024), [angle2pix(params.display,0.5) angle2pix(params.display,1)],1));
            
            tmpvar = zeros(m,n);
            tmpvar(r<7.515) = 1;
            tmpvar = repmat(tmpvar,[1 1 numMotSteps*params.numImages+2]);
            window = tmpvar == 1;
            
            images2= repmat(fusionSurroundImage(1:768,:).*255,[1 1 numMotSteps*params.numImages+2]);
            images2(window)=images(window);
            images=images2;
        end
        if startWithBlank==2
            images(:,:,numMotSteps*params.numImages+2)=ones(size(images(:,:,ii))).*0;
        end
        
        if resample==1
            minlumR=1;
            maxlumR=150;
            minlumB=1;
            maxlumB=255;
            
            gammaR=params.display.gamma(:,1);
            gamRangeR=gammaR(minlumR:maxlumR);
            difR=maxlumR-minlumR+1;
            rangeR=1:difR;
            rangeR=rangeR(:);
            resampleR=linspace(1, difR, 254);
            newGammaR=spline(rangeR, gamRangeR, resampleR);
            newGammaR=newGammaR(:);
            
            cmap(:,:,1) = [[0;newGammaR;1] params.display.gamma(:,2).*0+params.display.gamma(128,2) ...
            params.display.gamma(:,3).*0+params.display.gamma(128,3)];
        
            gammaB=params.display.gamma(:,3);
            gamRangeB=gammaB(minlumB:maxlumB);
            difB=maxlumB-minlumB+1;
            rangeB=1:difB;
            rangeB=rangeB(:);
            resampleB=linspace(1, difB, 254);
            newGammaB=spline(rangeB, gamRangeB, resampleB);
            newGammaB=newGammaB(:);
            
            cmap(:,:,2) = [params.display.gamma(:,1).*0+params.display.gamma(128,1) ...
            params.display.gamma(:,2).*0+params.display.gamma(128,2) [0;newGammaB;1]];
        
            cmap(1,:,:) = 0;
            cmap(256,:,:) = 1;
            
        else
            cmap(:,:,1) = [params.display.gamma(:,1) params.display.gamma(:,2).*0+params.display.gamma(128,2) ...
                params.display.gamma(:,3).*0+params.display.gamma(128,3)];

            cmap(:,:,2) = [params.display.gamma(:,1).*0+params.display.gamma(128,1) ...
                params.display.gamma(:,2).*0+params.display.gamma(128,2) params.display.gamma(:,3)];
        end

        % put in clut changes -clut
%         s = diff(sequence<=max(sequence(:))./2);
%         f = find(s~=0);
%         s = [-s(f(1)); s];
%         f = find(s>0);
%         s(f) = -2;
%         ii = find(s<0);
%         sequence(ii) = s(ii);
    case {'full-field, red/green - red only','full-field, red/green - red only with blanks'},
        mask        = ones(size(params.display.gamma,1),1)*[1 0 0];
        cmap(:,:,1) = params.display.gamma .* mask;
        mask        = ones(size(params.display.gamma,1),1)*[1 0 0];
        cmap(:,:,2) = params.display.gamma .* mask;
        % put in clut changes -clut
        s = diff(sequence<=max(sequence(:))./2);
        f = find(s~=0);
        s = [-s(f(1)); s];
        f = find(s>0);
        s(f) = -2;
        ii = find(s<0);
        sequence(ii) = s(ii);
    case {'full-field, red/green - green only','full-field, red/green - green only with blanks'},
        mask        = ones(size(params.display.gamma,1),1)*[0 0 1];
        cmap(:,:,1) = params.display.gamma .* mask;
        mask        = ones(size(params.display.gamma,1),1)*[0 0 1];
        cmap(:,:,2) = params.display.gamma .* mask;
        % put in clut changes -clut
        s = diff(sequence<=max(sequence(:))./2);
        f = find(s~=0);
        s = [-s(f(1)); s];
        f = find(s>0);
        s(f) = -2;
        ii = find(s<0);
        sequence(ii) = s(ii);
        % scale images
        %images      = round((images-params.display.backColorRgb).*params.contrast)+params.display.backColorRgb;        
end;

% make stimulus structure for output
stimulus = createStimulusStruct(images,cmap,sequence,[],timing,fixSeq);

% save matrix if requested
if ~isempty(params.saveMatrix),
    save(params.saveMatrix,'images');
end;

