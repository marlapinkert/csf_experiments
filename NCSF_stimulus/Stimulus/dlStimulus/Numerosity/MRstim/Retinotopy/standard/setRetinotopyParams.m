function params = setRetinotopyParams(expName, params)
% setRetinotopyParams - set parameters for different retinotopy scans 
%
% params = setRetinotopyParams([expName], [params])
%
% Sets parameter values for the specified expName.  
%
% params is a struct with at least the following fields:
%  period, numCycles, tr, interleaves, framePeriod, startScan, prescanDuration
%
% Returns the parameter values in the struct params.
% If called with no arguments, params will be a cell array listing
% all the experiment names that it is configured to do.
%
% 99.08.12 RFD rewrote WAP's code with a cleaner wrapper.
% 05.07.04 SOD ported to OSX; several changes

% the following should match those listed in the switch statement below
% expNames = {'rotating wedge (90deg duty)','rotating wedge (90deg duty) Reverse',...
%             'rotating wedge (45deg duty)','rotating wedge (45deg duty) Reverse', ...
%             'rotating wedge with blanks (45deg duty)','rotating wedge with blanks (45deg duty) Reverse', ...
% 			'expanding ring (180deg duty)', 'contracting ring (180deg duty)', ...
% 			'expanding ring (45% duty)', 'contracting ring (45% duty)', ...
% 			'expanding ring with blanks (45% duty)', 'contracting ring with blanks (45% duty)', ...
% 			'full-field, on-off', 'full-field, drift-static', ...
% 			'center-surround','center-surround (0-1deg/14-20deg)','center (0-1deg)'};
expNames = {'rotating wedge (45deg duty)','8 bars with blanks contours (b0)','8 bars with blanks contours (b90)','radial checkerboard fast','radial checkerboard slow temporal','radial checkerboard slow spatial','radial checkerboard localizer left-still-right-still'...
            '8 bars with blanks contours (random)','8 bars with blanks contours (r0)','8 bars with blanks contours (r90)',...
            'rotating wedge (90deg duty)','rotating wedge (90deg duty) BH','rotating wedge (45deg duty) Reverse', ...
            'rotating wedge with blanks (45deg duty)','rotating wedge with blanks (45deg duty) Reverse', ...
			'expanding ring (45% duty)','expanding ring (90% duty)', 'contracting ring (45% duty)', ...
			'expanding ring with blanks (45% duty)', 'contracting ring with blanks (45% duty)', ...
			'full-field, on-off','full-field, flicker (sin)','full-field, flicker (check)', ...
            'full-field, flicker (check), stereo','left vs right vs blank',...
            ...%'full-field, on-off (impulse)','full-field, drift-static','full-field, red/green',...
            ...%'full-field, red/green - red only','full-field, red/green - green only',...
            ...%'full-field, red/green - red only with blanks','full-field, red/green - green only with blanks',...
			...%'center-surround','center-surround (0-1deg/14-20deg)','center (0-1deg)',...
            ...%'2 rings',...
            '8 bars','8 bars (slow)','8 bars with blanks','8 bars with blanks (lr)','8 bars with blanks (lr 2)','8 bars with blanks (lr 3)','8 bars with blanks (Grid)','8 bars with blanks (attn)','8 bars (sinewave)',...
            '8 bars (LMS)','8 bars (LMS) with blanks',...%'8 bars (L-M)','8 bars (S)',...
            '8 bars with blanks (ecc scaled)','8 bars (letters)', '8 bars with blanks (lr ONLY)', '8 bars with blanks (lr ONLY random)', '8 bars with blanks (lr ONLY wrap)', '8 bars with blanks (lr ONLY unwrap)', ...
            '8 bars with blanks contours (0)','8 bars with blanks contours (90)','8 bars with blanks contours (-45)','8 bars with blanks contours (+45)','images.circleimage','Full-field full', ...
            'Retinotopy Images', 'Retinotopy Images Cow (lr 3)', 'Retinotopy Images Natural (lr 3)', 'Natural Images 3 Flashes','Natural Images Grid 3 Flashes','Natural Images Grid 3 Flashes_set2', 'Natural Images Grid 3 Flashes_set3','Natural Images 3 Flashes_set1','Natural Images 3 Flashes_set2','Natural Images 3 Flashes_set3','Natural Images 3 Flashes_set4','Natural Images 3 Flashes_set5','Natural Images 3 Flashes_set6','Natural Images 10 Flashes', 'Natural Images 7 Flashes', 'Natural Images 4 Flashes','Natural Images 3 Fades','Natural Images 2 Fades','Natural Images Masks Short','Natural Images Masks Long','8 bars with blanks RDK (0)', '8 bars with blanks RDK (90)',...
            '8 bars with blanks RDK (-45)', '8 bars with blanks RDK (+45)', '8 bars with blanks RDK (random)', '8 bars with blanks RDK (90) Fast', '8 bars with blanks RDK (90) Medium', '8 bars with blanks RDK (90) Slow',...
            '8 bars with blanks RDK (0) Fast', '8 bars with blanks RDK (0) Medium', '8 bars with blanks RDK (0) Slow','8 bars with blanks Cow (0) Slow','8 bars with blanks Cow (0) Medium','8 bars with blanks Cow (0) Fast',...
            '8 bars with blanks Cow (90) Slow', '8 bars with blanks Cow (90) Medium','8 bars with blanks Cow (90) Fast','8 bars with blanks Cow (Flicker) Slow','8 bars with blanks Cow (Flicker) Fast', 'Cow Full Fast', 'Cow Full Medium','Cow Full Slow','Cow Full Still',...
            '8 bars with blanks Checks Counter (90) 2.5d/s', '8 bars with blanks Checks Counter (90) 5d/s', '8 bars with blanks Checks Together (90) 2.5d/s','8 bars with blanks Checks Together (90) 5d/s',...
            '8 bars with blanks Sine (90) 1.5d/s','8 bars with blanks Sine (90) 2.5d/s','8 bars with blanks Sine (90) 3.75d/s','8 bars with blanks Sine (90) 5d/s','8 bars with blanks Sine (90) 7.5d/s', '8 bars with blanks Sine (0) 2.5d/s','8 bars with blanks Sine (0) 5d/s',...
            '8 bars with blanks Sine (90) 1.5d/s 20%','8 bars with blanks Sine (90) 2.5d/s 20%','8 bars with blanks Sine (90) 3.75d/s 20%', '8 bars with blanks Sine (90) 5d/s 20%','8 bars with blanks Sine (90) 7.5d/s 20%','Sine motion psychophysics(90)'...
            'Numbers and Dots Scaled', 'Numbers and Dots Unscaled','Numbers Only', 'Dots Unscaled', 'Dots Scaled', 'Dots Scaled Reverse', 'Dots Small', 'Dots Scaled pRF', 'Dots Scaled pRF full blanks', 'Dots Scaled pRF short', 'Dots Scaled pRF full blanks short','Dots Area pRF full blanks TR=1.5, nTRs=3', 'Dots Size pRF full blanks TR=1.5, nTRs=3','Dots Circumference pRF full blanks TR=1.5, nTRs=3','Dots Dense pRF full blanks TR=1.5, nTRs=3','Dots Shapes pRF full blanks TR=1.5, nTRs=3', 'One Dot Sizes pRF full blanks TR=1.5, nTRs=3','Dots In Noise pRF full blanks TR=1.5, nTRs=3','Dots Area pRF full blanks TR=1.5, nTRs=3', 'Dots Size pRF full blanks ECoG TR=1.5, nTRs=3','Dots Size pRF ECoG long random order','Numbers Size pRF full blanks TR=1.5, nTRs=3',...
            'Dots Area pRF full blanks TR=2.1, nTRs=2','Dots Size pRF full blanks TR=2.1, nTRs=2','Dots Circumference pRF full blanks TR=2.1, nTRs=2','Dots Dense pRF full blanks TR=2.1, nTRs=2','Dots Shapes pRF full blanks TR=2.1, nTRs=2','Number Symbols pRF full blanks TR=2.1, nTRs=2','One Dot Sizes pRF full blanks TR=2.1, nTRs=2','One Dot Sizes Constant Step pRF full blanks TR=2.1, nTRs=2','One Dot Double Sizes pRF full blanks TR=2.1, nTRs=2','One Line Size Random Orientation pRF full blanks TR=2.1, nTRs=2','8 bars with blanks (TR 2.1)','pRF bars simultaneous 3h/4v (TR 2.1)','One Dot Luminance pRF full blanks TR=2.1, nTRs=2','Dots Area pRF full blanks 4degree low numbers TR=1.95, nTRs=2', 'Dots Area pRF full blanks 4degree high numbers TR=1.95, nTRs=2', 'Dots psychophysics', 'Dots Attention', 'Dots Gaussian', 'Dots HRF', '8 bars with blanks (tr 3)',...
            'Timing pRF TR=2.1, Constant Event Number', 'Timing pRF TR=2.1, Duration Constant Frequency','Timing pRF TR=2.1, Constant Event Duration', 'Timing pRF TR=2.1, Event Number Constant Frequency', 'Timing pRF TR=2.1, Constant Set Duration',...
            '8 bars with blanks (magno)', '8 bars with blanks (parvo)', '8 bars with blanks (attention)', '8 bars with blanks (attention checkerboard)', '8 bars with blanks (attention bar psychophysics)', '8 bars with blanks (attention fixation psychophysics)', '8 bars with blanks (TR 1.8)', 'pRF bars simultaneous 2h/3v', 'pRF bars simultaneous 3h/4v'};

if ~exist('expName', 'var')
	params = expNames;
	return;
end
disp(['[' mfilename ']:Setting stimulus parameters for ' expName '.']);

% some more definitions
if isfinite(params.interleaves),
    params.framePeriod = params.tr*params.interleaves;
else
    params.framePeriod = params.tr;
end;
params.startScan   = 0;
params.quitProgKey = KbName('q');


%disp('flipping images to simulate 3T projector view');
%params.display.flipUD = 1;
%params.display.flipLR = 1;

%--------------------------------------
% background id, you can change this for manual calibration when only
% having three intensities (black, white and gray=bg)
bg = 128;
%bg = 144;
%--------------------------------------

if ~isempty(params.calibration),
    params.display = loadDisplayParams('displayName',params.calibration);
    fprintf('[%s]:loading calibration from: %s.\n',mfilename,params.calibration);
else
    params.display.screenNumber   = max(Screen('screens'));
    [width, height]=Screen('WindowSize',params.display.screenNumber);
    params.display.numPixels  = [width height];
    params.display.dimensions = [24.6 18.3];
    params.display.pixelSize  = min(params.display.dimensions./params.display.numPixels);
    params.display.distance   = 43.0474;%40;
    params.display.frameRate  = 60;
    params.display.cmapDepth  =  8;
    params.display.gammaTable = (0:255)'./255*[1 1 1];
    params.display.gamma      = params.display.gammaTable;
    params.display.backColorRgb   = [bg bg bg 255];
    params.display.textColorRgb   = [255 255 255 255];
    params.display.backColorRgb   = bg;
    params.display.backColorIndex = bg;
    params.display.maxRgbValue    = 255;
    params.display.stimRgbRange   = [0 255];
    params.display.bitsPerPixel   = 32;
    fprintf('[%s]:no calibration.\n',mfilename);    
end;
params.display.quitProgKey = params.quitProgKey;

if max(Screen('screens')) < params.display.screenNumber,
    fprintf('[%s]:resetting screenNumber %d -> %d.\n',mfilename,...
        params.display.screenNumber,max(Screen('screens')));
    params.display.screenNumber   = max(Screen('screens'));
end;

% IMPORTANT: Set stereoFlag to 1 if using stereo display.  This     %
% will affect both the stimulus presentation and the fixation point %
params.stereoFlag = 0;
params.display.stereoFlag = 0;
params.display.stereoMode = 0;


% Flickering fixation point parameters
%
% this controls the duration of the fix flicks, in frames.
% Set it to 0 to turn get no flicks.
params.fixFlickFrames = 5;
% this controls the density of the flicks, per frame.
% Thus, .01 will, on average, flick once every 100 frames.
params.fixFlickFreq = .01;

params.dispString = [expName '.  Please watch the fixation square.'];

%
% Color parameters
%
params.backRGB.dir = [1 1 1]';	% These two values are your
params.backRGB.scale = 0.5;		% standard default gray.
params.stimLMS.dir = [1 1 1]';
params.stimLMS.scale = 1.0;
%bk = findName(params.display.reservedColor,'background');
%params.display.reservedColor(bk).gunVal = (params.display.numColors-1) * ...
%								params.backRGB.scale*params.backRGB.dir';

%
% Set some common defaults
%

%--- in certain cases remove stimulus rect parameters
if isfield(params.display, 'Rect') && strcmp(params.display.position,'7T UMC scanner rear-to-front')
    switch expName
        case {'Full-field full','rotating wedge (90deg duty) BH'}
            % remove rect - defaults to entire window
            tmpRect=params.display.Rect;
            params.display=rmfield(params.display, 'Rect');
        case {'left vs right vs blank'}
            % set to full width
            params.display.Rect(1) = 0;
            params.display.Rect(3) = params.display.numPixels(1);
        otherwise
            % do nothing
    end
end

params.temporal.frequency = 2; %Hz
params.temporal.motionSteps = 10;
if ischar(params.stimSize),
    if isfield(params.display, 'Rect')
        params.radius = pix2angle(params.display, floor(min((params.display.Rect(3)-params.display.Rect(1))/2, (params.display.Rect(4)-params.display.Rect(2))/2))); 
    else
        params.radius = pix2angle(params.display,floor(min(params.display.numPixels)/2));
    end
else
    params.radius = params.stimSize;	
end;

% center square matrix?!
if isfield(params.display, 'Rect') && ~strcmp(params.experiment, 'pRF bars simultaneous 3h/4v (TR 2.1)')%&& (abs(diff(params.display.Rect([1 3])))==abs(diff(params.display.Rect([2 4]))))
    tmpy=(params.display.Rect(4)+params.display.Rect(2))/2;
    tmpx=(params.display.Rect(3)+params.display.Rect(1))/2;
    tmpsize=angle2pix(params.display, params.radius);
    params.display.Rect=[tmpx-tmpsize tmpy-tmpsize tmpx+tmpsize tmpy+tmpsize];
    params.display.Rect=params.display.Rect(:);
end

fprintf('[%s]: Stimulus size: %.3f degrees / %d pixels.\n',...
    mfilename,params.radius,angle2pix(params.display,2*params.radius));
% front projector=16; back projection=3;
params.seqDirection = 0;	% 0 or 1- just plays the movie backwards if set to 1

% Wedge parameters
params.innerRad = 0;		% Non-zero for annular wedge condition (deg)
params.wedgeDeg = 90;		% Wedge polar angle (deg)
params.subWedgeDeg = 15;	% Sub wedge polar angle (deg) 

% Ring parameter - 8 for a radius=16 stim gives a 180 degree duty cycle
params.ringDeg = params.radius/2;			% Ring radius/width (deg)

% Wedge and ring parameters
params.subRingDeg = 1;			% 1/2 radial spatial freq (deg)

params.dynamicStaticFlag = 0;	% if set, half the time will be a static stim

params.numImages = params.period/params.framePeriod;  % Number of samples of the image (i.e. per cycle)
params.duration = params.period/params.numImages;

% insert blanks
params.insertBlanks.do = 0;
params.insertBlanks.freq = 4;
params.insertBlanks.phaseLock = 0;

switch expName
case 'rotating wedge (90deg duty)',
	params.type = 'wedge';		% Set to 'wedge' or 'ring'
	params.wedgeDeg = 90;
	params.seqDirection = 0;
    params.numSubRings = (params.radius)/(2*params.subRingDeg);
case 'rotating wedge (90deg duty) BH',
	params.type = 'wedge';		% Set to 'wedge' or 'ring'
	params.wedgeDeg = 90;
	params.seqDirection = 0;
    params.numSubRings = (params.radius)/(2*params.subRingDeg);
case 'rotating wedge (90deg duty) Reverse',
	params.type = 'wedge';		% Set to 'wedge' or 'ring'
	params.wedgeDeg = 90;
	params.seqDirection = 1;
    params.numSubRings = (params.radius)/(2*params.subRingDeg);
case 'rotating wedge (45deg duty)',
	params.type = 'wedge';
	params.wedgeDeg = 45;
	params.seqDirection = 0;
	params.innerRad = 0;
    params.numSubRings = (params.radius)/(2*params.subRingDeg);
case 'rotating wedge (45deg duty) Reverse',
	params.type = 'wedge';
	params.wedgeDeg = 45;
	params.seqDirection = 1;
	params.innerRad = 0;
    params.numSubRings = (params.radius)/(2*params.subRingDeg);
case 'rotating wedge with blanks (45deg duty)',
	params.type = 'wedge';
	params.wedgeDeg = 45;
	params.seqDirection = 0;
	params.innerRad = 0;
    params.insertBlanks.do = 1;
    params.numSubRings = (params.radius)/(2*params.subRingDeg);
case 'rotating wedge with blanks (45deg duty) Reverse',
	params.type = 'wedge';
	params.wedgeDeg = 45;
	params.seqDirection = 1;
	params.innerRad = 0;
    params.insertBlanks.do = 1;
    params.numSubRings = (params.radius)/(2*params.subRingDeg);
case 'left vs right vs blank',
	params.type = 'wedge';
	params.wedgeDeg = 180;
	params.seqDirection = 1;
	params.innerRad = 0.25;
    params.insertBlanks.do = 1;
    params.subRingDeg = 1;
    params.numSubRings = (params.radius)/(2*params.subRingDeg);
case 'expanding ring (90% duty)',
	params.type = 'ring';
	params.ringDeg = params.radius/4;
	params.seqDirection = 0;
    params.numSubRings = (params.radius)/(2*params.subRingDeg);
case 'contracting ring (180deg duty)',
	params.type = 'ring';
	params.ringDeg = params.radius/2;
	params.seqDirection = 1;
    params.numSubRings = (params.radius)/(2*params.subRingDeg);
case 'expanding ring (45% duty)',
	params.type = 'ring';
	params.ringDeg = params.radius/8;
	params.seqDirection = 0;
    params.numSubRings = (params.radius-params.innerRad)/(params.radius);
case 'contracting ring (45% duty)',
	params.type = 'ring';
	params.ringDeg = params.radius/8;
	params.seqDirection = 1;
    params.numSubRings = (params.radius-params.innerRad)/(params.radius);
case 'expanding ring with blanks (45% duty)',
	params.type = 'ring';
	params.ringDeg = params.radius/8;
	params.seqDirection = 0;
    params.insertBlanks.do = 1;
    params.numSubRings = (params.radius-params.innerRad)/(params.radius);
case 'contracting ring with blanks (45% duty)',
	params.type = 'ring';
	params.ringDeg = params.radius/8;
	params.seqDirection = 1;
    params.insertBlanks.do = 1;
    params.numSubRings = (params.radius-params.innerRad)/(params.radius);
case 'full-field, on-off',
	params.type = 'center-surround';
	params.centerInnerRad = 0;
	params.centerOuterRad = params.radius;
	params.surroundInnerRad = params.radius;
	params.surroundOuterRad = params.radius;
	params.numImages = 2;
	params.duration = params.period/params.numImages;
    params.numSubRings = (params.radius)/(2*params.subRingDeg);
    
case {'radial checkerboard fast'}, 
    params.type = 'center-surround';
    params.subRingDeg = 1; %Spatial frequency in degrees
	params.centerInnerRad = 0;
	params.centerOuterRad = params.radius;
	params.surroundInnerRad = params.radius;
	params.surroundOuterRad = params.radius;
	params.numImages = 2;
	params.duration = params.period/params.numImages;
    params.numSubRings = (params.radius)/(2*params.subRingDeg);  
    params.temporal.frequency = 1;
    params.temporal.motionSteps = 30;
    
case {'radial checkerboard slow temporal'}, 
    params.type = 'center-surround';
    params.subRingDeg = 4; %Spatial frequency in degrees
	params.centerInnerRad = 0;
	params.centerOuterRad = params.radius;
	params.surroundInnerRad = params.radius;
	params.surroundOuterRad = params.radius;
	params.numImages = 2;
	params.duration = params.period/params.numImages;
    params.numSubRings = (params.radius)/(2*params.subRingDeg);
    params.temporal.frequency = 1;
    params.temporal.motionSteps = 30;
    
case {'radial checkerboard slow spatial'}, 
    params.type = 'center-surround';
    params.subRingDeg = 4/5; %Spatial frequency in degrees
	params.centerInnerRad = 0;
	params.centerOuterRad = params.radius;
	params.surroundInnerRad = params.radius;
	params.surroundOuterRad = params.radius;
	params.numImages = 2;
	params.duration = params.period/params.numImages;
    params.numSubRings = (params.radius)/(2*params.subRingDeg);    
    params.temporal.frequency = 5;
    params.temporal.motionSteps = 6;
    

case {'radial checkerboard localizer left-still-right-still'}, 
    params.type = 'center-surround';
    params.subRingDeg = 4; %Spatial frequency in degrees
	params.centerInnerRad = 0;
	params.centerOuterRad = params.radius;
	params.surroundInnerRad = params.radius;
	params.surroundOuterRad = params.radius;
	params.numImages = 2;
	params.duration = params.period/params.numImages;
    params.numSubRings = (params.radius)/(2*params.subRingDeg);
    params.temporal.frequency = 1;
    params.temporal.motionSteps = 30;
    
case 'full-field, on-off (impulse)',
	params.type = 'center-surround';
	params.centerInnerRad = 0;
	params.centerOuterRad = params.radius;
	params.surroundInnerRad = params.radius;
	params.surroundOuterRad = params.radius;
	params.numImages = 2;
	params.duration  = params.period/params.numImages;
    params.numSubRings = (params.radius)/(2*params.subRingDeg);
    params.impulse   = input('Please enter impulse time (sec): ');
    params.insertBlanks.do = 1;    
    params.insertBlanks.freq = params.numCycles;
    params.insertBlanks.phaseLock = 1;
case 'full-field, drift-static',
	params.type = 'ring';
	params.dynamicStaticFlag = 1;	% if set, half the time will be a static stim
	params.innerRad = 0;		% Non-zero for annular wedge condition (deg)
	params.ringDeg = params.radius;			% Ring radius/width (deg)
	params.numImages = 2;
	params.duration = params.period/params.numImages;
    params.numSubRings = (params.radius)/(2*params.subRingDeg);
case 'full-field, flicker (sin)',
	params.type = 'ring';
	params.dynamicStaticFlag = 1;	% if set, half the time will be a static stim
	params.innerRad = 0;		% Non-zero for annular wedge condition (deg)
	params.ringDeg = params.radius;			% Ring radius/width (deg)
	params.numImages = 1;
	params.duration = params.period/params.numImages;
    params.subRingDeg = 0.5; %deg
    params.numSubRings = (params.radius)/(2*params.subRingDeg);
    params.flickerFrequencies = [1.5 7.5]; %Hz
    params.temporal.motionSteps = 30;
    params.flickerType = 'sin';
    params.flickerContrast = 0.2;%[1 0.2];
case 'full-field, flicker (check)',
	params.type = 'ring';
	params.dynamicStaticFlag = 1;	% if set, half the time will be a static stim
	params.innerRad = 0;		% Non-zero for annular wedge condition (deg)
	params.ringDeg = params.radius;			% Ring radius/width (deg)
	params.numImages = 1;
	params.duration = params.period/params.numImages;
    params.subRingDeg = 1; %deg
    params.numSubRings = (params.radius)/(2*params.subRingDeg);
    params.flickerFrequencies = [1.5 7.5]; %Hz
    params.temporal.motionSteps = 30;
    params.flickerType = 'check';
    params.flickerContrast = 0.2;
case 'full-field, flicker (check), stereo',
	params.type = 'ring';
	params.dynamicStaticFlag = 1;	% if set, half the time will be a static stim
	params.innerRad = 0;		% Non-zero for annular wedge condition (deg)
    params.display.quadrant='R';
    params.display.fusionBackground=true;
    params.display.fixationIndent=2;
    if params.display.quadrant~=false
        params.radius=params.radius*2;
    end
    params.ringDeg = params.radius;			% Ring radius/width (deg)
	params.numImages = 1;
	params.duration = params.period/params.numImages;
    params.subRingDeg = 1; %deg
    params.numSubRings = (params.radius)/(2*params.subRingDeg);
    params.flickerFrequencies = [7.5]; %Hz
    params.temporal.motionSteps = 30;
    params.flickerType = 'check';
    params.flickerContrast = 1;
    params.display.stereoMode = 4; % Stereo for cross-fusing
    params.display.stereoFlag = 1;
    params.display.disparity =0;
case 'center-surround',
	params.type = 'center-surround';
	params.centerInnerRad = 0.2;
	params.centerOuterRad = 4;
	params.surroundInnerRad = 6;%14;
	params.surroundOuterRad = 20;
	params.numImages = 2;
	params.duration = params.period/params.numImages;
    params.numSubRings = (params.radius)/(2*params.subRingDeg);
case 'center-surround (0-1?/14-20?)',
	params.type = 'center-surround';
	params.centerInnerRad = 0;
	params.centerOuterRad = 1;
	params.surroundInnerRad = 14;
	params.surroundOuterRad = 20;
	params.numImages = 2;
	params.duration = params.period/params.numImages;
    params.numSubRings = (params.radius)/(2*params.subRingDeg);
case 'center (0-1?)',
	params.type = 'center-surround';
	params.centerInnerRad = 0;
	params.centerOuterRad = 1;
	params.surroundInnerRad = 20;
	params.surroundOuterRad = 20;
	params.numImages = 2;
	params.duration = params.period/params.numImages;
    params.numSubRings = (params.radius)/(2*params.subRingDeg);
case 'full-field, red/green',
	params.type = 'center-surround';
	params.centerInnerRad = 0;
	params.centerOuterRad = params.radius;
	params.surroundInnerRad = 0;
	params.surroundOuterRad = params.radius;
	params.numImages = 2;
	params.duration = params.period/params.numImages;
    params.numSubRings = (params.radius)/(2*params.subRingDeg);
    params.contrast    = 0.5;%[1 0.1]; % red blue
    params.startScan   = 0;

case 'full-field, red/green - green only',
	params.type = 'center-surround';
	params.centerInnerRad = 0;
	params.centerOuterRad = params.radius*2;
	params.surroundInnerRad = 0;
	params.surroundOuterRad = 0;
	params.numImages = 2;
	params.duration = params.period/params.numImages;
    params.numSubRings = (params.radius)/(2*params.subRingDeg);
    params.contrast    = 0.5;%[1 0.1]; % red blue
    params.startScan   = 0;

case 'full-field, red/green - red only',
	params.type = 'center-surround';
	params.centerInnerRad = 0;
	params.centerOuterRad = 0;
	params.surroundInnerRad = 0;
	params.surroundOuterRad = params.radius;
	params.numImages = 2;
	params.duration = params.period/params.numImages;
    params.numSubRings = (params.radius)/(2*params.subRingDeg);
    params.contrast    = 0.5;%[1 0.1]; % red blue
    params.startScan   = 0;

case 'Full-field full',
	params.type = 'center-surround';
	params.centerInnerRad = 0;
	params.centerOuterRad = 0;
	params.surroundInnerRad = 0;
	params.surroundOuterRad = params.radius;
	params.numImages = 2;
	params.duration = params.period/params.numImages;
    params.numSubRings = (params.radius)/(2*params.subRingDeg);
    params.contrast    = 0.5;%[1 0.1]; % red blue
    params.startScan   = 0;
    %For ecog display. fMRI display can't go this fast
    %params.temporal.frequency = 4;
    params.temporal.motionSteps = 10;
    params.temporal.frequency = 2;
    
case 'full-field, red/green - green only with blanks',
	params.type = 'center-surround';
	params.centerInnerRad = 0;
	params.centerOuterRad = params.radius;
	params.surroundInnerRad = 0;
	params.surroundOuterRad = 0;
	params.numImages = 2;
	params.duration = params.period/params.numImages;
    params.numSubRings = (params.radius)/(2*params.subRingDeg);
    params.contrast    = 0.5;%[1 0.1]; % red blue
    params.insertBlanks.do = 1;
    params.insertBlanks.freq = params.numCycles;
    params.startScan   = 0;

case 'full-field, red/green - red only with blanks',
	params.type = 'center-surround';
	params.centerInnerRad = 0;
	params.centerOuterRad = 0;
	params.surroundInnerRad = 0;
	params.surroundOuterRad = params.radius;
	params.numImages = 2;
	params.duration = params.period/params.numImages;
    params.numSubRings = (params.radius)/(2*params.subRingDeg);
    params.contrast    = 0.5;%[1 0.1]; % red blue
    params.insertBlanks.do = 1;
    params.insertBlanks.freq = params.numCycles;
    params.startScan   = 0;

case '2 rings',
	params.type = 'ring';
	params.ringDeg = params.radius/8;
	params.seqDirection = 0;
    params.numSubRings = (params.radius-params.innerRad)/(params.radius);
    params.numCycles = 5; % second is 5+2
    params.period    = 28*params.tr*params.numCycles; 
    params.numImages = params.period/params.framePeriod;

case '8 bars',
	params.type = 'bar';
	params.ringDeg = params.radius./2;%params.radius/4;
	params.seqDirection = 0;
    params.insertBlanks.do = 0;
    params.numSubRings = (params.radius-params.innerRad)/(params.radius);
case '8 bars (slow)',
	params.type = 'bar';
	params.ringDeg = params.radius/3;
	params.seqDirection = 0;
    params.insertBlanks.do = 0;
    params.numSubRings = (params.radius-params.innerRad)/(params.radius);
    params.display.stimRgbRange   = [1 254];

case '8 bars with blanks',
	params.type = 'bar';
	params.ringDeg = params.radius./4; % HW1 used radius/2
	params.seqDirection = 0;
    params.insertBlanks.do = 1;
    params.numSubRings = (params.radius-params.innerRad)/(params.radius);
%    params.numSubRings = (params.radius)/(2*params.subRingDeg);

case '8 bars with blanks (lr)',
	params.type = 'bar';
	params.ringDeg = params.radius./4; 
	params.seqDirection = 0;
    params.insertBlanks.do = 1;
    params.numSubRings = (params.radius-params.innerRad)/(params.radius);
%    params.numSubRings = (params.radius)/(2*params.subRingDeg);

case '8 bars with blanks (lr 2)',
	params.type = 'bar';
	params.ringDeg = params.radius./4; 
	params.seqDirection = 0;
    params.insertBlanks.do = 1;
    params.numSubRings = (params.radius-params.innerRad)/(params.radius);
case '8 bars with blanks (lr 3)',
	params.type = 'bar';
	params.ringDeg = params.radius./4; 
	params.seqDirection = 0;
    params.insertBlanks.do = 1;
    params.numSubRings = (params.radius-params.innerRad)/(params.radius);
case '8 bars with blanks (TR 2.1)',
    params.type = 'bar';
	params.ringDeg = params.radius./4; 
	params.seqDirection = 0;
    params.insertBlanks.do = 1;
    params.numSubRings = (params.radius-params.innerRad)/(params.radius); 
case '8 bars with blanks (TR 1.8)',
    params.type = 'bar';
	params.ringDeg = params.radius./4; 
	params.seqDirection = 0;
    params.insertBlanks.do = 1;
    params.numSubRings = (params.radius-params.innerRad)/(params.radius);    
case '8 bars with blanks (Grid)',
	params.type = 'bar';
	params.ringDeg = 3;%params.radius./3; 
	params.seqDirection = 0;
    params.insertBlanks.do = 1;
    %params.numSubRings = (params.radius-params.innerRad)/(params.radius);
    params.numSubRings = 1;
    params.temporal.frequency = 3;
    params.temporal.motionSteps = 10;
case 'pRF bars simultaneous 2h/3v', 
    params.type = 'bar';
	params.ringDeg = params.radius./4; 
	params.seqDirection = 0;
    params.insertBlanks.do = 1;
    params.numSubRings = (params.radius-params.innerRad)/(params.radius);  
    params.insertBlanks.freq=2;
case'pRF bars simultaneous 3h/4v',
    params.type = 'bar';
	params.ringDeg = params.radius./4; 
	params.seqDirection = 0;
    params.insertBlanks.do = 1;
    params.numSubRings = 1.5;%(params.radius-params.innerRad)/(params.radius); 
    params.insertBlanks.freq=2;
case 'pRF bars simultaneous 3h/4v (TR 2.1)'
    params.type = 'bar';
	params.ringDeg = params.radius./4; 
	params.seqDirection = 0;
    params.insertBlanks.do = 1;
    params.numSubRings = 1.5;%(params.radius-params.innerRad)/(params.radius); 
    params.insertBlanks.freq=2;
case '8 bars with blanks contours (0)', 
	params.type = 'bar';
	params.ringDeg = params.radius./3; 
	params.seqDirection = 0;
    params.insertBlanks.do = 1;
    params.numSubRings = (params.radius-params.innerRad)/(params.radius);
%    params.numSubRings = (params.radius)/(2*params.subRingDeg);
    params.temporal.motionSteps = 10;
    params.contour.contourOrientation = 0;
    params.contour.contourBandpass = 30;
case '8 bars with blanks contours (90)', 
	params.type = 'bar';
	params.ringDeg = params.radius./3; 
	params.seqDirection = 0;
    params.insertBlanks.do = 1;
    params.numSubRings = (params.radius-params.innerRad)/(params.radius);
%    params.numSubRings = (params.radius)/(2*params.subRingDeg);
    params.temporal.motionSteps = 10;
    params.contour.contourOrientation = 90;
    params.contour.contourBandpass = 30;
case '8 bars with blanks contours (-45)', 
	params.type = 'bar';
	params.ringDeg = params.radius./3; 
	params.seqDirection = 0;
    params.insertBlanks.do = 1;
    params.numSubRings = (params.radius-params.innerRad)/(params.radius);
%    params.numSubRings = (params.radius)/(2*params.subRingDeg);
    params.temporal.motionSteps = 10;
    params.contour.contourOrientation = 135;
    params.contour.contourBandpass = 30;
case '8 bars with blanks contours (+45)', 
	params.type = 'bar';
	params.ringDeg = params.radius./3; 
	params.seqDirection = 0;
    params.insertBlanks.do = 1;
    params.numSubRings = (params.radius-params.innerRad)/(params.radius);
%    params.numSubRings = (params.radius)/(2*params.subRingDeg);
    params.temporal.motionSteps = 10;
    params.contour.contourOrientation = 45;
    params.contour.contourBandpass = 30;
case '8 bars with blanks contours (random)', 
	params.type = 'bar';
	params.ringDeg = params.radius./3; 
	params.seqDirection = 0;
    params.insertBlanks.do = 1;
    params.numSubRings = (params.radius-params.innerRad)/(params.radius);
%    params.numSubRings = (params.radius)/(2*params.subRingDeg);
    params.temporal.motionSteps = 10;
    params.contour.contourOrientation = 0;
    params.contour.contourBandpass = 360;%180;

case '8 bars with blanks contours (r0)', 
	params.type = 'bar';
	params.ringDeg = params.radius./3; 
	params.seqDirection = 0;
    params.insertBlanks.do = 1;
    params.numSubRings = (params.radius-params.innerRad)/(params.radius);
%    params.numSubRings = (params.radius)/(2*params.subRingDeg);
    params.temporal.motionSteps = 10;
    params.contour.contourOrientation = 0;
    params.contour.contourBandpass = 30;

case '8 bars with blanks contours (r90)', 
	params.type = 'bar';
	params.ringDeg = params.radius./3; 
	params.seqDirection = 0;
    params.insertBlanks.do = 1;
    params.numSubRings = (params.radius-params.innerRad)/(params.radius);
%    params.numSubRings = (params.radius)/(2*params.subRingDeg);
    params.temporal.motionSteps = 10;
    params.contour.contourOrientation = 90;
    params.contour.contourBandpass = 30;
    
case '8 bars with blanks contours (b0)', 
	params.type = 'bar';
	params.ringDeg = params.radius./3; 
	params.seqDirection = 0;
    params.insertBlanks.do = 1;
    params.numSubRings = (params.radius-params.innerRad)/(params.radius);
%    params.numSubRings = (params.radius)/(2*params.subRingDeg);
    params.temporal.motionSteps = 10;
    params.contour.contourOrientation = 0;
    params.contour.contourBandpass = 30;

case '8 bars with blanks contours (b90)', 
	params.type = 'bar';
	params.ringDeg = params.radius./3; 
	params.seqDirection = 0;
    params.insertBlanks.do = 1;
    params.numSubRings = (params.radius-params.innerRad)/(params.radius);
%    params.numSubRings = (params.radius)/(2*params.subRingDeg);
    params.temporal.motionSteps = 10;
    params.contour.contourOrientation = 90;
    params.contour.contourBandpass = 30;

case '8 bars with blanks (ecc scaled)',
	params.type = 'bar';
	params.ringDeg = params.radius./4; 
	params.seqDirection = 0;
    params.insertBlanks.do = 1;
    params.numSubRings = (params.radius-params.innerRad)/(params.radius);
%    params.numSubRings = (params.radius)/(2*params.subRingDeg);

case '8 bars with blanks (attn)',
	params.type = 'bar';
	params.ringDeg = params.radius./4;
	params.seqDirection = 0;
    params.insertBlanks.do = 1;
    params.numSubRings = (params.radius-params.innerRad)/(params.radius);
    params.attn.contrast = [1 1; % normal stim fix
                           .4 .5]; % other stim fix
%    params.numSubRings = (params.radius)/(2*params.subRingDeg);

case '8 bars (sinewave)',
	params.type = 'bar';
	params.ringDeg = params.radius/3;
	params.seqDirection = 0;
    params.insertBlanks.do = 0;
    params.numSubRings = input('How many cycles/degree?: ');
    % reset motionSteps (flicker)
    params.temporal.motionSteps = 2;
%   params.numSubRings = (params.radius-params.innerRad)/(params.radius);
case '8 bars (LMS)',
	params.type = 'bar';
	params.ringDeg = params.radius/3;
    params.seqDirection = 0;
    params.insertBlanks.do = 0;
    params.numSubRings = 1;
    params.temporal.motionSteps = 8;

case '8 bars (LMS) with blanks',
    params.type = 'bar';
    params.ringDeg = params.radius/3;
    params.seqDirection = 0;
    params.insertBlanks.do = 1;
    params.numSubRings = 1;
    params.temporal.frequency = 2; %Hz
    params.temporal.motionSteps = 8;
case '8 bars with blanks (lr ONLY)',
	params.type = 'bar';
	params.ringDeg = params.radius./4; 
    params.insertBlanks.freq = params.numCycles;
	params.seqDirection = 0;
    params.insertBlanks.do = 1;
    params.numSubRings = (params.radius-params.innerRad)/(params.radius);
case 'Retinotopy Images',
	params.type = 'bar';
	params.ringDeg = params.radius./4; 
    params.insertBlanks.freq = params.numCycles.*4;
	params.seqDirection = 0;
    params.insertBlanks.do = 1;
    params.numSubRings = (params.radius-params.innerRad)/(params.radius);
    
case 'Retinotopy Images Cow (lr 3)',
	params.type = 'bar';
	params.ringDeg = params.radius./4; 
	params.seqDirection = 0;
    params.insertBlanks.do = 1;
    params.numSubRings = (params.radius-params.innerRad)/(params.radius);
    
case 'Retinotopy Images Natural (lr 3)',
	params.type = 'bar';
	params.ringDeg = params.radius./4; 
	params.seqDirection = 0;
    params.insertBlanks.do = 1;
    params.numSubRings = (params.radius-params.innerRad)/(params.radius);
    
case 'Natural Images 3 Flashes',
	params.type = 'bar';
    params.numSubRings = (params.radius-params.innerRad)/(params.radius); 
    params.period=params.period*params.numCycles;
    params.numCycles=1;    
    params.numImages = params.period/params.framePeriod;  % Number of samples of the image (i.e. per cycle)
    params.duration = params.period/params.numImages;
    params.naturalimage.imageOff=0.2;   %Time between image presentations in the same TR
    params.naturalimage.imageOn=0.3;
    params.naturalimage.fadeLength=0;
    params.naturalimage.imageShows=3;
    params.naturalimage.TRsOn=6;
    params.naturalimage.imageFileName='/Users/lab/Documents/MATLAB/RetinotopyImages/stimuli-250310.mat';
    params.naturalimage.differentImages=20;
case 'Natural Images Grid 3 Flashes',
	params.type = 'bar';
    params.numSubRings = (params.radius-params.innerRad)/(params.radius); 
    params.period=params.period*params.numCycles;
    params.numCycles=1;    
    params.numImages = params.period/params.framePeriod;  % Number of samples of the image (i.e. per cycle)
    params.duration = params.period/params.numImages;
    params.naturalimage.imageOff=0.2;   %Time between image presentations in the same TR
    params.naturalimage.imageOn=0.3;
    params.naturalimage.fadeLength=0;
    params.naturalimage.imageShows=3;
    params.naturalimage.TRsOn=6;
    params.naturalimage.imageFileName='/Users/lab/Documents/MATLAB//RetinotopyImages/synstimuli-040411.mat';
    params.naturalimage.differentImages=20;
case 'Natural Images Grid 3 Flashes_set2',
	params.type = 'bar';
    params.numSubRings = (params.radius-params.innerRad)/(params.radius); 
    params.period=params.period*params.numCycles;
    params.numCycles=1;    
    params.numImages = params.period/params.framePeriod;  % Number of samples of the image (i.e. per cycle)
    params.duration = params.period/params.numImages;
    params.naturalimage.imageOff=0.2;   %Time between image presentations in the same TR
    params.naturalimage.imageOn=0.3;
    params.naturalimage.fadeLength=0;
    params.naturalimage.imageShows=3;
    params.naturalimage.TRsOn=6;
    params.naturalimage.imageFileName='/Users/lab/Documents/MATLAB/RetinotopyImages/synstimuli-160511-1.mat';
    params.naturalimage.differentImages=20;
case 'Natural Images Grid 3 Flashes_set3',
	params.type = 'bar';
    params.numSubRings = (params.radius-params.innerRad)/(params.radius); 
    params.period=params.period*params.numCycles;
    params.numCycles=1;    
    params.numImages = params.period/params.framePeriod;  % Number of samples of the image (i.e. per cycle)
    params.duration = params.period/params.numImages;
    params.naturalimage.imageOff=0.2;   %Time between image presentations in the same TR
    params.naturalimage.imageOn=0.3;
    params.naturalimage.fadeLength=0;
    params.naturalimage.imageShows=3;
    params.naturalimage.TRsOn=6;
    params.naturalimage.imageFileName='/Users/lab/Documents/MATLAB/RetinotopyImages/synstimuli-160511-2.mat';
    params.naturalimage.differentImages=20;
    
    case 'Natural Images 3 Flashes_set1',
	params.type = 'bar';
    params.numSubRings = (params.radius-params.innerRad)/(params.radius); 
    params.period=params.period*params.numCycles;
    params.numCycles=1;    
    params.numImages = params.period/params.framePeriod;  % Number of samples of the image (i.e. per cycle)
    params.duration = params.period/params.numImages;
    params.naturalimage.imageOff=0.2;   %Time between image presentations in the same TR
    params.naturalimage.imageOn=0.3;
    params.naturalimage.fadeLength=0;
    params.naturalimage.imageShows=3;
    params.naturalimage.TRsOn=6;
    params.naturalimage.imageFileName='/Users/lab/Documents/MATLAB/RetinotopyImages/naturalStimuli-060611-1.mat';
    params.naturalimage.differentImages=20;
case 'Natural Images 3 Flashes_set2',
	params.type = 'bar';
    params.numSubRings = (params.radius-params.innerRad)/(params.radius); 
    params.period=params.period*params.numCycles;
    params.numCycles=1;    
    params.numImages = params.period/params.framePeriod;  % Number of samples of the image (i.e. per cycle)
    params.duration = params.period/params.numImages;
    params.naturalimage.imageOff=0.2;   %Time between image presentations in the same TR
    params.naturalimage.imageOn=0.3;
    params.naturalimage.fadeLength=0;
    params.naturalimage.imageShows=3;
    params.naturalimage.TRsOn=6;
    params.naturalimage.imageFileName='/Users/lab/Documents/MATLAB/RetinotopyImages/naturalStimuli-060611-2.mat';
    params.naturalimage.differentImages=20;
case 'Natural Images 3 Flashes_set3',
	params.type = 'bar';
    params.numSubRings = (params.radius-params.innerRad)/(params.radius); 
    params.period=params.period*params.numCycles;
    params.numCycles=1;    
    params.numImages = params.period/params.framePeriod;  % Number of samples of the image (i.e. per cycle)
    params.duration = params.period/params.numImages;
    params.naturalimage.imageOff=0.2;   %Time between image presentations in the same TR
    params.naturalimage.imageOn=0.3;
    params.naturalimage.fadeLength=0;
    params.naturalimage.imageShows=3;
    params.naturalimage.TRsOn=6;
    params.naturalimage.imageFileName='/Users/lab/Documents/MATLAB/RetinotopyImages/naturalStimuli-060611-3.mat';
    params.naturalimage.differentImages=20;    

case 'Natural Images 3 Flashes_set4',
	params.type = 'bar';
    params.numSubRings = (params.radius-params.innerRad)/(params.radius); 
    params.period=params.period*params.numCycles;
    params.numCycles=1;    
    params.numImages = params.period/params.framePeriod;  % Number of samples of the image (i.e. per cycle)
    params.duration = params.period/params.numImages;
    params.naturalimage.imageOff=0.2;   %Time between image presentations in the same TR
    params.naturalimage.imageOn=0.3;
    params.naturalimage.fadeLength=0;
    params.naturalimage.imageShows=3;
    params.naturalimage.TRsOn=6;
    params.naturalimage.imageFileName='/Users/lab/Documents/MATLAB/RetinotopyImages/naturalStimuli-080115-4.mat';
    params.naturalimage.differentImages=20; 
case 'Natural Images 3 Flashes_set5',
	params.type = 'bar';
    params.numSubRings = (params.radius-params.innerRad)/(params.radius); 
    params.period=params.period*params.numCycles;
    params.numCycles=1;    
    params.numImages = params.period/params.framePeriod;  % Number of samples of the image (i.e. per cycle)
    params.duration = params.period/params.numImages;
    params.naturalimage.imageOff=0.2;   %Time between image presentations in the same TR
    params.naturalimage.imageOn=0.3;
    params.naturalimage.fadeLength=0;
    params.naturalimage.imageShows=3;
    params.naturalimage.TRsOn=6;
    params.naturalimage.imageFileName='/Users/lab/Documents/MATLAB/RetinotopyImages/naturalStimuli-080115-5.mat';
    params.naturalimage.differentImages=20; 
 case 'Natural Images 3 Flashes_set6',
	params.type = 'bar';
    params.numSubRings = (params.radius-params.innerRad)/(params.radius); 
    params.period=params.period*params.numCycles;
    params.numCycles=1;    
    params.numImages = params.period/params.framePeriod;  % Number of samples of the image (i.e. per cycle)
    params.duration = params.period/params.numImages;
    params.naturalimage.imageOff=0.2;   %Time between image presentations in the same TR
    params.naturalimage.imageOn=0.3;
    params.naturalimage.fadeLength=0;
    params.naturalimage.imageShows=3;
    params.naturalimage.TRsOn=6;
    params.naturalimage.imageFileName='/Users/lab/Documents/MATLAB/RetinotopyImages/naturalStimuli-080115-6.mat';
    params.naturalimage.differentImages=20; 
case 'Natural Images 10 Flashes',
	params.type = 'bar';
    params.numSubRings = (params.radius-params.innerRad)/(params.radius); 
    params.period=params.period*params.numCycles;
    params.numCycles=1;    
    params.numImages = params.period/params.framePeriod;  % Number of samples of the image (i.e. per cycle)
    params.duration = params.period/params.numImages;
    params.naturalimage.imageOff=0.1;   %Time between image presentations in the same TR
    params.naturalimage.imageOn=0.1;
    params.naturalimage.fadeLength=0;
    params.naturalimage.imageShows=10;
case 'Natural Images 7 Flashes',
	params.type = 'bar';
    params.numSubRings = (params.radius-params.innerRad)/(params.radius); 
    params.period=params.period*params.numCycles;
    params.numCycles=1;    
    params.numImages = params.period/params.framePeriod;  % Number of samples of the image (i.e. per cycle)
    params.duration = params.period/params.numImages;
    params.naturalimage.imageOff=0.1;   %Time between image presentations in the same TR
    params.naturalimage.imageOn=0.2;
    params.naturalimage.fadeLength=0;
    params.naturalimage.imageShows=7;  
case 'Natural Images 4 Flashes',
	params.type = 'bar';
    params.numSubRings = (params.radius-params.innerRad)/(params.radius); 
    params.period=params.period*params.numCycles;
    params.numCycles=1;    
    params.numImages = params.period/params.framePeriod;  % Number of samples of the image (i.e. per cycle)
    params.duration = params.period/params.numImages;
    params.naturalimage.imageOff=0.1;   %Time between image presentations in the same TR
    params.naturalimage.imageOn=0.4;
    params.naturalimage.fadeLength=0;
    params.naturalimage.imageShows=4;
case 'Natural Images 3 Fades',
	params.type = 'bar';
    params.numSubRings = (params.radius-params.innerRad)/(params.radius); 
    params.period=params.period*params.numCycles;
    params.numCycles=1;    
    params.numImages = params.period/params.framePeriod;  % Number of samples of the image (i.e. per cycle)
    params.duration = params.period/params.numImages;
    params.naturalimage.imageOff=0.1;   %Time between image presentations in the same TR
    params.naturalimage.imageOn=0.3;
    params.naturalimage.fadeLength=0.15;
    params.naturalimage.imageShows=3;
case 'Natural Images 2 Fades',
	params.type = 'bar';
    params.numSubRings = (params.radius-params.innerRad)/(params.radius); 
    params.period=params.period*params.numCycles;
    params.numCycles=1;    
    params.numImages = params.period/params.framePeriod;  % Number of samples of the image (i.e. per cycle)
    params.duration = params.period/params.numImages;
    params.naturalimage.imageOff=0.2;   %Time between image presentations in the same TR
    params.naturalimage.imageOn=0.3;
    params.naturalimage.fadeLength=0.3;
    params.naturalimage.imageShows=2;
case 'Natural Images Masks Short',
	params.type = 'bar';
    params.numSubRings = (params.radius-params.innerRad)/(params.radius); 
    params.period=params.period*params.numCycles;
    params.numCycles=1;    
    params.numImages = params.period/params.framePeriod;  % Number of samples of the image (i.e. per cycle)
    params.duration = params.period/params.numImages;
    params.naturalimage.imageOff=0;   %Time between image presentations in the same TR
    params.naturalimage.imageOn=0.05;
    params.naturalimage.fadeLength=0.05;
    params.naturalimage.imageShows=20;
case 'Natural Images Masks Long',
	params.type = 'bar';
    params.numSubRings = (params.radius-params.innerRad)/(params.radius); 
    params.period=params.period*params.numCycles;
    params.numCycles=1;    
    params.numImages = params.period/params.framePeriod;  % Number of samples of the image (i.e. per cycle)
    params.duration = params.period/params.numImages;
    params.naturalimage.imageOff=0.8;   %Time between image presentations in the same TR
    params.naturalimage.imageOn=1;
    params.naturalimage.fadeLength=0.2;
    params.naturalimage.imageShows=1;
case '8 bars with blanks RDK (0)',
	params.type = 'bar';
	params.ringDeg = params.radius./4; 
    params.insertBlanks.freq = params.numCycles.*4;
	params.seqDirection = 0;
    params.insertBlanks.do = 1;
    params.numSubRings = (params.radius-params.innerRad)/(params.radius);
    params.RDK.orientationInDeg=0;
case '8 bars with blanks RDK (90)',
	params.type = 'bar';
	params.ringDeg = params.radius./4; 
    params.insertBlanks.freq = params.numCycles.*4;
	params.seqDirection = 0;
    params.insertBlanks.do = 1;
    params.numSubRings = (params.radius-params.innerRad)/(params.radius);
    params.RDK.orientationInDeg=90;
case '8 bars with blanks RDK (-45)',
	params.type = 'bar';
	params.ringDeg = params.radius./4; 
    params.insertBlanks.freq = params.numCycles.*4;
	params.seqDirection = 0;
    params.insertBlanks.do = 1;
    params.numSubRings = (params.radius-params.innerRad)/(params.radius);
    params.RDK.orientationInDeg=135;
case '8 bars with blanks RDK (+45)',
	params.type = 'bar';
	params.ringDeg = params.radius./4; 
    params.insertBlanks.freq = params.numCycles.*4;
	params.seqDirection = 0;
    params.insertBlanks.do = 1;
    params.numSubRings = (params.radius-params.innerRad)/(params.radius);
    params.RDK.orientationInDeg=45;
case '8 bars with blanks RDK (random)',
	params.type = 'bar';
	params.ringDeg = params.radius./4; 
    params.insertBlanks.freq = params.numCycles.*4;
	params.seqDirection = 0;
    params.insertBlanks.do = 1;
    params.numSubRings = (params.radius-params.innerRad)/(params.radius);
    params.RDK.orientationInDeg=999;  
    params.RDK.dotSpeed=4;
case '8 bars with blanks RDK (90) Fast',
	params.type = 'bar';
	params.ringDeg = params.radius./4; 
    params.insertBlanks.freq = params.numCycles.*4;
	params.seqDirection = 0;
    params.insertBlanks.do = 1;
    params.numSubRings = (params.radius-params.innerRad)/(params.radius);
    params.RDK.orientationInDeg=90;
    params.RDK.dotSpeed=8;
case '8 bars with blanks RDK (90) Medium',
	params.type = 'bar';
	params.ringDeg = params.radius./4; 
    params.insertBlanks.freq = params.numCycles.*4;
	params.seqDirection = 0;
    params.insertBlanks.do = 1;
    params.numSubRings = (params.radius-params.innerRad)/(params.radius);
    params.RDK.orientationInDeg=90;
    params.RDK.dotSpeed=4;
case '8 bars with blanks RDK (90) Slow',
	params.type = 'bar';
	params.ringDeg = params.radius./4; 
    params.insertBlanks.freq = params.numCycles.*4;
	params.seqDirection = 0;
    params.insertBlanks.do = 1;
    params.numSubRings = (params.radius-params.innerRad)/(params.radius);
    params.RDK.orientationInDeg=90;
    params.RDK.dotSpeed=2;
    
case '8 bars with blanks RDK (0) Fast',
	params.type = 'bar';
	params.ringDeg = params.radius./4; 
    params.insertBlanks.freq = params.numCycles.*4;
	params.seqDirection = 0;
    params.insertBlanks.do = 1;
    params.numSubRings = (params.radius-params.innerRad)/(params.radius);
    params.RDK.orientationInDeg=0;
    params.RDK.dotSpeed=8;
case '8 bars with blanks RDK (0) Medium',
	params.type = 'bar';
	params.ringDeg = params.radius./4; 
    params.insertBlanks.freq = params.numCycles.*4;
	params.seqDirection = 0;
    params.insertBlanks.do = 1;
    params.numSubRings = (params.radius-params.innerRad)/(params.radius);
    params.RDK.orientationInDeg=0;
    params.RDK.dotSpeed=4;
case '8 bars with blanks RDK (0) Slow',
	params.type = 'bar';
	params.ringDeg = params.radius./4; 
    params.insertBlanks.freq = params.numCycles.*4;
	params.seqDirection = 0;
    params.insertBlanks.do = 1;
    params.numSubRings = (params.radius-params.innerRad)/(params.radius);
    params.RDK.orientationInDeg=0;
    params.RDK.dotSpeed=1;
    
case '8 bars with blanks (lr ONLY random)',
	params.type = 'bar';
	params.ringDeg = params.radius./4; 
	params.seqDirection = 0;
    params.insertBlanks.do = 1;
    params.insertBlanks.freq = params.numCycles;
    params.numSubRings = (params.radius-params.innerRad)/(params.radius);
 case '8 bars with blanks (lr ONLY wrap)',
	params.type = 'bar';
	params.ringDeg = params.radius./4; 
	params.seqDirection = 0;
    params.insertBlanks.do = 1;
    params.insertBlanks.freq = params.numCycles;
    params.numSubRings = (params.radius-params.innerRad)/(params.radius);
case '8 bars with blanks (lr ONLY unwrap)',
	params.type = 'bar';
	params.ringDeg = params.radius./4; 
	params.seqDirection = 0;
    params.insertBlanks.do = 1;
    params.insertBlanks.freq = params.numCycles;
    params.numSubRings = (params.radius-params.innerRad)/(params.radius);
    
case 'images.circleimage'
    params.type = 'center-surround';
	params.centerInnerRad = 0;
	params.centerOuterRad = params.radius;
	params.surroundInnerRad = 0;
	params.surroundOuterRad = 0;
    params.insertBlanks.do = 1;
    params.insertBlanks.freq = params.numCycles;
    
    
    params.numImages = 2;
	params.duration = params.period/params.numImages;
    params.numSubRings = (params.radius)/(2*params.subRingDeg);
    params.contrast    = 0.5;%[1 0.1]; % red blue
    params.startScan   = 0;
    
case '8 bars with blanks Cow (0) Slow',
	params.type = 'bar';
	params.ringDeg = params.radius./4; 
	params.seqDirection = 0;
    params.insertBlanks.do = 1;
    params.numSubRings = (params.radius-params.innerRad)/(params.radius);
    params.stimSpeed=1;
    params.stimDirection=0;
    params.stimFlicker=0;
    params.temporal.motionSteps = 8;
    
case '8 bars with blanks Cow (0) Medium',
	params.type = 'bar';
	params.ringDeg = params.radius./4; 
	params.seqDirection = 0;
    params.insertBlanks.do = 1;
    params.numSubRings = (params.radius-params.innerRad)/(params.radius);
    params.stimSpeed=4;
    params.stimDirection=0;
    params.stimFlicker=0;
    params.temporal.motionSteps = 8;

case '8 bars with blanks Cow (0) Fast',
	params.type = 'bar';
	params.ringDeg = params.radius./4; 
	params.seqDirection = 0;
    params.insertBlanks.do = 1;
    params.numSubRings = (params.radius-params.innerRad)/(params.radius);
    params.stimSpeed=8;
    params.stimDirection=0;
    params.stimFlicker=0;
    params.temporal.motionSteps = 8;
    
case '8 bars with blanks Cow (90) Slow',
	params.type = 'bar';
	params.ringDeg = params.radius./4; 
	params.seqDirection = 0;
    params.insertBlanks.do = 1;
    params.numSubRings = (params.radius-params.innerRad)/(params.radius);
    params.stimSpeed=1;
    params.stimDirection=90;
    params.stimFlicker=0;
    params.temporal.motionSteps = 8;
    
case '8 bars with blanks Cow (90) Medium',
	params.type = 'bar';
	params.ringDeg = params.radius./4; 
	params.seqDirection = 0;
    params.insertBlanks.do = 1;
    params.numSubRings = (params.radius-params.innerRad)/(params.radius);
    params.stimSpeed=4;
    params.stimDirection=90;
    params.stimFlicker=0;
    params.temporal.motionSteps = 8;
    
case '8 bars with blanks Cow (90) Fast',
	params.type = 'bar';
	params.ringDeg = params.radius./4; 
	params.seqDirection = 0;
    params.insertBlanks.do = 1;
    params.numSubRings = (params.radius-params.innerRad)/(params.radius);
    params.stimSpeed=8;
    params.stimDirection=90;
    params.stimFlicker=0;
    params.temporal.motionSteps = 8;
    
case '8 bars with blanks Cow (Flicker) Slow',
	params.type = 'bar';
	params.ringDeg = params.radius./4; 
	params.seqDirection = 0;
    params.insertBlanks.do = 1;
    params.numSubRings = (params.radius-params.innerRad)/(params.radius);
    params.stimSpeed=0;
    params.stimDirection=0;
    params.stimFlicker=1/1.5; %per second (Hz)
    params.temporal.motionSteps = 8;
        
case '8 bars with blanks Cow (Flicker) Fast',
	params.type = 'bar';
	params.ringDeg = params.radius./4; 
	params.seqDirection = 0;
    params.insertBlanks.do = 1;
    params.numSubRings = (params.radius-params.innerRad)/(params.radius);
    params.stimSpeed=0;
    params.stimDirection=0;
    params.stimFlicker=8/1.5; %per second (Hz)
    params.temporal.motionSteps = 8;
    
case 'Cow Full Fast'
    params.type = 'bar';
	params.ringDeg = params.radius./4; 
	params.seqDirection = 0;
    params.insertBlanks.do = 1;
    params.numSubRings = (params.radius-params.innerRad)/(params.radius);
    params.stimSpeed=8;
    params.stimDirection=0;
    
case 'Cow Full Medium'
    params.type = 'bar';
	params.ringDeg = params.radius./4; 
	params.seqDirection = 0;
    params.insertBlanks.do = 1;
    params.numSubRings = (params.radius-params.innerRad)/(params.radius);
    params.stimSpeed=4;
    params.stimDirection=0;
    
case 'Cow Full Slow'
    params.type = 'bar';
	params.ringDeg = params.radius./4; 
	params.seqDirection = 0;
    params.insertBlanks.do = 1;
    params.numSubRings = (params.radius-params.innerRad)/(params.radius);
    params.stimSpeed=1;
    params.stimDirection=0;
    
case 'Cow Full Still'
    params.type = 'bar';
	params.ringDeg = params.radius./4; 
	params.seqDirection = 0;
    params.insertBlanks.do = 1;
    params.numSubRings = (params.radius-params.innerRad)/(params.radius);
    params.stimSpeed=0;
    params.stimDirection=0;
    
case '8 bars with blanks Checks Counter (90) 2.5d/s'
    params.type = 'bar';
	params.ringDeg = 2;
    params.temporal.frequency = 2.5; %Hz
    params.temporal.motionSteps = 12;
    params.numSubRings = 2;  %effectively spatial frequency in cycles/deg
    params.insertBlanks.do = 1;
    
case '8 bars with blanks Checks Counter (90) 5d/s', 
    params.type = 'bar';
	params.ringDeg = 2;
    params.temporal.frequency = 5; %Hz
    params.temporal.motionSteps =6;
    params.numSubRings = 2;   
    params.insertBlanks.do = 1;
    
case '8 bars with blanks Checks Together (90) 2.5d/s'
    params.type = 'bar';
	params.ringDeg = 2;
    params.temporal.frequency = 2.5; %Hz
    params.temporal.motionSteps =12;
    params.numSubRings = 2;
    params.insertBlanks.do = 1;
    
case '8 bars with blanks Checks Together (90) 5d/s'
    params.type = 'bar';
	params.ringDeg = 2;
    params.temporal.frequency = 5; %Hz
    params.temporal.motionSteps =6;
    params.numSubRings = 2;  
    params.insertBlanks.do = 1;

case '8 bars with blanks Sine (90) 1.5d/s'
    params.type = 'bar';
	params.ringDeg = 2;
    params.temporal.frequency = 1.5; %Hz
    params.temporal.motionSteps =20;
    params.numSubRings = 2;
    params.insertBlanks.do = 1; 
    params.contrast=1;
    
case '8 bars with blanks Sine (90) 2.5d/s'
    params.type = 'bar';
	params.ringDeg = 2;
    params.temporal.frequency = 2.5; %Hz
    params.temporal.motionSteps =12;
    params.numSubRings = 2;
    params.insertBlanks.do = 1;  
    params.contrast=1;  

case '8 bars with blanks Sine (90) 3.75d/s'
    params.type = 'bar';
	params.ringDeg = 2;
    params.temporal.frequency = 3.75; %Hz
    params.temporal.motionSteps =8;
    params.numSubRings = 2;
    params.insertBlanks.do = 1; 
    params.contrast=1;      
    
case '8 bars with blanks Sine (90) 5d/s'
    params.type = 'bar';
	params.ringDeg = 2;
    params.temporal.frequency = 5; %Hz
    params.temporal.motionSteps =6;
    params.numSubRings = 2;  
    params.insertBlanks.do = 1;
    params.contrast=1;    
    
case '8 bars with blanks Sine (90) 7.5d/s'
    params.type = 'bar';
	params.ringDeg = 2;
    params.temporal.frequency = 7.5; %Hz
    params.temporal.motionSteps =4;
    params.numSubRings = 2;  
    params.insertBlanks.do = 1;
    params.contrast=1;
    
case '8 bars with blanks Sine (0) 2.5d/s'
    params.type = 'bar';
	params.ringDeg = 2;
    params.temporal.frequency = 2.5; %Hz
    params.temporal.motionSteps =12;
    params.numSubRings = 2;
    params.insertBlanks.do = 1;
    params.contrast=1;
    
case '8 bars with blanks Sine (0) 5d/s'
    params.type = 'bar';
	params.ringDeg = 2;
    params.temporal.frequency = 5; %Hz
    params.temporal.motionSteps =6;
    params.numSubRings = 2;  
    params.insertBlanks.do = 1;
    params.contrast=1;
    
case '8 bars with blanks Sine (90) 1.5d/s 20%'
    params.type = 'bar';
	params.ringDeg = 2;
    params.temporal.frequency = 1.5; %Hz
    params.temporal.motionSteps =20;
    params.numSubRings = 2;
    params.insertBlanks.do = 1; 
    params.contrast=0.1;
    
case '8 bars with blanks Sine (90) 2.5d/s 20%'
    params.type = 'bar';
	params.ringDeg = 2;
    params.temporal.frequency = 2.5; %Hz
    params.temporal.motionSteps =12;
    params.numSubRings = 2;
    params.insertBlanks.do = 1;
    params.contrast=0.1;

case '8 bars with blanks Sine (90) 3.75d/s 20%'
    params.type = 'bar';
	params.ringDeg = 2;
    params.temporal.frequency = 3.75; %Hz
    params.temporal.motionSteps =8;
    params.numSubRings = 2;
    params.insertBlanks.do = 1;    
    params.contrast=0.1;
    
case '8 bars with blanks Sine (90) 5d/s 20%'
    params.type = 'bar';
	params.ringDeg = 2;
    params.temporal.frequency = 5; %Hz
    params.temporal.motionSteps =6;
    params.numSubRings = 2;  
    params.insertBlanks.do = 1;
    params.contrast=0.1;
    
case '8 bars with blanks Sine (90) 7.5d/s 20%'
    params.type = 'bar';
	params.ringDeg = 2;
    params.temporal.frequency = 7.5; %Hz
    params.temporal.motionSteps =4;
    params.numSubRings = 2;  
    params.insertBlanks.do = 1;
    params.contrast=0.1;
    
    
case 'Sine motion psychophysics(90)'
    params.type = 'bar';
	params.ringDeg = 2;
    params.temporal.frequency =[1.5 2.5 3.75 5 7.5 0.75 1.25 1.875]; %Hz
    params.temporal.motionSteps =[20 12   8  6 4   40   24   16];
    params.numSubRings = 2;  
    params.contrast=1;    
    
case 'Numbers and Dots Unscaled'
    params.type = 'bar';
	params.ringDeg = params.radius./4; 
	params.seqDirection = 0;
    params.insertBlanks.do = 1;
    params.numSubRings = (params.radius-params.innerRad)/(params.radius);
    params.stimSpeed=0;
    params.stimDirection=0; 
    params.whichStim='dotsandnumbers'; 
    params.equalArea = 0;
    params.reverseDirection=false;
    
case 'Numbers and Dots Scaled'
    params.type = 'bar';
	params.ringDeg = params.radius./4; 
	params.seqDirection = 0;
    params.insertBlanks.do = 1;
    params.numSubRings = (params.radius-params.innerRad)/(params.radius);
    params.stimSpeed=0;
    params.stimDirection=0;  
    params.whichStim='dotsandnumbers'; 
    params.equalArea = 1;
    params.reverseDirection=false;
    
case 'Numbers Only'
    params.type = 'bar';
	params.ringDeg = params.radius./4; 
	params.seqDirection = 0;
    params.insertBlanks.do = 1;
    params.numSubRings = (params.radius-params.innerRad)/(params.radius);
    params.stimSpeed=0;
    params.stimDirection=0; 
    params.whichStim='numbers'; 
    params.equalArea = 0;
    params.reverseDirection=false;
    
case 'Dots Unscaled'
    params.type = 'bar';
	params.ringDeg = params.radius./4; 
	params.seqDirection = 0;
    params.insertBlanks.do = 1;
    params.numSubRings = (params.radius-params.innerRad)/(params.radius);
    params.stimSpeed=0;
    params.stimDirection=0;  
    params.whichStim='dots'; 
    params.equalArea = 0;
    params.reverseDirection=false;
    
case 'Dots Scaled'
    params.type = 'bar';
	params.ringDeg = params.radius./4; 
	params.seqDirection = 0;
    params.insertBlanks.do = 1;
    params.numSubRings = (params.radius-params.innerRad)/(params.radius);
    params.stimSpeed=0;
    params.stimDirection=0;  
    params.whichStim='dots'; 
    params.equalArea = 1;
    params.reverseDirection=false;
    
case 'Dots Scaled Reverse'
    params.type = 'bar';
	params.ringDeg = params.radius./4; 
	params.seqDirection = 0;
    params.insertBlanks.do = 1;
    params.numSubRings = (params.radius-params.innerRad)/(params.radius);
    params.stimSpeed=0;
    params.stimDirection=0;  
    params.whichStim='dots'; 
    params.equalArea = 1;
    params.reverseDirection=true;
    
case 'Dots Small'
    params.type = 'bar';
	params.ringDeg = params.radius./4; 
	params.seqDirection = 0;
    params.insertBlanks.do = 1;
    params.numSubRings = (params.radius-params.innerRad)/(params.radius);
    params.stimSpeed=0;
    params.stimDirection=0;  
    params.whichStim='dots'; 
    params.equalArea = 1;
    params.reverseDirection=false;
    
case 'Dots Scaled pRF'
    params.type = 'bar';
	params.ringDeg = params.radius./4; 
	params.seqDirection = 0;
    params.insertBlanks.do = 1;
    params.numSubRings = (params.radius-params.innerRad)/(params.radius);
    params.stimSpeed=0;
    params.stimDirection=0;  
    params.whichStim='dots'; 
    params.equalArea = 1;
    params.reverseDirection=false;
    %Initial pilot
    %params.dotOrder=[1 0 2 0 3 0 4 0 5 0 6 0 7 0 0 0 0 0 0 0 0 0 0 7 0 6 0 5 0 4 0 3 0 2 0 1 0 0 0 0 0 0 0 0 0 0]; 
    %Second pilot, no blanks between numbers, less frequent presentations to avoid
    %adaptation
    params.dotOrder=[1 1 2 2 3 3 4 4 5 5 6 6 7 7 0 0 0 0 0 0 0 0 0 7 7 6 6 5 5 4 4 3 3 2 2 1 1 0 0 0 0 0 0 0 0 0]; 

case 'Dots Scaled pRF full blanks'
    params.type = 'bar';
	params.ringDeg = params.radius./4; 
	params.seqDirection = 0;
    params.insertBlanks.do = 1;
    params.numSubRings = (params.radius-params.innerRad)/(params.radius);
    params.stimSpeed=0;
    params.stimDirection=0;  
    params.whichStim='dots'; 
    params.equalArea = 1;
    params.reverseDirection=false;
    %Initial pilot
    %params.dotOrder=[1 0 2 0 3 0 4 0 5 0 6 0 7 0 0 0 0 0 0 0 0 0 0 7 0 6 0 5 0 4 0 3 0 2 0 1 0 0 0 0 0 0 0 0 0 0]; 
    %Second pilot, no blanks, less frequent presentations to avoid
    %adaptation
    params.dotOrder=[1 1 2 2 3 3 4 4 5 5 6 6 7 7 20 20 20 20 20 20 20 20 20 7 7 6 6 5 5 4 4 3 3 2 2 1 1 20 20 20 20 20 20 20 20 20]; 

    case 'Dots Scaled pRF short'
    params.type = 'bar';
	params.ringDeg = params.radius./4; 
	params.seqDirection = 0;
    params.insertBlanks.do = 1;
    params.numSubRings = (params.radius-params.innerRad)/(params.radius);
    params.stimSpeed=0;
    params.stimDirection=0;  
    params.whichStim='dots'; 
    params.equalArea = 1;
    params.reverseDirection=false;
    %Initial pilot
    %params.dotOrder=[1 0 2 0 3 0 4 0 5 0 6 0 7 0 0 0 0 0 0 0 0 0 0 7 0 6 0 5 0 4 0 3 0 2 0 1 0 0 0 0 0 0 0 0 0 0]; 
    %Second pilot, no blanks between numbers, less frequent presentations to avoid
    %adaptation
    params.dotOrder=[1 1 2 2 3 3 4 4 5 5 6 6 7 7 0 0 0 0 0 0 0 0 0 0 7 7 6 6 5 5 4 4 3 3 2 2 1 1 0 0 0 0 0 0 0 0 0 0]; 

case 'Dots Scaled pRF full blanks short'
    params.type = 'bar';
	params.ringDeg = params.radius./4; 
	params.seqDirection = 0;
    params.insertBlanks.do = 1;
    params.numSubRings = (params.radius-params.innerRad)/(params.radius);
    params.stimSpeed=0;
    params.stimDirection=0;  
    params.whichStim='dots'; 
    params.equalArea = 1;
    params.reverseDirection=false;
    %Initial pilot
    %params.dotOrder=[1 0 2 0 3 0 4 0 5 0 6 0 7 0 0 0 0 0 0 0 0 0 0 7 0 6 0 5 0 4 0 3 0 2 0 1 0 0 0 0 0 0 0 0 0 0]; 
    %Second pilot, no blanks, less frequent presentations to avoid
    %adaptation
    params.dotOrder=[1 1 2 2 3 3 4 4 5 5 6 6 7 7 20 20 20 20 20 20 20 20 20 20 7 7 6 6 5 5 4 4 3 3 2 2 1 1 20 20 20 20 20 20 20 20 20 20]; 
    
case 'Dots Area pRF full blanks TR=1.5, nTRs=3'
    params.type = 'bar';
	params.ringDeg = params.radius./4; 
	params.seqDirection = 0;
    params.insertBlanks.do = 1;
    params.numSubRings = (params.radius-params.innerRad)/(params.radius);
    params.stimSpeed=0;
    params.stimDirection=0;  
    params.whichStim='dots'; 
    params.equalArea = 1;
    params.reverseDirection=false;
    %Initial pilot
    %params.dotOrder=[1 0 2 0 3 0 4 0 5 0 6 0 7 0 0 0 0 0 0 0 0 0 0 7 0 6 0 5 0 4 0 3 0 2 0 1 0 0 0 0 0 0 0 0 0 0]; 
    %Second pilot, no blanks, less frequent presentations to avoid
    %adaptation
    params.dotOrder=[1 1 1 2 2 2 3 3 3 4 4 4 5 5 5 6 6 6 7 7 7 20 20 20 20 20 20 20 20 20 7 7 7 6 6 6 5 5 5 4 4 4 3 3 3 2 2 2 1 1 1 20 20 20 20 20 20 20 20 20]; 
    %params.dotOrder=[1 1 1 2 2 2 3 3 3 4 4 4 5 5 5 6 6 6 7 7 7 0 0 0 0 0 0 0 0 0 7 7 7 6 6 6 5 5 5 4 4 4 3 3 3 2 2 2 1 1 1 0 0 0 0 0 0 0 0 0]; 
    
case 'Dots Size pRF full blanks TR=1.5, nTRs=3'
    params.type = 'bar';
	params.ringDeg = params.radius./4; 
	params.seqDirection = 0;
    params.insertBlanks.do = 1;
    params.numSubRings = (params.radius-params.innerRad)/(params.radius);
    params.stimSpeed=0;
    params.stimDirection=0;  
    params.whichStim='dots'; 
    params.equalArea = 0;
    params.reverseDirection=false;
    %Initial pilot
    %params.dotOrder=[1 0 2 0 3 0 4 0 5 0 6 0 7 0 0 0 0 0 0 0 0 0 0 7 0 6 0 5 0 4 0 3 0 2 0 1 0 0 0 0 0 0 0 0 0 0]; 
    %Second pilot, no blanks, less frequent presentations to avoid
    %adaptation
    params.dotOrder=[1 1 1 2 2 2 3 3 3 4 4 4 5 5 5 6 6 6 7 7 7 20 20 20 20 20 20 20 20 20 7 7 7 6 6 6 5 5 5 4 4 4 3 3 3 2 2 2 1 1 1 20 20 20 20 20 20 20 20 20]; 
    %params.dotOrder=[1 1 1 2 2 2 3 3 3 4 4 4 5 5 5 6 6 6 7 7 7 0 0 0 0 0 0
    %0 0 0 7 7 7 6 6 6 5 5 5 4 4 4 3 3 3 2 2 2 1 1 1 0 0 0 0 0 0 0 0 0]; 
    
case 'Dots Shapes pRF full blanks TR=1.5, nTRs=3'
    params.type = 'bar';
	params.ringDeg = params.radius./4; 
	params.seqDirection = 0;
    params.insertBlanks.do = 1;
    params.numSubRings = (params.radius-params.innerRad)/(params.radius);
    params.stimSpeed=0;
    params.stimDirection=0;  
    params.whichStim='dots'; 
    params.equalArea = 0;
    params.reverseDirection=false;
    %Initial pilot
    %params.dotOrder=[1 0 2 0 3 0 4 0 5 0 6 0 7 0 0 0 0 0 0 0 0 0 0 7 0 6 0 5 0 4 0 3 0 2 0 1 0 0 0 0 0 0 0 0 0 0]; 
    %Second pilot, no blanks, less frequent presentations to avoid
    %adaptation
    params.dotOrder=[1 1 1 2 2 2 3 3 3 4 4 4 5 5 5 6 6 6 7 7 7 20 20 20 20 20 20 20 20 20 7 7 7 6 6 6 5 5 5 4 4 4 3 3 3 2 2 2 1 1 1 20 20 20 20 20 20 20 20 20]; 


case 'Dots Circumference pRF full blanks TR=1.5, nTRs=3'
    params.type = 'bar';
	params.ringDeg = params.radius./4; 
	params.seqDirection = 0;
    params.insertBlanks.do = 1;
    params.numSubRings = (params.radius-params.innerRad)/(params.radius);
    params.stimSpeed=0;
    params.stimDirection=0;  
    params.whichStim='dots'; 
    params.equalArea = 2;
    params.reverseDirection=false;
    %Initial pilot
    %params.dotOrder=[1 0 2 0 3 0 4 0 5 0 6 0 7 0 0 0 0 0 0 0 0 0 0 7 0 6 0 5 0 4 0 3 0 2 0 1 0 0 0 0 0 0 0 0 0 0]; 
    %Second pilot, no blanks, less frequent presentations to avoid
    %adaptation
    params.dotOrder=[1 1 1 2 2 2 3 3 3 4 4 4 5 5 5 6 6 6 7 7 7 20 20 20 20 20 20 20 20 20 7 7 7 6 6 6 5 5 5 4 4 4 3 3 3 2 2 2 1 1 1 20 20 20 20 20 20 20 20 20]; 
    %params.dotOrder=[1 1 1 2 2 2 3 3 3 4 4 4 5 5 5 6 6 6 7 7 7 0 0 0 0 0 0
    %0 0 0 7 7 7 6 6 6 5 5 5 4 4 4 3 3 3 2 2 2 1 1 1 0 0 0 0 0 0 0 0 0];
    
    
case 'Dots Dense pRF full blanks TR=1.5, nTRs=3'
    params.type = 'bar';
	params.ringDeg = params.radius./4; 
	params.seqDirection = 0;
    params.insertBlanks.do = 1;
    params.numSubRings = (params.radius-params.innerRad)/(params.radius);
    params.stimSpeed=0;
    params.stimDirection=0;  
    params.whichStim='dots'; 
    params.equalArea = 3;
    params.reverseDirection=false;
    %Initial pilot
    %params.dotOrder=[1 0 2 0 3 0 4 0 5 0 6 0 7 0 0 0 0 0 0 0 0 0 0 7 0 6 0 5 0 4 0 3 0 2 0 1 0 0 0 0 0 0 0 0 0 0]; 
    %Second pilot, no blanks, less frequent presentations to avoid
    %adaptation
    params.dotOrder=[1 1 1 2 2 2 3 3 3 4 4 4 5 5 5 6 6 6 7 7 7 20 20 20 20 20 20 20 20 20 7 7 7 6 6 6 5 5 5 4 4 4 3 3 3 2 2 2 1 1 1 20 20 20 20 20 20 20 20 20]; 
    %params.dotOrder=[1 1 1 2 2 2 3 3 3 4 4 4 5 5 5 6 6 6 7 7 7 0 0 0 0 0 0 0 0 0 7 7 7 6 6 6 5 5 5 4 4 4 3 3 3 2 2 2 1 1 1 0 0 0 0 0 0 0 0 0];     

case 'One Dot Sizes pRF full blanks TR=1.5, nTRs=3'
params.type = 'bar';
	params.ringDeg = params.radius./4; 
	params.seqDirection = 0;
    params.insertBlanks.do = 1;
    params.numSubRings = (params.radius-params.innerRad)/(params.radius);
    params.stimSpeed=0;
    params.stimDirection=0;  
    params.whichStim='dots'; 
    params.equalArea = 4;
    params.reverseDirection=false;
    %Initial pilot
    %params.dotOrder=[1 0 2 0 3 0 4 0 5 0 6 0 7 0 0 0 0 0 0 0 0 0 0 7 0 6 0 5 0 4 0 3 0 2 0 1 0 0 0 0 0 0 0 0 0 0]; 
    %Second pilot, no blanks, less frequent presentations to avoid
    %adaptation
    %params.dotOrder=[1 1 1 2 2 2 3 3 3 4 4 4 5 5 5 6 6 6 7 7 7 20 20 20 20 20 20 20 20 20 7 7 7 6 6 6 5 5 5 4 4 4 3 3 3 2 2 2 1 1 1 20 20 20 20 20 20 20 20 20]; 
    %params.dotOrder=[logspace(log10(3), log10(63), 21) 0 0 0 0 0 0 0 0 0 flipLR(logspace(log10(3), log10(63), 21)) 0 0 0 0 0 0 0 0 0];
    params.dotOrder=[linspace(3, 63, 21) 0 0 0 0 0 0 0 0 0 flipLR(linspace(3, 63, 21)) 0 0 0 0 0 0 0 0 0];
    %params.dotOrder=[1 1 1 2 2 2 3 3 3 4 4 4 5 5 5 6 6 6 7 7 7 0 0 0 0 0 0 0 0 0 7 7 7 6 6 6 5 5 5 4 4 4 3 3 3 2 2 2 1 1 1 0 0 0 0 0 0 0 0 0];    
 case 'Dots Area pRF full blanks TR=2.1, nTRs=2'
    params.type = 'bar';
	params.ringDeg = params.radius./4; 
	params.seqDirection = 0;
    params.insertBlanks.do = 1;
    params.numSubRings = (params.radius-params.innerRad)/(params.radius);
    params.stimSpeed=0;
    params.stimDirection=0;  
    params.whichStim='dots'; 
    params.equalArea = 1;
    params.reverseDirection=false;
    params.dotOrder=[1 1 2 2 3 3 4 4 5 5 6 6 7 7 20 20 20 20 20 20 20 20 7 7 6 6 5 5 4 4 3 3 2 2 1 1  20 20 20 20 20 20 20 20];
    
 case 'Dots Size pRF full blanks TR=2.1, nTRs=2'
    params.type = 'bar';
	params.ringDeg = params.radius./4; 
	params.seqDirection = 0;
    params.insertBlanks.do = 1;
    params.numSubRings = (params.radius-params.innerRad)/(params.radius);
    params.stimSpeed=0;
    params.stimDirection=0;  
    params.whichStim='dots'; 
    params.equalArea = 0;
    params.reverseDirection=false;
    params.dotOrder=[1 1 2 2 3 3 4 4 5 5 6 6 7 7 20 20 20 20 20 20 20 20 7 7 6 6 5 5 4 4 3 3 2 2 1 1  20 20 20 20 20 20 20 20]; 

case 'Dots Circumference pRF full blanks TR=2.1, nTRs=2'
    params.type = 'bar';
	params.ringDeg = params.radius./4; 
	params.seqDirection = 0;
    params.insertBlanks.do = 1;
    params.numSubRings = (params.radius-params.innerRad)/(params.radius);
    params.stimSpeed=0;
    params.stimDirection=0;  
    params.whichStim='dots'; 
    params.equalArea = 2;
    params.reverseDirection=false;
    params.dotOrder=[1 1 2 2 3 3 4 4 5 5 6 6 7 7 20 20 20 20 20 20 20 20 7 7 6 6 5 5 4 4 3 3 2 2 1 1  20 20 20 20 20 20 20 20];
    
 case 'Dots Dense pRF full blanks TR=2.1, nTRs=2'
    params.type = 'bar';
	params.ringDeg = params.radius./4; 
	params.seqDirection = 0;
    params.insertBlanks.do = 1;
    params.numSubRings = (params.radius-params.innerRad)/(params.radius);
    params.stimSpeed=0;
    params.stimDirection=0;  
    params.whichStim='dots'; 
    params.equalArea = 3;
    params.reverseDirection=false;
    params.dotOrder=[1 1 2 2 3 3 4 4 5 5 6 6 7 7 20 20 20 20 20 20 20 20 7 7 6 6 5 5 4 4 3 3 2 2 1 1  20 20 20 20 20 20 20 20]; 

 case 'Dots Shapes pRF full blanks TR=2.1, nTRs=2'
    params.type = 'bar';
	params.ringDeg = params.radius./4; 
	params.seqDirection = 0;
    params.insertBlanks.do = 1;
    params.numSubRings = (params.radius-params.innerRad)/(params.radius);
    params.stimSpeed=0;
    params.stimDirection=0;  
    params.whichStim='dots'; 
    params.equalArea = 0;
    params.reverseDirection=false;
    params.dotOrder=[1 1 2 2 3 3 4 4 5 5 6 6 7 7 20 20 20 20 20 20 20 20 7 7 6 6 5 5 4 4 3 3 2 2 1 1  20 20 20 20 20 20 20 20]; 

  case 'Dots Area pRF full blanks 4degree high numbers TR=1.95, nTRs=2'
    params.type = 'bar';
	params.ringDeg = params.radius./4; 
	params.seqDirection = 0;
    params.insertBlanks.do = 1;
    params.numSubRings = (params.radius-params.innerRad)/(params.radius);
    params.stimSpeed=0;
    params.stimDirection=0;  
    params.whichStim='dots'; 
    params.equalArea = 1;
    params.reverseDirection=false;
    % Sets order and number of dots
    params.dotOrder = [1 1 2 2 4 4 8 8 16 16 32 32 64 64 512 512 512 512 512 512 512 512 64 64 32 32 16 16 8 8 4 4 2 2 1 1 512 512 512 512 512 512 512 512];
    %params.dotOrder = repmat(4,1,15);
    params.dotSize = 35;
    
  case 'Dots Area pRF full blanks 4degree low numbers TR=1.95, nTRs=2'
    params.type = 'bar';
	params.ringDeg = params.radius./4; 
	params.seqDirection = 0;
    params.insertBlanks.do = 1;
    params.numSubRings = (params.radius-params.innerRad)/(params.radius);
    params.stimSpeed=0;
    params.stimDirection=0;  
    params.whichStim='dots'; 
    params.equalArea = 1;
    params.reverseDirection=false;
    % Sets order and number of dots
    params.dotOrder=[1 1 2 2 3 3 4 4 5 5 6 6 7 7 20 20 20 20 20 20 20 20 7 7 6 6 5 5 4 4 3 3 2 2 1 1  20 20 20 20 20 20 20 20]; 
    params.dotSize = 35;  

    
case 'Number Symbols pRF full blanks TR=2.1, nTRs=2'
    params.type = 'bar';
	params.ringDeg = params.radius./4; 
	params.seqDirection = 0;
    params.insertBlanks.do = 1;
    params.numSubRings = (params.radius-params.innerRad)/(params.radius);
    params.stimSpeed=0;
    params.stimDirection=0;  
    params.whichStim='dots'; 
    params.equalArea = 0;
    params.reverseDirection=false;
    %Initial pilot
    %params.dotOrder=[1 0 2 0 3 0 4 0 5 0 6 0 7 0 0 0 0 0 0 0 0 0 0 7 0 6 0 5 0 4 0 3 0 2 0 1 0 0 0 0 0 0 0 0 0 0]; 
    %Second pilot, no blanks, less frequent presentations to avoid
    %adaptation
    params.dotOrder=[1 1 2 2 3 3 4 4 5 5 6 6 7 7 8 8 9 9 20 20 20 20 20 20 20 20 20 20 9 9 8 8 7 7 6 6 5 5 4 4 3 3 2 2 1 1 20 20 20 20 20 20 20 20 20 20]; 

case {'One Dot Sizes pRF full blanks TR=2.1, nTRs=2', 'One Dot Sizes Constant Step pRF full blanks TR=2.1, nTRs=2', 'One Line Size Random Orientation pRF full blanks TR=2.1, nTRs=2', 'One Dot Luminance pRF full blanks TR=2.1, nTRs=2'}
params.type = 'bar';
	params.ringDeg = params.radius./4; 
	params.seqDirection = 0;
    params.insertBlanks.do = 1;
    params.numSubRings = (params.radius-params.innerRad)/(params.radius);
    params.stimSpeed=0;
    params.stimDirection=0;  
    params.whichStim='dots'; 
    params.equalArea = 4;
    params.reverseDirection=false;
    %Initial pilot
    %params.dotOrder=[1 0 2 0 3 0 4 0 5 0 6 0 7 0 0 0 0 0 0 0 0 0 0 7 0 6 0 5 0 4 0 3 0 2 0 1 0 0 0 0 0 0 0 0 0 0]; 
    %Second pilot, no blanks, less frequent presentations to avoid
    %adaptation
    %params.dotOrder=[1 1 1 2 2 2 3 3 3 4 4 4 5 5 5 6 6 6 7 7 7 20 20 20 20 20 20 20 20 20 7 7 7 6 6 6 5 5 5 4 4 4 3 3 3 2 2 2 1 1 1 20 20 20 20 20 20 20 20 20]; 
    %params.dotOrder=[logspace(log10(3), log10(63), 21) 0 0 0 0 0 0 0 0 0 flipLR(logspace(log10(3), log10(63), 21)) 0 0 0 0 0 0 0 0 0];
    %params.dotOrder=[linspace(3, 68, 14) 180 180 180 180 180 180 180 180 flipLR(linspace(3, 68, 14)) 180 180 180 180 180 180 180 180];
    params.dotOrder=[linspace(3, 68, 14) 180 180 180 180 180 180 180 180 flipLR(linspace(3, 68, 14)) 180 180 180 180 180 180 180 180];
    %params.dotOrder=[1 1 1 2 2 2 3 3 3 4 4 4 5 5 5 6 6 6 7 7 7 0 0 0 0 0 0
    %0 0 0 7 7 7 6 6 6 5 5 5 4 4 4 3 3 3 2 2 2 1 1 1 0 0 0 0 0 0 0 0 0]; 

case {'One Dot Double Sizes pRF full blanks TR=2.1, nTRs=2'}
    params.type = 'bar';
	params.ringDeg = params.radius./4; 
	params.seqDirection = 0;
    params.insertBlanks.do = 1;
    params.numSubRings = (params.radius-params.innerRad)/(params.radius);
    params.stimSpeed=0;
    params.stimDirection=0;  
    params.whichStim='dots'; 
    params.equalArea = 4;
    params.reverseDirection=false;
    %Initial pilot
    %params.dotOrder=[1 0 2 0 3 0 4 0 5 0 6 0 7 0 0 0 0 0 0 0 0 0 0 7 0 6 0 5 0 4 0 3 0 2 0 1 0 0 0 0 0 0 0 0 0 0]; 
    %Second pilot, no blanks, less frequent presentations to avoid
    %adaptation
    %params.dotOrder=[1 1 1 2 2 2 3 3 3 4 4 4 5 5 5 6 6 6 7 7 7 20 20 20 20 20 20 20 20 20 7 7 7 6 6 6 5 5 5 4 4 4 3 3 3 2 2 2 1 1 1 20 20 20 20 20 20 20 20 20]; 
    %params.dotOrder=[logspace(log10(3), log10(63), 21) 0 0 0 0 0 0 0 0 0 flipLR(logspace(log10(3), log10(63), 21)) 0 0 0 0 0 0 0 0 0];
    %params.dotOrder=[linspace(3, 68, 14) 180 180 180 180 180 180 180 180 flipLR(linspace(3, 68, 14)) 180 180 180 180 180 180 180 180];
    params.dotOrder=[linspace(3, 68, 14) 180 180 180 180 180 180 180 180 flipLR(linspace(3, 68, 14)) 180 180 180 180 180 180 180 180].*2;
    %params.dotOrder=[1 1 1 2 2 2 3 3 3 4 4 4 5 5 5 6 6 6 7 7 7 0 0 0 0 0 0
    %0 0 0 7 7 7 6 6 6 5 5 5 4 4 4 3 3 3 2 2 2 1 1 1 0 0 0 0 0 0 0 0 0]; 
    
case 'Dots In Noise pRF full blanks TR=1.5, nTRs=3'
    params.type = 'bar';
	params.ringDeg = params.radius./4; 
	params.seqDirection = 0;
    params.insertBlanks.do = 1;
    params.numSubRings = (params.radius-params.innerRad)/(params.radius);
    params.stimSpeed=0;
    params.stimDirection=0;  
    params.whichStim='dots'; 
    params.equalArea = 0;
    params.reverseDirection=false;
    %Initial pilot
    %params.dotOrder=[1 0 2 0 3 0 4 0 5 0 6 0 7 0 0 0 0 0 0 0 0 0 0 7 0 6 0 5 0 4 0 3 0 2 0 1 0 0 0 0 0 0 0 0 0 0]; 
    %Second pilot, no blanks, less frequent presentations to avoid
    %adaptation
    params.dotOrder=[1 1 1 2 2 2 3 3 3 4 4 4 5 5 5 6 6 6 7 7 7 20 20 20 20 20 20 20 20 20 7 7 7 6 6 6 5 5 5 4 4 4 3 3 3 2 2 2 1 1 1 20 20 20 20 20 20 20 20 20]; 
    
case 'Numbers Size pRF full blanks TR=1.5, nTRs=3'
    params.type = 'bar';
	params.ringDeg = params.radius./4; 
	params.seqDirection = 0;
    params.insertBlanks.do = 1;
    params.numSubRings = (params.radius-params.innerRad)/(params.radius);
    params.stimSpeed=0;
    params.stimDirection=0;  
    params.whichStim='dots'; 
    params.equalArea = 0;
    params.reverseDirection=false;
    %Initial pilot
    %params.dotOrder=[1 0 2 0 3 0 4 0 5 0 6 0 7 0 0 0 0 0 0 0 0 0 0 7 0 6 0 5 0 4 0 3 0 2 0 1 0 0 0 0 0 0 0 0 0 0]; 
    %Second pilot, no blanks, less frequent presentations to avoid
    %adaptation
    params.dotOrder=[1 1 1 2 2 2 3 3 3 4 4 4 5 5 5 6 6 6 7 7 7 20 20 20 20 20 20 20 20 20 7 7 7 6 6 6 5 5 5 4 4 4 3 3 3 2 2 2 1 1 1 20 20 20 20 20 20 20 20 20]; 

case 'Dots Size pRF full blanks ECoG TR=1.5, nTRs=3'
    params.type = 'bar';
	params.ringDeg = params.radius./4; 
	params.seqDirection = 0;
    params.insertBlanks.do = 1;
    params.numSubRings = (params.radius-params.innerRad)/(params.radius);
    params.stimSpeed=0;
    params.stimDirection=0;  
    params.whichStim='dots'; 
    params.equalArea = 1;
    params.reverseDirection=false;
    %Initial pilot
    %params.dotOrder=[1 0 2 0 3 0 4 0 5 0 6 0 7 0 0 0 0 0 0 0 0 0 0 7 0 6 0 5 0 4 0 3 0 2 0 1 0 0 0 0 0 0 0 0 0 0]; 
    %Second pilot, no blanks, less frequent presentations to avoid
    %adaptation
    params.dotOrder=[1 1 1 2 2 2 3 3 3 4 4 4 5 5 5 6 6 6 7 7 7 20 20 20 7 7 7 6 6 6 5 5 5 4 4 4 3 3 3 2 2 2 1 1 1 20 20 20]; 
    %params.dotOrder=[1 1 1 2 2 2 3 3 3 4 4 4 5 5 5 6 6 6 7 7 7 0 0 0 0 0 0
    %0 0 0 7 7 7 6 6 6 5 5 5 4 4 4 3 3 3 2 2 2 1 1 1 0 0 0 0 0 0 0 0 0]; 

case 'Dots Size pRF ECoG long random order'
    params.type = 'bar';
	params.ringDeg = params.radius./4; 
	params.seqDirection = 0;
    params.insertBlanks.do = 1;
    params.numSubRings = (params.radius-params.innerRad)/(params.radius);
    params.stimSpeed=0;
    params.stimDirection=0;  
    params.whichStim='dots'; 
    params.equalArea = 0;
    params.reverseDirection=false;

    %params.dotOrder=        [3 4 2 2 20 7 6 1 3 2 20 4 3 5 1 7 2 5 1 5 2 4 4 6 6 7 20 3 5 7 4 1 6 20 5 2 6 20 7 6 3 1 4 5 7]; 
    %params.conditionOrder = [3 2 5 3 6  1 4 3 4 2 2  5 6 5 5 5 1 4 6 3 4 1 3 5 3 6  4 5 6 3 4 1 6  5 1 6 2  1 4 1 2 2 6 2 2];
    
    params.dotOrder       = [2 5 4 6 6 7 6 2 7 20 6 3 3 20 1 1 5 6 6 7 7 5 4 4 4 5 7 20 7 20 1 2 2 1 2 4 3 5 5 2 3 1 3 4 20];
    params.conditionOrder = [3 2 2 2 6 1 3 4 3  2 1 2 6  1 3 6 3 4 5 6 5 1 3 5 4 4 2  4 4  6 2 1 2 5 5 1 5 6 5 6 3 1 4 6  5];

case 'Timing pRF TR=2.1, Constant Event Number'
%     isi=100;
%     nTRsBlank=8;
%     TR=2100;
%     %Desired event durations. Last is duration during blank
%     eventDuration =  [50 100 150 200 250 300 350 400 450 500 550 600 650 700 750 800 850 900 950 1000 TR-isi];
%     %Some math to calculate how many events to show in each TR
%     setsPerTR=round(TR./(eventDuration+isi));
%     timingError=(TR*length(eventDuration))-(sum(setsPerTR.*(eventDuration+isi)));
% 
%     if timingError>0
%         setsPerTR(eventDuration==(timingError-isi))=setsPerTR(eventDuration==(timingError-isi))+1;
%     elseif timingError<0
%         setsPerTR(eventDuration==(-timingError-isi))=setsPerTR(eventDuration==(-timingError-isi))-1; 
%     end
%     
%     params.eventDuration=[eventDuration repmat(eventDuration(end), [1,nTRsBlank-2]) fliplr(eventDuration), repmat(eventDuration(end), [1,nTRsBlank])];
%     params.setsPerTR =   [setsPerTR repmat(setsPerTR(end), [1,nTRsBlank-2]) fliplr(setsPerTR), repmat(setsPerTR(end), [1,nTRsBlank])];
%     params.eventNumber = ones(size(params.eventDuration));
%     params.dotSize=20;
%     params.isi=repmat(isi, [1,length(params.eventDuration)]);
%     params.interEventInterval=repmat(0, [1,length(params.eventDuration)]);
%     params.stimTR=TR;
%     
    
    isi=100;
    nTRsBlank=8;
    TR=2100;
    %Desired event durations. Last is duration during blank
    eventDuration =  [50 100 150 200 250 300 350 400 450 500 550 600 650 700 750 800 850 900 950 1000 2000];
    %Some math to calculate how many events to show in each TR
    setsPerTR=round((TR-isi)./(eventDuration));
    timingDrift=(TR-isi)-setsPerTR.*eventDuration;
    
%     timingDrift=0;
%     for n=1:length(eventDuration)
%         setsPerTR(n)=round((TR+timingDrift(n)-isi)/eventDuration(n));
%         timingDrift(n+1)=TR-(setsPerTR(n)*eventDuration(n)+isi);
%     end
    
    
    params.eventDuration=[eventDuration repmat(eventDuration(end), [1,nTRsBlank-2]) fliplr(eventDuration), repmat(eventDuration(end), [1,nTRsBlank])];
    params.setsPerTR =   [setsPerTR repmat(setsPerTR(end), [1,nTRsBlank-2]) fliplr(setsPerTR), repmat(setsPerTR(end), [1,nTRsBlank])];
    params.timingDrift =   [timingDrift repmat(timingDrift(end), [1,nTRsBlank-2]) fliplr(timingDrift), repmat(timingDrift(end), [1,nTRsBlank])];
    params.eventNumber = ones(size(params.eventDuration));
    params.dotSize=20;
    params.isi=repmat(isi, [1,length(params.eventDuration)]);
    params.interEventInterval=repmat(0, [1,length(params.eventDuration)]);
    params.stimTR=TR;
    
case 'Timing pRF TR=2.1, Duration Constant Frequency'
    nTRsBlank=8;
    TR=2100;
    setsPerTR=2;
    %Desired event durations. Last is duration during blank
    eventDuration =  [50 100 150 200 250 300 350 400 450 500 550 600 650 700 750 800 850 900 950 1000 2000];
    isi=[(TR/setsPerTR)-eventDuration(1:(end-1)) TR-eventDuration(end)];
    setsPerTR=[ones(1,length(eventDuration)-1).*setsPerTR 1];
    
    params.eventDuration=[eventDuration repmat(eventDuration(end), [1,nTRsBlank-2]) fliplr(eventDuration), repmat(eventDuration(end), [1,nTRsBlank])];
    params.setsPerTR =   [setsPerTR repmat(setsPerTR(end), [1,nTRsBlank-2]) fliplr(setsPerTR), repmat(setsPerTR(end), [1,nTRsBlank])];
    params.isi=[isi repmat(isi(end), [1,nTRsBlank-2]) fliplr(isi), repmat(isi(end), [1,nTRsBlank])];
    params.dotSize=20;
    params.interEventInterval=repmat(0, [1,length(params.eventDuration)]);
    params.eventNumber = ones(size(params.eventDuration));
    params.stimTR=TR;
  
case 'Timing pRF TR=2.1, Constant Event Duration'
    isi=300;
    interEventInterval=100;
    eventDuration=100;
    
    %Synchronise to every TR
%     TR=2100;
%     eventNumber=[1 1 2 2 3 3 4 4 5 5 6 6 7 7 8 8 9 9 10 10 1+(TR-eventDuration-isi)/(eventDuration+interEventInterval)];
%     nTRsBlank=8;
%     
    %Synchronise to every second TR
    TR=4200;
    eventNumber=[1 2 3 4 5 6 7 8 9 10 1+(TR-eventDuration-isi)/(eventDuration+interEventInterval)];
    isi=repmat(isi-interEventInterval, size(eventNumber));
    nTRsBlank=4;
    

     setDuration=eventNumber.*(eventDuration+interEventInterval);
     setsPerTR=round((TR-isi)./setDuration);

     setsPerTR(2)=9;
     timingDrift=(TR-isi)-(setsPerTR.*setDuration);
%     setsPerTR=round(TR./(setDuration+isi));
%     timingError=(TR*length(setDuration))-(sum(setsPerTR.*(setDuration+isi)));
% 
%     if timingError>0
%         indices=eventNumber.*eventDuration+(eventNumber-1)*interEventInterval==(timingError-isi);
%         indices=find(indices,1);
%         setsPerTR(indices)=setsPerTR(indices)+1;
%     elseif timingError<0
%         indices=eventNumber.*eventDuration+(eventNumber-1)*interEventInterval==(-timingError-isi);
%         indices=find(indices,1);
%         setsPerTR(indices)=setsPerTR(indices)-1;
%     end
%     timingError=(TR*length(setDuration))-(sum(setsPerTR.*(setDuration+isi)))
    
    params.eventNumber=[eventNumber repmat(eventNumber(end), [1,nTRsBlank-2]) fliplr(eventNumber), repmat(eventNumber(end), [1,nTRsBlank])];
    params.setsPerTR =   [setsPerTR repmat(setsPerTR(end), [1,nTRsBlank-2]) fliplr(setsPerTR), repmat(setsPerTR(end), [1,nTRsBlank])];
    params.eventDuration=ones(size(params.eventNumber)).*eventDuration;
    params.timingDrift =   [timingDrift repmat(timingDrift(end), [1,nTRsBlank-2]) fliplr(timingDrift), repmat(timingDrift(end), [1,nTRsBlank])];
    params.isi=[isi repmat(isi(end), [1,nTRsBlank-2]) fliplr(isi), repmat(isi(end), [1,nTRsBlank])];
    params.interEventInterval=repmat(interEventInterval, size(params.eventNumber));
    params.stimTR=TR;
    params.dotSize=20;
    
case 'Timing pRF TR=2.1, Event Number Constant Frequency'
    isi=300;
    interEventInterval=100;
    eventDuration=100;
    setsPerTR=2;

    %Synchronise to every second TR
    TR=4200;
    eventNumber=[1 2 3 4 5 6 7 8 9 10 1+(TR-eventDuration-isi)/(eventDuration+interEventInterval)];
    nTRsBlank=4;
    setsPerTR=[ones(1,length(eventNumber)-1).*setsPerTR 1];
    setDuration=eventNumber.*eventDuration+interEventInterval.*(eventNumber-1);
    isi=[(TR./setsPerTR(1:(end)))-setDuration(1:(end))];
    
    params.eventNumber=[eventNumber repmat(eventNumber(end), [1,nTRsBlank-2]) fliplr(eventNumber), repmat(eventNumber(end), [1,nTRsBlank])];
    params.setsPerTR =   [setsPerTR repmat(setsPerTR(end), [1,nTRsBlank-2]) fliplr(setsPerTR), repmat(setsPerTR(end), [1,nTRsBlank])];
    params.eventDuration=ones(size(params.eventNumber)).*eventDuration;
    params.isi=[isi repmat(isi(end), [1,nTRsBlank-2]) fliplr(isi), repmat(isi(end), [1,nTRsBlank])];
    params.interEventInterval=repmat(interEventInterval, size(params.eventNumber));
    params.stimTR=TR;
    params.dotSize=20;
    
case 'Timing pRF TR=2.1, Constant Set Duration'
    isi=300;
    interEventInterval=100;
    
%     TR=2100;
%     eventNumber=[1 1 2 2 3 3 4 4 5 5 6 6 7 7 8 8 9 9 10 10 20];
%     nTRsBlank=8;
    
    %Synchronise to every second TR
    TR=4200;
    eventNumber=[1 2 3 4 5 6 7 8 9 10 20];
    nTRsBlank=4;
    
    %eventDuration=(TR-(isi-interEventInterval))./eventNumber-interEventInterval;
    eventDuration=TR./(eventNumber*2);
        
    params.eventDuration=[eventDuration repmat(eventDuration(end), [1,nTRsBlank-2]) fliplr(eventDuration), repmat(eventDuration(end), [1,nTRsBlank])];
    params.eventNumber=[eventNumber repmat(eventNumber(end), [1,nTRsBlank-2]) fliplr(eventNumber), repmat(eventNumber(end), [1,nTRsBlank])];
    params.setsPerTR=ones(size(params.eventNumber));
    params.isi=params.eventDuration;%repmat(isi, [1,length(params.eventDuration)]);
    params.interEventInterval=zeros(size(params.eventNumber));%repmat(interEventInterval, [1,length(params.eventDuration)]);
    params.stimTR=TR;
    params.dotSize=20;
    
    
    
case 'Dots Scaled pRF full blanks TR=2, nTRs=2'
    params.type = 'bar';
	params.ringDeg = params.radius./4; 
	params.seqDirection = 0;
    params.insertBlanks.do = 1;
    params.numSubRings = (params.radius-params.innerRad)/(params.radius);
    params.stimSpeed=0;
    params.stimDirection=0;  
    params.whichStim='dots'; 
    params.equalArea = 1;
    params.reverseDirection=false;
    %Initial pilot
    %params.dotOrder=[1 0 2 0 3 0 4 0 5 0 6 0 7 0 0 0 0 0 0 0 0 0 0 7 0 6 0 5 0 4 0 3 0 2 0 1 0 0 0 0 0 0 0 0 0 0]; 
    %Second pilot, no blanks, less frequent presentations to avoid
    %adaptation
    %params.dotOrder=[1 1 2 2 3 3 4 4 5 5 6 6 7 7 20 20 20 20 20 20 7 7 6 6 5 5 4 4 3 3 2 2 1 1 20 20 20 20 20 20]; 
    params.dotOrder=[1 2 3 4 5 6 7 20 20 20 7 6 5 4 3 2 1 20 20 20]; 
    
case 'Dots psychophysics'
    params.type = 'bar';
	params.ringDeg = params.radius./4; 
	params.seqDirection = 0;
    params.insertBlanks.do = 1;
    params.numSubRings = (params.radius-params.innerRad)/(params.radius);
    params.stimSpeed=0;
    params.stimDirection=0;  
    params.whichStim='dots'; 
    params.equalArea = 1;
    params.reverseDirection=false;

    
case 'Dots Attention'
    params.type = 'bar';
	params.ringDeg = params.radius./4; 
	params.seqDirection = 0;
    params.insertBlanks.do = 1;
    params.numSubRings = (params.radius-params.innerRad)/(params.radius);
    params.stimSpeed=0;
    params.stimDirection=0;  
    params.whichStim='dots'; 
    params.equalArea = 0;
    params.reverseDirection=false;
    
    
case 'Dots Gaussian'
    params.type = 'bar';
	params.ringDeg = params.radius./4; 
	params.seqDirection = 0;
    params.insertBlanks.do = 1;
    params.numSubRings = (params.radius-params.innerRad)/(params.radius);
    params.stimSpeed=0;
    params.stimDirection=0;  
    params.whichStim='dots'; 
    params.equalArea = 0;
    params.reverseDirection=false;
    
case 'Dots HRF'
    params.type = 'bar';
	params.ringDeg = params.radius./4; 
	params.seqDirection = 0;
    params.insertBlanks.do = 1;
    params.numSubRings = (params.radius-params.innerRad)/(params.radius);
    params.stimSpeed=0;
    params.stimDirection=0;  
    params.whichStim='dots'; 
    params.equalArea = 0;
    params.reverseDirection=false;
    %Initial pilot
    %params.dotOrder=[1 0 2 0 3 0 4 0 5 0 6 0 7 0 0 0 0 0 0 0 0 0 0 7 0 6 0 5 0 4 0 3 0 2 0 1 0 0 0 0 0 0 0 0 0 0]; 
    %Second pilot, no blanks, less frequent presentations to avoid
    %adaptation
    params.dotOrder=[3 3 3 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20 20]; 
    %params.dotOrder=[1 1 1 2 2 2 3 3 3 4 4 4 5 5 5 6 6 6 7 7 7 0 0 0 0 0 0
    %0 0 0 7 7 7 6 6 6 5 5 5 4 4 4 3 3 3 2 2 2 1 1 1 0 0 0 0 0 0 0 0 0]; 
    expName='Dots Size pRF full blanks TR=1.5, nTRs=3';
    params.experiment='Dots Size pRF full blanks TR=1.5, nTRs=3';
    
    
case '8 bars with blanks (tr 3)',
	params.type = 'bar';
	params.ringDeg = params.radius./4; 
	params.seqDirection = 0;
    params.insertBlanks.do = 1;
    params.numSubRings = (params.radius-params.innerRad)/(params.radius);
    
case '8 bars with blanks (magno)'
    params.type = 'bar';
	params.ringDeg = 2;
    params.temporal.frequency = 7.5; %Hz
    params.temporal.motionSteps =4;
    params.numSubRings = 4;  
    params.insertBlanks.do = 1;
    params.contrast=1;
    params.rmscontrast=12;
case '8 bars with blanks (parvo)'
    params.type = 'bar';
	params.ringDeg = 2;
    params.temporal.frequency = 30/22; %Hz
    params.temporal.motionSteps =22;
    params.numSubRings = 4;  
    params.insertBlanks.do = 1;
    params.contrast=1;
    params.rmscontrast=12;
    
case '8 bars with blanks (attention)'
    params.type = 'bar';
	params.ringDeg = 2;
    params.temporal.frequency = 7.5; %Hz
    params.temporal.motionSteps =4;
    params.numDiffStim = 2;
    params.numSubRings = 4;  
    params.insertBlanks.do = 1;
    params.contrast=1;
    params.rmscontrast=12;
    params.ISIframes = 5;
    params.StimOnFrames = 7;
    
case '8 bars with blanks (attention checkerboard)'
    params.type = 'bar';
	%params.ringDeg = 2;
    %params.temporal.frequency = 7.5; %Hz
    %params.temporal.motionSteps =4;
    %params.numDiffStim = 2;
    %params.numSubRings = 4;  
    %params.insertBlanks.do = 1;
    %params.contrast=1;
    %params.rmscontrast=12;
    params.ISIframes = 5;
    params.StimOnFrames = 7;
    
    params.type = 'bar';
	params.ringDeg = params.radius./4; 
	params.seqDirection = 0;
    params.insertBlanks.do = 1;
    params.numSubRings = (params.radius-params.innerRad)/(params.radius);
    
    
case '8 bars with blanks (attention bar psychophysics)'
    params.type = 'bar';
	params.ringDeg = 2;
    params.temporal.frequency = 7.5; %Hz
    params.temporal.motionSteps =4;
    params.numDiffStim = 2;
    params.numSubRings = 4;  
    params.insertBlanks.do = 1;
    params.contrast=1;
    params.rmscontrast=12;
    params.ISIframes = 10;
    params.StimOnFrames = 5;    
case '8 bars with blanks (attention fixation psychophysics)'
    params.type = 'bar';
	params.ringDeg = 2;
    params.temporal.frequency = 7.5; %Hz
    params.temporal.motionSteps =4;
    params.numDiffStim = 2;
    params.numSubRings = 4;  
    params.insertBlanks.do = 1;
    params.contrast=1;
    params.rmscontrast=12;
    params.ISIframes = 2;
    params.StimOnFrames = 10;
%    params.numSubRings = (params.radius)/(2*params.subRingDeg);

    %     params.display.gamma = create_LMScmap(params.display,[1 1 1]);%.*.5); 
%     if size(params.display.gamma,1)~=256,
%         params.display.gamma = params.display.gamma(round(linspace(1,size(params.display.gamma,1),255)),:);
%         params.display.gamma(256,:) = [1 1 1];
%     end;
%     params.display.gammaTable = round(params.display.gamma.*256)+1;
% case '8 bars (L-M)',
% 	params.type = 'bar';
% 	params.ringDeg = params.radius/3;
% 	params.seqDirection = 0;
%     params.insertBlanks.do = 0;
%     params.numSubRings = 1;
%     params.temporal.motionSteps = 8;
%     params.display.gamma = create_LMScmap(params.display,[-1 1 0].*.06); 
%     if size(params.display.gamma,1)~=256,
%         params.display.gamma = params.display.gamma(round(linspace(1,size(params.display.gamma,1),255)),:);
%         params.display.gamma(256,:) = [1 1 1];
%     end;
%     params.display.gammaTable = round(params.display.gamma.*256)+1;
% case '8 bars (S)',
% 	params.type = 'bar';
% 	params.ringDeg = params.radius/3;
% 	params.seqDirection = 0;
%     params.insertBlanks.do = 0;
%     params.numSubRings = 1;
%     params.temporal.motionSteps = 8;
%     params.display.gamma = create_LMScmap(params.display,[0 0 1].*.5); 
%     if size(params.display.gamma,1)~=256,
%         params.display.gamma = params.display.gamma(round(linspace(1,size(params.display.gamma,1),255)),:);
%         params.display.gamma(256,:) = [1 1 1];
%     end;
%     params.display.gammaTable = round(params.display.gamma.*256)+1;
    
case '8 bars (letters)',
    params.temporal.numStimChanges = 2;
    params.temporal.numNoiseChanges = 4;
    params.stimulusType = 'letters';
    
case 'new',
	% a convenient place for specifying some params to test
	params.type = 'ring';
	params.backRGB.dir = [1 1 1]';
	params.backRGB.scale = 0.5;
	params.stimLMS.dir = [1 1 1]';
	params.stimLMS.scale = 1;
	params.temporal.frequency = 4;
	params.radius = 16;			% Stimulus radius (deg; max 16)
	params.innerRad = 0;		% Non-zero for annular wedge condition (deg)
	params.wedgeDeg = 90;		% Wedge polar angle (deg)
	params.subWedgeDeg = 15;	% Sub wedge polar angle (deg) 
	params.ringDeg = params.radius/2;			% Ring radius/width (deg)
	params.subRingDeg = 0.5;			% 1/2 radial spatial freq (deg)
    params.numSubRings = (params.radius)/(2*params.subRingDeg);


otherwise,
	error('Unknown expName!');
end


% stimulus on/off presentation
if params.insertBlanks.do,
%    bn = questdlg('Phase lock stimulus on/off cycle?','Blanking','Yes','No','No');
%	if strmatch(bn,'Yes'),
%		params.insertBlanks.phaseLock = 1;
%    else,
		params.insertBlanks.phaseLock = 0;
%    end;
end;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%																	%
% Fixation parameters												%
%																	%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

params.display.fixType        = params.fixation; % disk or largeCross
params.display.fixSizePixels  = 6;%3;%6;12  %pixels RADIUS
switch(lower(params.display.fixType))
    case {'disk','double disk', 'mid disk double'}
        params.display.fixColorRgb    = [255 0 0 255;...
                                         0 255 0 255];%172 0 0  255];
        if strcmpi(expName,'8 bars with blanks (attn)')
            params.display.fixColorRgb    = [255 0 0 255;...
                                             255 0 0 255];%172 0 0  255];
            params.display.fixColorRgb(2,1)=...
            round(128+128.*params.attn.contrast(2,2))-1;
        end
        
%        params.display.fixColorRgb    = [255 255 255 255;...
%                                         255 255 255 255];
        dim.x = params.display.numPixels(1);
        dim.y = params.display.numPixels(2);
        params.display.fixX = round(dim.x./2);
        params.display.fixY = round(dim.y./2);
        
        %params.display.fixX = params.display.fixX - 24; %-24 = left +24 = right
        
%         [physicalWidth, physicalHeight]=Screen('WindowSize', 0);
%         if dim.x<physicalWidth || dim.y<physicalHeight
%             %sizeDifX=(physicalWidth-dim.x)
%             
%             dim.x = physicalWidth;
%             dim.y = physicalHeight;
%             params.display.fixX = round(dim.x./2);
%             params.display.fixY = round(dim.y./2);
%         end
        
        
        %FOR 7T PROJECTOR WITH BIGGEST POSSIBLE STIMULI
        %params.display.fixY=params.display.fixY+115;
        if strcmp(expName,'Full-field full') && strcmp(params.display.position,'7T UMC scanner rear-to-front')
            params.display.fixColorRgb    = [255 255 255 255;...
                                            0 0 0 255];
            params.display.fixY= round(dim.y./2) + 115;
            %For HRF measurement
            params.display.fixColorRgb    = [255 0 0 255;...
                                            0 255 0 255];
            params.display.fixY= round(dim.y./2) - 115;
            
        %elseif strcmp(expName,'full-field, flicker (sin)') && strcmp(params.display.position,'7T UMC scanner rear-to-front')
%             params.display.fixColorRgb    = [255 255 255 255;...
%                                             0 0 0 255];
         %    params.display.fixY= round(dim.y./2) +115; %middle of viewable area
             %params.display.fixY=300; %top of viewable area
        elseif strcmp(expName,'rotating wedge (90deg duty) BH') && strcmp(params.display.position,'7T UMC scanner rear-to-front')
%             params.display.fixColorRgb    = [255 255 255 255;...
%                                             0 0 0 255];
             %params.display.fixY= round(dim.y./2) +115; %middle of viewable area
             
%         elseif strcmp(expName(1:19),'radial checkerboard') && strcmp(params.display.position,'7T UMC scanner rear-to-front')
%             params.display.fixColorRgb    = [255 255 255 255;...
%                                             0 0 0 255];
             params.display.fixY= round(dim.y./2) +115; %middle of viewable area
             %params.display.fixY=300; %top of viewable area
        end
        
        if isfield(params.display, 'viewableRect')
            params.display.fixY=round((params.display.viewableRect(2)+params.display.viewableRect(4))/2);
            if isfield(params.display, 'quadrant') && strcmp(params.display.quadrant, 'L')
                params.display.fixX = params.display.viewableRect(1)+angle2pix(params.display, params.display.fixationIndent);
            elseif isfield(params.display, 'quadrant') &&strcmp(params.display.quadrant, 'R')
                params.display.fixX = params.display.viewableRect(3)-angle2pix(params.display, params.display.fixationIndent);
            elseif isfield(params.display, 'quadrant') &&strcmp(params.display.quadrant, 'LU')
                params.display.fixX = params.display.viewableRect(1)+angle2pix(params.display, params.display.fixationIndent);
                params.display.fixY = params.display.viewableRect(2)+angle2pix(params.display, params.display.fixationIndent);
            elseif isfield(params.display, 'quadrant') &&strcmp(params.display.quadrant, 'LD')
                params.display.fixX = params.display.viewableRect(1)+angle2pix(params.display, params.display.fixationIndent);
                params.display.fixY = params.display.viewableRect(4)-angle2pix(params.display, params.display.fixationIndent);
            elseif isfield(params.display, 'quadrant') &&strcmp(params.display.quadrant, 'RU')
                params.display.fixX = params.display.viewableRect(3)-angle2pix(params.display, params.display.fixationIndent);
                params.display.fixY = params.display.viewableRect(2)+angle2pix(params.display, params.display.fixationIndent);
            elseif isfield(params.display, 'quadrant') &&strcmp(params.display.quadrant, 'RD')
                params.display.fixX = params.display.viewableRect(3)-angle2pix(params.display, params.display.fixationIndent);
                params.display.fixY = params.display.viewableRect(4)-angle2pix(params.display, params.display.fixationIndent);
            end
        elseif isfield(params.display, 'Rect')
            params.display.fixY=round((params.display.Rect(2)+params.display.Rect(4))/2);
        end
        
            params.display.hemifield='L';
            params.display.quadrant=false;
            params.display.fusionBackground=true;
        
        if strcmpi(params.display.fixType,'double disk');
            params.display.fixSizePixels  = [params.display.fixSizePixels, 1.5*params.display.fixSizePixels, angle2pix(params.display, 1/2)];
        end
    case {'left disk 0.5deg','right disk 0.5deg'}
        params.display.fixColorRgb    = [255 0 0 255;...
                                         0 255 0 255];%172 0 0  255];

        dim.x = params.display.numPixels(1);
        dim.y = params.display.numPixels(2);
        params.display.fixX = round(dim.x./2);
        params.display.fixY = round(dim.y./2);
        
        
        if isfield(params.display, 'Rect')
            params.display.fixY=round((params.display.Rect(2)+params.display.Rect(4))/2);
        end
        
        if strcmpi(params.display.fixType,'left disk 0.5deg');
            params.display.fixX = params.display.fixX-angle2pix(params.display, 0.5);
        elseif strcmpi(params.display.fixType,'right disk 0.5deg');
            params.display.fixX = params.display.fixX+angle2pix(params.display, 0.5);
        end
        
        params.display.fixType='disk';
    case {'disk and markers'}
        params.display.fixColorRgb    = [255 0 0 255;...
                                         0 255 0 255];%172 0 0  255];
        dim.x = params.display.numPixels(1);
        dim.y = params.display.numPixels(2);
        params.display.fixX = round(dim.x./2);
        params.display.fixY = round(dim.y./2);
        step_startx = linspace(params.ringDeg./2,params.radius,ceil(21./2))-(params.ringDeg./2);
    % add the negative starts from fixation, define as outeredge
        step_startx = [fliplr(-1.*step_startx(2:end)) step_startx]-(params.ringDeg./2);
        step_startx = angle2pix(params.display, step_startx);
        startx=ceil(step_startx(14));
        params.display.markerX=[params.display.fixX+startx params.display.fixX+startx+angle2pix(params.display, params.ringDeg) params.display.fixX-startx params.display.fixX-startx-angle2pix(params.display, params.ringDeg)];
        %[dim.x-((dim.x-dim.y)/2)-round(angle2pix(params.display, (params.radius-params.ringDeg./2)./1.5+params.ringDeg./2))-angle2pix(params.display, params.ringDeg./2) dim.x-((dim.x-dim.y)/2)-round(angle2pix(params.display, (params.radius-params.ringDeg./2)./1.5+params.ringDeg./2))+angle2pix(params.display, params.ringDeg./2)];
        %params.display.markerX=[100 200];
        
        params.display.markerY=[0 5 dim.y-5 dim.y];
        params.display.markerColor=[255 255 255];
        if isfield(params.display, 'Rect')
            params.display.fixY=round((params.display.Rect(2)+params.display.Rect(4))/2);
        end
    case {'small cross +'}
        params.display.fixColorRgb    = [255 0 0 255;...
                                         0 255 0 255];
        dim.x = params.display.numPixels(1);
        dim.y = params.display.numPixels(2);
        params.display.fixX = round(dim.x./2);
        params.display.fixY = round(dim.y./2);
        if isfield(params.display, 'Rect')
            params.display.fixY=round((params.display.Rect(2)+params.display.Rect(4))/2);
        end       
        
    case {'large cross' , 'largecross'},
        params.display.fixColorRgb    = [255 0 0 255;...
                                        255 0 0 255];
        if strcmp(params.experiment, '8 bars with blanks (TR 2.1)')
            params.display.fixColorRgb    = [255 0 0 255;...
                                            0 255 0 255];
        end
        params.display.fixSizePixels  = 1;
        dim.x = params.display.numPixels(1);
        dim.y = params.display.numPixels(2);
        dim.ycoord = [1:dim.y dim.y:-1:1] ; % assume ydim is smallest
        dim.xcoord = [1:dim.y 1:dim.y] + round(-dim.y/2+dim.x/2);
        if strcmp(expName,'Full-field full') && strcmp(params.display.position,'7T UMC scanner rear-to-front')
            params.display.Rect=tmpRect;
        end
         if isfield(params.display, 'Rect')
            %For cross centered at middle of Rect, but reaching edge of
            %display
            ymid=round((params.display.Rect(2)+params.display.Rect(4))/2);
            yrange=dim.y-ymid;
            ymin=ymid-yrange;
            ymax=ymid+yrange;
            xmid=round((params.display.Rect(1)+params.display.Rect(3))/2);
            xmin=xmid-yrange;
            xmax=xmid+yrange;
            dim.ycoord= [ymin:ymax ymax:-1:ymin];
            dim.xcoord= [xmin:xmax xmin:xmax];
            params.display.fixY=round((params.display.Rect(2)+params.display.Rect(4))/2);
            
%             %For cross contained entirely within Rect
%             dim.ycoord= [params.display.Rect(2):params.display.Rect(4) params.display.Rect(4):-1:params.display.Rect(2)];
%             dim.xcoord= [params.display.Rect(1):params.display.Rect(3) params.display.Rect(1):params.display.Rect(3)];
        end        
        params.display.fixCoords = [dim.xcoord;dim.ycoord];

    case {'double large cross' , 'doublelargecross'},
        params.display.fixColorRgb    = [255 255 0 255;...
                                         255 255 0 255];
        params.display.fixSizePixels{1}= 12;
        dim.x = params.display.numPixels(1);
        dim.y = params.display.numPixels(2);
        dim.ycoord = [1:dim.y dim.y:-1:1] ; % assume ydim is smallest
        dim.xcoord = [1:dim.y 1:dim.y] + round(-dim.y/2+dim.x/2);
        params.display.fixCoords{1} = [dim.xcoord;dim.ycoord];
        
    case {'large cross x+' , 'largecrossx+'},
        params.display.fixColorRgb    = [255 255 0 255;...
                                         255 255 0 255];
        params.display.fixSizePixels  = round([1 sqrt(2)].*12);
        dim.x = params.display.numPixels(1);
        dim.y = params.display.numPixels(2);
        dim.ycoord = [1:dim.y dim.y:-1:1] ; % assume ydim is smallest
        dim.xcoord = [1:dim.y 1:dim.y] + round(-dim.y/2+dim.x/2);
        params.display.fixCoords{1} = [dim.xcoord;dim.ycoord];
        dim.x = params.display.numPixels(1);
        dim.y = params.display.numPixels(2);
        dim.ycoord = [1:dim.y (1:dim.y).*0+round(dim.y./2)] ; % assume ydim is smallest
        dim.xcoord = [(1:dim.y).*0+round(dim.y./2) 1:dim.y] + round(-dim.y/2+dim.x/2);
        params.display.fixCoords{2} = [dim.xcoord;dim.ycoord];
    case {'left disk', 'left disk double'},
        params.display.fixColorRgb    = [255 0 0 255;...
                                         128 0 0 255];
        dim.x = params.display.numPixels(1);
        dim.y = params.display.numPixels(2);
        params.display.fixX = round(dim.x./2) - floor(min(max(dim.x),max(dim.y))./2);
        params.display.fixY = round(dim.y./2);
        %if params.display.numPixels(1)==1024
        if strcmp(expName,'Full-field full') && strcmp(params.display.position,'7T UMC scanner rear-to-front')
            params.display.fixColorRgb    = [255 255 255 255;...
                                            0 0 0 255];
            params.display.fixX = round((dim.x./2) - ((dim.x./2)*0.7));%round((params.display.Rect(4)-params.display.Rect(2))/3);
            params.display.fixY= round(dim.y./2) - 115;%round((params.display.Rect(2)-params.display.Rect(4))/2.4);
        end
        
    case {'right disk','right disk double'},
        params.display.fixColorRgb    = [255 0 0 255;...
                                         0 255 0 255];%172 0 0  255];
        dim.x = params.display.numPixels(1);
        dim.y = params.display.numPixels(2);
        params.display.fixX = round(dim.x./2) + floor(min(max(dim.x),max(dim.y))./2);
        params.display.fixY = round(dim.y./2);
        if strcmp(expName,'Full-field full') && strcmp(params.display.position,'7T UMC scanner rear-to-front')
            params.display.fixColorRgb    = [255 255 255 255;...
                                            0 0 0 255];
            params.display.fixX = round((dim.x./2) + ((dim.x./2)*0.7));%round((params.display.Rect(4)-params.display.Rect(2))/3);
            params.display.fixY= round(dim.y./2) + 115;
        end
    case {'none'}
        %do nothing
    otherwise,
        error('Unknown fixationType!');
end

% if red/green we make the fixation white so it can be seen in any
% condition
switch expName
    case {'full-field, red/green',...
          'full-field, red/green - red only',...
          'full-field, red/green - green only',...
          'full-field, red/green - red only with blanks',...
          'full-field, red/green - green only with blanks'}
      params.display.fixColorRgb    = [0 0 0 255;...
                                       255 255 255 255];
%     case {'8 bars','8 bars (slow)','8 bars with blanks','8 bars (sinewave)'}
%         params.display.fixColorRgb    = [  0   0   0 255;...
%                                          255 255 255 255];
%         params.display.fixSizePixels  = 3;
%     case {'8 bars (slow)'}
%         params.display.fixColorRgb    = [  0   0   0 255;...
%                                          255 255 255 255];
%         params.display.fixSizePixels  = 3;
    case {'8 bars (LMS)','8 bars (LMS) with blanks'}
        params.display.fixColorRgb    = [255 255 255 255;...
                                         255 255 255 255];
        params.display.fixSizePixels  = 2;
    case {'8 bars with blanks contours (0)','8 bars with blanks contours (90)','8 bars with blanks contours (-45)','8 bars with blanks contours (+45)','8 bars with blanks contours (random)','8 bars with blanks contours (r0)','8 bars with blanks contours (r90)','8 bars with blanks contours (b0)','8 bars with blanks contours (b90)','left vs right vs blank'}
        params.display.fixColorRgb    = [255 0 0 255;...
                                         255 0 0 255];
    case {'Full-field full','rotating wedge (90deg duty) BH', 'radial checkerboard fast','radial checkerboard slow temporal','radial checkerboard slow spatial', 'radial checkerboard localizer left-still-right-still'}
            % remove rect - defaults to entire window
            if isfield(params.display, 'Rect')
            params.display=rmfield(params.display, 'Rect');
            end
end;


params.fix.task               = 'Detect fixation change';
params.fix.colorRgb           = params.display.fixColorRgb;
params.fix.responseTime       = [.01 2]; % seconds


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%																	%
% Calculations (not to be updated by user)							%
%																	%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

params.ringWidth=params.ringDeg;

% Polar angle of wedge in radians
params.wedgeWidth = params.wedgeDeg * (pi/180);

% Number of rings in each wedge
%params.numSubRings = (params.radius-params.innerRad)/(2*params.subRingDeg);
%params.numSubRings = (params.radius-params.innerRad)/(params.radius);
%params.numSubRings = (params.radius)/(2*params.subRingDeg);

% Number of wedges in each ring
params.numSubWedges = params.wedgeDeg/(2*params.subWedgeDeg);

% duration of each image (seconds) 
params.imageDuration = params.period / params.numImages; 

% Duration of params
params.scanDuration = params.period * params.numCycles + params.prescanDuration;

% some checks, must be done before we reset certain params
retParamsCheck(params);

% ***HACK!  We'll let makeRetinotopy add the prescan stuff
params.ncycles = params.numCycles;
params.prescanDuration = params.prescanDuration;
params.period = params.period;


