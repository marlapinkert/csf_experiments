function newStimuli = makeRandomImages(numberOfStimuli)

% make random images to use in rmMakeStimulusSequence.m
[g,cells,number_of_cells]=hexGrid(538);

colornumbers = unique(cells);
colornumbers = colornumbers(2:end); % not the zero of mean luminance
%numberOfStimuli = 86;
numberOfDifferentCells = size(colornumbers,1); 

newStimuli = zeros(538,538,numberOfStimuli);

stimIndex = 1;
makeNewStimuli = 1;
while makeNewStimuli
    newStim = cells;
    
    %numberOfCellsOn = ceil(rand(1)*(numberOfDifferentCells-1));  % minus one, to not make the fullfield stimulus
    %decide which cells to turn on
    %randomCellOrder = randperm(numberOfDifferentCells);
    %cellsToTurnOn =colornumbers(randomCellOrder(1:numberOfCellsOn));
    
    cellsToTurnOn = colornumbers(find(round(rand(numberOfDifferentCells, 1))));
    for c = 1:numberOfDifferentCells
        colorValue = colornumbers(c);
        if sum(cellsToTurnOn == colorValue) 
            cellColorIndex = newStim == colorValue;
            newStim(cellColorIndex) = 1;
        else
            cellColorIndex = newStim == colorValue;
            newStim(cellColorIndex) = 0;
        end
    end
    newStimuli(:,:,stimIndex) = newStim;  
    
    % check if we already have the new made stimulus, then remove it and
    % make a new one
    if stimIndex >1
        for j = 1:stimIndex-1
            if abs(newStimuli(:,:,j)-newStimuli(:,:,stimIndex)) < eps
                newStimuli(:,:,stimIndex) = zeros(538,538);                  % remove the last made stimulus
                stimIndex = stimIndex -1;                                    % remake the last stimulus
                break;
            end
        end
    end
    stimIndex = stimIndex + 1;
    if stimIndex > numberOfStimuli
        makeNewStimuli = 0;
    end
    
    
end


