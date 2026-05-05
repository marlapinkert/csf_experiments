if Parameters.ConnectET == 1
    for i = 3:-1:1 %Show the counter on the screen until start
        text = sprintf('Look at the centre! Start in %s second(s)!',int2str(i));
        DrawFormattedText(w, text, 'center', 'center', []);
        Screen('Flip', w);
        WaitSecs(1);
    end
    
    % Present the fixation dot for checking the gaze location
    Screen('FillOval', w, [0,0,0], [ScreenRect(3)/2-FixationSize ScreenRect(4)/2-FixationSize ScreenRect(3)/2+FixationSize ScreenRect(4)/2+FixationSize]); %fixation point
    Screen('Flip', w);
    
    tetio_startTracking;
    WaitSecs(0.2); % wait to build up data
    timeLastSampleRecord = -inf;
    
    while 1 %Chekcing the location of gaze until press space key
        [lefteye, righteye, timestamp, trigSignal] = tetio_readGazeData;
        
        if ~isempty(lefteye)
            numGazeData = size(lefteye, 2);
            leftEyeAll = vertcat(leftEyeAll, [lefteye(:, 1:numGazeData)]);
            rightEyeAll = vertcat(rightEyeAll, [righteye(:, 1:numGazeData)]);
            timeStampAll = vertcat(timeStampAll, timestamp(:,1));
            timeLastSampleRecord = GetSecs();
        end
        
        if Parameters.TrackWhichEyes == 0 %track left eye only
            TrackedEye = leftEyeAll;
            if length(leftEyeAll(:,7)~=-1) <= ETSampleNo
                continue;
            end
        elseif Parameters.TrackWhichEyes == 1 %track right eye only
            TrackedEye = rightEyeAll;
            if length(rightEyeAll(:,7)~=-1) <= ETSampleNo
                continue;
            end
        elseif Parameters.TrackWhichEyes == 2 %track both eyes
            BothEyesAll(:,1) = mean(leftEyeAll(:,7)~=-1,rightEyeAll(:,7)~=-1);
            BothEyesAll(:,2) = mean(leftEyeAll(:,8)~=-1,rightEyeAll(:,8)~=-1);
            TrackedEye = BothEyesAll;
            
            if length(BothEyesAll(:,1)~=-1) <= ETSampleNo
                continue;
            end
        end
        
        AllowedRangeDegVA = 1;
        AllowedRangePx = AllowedRangeDegVA ./ Parameters.degperpix;
        
        AllowedRangeX = AllowedRangePx/ScreenRect(3);
        AllowedRangeY = AllowedRangePx/ScreenRect(4);
        
        xv=[0.5-AllowedRangeX,0.5+AllowedRangeX,0.5+AllowedRangeX,0.5-AllowedRangeX];yv=[0.5-AllowedRangeY,0.5-AllowedRangeY,0.5+AllowedRangeY,0.5+AllowedRangeY];
        
        TrackedEyeXidx = find(TrackedEye(end-ETSampleNo:end,7)~=-1);
        TrackedEyeYidx = find(TrackedEye(end-ETSampleNo:end,8)~=-1);
        currentEye = TrackedEye(end-ETSampleNo:end,:);
        in = inpolygon(median(currentEye(TrackedEyeXidx,7)),median(currentEye(TrackedEyeYidx,8)),xv,yv);
        
        if ~in
            Screen('FillOval', w, [1,0,0], [ScreenRect(3)/2-Parameters.FixationSize_Pix ScreenRect(4)/2-Parameters.FixationSize_Pix ScreenRect(3)/2+Parameters.FixationSize_Pix ScreenRect(4)/2+Parameters.FixationSize_Pix]); %fixation point
            Screen('Flip', w);
        elseif in
            Screen('FillOval', w, [0,0,0], [ScreenRect(3)/2-Parameters.FixationSize_Pix ScreenRect(4)/2-Parameters.FixationSize_Pix ScreenRect(3)/2+Parameters.FixationSize_Pix ScreenRect(4)/2+Parameters.FixationSize_Pix]); %fixation point
            Screen('Flip', w);
        end
        
        reply = InH.getInput();
        if reply == InH.INPT_SPACE.code
            break
        end
        WaitSecs(0.1);
    end
end