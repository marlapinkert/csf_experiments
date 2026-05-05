if ~Parameters.SkipPractice
    % Task Practice 1: Gabor presentation only
    text = sprintf('Practice Round 1');
    DrawFormattedText(w, text, 'center', 'center', []);
    Screen('Flip', w);
    WaitSecs(0.1);
    KbWait();
    WaitSecs(0.1);
    
    InstCountN = 0;
    InstContrst = [1,1,1,0.5,0.75,0,1,1,0.5];
    
    for InstFreq = [3,10,6,8,8,20,10,16,20]
        InstLoc = round(3*rand(1)+1); %randomly choosing the location
        InstCountN = InstCountN + 1;
        Screen('FillOval', w, [0,0,0], [ScreenRect(3)/2-Parameters.FixationSize_Pix ScreenRect(4)/2-Parameters.FixationSize_Pix ScreenRect(3)/2+Parameters.FixationSize_Pix ScreenRect(4)/2+Parameters.FixationSize_Pix]); %fixation point
        
        ContrastNow = InstContrst(InstCountN);
        disp(['Frequency: ' num2str(InstFreq) 'cpd'])
        disp(['Contrast: ' num2str(ContrastNow*100) '%'])
        
        [isTracking,meanFixedLocX] = GazeLocIndicator(leftEyeAll,rightEyeAll,timeStampAll,xv,yv,Parameters.TrackWhichEyes,ETSampleNo,Parameters.ConnectET,in,w,ScreenRect,Parameters.FixationSize_Pix); %Call the function to change the colour of fixation based on gaze loc
        if Parameters.GaborCreation == 1
            [dstRect] = GaborPatchConstruction_Commented(InstFreq,ContrastNow,XYLoc_px_gabor(InstLoc,:),Parameters,w,ScreenRect,Gabor); %Gabor patch presentation
        elseif Parameters.GaborCreation == 2
            [dstRect] = GaborPatchConstruction_Hugo(InstFreq,ContrastNow,XYLoc_px_gabor(InstLoc,:),Parameters,w,ScreenRect,Gabor); %Gabor patch presentation
        end
        VBL1 = Screen('Flip', w);
        % To physically measure the size of 1 cycle in cm
        % Parameters.pixperdeg/InstFreq/Parameters.ScreenWidthpix*Parameters.ScreenCM(1)
        while 1
            if KeyPad % If using the KiteRoom Keypad
                [keypressed,secs,keycode] = KbCheck;
                reply = KbName(keycode);
                if keypressed ~= 0
                    break
                end
            elseif ~KeyPad
                reply = InH.getInput();
                if reply == InH.INPT_NULL.code
                else
                    break
                end
            end
        end
        rndFeedback = round(2*rand(1)+1);
        switch rndFeedback
            case 1
                [yWrongResp,FsWrongResp] = audioread('pig.wav');
            case 2
                [yWrongResp,FsWrongResp] = audioread('bear.wav');
            case 3
                [yWrongResp,FsWrongResp] = audioread('cat.wav');
        end
        if InstCountN == 8
            [TrackedEye,meanFixedLocX,isTracking,wascorrect,respondedLoc,targetLoc] = ResponseCheck(InH,practicerRespLoc,practiceTargetLoc,yWrongResp,FsWrongResp,leftEyeAll,rightEyeAll,timeStampAll,Parameters.TrackWhichEyes,xv,yv,ETSampleNo,InstLoc,KeyPad,reply,XYLoc_name,Parameters.ConnectET,in,ScreenRect,Parameters.FixationSize_Pix,w,coinScoreIdx,ZebraIdx_w,dstRect,yCoin,FsCoin);
        elseif InstCountN == 6
            [TrackedEye,meanFixedLocX,isTracking,wascorrect,respondedLoc,targetLoc] = ResponseCheck(InH,practicerRespLoc,practiceTargetLoc,yWrongResp,FsWrongResp,leftEyeAll,rightEyeAll,timeStampAll,Parameters.TrackWhichEyes,xv,yv,ETSampleNo,InstLoc,KeyPad,reply,XYLoc_name,Parameters.ConnectET,in,ScreenRect,Parameters.FixationSize_Pix,w,ZebraIdx_w,ZebraIdx_w,dstRect,yWrongResp,FsWrongResp);
        else
            [TrackedEye,meanFixedLocX,isTracking,wascorrect,respondedLoc,targetLoc] = ResponseCheck(InH,practicerRespLoc,practiceTargetLoc,yWrongResp,FsWrongResp,leftEyeAll,rightEyeAll,timeStampAll,Parameters.TrackWhichEyes,xv,yv,ETSampleNo,InstLoc,KeyPad,reply,XYLoc_name,Parameters.ConnectET,in,ScreenRect,Parameters.FixationSize_Pix,w,ZebraIdx_r,ZebraIdx_w,dstRect,yCorrResp,FsCorrResp);
        end
    end
    
    % Task Practice 2: Gabor presentation + Noise
    text = sprintf('Practice Round 2');
    DrawFormattedText(w, text, 'center', 'center', []);
    Screen('Flip', w);
    WaitSecs(0.1);
    KbWait();
    WaitSecs(0.1);
    
    InstCountN = 0;
    InstContrst = [1,1,0.75,1,0.8,0.75,0.9,0.7,0.5,0.0001,0.5,0.6,0.0001,0.5,1];
    
    
    for InstFreq = [3,10,16,8,12,3,10,20,8,2,30,5,11,10,6]
        InstLoc = round(3*rand(1)+1); %randomly choosing the location
        InstCountN = InstCountN + 1;
        Screen('FillOval', w, [0,0,0], [ScreenRect(3)/2-Parameters.FixationSize_Pix ScreenRect(4)/2-Parameters.FixationSize_Pix ScreenRect(3)/2+Parameters.FixationSize_Pix ScreenRect(4)/2+Parameters.FixationSize_Pix]); %fixation point
        for ramp = Gabor.RampVector
            ContrastNow = InstContrst(InstCountN) .* ramp;
            [isTracking,meanFixedLocX] = GazeLocIndicator(leftEyeAll,rightEyeAll,timeStampAll,xv,yv,Parameters.TrackWhichEyes,ETSampleNo,Parameters.ConnectET,in,w,ScreenRect,Parameters.FixationSize_Pix); %Call the function to change the colour of fixation based on gaze loc
            if Parameters.GaborCreation == 1
                [dstRect] = GaborPatchConstruction_Commented(InstFreq,ContrastNow,XYLoc_px_gabor(InstLoc,:),Parameters,w,ScreenRect,Gabor); %Gabor patch presentation
            elseif Parameters.GaborCreation == 2
                [dstRect] = GaborPatchConstruction_Hugo(InstFreq,ContrastNow,XYLoc_px_gabor(InstLoc,:),Parameters,w,ScreenRect,Gabor); %Gabor patch presentation
            end
            VBL1 = Screen('Flip', w);
        end
        Screen('FillOval', w, [0,0,0], [ScreenRect(3)/2-Parameters.FixationSize_Pix ScreenRect(4)/2-Parameters.FixationSize_Pix ScreenRect(3)/2+Parameters.FixationSize_Pix ScreenRect(4)/2+Parameters.FixationSize_Pix]); %fixation point
        Screen('Flip', w);
        RunNoise;
        
        while 1
            if KeyPad % If using the KiteRoom Keypad
                [keypressed,secs,keycode] = KbCheck;
                reply = KbName(keycode);
                if keypressed ~= 0
                    break
                end
            elseif ~KeyPad
                reply = InH.getInput();
                if reply == InH.INPT_NULL.code
                else
                    break
                end
            end
        end
        rndFeedback = round(2*rand(1)+1);
        switch rndFeedback
            case 1
                [yWrongResp,FsWrongResp] = audioread('pig.wav');
            case 2
                [yWrongResp,FsWrongResp] = audioread('bear.wav');
            case 3
                [yWrongResp,FsWrongResp] = audioread('cat.wav');
        end
        if InstCountN == 7
            [TrackedEye,meanFixedLocX,isTracking,wascorrect,respondedLoc,targetLoc] = ResponseCheck(InH,practicerRespLoc,practiceTargetLoc,yWrongResp,FsWrongResp,leftEyeAll,rightEyeAll,timeStampAll,Parameters.TrackWhichEyes,xv,yv,ETSampleNo,InstLoc,KeyPad,reply,XYLoc_name,Parameters.ConnectET,in,ScreenRect,Parameters.FixationSize_Pix,w,coinScoreIdx,ZebraIdx_w,dstRect,yCoin,FsCoin);
        else
            [TrackedEye,meanFixedLocX,isTracking,wascorrect,respondedLoc,targetLoc] = ResponseCheck(InH,practicerRespLoc,practiceTargetLoc,yWrongResp,FsWrongResp,leftEyeAll,rightEyeAll,timeStampAll,Parameters.TrackWhichEyes,xv,yv,ETSampleNo,InstLoc,KeyPad,reply,XYLoc_name,Parameters.ConnectET,in,ScreenRect,Parameters.FixationSize_Pix,w,ZebraIdx_r,ZebraIdx_w,dstRect,yCorrResp,FsCorrResp);
        end
    end
end