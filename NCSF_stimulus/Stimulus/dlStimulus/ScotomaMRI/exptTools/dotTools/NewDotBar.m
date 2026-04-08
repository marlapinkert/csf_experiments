function dots = NewDotBar(params, vbl)

ylim = params.barwidth./2;
xlim = params.radius;%.*params.pixperdeg;

%enoughSpace = 0;

% tic; % Put a timer on
% tcur = toc;

%pa.dotKillTime(1:pa.numberOfDots,1) = ((2*params.disparityLimit)/params.speed)*rand + vbl; % random 'kill' time in seconds for new set of dots between ds.vbl (0) and ds.vbl+maxtime (will be used to determine the z location)

%pa.distanceBeforeKill = params.speed*(params.dotKillTime-vbl); % how far the dot will travel in deg.


% dots(:,3) = ((2*params.disparityLimit)/params.speed)*rand(1:params.numberofdots,1) + vbl;%(params.maxdisparity*2)*rand(params.numberofdots,1) - params.maxdisparity; % z  (rand(params.numberofdots,1)*360)/360.*(2*pi);%
% dots(:,4) = params.speed*(dots(:,3)-vbl);%(2*pi)*rand(params.numberofdots,1)-pi;

for doti=1:size(dots,1)
    
    enoughSpace = 0;
    while ~enoughSpace %&& tcur<0.5 % Keep it under X s
        %
        
        
        dots(doti,1) = (xlim*2)*rand() - xlim;
        dots(doti,2) = (ylim*2)*rand() - ylim;
        
        %         dots(:,1) = dots(:,1) * cos(params.orientation) - dots(:,2) * sin(params.orientation);
        %         dots(:,2) = dots(:,2) * sin(params.orientation) + dots(:,1) * cos(params.orientation);
        
        % Check the spacing
%         mydist = (meshgrid(dots(:,1))'-meshgrid(dots(:,1))).^2 +...
%                  (meshgrid(dots(:,2))'-meshgrid(dots(:,2))).^2;
%         mydist = mydist + diag(NaN.*ones(1,doti));

        mydist = sqrt((dots(:,1)-dots(doti,1)).^2 + (dots(:,2)-dots(doti,2)).^2);
        mydist(doti) = params.dotspacing;
                
        if min(mydist(:)) >= params.dotspacing
            enoughSpace = 1;
        end
        
    end
    
    
    dots(doti,3) = ((2*params.disparityLimit)/params.speed)*rand + vbl;%(params.maxdisparity*2)*rand(params.numberofdots,1) - params.maxdisparity; % z  (rand(params.numberofdots,1)*360)/360.*(2*pi);%
    dots(doti,4) = params.speed*(dots(doti,3)-vbl);%(2*pi)*rand(params.numberofdots,1)-pi;
    

   % tcur = toc;
end

end