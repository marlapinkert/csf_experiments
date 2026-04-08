AssertOpenGL;

% to skip annoying warning message on display (but not terminal)
Screen('Preference','SkipSyncTests', 1);

% Open the screen
params.display                = openScreen(params.display);
params.display.devices        = params.devices;

% to allow blending
Screen('BlendFunction', params.display.windowPtr, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

% Store the images in textures
if exist('stimulus', 'var')
    original_stimulus = stimulus; %#ok<NASGU>
end
switch params.experiment
    case {'8 bars with blanks RDK (0)', '8 bars with blanks RDK (90)', '8 bars with blanks RDK (-45)', '8 bars with blanks RDK (+45)', '8 bars with blanks RDK (random)', '8 bars with blanks RDK (90) Fast', '8 bars with blanks RDK (90) Medium', '8 bars with blanks RDK (90) Slow','8 bars with blanks RDK (0) Fast',...
            '8 bars with blanks RDK (0) Medium', '8 bars with blanks RDK (0) Slow'},
        %stimulus = createTexturesRDK(params.display,stimulus);
    case {'8 bars with blanks Cow (0) Slow','8 bars with blanks Cow (0) Medium','8 bars with blanks Cow (0) Fast','8 bars with blanks Cow (90) Slow', '8 bars with blanks Cow (90) Medium','8 bars with blanks Cow (90) Fast',...
            '8 bars with blanks Cow (Flicker) Slow','8 bars with blanks Cow (Flicker) Fast', 'Cow Full Fast', 'Cow Full Medium','Cow Full Slow','Cow Full Still'}
        [stimulus, params]=createWindowPositions(stimulus,params);
    case {'Numbers and Dots Scaled', 'Numbers and Dots Unscaled','Numbers Only', 'Dots Unscaled', 'Dots Scaled', 'Dots Scaled Reverse', 'Dots Scaled pRF', 'Dots Scaled pRF full blanks','Dots Small', 'Dots Attention', 'Dots Gaussian'},
        %Do nothing, stimulus generated on-the-fly
    otherwise
        stimulus = createTextures(params.display,stimulus);
end

% getting to the source rather than doScan->doTrial->showStimulus
for n = 1:params.repetitions,
    % set priority
    Priority(params.runPriority);
    
    % reset colormap?
    resetColorMap(params);
    
    % flush the device
    deviceUMC('read',params.devices.UMCport);
    
    % wait for go signal
    if params.display.stereoFlag==1
        %make texture for calibration lines and fusion background
        params.display.calibrate=0;
        stimulus.backgroundTexture=fusionBackGround(params.display, params);
        dispStringInCenterStereo(params.display,'Waiting for scanner to start',0.6,40,[0 0 0], stimulus);
    else
        dispStringInCenter(params.display,'Waiting for scanner to start',0.6,40,[0 0 0]);
    end
    %         tmp = Screen('MakeTexture',params.display.windowPtr, ...
    %             zeros(768,1024));
    %         Screen('DrawTexture', params.display.windowPtr, tmp);
    %         Screen('Flip',params.display.windowPtr);
    
    [~, time0]=deviceUMC('wait for trigger',params.devices.UMCport);
    if params.devices.UMCport==2
        system('say -v Vicki stimulus started &'); % in the background
    end
    
    % go
    switch params.experiment
        case {'8 bars with blanks RDK (0)', '8 bars with blanks RDK (90)', '8 bars with blanks RDK (-45)', '8 bars with blanks RDK (+45)', '8 bars with blanks RDK (random)', '8 bars with blanks RDK (90) Fast', '8 bars with blanks RDK (90) Medium', '8 bars with blanks RDK (90) Slow','8 bars with blanks RDK (0) Fast', '8 bars with blanks RDK (0) Medium', '8 bars with blanks RDK (0) Slow'},
            [response, ~, quitProg] = showScanStimulusRDK(params.display,stimulus,time0);
        case {'Full-field full'},
            [response, ~, quitProg] = showScanStimulusRedBlue(params.display,stimulus,time0);
        case {'8 bars with blanks Cow (0) Slow','8 bars with blanks Cow (0) Medium','8 bars with blanks Cow (0) Fast','8 bars with blanks Cow (90) Slow', '8 bars with blanks Cow (90) Medium','8 bars with blanks Cow (90) Fast','8 bars with blanks Cow (Flicker) Slow','8 bars with blanks Cow (Flicker) Fast', 'Cow Full Fast','Cow Full Medium','Cow Full Slow','Cow Full Still'},
            [response, ~, quitProg, stimulus] = showScanStimulusMovingImage(params.display,stimulus,params,time0);
        case {'Numbers and Dots Scaled', 'Numbers and Dots Unscaled','Numbers Only', 'Dots Unscaled', 'Dots Scaled', 'Dots Scaled Reverse', 'Dots Scaled pRF', 'Dots Scaled pRF full blanks', 'Dots Small', 'Dots Attention', 'Dots Gaussian'},
            [response, ~, quitProg, stimulus] = showScanStimulusNumbersDots(params.display, params, time0);
        case {'full-field, flicker (check), stereo'}
            [response, ~, quitProg] = showScanStimulusStereo(params.display, params,stimulus,time0);
        otherwise
            [response, ~, quitProg] = showScanStimulus(params.display,stimulus,time0);
    end
    
    % clean up immediately
    if n==params.repetitions
        % Close the one on-screen and many off-screen windows
        closeScreen(params.display);
    end
    
    % syncing check 
    if params.devices.UMCport==2
        getNumberOfTriggers(params,response);
    end
    
    % reset priority
    Priority(0);
    
    % get performance
    [pc,rc] = getFixationPerformance(params.fix,stimulus,response);
    fprintf('[%s]:Fixation dot task: percent correct: %.1f %%, reaction time: %.1f secs\n',mfilename,pc,rc);
end


