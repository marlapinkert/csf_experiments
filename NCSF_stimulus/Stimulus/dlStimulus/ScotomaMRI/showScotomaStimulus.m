function [pa,ds,response,data,quitProg] = showScotomaStimulus(pa,ds,stimulus,t0)

% quit key
try
    quitProgKey = display.quitProgKey;
catch
    quitProgKey = KbName('q');
end;

leftKey = KbName('LeftArrow');
rightKey = KbName('RightArrow');
upKey = KbName('UpArrow');
downKey = KbName('DownArrow');

% Run experiment (press 'q' to quit)
pa.deltaT = 0;
quitProg = 0;

% t0=GetSecs;
% ds.vbl = t0;
vbls = t0;

screendump = 0;
iframe = 0;
startFrame = 0;


data = nan(pa.numberOfTrials,6);

response.keyCode = [];
response.secs = [];

if isfield(ds,'horizontalOffset')
    xPos = [ds.fixX - ds.horizontalOffset ds.fixX + ds.horizontalOffset];
else
    xPos = [ds.fixX ds.fixX];
end


for trialii = 1:pa.numberOfTrials;
    
    thistrialresponse = NaN;
    thistrialresponsetime = 0;
    
    pa.trial = pa.trialLocations(pa.design(trialii),:);
    
    pa.trial(3) = 1 + round(rand());
    
    % Center textures on holes in swiss cheese texture
    for eye = 0:1
        [x, y] = pol2cart(d2r(pa.thetaDirs(pa.trial(1)) - (2*(eye-.5))*ds.screenRotation), ds.ppd.*pa.rDirs(pa.trial(2)));
        %dstRect = CenterRect([0 0 pa.apertureRadius pa.apertureRadius], ds.rect');

        dstRect = CenterRectOnPointd([0 0 pa.apertureRadius pa.apertureRadius],xPos(eye+1),ds.fixY);

        dstRect = OffsetRect(dstRect,x,-y);  % NOTE: -y because pol2cart and OffsetRect differ on what is up & down

        [ds.dstCenter(eye+1, 1), ds.dstCenter(eye+1, 2)] = RectCenter(dstRect);
    end
    
    ds.vbl = GetSecs;
    tStart = ds.vbl;
    
    % Get new dots
    pa.dots = [];
    pa.dotKillTime = [];
    pa.distanceBeforeKill = [];
    
    pa.dotKillTime = ((2*pa.disparityLimit)/pa.speed)*rand(pa.numberOfDots,1) + ds.vbl; % random 'kill' time in seconds for new set of dots between ds.vbl (0) and ds.vbl+maxtime (will be used to determine the z location)
    
    pa.distanceBeforeKill = pa.speed*(pa.dotKillTime-ds.vbl); % how far the dot will travel in deg.
    
    pa = NewDots(ds,pa,1:pa.numberOfDots); % optimized code
    
    
    pa.deltaT = 0;
    
    preStimDur = rand*pa.preStimDuration;
    %postStimDur = pa.framePeriod-(preStimDur+pa.stimDuration);
    
    
    while ds.vbl < tStart + (2*pa.framePeriod) && ~quitProg
        
        
        if ds.vbl < tStart + preStimDur
            Screen('SelectStereoDrawBuffer',ds.windowPtr,0);
            drawBackground(ds,stimulus,0);
            Screen('SelectStereoDrawBuffer',ds.windowPtr,1);
            drawBackground(ds,stimulus,1);
            
            
            Screen('SelectStereoDrawBuffer',ds.windowPtr,0);
            drawFixation(ds,[],0);
            Screen('SelectStereoDrawBuffer',ds.windowPtr,1);
            drawFixation(ds,[],1);
            
        elseif ds.vbl > tStart+preStimDur && ds.vbl < tStart + (preStimDur+pa.stimDuration)
            
            if screendump
                pa.xoffset = (1/30) * pa.speed;
            else
                pa.xoffset = pa.deltaT * pa.speed;
            end
            
            pa = UpdateDotPositions(pa,ds);
            
            DrawDots(ds,pa);
            
            Screen('SelectStereoDrawBuffer',ds.windowPtr,0);
            drawBackground(ds,stimulus,0);
            Screen('SelectStereoDrawBuffer',ds.windowPtr,1);
            drawBackground(ds,stimulus,1);
            
            
            Screen('SelectStereoDrawBuffer',ds.windowPtr,0);
            drawFixation(ds,[],0);
            Screen('SelectStereoDrawBuffer',ds.windowPtr,1);
            drawFixation(ds,[],1);
            
        elseif ds.vbl > tStart + (preStimDur+pa.stimDuration)
            
            Screen('SelectStereoDrawBuffer',ds.windowPtr,0);
            drawBackground(ds,stimulus,0);
            Screen('SelectStereoDrawBuffer',ds.windowPtr,1);
            drawBackground(ds,stimulus,1);
            
            
            Screen('SelectStereoDrawBuffer',ds.windowPtr,0);
            drawFixation(ds,[0 255 0],0);
            Screen('SelectStereoDrawBuffer',ds.windowPtr,1);
            drawFixation(ds,[0 255 0],1);
            
        end;
        
        % Scan the UMC device for subject response
        [ssKeyCode,ssSecs] = deviceUMC('response',ds.devices.UMCport);
        
        %            kc = find(ssKeyCode);
        %            response.keyCode(frame) = kc(1); % binary response for now
        
        if ssKeyCode==65 && ds.calibrate
            ds.horizontalOffset = ds.horizontalOffset + 5;
        elseif ssKeyCode==68 && ds.calibrate
            ds.horizontalOffset = ds.horizontalOffset - 5;
        elseif ssKeyCode==66 && ds.calibrate
            ds.screenRotation=ds.screenRotation+2.25;
        elseif ssKeyCode==67 && ds.calibrate
            ds.screenRotation=ds.screenRotation-2.25;
            
        elseif ssKeyCode==66
            ds.screenRotation=ds.screenRotation+0.25;
        elseif ssKeyCode==67
            ds.screenRotation=ds.screenRotation-0.25;
            
                    elseif(ssKeyCode(1)~=0)
                        response.keyCode(end+1) = ssKeyCode(end);
                        response.secs(end+1)    = ssSecs - t0;
                        
                        if isnan(thistrialresponse)
                            thistrialresponse = ssKeyCode(end);
                            thistrialresponsetime = ssSecs - t0;
                        end
        end
        
        % scan the keyboard for experimentor input
        [exKeyIsDown,exSecs,exKeyCode] = KbCheck(ds.devices.keyInputInternal);
        if(exKeyIsDown)
            if exKeyCode(upKey) && ds.calibrate
                ds.horizontalOffset = ds.horizontalOffset + 1;
            elseif exKeyCode(downKey) && ds.calibrate
                ds.horizontalOffset = ds.horizontalOffset - 1;
            elseif exKeyCode(leftKey) && ds.calibrate
                ds.screenRotation=ds.screenRotation+0.25;
            elseif exKeyCode(rightKey) && ds.calibrate
                ds.screenRotation=ds.screenRotation-0.25;
                
            elseif exKeyCode(leftKey)
                ds.screenRotation=ds.screenRotation+0.25;
            elseif exKeyCode(rightKey)
                ds.screenRotation=ds.screenRotation-0.25;
                
                            elseif exKeyCode(upKey)
                                response.keyCode(end+1) = 65;%ssKeyCode(end);
                                response.secs(end+1)    = exSecs - t0;
                                thistrialresponse = 65;
                            elseif exKeyCode(downKey)
                                response.keyCode(end+1) = 68;%ssKeyCode(end);
                                response.secs(end+1)    = exSecs - t0;
                                thistrialresponse = 68;
            elseif(exKeyCode(quitProgKey)),
                quitProg = 1;
                break; % out of while loop
            end;
            
             
        end
        
         ds.screenRotationRadian = (ds.screenRotation/360)*(2*pi);
        ds.vbl = Screen('Flip',ds.windowPtr,ds.vbl);%+(1/60));
        
        vbls(end+1) = ds.vbl;
        pa.deltaT = vbls(end) - vbls(end-1);
        
    end
    
    if quitProg,
        return;
    end
    
    data(trialii,:) = [trialii thistrialresponse thistrialresponsetime pa.directions(pa.trial(3)) pa.thetaDirs(pa.trial(1)) pa.rDirs(pa.trial(2))];
    
end

return;
end