mask=makecircle(538/3,538);
mask=logical(mask);
for n=1:5
    im=textureimages(538,[],48);
    im2=fliplr(textureimages(538,[],48));
    im3=im;
    im(mask)=im2(mask);
    mat2tif(im,sprintf('~/desktop/texture_%d.tif',n));
    im3(~mask) = 128;
    mat2tif(im3,sprintf('~/Desktop/circle_%d.tif',n));
end
