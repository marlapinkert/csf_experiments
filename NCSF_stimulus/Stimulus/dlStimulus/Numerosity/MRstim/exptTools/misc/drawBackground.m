function drawBackground(d, stimulus, eye)
%
% drawBackground(display, [colIndex=1])
%
% adapted 20100603 by BR from:
% drawFixation(display, [colIndex=1])
%
% Draws the fixation point specified in the display struct.
%
% HISTORY:
% 2005.02.23 RFD: wrote it.
% 2005.06.29 SOD: added colIndex for fixation dot task
%                 added largeCrosses options
% 2008.05.11 JW:  added 'dot and 'none' options 
%                 added 'lateraldots'
if nargin < 2,
    colIndex = 1;
end;

Screen('DrawTexture', d.windowPtr, stimulus.backgroundTexture, [],...
    CenterRectOnPointd([-d.numPixels(1),-d.numPixels(1),d.numPixels(1),d.numPixels(1)],d.fixX,d.fixY) , 2*(eye-.5)*d.screenRotation);

%d.calibrate = 1;
if d.calibrate % Draw dashed line stimulus for calibration
    if eye
        Screen('DrawTexture', d.windowPtr, stimulus.leftCalibrationTexture, [],...
            CenterRectOnPointd([-d.numPixels(1),-d.numPixels(1),d.numPixels(1),d.numPixels(1)],d.fixX,d.fixY) , 2*(eye-.5)*d.screenRotation);
    else
        Screen('DrawTexture', d.windowPtr, stimulus.rightCalibrationTexture, [],...
            CenterRectOnPointd([-d.numPixels(1),-d.numPixels(1),d.numPixels(1),d.numPixels(1)],d.fixX,d.fixY) , 2*(eye-.5)*d.screenRotation);
    end
end
return


% [x,y] = meshgrid([0:display.numPixels(1)]-display.fixX,...
%     [0:display.numPixels(2)]-display.fixY);