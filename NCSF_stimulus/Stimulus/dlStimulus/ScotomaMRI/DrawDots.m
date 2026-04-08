function DrawDots(ds,pa)

    if strcmp(pa.experiment, 'Vertical motion')
        leftDots = [pa.dots(:,1) pa.dots(:,2) - pa.dots(:,3)] .* ds.ppd;
        rightDots = [pa.dots(:,1) pa.dots(:,2) + pa.dots(:,3)] .* ds.ppd;    
    else
        leftDots = [pa.dots(:,1) - pa.dots(:,3) pa.dots(:,2)] .* ds.ppd;
        rightDots = [pa.dots(:,1) + pa.dots(:,3) pa.dots(:,2)] .* ds.ppd;
    end

    leftDots(:,1) = (leftDots(:,1)) .* cos(-1*ds.screenRotationRadian) - (leftDots(:,2)).*sin(-1*ds.screenRotationRadian);
    leftDots(:,2) = (leftDots(:,1)) .* sin(-1*ds.screenRotationRadian) + (leftDots(:,2)).*cos(-1*ds.screenRotationRadian);
    
    rightDots(:,1) = (rightDots(:,1)) .* cos(ds.screenRotationRadian) - (rightDots(:,2)).*sin(ds.screenRotationRadian);
    rightDots(:,2) = (rightDots(:,1)) .* sin(ds.screenRotationRadian) + (rightDots(:,2)).*cos(ds.screenRotationRadian);

     if size(pa.dots,1) > pa.numberOfDots
         leftColors = pa.backgroundDotColors';
         
     else

        leftColors = pa.dotColors';
        
     end
    
     rightColors = leftColors;
    
    Screen('SelectStereoDrawBuffer',ds.windowPtr,0);
    Screen('DrawDots',ds.windowPtr,leftDots', pa.dotSize, leftColors*255, ds.dstCenter(1,:), 2);
    
    Screen('SelectStereoDrawBuffer',ds.windowPtr,1);
    Screen('DrawDots',ds.windowPtr,rightDots', pa.dotSize, rightColors*255, ds.dstCenter(2,:), 2);

end