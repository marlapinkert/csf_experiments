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

%KbName('UnifyKeyNames'); ListenChar(2);

% quit key
try,
    quitProgKey = params.display.quitProgKey;
catch,
    quitProgKey = KbName('q');
end;

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

try,
    params = setDisplay(params);
    
    % br thinks setRetinotopyParams should be here, after we know the
    % display
    % now set rest of the params
    params = setRetinotopyParams(params.experiment, params);
   
    params.display.white = 255;%[255 255 255];
    params.display.black = 0;%[0 0 0];
    params.display.gray = 127.5;%[127.5 127.5 127.5];
    
    % make/load stimulus
    switch params.experiment

        case { 'Stereo Calibration'},
            %params.ringWidth=1;
            [stimulus]= makeRetinotopyStimulus_bars8Pass(params);
            % mb 010713
             % Store the images in textures
            stimulus = createTextures(params,stimulus);  
                        
        case {'Scotoma stimulus','Vertical motion'}
            
  
            [stimulus]= makeRetinotopyStimulus_dotbars(params);
            
            params = SetupParameters(params.display,params);
            [params.display, stimulus] = MakeTextures(params, params.display,stimulus);
             % Store the images in textures
            stimulus = createTexturesPerimetry(params,stimulus);  
            
            params.display.screenRotationRadian = (params.display.screenRotation/360)*(2*pi);
            
        case {'Retinotopy'}
            [stimulus]= makeRetinotopyStimulus_bars8Pass(params);
            % mb 010713
             % Store the images in textures
            stimulus = createTextures(params,stimulus);              
            
        case {'Localizer'}
            
            [stimulus]= makeRetinotopyStimulus_dotbars(params);
            
            params = SetupLocalizerParameters(params.display,params);
            [params.display, stimulus] = MakeTextures(params, params.display,stimulus);
             % Store the images in textures
            stimulus = createTexturesPerimetry(params,stimulus);
            
            params.display.screenRotationRadian = (params.display.screenRotation/360)*(2*pi);
            
        otherwise,
            stimulus = makeRetinotopyStimulus(params);
             % Store the images in textures
            stimulus = createTextures(params,stimulus);  
    end;
    
    
   
    
    
    % getting to the source rather than doScan->doTrial->showStimulus
    for n = 1:params.repetitions,
        % set priority
        Priority(params.runPriority);
        
        % reset colormap?
        resetColorMap(params);
        
        % flush the device
        deviceUMC('read',params.devices.UMCport);
        
        % wait for go signal
        %drawBackground(params.display,[],[]);
        dispStringInCenter(params.display,'Waiting for scanner to start',0.3,[],'white');

        
        [junk, time0, params.display]=deviceUMC('wait for trigger',params.devices.UMCport, params.display);
        disp(sprintf('[%s]:%s',mfilename,'Waiting for scanner to start'));
        
        % go
        %
        
        t1=tic;
        if any(strcmp(params.experiment,{'Scotoma stimulus','Vertical motion'}))
           [params,params.display,response,data, quitProg] = showScotomaStimulus(params, params.display, stimulus, time0);%, dotparams, duration, stimdots, BGdots, BGdotColors);
            
%             % Check performance
%             pressed = find(response.keyCode);
%             pc = 100 * (sum(response.correct_response(pressed))./length(pressed));
%             
%             
%             %pc = 100*(sum(response.correct_response(find(response.keyCode)))./length(find(response.keyCode)));
%             rc = 0;
%             
%             disp(sprintf('[%s]:Fixation dot task: percent correct: %.1f %%',mfilename,pc));
        elseif any(strcmp(params.experiment,{'Localizer'}))
            [quitProg] = showLocalizerStimulus(params, params.display, stimulus, time0);
            
        else
            [response, junk, quitProg, display] = showScanStimulus(params.display,stimulus,time0);
            %[pc,rc] = getFixationPerformance(params.fix,stimulus,response);
            
            [pCorrect] = computePercentageCorrect(stimulus,response);
                                   
            disp(sprintf('[%s]:Final screen change was: %f (rot), %f (shift)' ,mfilename, display.screenRotation, display.horizontalOffset));
            %save /Users/lab/Desktop/Bas/MRstim-stereo/trunk/Displays/Stereo_7T_projector_UMC_1024x768/screenRotation.mat  -STRUCT display screenRotation;
            %save ~/Desktop/ScannerStimulus/Displays/Stereo_7T_projector_UMC_1024x768/screenRotation.mat  -STRUCT display screenRotation;
            % that's it
            %screenRotation = display.screenRotation;
            %horizontalOffset = display.horizontalOffset;
            
            if exist(['~/Documents/MATLAB/ScannerStimulus/Displays/' params.calibration '/'],'dir')
                save(['~/Documents/MATLAB/ScannerStimulus/Displays/' params.calibration '/screenRotation.mat'],'-STRUCT','display','screenRotation','horizontalOffset');
            end
            
            disp(sprintf('[%s]:Fixation dot task: percent correct: %.1f %%',mfilename,100*pCorrect));
        end
        
        toc(t1)
        
        % reset priority
        Priority(0);
        
        % get performance
        %[pc,rc] = getFixationPerformance(params.fix,stimulus,response);
        %pc = 0; rc = 0;
        %disp(sprintf('[%s]:Fixation dot task: percent correct: %.1f %%, reaction time: %.1f secs',mfilename,pc,rc));
        
        
        
        % get other detection performance
        if exist('otherSequence') && ~isempty(otherSequence),
            [pc,rc,nn] = getDetectionPerformance(params.fix,stimulus,response,otherSequence);
            disp(sprintf('[%s]:Other task: percent correct: %.1f %%, reaction time: %.1f secs',mfilename,pc,rc));
        end;
        
        
        % save
        if params.savestimparams,
            filename = ['~/Desktop/' datestr(now,30) '.mat'];
            save(filename);                % save parameters
            disp(sprintf('[%s]:Saving in %s.',mfilename,filename));
        end;
        
        % keep going?
        if quitProg, % don't keep going if quit signal is given
            break;
        end;
    end;
    
    % Close the one on-screen and many off-screen windows
    closeScreen(params.display);
    Screen('CloseAll'); %ListenChar(0);
catch ME,
    % clean up if error occurred
    Screen('CloseAll');
    setGamma(0);
    Priority(0);
    ShowCursor;
    rethrow(ME);
end;


return;


function resetColorMap(params);
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
        else,
            stimtype = [0 0 1];
        end;
        
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
