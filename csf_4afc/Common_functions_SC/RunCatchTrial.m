%% Catch Trial
EncorageCont = [1,0.8,1,0.9];
EncorageFreq = [3,10,16,8];

if singleTrialCounter4Catch(end) == catchTrialNum(catchTrialCount)
    isCatch(end+1) = 1;
    singleTrialCounter(end+1) = singleTrialCounter(end) + 1;
    BlockNum(end+1) = 0; 
    wasAborted(end+1) = 0;
    catchTrialCount = catchTrialCount + 1;
    CatchTrialIdx = round(3*rand(1)+1);
    isRevesal(end+1) = 333; %#ok
    
    [TrackedEye,isTracking,meanFixedLocX] = GazeLocIndicator(leftEyeAll,rightEyeAll,timeStampAll,xv,yv,Parameters.TrackWhichEyes,ETSampleNo,Parameters.ConnectET,in,w,ScreenRect,Parameters.FixationSize_Pix);

    timeStamp(end+1) = GetSecs; 
    for ramp = Gabor.RampVector
        ContrastNow = EncorageCont(CatchTrialIdx) .* ramp;
        [TrackedEye,isTracking,meanFixedLocX] = GazeLocIndicator(leftEyeAll,rightEyeAll,timeStampAll,xv,yv,Parameters.TrackWhichEyes,ETSampleNo,Parameters.ConnectET,in,w,ScreenRect,Parameters.FixationSize_Pix); %Call the function to change the colour of fixation based on gaze loc
        if Parameters.GaborCreation == 1
            [dstRect] = GaborPatchConstruction_Commented(EncorageFreq(CatchTrialIdx),ContrastNow,XYLoc_px_gabor((CatchTrialIdx),:),Parameters,w,ScreenRect,Gabor); %Gabor patch presentation
        elseif Parameters.GaborCreation == 2
            [dstRect] = GaborPatchConstruction_Hugo(EncorageFreq(CatchTrialIdx),ContrastNow,XYLoc_px_gabor((CatchTrialIdx),:),Parameters,w,ScreenRect,Gabor); %Gabor patch presentation
        end
        VBL1 = Screen('Flip', w);
    end
    RunNoise;

    while 1
        [TrackedEye,isTracking,meanFixedLocX] = GazeLocIndicator(leftEyeAll,rightEyeAll,timeStampAll,xv,yv,Parameters.TrackWhichEyes,ETSampleNo,Parameters.ConnectET,in,w,ScreenRect,Parameters.FixationSize_Pix); %Call the function to change the colour of fixation based on gaze loc
        Screen('Flip', w);
        
        respTimeStart = GetSecs;
        while 1
            [TrackedEye,isTracking,meanFixedLocX] = GazeLocIndicator(leftEyeAll,rightEyeAll,timeStampAll,xv,yv,Parameters.TrackWhichEyes,ETSampleNo,Parameters.ConnectET,in,w,ScreenRect,Parameters.FixationSize_Pix); %Call the function to change the colour of fixation based on gaze loc
            Screen('Flip', w);
            if KeyPad % If using the KiteRoom Keypad
                [keypressed,secs,keycode] = KbCheck;
                replyCatch = KbName(keycode);
                if ismember(str2double(replyCatch),XYLoc_name)
                    break
                end
            elseif ~KeyPad
                replyCatch = InH.getInput();
                if ismember(replyCatch,XYLoc_name)
                    break
                end
            end
            WaitSecs(0.01);
        end
        respTimeEnd = GetSecs;
        respDuration(end+1) = respTimeEnd - respTimeStart; %#ok
        
        
        rndFeedback = round(2*rand(1)+1);
        switch rndFeedback
            case 1
                [yWrongResp,FsWrongResp] = audioread('pig.wav');
            case 2
                [yWrongResp,FsWrongResp] = audioread('bear.wav');
            case 3
                [yWrongResp,FsWrongResp] = audioread('cat.wav');
        end
        [TrackedEye,meanFixedLocX,isTracking,wascorrect,respondedLoc,targetLoc] = ResponseCheck(InH,respondedLoc,targetLoc,yWrongResp,FsWrongResp,leftEyeAll,rightEyeAll,timeStampAll,Parameters.TrackWhichEyes,xv,yv,ETSampleNo,CatchTrialIdx,KeyPad,replyCatch,XYLoc_name,Parameters.ConnectET,in,ScreenRect,Parameters.FixationSize_Pix,w,coinScoreIdx,ZebraIdx_w,dstRect,yCoin,FsCoin);
        CorrectAns(end+1) = wascorrect; %#ok
        PresentedContrast(end+1) = EncorageCont(CatchTrialIdx);; %#ok
        PresentedFreq(end+1) = EncorageFreq(CatchTrialIdx); %#ok
        
        break
    end
    isETTracking(end+1) = isTracking; 
    meanFixation(end+1) = meanFixedLocX;
end
