function stimulus = createTexturesAttention(display, stimulus, removeImages);
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
if ~exist('removeImages','var'),      removeImages = 1;       end

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
    stimulus(stimNum).srcFixRect = [0,0,31,31];
	if ~isfield(display,'Rect'),
		stimulus(stimNum).destRect = CenterRect(stimulus(stimNum).srcRect, display.rect);
    else
		stimulus(stimNum).destRect = display.Rect;
	end;
    
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

	% clean up
	if removeImages==1
		stimulus(stimNum).images = [];
	end
end;

fixCRadAngle=0.125;
fixLRRadAngle=0.2;
fixCRadPix = 2*display.distance*tan(fixCRadAngle*pi/360)/display.pixelSize;
fixLRRadPix = 2*display.distance*tan(fixLRRadAngle*pi/360)/display.pixelSize;
sizeGludiskC = (fixCRadAngle+0.25);
sizeGludiskLR = (fixLRRadAngle+0.25);
% sizeGludiskC = (ceil((2*((fixCRadPix+6)/(539/11)))*100)/100);
% sizeGludiskLR = (ceil((2*((fixLRRadPix+6)/(539/11)))*100)/100);
midCoords = mean(reshape(stimulus.destRect,2,2),2);

%distFromEd = 0-sizeGludiskLR;%(ceil(((11/539)*(fixLRRadPix+6))*100)/100);
distFromCenter = round(539/2+(2*display.distance*tan(sizeGludiskLR*pi/360)/display.pixelSize)); %(((11/2)-distFromEd)*539/11);
stimulus.destFixRect1 = [midCoords(1)-(max(stimulus.srcFixRect-1))/2;midCoords(2)-(max(stimulus.srcFixRect-1))/2;midCoords(1)+(max(stimulus.srcFixRect-1))/2;midCoords(2)+(max(stimulus.srcFixRect-1))/2];
stimulus.destFixRect2 = stimulus.destFixRect1-[distFromCenter;0;distFromCenter;0];
stimulus.destFixRect3 = stimulus.destFixRect1+[distFromCenter;0;distFromCenter;0];
stimulus.distFromCenter = distFromCenter;
[x,y] = meshgrid(1:stimulus.srcFixRect(3), 1:stimulus.srcFixRect(4));
radimap       = sqrt(((x-((stimulus.srcFixRect(3)/2))).^2+(y-((stimulus.srcFixRect(4)/2))).^2));
qin1          = radimap<=fixCRadPix;
qin2          = radimap<=fixLRRadPix;
alphaMap=zeros(stimulus.srcFixRect(3), stimulus.srcFixRect(4));
alphaMap2=zeros(stimulus.srcFixRect(3), stimulus.srcFixRect(4));
alphaMap(qin1)=1;
alphaMap2(qin2)=1;

%These mask maps also add one pixel to the masked area to prevent edge
%pixels anti-aliasing from behind the mask on rotation
% qin3          = radimap<=fixCRadPix+1;
% qin4          = radimap<=fixLRRadPix+1;
% alphaMap3=zeros(stimulus.srcFixRect(3), stimulus.srcFixRect(4));
% alphaMap4=zeros(stimulus.srcFixRect(3), stimulus.srcFixRect(4));
% alphaMap3(qin3)=1;
% alphaMap4(qin4)=1;

Frame=zeros(stimulus.srcFixRect(3), stimulus.srcFixRect(4), 2);
stimulus.sizeGludiskLR = sizeGludiskLR;
stimulus.sizeGludiskC = sizeGludiskC;
nTRs=10;
for counter=1:nTRs
    for fix = 1:3;
        if fix ==1;
            Frame(:,:,2)=alphaMap;
            Frame(:,:,1)=zeros(stimulus.srcFixRect(3), stimulus.srcFixRect(4))+0.5;
            stimulus.alphaTexture=Screen('MakeTexture', display.windowPtr, Frame.*255);
            %Frame(:,:,2)=alphaMap;
        elseif fix ==2 || fix==3
            Frame(:,:,2)=alphaMap2;
            Frame(:,:,1)=zeros(stimulus.srcFixRect(3), stimulus.srcFixRect(4))+0.5;
            stimulus.alphaTexture2=Screen('MakeTexture', display.windowPtr, Frame.*255);
            %Frame(:,:,2)=alphaMap2;
        end
        Frame(:,:,1)=oneoverf(1,stimulus.srcFixRect(3), stimulus.srcFixRect(4));
        stimulus.fixationTexture(counter,fix)=Screen('MakeTexture', display.windowPtr, Frame.*255);
    end
end







% call/load 'DrawTexture' prior to actual use (clears overhead)
Screen('DrawTexture', display.windowPtr, stimulus(1).textures(1), ...
	stimulus(1).srcRect, stimulus(1).destRect);
Screen('DrawTexture', display.windowPtr, stimulus(1).textures(end), ...
	stimulus(1).srcRect, stimulus(1).destRect);

return
