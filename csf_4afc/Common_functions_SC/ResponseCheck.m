function [TrackedEye,meanFixedLocX,isTracking,wascorrect,respondedLoc,targetLoc] = ResponseCheck(InH,respondedLoc,targetLoc,yWrongResp,FsWrongResp,leftEyeAll,rightEyeAll,timeStampAll,TrackWhichEyes,xv,yv,ETSampleNo,rnd_loc,KeyPad,reply,XYLoc_name,ConnectET,in,ScreenRect,FixationSize,w,ZebraIdx_r,ZebraIdx_w,dstRect,yCorr,FsCorr)
% reply = InH.getInput();
% if reply(1) == InH.INPT_TRIGGER_EYETRACKER_CALIBRATION.code
%     ConnectET = 0; %#ok
% end
if KeyPad % If using the KiteRoom Keypad
    respondedLoc(end+1) = str2double(reply(1)); %#ok
    targetLoc(end+1) = XYLoc_name(rnd_loc); %#ok

    if str2double(reply(1)) == XYLoc_name(rnd_loc)      
        wascorrect = true;
        sound(yCorr,FsCorr);
        for i=1:3
            if mod(i,2) == 0
                [TrackedEye,isTracking,meanFixedLocX] = GazeLocIndicator(leftEyeAll,rightEyeAll,timeStampAll,xv,yv,TrackWhichEyes,ETSampleNo,ConnectET,in,w,ScreenRect,FixationSize); %Call the function to change the colour of fixation based on gaze loc
                Screen('DrawTexture', w, ZebraIdx_r,[],dstRect,15);
                Screen('flip',w);
                WaitSecs(0.1);
            else
                [TrackedEye,isTracking,meanFixedLocX] = GazeLocIndicator(leftEyeAll,rightEyeAll,timeStampAll,xv,yv,TrackWhichEyes,ETSampleNo,ConnectET,in,w,ScreenRect,FixationSize); %Call the function to change the colour of fixation based on gaze loc
                Screen('DrawTexture', w, ZebraIdx_r,[],dstRect,-15);
                Screen('flip',w);
                WaitSecs(0.1);
            end
        end
    else
        wascorrect = false;
        sound(yWrongResp,FsWrongResp)
        for i=1:3
            if mod(i,2) == 0
                [TrackedEye,isTracking,meanFixedLocX] = GazeLocIndicator(leftEyeAll,rightEyeAll,timeStampAll,xv,yv,TrackWhichEyes,ETSampleNo,ConnectET,in,w,ScreenRect,FixationSize); %Call the function to change the colour of fixation based on gaze loc
                Screen('DrawTexture', w, ZebraIdx_w,[],dstRect,0);
                Screen('flip',w);
                WaitSecs(0.1);
            else
                [TrackedEye,isTracking,meanFixedLocX] = GazeLocIndicator(leftEyeAll,rightEyeAll,timeStampAll,xv,yv,TrackWhichEyes,ETSampleNo,ConnectET,in,w,ScreenRect,FixationSize); %Call the function to change the colour of fixation based on gaze loc
                Screen('DrawTexture', w, ZebraIdx_w,[],dstRect,0);
                Screen('flip',w);
                WaitSecs(0.1);
            end
        end
    end
elseif ~KeyPad
    respondedLoc(end+1) = reply(1); %#ok
    targetLoc(end+1) = XYLoc_name(rnd_loc); %#ok
    
    if ismember(reply(1),XYLoc_name)
        if reply(1) == XYLoc_name(rnd_loc)
            wascorrect = true;
            sound(yCorr,FsCorr);
            for i=1:3
                if mod(i,2) == 0
                    [TrackedEye,isTracking,meanFixedLocX] = GazeLocIndicator(leftEyeAll,rightEyeAll,timeStampAll,xv,yv,TrackWhichEyes,ETSampleNo,ConnectET,in,w,ScreenRect,FixationSize); %Call the function to change the colour of fixation based on gaze loc
                    Screen('DrawTexture', w, ZebraIdx_r,[],dstRect,15);
                    Screen('flip',w);
                    WaitSecs(0.1);
                else
                    [TrackedEye,isTracking,meanFixedLocX] = GazeLocIndicator(leftEyeAll,rightEyeAll,timeStampAll,xv,yv,TrackWhichEyes,ETSampleNo,ConnectET,in,w,ScreenRect,FixationSize); %Call the function to change the colour of fixation based on gaze loc
                    Screen('DrawTexture', w, ZebraIdx_r,[],dstRect,-15);
                    Screen('flip',w);
                    WaitSecs(0.1);
                end
            end
        else
            wascorrect = false;
            sound(yWrongResp,FsWrongResp)
            for i=1:3
                if mod(i,2) == 0
                    [TrackedEye,isTracking,meanFixedLocX] = GazeLocIndicator(leftEyeAll,rightEyeAll,timeStampAll,xv,yv,TrackWhichEyes,ETSampleNo,ConnectET,in,w,ScreenRect,FixationSize); %Call the function to change the colour of fixation based on gaze loc
                    Screen('DrawTexture', w, ZebraIdx_w,[],dstRect,0);
                    Screen('flip',w);
                    WaitSecs(0.1);
                else
                    [TrackedEye,isTracking,meanFixedLocX] = GazeLocIndicator(leftEyeAll,rightEyeAll,timeStampAll,xv,yv,TrackWhichEyes,ETSampleNo,ConnectET,in,w,ScreenRect,FixationSize); %Call the function to change the colour of fixation based on gaze loc
                    Screen('DrawTexture', w, ZebraIdx_w,[],dstRect,0);
                    Screen('flip',w);
                    WaitSecs(0.1);
                end
            end
        end
    end
end
Screen('FillOval', w, [0,0,0], [ScreenRect(3)/2-FixationSize ScreenRect(4)/2-FixationSize ScreenRect(3)/2+FixationSize ScreenRect(4)/2+FixationSize]); %fixation point
Screen('flip',w);
WaitSecs(0.1);
end
