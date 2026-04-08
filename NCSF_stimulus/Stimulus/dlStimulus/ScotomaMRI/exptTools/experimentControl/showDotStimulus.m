function [response, timing, quitProg] = showDotStimulus(params, stimulus, t0, dotparams, duration, pregenbars, BGdots, BGdotColors)
% [response, timing] = showStimulus(display,stimulus, time0)
%
% t0 is the time the scan started and the stimulus timing should be
% relative to t0. If t0 does not exist it is created at the start of
% this program.
%  
% HISTORY:
% 2005.02.23 RFD: ported from showStimulus.
% 2005.06.15 SOD: modified for OSX. Use internal clock for timing rather
% than framesyncing because getting framerate does not always work. Using
% the internal clock will also allow some "catching up" if stimulus is
% delayed for whatever reason. Loading mex functions is slow, so this 
% should be done before callling this program.

% input checks
if nargin < 2,
	help(mfilename);
    return;
end;
if nargin < 3 || isempty(t0),
    t0 = GetSecs; % "time 0" to keep timing going
end;

display = params.display;

% quit key
try
    quitProgKey = display.quitProgKey;
catch
    quitProgKey = KbName('q');
end;

leftKey=KbName('z');
rightKey=KbName('x');

% some variables

HideCursor; GetSecs;

%response.keyCode = zeros(length(stimulus.seq),1); % get 1 buttons max
%response.secs = zeros(size(stimulus.seq));        % timing
quitProg = 0;

% go
fprintf('[%s]:Running. Hit %s to quit.',mfilename,KbName(quitProgKey));


%dotparams.motionDir = 2*round(rand)-1;

% % Timing
% %duration.stimframe          = 1./params.temporal.frequency./params.temporal.motionSteps;
% duration.scan.seconds       = params.ncycles*params.period;
% %duration.scan.stimframes    = params.ncycles*params.period./duration.stimframe;
% duration.cycle.seconds      = params.period;
% %duration.cycle.stimframes   = params.period./duration.stimframe;
% duration.prescan.seconds    = params.prescanDuration;
% %duration.prescan.stimframes = params.prescanDuration./duration.stimframe;
% 
% duration.prescan.stimframes = params.prescanDuration ./ params.tr;
% 
% if params.insertBlanks.do
%     blankTime = 30; %~30sec blanks
%     totalBlankTime   = 4.*ceil(blankTime./params.tr).*params.tr; % make sure it is a multiple of the tr
%     barPassTime=duration.cycle.seconds-totalBlankTime;
% else
%     barPassTime=duration.cycle.seconds;
% end
% 
% dotparams.fixationDotTiming = dotparams.fixChangeTime:dotparams.fixChangeTime:(duration.cycle.seconds+duration.prescan.seconds);
% fixationDotSequence = repmat([1; -1; 0], floor(length(dotparams.fixationDotTiming)/12), 1);
% fixationDotSequence = fixationDotSequence(randperm(size(fixationDotSequence,1)));
% dotparams.fixationDotSequence(2:4:length(dotparams.fixationDotTiming)) = fixationDotSequence;
% 
% disp(size(dotparams.fixationDotSequence));
% 
% % TODO: fix the stepsize because there are way to many steps now
% step_nx      = (barPassTime)./params.tr/8;
% stepradius   = angle2pix(display,params.radius) - round(dotparams.barwidth./4);
% step_x       = linspace(-stepradius, stepradius, step_nx);%(2*outerRad) ./ step_nx;

%fprintf('[%s]:stepsize: %f pixels.',mfilename,step_x); 

% vbl = Screen('Flip',display.windowPtr);
% prevvbl = vbl

response.keyCode = zeros(length(dotparams.fixationDotSequence),1);
response.correct_response = zeros(length(dotparams.fixationDotSequence),1);
fixationDotIndex = 1;

dotColors = Shuffle([zeros(round((dotparams.numberofdots)./2),1); 255.*ones(round((dotparams.numberofdots)./2),1)]);
dotColors = repmat(dotColors,1,3)';

% display.screenRotation = 20;
display.screenRotationRadian = (display.screenRotation/360)*(2*pi); % convert to radians


% START OF EXPERIMENT

for orii = 1:length(stimulus.orientations)
    dotparams.orientation = stimulus.orientations(orii);
    
    if dotparams.orientation==-1 % prescan stimulus
       
        dotparams.orientation = stimulus.orientations(end);
        step_x = dotparams.step_x(end-duration.prescan.stimframes+1:end);
        
    else
        step_x = dotparams.step_x;
    end
    
    
    if isnan(dotparams.orientation) % if orientation=NaN then present blank
        bStart = GetSecs;
        vbl = bStart;
        
        while (vbl-bStart) <= duration.blankTime
            
            Screen('SelectStereoDrawBuffer',display.windowPtr,0);
            drawBackground(display,stimulus, 0); % 1/f noise background
            
            Screen('SelectStereoDrawBuffer',display.windowPtr,1);
            drawBackground(display,stimulus, 1); % 1/f noise background
            
            fixationDotIndex = drawFixationStereo(display,t0, dotparams, fixationDotIndex);
            
                [ssKeyCode] = deviceUMC('response',display.devices.UMCport);

                if (ssKeyCode(end)==67) || (ssKeyCode(end)==68)
                    response.keyCode(fixationDotIndex) = ssKeyCode(end);
                    
                    if ssKeyCode(end)==67 && ...
                       (dotparams.fixationDotSequence(fixationDotIndex)==-1) ||...
                       (dotparams.fixationDotSequence(max(fixationDotIndex-1,1))==-1) ||...
                       (dotparams.fixationDotSequence(max(fixationDotIndex-2,1))==-1)                           
                        response.correct_response(fixationDotIndex) = 1;
                    elseif ssKeyCode(end)==68 && ...
                       (dotparams.fixationDotSequence(fixationDotIndex)==1) ||...
                       (dotparams.fixationDotSequence(max(fixationDotIndex-1,1))==1) ||...
                       (dotparams.fixationDotSequence(max(fixationDotIndex-2,1))==1)                            
                        response.correct_response(fixationDotIndex) = 1;
                    else
                        response.correct_response(fixationDotIndex) = 0;
                    end
                        
                    %response.secs(frame)    = ssSecs - t0;
                end 
                
                %scan the keyboard for experimentor input
                [exKeyIsDown,exSecs,exKeyCode] = KbCheck(display.devices.keyInputInternal);
                if(exKeyIsDown && exKeyCode(quitProgKey))
                    quitProg = 1;
                    break; % out of while loop
                elseif exKeyIsDown && exKeyCode(leftKey)
                    
                    if (dotparams.fixationDotSequence(fixationDotIndex)==-1) ||...
                       (dotparams.fixationDotSequence(max(fixationDotIndex-1,1))==-1) ||...
                       (dotparams.fixationDotSequence(max(fixationDotIndex-2,1))==-1)
                        response.correct_response(fixationDotIndex) = 1;
                    else
                        response.correct_response(fixationDotIndex) = 0;
                    end
                    
                elseif exKeyIsDown && exKeyCode(rightKey)
                    
                    if (dotparams.fixationDotSequence(fixationDotIndex)==1) ||...
                       (dotparams.fixationDotSequence(max(fixationDotIndex-1,1))==1) ||...
                       (dotparams.fixationDotSequence(max(fixationDotIndex-2,1))==1)
                        response.correct_response(fixationDotIndex) = 1;
                    else
                        response.correct_response(fixationDotIndex) = 0;
                    end                   
                    
                end;
            
            
            %--- update screen
            vbl = Screen('Flip',display.windowPtr);

        end
        
    else % otherwise present bars at selected orientation
        
        mfExtent = -256:1:255;
        nsamp = fft2(randn(length(mfExtent)));
        [xs,ys] = meshgrid(mfExtent,mfExtent);
        rs = sqrt(xs.^2 + ys.^2);
        sf1 = 6;%the upper spatial frequency bound for the spatial correlation (cycles per 512 pixels)
        sf2 = 2;%the lower s.f. bound (cycles per 512 pixels)
        bfilt = ifftshift(exp(-(rs./sf1).^2) - exp(-(rs./sf2).^2));
        nsamp = real(ifft2(nsamp.*bfilt));
        nsamp = pi*nsamp./max(abs(nsamp(:)));%random phase map
        
        for stepii = 1:length(step_x)

            tStart = GetSecs;
            vbl = tStart;
            vbls = [0 vbl];
            
            % Choose starting direction at random
            dotparams.direction = 2*round(rand)-1;
            dotparams.startDir = 1;
            
            % Create new dot-defined bar
            dotparams.dotKillTime = ((2*dotparams.maxdisparity)/dotparams.speed).*rand(dotparams.numberofdots,1) + vbl; % + ds.vbl;  %
            %dotparams.dotKillTime = ones(dotparams.numberofdots,1) + vbl;
            dotparams.distanceBeforeKill = dotparams.speed.*(dotparams.dotKillTime-vbl);
            %sca
            dotparams = NewDotBarUpdated(dotparams, vbl, 1:dotparams.numberofdots);
            
            % Rotate bar for the current position
            %dotparams = InitialBarRotation(dotparams, step_x(stepii));
            
            dotparams.deltaT = 0;
            
            %stimdots = NewDotBar(dotparams, vbl);%pregenbars{orii}{stepii};
            %sca
            
            correlatePhase = 0;
            randStartPhase = NaN+zeros(dotparams.numberofdots,1);
            if(correlatePhase)
                for x = 1:dotparams.numberofdots
                    randStartPhase(x) = nsamp(mfExtent==round(dotparams.dots(x,1)),mfExtent==round(dotparams.dots(x,2)));
                end;
            else
                randStartPhase = 2*pi*rand(dotparams.numberofdots,1);
            end;
            while (vbl-tStart) < params.tr % single TR
                
                
                % At half time, reverse motion direction
%                 if (vbl-tStart) >= (params.tr/2) && dotparams.startDir
%                     dotparams.direction = dotparams.direction * -1;
%                     dotparams.startDir = 0;
%                 end  
                
%                dotparams.dots(:,4) = dotparams.direction;
                
                % dotparams.xoffset = dotparams.deltaT * dotparams.speed;
                
                %dotparams.xoffset = sin((2*pi)*dotparams.speedDeg*(vbl-tStart));% * dotparams.maxdisparity/2;
                %dotparams.xoffset = dotparams.maxdisparity./10 * sin(vbl + randphase);
                dotparams.xoffset = dotparams.maxdisparity * sin((4*pi * vbl)./params.imageDuration + randStartPhase);
                %sca
                
                % Update dot positions for next presentation
                %Loffset = dotparams.maxdisparity * sin(stimdots(:,4)*deg2rad(dotparams.speed)*vbl);
                %Roffset = dotparams.maxdisparity * sin(pi+stimdots(:,4)*deg2rad(dotparams.speed)*vbl);
                %Loffset = dotparams.maxdisparity * sin(stimdots(:,4)+dotparams.speed*vbl);
                %Roffset = dotparams.maxdisparity * sin(pi+stimdots(:,4)+dotparams.speed*vbl);               
                
                
                %Loffset = dotparams.maxdisparity * stimdots(:,4)*dotparams.speed*vbl;
                %Roffset = -1*dotparams.maxdisparity * stimdots(:,4)*dotparams.speed*vbl; 
                
                % stimdots (3 x 50): x,y,z by nDots
                % stimdots is independent of orientation
                
                % plotdots is position after applying rotation
                % so this means that plotdots(x) is a function of stimdots(x,y)
%                 (:,1) = (dotparams.dots(:,1)) .* sin(dotparams.orientation) - (stimdots(:,2) + step_x(stepii)) .* cos(dotparams.orientation);
%                 Lplotdots(:,2) = (stimdots(:,1)) .* cos(dotparams.orientation) + (stimdots(:,2) + step_x(stepii)) .* sin(dotparams.orientation);
%                 
%                 Rplotdots(:,1) = (stimdots(:,1)) .* sin(dotparams.orientation) - (stimdots(:,2) + step_x(stepii)) .* cos(dotparams.orientation);
%                 Rplotdots(:,2) = (stimdots(:,1)) .* cos(dotparams.orientation) + (stimdots(:,2) + step_x(stepii)) .* sin(dotparams.orientation);
%                 
                          
                % Update dots based on time passed (still in horizontal
                % orientation)
                 %dotparams = UpdateDotPositions(dotparams, vbl);
                 
                 
                % First rotate bar in correct orientation for this trial
                plotdots(:,1) = (dotparams.dots(:,1)) .* cos(dotparams.orientation) - (dotparams.dots(:,2) + step_x(stepii)).*sin(dotparams.orientation);
                plotdots(:,2) = (dotparams.dots(:,1)) .* sin(dotparams.orientation) + (dotparams.dots(:,2) + step_x(stepii)).*cos(dotparams.orientation);
                
                % Add disparity and rotate the stimulus with the display
                Lplotdots(:,1) = (plotdots(:,1) - (dotparams.dots(:,3) + dotparams.xoffset)) .* cos(-1*display.screenRotationRadian) - (plotdots(:,2)).*sin(-1*display.screenRotationRadian);
                Lplotdots(:,2) = (plotdots(:,1) - (dotparams.dots(:,3) + dotparams.xoffset)) .* sin(-1*display.screenRotationRadian) + (plotdots(:,2)).*cos(-1*display.screenRotationRadian);
                
                if params.dots.lateral
                    Rplotdots(:,1) = (plotdots(:,1) - (dotparams.dots(:,3) + dotparams.xoffset)) .* cos(display.screenRotationRadian) - (plotdots(:,2)).*sin(display.screenRotationRadian);
                    Rplotdots(:,2) = (plotdots(:,1) - (dotparams.dots(:,3) + dotparams.xoffset)) .* sin(display.screenRotationRadian) + (plotdots(:,2)).*cos(display.screenRotationRadian);
                else
                    
                    Rplotdots(:,1) = (plotdots(:,1) + (dotparams.dots(:,3) + dotparams.xoffset)) .* cos(display.screenRotationRadian) - (plotdots(:,2)).*sin(display.screenRotationRadian);
                    Rplotdots(:,2) = (plotdots(:,1) + (dotparams.dots(:,3) + dotparams.xoffset)) .* sin(display.screenRotationRadian) + (plotdots(:,2)).*cos(display.screenRotationRadian);
                
                end
               
%                 Lplotdots = angle2pix(params.display, Lplotdots);
%                 Rplotdots = angle2pix(params.display, Rplotdots);
                
                xPosLeft = display.fixX - display.horizontalOffset;
                xPosRight = display.fixX + display.horizontalOffset;
            
                Screen('SelectStereoDrawBuffer', display.windowPtr, 0);
                
                Screen('DrawDots', display.windowPtr, [Lplotdots(:,1) Lplotdots(:,2)]', dotparams.dotsize, dotColors,[xPosLeft display.fixY],1);
                
                drawBackground(display,stimulus, 0); % 1/f noise background
                
                Screen('SelectStereoDrawBuffer', display.windowPtr, 1);
              
                Screen('DrawDots', display.windowPtr, [Rplotdots(:,1) Rplotdots(:,2)]', dotparams.dotsize, dotColors,[xPosRight display.fixY],1);
                
                drawBackground(display,stimulus, 1); % 1/f noise background
                
                fixationDotIndex = drawFixationStereo(display,t0, dotparams, fixationDotIndex);
                
                [ssKeyCode] = deviceUMC('response',display.devices.UMCport);

                if (ssKeyCode(end)==65) || (ssKeyCode(end)==66)
                    response.keyCode(fixationDotIndex) = ssKeyCode(end);
                    
                    if ssKeyCode(end)==65 && ...
                       (dotparams.fixationDotSequence(fixationDotIndex)==-1) ||...
                       (dotparams.fixationDotSequence(max(fixationDotIndex-1,1))==-1) ||...
                       (dotparams.fixationDotSequence(max(fixationDotIndex-2,1))==-1)                           
                        response.correct_response(fixationDotIndex) = 1;
                    elseif ssKeyCode(end)==66 && ...
                       (dotparams.fixationDotSequence(fixationDotIndex)==1) ||...
                       (dotparams.fixationDotSequence(max(fixationDotIndex-1,1))==1) ||...
                       (dotparams.fixationDotSequence(max(fixationDotIndex-2,1))==1)                            
                        response.correct_response(fixationDotIndex) = 1;
                    else
                        response.correct_response(fixationDotIndex) = 0;
                    end
                        
                    %response.secs(frame)    = ssSecs - t0;
                end 
                
                %scan the keyboard for experimentor input
                [exKeyIsDown,exSecs,exKeyCode] = KbCheck(display.devices.keyInputInternal);
                if(exKeyIsDown && exKeyCode(quitProgKey))
                    quitProg = 1;
                    break; % out of while loop
                elseif exKeyIsDown && exKeyCode(leftKey)
                    response.keyCode(fixationDotIndex) = 1;
                    
                    if (dotparams.fixationDotSequence(fixationDotIndex)==-1) ||...
                       (dotparams.fixationDotSequence(max(fixationDotIndex-1,1))==-1) ||...
                       (dotparams.fixationDotSequence(max(fixationDotIndex-2,1))==-1)
                        response.correct_response(fixationDotIndex) = 1;
                        
                    else
                        response.correct_response(fixationDotIndex) = 0;
                    end
                    
                elseif exKeyIsDown && exKeyCode(rightKey)
                    response.keyCode(fixationDotIndex) = 2;
                    
                    if (dotparams.fixationDotSequence(fixationDotIndex)==1) ||...
                       (dotparams.fixationDotSequence(max(fixationDotIndex-1,1))==1) ||...
                       (dotparams.fixationDotSequence(max(fixationDotIndex-2,1))==1)
                        response.correct_response(fixationDotIndex) = 1;
                    else
                        response.correct_response(fixationDotIndex) = 0;
                    end                   
                    
                end;
                %sca
                %--- update screen
                vbl = Screen('Flip',display.windowPtr);
                
                vbls(end+1) = vbl;
                dotparams.deltaT = vbls(end) - vbls(end-1);
                
            end
            
            if quitProg
                break; % go out of this loop
            end
        end
        %toc(t1)
    end
    
    if quitProg
        break; % stop running
    end
end

%disp(sprintf('[%s]:Final screen rotation was: %f' ,mfilename, display.screenRotation));
%save /Users/martijn/Desktop/MRstim-stereo/trunk/Displays/Stereo_7T_projector_UMC_1024x768/screenRotation.mat  -STRUCT display screenRotation;

% that's it
ShowCursor;
timing = GetSecs-t0;
disp(sprintf('[%s]:Stimulus run time: %f seconds [should be: %f].',mfilename,timing,duration.prescan.seconds+duration.cycle.seconds));

return;