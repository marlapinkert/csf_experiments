function [scalefac,scalematrix,contrastout]=rmsscale(matrix,rms,range);
% RMSSCALE - scale image to rms-contrast
%  [scalefac,scalematrix]=rmsscale(matrix,rms,range);
%  default range [0 255]

if nargin < 2,
  help(mfilename);
  return;
end;
if nargin < 3 | isempty(range),
  range = [0 255];
end;

hrange=(range(2)-range(1))./2;
disc=imagestat(matrix, range);
out=matrix;
scalefac=1;
scalefac2=0;

while round((disc.contrast.rms-rms).*1000)~=0,
  scalefac2=disc.contrast.rms.\rms;
  scalefac=scalefac.*scalefac2;
  
  meanmatrix=mean(matrix(:));
  out = (matrix-meanmatrix).*scalefac+meanmatrix;
  out((out>range(2)))=range(2);
  out((out<range(1)))=range(1);
  disc=imagestat(out,range);
  contrastout=disc.contrast;
end;
if min(out(:))<=range(1) || max(out(:))>=range(2)
    fprintf('\n[%s]: Warning: Clipping may have occured\n', mfilename)
end
scalematrix=out;
 
  
