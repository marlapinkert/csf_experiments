function [stimulus] = makePsychophysicsStimulusMotion(params)
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
duration.stimframe          = 1./params.temporal.frequency(1)./params.temporal.motionSteps(1);
duration.scan.seconds       = params.ncycles*params.period;
duration.scan.stimframes    = params.ncycles*params.period./duration.stimframe;
duration.cycle.seconds      = params.period;
duration.cycle.stimframes   = params.period./duration.stimframe;
duration.prescan.seconds    = params.prescanDuration;
duration.prescan.stimframes = params.prescanDuration./duration.stimframe;

blanksAfterPass=1;  %1 (True) puts blanks after horizontal bars have passed. 0 (false) puts blanks within the bar pass
blankTime=30;       %Blank time (in seconds) will be rounded up to the nearest TR

sineChecks=1;
softEdgeWindow=1;

outerRad = params.radius;
innerRad = params.innerRad;
wedgeWidth = params.wedgeWidth;
ringWidth = params.ringWidth;

%halfNumImages = numBarImages./2;
%numMotSteps = params.temporal.motionSteps;
numSubRings = params.numSubRings;
%numSubWedges = params.numSubWedges;

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
[x,y]=meshgrid(linspace(-outerRad,outerRad,n),linspace(outerRad,-outerRad,m));

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
orientation = pi/2;

original_x   = x;
original_y   = y;
% step size of the bar
%step_nx      = barPassTime./params.tr/8;
%step_x       = (2*outerRad) ./ step_nx;
%step_startx  = (step_nx-1)./2.*-step_x - (ringWidth./2);
%[0:step_nx-1].*step_x+step_startx+ringWidth./2
%disp(sprintf('[%s]:stepsize: %f degrees.',mfilename,step_x));

x = original_x .* cos(orientation) - original_y .* sin(orientation);
y = original_x .* sin(orientation) + original_y .* cos(orientation);

% Loop that creates the final images
fprintf('[%s]:Creating %d images:',length(params.temporal.motionSteps));
images=zeros(m,n,max(params.temporal.motionSteps)*length(params.temporal.motionSteps),'uint8');
                
loX   = -4.0263;%loX + step_x;
hiX   = loX + ringWidth;
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
fadedWindow=tmpvar;


for imgNum=1:length(params.temporal.motionSteps);

        %wedges    = sign(round((cos((y+step_startx)*numSubRings*(2*pi/ringWidth)))./2+.5).*2-1);
        rings     = zeros(size(y));
        
        checks    = zeros(size(rings,1),size(rings,2),max(params.temporal.motionSteps));
        for ii=1:params.temporal.motionSteps(imgNum),
            if sineChecks==1
                rings = (((cos(y*numSubRings*(2*pi/ringWidth)+(ii-1)/params.temporal.motionSteps(imgNum)*2*pi)+1)/2));
            end
            

            checks(:,:,ii)=(fliplr(rings'));%minCmapVal+ceil((maxCmapVal-minCmapVal) * (fliplr(rings')));

            
        end;
        if isfield(params, 'contrast')
            checks=((checks-0.5).*params.contrast)+0.5;
        end
        
    img = zeros(size(tmpvar,1),size(tmpvar,2),size(checks,3));
    for jj=1:size(checks,3)
        img(:,:,jj)=minCmapVal+ceil((maxCmapVal-minCmapVal) * (((checks(:,:,jj)-0.5).*(fadedWindow))+0.5));
        
    end
    
    
    images(:,:,(imgNum-1)*max(params.temporal.motionSteps)+1:imgNum*max(params.temporal.motionSteps)) = uint8(img);
    
    
    
    fprintf('.');drawnow;
end
fprintf('Done.\n');

images(:,:,size(images,3)+1)   = uint8(ones(size(images,1),size(images,2)).*bk);


cmap     = params.display.gammaTable;


% make stimulus structure for output
stimulus = createStimulusStruct(images,cmap,[],[],[],[]);

% save matrix if requested
if ~isempty(params.saveMatrix),
    save(params.saveMatrix,'images');
end;
end

