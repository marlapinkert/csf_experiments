function stimulus = createTextures(params, stimulus, removeImages);
%stimulus = createTextures(display, stimulus, [removeImages=1]);
%
%Replace images within stimulus (stimulus.image) with textures
%(stimulus.textures).
%
%Stimulus can be a 1xn array of stimuli.  It creates the textures
%(like loading in off-screen memory in OS9).
% If the removeImages flag is set to 1 [default value], the code
% destroys the original image field (freeing up the memory and speeding up
% pass-by-copy calls of stimulus). For stimuli with many images, this is
% strongly recommended; however, for a small number of images, the field
% may not slow things too much; setting the flag to 0 keeps the images.
%
%If you're trying to create an texture starting at something
%other than the first image, use addTextures.

%2005/06/09   SOD: ported from createImagePointers
%31102005    fwc:	changed display.screenNumber into display.windowPtr
if notDefined('removeImages'),      removeImages = 1;       end

display = params.display;

%c = getReservedColor(display, 'background');
try,
	c = display.backColorIndex;
catch,
	c = display.backColorRgb;
end;

for stimNum = 1:length(stimulus)

	% if stored as cell?!
	% maybe everything should be cell based and not based on the 3 image
	% dimension - this would allow easy support for rgb images
	if iscell(stimulus(stimNum).images),
		stimulus(stimNum).images = cell2mat(stimulus(stimNum).images);
	end;

	% number of images
	nImages = size(stimulus(stimNum).images,3);
    
    % make Rects
    stimulus(stimNum).srcRect = [0,0,size(stimulus(stimNum).images, 2), ...
        size(stimulus(stimNum).images, 1)];
    
    stimulus(stimNum).destRect = CenterRect(stimulus(stimNum).srcRect, display.viewableRect);
    % BR: Ben, can you explain why we need the if, else below?
    % 	if ~isfield(display,'viewableRect'),
    % 		stimulus(stimNum).destRect = CenterRect(stimulus(stimNum).srcRect, display.viewableRect);
    %     else
    % 		stimulus(stimNum).destRect = display.viewableRect;
    % 	end;

	% clean up nicely if any of the textures are not null.
	if isfield(stimulus(stimNum), 'textures'),
		nonNull = find(stimulus(stimNum).textures);
		for i=1:length(nonNull),
			% run this from eval to suppress any errors that might ensue if the texture isn't valid
			eval('Screen(stimulus(stimNum).textures(nonNull(i)), ''Close'');', '[];');
		end;
	end;
	stimulus(stimNum).textures = zeros(nImages, 1);
    
	% make textures
	for imgNum = 1:nImages,
        %jw: flip for back bore inverted display
        if (isfield(display, 'flipLR') && display.flipLR),
            stimulus(stimNum).images(:,:,imgNum) = fliplr(stimulus(stimNum).images(:,:,imgNum));
        end
        if (isfield(display, 'flipUD') &&display.flipUD),
            stimulus(stimNum).images(:,:,imgNum) = flipud(stimulus(stimNum).images(:,:,imgNum));
        end
        
        stimulus(stimNum).textures(imgNum) = ...
			Screen('MakeTexture',display.windowPtr, ...
			double(stimulus(stimNum).images(:,:,imgNum)));  % fwc:	changed display.screenNumber into display.windowPtr
	end;
    
    if isfield(stimulus, 'pictures')
        for pictNum=1:length(stimulus.pictures)
            stimulus(stimNum).textures(nImages+((pictNum-1)*2+1)) = Screen('MakeTexture',display.windowPtr, double(stimulus.pictures(pictNum).circleimage1));
            stimulus(stimNum).textures(nImages+((pictNum-1)*2+2)) = Screen('MakeTexture',display.windowPtr, double(stimulus.pictures(pictNum).circleimage2));
        end
    end
    
    % make background texture
    % stimulus.backgroundTexure = 
    
	% clean up
	if removeImages==1
		stimulus(stimNum).images = [];
	end
end;

% Make a single 1/f noise background texture to help anchor vergence
[x,y] = meshgrid(-display.numPixels(1):display.numPixels(1),...
    -display.numPixels(2):display.numPixels(2));

noysSlope = 1.0; %1.5;
pa.rmax_bg_p10 = angle2pix(display,params.radius+.5+.5); % radius beyond which NOT to show nonius lines
pa.rmax_bg_p5 = angle2pix(display,params.radius+.5); % radius beyond which to show nonius lines
pa.rmax_bg = angle2pix(display,params.radius+.5); % radius beyond which to show background
pa.rmin_bg= angle2pix(display,.25); % degrees
ds.white = 255;

% noys = ds.white .* oneoverf(noysSlope, size(display.numPixels,1), size(display.numPixels,2));
% noys = ds.white .* zeros(size(x,1), size(x,2)); % Temp fix for lack of Vistools
% noys = ds.white .* zeros(size(x,1), size(x,2)); % Temp fix for lack of Vistools
noys = ds.white .* oneoverf(noysSlope, size(x,1), size(x,2));

% Additional fixation nonius lines outside aperture  
noys(abs(x) < 2 & abs(y)>(pa.rmax_bg_p5) & abs(y)<(pa.rmax_bg_p10)) = 1 .* ds.white;
noys(abs(y) < 2 & abs(x)>(pa.rmax_bg_p5) & abs(x)<(pa.rmax_bg_p10)) = 0 .* ds.white;

% noys(abs(x-pa.rmax_bg)<2 & y == 0) = 0 .* ds.white;
% noys(abs(y-pa.rmax_bg)<2 & x == 0) = 1 .* ds.white;

% noys(abs(x-pa.rmax_bg)<2 & abs(y)>(pa.rmax_bg + angle2pix(.5))) = 0 .* ds.white;
% noys(abs(y-pa.rmax_bg)<2 & abs(x)>(pa.rmax_bg + angle2pix(.5))) = 1 .* ds.white;

% Add (alpha) transparency map
noys(:,:,2) = ds.white .* (sqrt(x.^2+y.^2) > pa.rmax_bg); % outer region
noys(:,:,2)= noys(:,:,2) + ds.white.*((x.^2+y.^2) < pa.rmin_bg.^2); % inner region

% [H,W] = size(noys);
% % Add a gray donut near fixation
% [xs,ys] = meshgrid((1:H)-(H/2)+1,(1:W)-(W/2)+1);
% rs = sqrt(xs.^2 + ys.^2);
% donut = rs> pa.rmin_bg & rs< 4*pa.rmin_bg;
% noys(donut) = 128;

% donut = ((x.^2+y.^2)>pa.rmin_bg.^2 & (x.^2+y.^2)<(4*pa.rmin_bg).^2);
% noys(donut) = 128;

% noys = noys .*donut

% Additional fixation nonius lines outside aperture  
% noys(abs(x) < 2 & abs(y)>(pa.rmax_bg_p5) & abs(y)<(pa.rmax_bg_p10)) = 1 .* ds.white;
% noys(abs(y) < 2 & abs(x)>(pa.rmax_bg_p5) & abs(x)<(pa.rmax_bg_p10)) = 0 .* ds.white;

% noys(abs(x-pa.rmax_bg)<2 & y == 0) = 0 .* ds.white;
% noys(abs(y-pa.rmax_bg)<2 & x == 0) = 1 .* ds.white;

% noys(abs(x-pa.rmax_bg)<2 & abs(y)>(pa.rmax_bg + angle2pix(.5))) = 0 .* ds.white;
% noys(abs(y-pa.rmax_bg)<2 & abs(x)>(pa.rmax_bg + angle2pix(.5))) = 1 .* ds.white;

% Add (alpha) transparency map
% noys(:,:,2) = ds.white .* (sqrt(x.^2+y.^2) > pa.rmax_bg); % outer region
% %noys(:,:,2)= noys(:,:,2) + ds.white.*((x.^2+y.^2) < pa.rmin_bg.^2); % inner region
% noys(:,:,2)= noys(:,:,2) + ds.white.*((x.^2+y.^2) < (pa.rmin_bg)^2); % inner region


% draw nonius lines beyond rmax_bg
% If we we do that here, it cannot be eye dependent
% noniusSize = round(pa.rmax_bg:pa.rmax_bg+20);
% noys(,0,1) = 1 * ds.white;
% noys(0,round(pa.rmax_bg:pa.rmax_bg+20),1) = 0 * ds.white;

stimulus.backgroundTexture = Screen('MakeTexture', display.windowPtr, round(noys));

% 2 textures for stereo calibration
dashLength = 2; %16; % pixels, keep it even for simplicity
calib0 = ds.white .* x;
calib0(mod(x,2*dashLength)>=dashLength & abs(y)<2) = 0. * ds.white; % horizontal line
calib0(abs(x)<2 & mod(y,2*dashLength)>=dashLength) = 1. * ds.white; % vertical line

calib0(abs(y-pa.rmax_bg)<2) = 0. * ds.white; % additional line visible in both eyes
calib0(abs(y+pa.rmax_bg)<2) = 0. * ds.white; % additional line visible in both eyes

calib0(abs(x-pa.rmax_bg)<2) = 1. * ds.white; % additional line visible in both eyes
calib0(abs(x+pa.rmax_bg)<2) = 1. * ds.white; % additional line visible in both eyes

calib0(:,:,2) = ds.white .* (mod(x,2*dashLength)>=dashLength & abs(y)<2);
calib0(:,:,2) = calib0(:,:,2) + ds.white .* (abs(x)<2 & mod(y,2*dashLength)>=dashLength);

% additional lines visible in both eyes
calib0(:,:,2) = calib0(:,:,2) + ds.white .* (abs(y-pa.rmax_bg)<2); % horizontal line
calib0(:,:,2) = calib0(:,:,2) + ds.white .* (abs(y+pa.rmax_bg)<2); % horizontal line

calib0(:,:,2) = calib0(:,:,2) + ds.white .* (abs(x-pa.rmax_bg)<2); % horizontal line
calib0(:,:,2) = calib0(:,:,2) + ds.white .* (abs(x+pa.rmax_bg)<2); % horizontal line

% calib0(:,:,2) = ds.white .* (mod(x,20)>10 & ~y & ~x & mod(y,20)>10);
% calib0(:,:,2) = ds.white .* (~y & ~x);
% calib0(:,:,2) = ds.white .* (~x & mod(y,20)>10);

calib1 = ds.white .* x;
calib1((mod(x,2*dashLength)<dashLength) & abs(y)<2) = 0. * ds.white;
calib1(abs(x)<2 & (mod(y,2*dashLength)<dashLength)) = 1. * ds.white;

calib1(abs(y-pa.rmax_bg)<2) = 0. * ds.white; % additional line visible in both eyes
calib1(abs(y+pa.rmax_bg)<2) = 0. * ds.white; % additional line visible in both eyes

calib1(abs(x-pa.rmax_bg)<2) = 1. * ds.white; % additional line visible in both eyes
calib1(abs(x+pa.rmax_bg)<2) = 1. * ds.white; % additional line visible in both eyes

calib1(:,:,2) = ds.white .* ((mod(x,2*dashLength)<dashLength) & abs(y)<2);
calib1(:,:,2) = calib1(:,:,2) + ds.white .* (abs(x)<2 & (mod(y,2*dashLength)<dashLength));

% additional lines visible in both eyes
calib1(:,:,2) = calib1(:,:,2) + ds.white .* (abs(y-pa.rmax_bg)<2); % horizontal line
calib1(:,:,2) = calib1(:,:,2) + ds.white .* (abs(y+pa.rmax_bg)<2); % horizontal line

calib1(:,:,2) = calib1(:,:,2) + ds.white .* (abs(x-pa.rmax_bg)<2); % horizontal line
calib1(:,:,2) = calib1(:,:,2) + ds.white .* (abs(x+pa.rmax_bg)<2); % horizontal line

stimulus.leftCalibrationTexture = Screen('MakeTexture', display.windowPtr, round(calib0));
stimulus.rightCalibrationTexture = Screen('MakeTexture', display.windowPtr, round(calib1));

% call/load 'DrawTexture' prior to actual use (clears overhead)
%for ii = 0:display.stereoFlag        
        Screen('SelectStereoDrawBuffer', display.windowPtr, 0);
%         Screen('DrawTexture', display.windowPtr, stimulus(1).textures(1), ...
%             stimulus(1).srcRect, stimulus(1).destRect,2*(ii-.5)*display.screenRotation);
%         Screen('DrawTexture', display.windowPtr, stimulus.backgroundTexture, [], [], 2*(ii-.5)*display.screenRotation);
        drawBackground(display,stimulus, 0); % 1/f noise background
        
        Screen('SelectStereoDrawBuffer',display.windowPtr, 1);
        drawBackground(display, stimulus, 1);
%end

return
