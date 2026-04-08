function [stimulus otherSequence] = makeRetinotopyStimulus_simultaneous(params)
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
% 2015.02.16 BMH: modified from makeRetinotopyStimulus_LR3 to give
% simultaneous wedges and rings, increasing efficiency in mapping pRFs


% various time measurements:
duration.stimframe          = 1./params.temporal.frequency./params.temporal.motionSteps;
duration.scan.seconds       = params.ncycles*params.period;
duration.scan.stimframes    = params.ncycles*params.period./duration.stimframe;
duration.cycle.seconds      = params.period;
duration.cycle.stimframes   = params.period./duration.stimframe;
duration.prescan.seconds    = params.prescanDuration;
duration.prescan.stimframes = params.prescanDuration./duration.stimframe;

blanksAfterPass=1;  %1 (True) puts blanks after horizontal bars have passed. 0 (false) puts blanks within the bar pass

if strcmp(params.experiment, 'pRF bars simultaneous 3h/4v (TR 2.1)')
    blankTime=31.5;       %Blank time (in seconds) will be rounded up to the nearest TR
    lastBlankTime=31.5;
else
    blankTime=30;       %Blank time (in seconds) will be rounded up to the nearest TR
    lastBlankTime=30;
end
firstBlankTime=0;   %Use Prescan Only



if blanksAfterPass==1;
    totalBlankTime   = ceil((blankTime+firstBlankTime+lastBlankTime)./params.tr).*params.tr;
    barPassTime=duration.cycle.seconds-totalBlankTime;
    numBarImages=round(params.numImages-(totalBlankTime./params.tr));
    barPassFrames=round(barPassTime/duration.stimframe);
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
    outerRad = params.radius*2;
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
    if strcmp(params.display.arch, 'maci')
        bk = 0;
        original_bk=params.display.backColorIndex;
    else
        bk=params.display.backColorIndex;
    end

    
    minCmapVal = min([params.display.stimRgbRange]);
    maxCmapVal = max([params.display.stimRgbRange]);
    
    
    %%% Initialize image template %%%

    if isfield(params.display, 'Rect')
        sSize.pix = ([params.display.Rect(4)-params.display.Rect(2) params.display.Rect(3)-params.display.Rect(1)]);
    else
        sSize.pix = fliplr(params.display.numPixels);
    end
    sSize.deg(1) = pix2angle(params.display,sSize.pix(1));
    sSize.deg(2) = sSize.deg(1)./sSize.pix(1)*sSize.pix(2);
    
    ringWidth=ringWidth./outerRad.*sSize.deg(1);
    
    m=sSize.pix(1);%angle2pix(params.display,2*outerRad);
    n=sSize.pix(2);
    mask = ones(n,m);
    
    % should really do something more intelligent, like outerRad-fix
    if isfield(params.display, 'Rect')
        xFixDev=pix2angle(params.display, params.display.fixX-params.display.Rect(1)-sSize.pix(2)/2);
        yFixDev=pix2angle(params.display, params.display.fixY-params.display.Rect(2)-sSize.pix(1)/2);
    else
        xFixDev=pix2angle(params.display, params.display.fixX-sSize.pix(2)/2);
        yFixDev=pix2angle(params.display, params.display.fixY-sSize.pix(1)/2);
    end
    [x, y] = meshgrid(linspace(-sSize.deg(2)./2-xFixDev,sSize.deg(2)./2-xFixDev,sSize.pix(2)),...
        linspace(-sSize.deg(1)./2-yFixDev,sSize.deg(1)./2-yFixDev,sSize.pix(1)));
    fprintf(1,'[%s]:size stimulus: %dx%d pixels.\n',mfilename,n,m);
    
    
    % %     switch(lower(params.display.fixType))
    % %         case 'left disk',
    % %             [x,y]=meshgrid(linspace( 0,outerRad*2,n),linspace(outerRad,-outerRad,m));
    % %             outerRad = outerRad.*2;
    % %         case 'right disk',
    % %             [x,y]=meshgrid(linspace(-outerRad*2,0,n),linspace(outerRad,-outerRad,m));
    % %             outerRad = outerRad.*2;
    % %         otherwise,
    % %             [x,y]=meshgrid(linspace(-outerRad,outerRad,n),linspace(outerRad,-outerRad,m));
    % %     end;
    %
    %     % here we crop the image if it is larger than the screen
    %     % seems that you have to have a square matrix, bug either in my or
    %     % psychtoolbox' code - so we make it square
    %     if m>params.display.numPixels(2),
    %         start  = round((m-params.display.numPixels(2))/2);
    %         len    = params.display.numPixels(2);
    %         y = y(start+1:start+len, start+1:start+len);
    %         x = x(start+1:start+len, start+1:start+len);
    %         m = len;
    %         n = len;
    %     end;
    %     disp(sprintf('[%s]:size stimulus: %dx%d pixels.',mfilename,n,m));
    
    % r = eccentricity; theta = polar angle
    r = sqrt (x.^2  + y.^2);
    theta = atan2 (y, x);					% atan2 returns values between -pi and pi
    theta(theta<0) = theta(theta<0)+2*pi;	% correct range to be between 0 and 2*pi
    
    
    % loop over different orientations and make checkerboard
    % first define which orientations
    orientations = ([0 180])./360*(2*pi); % degrees -> rad
    %orientations = orientations([3 2 5 4 7 6 1 8]);  %[6 3 8 5 2 7 4 1]);
    remake_xy    = zeros(1,numBarImages)-1;
    remake_xy(1:length(remake_xy)/length(orientations):length(remake_xy)) = orientations;
    original_x   = x;
    original_y   = y;
    % step size of the bar
    step_nx      = barPassTime./params.tr/6;
    step_ny      = barPassTime./params.tr/8;
    step_x       = sSize.deg(2) ./ step_nx;
    step_y       = sSize.deg(1) ./ step_ny;
    step_startx  = (step_nx-1)./2.*-step_x-(ringWidth./2);%-0.5*sSize.deg(2) - (ringWidth./2);
    step_starty  = (step_ny-1)./2.*-step_y-(ringWidth./2);
    %[0:step_nx-1].*step_x+step_startx+ringWidth./2
    disp(sprintf('[%s]:stepsize: %f degrees.',mfilename,step_x));
    
    % if we create colored bars we want to make the edges soft.
    softmask = ones(m);
    
    
    % Loop that creates the final images
    fprintf('[%s]:Creating %d images:',mfilename,halfNumImages);
    %For moving checks
    %images=zeros(m,n,halfNumImages*params.temporal.motionSteps,'uint8');
    %For randomly colored flickering checks
    
    if strcmp(params.display.arch, 'maci')
        images=zeros(m,n,halfNumImages, 'uint16');
    else
        nRandChecks=50;
        images=ones(m,n, 4*(halfNumImages+nRandChecks+1), 'uint8').*bk;
        images(:,:,end)=ones(size(images(:,:,end)));
    end
    maxCell=0;
    
    for imgNum=1:round(halfNumImages)
        
        if remake_xy(imgNum) >=0,
            x = original_x .* cos(remake_xy(imgNum)) - original_y .* sin(remake_xy(imgNum));
            y = original_x .* sin(remake_xy(imgNum)) + original_y .* cos(remake_xy(imgNum));
            
            
            % Calculate checkerboard.
            % Wedges alternating between -1 and 1 within stimulus window.
            % The computational contortions are to avoid sign=0 for sin
            % zero-crossings
            
            %For randomly colored flickering checks
            xcell=round((x-step_startx)*2*numSubRings/ringWidth);
            ycell=round((y-step_starty)*2*numSubRings/ringWidth);

            checks=xcell+(ycell-1)*max(xcell(:))+1;
            if strcmp(params.display.arch, 'maci')
                checks=mod(checks, 253)+3;
            else
                %checks=mod(checks, 100);
                %checksBig=zeros(size(checks,1), size(checks,2), numMotSteps*3);
                for whichFrame=1:(nRandChecks*4)
                    if mod(whichFrame,4)==0
                        images(:,:,whichFrame+halfNumImages*4)=ones(size(checks)).*255;
                    else
                        colorList=randperm(max(checks(:)));
                        tmp=colorList(checks);
                        tmp=mod(tmp,255);
                        images(:,:,whichFrame+halfNumImages*4)=tmp;
                    end
                end
            end   
            
            % reset starting point
            loX = step_startx - step_x;
            loY = step_starty - step_y;
        end;
        
        
        switch params.type;
            case 'bar'
                loEcc = innerRad;
                hiEcc = outerRad;
                loX   = loX + step_x;
                if loX>(max(original_x(:))-step_x)
                    loX=step_startx;
                end
                hiX   = loX + ringWidth;
                loY   = loY + step_y;
                if loY>(max(original_y(:))-step_y)
                    loY=step_starty;
                end
                hiY   = loY + ringWidth;
            otherwise,
                error('Unknown stimulus type!');
                
        end
        % This isn't as bad as it looks
        % Can fiddle with this to clip the edges of an expanding ring - want the ring to completely
        % disappear from view before it re-appears again in the middle.
        
        % Can we do this just be removing the second | from the window
        % expression? so...
        window = ( (x>=loX & x<=hiX) | (y>=loY & y<=hiY));% r<outerRad);
        
        % yet another loop to be able to move the checks...
        
        %                 tmpvar = zeros(m,n);
        %                 tmpvar(window) = 1;
        %                 tmpvar = repmat(tmpvar,[1 1 numMotSteps]);
        %                 window = tmpvar == 1;
        %                 img         = bk*ones(size(checks));
        %                 img(window) = checks(window);
        %                 images(:,:,(imgNum-1).*numMotSteps+1:imgNum.*numMotSteps) = uint8(img);
        if strcmp(params.display.arch, 'maci')
            %For randomly-colored flickering checks
            tmpvar=ones(m,n).*bk;
            %window=repmat(window,[1 1 3]);
            tmpvar(window)=checks(window);
            images(:,:,imgNum)=tmpvar;
            
            fprintf('.');drawnow;
            
        else
%             window=repmat(window,[1 1 3*numMotSteps]);
%             tmpVar=ones(size(checksBig)).*bk;
%             tmpVar(window)=checksBig(window);
%             images(:,:,((imgNum-1)*(3*numMotSteps)+1):(imgNum*3*numMotSteps))=tmpVar;
            
            %window=repmat(window,[1 1 3*numMotSteps]);
            tmpVar=ones(size(window)).*255;
            tmpVar(window)=0;
            images(:,:,(imgNum*4))=tmpVar;
            
           
            
            
            
%             tmpvar(window)=checks(window);
%             activeCells=unique(tmpvar(:));
%             activeCells=activeCells(activeCells~=0);
%             tmpvarR=ones(m,n).*bk;
%             tmpvarG=ones(m,n).*bk;
%             tmpvarB=ones(m,n).*bk;
%             for whichFrame=1:numMotSteps
%                 for whichCell=1:length(activeCells)
%                     tmpvarR(tmpvar==activeCells(whichCell))=round(rand*255);
%                     tmpvarG(tmpvar==activeCells(whichCell))=round(rand*255);
%                     tmpvarB(tmpvar==activeCells(whichCell))=round(rand*255);
%                 end
%                 images(:,:,((imgNum-1)*whichFrame+1))=tmpvarR;
%                 images(:,:,((imgNum-1)*whichFrame+2))=tmpvarG;
%                 images(:,:,((imgNum-1)*whichFrame+3))=tmpvarB;
%             end
            
            fprintf('.');drawnow;
        end
    end
    
    fprintf('Done.\n');
end;

clear checks checksBig img mask negWedges posWedges original_x original_y r theta rings softmask tmpvar tmprings1 tmprings2 x y wedges window


% Now we compile the actual sequence
% make stimulus sequence, make half and then add the rest as a flipped
% version of the first half

%Moving black and white checks
% sequence = ...
%     ones(barPassFrames./2./halfNumImages,1)*...
%     [1:params.temporal.motionSteps:params.temporal.motionSteps*halfNumImages];

% Stationary color flickering checks
if strcmp(params.display.arch, 'maci')
    sequence = ones(barPassFrames./2./round(halfNumImages),1)*[1:round(halfNumImages)];
else
%     sequence = ...
%     ones(barPassFrames./2./halfNumImages,1)*...
%     [1:params.temporal.motionSteps:params.temporal.motionSteps*halfNumImages];
%     
    sequence = ...
    ones(barPassFrames./2./halfNumImages,1)*...
    [1:params.temporal.motionSteps:params.temporal.motionSteps*halfNumImages];
    sequence=ones(size(sequence))+(halfNumImages);
    seq2 = ones(barPassFrames./2./halfNumImages,1)*[1:halfNumImages];
    seq2=seq2(:);
end

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
    if exist('seq2', 'var')
        seq2=repmat(seq2, params.ncycles,1);

    end
end;

% we make only half so we need to flip the rest
%sep   = round(linspace(1,length(sequence)+1,5));
%rev = flipud(sequence); 
% for n=1:4,
%     rev = [rev; flipud(sequence(sep(n):sep(n+1)-1))];
% end;
sequence = [sequence; flipud(sequence)];
if exist('seq2', 'var')
    seq2 = [seq2; flipud(seq2)];
end

if ~strcmp(params.display.arch, 'maci')
    % motion frames within wedges/rings - lowpass
    %nn=30; % this should be a less random choice, ie in seconds
%     nn = 1./duration.stimframe*4; % on average every 4 seconds [max response time = 3 seconds]
%     motionSeq = ones(nn,1)*round(rand(1,ceil(length(sequence))));
%     motionSeq = motionSeq(:)-0.5;
%     motionSeq = motionSeq(1:length(sequence));
%     motionSeq = cumsum(sign(motionSeq));
%     
%     % wrap
%     above = find(motionSeq>params.temporal.motionSteps);
%     while ~isempty(above),
%         motionSeq(above)=motionSeq(above)-params.temporal.motionSteps;
%         above = find(motionSeq>params.temporal.motionSteps);
%     end;
%     below = find(motionSeq<1);
%     while ~isempty(below),
%         motionSeq(below)=motionSeq(below)+params.temporal.motionSteps;
%         below = find(motionSeq<1);
%     end;
%     sequence=sequence+motionSeq-1;
    

    motionSeq = ones(size(sequence));
    motionSeq = cumsum(motionSeq);
    motionSeq = mod(motionSeq, nRandChecks);
    motionSeq(motionSeq==0)=nRandChecks;
    sequence=sequence+motionSeq-1;
end

% direction
if params.seqDirection~=0
	sequence = flipud(sequence);
end

% insert blanks (always of for 12 seconds)
if params.insertBlanks.do,
    if blanksAfterPass==1
        blankCycleFrames=length(sequence)/(params.insertBlanks.freq);
        offTime   = ceil(blankTime./params.tr).*params.tr; % make sure it's a multiple of the tr
        offPeriod = ceil(offTime./duration.stimframe);
        
        offTimeEnd   = ceil(lastBlankTime./params.tr).*params.tr; % make sure it's a multiple of the tr
        offPeriodEnd = ceil(offTimeEnd./duration.stimframe);
        
        if ~strcmp(params.display.arch, 'maci')
            blankInsert=ones(offPeriod,1).*(size(images,3)./4);
            blankInsertEnd=ones(offPeriodEnd,1).*(size(images,3)./4);
            sequence=cat(1,sequence(1:blankCycleFrames), blankInsert, sequence(blankCycleFrames+1:end), blankInsertEnd);
            if exist('seq2', 'var')
                blankInsert=zeros(offPeriod,1);
                blankInsertEnd=zeros(offPeriodEnd,1);
                seq2=cat(1,seq2(1:blankCycleFrames), blankInsert, seq2(blankCycleFrames+1:end), blankInsertEnd);
            end
        else
            images(:,:,size(images,3)+1)   = uint8(ones(size(images,1),size(images,2)).*bk);
            blankInsert=ones(offPeriod,1).*size(images,3);
            blankInsertEnd=ones(offPeriodEnd,1).*size(images,3);
            sequence=cat(1,sequence(1:blankCycleFrames), blankInsert, sequence(blankCycleFrames+1:end), blankInsertEnd);
        end
        
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
minsec = 2./duration.stimframe;
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
cmap_original     = params.display.gammaTable;
fixSeq   = [fixSeq(length(fixSeq)+1-duration.prescan.stimframes:end); fixSeq];

%For flickering color checks
% hsvPart=round(256.*gray(253));
% for gunIndex=1:3
%     for intensityIndex=1:(253)
%         if hsvPart(intensityIndex,gunIndex)>0
%             hsvPart(intensityIndex,gunIndex)=cmap_original(hsvPart(intensityIndex,gunIndex),gunIndex);
%         end
%     end
% end

if strcmp(params.display.arch, 'maci')
    cmap=[cmap_original(original_bk,:); [cmap_original(255,1) cmap_original(1,2) cmap_original(1,3)]; [cmap_original(1,1) cmap_original(255,2) cmap_original(1,3)]; cmap_original(4:end,:)];
    if max(cmap(:))>1
        cmap=cmap./256;
    end
else
    cmap=cmap_original;
end

switch params.experiment
    case '8 bars with blanks (attn)'
        minsec = 8./duration.stimframe;
        barSeq = ones(minsec,1)*round(rand(1,ceil(length(sequence)/minsec)));
        barSeq = barSeq(:);
        barSeq = barSeq(1:length(sequence));
        % force binary
        barSeq(fixSeq>2)=2; 
        barSeq(fixSeq<1)=1;
        
        % bar flickers to lower contrast
        barSeqId = abs(barSeq(:)-circshift(barSeq(:),4))>0;
        barSeq = ones(size(barSeq));
        barSeq(barSeqId) = 2;
        barSeq=barSeq.*[0; double(diff(barSeq)~=0)]; % only keep where we need to change
        
        % mask so no change during mean luminance 
        barSeq(sequence==max(sequence))=0;
        
        % fixation flickers to lower contrast
        fixSeq = ones(minsec,1)*round(rand(1,ceil(length(sequence)/minsec)));
        fixSeq = fixSeq(:)+1;
        fixSeq = fixSeq(1:length(sequence));
        % force binary
        fixSeq(fixSeq>2)=2;
        fixSeq(fixSeq<1)=1;

        fixSeqId = abs(fixSeq(:)-circshift(fixSeq(:),8))>0;
        fixSeq = ones(size(fixSeq));
        fixSeq(fixSeqId) = 2;
        fixSeq = [fixSeq fixSeq]';
        fixSeq = fixSeq(:);
        
        % double sequence with bar contrast sequence
        sequence = [sequence -barSeq]';
        sequence = sequence(:);
        
        % put in new cmap
        cmap(:,:,2) = cmap;
        
        % images
        images(images<1) = 1; % 1-254
        images(images>254) = 254; % 1-254
        cmap(255,:,:) = cmap(256,:,:);
        cmap(255,:,2) = cmap(round(128+128.*params.attn.contrast(2,1)),:,1);
        cmap(  2,:,:) = cmap(  1,:,:);
        cmap(  2,:,2) = cmap(round(128-128.*params.attn.contrast(2,1)),:,1);
        
        % timing
        timing = [timing timing+duration.stimframe./2]';
        timing = timing(:);
        
        % output
        otherSequence = double(sequence==-2);
        
    otherwise
        otherSequence = [];
        
end



% make stimulus structure for output
stimulus = createStimulusStruct(images,cmap,sequence,[],timing,fixSeq);
stimulus.cmap_original=cmap_original./256;
if exist('seq2', 'var')
    seq2 = [seq2(length(seq2)+1-duration.prescan.stimframes:end); seq2];
    stimulus.seq2=seq2;
end

% save matrix if requested
if ~isempty(params.saveMatrix),
    save(params.saveMatrix,'images');
end;

