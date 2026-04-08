function stimulus = makeRetinotopyStimulus_Flicker(params)
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

    numImages = 1;
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
    
    
    
    %%% Initialize image template %%%

    if isfield(params.display, 'quadrant')% && params.display.quadrant~=false
        sSize.pix = fliplr(params.display.numPixels);
        sSize.deg = min(pix2angle(params.display,sSize.pix));

        m=angle2pix(params.display,2*outerRad);%angle2pix(params.display,2*outerRad); 
        n=angle2pix(params.display,2*outerRad);
        mask = ones(n,m);
%         if isfield(params.display, 'Rect')
%             xFixDev=pix2angle(params.display, params.display.fixX+params.display.Rect(1)-((params.display.Rect(3)-params.display.Rect(1))/2));
%             yFixDev=pix2angle(params.display, params.display.fixY+params.display.Rect(2)-((params.display.Rect(4)-params.display.Rect(2))/2));
%         else
%             xFixDev=pix2angle(params.display, params.display.fixX-sSize.pix(2)/2);
%             yFixDev=pix2angle(params.display, params.display.fixY-sSize.pix(1)/2);
%         end
%         [x, y] = meshgrid(linspace(-outerRad,outerRad,n),linspace(outerRad,-outerRad,m));
%         x=x-xFixDev;
%         y=y+yFixDev;
        
        xFixDev=pix2angle(params.display, params.display.fixX+params.display.viewableRect(1)-((params.display.viewableRect(3)-params.display.viewableRect(1))/2));
        yFixDev=pix2angle(params.display, params.display.fixY-params.display.viewableRect(2)/2-((params.display.viewableRect(4)-params.display.viewableRect(2))/2));
        [x, y] = meshgrid(linspace(-sSize.deg*2./2-xFixDev,sSize.deg*2./2-xFixDev,sSize.pix(2)*2),...
                 linspace(-sSize.deg*2./2-yFixDev,sSize.deg*2./2-yFixDev,sSize.pix(2)*2));
    else
        m=angle2pix(params.display,2*outerRad); 
        n=angle2pix(params.display,2*outerRad);
        wholecycle = angle2pix(params.display,2.*floor(outerRad));
        mask = makecircle(wholecycle,m);
        [x,y]=meshgrid(linspace(-outerRad,outerRad,n),linspace(outerRad,-outerRad,m));
    end
    
    disp(sprintf('[%s]:size stimulus: %dx%d pixels.',mfilename,n,m));

    %FOR 7T PROJECTOR WITH BIGGEST POSSIBLE STIMULI
    %y=y+pix2angle(params.display, 115);

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
    fprintf(1,'[%s]:size stimulus: %dx%d pixels.\n',mfilename,n,m);
    
    
    % r = eccentricity; theta = polar angle
    r = sqrt (x.^2  + y.^2);
    theta = atan2 (y, x);					% atan2 returns values between -pi and pi
    theta(theta<0) = theta(theta<0)+2*pi;	% correct range to be between 0 and 2*pi

    % Calculate checkerboard.
    % Wedges alternating between -1 and 1 within stimulus window.
    % The computational contortions are to avoid sign=0 for sin zero-crossings
    switch params.flickerType
        case 'check'
            wedges = sign(2*round((sin(theta*numSubWedges*(2*pi/wedgeWidth))+1)/2)-1);
            rings = sign(2*round((sin(r*numSubRings*(2*pi/ringWidth))+1)/2)-1);
            myim     = sign(wedges.*rings);
            

%     wedges = sin(theta*numSubWedges*(2*pi/wedgeWidth));
%     rings  = sin(r*numSubRings*(2*pi/ringWidth));
%     myim   = wedges.*rings;
%     myim(r>max(x(:))) = 0;
%     myim = myim.*mask;

        case 'sin'
            rings = sin(r*numSubRings*(2*pi/ringWidth));
            myim  = rings;
            
        otherwise
            error('Unknown option');
    end
    %myim(r>max(x(:))) = 0;
    myim = myim;%.*mask;
    myim = myim.*params.flickerContrast;
    
    
    images   = uint8(ones(size(rings,1),size(rings,2),numMotSteps/min(params.flickerFrequencies)+1).*128);
    contrasts = cos(linspace(0,2.*pi,numMotSteps/min(params.flickerFrequencies)+1));
    contrasts = contrasts(1:end-1);
    contrasts = sign(contrasts);%[1 1 -1 -1];
    
    fprintf('[%s]:Creating images:',mfilename);
    for ii=1:numel(contrasts),
%         tmprings1 = sign(2*round((sin(r*numSubRings*(2*pi/ringWidth)+(ii-1)/numMotSteps*2*pi)+1)/2)-1);
%         tmprings2 = sign(2*round((sin(r*numSubRings*(2*pi/ringWidth)-(ii-1)/numMotSteps*2*pi)+1)/2)-1);
%         rings(posWedges)=tmprings1(posWedges);
%         rings(negWedges)=tmprings2(negWedges);

        images(:,:,ii)= uint8(minCmapVal+ceil((maxCmapVal-minCmapVal) .* (myim .* contrasts(ii)+1)./2));
        fprintf('.');drawnow;
    end;
    fprintf('Done.\n');
end;



duration.stimframe          = 1./params.temporal.motionSteps;
duration.scan.seconds       = params.ncycles*params.period;
duration.scan.stimframes    = params.ncycles*params.period./duration.stimframe;
duration.cycle.seconds      = params.period;
duration.cycle.stimframes   = params.period./duration.stimframe;
duration.prescan.seconds    = params.prescanDuration;
duration.prescan.stimframes = params.prescanDuration./duration.stimframe;

% make stimulus sequence
% main wedges/rings
sequence = (duration.stimframe:duration.stimframe:duration.cycle.seconds/length(params.flickerFrequencies))'*repmat(params.flickerFrequencies,1,params.ncycles);
sequence = round(sequence.*numel(contrasts));
% wrap
above = sequence>numel(contrasts);
while any(above),
    sequence(above)=sequence(above)-numel(contrasts);
    above = find(sequence>numel(contrasts));
end
below = sequence<1;
while any(below),
    sequence(below)=sequence(below)+numel(contrasts);
    below = find(sequence<1);
end
sequence = sequence(:);


% fixation dot sequence
nn=150;
fixSeq = ones(nn,1)*round(rand(1,ceil(length(sequence)/nn)));
fixSeq = fixSeq(:)+1;
fixSeq = fixSeq(1:length(sequence));
% force binary
fixSeq(fixSeq>2)=2; 
fixSeq(fixSeq<1)=1;

        
% Insert the preappend images by copying some images from the
% end of the seq and tacking them on at the beginning
sequence = [sequence(length(sequence)+1-duration.prescan.stimframes:end); sequence];
timing   = (0:length(sequence)-1)'.*duration.stimframe;
cmap     = params.display.gammaTable;
fixSeq   = [fixSeq(length(fixSeq)+1-duration.prescan.stimframes:end); fixSeq];



% make stimulus structure for output
stimulus = createStimulusStruct(images,cmap,sequence,[],timing,fixSeq);

% save matrix if requested
if ~isempty(params.saveMatrix),
    save(params.saveMatrix,'images');
end;

