function [pa] = NewBGDots(ds,pa,idot)

for d=1:length(idot)
    
    enoughSpace = 0;
    
    % Assign the x and y dot positions
    while ~enoughSpace
                
            actFixationRadius = 0;
            actApertureRadius = pa.backgroundApertureRadius-2*(pa.disparityLimit+2*pa.dotSizeDeg);

        
        %actApertureRadius = pa.apertureRadius-2*(pa.disparityLimit+pa.dotSizeDeg);
        r = (actApertureRadius - actFixationRadius)*sqrt(rand) + actFixationRadius;
        
        theta = 2*pi*rand();
        
        % new random x and y
        pa.dots(idot(d),1) = r.*cos(theta);
        pa.dots(idot(d),2) = r.*sin(theta);
        
        % check spacing relative to the other dots
        mydist = sqrt((pa.dots(:,1) - pa.dots(idot(d),1)).^2 + (pa.dots(:,2) - pa.dots(idot(d),2)).^2);
        mydist(idot(d)) = pa.dotSpacing;                
        
        if (min(mydist(:)) >= pa.dotSpacing)
            enoughSpace = 1;
        end
        
    end
    
    
    % When updating a single dot, update its kill time too
    if length(idot)==1
        pa.dotKillTime(idot(d)) = ((2*pa.disparityLimit)/pa.speed) + pa.dotKillTime(idot(d)); % + ds.vbl;  %
        pa.distanceBeforeKill(idot(d)) = pa.speed*(pa.dotKillTime(idot(d))-ds.vbl);
    end
    
    % Assign z position based on kill time
    pa.dots(idot(d),3) = -pa.directions(pa.trial(3)) * (pa.distanceBeforeKill(idot(d)) - pa.disparityLimit); % basically mimics to former disparity-dependent code with 'overage' by putting the dots either around -0.15 or around +0.15 (the limits), at the opposite side of fixation given motion direction

    
    % Assign the motion direction of the dot
    pa.dots(idot(d),4) = pa.directions(pa.trial(3));
end

end