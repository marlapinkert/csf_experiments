tAudio = 0.05; % 50ms

if WhichCondition(TrialCounter) == 1
    DisplayBlankCondition;
end

% Gabor presentation ~ 500ms
CurrentFrame = 1; revs = 1;
Beeper(freqAudio(idxStim(1)),VolumeAudio, tAudio); % Make a beep sound
frm = 1;
timeStamp(end+1,1) = GetSecs;
GratingOn = timeStamp(end,1);
FlipReversalTime = 0:Gabor.FlipReversalRate:Gabor.stimDurationWithRamp_secs;
FlipReversalIndex = repmat([1,2],1,length(FlipReversalTime));
while GratingOn-timeStamp(end,1) <= Gabor.stimDurationWithRamp_secs
    % Check the closest FlipReversalTime in order to get the FlipReversalIndex 
    [~,closestIndex] = min(abs(FlipReversalTime-(GratingOn-timeStamp(end,1))));
    
    Screen('DrawTexture', w, gaborid(FlipReversalIndex(closestIndex)), [], dstRect(FlipReversalIndex(closestIndex),:), 0+Gabor.Orientation, [], abs(targContrast), [], [], []);
    if Gabor.StimCondition == 2
        Screen('FillOval', w, Parameters.Background, double(DrawCentralScotoma_Pix)); %fixation point for peripheral vision condition
    end
    GratingOn = Screen('Flip', w);

    if Parameters.EyeTrack && validTrial
        if frm==1
            Eyelink('message', 'STIMULUS_START');
        end
        [x,y]=CheckEyePos(w,elparam); %gives estimate of eye position
        [inside] = CheckFixRad(x,y,[ScreenRect(3)/2 ScreenRect(4)/2], elparam.FixRadPix);
        if ~inside && validTrial
            Eyelink('message', 'FIXATION_BREAK');
            validTrial = 0;
            NumInvalid = NumInvalid+1;
            PsychPortAudio('FillBuffer', pahandle, double(EyeBeep));
            PsychPortAudio('Start', pahandle);
            PsychPortAudio('Stop', pahandle,1);
            Screen('FillRect', w, [1,0,0], Parameters.FixationPos); %fixation point
            Screen('Flip',w);
%             break;
        end
    elseif Parameters.EyeTrack && ~validTrial
        Screen('FillRect', w, [1,0,0], Parameters.FixationPos); %fixation point
        Screen('Flip',w);
    end
    frm = frm+1;
end

% while GratingOn-timeStamp(end,1) < Gabor.stimDuration_secs+(sum(Gabor.RampVector ~= 1)/2-2)*ifi
%     Screen('DrawTexture', w, gaborid(Gabor.FlipReversalIndex(rampidx)), [], dstRect(Gabor.FlipReversalIndex(rampidx),:), 0+Gabor.Orientation, [], Gabor.RampVector(rampidx), [], [], []);
%     if Gabor.StimCondition == 2
%         Screen('FillOval', w, Parameters.Background, DrawCentralScotoma_Pix); %fixation point for peripheral vision condition
%     end
%     GratingOn = Screen('Flip', w,GratingOn+ifi*2);
%     rampidx = rampidx+3;
% end

% Noise patch
if Parameters.EyeTrack
    Eyelink('message', 'STIMULUS_END');
    Eyelink('message', 'NOISE_START');
end
timeStamp(end+1,1) = GetSecs;
NoiseOn = timeStamp(end,1);
while NoiseOn-timeStamp(end,1) < Parameters.NoiseTimer
    for i=randperm(size(noisetex,2))
        if Gabor.StimCondition == 1 || Gabor.StimCondition == 2
            noiselocEnc = CenterRectOnPoint([0 0 Gabor.Size_px, Gabor.Size_px],XYLoc_px_gabor(1)+Gabor.Size_px/2,XYLoc_px_gabor(2)+Gabor.Size_px/2);
        elseif Gabor.StimCondition == 3 % Central vision: change noise patch to match the size projected
            noiselocEnc = CenterRectOnPoint([0 0 2*Gabor.PeripheralScotoma_pix, 2*Gabor.PeripheralScotoma_pix],XYLoc_px_gabor(1)+Gabor.Size_px/2,XYLoc_px_gabor(2)+Gabor.Size_px/2);
        end
        Screen('DrawTextures', w, noisetex(NoiseIdx,i), [], double(noiselocEnc'), 0, [], [], [], [], []);
        if Gabor.StimCondition == 2 % Fixation for peripheral vision
            Screen('FillOval', w, Parameters.Background, double(DrawCentralScotoma_Pix));
        end
        Screen('FillOval', w, [0,0,0], Parameters.FixationPos); %fixation point
        NoiseOn = Screen('Flip',w);
    end
end
Screen('FillOval', w, [0,0,0], Parameters.FixationPos); %fixation point
Screen('Flip',w);

if Parameters.EyeTrack
    Eyelink('message', 'NOISE_END');
end

if WhichCondition(TrialCounter) == 0
    DisplayBlankCondition;
end
