function [pa] = SetupParameters(ds,pa)

    ds.ppd = angle2pix(ds,1);
    
    pa.display.ppd = ds.ppd;
    
    pa.thetaDirs = linspace(22.5, 337.5, 8);%[22.5000  67.5000  112.5000  157.5000  202.5000  247.5000  292.5000 247.5000  292.5000 247.5000  292.5000 337.5000];%[67.5 112.5 247.5 292.5];%linspace(22.5, 337.5, 8);
    pa.rDirs = [1.5 3];%linspace(.75,3.75, 5);
    
    pa.bgThetaDirs = linspace(22.5, 337.5, 8);
    pa.bgRDirs = [1.5 3];
    
    pa.aperturePosition = [0 0];         % theta&r for every aperture
    pa.apertureRadius   = 1;%1.3; %1;          % radius (in deg) for every aperture
    pa.fixationRadius   = 0.6; %0.7;    
    
    pa.fixationDotSize  = 6;                    % fixation dot size (in pixels)    
    pa.fixationDotColor  = [255 255 255];

    pa.numberOfDots     = 8;                   % number of dots in each aperture
    pa.totalOfDots      = pa.numberOfDots;
    pa.dotSize          = 5; %3;                    % stimulus dot size (pixels)
    pa.disparityLimit   = .15; %.15; %.5; %2*0.075;                  % maximum disparity (deg)
    pa.dotSpacing       = (0*pa.disparityLimit) + ((pa.dotSize*3)./ds.ppd); %(2*pa.disparityLimit) + ((pa.dotSize*2)./ds.ppd);
    pa.dotSizeDeg       = pa.dotSize ./ ds.ppd;
    pa.dotColors        = repmat(Shuffle([zeros(floor(pa.numberOfDots/2),1);ones(ceil(pa.numberOfDots/2),1)]),1,3);    %repmat((rand(pa.numberOfDots,1)>0.5),1,3);
    
    pa.backgroundApertureRadius                 = 3;
    pa.numberOfBackgroundDots                   = 100;    
    pa.backgroundDotColors        = repmat(Shuffle([zeros(floor(pa.numberOfBackgroundDots/2),1);ones(ceil(pa.numberOfBackgroundDots/2),1)]),1,3); 
    
    pa.speed            = 0.6;%.6; %.6; %1; %0.5*0.6;             % experiment speeds (in deg/sec)
    pa.directions       = [-1 1];               % experiment directions
    %pa.conditions       = 2;%[1 2 3];               % 1: FULL, 2: CD, 3: IOVD

    %pa.conditionNames   = {'FULL','CD','IOVD'};
    
    pa.dotKillTime      = GetSecs.*ones(pa.numberOfDots,1); % Initialize refresh time of dots to now        
    
    % Stimulus duration
    pa.stimDuration     = 1;%4*.25;%.5;%pa.stimulusOnTime + pa.stimulusOffTime;
    pa.preStimDuration  = 0.5;
    
    pa.numberOfRepeats  = 5; % repeats of each speed/dir combination

    
    exp_mat = [length(pa.thetaDirs) length(pa.rDirs)];
    pa.trialLocations = fullfact(exp_mat);
    
    tmpShift = randi(287,1);
    pa.design = mseqSearch(17,2,tmpShift);
    % remove 0 events, makes it a slightly less "m" sequence
    pa.design(pa.design==0) = [];
    % prescan frames
    pa.design = [pa.design(end-8:end); pa.design];
    pa.numberOfTrials = size(pa.design,1);
%     exp_mat = exp_mat(find(exp_mat)); %#ok<FNDSB>
%     pa.design = fullfact(exp_mat);
% 
%     pa.design = repmat(pa.design,pa.numberOfRepeats,1);
%     pa.numberOfTrials = size(pa.design,1);
%     pa.design = pa.design(randperm(pa.numberOfTrials),:);       
%     pa.numberOfTrials = size(pa.design,1);
    
    %pa.baseDir = pwd;
    %pa.filename = fullfile(pa.baseDir, [pa.subject '-ScotomaMRI-' datestr(now,30) '.mat']);

   