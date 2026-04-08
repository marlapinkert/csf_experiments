function [ds] = MakeBgTexture(ds,pa)

% 1/f noise texture to help anchor vergence
[x,y] = meshgrid(-ds.windowRect(3)/2:ds.windowRect(3)/2,-ds.windowRect(4)/2:ds.windowRect(4)/2);

noysSlope = 1.1;% bigger values --> less grainy?    1.0;
noys = oneoverf(noysSlope, size(x,1), size(x,2));
noys = ds.white.*noys; 

% Individual cutouts for each location
%  positions   = allcomb(unique(d2r(pa.aperturePosition(:,1))), unique(pa.aperturePosition(:,2).*ds.ppd));
%  [centerX, centerY]     = pol2cart(positions(:,1), positions(:,2));
%  centerY = -centerY;
 
%centerX = [ds.dstCenterL(1) ds.dstCenterR(1)];
%centerY = [ds.dstCenterL(2) ds.dstCenterR(2)];
noys(:,:,2) = ones(size(noys));

cheeseHoleLimit = max(pa.apertureRadius.*ds.ppd);

%for ii = 1:length(centerX)    
noys(:,:,2) = noys(:,:,2) & (sqrt((x).^2+(y).^2) > cheeseHoleLimit);% & (sqrt((x).^2+(y).^2) < (pa.fixationRadius*ds.ppd));    
noys(:,:,2) = noys(:,:,2) + (sqrt((x).^2+(y).^2) < (pa.fixationRadius*ds.ppd));
%end
% 
% arcX = (1.25*cheeseHoleLimit) * cos([pa.thetaLimits + deg2rad(2*[5 -5 5 -5])]);
% arcY = (1.25*cheeseHoleLimit) * sin([pa.thetaLimits + deg2rad(2*[5 -5 5 -5])]);
% 
% ds.xv = [arcX(1) 0 arcX(2) arcX(1) arcX(3) 0 arcX(4) arcX(3)];
% ds.yv = [arcY(1) 0 arcY(2) arcY(1) arcY(3) 0 arcY(4) arcY(3)];
% 
% in = inpolygon(x,y,ds.xv,ds.yv);
% 
% noys(:,:,2) = noys(:,:,2) + in;

%noys(:,:,2) = noys(:,:,2) & (sqrt(((0)-x).^2+((0)-y).^2) > (pa.fixationRadius*ds.ppd));    

noys(:,:,2) = noys(:,:,2) .* ds.white;
ds.bg=Screen('MakeTexture', ds.w, noys);

% fusionRect = CenterRect([0 0 2.1*pa.apertureRadius*ds.ppd 2.1*pa.apertureRadius*ds.ppd], ds.windowRect);
% ds.fusionRectL = OffsetRect(fusionRect, centerX(1), 0);
% ds.fusionRectR = OffsetRect(fusionRect, centerX(2), 0);

end