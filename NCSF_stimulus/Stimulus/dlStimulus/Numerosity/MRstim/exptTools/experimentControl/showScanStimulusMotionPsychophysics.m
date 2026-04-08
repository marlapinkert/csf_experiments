function [response, timing, quitProg, params] = showScanStimulusMotionPsychophysics(display,params, stimulus, t0)
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

% some more checks
if ~isfield(stimulus,'textures')
	% Generate textures for each image
	disp('WARNING: Creating textures before stimulus presentation.');
	disp(['         This should be done before calling ' mfilename ' for']);
	disp('         accurate timing.  See "makeTextures" for help.');
	stimulus = makeTextures(display,stimulus);
end;

% quit key
quitProgKey = KbName('q'); %#ok<NASGU>
firstIntervalKey=KbName('z');
secondIntervalKey=KbName('a');
nextTrialKey=KbName('space');

% some variables
stimframe = 1./params.temporal.frequency(1)./params.temporal.motionSteps(1);
interval=0.75;
isi=0.5;
psiMin=0;
interval=floor(interval/stimframe);
%isi=ceil(isi/stimframe);
psiMin=floor(psiMin/stimframe);

displacements=[-.8 -.4 -.2 -.1 -.05 0 .05 .1 .2 .4 .8];
directions=[1:4];
speeds=[1:5];

displacementsBlock=repmat(displacements, 1, length(directions)*length(speeds))';
directionsBlock=repmat(directions, length(displacements), length(speeds));
directionsBlock=directionsBlock(:);
speedsBlock=repmat(speeds, length(displacements)*length(directions), 1);
speedsBlock=speedsBlock(:);
rando=rand(size(displacementsBlock));
[tmp index]=sort(rando);
displacementsBlock=displacementsBlock(index);
directionsBlock=directionsBlock(index);
speedsBlock=speedsBlock(index);


rect=Screen('Rect', display.windowPtr);
if ~isfield(display, 'Rect');
    tmp1=round((display.numPixels(1)-display.numPixels(2))/2);
    display.Rect=[tmp1; 0; tmp1+display.numPixels(2); display.numPixels(2)];
    stimulus.destRect=stimulus.destRect(:);
end
degPerPix=(params.radius*2)/(display.Rect(4)-display.Rect(2));
displacementsBlock=(displacementsBlock./2)./degPerPix;

%nFrames = length(stimulus.seq);
HideCursor;
nGamma = size(stimulus.cmap,3);
%nImages = length(stimulus.textures);
%response.keyCode = zeros(length(stimulus.seq),2); % get 1 buttons max
response.secs = zeros(size(displacementsBlock));        % timing
quitProg = 0;
startFlag=0;
response=zeros(size(displacementsBlock));
% go
fprintf('[%s]:Running. Hit %s to quit.\n',mfilename,KbName(quitProgKey));
for trial = 1:length(displacementsBlock)
    
    Screen('FillRect', display.windowPtr, [128 128 128], rect );
    drawFixation(display,2);
    Screen('Flip',display.windowPtr);
    
    %Make a list of frames to be shown, starting at a random point
    startFrame=ceil(rand(1)*params.temporal.motionSteps(speedsBlock(trial)));
    frameList=startFrame:1:startFrame+interval;
    frameList=mod(frameList, params.temporal.motionSteps(speedsBlock(trial)));
    frameList(frameList==0)=params.temporal.motionSteps(speedsBlock(trial));
    frameList=frameList+(max(params.temporal.motionSteps)*(speedsBlock(trial)-1));
    if directionsBlock(trial)>=3
        frameList=flipLR(frameList);
    end
    frameTimes=stimframe:stimframe:interval*stimframe;
    resp=[];

    while startFlag==0
        [exKeyIsDown,tmp,exKeyCode] = KbCheck(display.devices.keyInputInternal);
        if(exKeyIsDown)
            if(exKeyCode(quitProgKey)),
                quitProg = 1;
                break; % out of while loop
            elseif (exKeyCode(nextTrialKey))    
                startFlag=1;
            end;
        end;
    end
    frameTimes=frameTimes+GetSecs;
    
     for frame=1:interval
        Screen('DrawTexture', display.windowPtr, stimulus.textures(frameList(frame)), stimulus.srcRect, stimulus.destRect+[0; displacementsBlock(trial); 0; displacementsBlock(trial)]);
        drawFixation(display,1);
        waitTime = (GetSecs-frameTimes(frame));
        
        %%USEFUL FOR CHECKING FOR DROPPED FRAMES
        if waitTime>0
            waitTime
        end
        
        %--- get inputs (subject or experimentor)
        while(waitTime<0),
            
            % scan the keyboard for experimentor input
%             [exKeyIsDown,tmp,exKeyCode] = KbCheck(display.devices.keyInputInternal);
%             if(exKeyIsDown)
%                 if(exKeyCode(quitProgKey)),
%                     quitProg = 1;
%                     break; % out of while loop
%                 elseif (exKeyCode(firstIntervalKey))
%                     response(trial)=1;
%                 elseif (exKeyCode(secondIntervalKey))
%                     response(trial)=2;
%                 end;
%             end;
            
            % if there is time release cpu
            if(waitTime<-0.02),
                WaitSecs(0.01);
            end;
            
            % timing
            waitTime = (GetSecs-frameTimes(frame));
        end;
        
        %--- stop?
        if quitProg,
            fprintf('[%s]:Quit signal recieved.\n',mfilename);
            break;
        end;
        
        %--- update screen
        Screen('Flip',display.windowPtr);
    end
    Screen('FillRect', display.windowPtr, [128 128 128], rect );
    drawFixation(display,2);
    Screen('Flip',display.windowPtr);
    endTime=isi+GetSecs;
    
    startFrame=ceil(rand(1)*params.temporal.motionSteps(speedsBlock(trial)));
    frameList=startFrame:1:startFrame+interval;
    frameList=mod(frameList, params.temporal.motionSteps(speedsBlock(trial)));
    frameList(frameList==0)=params.temporal.motionSteps(speedsBlock(trial));
    frameList=frameList+(max(params.temporal.motionSteps)*(speedsBlock(trial)-1));
    if directionsBlock(trial)==2 || directionsBlock(trial)==3
        frameList=flipLR(frameList);
    end
    frameTimes=stimframe:stimframe:interval*stimframe;
    
    waitTime=(GetSecs-endTime);
    while(waitTime<0),
        
        % scan the keyboard for experimentor input
        [exKeyIsDown,tmp,exKeyCode] = KbCheck(display.devices.keyInputInternal);
        if(exKeyIsDown)
            if(exKeyCode(quitProgKey)),
                quitProg = 1;
                break; % out of while loop
            elseif (exKeyCode(firstIntervalKey))
                response(trial)=1;
            elseif (exKeyCode(secondIntervalKey))
                response(trial)=2;
            end;
        end;
        
        % if there is time release cpu
        if(waitTime<-0.02),
            WaitSecs(0.01);
        end;
        
        % timing
        waitTime = (GetSecs-endTime);
    end;
        %--- stop?
    if quitProg,
        fprintf('[%s]:Quit signal recieved.\n',mfilename);
        break;
    end;
    
    frameTimes=frameTimes+GetSecs;
    
    for frame=1:interval
        Screen('DrawTexture', display.windowPtr, stimulus.textures(frameList(frame)), stimulus.srcRect, stimulus.destRect-[displacementsBlock(trial); 0; displacementsBlock(trial); 0]);
        drawFixation(display,1);
        waitTime = (GetSecs-frameTimes(frame));
        
        %%USEFUL FOR CHECKING FOR DROPPED FRAMES
        if waitTime>0
            waitTime
        end
        
        %--- get inputs (subject or experimentor)
        while(waitTime<0),
            
            % scan the keyboard for experimentor input
            [exKeyIsDown,tmp,exKeyCode] = KbCheck(display.devices.keyInputInternal);
            if(exKeyIsDown)
                if(exKeyCode(quitProgKey)),
                    quitProg = 1;
                    break; % out of while loop
                elseif (exKeyCode(firstIntervalKey))
                    response(trial)=1;
                elseif (exKeyCode(secondIntervalKey))
                    response(trial)=2;
                end;
            end;
            
            % if there is time release cpu
            if(waitTime<-0.02),
                WaitSecs(0.01);
            end;
            
            % timing
            waitTime = (GetSecs-frameTimes(frame));
        end;
        
        %--- stop?
        if quitProg,
            fprintf('[%s]:Quit signal recieved.\n',mfilename);
            break;
        end;
        
        %--- update screen
        Screen('Flip',display.windowPtr);
    end
    Screen('FillRect', display.windowPtr, [128 128 128], rect );
    drawFixation(display,2);
    Screen('Flip',display.windowPtr);
    while response(trial)==0
        [exKeyIsDown,tmp,exKeyCode] = KbCheck(display.devices.keyInputInternal);
        if(exKeyIsDown)
            if(exKeyCode(quitProgKey)),
                quitProg = 1;
                break; % out of while loop
            elseif (exKeyCode(firstIntervalKey))
                response(trial)=1;
            elseif (exKeyCode(secondIntervalKey))
                response(trial)=2;
            end;
        end;
        
        % if there is time release cpu
        if(waitTime<-0.02),
            WaitSecs(0.01);
        end;
    end
    %response(trial)=resp;

end

if response(end)>0
    response(index)=response;
    displacementsBlock(index)=displacementsBlock;
    directionsBlock(index)=directionsBlock;
    speedsBlock(index)=speedsBlock;
    filename = ['~/Documents/MATLAB/matfiles/MotionPsychophysics' datestr(now,30) '.mat'];
    save(filename, 'response', 'index', 'displacementsBlock', 'directionsBlock', 'speedsBlock')
end


% that's it
ShowCursor;
timing = GetSecs-t0;
fprintf('[%s]:Stimulus run time: %f seconds [should be: %f].\n',mfilename,timing,max(stimulus.seqtiming));

return;
z z