function doRetinotopyScan(params)
% doRetinotopyScan - runs retinotopy scans
%
% doRetinotopyScan(params)
%
% Runs any of several retinotopy scans
%
% 99.08.12 RFD wrote it, consolidating several variants of retinotopy scan code.
% 05.06.09 SOD modified for OSX, lots of changes.

% defaults
if ~exist('params', 'var')
	error('No parameters specified!');
end

% quit key
try
    quitProgKey = params.display.quitProgKey;
catch ME
    quitProgKey = KbName('q');
    retrow(ME);
end;

qparams.display.arch=computer('arch');

% make/load stimulus
switch params.experiment
    case '2 rings',
        stimulus = makeRetinotopyStimulus_2rings(params);
    case {'8 bars','8 bars with blanks','8 bars (sinewave)','8 bars (slow)',...
          '8 bars (LMS)','8 bars (LMS) with blanks','8 bars with blanks (attn)'},
        [stimulus otherSequence] = makeRetinotopyStimulus_bars(params);
    case {'8 bars with blanks (lr)'},
        [stimulus otherSequence] = makeRetinotopyStimulus_barsLR(params);
    case {'8 bars with blanks (lr 2)'},
        [stimulus otherSequence] = makeRetinotopyStimulus_barsLR2(params);
    case {'8 bars with blanks (lr 3)', '8 bars with blanks (attention checkerboard)'},
        [stimulus otherSequence] = makeRetinotopyStimulus_barsLR3(params);
    case '8 bars with blanks (TR 2.1)',
        [stimulus otherSequence] = makeRetinotopyStimulus_barsTR21(params);
    case '8 bars with blanks (TR 1.8)',
        [stimulus otherSequence] = makeRetinotopyStimulus_barsTR18(params);
    case {'8 bars with blanks (Grid)'},
        [stimulus otherSequence] = makeRetinotopyStimulus_barsGrid(params);
    case {'8 bars with blanks (ecc scaled)'},
        [stimulus otherSequence] = makeRetinotopyStimulus_bars_ecc_scaled(params);
    case {'8 bars with blanks (lr ONLY random)','8 bars with blanks (lr ONLY)'},
        [stimulus] = makeRetinotopyStimulus_bars_LRONLY_random(params);
    case {'8 bars with blanks (lr ONLY wrap)', '8 bars with blanks (lr ONLY unwrap)'},
        [stimulus] = makeRetinotopyStimulus_bars_LRONLY_wrap(params);
    case {'Full-field full'},
        [stimulus] = makeRetinotopyStimulusFull(params);
    case '8 bars (letters)',
        [stimulus] = makeApertureStimulus(params);
    case {'8 bars with blanks contours (0)','8 bars with blanks contours (90)','8 bars with blanks contours (-45)','8 bars with blanks contours (+45)','8 bars with blanks contours (random)'},
        [stimulus] = makeRetinotopyStimulus_barsContours(params);
    case {'8 bars with blanks contours (r0)','8 bars with blanks contours (r90)'},
        [stimulus] = makeRetinotopyStimulus_barsContours2(params);
    case {'8 bars with blanks contours (b0)','8 bars with blanks contours (b90)'},
        [stimulus] = makeRetinotopyStimulus_barsContours3(params);
    case {'Retinotopy Images'},
        [stimulus] = makeRetinotopyStimulus_barsImages(params);
    case {'Retinotopy Images Cow (lr 3)', 'Retinotopy Images Natural (lr 3)'}    
        [stimulus] = makeRetinotopyStimulus_barsImagesLR3(params);
    case {'Natural Images 10 Flashes', 'Natural Images 7 Flashes', 'Natural Images 4 Flashes','Natural Images 3 Fades','Natural Images 2 Fades', 'Natural Images Masks Short','Natural Images Masks Long','Natural Images Grid 3 Flashes', 'Natural Images Grid 3 Flashes_set2', 'Natural Images Grid 3 Flashes_set3','Natural Images 3 Flashes', 'Natural Images 3 Flashes_set1','Natural Images 3 Flashes_set2', 'Natural Images 3 Flashes_set3', 'Natural Images 3 Flashes_set4', 'Natural Images 3 Flashes_set5', 'Natural Images 3 Flashes_set6'},
        [stimulus params] = makeRetinotopyStimulus_naturalImages(params);
    case  'images.circleimage',
        [stimulus] = makeRetinotopyStimulusImages(params);
    case {'8 bars with blanks RDK (0)', '8 bars with blanks RDK (90)', '8 bars with blanks RDK (-45)', '8 bars with blanks RDK (+45)', '8 bars with blanks RDK (random)', '8 bars with blanks RDK (90) Fast', '8 bars with blanks RDK (90) Medium', '8 bars with blanks RDK (90) Slow','8 bars with blanks RDK (0) Fast', '8 bars with blanks RDK (0) Medium', '8 bars with blanks RDK (0) Slow'}
        [stimulus] = makeRetinotopyStimulus_barsRDKWindow(params);
    case {'8 bars with blanks Cow (0) Slow','8 bars with blanks Cow (0) Medium','8 bars with blanks Cow (0) Fast', '8 bars with blanks Cow (90) Slow', '8 bars with blanks Cow (90) Medium','8 bars with blanks Cow (90) Fast','8 bars with blanks Cow (Flicker) Slow','8 bars with blanks Cow (Flicker) Fast'},
        [stimulus] = makeRetinotopyStimulus_barsCowPassout(params);
    case {'Cow Full Fast','Cow Full Medium','Cow Full Slow','Cow Full Still'},
        [stimulus] = makeRetinotopyStimulus_CowPassoutFull(params);
    case {'full-field, flicker','full-field, flicker (sin)','full-field, flicker (check)'},
        [stimulus] = makeRetinotopyStimulus_Flicker(params);
    case {'full-field, flicker (check), stereo'},
        [stimulus] = makeRetinotopyStimulus_FlickerStereo(params);
    case {'8 bars with blanks Checks Counter (90) 2.5d/s', '8 bars with blanks Checks Counter (90) 5d/s', '8 bars with blanks Checks Together (90) 2.5d/s','8 bars with blanks Checks Together (90) 5d/s', '8 bars with blanks Sine (90) 1.5d/s', '8 bars with blanks Sine (90) 2.5d/s', '8 bars with blanks Sine (90) 3.75d/s', '8 bars with blanks Sine (90) 5d/s', '8 bars with blanks Sine (90) 7.5d/s','8 bars with blanks Sine (0) 2.5d/s', '8 bars with blanks Sine (0) 5d/s', '8 bars with blanks Sine (90) 1.5d/s 20%','8 bars with blanks Sine (90) 2.5d/s 20%','8 bars with blanks Sine (90) 3.75d/s 20%', '8 bars with blanks Sine (90) 5d/s 20%','8 bars with blanks Sine (90) 7.5d/s 20%'},
        [stimulus otherSequence] = makeRetinotopyStimulus_barsMotionChecks(params);
    case {'Sine motion psychophysics(90)'},
        [stimulus] = makePsychophysicsStimulusMotion(params);        
        
    case {'rotating wedge (90deg duty) BH'},
        stimulus = makeRetinotopyStimulusFull(params);
    case {'8 bars with blanks (tr 3)'},
        [stimulus otherSequence] = makeRetinotopyStimulus_barsTR3(params);
    case {'Numbers and Dots Scaled', 'Numbers and Dots Unscaled','Numbers Only', 'Dots Unscaled', 'Dots Scaled', 'Dots Scaled Reverse', 'Dots Scaled pRF', 'Dots Scaled pRF full blanks', 'Dots Scaled pRF short', 'Dots Scaled pRF full blanks short','Dots Area pRF full blanks TR=1.5, nTRs=3','Dots Size pRF full blanks TR=1.5, nTRs=3','Numbers Size pRF full blanks TR=1.5, nTRs=3', 'Dots Shapes pRF full blanks TR=1.5, nTRs=3', 'Dots Circumference pRF full blanks TR=1.5, nTRs=3', 'Dots Dense pRF full blanks TR=1.5, nTRs=3','Dots Size pRF full blanks ECoG TR=1.5, nTRs=3','Dots Size pRF ECoG long random order','One Dot Sizes pRF full blanks TR=1.5, nTRs=3','Dots In Noise pRF full blanks TR=1.5, nTRs=3','Dots Area pRF full blanks TR=2.1, nTRs=2','Dots Size pRF full blanks TR=2.1, nTRs=2','Dots Circumference pRF full blanks TR=2.1, nTRs=2','Dots Shapes pRF full blanks TR=2.1, nTRs=2','Dots Dense pRF full blanks TR=2.1, nTRs=2','Number Symbols pRF full blanks TR=2.1, nTRs=2', 'One Dot Sizes pRF full blanks TR=2.1, nTRs=2', 'One Dot Sizes Constant Step pRF full blanks TR=2.1, nTRs=2','One Dot Double Sizes pRF full blanks TR=2.1, nTRs=2','One Line Size Random Orientation pRF full blanks TR=2.1, nTRs=2','One Dot Luminance pRF full blanks TR=2.1, nTRs=2','Dots Small', 'Dots Attention', 'Dots Gaussian', 'Perspective Calibration', 'Dots psychophysics', 'Dots HRF', 'Dots Area pRF full blanks 4degree low numbers TR=1.95, nTRs=2', 'Dots Area pRF full blanks 4degree high numbers TR=1.95, nTRs=2', 'Timing pRF TR=2.1, Constant Event Number', 'Timing pRF TR=2.1, Duration Constant Frequency','Timing pRF TR=2.1, Constant Event Duration', 'Timing pRF TR=2.1, Event Number Constant Frequency','Timing pRF TR=2.1, Constant Set Duration',},
        %Do nothing, stimulus generated on-the-fly
    case {'8 bars with blanks (magno)', '8 bars with blanks (parvo)'},
        [stimulus otherSequence] = makeRetinotopyStimulus_magno_parvo(params);
    case {'8 bars with blanks (attention)', '8 bars with blanks (attention bar psychophysics)', '8 bars with blanks (attention fixation psychophysics)'},
        [stimulus otherSequence] = makeRetinotopyStimulus_attention(params);
        %[stimulus otherSequence] = makeRetinotopyStimulus_barsLR3(params);
    case 'left vs right vs blank'
        [stimulus otherSequence] =makeRetinotopyStimulus_lrb(params);
    case {'radial checkerboard fast', 'radial checkerboard slow temporal', 'radial checkerboard slow spatial',}
        [stimulus] =makeRetinotopyStimulus_checkSpeedECoG(params);
    case {'radial checkerboard localizer left-still-right-still'}
        [stimulus] =makeRetinotopyStimulus_checkLeftStillRight(params);
    case {'pRF bars simultaneous 2h/3v', 'pRF bars simultaneous 3h/4v', 'pRF bars simultaneous 3h/4v (TR 2.1)'},
        [stimulus otherSequence] = makeRetinotopyStimulus_simultaneous(params);
    otherwise,
        stimulus = makeRetinotopyStimulus(params);
end;

% keep original stimulus structure (because createTextures replaces images by textures)
if exist('stimulus', 'var')
    original_stimulus = stimulus; %#ok<NASGU>
end


% allow stimulus to start a little earlier
% stimulus.offset = 3; % secs
% if stimulus.offset>0
%     stimulus.unclipped = stimulus; % keep the old one just in case
%     
%     stimulus.seqtimging = stimulus.seqtiming-stimulus.offset;
%     keep = stimulus.seqtiming>=0;
%     stimulus.seq = stimulus.seq(keep);
%     stimulus.seqtiming = stimulus.seqtiming(keep);
%     stimulus.fixSeq = stimulus.fixSeq(keep);
%     if exist('otherSequence')
%         otherSequence = otherSequence(keep);
%     end
% end

% loading mex functions for the first time can be
% extremely slow (seconds!), so we want to make sure that 
% the ones we are using are loaded.
KbCheck;GetSecs;WaitSecs(0.001);

try
    % check for OpenGL
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
        case{'8 bars with blanks (attention)', '8 bars with blanks (attention fixation psychophysics)', '8 bars with blanks (attention bar psychophysics)', '8 bars with blanks (attention checkerboard)'}
            stimulus = createTexturesAttention(params.display,stimulus);
        case {'Numbers and Dots Scaled', 'Numbers and Dots Unscaled','Numbers Only', 'Dots Unscaled', 'Dots Scaled', 'Dots Scaled Reverse', 'Dots Scaled pRF', 'Dots Scaled pRF full blanks','Dots Scaled pRF short', 'Dots Scaled pRF full blanks short','Dots Area pRF full blanks TR=1.5, nTRs=3','Dots Size pRF full blanks TR=1.5, nTRs=3', 'Numbers Size pRF full blanks TR=1.5, nTRs=3','Dots Shapes pRF full blanks TR=1.5, nTRs=3', 'Dots Circumference pRF full blanks TR=1.5, nTRs=3', 'Dots Dense pRF full blanks TR=1.5, nTRs=3', 'Dots Size pRF full blanks ECoG TR=1.5, nTRs=3', 'Dots Size pRF ECoG long random order','Dots Area pRF full blanks TR=2.1, nTRs=2','Dots Size pRF full blanks TR=2.1, nTRs=2','Dots Circumference pRF full blanks TR=2.1, nTRs=2','Dots Shapes pRF full blanks TR=2.1, nTRs=2','Dots Dense pRF full blanks TR=2.1, nTRs=2','Number Symbols pRF full blanks TR=2.1, nTRs=2','One Dot Sizes pRF full blanks TR=1.5, nTRs=3','One Dot Sizes pRF full blanks TR=2.1, nTRs=2','One Dot Double Sizes pRF full blanks TR=2.1, nTRs=2','One Dot Sizes Constant Step pRF full blanks TR=2.1, nTRs=2','One Line Size Random Orientation pRF full blanks TR=2.1, nTRs=2','One Dot Luminance pRF full blanks TR=2.1, nTRs=2', 'Dots Area pRF full blanks 4degree low numbers TR=1.95, nTRs=2', 'Dots Area pRF full blanks 4degree high numbers TR=1.95, nTRs=2','Timing pRF TR=2.1, Constant Event Number', 'Timing pRF TR=2.1, Duration Constant Frequency','Timing pRF TR=2.1, Constant Event Duration', 'Timing pRF TR=2.1, Event Number Constant Frequency', 'Timing pRF TR=2.1, Constant Set Duration','Dots Small', 'Dots Attention', 'Dots Gaussian', 'Perspective Calibration', 'Dots psychophysics', 'Dots HRF'},
            %Do nothing, stimulus generated on-the-fly
        case {'Dots In Noise pRF full blanks TR=1.5, nTRs=3'}
            stimulus = createTexturesNoiseDots(params.display);
        case {'pRF bars simultaneous 2h/3v', 'pRF bars simultaneous 3h/4v', 'pRF bars simultaneous 3h/4v (TR 2.1)'},
            Screen('LoadNormalizedGammaTable', params.display.windowPtr, stimulus.cmap);
            stimulus = createTextures(params.display,stimulus);
            params.display.fixColorRgb=[1 1 1;2 2 2];
            %Screen('LoadNormalizedGammaTable', params.display.windowPtr, stimulus.cmap_original);
        otherwise
            stimulus = createTextures(params.display,stimulus);
    end

    % getting to the source rather than doScan->doTrial->showStimulus 
    for n = 1:params.repetitions,
        % set priority
        Priority(2);
        
        % reset colormap?
        resetColorMap(params);
        
        % flush the device
        deviceUMC('read',params.devices.UMCport);
        
        % wait for go signal
%         if params.display.stereoFlag==1
%             %make texture for calibration lines and fusion background
%             params.display.calibrate=0;
%             stimulus.backgroundTexture=fusionBackGround(params.display, params);
%             dispStringInCenterStereo(params.display,'Waiting for scanner to start',0.6,40,[0 0 0], stimulus);
%             [dummyonold, time0]=deviceUMC('wait for trigger',params.devices.UMCport); 
%         elseif strcmp(params.experiment, 'pRF bars simultaneous 3h/4v') || strcmp(params.experiment, 'pRF bars simultaneous 3h/4v (TR 2.1)')
%             frame=1;
%             drawFixation(params.display,stimulus.fixSeq(frame));
%             Screen('Flip',params.display.windowPtr);
%             t0=GetSecs;
%             trig=[];
%             while(isempty(trig))
%                 waitTime = (GetSecs-t0)-stimulus.seqtiming(frame);
%                 while(waitTime<0)
%                     if params.devices.UMCport<0
%                         [output] = KbCheck;
%                     else
%                         [output]=deviceUMC('trigger',params.devices.UMCport);
%                     end
%                     if output
%                         trig=1;
%                         time0=GetSecs;
%                         break;
%                     end
%                     WaitSecs(0.01);
%                     waitTime = (GetSecs-t0)-stimulus.seqtiming(frame);
%                 end
%                 frame=frame+1;
%                 drawFixation(params.display,stimulus.fixSeq(frame));
%                 Screen('Flip',params.display.windowPtr);
%             end
%         else
%             dispStringInCenter(params.display,'Waiting for scanner to start',0.6,40,[0 0 0]);
%             [dummyonold, time0]=deviceUMC('wait for trigger',params.devices.UMCport); 
%         end
         
switch params.eyeTracker
    case {1}
        eyelinkGray = [125 125 125];
        fileNameStart = datestr(now,30);
        fileEdf = [ fileNameStart( (length(fileNameStart)-5) : length(fileNameStart)) '.edf' ];
        Screen('FillRect',params.display.windowPtr,eyelinkGray);
        Screen('Flip',params.display.windowPtr);
        WaitSecs(0.5);
        if (Eyelink('initialize') ~= 0)
            return;
        end;


        el=EyelinkInitDefaults( params.display.windowPtr );
        el = initEyelink_01(el, params.display.rect, eyelinkGray, [0 0 0], 0, fileEdf);
        %Eyelink('Command', 'enable_automatic_calibration = YES');
        %Eyelink('command', 'link_sample_data = LEFT,RIGHT,GAZE,AREA');
        %Eyelink('command','screen_pixel_coords = 0 0 1920 1080' );
        %Eyelink('command', 'calibration_type = HV5');
        %Eyelink('command', 'screen_distance = 600 660');
        
        el.callback=[];
        
        Eyelink('openfile', fileEdf);
        WaitSecs(0.1);
        Screen('Flip',params.display.windowPtr);
        
        EyelinkDoTrackerSetup(el);
        %EyelinkDoDriftCorrection(el);
        
        Eyelink('StartRecording');
        
        WaitSecs(0.1);
        
        % mark zero-plot time in data file
        %Eyelink('Message', 'Start_Stimuli');
end


         dispStringInCenter(params.display,'Waiting for scanner to start',0.6,40,[0 0 0]);
         KbTriggerWait(KbName('t'),-3)%-3 makes sure the Forb box is caught
         time0=GetSecs;
         switch params.eyeTracker
             case {1}
                 Eyelink('Message', 'Start_Stimuli');
         end
%         tmp = Screen('MakeTexture',params.display.windowPtr, ...
%             zeros(768,1024));
%         Screen('DrawTexture', params.display.windowPtr, tmp);
%         Screen('Flip',params.display.windowPtr);

         
        if params.devices.UMCport==2
            system('say -v Vicki stimulus started &'); % in the background
        end

        % go
        switch params.experiment
            case {'8 bars with blanks RDK (0)', '8 bars with blanks RDK (90)', '8 bars with blanks RDK (-45)', '8 bars with blanks RDK (+45)', '8 bars with blanks RDK (random)', '8 bars with blanks RDK (90) Fast', '8 bars with blanks RDK (90) Medium', '8 bars with blanks RDK (90) Slow','8 bars with blanks RDK (0) Fast', '8 bars with blanks RDK (0) Medium', '8 bars with blanks RDK (0) Slow'},
                [response, dummyonold, quitProg] = showScanStimulusRDK(params.display,stimulus,time0);
            case {'Full-field full'},
                [response, dummyonold, quitProg] = showScanStimulus(params.display,stimulus,time0);
            case {'8 bars with blanks Cow (0) Slow','8 bars with blanks Cow (0) Medium','8 bars with blanks Cow (0) Fast','8 bars with blanks Cow (90) Slow', '8 bars with blanks Cow (90) Medium','8 bars with blanks Cow (90) Fast','8 bars with blanks Cow (Flicker) Slow','8 bars with blanks Cow (Flicker) Fast', 'Cow Full Fast','Cow Full Medium','Cow Full Slow','Cow Full Still'},
                [response, dummyonold, quitProg, stimulus] = showScanStimulusMovingImage(params.display,stimulus,params,time0);
            case {'Numbers and Dots Scaled', 'Numbers and Dots Unscaled','Numbers Only', 'Dots Unscaled', 'Dots Scaled', 'Dots Scaled Reverse', 'Dots Scaled pRF', 'Dots Scaled pRF full blanks', 'Dots Scaled pRF short', 'Dots Scaled pRF full blanks short','Dots Area pRF full blanks TR=1.5, nTRs=3','Dots Size pRF full blanks TR=1.5, nTRs=3', 'Numbers Size pRF full blanks TR=1.5, nTRs=3','Dots Shapes pRF full blanks TR=1.5, nTRs=3','Dots Circumference pRF full blanks TR=1.5, nTRs=3', 'Dots Dense pRF full blanks TR=1.5, nTRs=3','Dots Size pRF full blanks ECoG TR=1.5, nTRs=3','Dots Size pRF ECoG long random order','One Dot Sizes pRF full blanks TR=1.5, nTRs=3','Dots In Noise pRF full blanks TR=1.5, nTRs=3', 'Dots Area pRF full blanks TR=2.1, nTRs=2','Dots Size pRF full blanks TR=2.1, nTRs=2','Dots Circumference pRF full blanks TR=2.1, nTRs=2','Dots Dense pRF full blanks TR=2.1, nTRs=2','Dots Shapes pRF full blanks TR=2.1, nTRs=2','Number Symbols pRF full blanks TR=2.1, nTRs=2','One Dot Sizes pRF full blanks TR=2.1, nTRs=2','One Dot Sizes Constant Step pRF full blanks TR=2.1, nTRs=2','One Dot Double Sizes pRF full blanks TR=2.1, nTRs=2','One Line Size Random Orientation pRF full blanks TR=2.1, nTRs=2','One Dot Luminance pRF full blanks TR=2.1, nTRs=2', 'Dots Area pRF full blanks 4degree low numbers TR=1.95, nTRs=2', 'Dots Area pRF full blanks 4degree high numbers TR=1.95, nTRs=2','Dots Small', 'Dots Attention', 'Dots Gaussian', 'Dots HRF'},
                if exist('stimulus', 'var')
                    [response, dummyonold, quitProg, stimulus] = showScanStimulusNumbersDots(params.display, params, time0, stimulus);
                else
                    [response, dummyonold, quitProg, stimulus] = showScanStimulusNumbersDots(params.display, params, time0);
                end
                
            case {'Timing pRF TR=2.1, Constant Event Number', 'Timing pRF TR=2.1, Duration Constant Frequency','Timing pRF TR=2.1, Constant Event Duration', 'Timing pRF TR=2.1, Event Number Constant Frequency','Timing pRF TR=2.1, Constant Set Duration'}
                if exist('stimulus', 'var')
                    [response, dummyonold, quitProg, stimulus] = showScanStimulusTiming(params.display, params, time0, stimulus);
                else
                    [response, dummyonold, quitProg, stimulus] = showScanStimulusTiming(params.display, params, time0);
                end
            case {'Dots psychophysics'}
                [response, dummyonold, quitProg] = showPsychophysicsStimulusNumbersDots(params.display, params, time0);
            case {'full-field, flicker (check), stereo'}
                [response, dummyonold, quitProg] = showScanStimulusStereo(params.display, params,stimulus,time0);
            case{'Perspective Calibration'}
                [response, dummyonold, quitProg] = showPerspectiveCalibration(params.display, params,stimulus);
            case{'8 bars with blanks (attention)'}
                [response, dummyonold, quitProg, params] = showScanStimulusAttention(params.display, params,stimulus,time0);
            case{'8 bars with blanks (attention checkerboard)'}
                [response, dummyonold, quitProg, params] = showScanStimulusAttentionChecksRSVP(params.display, params,stimulus,time0);
            case{'8 bars with blanks (attention bar psychophysics)'}
                [response, dummyonold, quitProg, params] = showScanStimulusAttentionPsychophysics(params.display, params,stimulus,time0);
            case{'8 bars with blanks (attention fixation psychophysics)'}
                [response, dummyonold, quitProg, params] = showScanStimulusAttentionFixationMeanContrast(params.display, params,stimulus,time0);
%             case{'8 bars with blanks (magno)', '8 bars with blanks (parvo)'}
%                 [response, dummyonold, quitProg] = showScanStimulusFast(params.display,stimulus,time0);
            case{'Sine motion psychophysics(90)'}
                [response, timing, quitProg, params] = showScanStimulusMotionPsychophysics(params.display,params, stimulus, time0);

            otherwise
                [response, dummyonold, quitProg, storeFlips] = showScanStimulus(params.display,stimulus,time0);
        end
        
        switch params.eyeTracker
            case {1}
                Eyelink('Command', 'enable_automatic_calibration = YES');
                % mark end time in data file
                Eyelink('Message', 'End_Stimuli');
                WaitSecs(0.1);
                Eyelink('StopRecording');
                Eyelink('CloseFile');
                WaitSecs(1);
                status = Eyelink('receivefile','',fileEdf);
                Eyelink('shutdown');
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
        try
            [pc,rc] = getFixationPerformance(params.fix,stimulus,response);
            fprintf('[%s]:Fixation dot task: percent correct: %.1f %%, reaction time: %.1f secs\n',mfilename,pc,rc);
        end
        
        % get other detection performance
        if exist('otherSequence','var') && ~isempty(otherSequence),
            [pc,rc] = getDetectionPerformance(params.fix,stimulus,response,otherSequence);
             fprintf('[%s]:Other task: percent correct: %.1f %%, reaction time: %.1f secs\n',mfilename,pc,rc);
        end;
        
        % save 
        if params.savestimparams,
             directory = uigetdir(pwd,'pick the directory to save the stimulus file');
%            directory = 'H:\Serges_Group\Ben\matfiles';
            filename = [directory '\' datestr(now,30) '.mat'];
          %  filename = ['H:\Serges_Group\Ben\matfiles\' datestr(now,30) '.mat'];
            save(filename);                % save parameters
            fprintf('[%s]:Saving in %s.\n',mfilename,filename);
        end;
        
        % keep going?
        if quitProg, % don't keep going if quit signal is given
            break;
        end
    end
    
catch ME
    % clean up if error occurred
    Screen('CloseAll');
    setGamma(0);
    Priority(0);
    ShowCursor;
    rethrow(ME);
end;


return;


function resetColorMap(params)
switch params.experiment,
    case {'8 bars (slow)'},
        % get subject input on stimulus contrast
        answer = 'a';
        while (~isnumeric(answer) || isempty(answer)),
            % say it just in case the screen is in mirror mode and you
            % cannot see the screen
            if params.display.screenNumber == 0,
                eval('system(sprintf(''say please enter percent stimulus contrast.''));'); 
            end;
            answer = input('Please enter percent stimulus contrast [100]: ');
        end;
        sz = size(params.display.gamma,1)*([-1 1]*answer/100/2+0.5);
        if sz(1)==0,sz(1)=1;end;
        % make new gamma
        putgamma = zeros(256,3);
        putgamma(2:255,:) = params.display.gamma(round(linspace(sz(1),sz(2),254)),:);
        % load gamma
        putgamma(1,:)   = params.display.fixColorRgb(1,1:3)./255;
        putgamma(256,:) = params.display.fixColorRgb(2,1:3)./255;
        Screen('LoadNormalizedGammaTable', params.display.screenNumber,putgamma);
        
    case {'8 bars (LMS)','8 bars (LMS) with blanks'},
        % get subject input on stimulus type 
        answer = 'a';
        while (~isnumeric(answer) || isempty(answer) || answer>3 || answer<1),
            % say it just in case the screen is in mirror mode and you
            % cannot see the screen
            if params.display.screenNumber == 0,
                eval('system(sprintf(''say please enter  stimulus type 1, 2, or 3.''));'); 
            end;
            answer = input('Please enter  stimulus type [1=LMS,2=L-M,3=S]: ');
        end;
        if answer == 1,
            stimtype = [ 1 1 1];
        elseif answer == 2,
            stimtype = [-1 1 0];
        else
            stimtype = [0 0 1];
        end
        
        % get subject input on stimulus contrast
        answer = 'a';
        while (~isnumeric(answer) || isempty(answer) || answer<0 || answer>100),
            % say it just in case the screen is in mirror mode and you
            % cannot see the screen
            if params.display.screenNumber == 0,
                eval('system(sprintf(''say please enter percent stimulus contrast 0 to 100.''));'); 
            end;
            answer = input('Please enter percent stimulus contrast: ');
        end;
        stimcontrast = answer;
        
        
        sz = size(params.display.gamma,1)*([-1 1]*answer/100/2+0.5);
        if sz(1)==0,sz(1)=1;end;
        % make new gamma        
        newgamma = create_LMScmap(params.display,stimtype.*(stimcontrast./100));
        putgamma = zeros(256,3);
        if size(newgamma,1)~=256,
            putgamma(2:255,:) = newgamma(round(linspace(1,size(newgamma,1),254)),:);
        end;
        % load gamma
        putgamma(1,:)   = params.display.fixColorRgb(1,1:3)./255;
        putgamma(256,:) = params.display.fixColorRgb(2,1:3)./255;
        Screen('LoadNormalizedGammaTable', params.display.screenNumber,putgamma);

        
        
    otherwise,
        % well.. nothing
end;
return;
