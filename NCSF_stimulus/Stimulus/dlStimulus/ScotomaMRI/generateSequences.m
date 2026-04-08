function optseq = generateSequences()
% Generate sequences with minimal temporal correlations



numEvents = 16; % locations to measure
eventDur = 2; % each event will last 2 TRs
TR = 1.5; % sec
nRepeats = 5;
prestimDur = 0.5; % sec
stimDur = 1; % sec


e = 1; 
optseq = [];

for ii = 1:1000
   
    tmpdesign = repmat([1:numEvents],1,nRepeats);
    
    stimseq(1:2:(numEvents.*nRepeats*2)) = tmpdesign;
    
    prediction = genPred(stimseq);
    
    cr = corr(prediction);
    cr = cr(:);
    thise = max(cr(cr~=1));
    
    if thise < e
        e = thise;
        optseq = stimseq;
    end
end



function prediction = genPred(stimseq)
        stimuli = unique(stimseq);
        stimuli = stimuli(2:end);
        numOfStimuli = length(stimuli);
        
        predictMat = zeros(length(stimseq),numOfStimuli);
        tempSeq = [];
        
        for stimInd = 1 : numOfStimuli
            
            % Create stimulus-specific sequence
            tempSeq = stimseq;
            tempSeq( tempSeq ~= stimuli( stimInd )) = 0;
            tempSeq( tempSeq > 0) = 1;
            
            % Add sequence to prediction matrix
            predictMat(:,stimInd) = tempSeq;
        end
        
        % convolve with hrf
        prediction = rfConvolveTC(predictMat,TR,'t');
end


end