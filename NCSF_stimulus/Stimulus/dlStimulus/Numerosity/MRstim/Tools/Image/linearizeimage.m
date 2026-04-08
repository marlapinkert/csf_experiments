function im=linearizeimage(im,mask)
% linearizeimage - set mean to 128 (0.5)
%
%
% 2011 SOD: wrote it.

if ~exist('im','var') || isempty(im)
    error('Need image');
end
if ~exist('mask','var') || isempty(mask)
    mask = ones(size(im));
end

imorg = im;

im=double(im);
im=im-min(im(:));
im=im./max(im(:));
if max(im(:))>1
    im = double(im)./255;
end

exponent = fminsearch(@(x) myerrorfunction(x,im,mask),1);

im = im.^exponent;

%if ~nargout
    figure;    imagesc(imorg);colormap(gray);axis image off; colorbar;
    figure;    imagesc(im);   colormap(gray);axis image off; colorbar;
%end

return

function e=myerrorfunction(ex,im,mask)
im = im(:).^ex;
e = sum(im.*mask(:))./sum(mask(:));
e = abs(e-0.5);
return