function [dotparams, duration, stimulus] = setDotParams(params,stimulus)

% Specific dot parameters
dotparams.pixperdeg = params.display.numPixels(1)/params.display.dimensions(1);
dotparams.maxdisparity = angle2pix(params.display,0.1);%0.5 .* dotparams.pixperdeg;
dotparams.dotsize = 6; % pixels
dotparams.dotspacing= dotparams.dotsize*2 + 2*dotparams.maxdisparity;
dotparams.numberofdots = 32;%32;%64;%32;%50;

dotparams.speedDeg = 0.6;%angle2pix(params.display,1);%1 .* dotparams.pixperdeg;
dotparams.speed = angle2pix(params.display, dotparams.speedDeg);
dotparams.barwidth = angle2pix(params.display,1);%0.75 .* dotparams.pixperdeg;
dotparams.radius = angle2pix(params.display, params.radius);
dotparams.ifi = 1 / params.display.frameRate;
dotparams.fixTaskChance = 0.3; % chance the fixation dot moves in a given TR
dotparams.fixChangeTime = 0.5;%2; % 500 msec 'blocks' of fixation dot action'

dotparams.numberofbgdots = round((dotparams.numberofdots./(dotparams.barwidth*(2*dotparams.radius))) * (2*dotparams.radius).^2);

%stimulus.orientations = [-1 stimulus.orientations([1 4 3 2 5 8 7 6])];

stimulus.orientations = [-1 stimulus.orientations([7 2 5 8 3 4 1 6])];


% Insert blanks after orthogonal passes (hard coded based on sequence)
if params.insertBlanks.do
    oldorientations = stimulus.orientations;
    stimulus.orientations = [oldorientations([1 2]) NaN oldorientations([3 4]) NaN oldorientations([5 6]) NaN oldorientations([7 8]) NaN oldorientations(9)];
end

% Timing
%duration.stimframe          = 1./params.temporal.frequency./params.temporal.motionSteps;
duration.scan.seconds       = params.ncycles*params.period;
%duration.scan.stimframes    = params.ncycles*params.period./duration.stimframe;
duration.cycle.seconds      = params.period;
%duration.cycle.stimframes   = params.period./duration.stimframe;
duration.prescan.seconds    = params.prescanDuration;
%duration.prescan.stimframes = params.prescanDuration./duration.stimframe;

duration.prescan.stimframes = params.prescanDuration ./ params.tr;

if params.insertBlanks.do
    duration.blankTime = 30; %~30sec blanks
    totalBlankTime   = 4.*ceil(duration.blankTime./params.tr).*params.tr; % make sure it is a multiple of the tr
    barPassTime=duration.cycle.seconds-totalBlankTime;
else
    barPassTime=duration.cycle.seconds;
end

dotparams.fixationDotTiming = dotparams.fixChangeTime:dotparams.fixChangeTime:(duration.cycle.seconds+duration.prescan.seconds);
fixationDotSequence = repmat([1; -1; 0], floor(length(dotparams.fixationDotTiming)/12), 1);
fixationDotSequence = fixationDotSequence(randperm(size(fixationDotSequence,1)));
dotparams.fixationDotSequence(2:4:length(dotparams.fixationDotTiming)) = fixationDotSequence;

step_nx      = (barPassTime)./params.tr/8;
stepradius   = dotparams.radius - round(dotparams.barwidth/2);
dotparams.step_x = linspace(-stepradius, stepradius, step_nx);%(2*outerRad) ./ step_nx;