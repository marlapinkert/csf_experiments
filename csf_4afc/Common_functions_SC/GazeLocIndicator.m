function [TrackedEye,isTracking,meanFixedLocX] = GazeLocIndicator(leftEyeAll,rightEyeAll,timeStampAll,xv,yv,TrackWhichEyes,ETSampleNo,ConnectET,in,w,ScreenRect,FixationSize)

if ConnectET
    [lefteye, righteye, timestamp, trigSignal] = tetio_readGazeData;
    numGazeData = size(lefteye, 2);
    leftEyeAll = vertcat(leftEyeAll, [lefteye(:, 1:numGazeData)]);
    rightEyeAll = vertcat(rightEyeAll, [righteye(:, 1:numGazeData)]);
    timeStampAll = vertcat(timeStampAll, timestamp(:,1)); %#ok
    timeLastSampleRecord = GetSecs(); %#ok
    
    if TrackWhichEyes == 0 %track left eye only
        TrackedEye = leftEyeAll;
    elseif TrackWhichEyes == 1 %track right eye only
        TrackedEye = rightEyeAll;
    elseif TrackWhichEyes == 2 %track both eyes
        BothEyesAll(:,1) = mean(leftEyeAll(:,7)~=-1,rightEyeAll(:,7)~=-1);
        BothEyesAll(:,2) = mean(leftEyeAll(:,8)~=-1,rightEyeAll(:,8)~=-1);
        TrackedEye = BothEyesAll;
    end
    
    TrackedEyeXidx = find(TrackedEye(end-ETSampleNo:end,7)~=-1);
    TrackedEyeYidx = find(TrackedEye(end-ETSampleNo:end,8)~=-1);
    currentEye = TrackedEye(end-ETSampleNo:end,:);
    in = inpolygon(median(currentEye(TrackedEyeXidx,7)),median(currentEye(TrackedEyeYidx,8)),xv,yv);
    
    if ~in
        Screen('FillOval', w, [0.2,0.2,0.2], [ScreenRect(3)/2-FixationSize ScreenRect(4)/2-FixationSize ScreenRect(3)/2+FixationSize ScreenRect(4)/2+FixationSize]); %fixation point
    elseif in
        Screen('FillOval', w, [0,0,0], [ScreenRect(3)/2-FixationSize ScreenRect(4)/2-FixationSize ScreenRect(3)/2+FixationSize ScreenRect(4)/2+FixationSize]); %fixation point
    end
    
    if mode(TrackedEye(end-ETSampleNo:end,7)) == -1
        isTracking = 0; %#ok
    else
        isTracking = 1; %#ok
    end
    meanFixedLocX = mean([mean(currentEye(TrackedEyeXidx,7)),mean(currentEye(TrackedEyeXidx,8))]);
    
else
    Screen('FillOval', w, [0,0,0], [ScreenRect(3)/2-FixationSize ScreenRect(4)/2-FixationSize ScreenRect(3)/2+FixationSize ScreenRect(4)/2+FixationSize]); %fixation point
    meanFixedLocX = 333;
    isTracking = 333;
    TrackedEye = 333;
end

