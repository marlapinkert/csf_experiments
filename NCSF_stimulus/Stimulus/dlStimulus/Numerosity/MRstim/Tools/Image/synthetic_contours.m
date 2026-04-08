function im=synthetic_contours(sizeInPix,sizeInDeg,contourWidthInDeg,orientationInDeg,orientationBPinDeg,circularWindow,region)
% im = synthetic_contours(sizeInPix,sizeInDeg,contourWidthInDeg,orientationBPinDeg,region);
%
% make black-white contours
%
% 2009/10 SOD: wrote it.

% revert to single precision

% input handling
if ~exist('sizeInPix','var') || isempty(sizeInPix) 
    sizeInPix = 600;
end
if ~exist('sizeInDeg','var') || isempty(sizeInDeg) 
    sizeInDeg = 12.5;
end
if ~exist('contourWidthInDeg','var') || isempty(contourWidthInDeg) 
    contourWidthInDeg = 1/3; % 3 cycles per degree
end
if ~exist('orientationBPinDeg','var') || isempty(orientationBPinDeg) 
    orientationBPinDeg = 30;
end
if ~exist('orientationInDeg','var') || isempty(orientationInDeg) 
    orientationInDeg = 0;
end
if ~exist('circularWindow','var') || isempty(circularWindow) 
    circularWindow=1;
end
if ~exist('region','var') || isempty(region)
    region = [];
end
% if orientationInDeg>360
%     orientationInDeg=orientationInDeg-360;
% end

% derived parameters
contourWidthInPix = round(contourWidthInDeg ./ sizeInDeg.*sizeInPix);

% make image larger to prevent edge effects
sizeInPix=sizeInPix+contourWidthInPix*2;
sizeInDeg=sizeInDeg+contourWidthInDeg*2;

% make orientation and bandpass filter 
oriFilter = [0 (1./(sizeInPix./2).*((1/contourWidthInDeg*sizeInDeg)));...
            [-1 1].*orientationBPinDeg./2];
        
% random image from 0-1
imr = rand(sizeInPix,'single');
imr = imr-mean(imr(:));

% filter image
[im grid] = filterimagecontours(imr,single(oriFilter),single(1),[],orientationInDeg);

% different filter inside region
if ~isempty(region)
    % rotate region
    rmask = region.mask;%imrotate(region.mask,-1*orientationInDeg,'bilinear','crop');
    
    % make second filter
    oriFilter2 = [0 (1./(sizeInPix./2).*((1/contourWidthInDeg*sizeInDeg)));...
                 [-1 1].*region.orientationBPinDeg./3];
    % and filter
    im2 = filterimagecontours(imr,single(oriFilter2),single(1),grid,orientationInDeg);
    % grow mask region appropriately
    mask2 = zeros(sizeInPix);
    mask2(contourWidthInPix+1:end-contourWidthInPix, contourWidthInPix+1:end-contourWidthInPix) = rmask;
    % blend
    im  = im.*(1-mask2) + im2.*mask2;
end

% binary
im = sign(im);


% create edge mask
mask = filter2(single(makecircle(single(contourWidthInPix))),single(im));
mask = mask~=min(mask(:)) & mask~=max(mask(:));

% mask out edges
im = im.*mask;

% crop out actual image
im = im(1+contourWidthInPix:sizeInPix-contourWidthInPix,1+contourWidthInPix:sizeInPix-contourWidthInPix);


% place in circular window with faded edge
if circularWindow
    % create soft circular mask
    mask = makecircle(size(im,1)-contourWidthInPix.*2,size(im,1),contourWidthInPix);

    im = im.*mask;
end
% rotate
%im = imrotate(im,orientationInDeg,'nearest','crop');

if ~nargout
    disp(imagestat(im,[-1 1],mask==1));
    figure;imagesc(im);colormap(gray);axis image off;
end

return


function [imout grid]=filterimagecontours(imagein,freqrange,paddfactor,grid,orientationInDeg)
% filterimage - hard edge bandpass and orientation filter an image
%
% imout=filterimage(imagein,freqrange,paddfactor)
%


padd=max(size(imagein))*paddfactor;

if isempty(grid)
    % circular coords
    [x,y]=meshgrid(-padd/2:padd/2-1);
    [grid.th,grid.r]=cart2pol(x,y);
    
    % scale r (keep 3 factor for compatibility with previous stimuli
    grid.r = grid.r./(size(imagein,1)./3.*paddfactor./2);
    grid.th = (grid.th+pi)./(2.*pi).*360;
    grid.th = grid.th+orientationInDeg;
    grid.th(grid.th>360)=grid.th(grid.th>360)-360;
    grid.th(grid.th<0)=grid.th(grid.th<00)+360;
    
    
    % scale input
    grid.fftimagein = fftshift( fft2(imagein,padd,padd) );
    grid.filt1 = grid.r>=freqrange(1,1) & grid.r<=freqrange(1,2);
end

% make filters
filt2 = (grid.th<=freqrange(2,2) | grid.th>=360+freqrange(2,1)) | ...
    (grid.th<=180 - freqrange(2,1) & grid.th>=180-freqrange(2,2));
filt = grid.filt1.*filt2;

% filter
imouttmp = real(ifft2(ifftshift( grid.fftimagein .*filt ),padd,padd));
imout = imouttmp(1:size(imagein,1),1:size(imagein,2));

return


