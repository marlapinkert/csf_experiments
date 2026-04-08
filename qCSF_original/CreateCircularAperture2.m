function [patch] = CreateCircularAperture2(siz,sizRaisedSin,pwrRaisedSin,imgSiz)

if nargin < 4 || isempty(imgSiz)
    imgSiz = siz.*1.2;
end
if nargin < 3 || isempty(siz)
    error('Not enough input arguments.');
end

[x,y] = meshgrid((1:imgSiz)-(imgSiz+1)/2);
[~,r] = cart2pol(x,y);
patch  = double(r <= siz/2);

sinFilter = sin(linspace(0,pi,sizRaisedSin)).^pwrRaisedSin;
sinFilter = sinFilter'*sinFilter;
sinFilter = sinFilter/sum(sinFilter(:));

patch = conv2(patch, sinFilter,'same');

% Idx_1 = abs(patch-1) <= 10^-2;
% Idx_r = r(Idx_1);
% full_objsiz = 2*max(Idx_r(:));
% imagesc(patch);

end
