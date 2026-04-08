function imout=filterimage(imagein,freqrange,paddfactor)
% filterimage - hard edge bandpass and orientation filter an image
%
% imout=filterimage(imagein,freqrange,paddfactor)
%
% 2010 SOD: wrote it.

padd=max(size(imagein))*paddfactor;
size(imagein)
% circular coords
[x,y]=meshgrid(-padd/2:padd/2-1);
[th,r]=cart2pol(x,y);

% scale r
r = r./(size(imagein,1).*paddfactor./2);
th = (th+pi)./(2.*pi).*360;

% scale input
meanf = mean(imagein(:));
fftimagein = fftshift( fft2(imagein-meanf,padd,padd) );
size(fftimagein)
%imout = zeros(size(imagein,1),size(imagein,1),size(freqrange,1));

% make filters
filt = ((r>=freqrange(1,1) & r<=freqrange(1,2)) & ...
    (th<=freqrange(2,2) | th>=360+freqrange(2,1))) | ...
    ((r>=freqrange(1,1) & r<=freqrange(1,2)) & ...
    (th<=180 - freqrange(2,1) & th>=180-freqrange(2,2)));

% filter
imouttmp = real(ifft2(ifftshift( fftimagein .*filt ),padd,padd))+meanf;
imout = imouttmp(1:size(imagein,1),1:size(imagein,2));

return