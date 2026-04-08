function im=gammaimage(im)

% set to double
im = single(im);

% scale between 0 and 1
%im = im./255;
im = im-min(im(:));
im = im./max(im(:));

% now scale to 0.01 resolution
x=fminsearch(@(x) submin(x,im),1);

im = im.^x;

return

function e=submin(x,im)
e = abs(round(100.*mean(im(:).^x))-50);
return