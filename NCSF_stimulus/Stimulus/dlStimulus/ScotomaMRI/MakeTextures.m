function [ds,stimulus] = MakeTextures(pa,ds,stimulus)

% 1/f noise texture to help anchor vergence
%[x,y] = meshgrid(-ds.rect(3)/2:ds.rect(3)/2,-ds.rect(4)/2:ds.rect(4)/2);
%[x,y] = meshgrid(-ds.viewableRect(3):ds.viewableRect(3),-ds.viewableRect(4):ds.viewableRect(4));
[x,y] = meshgrid(-ds.numPixels(1):ds.numPixels(1),-ds.numPixels(1):ds.numPixels(1));

%for bgii =1:10

    noysSlope = 1.1;
    noys = oneoverf(noysSlope, size(x,1), size(x,2));
    noys = ds.white.*noys; 

    % Individual cutouts for each location
    positions   = allcomb(d2r(pa.bgThetaDirs), pa.bgRDirs.*ds.ppd);
    [centerX, centerY]     = pol2cart(positions(:,1), positions(:,2));
    centerY = -centerY;
    noys(:,:,2) = ones(size(noys));

    cheeseHoleLimit = 1*pa.apertureRadius * ds.ppd;

    for ii = 1:length(centerX)    
        noys(:,:,2) = noys(:,:,2) & (sqrt((centerX(ii)-x).^2+(centerY(ii)-y).^2) > cheeseHoleLimit);    
    end
    % 
    % noys(:,:,2) = noys(:,:,2) & (sqrt(x.^2+y.^2) < pa.rmax_bg);

    %noys(:,:,2) = noys(:,:,2) + (sqrt((x).^2+(y).^2) < (pa.fixationRadius*ds.ppd));

    noys(:,:,2) = noys(:,:,2) .* ds.white;


    %ds.bg(bgii)=Screen('MakeTexture', ds.w, noys);
    stimulus.backgroundTexture = Screen('MakeTexture', ds.windowPtr, noys);
    %ds.bg = Screen('MakeTexture', ds.windowPtr, noys);
%end

%ds.curBg = 1;

% ds.fixationCrosshairs = [ds.fixationCrosshairs ...
%                         [ds.fixationCrosshairs(1,:) + (max(pa.rDirs).*ds.ppd); ds.fixationCrosshairs(2,:)] ...
%                         [ds.fixationCrosshairs(1,:) - (max(pa.rDirs).*ds.ppd); ds.fixationCrosshairs(2,:)] ...
%                         [ds.fixationCrosshairs(1,:); ds.fixationCrosshairs(2,:) + (max(pa.rDirs).*ds.ppd)] ...
%                         [ds.fixationCrosshairs(1,:); ds.fixationCrosshairs(2,:) - (max(pa.rDirs).*ds.ppd)]];
% 
% ds.fixationCrosshairColors = repmat(ds.fixationCrosshairColors, 1, 5);

end



