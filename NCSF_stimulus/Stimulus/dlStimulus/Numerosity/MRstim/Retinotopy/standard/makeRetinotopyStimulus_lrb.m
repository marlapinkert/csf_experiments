function [stimulus otherseq] = makeRetinotopyStimulus_lrb(params)
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


% load matrix or make it
if ~isempty(params.loadMatrix),
    % we should really put some checks that the matrix loaded is
    % appropriate etc.
    load(params.loadMatrix);
    fprintf(1,'[%s]:loading images from %s.\n',mfilename,params.loadMatrix);
%    disp(sprintf('[%s]:size stimulus: %dx%d pixels.',mfilename,n,m));
else
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


    %%% Initialize image template %%%
    
    %%% Initialize image template %%%

    % circular stimulus
%    m=angle2pix(params.display,2*outerRad); 
%     n=angle2pix(params.display,2*outerRad);
%     
%     % should really do something more intelligent, like outerRad-fix
%     switch(lower(params.display.fixType))
%         case 'left disk',
%             [x,y]=meshgrid(linspace( 0,outerRad*2,n),linspace(outerRad,-outerRad,m));
%             outerRad = outerRad.*2;
%         case 'right disk',
%             [x,y]=meshgrid(linspace(-outerRad*2,0,n),linspace(outerRad,-outerRad,m));
%             outerRad = outerRad.*2;
%         otherwise,
%             [x,y]=meshgrid(linspace(-outerRad,outerRad,n),linspace(outerRad,-outerRad,m));
%     end;

    % rectangular stimulus
    sSize.pix = [abs(diff(params.display.Rect([2 4]))) abs(diff(params.display.Rect([1 3])))];
    sSize.deg = pix2angle(params.display,sSize.pix);
    

    m=sSize.pix(1);%angle2pix(params.display,2*outerRad); 
    n=sSize.pix(2);
    mask = ones(n,m);
    
    xFixDev=pix2angle(params.display, params.display.fixX-sSize.pix(2)/2);
    yFixDev=pix2angle(params.display, params.display.fixY-sSize.pix(1)/2);
    [x, y] = meshgrid(linspace(-sSize.deg(2)./2-xFixDev,sSize.deg(2)./2-xFixDev,sSize.pix(2)),...
                 linspace(-sSize.deg(1)./2-yFixDev,sSize.deg(1)./2-yFixDev,sSize.pix(1)));
    fprintf(1,'[%s]:size stimulus: %dx%d pixels.\n',mfilename,n,m);
   
    
    % here we crop the image if it is larger than the screen 
    % seems that you have to have a square matrix, bug either in my or
%     % psychtoolbox' code - so we make it square
%     if m>params.display.numPixels(2),
%         start  = round((m-params.display.numPixels(2))/2);
%         len    = params.display.numPixels(2);
%         y = y(start+1:start+len, start+1:start+len);
%         x = x(start+1:start+len, start+1:start+len);
%         m = len;
%         n = len;
%     end;
%     fprintf(1,'[%s]:size stimulus: %dx%d pixels.\n',mfilename,n,m);
%     
    
    % r = eccentricity; theta = polar angle
    r = sqrt (x.^2  + y.^2);
    theta = atan2 (y, x)-pi/2;					% atan2 returns values between -pi and pi
    theta(theta<0) = theta(theta<0)+2*pi;	% correct range to be between 0 and 2*pi
    
    
    % Calculate checkerboard.
    % Wedges alternating between -1 and 1 within stimulus window.
    % The computational contortions are to avoid sign=0 for sin zero-crossings
    wedges = sign(2*round((sin(theta*numSubWedges*(2*pi/wedgeWidth))+1)/2)-1);
    posWedges = find(wedges==1);
    negWedges = find(wedges==-1);

    %rings = wedges.*0;
    rings = sign(2*round((sin(r*numSubRings*(2*pi/ringWidth))+1)/2)-1);

    checks   = zeros(size(rings,1),size(rings,2),params.temporal.motionSteps);
    for ii=1:numMotSteps,
        tmprings1 = sign(2*round((sin(r*numSubRings*(2*pi/ringWidth)+(ii-1)/numMotSteps*2*pi)+1)/2)-1);
        tmprings2 = sign(2*round((sin(r*numSubRings*(2*pi/ringWidth)-(ii-1)/numMotSteps*2*pi)+1)/2)-1);
        rings(posWedges)=tmprings1(posWedges);
        rings(negWedges)=tmprings2(negWedges);

        checks(:,:,ii)=minCmapVal+ceil((maxCmapVal-minCmapVal) * (wedges.*rings+1)./2);
    end;
    
    % Loop that creates the final images
    fprintf('[%s]:Creating %d images:',mfilename,numImages);
    images=zeros(m,n,numImages*params.temporal.motionSteps,'uint8');
    for imgNum=1:params.numImages

        switch params.type;
            case 'wedge',
                switch(lower(params.display.fixType))
                    case {'left disk','right disk'},
                        loAngle = 2*pi*((imgNum-1)/(numImages*2));
                        hiAngle = loAngle + wedgeWidth;
                        % for second wedge
                        loAngle2 = loAngle + pi;
                        hiAngle2 = loAngle2 + wedgeWidth;
                    otherwise
                        loAngle = 2*pi*((imgNum-1)/numImages);
                        hiAngle = loAngle + wedgeWidth;
                end;
                loEcc = innerRad;
                hiEcc = outerRad;
            case 'ring',
                loAngle = 0;
                hiAngle = 2*pi;
                loEcc = outerRad * (imgNum-1)/numImages;
                hiEcc = loEcc+ringWidth;
            case 'center-surround',
                loAngle = 0;
                hiAngle = 2*pi;
                if mod(imgNum,2)
                    loEcc = params.centerInnerRad;
                    hiEcc = params.centerOuterRad;
                else
                    loEcc = params.surroundInnerRad;
                    hiEcc = params.surroundOuterRad;
                end
                switch(lower(params.display.fixType))
                    case {'left disk','right disk'},
                        hiEcc = hiEcc.*2;
                end;
            otherwise,
                error('Unknown stimulus type!');

        end
        % This isn't as bad as it looks
        % Can fiddle with this to clip the edges of an expanding ring - want the ring to completely 
        % disappear from view before it re-appears again in the middle.

        % Can we do this just be removing the second | from the window expression? so...
        window = ( ((theta>=loAngle & theta<hiAngle) | ...
            (hiAngle>2*pi & theta<mod(hiAngle,2*pi))) & ...
...%            ((r>=loEcc & r<=hiEcc)) & ...
            (r>=loEcc));% & ...
            %r<outerRad) ;
    
        

        % yet another loop to be able to move the checks...
        for ii=1:numMotSteps, 
            img = bk*ones(m,n);
            tmpvar = checks(:,:,ii);
            img(window) = tmpvar(window);	
            images(:,:,imgNum*numMotSteps-numMotSteps+ii) = uint8(img);
        end;
        fprintf('.');drawnow;
    end
    fprintf('Done.\n');
end;
%save 
%return;


% Now we compile the actual sequence
% seq = [];
% curCmapFrame = 1;
% if params.seqDirection==0
% 	imSeq = 1:params.numImages;
% else
% 	imSeq = params.numImages:-1:1;
% end

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
    ones(1,uint16(duration.cycle.stimframes./params.numImages))'*...
    (1:params.temporal.motionSteps:params.temporal.motionSteps*params.numImages);


sequence = repmat(sequence(:),params.ncycles,1);


% motion frames within wedges/rings - lowpass
nn=60; % this should be a less random choice, ie in seconds
motionSeq = ones(nn,1)*round(rand(1,ceil(length(sequence)/nn)));
motionSeq = motionSeq(:)-0.5;
motionSeq = motionSeq(1:length(sequence));
motionDirectionChange = [abs(diff(motionSeq)); 0];
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
    oneCycle  = length(sequence)/params.ncycles;
%     switch params.experiment,
%         case {'full-field, on-off (impulse)'},
%             onPeriod  = round(params.impulse./duration.stimframe);
%             offPeriod = oneCycle-onPeriod;
%             seq2      = repmat([zeros(onPeriod,1); ones(offPeriod,1)],params.insertBlanks.freq,1);
% %             sequence = ones(duration.scan.stimframes,1).*(params.temporal.motionSteps*params.numImages);
% %             impulseInStimframes = round(params.impulse/duration.stimframe);
% %             sequence(1:impulseInStimframes) = 1;
% 
%         case {'full-field, red/green - red only with blanks','full-field, red/green - green only with blanks'},
%             % ugly hack for Yoichiro's exp't
%             onPeriod  = oneCycle./24.*4.5;
%             offPeriod = oneCycle./24.*7.5;
%             seq2      = repmat([zeros(onPeriod,1); ones(offPeriod,1)],params.insertBlanks.freq.*2,1);
%         otherwise,
            offPeriod = oneCycle./2;%ceil((duration.cycle.seconds/2)/duration.stimframe);
            onPeriod = oneCycle;
            seq2       = repmat([false(onPeriod,1); true(offPeriod,1)],params.ncycles,1);
            seq2       = seq2(1:length(sequence));
%    end
    add       = size(images,3)+1;
    if isempty(params.loadMatrix),
        sequence(seq2) = add;
        motionDirectionChange(seq2)=0;
        images(:,:,add)   = uint8(ones(size(images,1),size(images,2)).*bk);
    end;
    clear seq2;
    fprintf('[%s]:Stimulus on for %.1f and off for %.1f seconds.\n',...
        mfilename,onPeriod*duration.stimframe,offPeriod*duration.stimframe);
end;

% Insert the preappend images by copying some images from the
% end of the seq and tacking them on at the beginning
sequence = [sequence(length(sequence)+1-duration.prescan.stimframes:end); sequence];
timing   = (0:length(sequence)-1)'.*duration.stimframe;
cmap     = params.display.gammaTable;
fixSeq   = [fixSeq(length(fixSeq)+1-duration.prescan.stimframes:end); fixSeq];
motionDirectionChange = [motionDirectionChange(length(fixSeq)+1-duration.prescan.stimframes:end); motionDirectionChange];

% make stimulus structure for output
stimulus = createStimulusStruct(images,cmap,sequence,[],timing,fixSeq);

otherseq = motionDirectionChange;

% save matrix if requested
if ~isempty(params.saveMatrix),
    save(params.saveMatrix,'images');
end;

