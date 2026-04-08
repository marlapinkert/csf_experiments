function [imdesc]=imagestat(anyimage,imrange,mask);
% IMAGESTAT - general image statistics
% [imdesc]=imagestat(image,imrange,mask);
%  Calculate various image statistics, 
%   including: mean, max, min, median,
%              contrast (michelson, rms), 
%              kurtosis, skewness

% 2004 SOD: wrote it.

if nargin < 2 | isempty(imrange),
  imrange = [0 255];
end;
lr=max(imrange)-min(imrange);

if nargin < 3,
  mask = [];
end;
if ~isempty(mask),
  ii = find(mask > 0.5);
else,
  ii = ':';
end;

if isempty(ii),
  disp(sprintf('No values in mask'));
  imdesc = [];
  return;
end;
 
anyimage = double(anyimage);
tmpimage = anyimage(ii);

imdesc.name               = inputname(1);
imdesc.size               = size(anyimage);
imdesc.npixels            = length(tmpimage);
imdesc.mean               = mean(tmpimage);
imdesc.median             = median(tmpimage);
imdesc.max                = max(tmpimage);
imdesc.min                = min(tmpimage);
%imdesc.kurtosis           = kurtosis(tmpimage);
%imdesc.skewness           = skewness(tmpimage);
imdesc.contrast.michelson = (imdesc.max-imdesc.min)./lr.*100;
imdesc.contrast.rms       = sqrt(sum(((tmpimage./lr-imdesc.mean./lr).^2))...
                                 ./imdesc.npixels).*100;
imdesc.histogram.bins     = [floor(imdesc.min):ceil(imdesc.max)]';
imdesc.histogram.values   = hist(tmpimage,imdesc.histogram.bins)';
imdesc.entropy            = -sum(imdesc.histogram.values.*...
                                 log(imdesc.histogram.values));
