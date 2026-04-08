function [stimdots, BGdots] = precomputeDotPositions(dotparams, stimulus)

BGdots = [];
BGdotColors = [];


%dispStringInCenter(params.display,'Generating dot positions...',0.3,[],'white');
%disp(['Pre-generating dot positions...']);

for orii = 1:length(stimulus.orientations)
    for stepii = 1:length(dotparams.step_x)
        
        stimdots{orii}{stepii} = NewDotBar(dotparams);
        if params.dots.bgNoise
            
            BGdots{orii}{stepii}(:,1) = (dotparams.radius*2)*rand(dotparams.numberofbgdots,1) - dotparams.radius; % x
            BGdots{orii}{stepii}(:,2) = (dotparams.radius*2)*rand(dotparams.numberofbgdots,1) - dotparams.radius; % y
            BGdots{orii}{stepii}(:,3) = (rand(dotparams.numberofbgdots,1)*360)/360.*(2*pi);   % motion dir
            BGdots{orii}{stepii}(:,4) = (2*pi)*rand(dotparams.numberofbgdots,1); % random phase
            
            
            t1 = tic;
            tcur = toc(t1);
            
            for doti = 1:size(BGdots{orii}{stepii},1)
                enoughSpace = 0;
                while ~enoughSpace && tcur<0.1 % Keep it under X s

                    BGdots{orii}{stepii}(doti,1) = (dotparams.radius*2)*rand() - dotparams.radius;
                    BGdots{orii}{stepii}(doti,2) = (dotparams.radius*2)*rand() - dotparams.radius;

                    %         dots(:,1) = dots(:,1) * cos(params.orientation) - dots(:,2) * sin(params.orientation);
                    %         dots(:,2) = dots(:,2) * sin(params.orientation) + dots(:,1) * cos(params.orientation);

                    % Check the spacing
                    mydist = (meshgrid(BGdots{orii}{stepii}(:,1))'-meshgrid(BGdots{orii}{stepii}(:,1))).^2 +...
                             (meshgrid(BGdots{orii}{stepii}(:,2))'-meshgrid(BGdots{orii}{stepii}(:,2))).^2;
                    mydist = mydist + diag(NaN.*ones(1,dotparams.numberofbgdots));

                    if min(mydist(:)) >= dotparams.dotspacing
                        enoughSpace = 1;
                    end

                    tcur = toc(t1);
                end
            end
            BGdotColors = Shuffle([zeros(round((dotparams.numberofbgdots)./2),1); 255.*ones(round((dotparams.numberofbgdots)./2),1)]);
            BGdotColors = repmat(BGdotColors,1,3)';
        end
    end
end