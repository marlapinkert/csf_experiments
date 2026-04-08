function [pa] = SetupLocalizerParameters(ds,pa)

    ds.ppd = angle2pix(ds,1);
    
    pa.display.ppd = ds.ppd;
    
    pa.thetaDirs = linspace(22.5, 337.5, 8);
    pa.rDirs = [1.5 3];%linspace(.75,3.75, 5);
    
    pa.bgThetaDirs = linspace(22.5, 337.5, 8);
    pa.bgRDirs = [1.5 3];    

    pa.aperturePosition = [0 0];         % theta&r for every aperture
    pa.apertureRadius   = 1;%1.3; %1;          % radius (in deg) for every aperture
    pa.fixationRadius   = 0.6; %0.7;    
    
    pa.fixationDotSize  = 4;                    % fixation dot size (in pixels)    
    pa.fixationDotColor  = [255 255 255];

    pa.numberOfDots     = 12;                   % number of dots in each aperture
    pa.totalOfDots      = pa.numberOfDots;
    pa.dotSize          = 5; %3;                    % stimulus dot size (pixels)
    pa.disparityLimit   = .15; %.15; %.5; %2*0.075;                  % maximum disparity (deg)
    pa.dotSpacing       = (0*pa.disparityLimit) + ((pa.dotSize*2)./ds.ppd); %(2*pa.disparityLimit) + ((pa.dotSize*2)./ds.ppd);
    pa.dotSizeDeg       = pa.dotSize ./ ds.ppd;
    pa.dotColors        = repmat(Shuffle([zeros(floor(pa.numberOfDots/2),1);ones(ceil(pa.numberOfDots/2),1)]),1,3);    %repmat((rand(pa.numberOfDots,1)>0.5),1,3);
    
    pa.backgroundApertureRadius                 = 2*max(pa.rDirs);
    pa.numberOfBackgroundDots                   = 500;    
    pa.backgroundDotColors        = repmat(Shuffle([zeros(floor(pa.numberOfBackgroundDots/2),1);ones(ceil(pa.numberOfBackgroundDots/2),1)]),1,3); 
    
    pa.speed            = 0.6;%.6; %.6; %1; %0.5*0.6;             % experiment speeds (in deg/sec)
    pa.directions       = [-1 1];               % experiment directions
    %pa.conditions       = 2;%[1 2 3];               % 1: FULL, 2: CD, 3: IOVD

    %pa.conditionNames   = {'FULL','CD','IOVD'};
    
    pa.dotKillTime      = GetSecs.*ones(pa.numberOfDots,1); % Initialize refresh time of dots to now        
    
    % Stimulus duration
    pa.stimDuration     = 1;%4*.25;%.5;%pa.stimulusOnTime + pa.stimulusOffTime;
    pa.preStimDuration  = 0.5;
    
    pa.numberOfRepeats  = 1; % repeats of each speed/dir combination

    
    exp_mat = [length(pa.thetaDirs) length(pa.rDirs)];
    exp_mat = exp_mat(find(exp_mat)); %#ok<FNDSB>
    pa.design = fullfact(exp_mat);

    pa.design = [pa.design; flipud(pa.design)];%repmat(pa.design,pa.numberOfRepeats,1);
    pa.design(:,3) = 1+round(rand(size(pa.design,1),1));
    pa.numberOfTrials = size(pa.design,1);
    %pa.design = pa.design(randperm(pa.numberOfTrials),:);       
    pa.numberOfTrials = size(pa.design,1);
    
    %pa.baseDir = pwd;
    %pa.filename = fullfile(pa.baseDir, [pa.subject '-ScotomaMRI-' datestr(now,30) '.mat']);

   