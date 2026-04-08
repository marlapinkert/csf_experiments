function selection=ResizeNaturalImages(selection)
% load('/Users/student/Documents/Martijn/retintopimg.mat','-mat');
% 
% disp(sprintf('[%s]:resizing images to 538x538.',mfilename));
% for i = 1:length(retinotopimg)
%     retinotopimg(i).image = single(imresize(mat2gray(retinotopimg(i).image,[0 255]),[540 540]));
% end
% 
% save('/Users/student/Documents/Martijn/retintopimg(538).mat','retinotopimg');
% naturalimg = [];

temp = [];

for i = 1:20
   tmpimage = selection(i).grayscale;
   tmpmask = selection(i).circlemask;
   
   [height,width] = size( tmpimage );
   
   [rows,cols] = find( tmpmask );
   
   if height > width
       tmpimage = rot90(tmpimage);
       
       [rows,cols] = find( rot90(tmpmask) );
       
       tmpimage = rot90( tmpimage( :, cols(1):cols(end) ), 3 );
   else
       tmpimage = tmpimage(:, cols(1):cols(end));
   end
       
   tmpimage = single(imresize(mat2gray(tmpimage),[538 538]));
   
   k = tmpimage;
   sz = 538;
   w = 48;
   
   win = makecircle(sz-2*w,sz,w);

   
%    % Linearize and normalize image for mean luminance
%     k = k-0.5;
%     % make window
%     % get weighted stats
%     s = wstat(k(:));
%     % center on mean window
%     k = k - s.mean;
%     % scale to max contrast
%     k = k./max(abs(k(win>0)));
%     % mask
%     k = k.*win;
%     % scale to 0-1
%     k = k./2+0.5;
%     %convert to uint8
%     k = uint8(k.*255);


%   %Power-based rescaling and normalization for mean luminance. Maintains
%   and maxamizes image range, while ensuring mean luminance
    k=gammaimage(k);
    k=k-0.5;
    k=k.*win;
    k=(k+0.5).*255;
    k=uint8(k);

   
    selection(i).image = k;
   
%    naturalimg(i).mask = single(imresize(mat2gray(tmpmask),[540 540]));
%    
%    tmpimage = naturalimg(i).image;
%    
%    meanDiff = 0.5 - mean( tmpimage(:) );
%    tmpimage = tmpimage + meanDiff;
%    
%    tmpimage = tmpimage - 0.5;
%    
%    factor = max( abs( tmpimage(:) ) );
%    tmpimage = tmpimage ./ factor .* 0.5;
%    
%    tmpimage = tmpimage .* naturalimg(i).mask;
%    tmpimage = tmpimage + 0.5;
%    
%   
%    naturalimg(i).image = tmpimage .* 255;
   
end
return

% save('','naturalimg');

% for i = 1:length(naturalimg)
%     figure;
%     
%     imagesc(naturalimg(i).image); colormap(gray);
% end


% main = 1;
% 
% for i=1:length(bgcontrast)
%     goodimg(main).image = bgcontrast(i).final;
%     goodimg(main).set = 'bgcontrast';
%     main = main + 1;
% end
% 
% for i=1:length(luminance)
%     goodimg(main).image = luminance(i).final;
%     goodimg(main).set = 'luminance';
%     main = main + 1;
% end
% 
% for i=1:length(other)
%     goodimg(main).image = other(i).final;
%     goodimg(main).set = 'other';
%     main = main + 1;
% end
% 
% for i=1:length(reflection)
%     goodimg(main).image = reflection(i).final;
%     goodimg(main).set = 'rlefection';
%     main = main + 1;
% end
% 
% for i=1:length(shadow)
%     goodimg(main).image = shadow(i).final;
%     goodimg(main).set = 'shadow';
%     main = main + 1;
% end
% 
% for i=1:length(texture)
%     goodimg(main).image = texture(i).final;
%     goodimg(main).set = 'texture';
%     main = main + 1;
% end
% 
% for i=1:length(textureshadow)
%     goodimg(main).image = textureshadow(i).final;
%     goodimg(main).set = 'textureshadow';
%     main = main + 1;
% end