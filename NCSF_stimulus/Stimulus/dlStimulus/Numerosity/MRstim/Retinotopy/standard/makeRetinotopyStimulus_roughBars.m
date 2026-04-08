function [stimulus params] = makeRetinotopyStimulus_roughBars(params)

params.ncycles = 1;
params.stimrep = 6; % 5

% various time measurements:
duration.stimframe          = 1./params.temporal.frequency;
duration.scan.seconds       = params.ncycles*params.period;
duration.scan.stimframes    = params.ncycles*params.period./duration.stimframe;
duration.cycle.seconds      = params.period;
duration.cycle.stimframes   = params.period./duration.stimframe;
duration.prescan.seconds    = params.prescanDuration;
duration.prescan.stimframes = params.prescanDuration./duration.stimframe;


fixMov = -max(params.fixationCentres(:));

% x,y degrees and torsion in radians of the subjects eye-movements.
eyeMov = [30 10 20./180*pi]./2; % maximal, most conservative, no overlap
eyeMov = [20 10 20./180*pi]./2; % less conservative, mostly no overlap
%eyeMov = [15 7.5 20./180*pi]./2; % least conservative, definitive overlap

%--- based on distributions previous scanner eyemovements: 
%    sd(x) = [3.66 4.07 6.32] ~-> 5   : fwhm = 12 : 95% = 20
%    sd(y) = [1.12 1.32 2.91] ~-> 2.5 : fwhm =  6 : 95% = 10
eyeMov = [10 5 10./180*pi];

% make 6 images
sSize.pix = fliplr(params.display.numPixels);
sSize.deg = pix2angle(params.display,sSize.pix);
[X Y] = meshgrid(linspace(-sSize.deg(2)./2,sSize.deg(2)./2,sSize.pix(2)),...
                 linspace(-sSize.deg(1)./2,sSize.deg(1)./2,sSize.pix(1)));

% checks (0.25cyc/deg
cpd = 0.2; % cycles/degree
checks(:,:,1)=sign(sin(Y*(2*pi*cpd))).*sign(sin(X*(2*pi*cpd)));
checks(:,:,2)=-1.*checks(:,:,1);
% now make all images
images=zeros(sSize.pix(1),sSize.pix(2),29);
imii  = 1;

%--- fix: left up 
X2 = X-fixMov;
Y2 = Y-fixMov;
% stim: right   {{ 1 2 }}
X3 = X2 - eyeMov(1);
Y3 = Y2;
t  = atan2 (Y3, X3);
mask = t>=-pi/2+eyeMov(3) & t<=pi/2-eyeMov(3);
for n=1:2,
    images(:,:,imii) = checks(:,:,n).*(mask);
    imii=imii+1;
end

% stim: bottom    {{ 3 4 }}
X3 = X2;
Y3 = Y2 - eyeMov(2);
t  = atan2 (Y3, X3);
mask = t>=0+eyeMov(3) & t<=pi-eyeMov(3);
for n=1:2,
    images(:,:,imii) = checks(:,:,n).*(mask);
    imii=imii+1;
end


%-- fix: right up  {{ 5 6 }}
X2 = X+fixMov;
Y2 = Y-fixMov;
% stim: left
X3 = X2 + eyeMov(1);
Y3 = Y2;
t  = atan2 (Y3, X3);
mask = t<=-pi/2-eyeMov(3) | t>=pi/2+eyeMov(3);
for n=1:2,
    images(:,:,imii) = checks(:,:,n).*(mask);
    imii=imii+1;
end
% stim: bottom   {{ 7 8 }}
X3 = X2;
Y3 = Y2 - eyeMov(2);
t  = atan2 (Y3, X3);
mask = t>=0+eyeMov(3) & t<=pi-eyeMov(3);
for n=1:2,
    images(:,:,imii) = checks(:,:,n).*(mask);
    imii=imii+1;
end


%--- fix: center  {{ 9 10 }}
X2 = X;
Y2 = Y;
% vertical
mask = abs(X2)<=eyeMov(1)./2;
for n=1:2,
    images(:,:,imii) = checks(:,:,n).*(mask);
    imii=imii+1;
end
% horizontal      {{ 11 12 }}
mask = abs(Y2)<=eyeMov(2)./2;
for n=1:2,
    images(:,:,imii) = checks(:,:,n).*(mask);
    imii=imii+1;
end


%--- fix: left down   
X2 = X-fixMov;
Y2 = Y+fixMov;
% stim: right       {{ 13 14 }}
X3 = X2 - eyeMov(1);
Y3 = Y2;
t  = atan2 (Y3, X3);
mask = t>=-pi/2+eyeMov(3) & t<=pi/2-eyeMov(3);
for n=1:2,
    images(:,:,imii) = checks(:,:,n).*(mask);
    imii=imii+1;
end
% stim: top         {{ 15 16 }}
X3 = X2;
Y3 = Y2 + eyeMov(2);
t  = atan2 (Y3, X3);
mask = t>=-pi+eyeMov(3) & t<=0-eyeMov(3);
for n=1:2,
    images(:,:,imii) = checks(:,:,n).*(mask);
    imii=imii+1;
end


%-- fix: right down
X2 = X+fixMov;
Y2 = Y+fixMov;
% stim: left      {{ 17 18 }}
X3 = X2 + eyeMov(1);
Y3 = Y2;
t  = atan2 (Y3, X3);
mask = t<=-pi/2-eyeMov(3) | t>=pi/2+eyeMov(3);
for n=1:2,
    images(:,:,imii) = checks(:,:,n).*(mask);
    imii=imii+1;
end
% stim: top      {{ 19 20 }}
X3 = X2;
Y3 = Y2 + eyeMov(2);
t  = atan2 (Y3, X3);
mask = t>=-pi+eyeMov(3) & t<=0-eyeMov(3);
for n=1:2,
    images(:,:,imii) = checks(:,:,n).*(mask);
    imii=imii+1;
end


%--- fix: center sidebars
X2 = X;
Y2 = Y;
% vertical right  {{ 21 22 }}
mask = X2>=eyeMov(1)./2 & X2<=eyeMov(1).*1.5;
for n=1:2,
    images(:,:,imii) = checks(:,:,n).*(mask);
    imii=imii+1;
end
% vertical left    {{ 23 24 }}
mask = X2<=-eyeMov(1)./2 & X2>=-eyeMov(1).*1.5;
for n=1:2,
    images(:,:,imii) = checks(:,:,n).*(mask);
    imii=imii+1;
end


% horizontal top  {{ 25 26 }}
mask = Y2>=eyeMov(2)./2 & Y2<=eyeMov(2).*1.5;
for n=1:2,
    images(:,:,imii) = checks(:,:,n).*(mask);
    imii=imii+1;
end
% horizontal bottom  {{ 27 28 }}
mask = Y2<=-eyeMov(2)./2 & Y2>=-eyeMov(2).*1.5;
for n=1:2,
    images(:,:,imii) = checks(:,:,n).*(mask);
    imii=imii+1;
end



images = uint8((images+1).*255./2);

% make balanced sequence
lr = [23:24  9:10 21:22];
td = [27:28 11:12 25:26];
fix  = [29,29];
sequence = [1,2 fliplr(lr) 5,6 fix 7,8 fliplr(td) 19,20 fix 17,18 lr 13,14 fix 15,16 td 3,4 fix];


fixseq   = ceil(sequence./4);

% make stimulus sequence for each temporal frame
sequence = reshape(sequence,2,numel(sequence)./2)';% pair up (flicker)
sequence(:,3:params.framePeriod.*params.temporal.frequency) = size(images,3); % add blank periods
sequence = repmat(sequence,1,params.stimrep);      % n stimulus presentations per block
sequence = sequence';
sequence = sequence(:); % final sequence
sequence = repmat(sequence,params.ncycles,1);

% similar for fixation sequence
fixseq = reshape(fixseq,2,numel(fixseq)./2)';% pair up
fixseq = fixseq(:,1);
fixseq = repmat(fixseq,1,params.framePeriod.*params.temporal.frequency.*params.stimrep);
fixseq = fixseq';
fixseq = fixseq(:);
fixseq = repmat(fixseq,params.ncycles,1);

% later bars are with central fixation
fixseq(fixseq==6 | fixseq==7) = 3;

% fill in fixseq with nearest 
while sum(fixseq==8),
    a = diff(fixseq==8);
    ii=find(a==1);
    fixseq(ii+1)= fixseq(ii);
    ii=find(a==-1);
    fixseq(ii) = fixseq(ii+1);
end 


% reset stimulus period
params.period  = numel(sequence)./params.temporal.frequency;
fprintf(1,'[%s]:resetting ncycles(%d) and stimulus period (%.2fsec).\n',...
    mfilename,params.ncycles,params.period);

retParamsCheck(params);



% Insert the preappend images by copying some images from the
% end of the seq and tacking them on at the beginning
sequence = [sequence(length(sequence)+1-duration.prescan.stimframes:end); sequence];
fixseq   = [fixseq(length(fixseq)+1-duration.prescan.stimframes:end); fixseq];
% move fixseq forward by 1 sec
nsteps = 1/duration.stimframe;
fixseq(1:end-nsteps)=fixseq(nsteps+1:end);

timing   = [0:length(sequence)-1]'.*duration.stimframe;
cmap     = params.display.gammaTable;

% reset fixation parameters
params.fixation = 'large cross';
params.display.fixType = params.fixation;
params.display.fixColorRgb    = [255 255 0 255;...
    255 255 0 255];
params.display.fixSizePixels  = 10;
dim.x = params.display.numPixels(1);
dim.y = params.display.numPixels(2);
dim.ycoord = [1:dim.y dim.y:-1:1] ; % assume ydim is smallest
dim.xcoord = [1:dim.y 1:dim.y] + round(-dim.y/2+dim.x/2);
params.display.fixCoords{3} = [dim.xcoord;dim.ycoord];
% convert fixMov to pixels
fixMov = angle2pix(params.display,abs(fixMov));
tmp = params.display.fixCoords{3};
tmp(1,:) = tmp(1,:)-fixMov;
tmp(2,:) = tmp(2,:)-fixMov;
keep = min(sign(tmp))>0;
params.display.fixCoords{1} = tmp(:,keep);
tmp = params.display.fixCoords{3};
tmp(1,:) = tmp(1,:)+fixMov;
tmp(2,:) = tmp(2,:)-fixMov;
keep = min(sign(tmp))>0;
params.display.fixCoords{2} = tmp(:,keep);
tmp = params.display.fixCoords{3};
tmp(1,:) = tmp(1,:)-fixMov;
tmp(2,:) = tmp(2,:)+fixMov;
keep = min(sign(tmp))>0;
params.display.fixCoords{4} = tmp(:,keep);
tmp = params.display.fixCoords{3}; 
tmp(1,:) = tmp(1,:)+fixMov;
tmp(2,:) = tmp(2,:)+fixMov;
keep = min(sign(tmp))>0;
params.display.fixCoords{5} = tmp(:,keep);

% simulate nystagmus with second fixation dot
params.display.simnys.do = false;
%sdxy = [3.4 1.1];
%sdxy = [3.7 1.3];
sdxy = [6.0 2.8];

% add for controls (worst case scenerio.
sdxy = sdxy + 0.25;


% make sequence on x -+15deg at 4Hz
npoints = numel(timing);
ntime   = timing(end);
xtime   = linspace(timing(1),timing(end),ntime*4); % 4Hz
xeye    = (randn(size(xtime))).*angle2pix(params.display,sdxy(1));%30
params.display.simnys.x = interp1(xtime,xeye,timing,'spline',0)+params.display.numPixels(1)/2;
% make sequence on y -+5deg at 2Hz
xtime   = linspace(timing(1),timing(end),ntime*2); % 2Hz
xeye    = (randn(size(xtime))).*angle2pix(params.display,sdxy(2));%10
params.display.simnys.y = interp1(xtime,xeye,timing,'spline',0)+params.display.numPixels(2)/2;
params.display.simnys.size = 5;

for n=[1 2 4 5];    
    ii = fixseq==n;
    offsetx=0;offsety=0;
    if n==1,
        offsetx = -fixMov;
        offsety = -fixMov;
    elseif n==2,
        offsetx = +fixMov;
        offsety = -fixMov;
    elseif n==4,
        offsetx = -fixMov;
        offsety = +fixMov;
    elseif n==5,
        offsetx = +fixMov;
        offsety = +fixMov;
    end
    params.display.simnys.x(ii) = params.display.simnys.x(ii)+offsetx;
    params.display.simnys.y(ii) = params.display.simnys.y(ii)+offsety;
end    


% make stimulus structure for output
stimulus = createStimulusStruct(images,cmap,sequence,[],timing,fixseq);

return
