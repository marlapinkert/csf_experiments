function params = NewDotBarUpdated(params, vbl, idot)

ylim = params.barwidth./2;
xlim = params.radius;%.*params.pixperdeg;

%enoughSpace = 0;

% tic; % Put a timer on
% tcur = toc;

%pa.dotKillTime(1:pa.numberOfDots,1) = ((2*params.disparityLimit)/params.speed)*rand + vbl; % random 'kill' time in seconds for new set of dots between ds.vbl (0) and ds.vbl+maxtime (will be used to determine the z location)

%pa.distanceBeforeKill = params.speed*(params.dotKillTime-vbl); % how far the dot will travel in deg.


% dots(:,3) = ((2*params.disparityLimit)/params.speed)*rand(1:params.numberofdots,1) + vbl;%(params.maxdisparity*2)*rand(params.numberofdots,1) - params.maxdisparity; % z  (rand(params.numberofdots,1)*360)/360.*(2*pi);%
% dots(:,4) = params.speed*(dots(:,3)-vbl);%(2*pi)*rand(params.numberofdots,1)-pi;

for d=1:length(idot)
    
    enoughSpace = 0;
    while ~enoughSpace %&& tcur<0.5 % Keep it under X s
        %
        
        
        params.dots(idot(d),1) = (xlim*2)*rand() - xlim;
        params.dots(idot(d),2) = (ylim*2)*rand() - ylim;
        
        %         dots(:,1) = dots(:,1) * cos(params.orientation) - dots(:,2) * sin(params.orientation);
        %         dots(:,2) = dots(:,2) * sin(params.orientation) + dots(:,1) * cos(params.orientation);
        
        % Check the spacing
%         mydist = (meshgrid(dots(:,1))'-meshgrid(dots(:,1))).^2 +...
%                  (meshgrid(dots(:,2))'-meshgrid(dots(:,2))).^2;
%         mydist = mydist + diag(NaN.*ones(1,idot(d)));

        mydist = sqrt((params.dots(:,1)-params.dots(idot(d),1)).^2 + (params.dots(:,2)-params.dots(idot(d),2)).^2);
        mydist(idot(d)) = params.dotspacing;
                
        if min(mydist(:)) >= params.dotspacing
            enoughSpace = 1;
        end
        
    end
    
    % Assign the motion direction of the dot
    params.dots(idot(d),4) = params.direction;
    
    if length(idot)==1
    
        %params.dots(idot(d),4) = params.direction*-1;
        
        params.dotKillTime(idot(d)) = ((2*params.maxdisparity)/params.speed) + params.dotKillTime(idot(d)); % + ds.vbl;  %
        params.distanceBeforeKill(idot(d)) = params.speed*(params.dotKillTime(idot(d))-vbl);
        
        
    end
    
    params.dots(idot(d),3) = -params.direction * (params.distanceBeforeKill(idot(d)) - params.maxdisparity); % basically mimics to former disparity-dependent code with 'overage' by putting the dots either around -0.15 or around +0.15 (the limits), at the opposite side of fixation given motion direction



   % tcur = toc;
end

end