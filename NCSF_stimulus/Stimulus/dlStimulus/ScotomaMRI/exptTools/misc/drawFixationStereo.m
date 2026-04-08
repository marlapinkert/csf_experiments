function fixationDotIndex = drawFixationStereo(d, startTime, dotparams, fixationDotIndex)
%
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
    startTime = 0;
    dotparams = [];
    fixationDotIndex = 0;
    d.fixDisparity = 0;

else

    if (GetSecs - startTime) < dotparams.fixationDotTiming(fixationDotIndex)
        d.fixDisparity = dotparams.fixationDotSequence(fixationDotIndex) .* 3; % should have a more informed value
    else
        fixationDotIndex = min(fixationDotIndex + 1,length(dotparams.fixationDotSequence));
        d.fixDisparity = dotparams.fixationDotSequence(fixationDotIndex) .* 3;
    end

end;

xPosLeft = d.fixX - d.horizontalOffset;
xPosRight = d.fixX + d.horizontalOffset;

Screen('SelectStereoDrawBuffer',d.windowPtr,0); % left eye
%Screen('gluDisk', d.windowPtr, [255 0 0], leftX, leftY, d.fixSizePixels);
Screen('DrawDots',d.windowPtr, [0 0], d.fixSizePixels,[0 0 0],[xPosLeft - d.fixDisparity d.fixY],1);

Screen('SelectStereoDrawBuffer',d.windowPtr,1); % right eye
%Screen('gluDisk', d.windowPtr, [255 0 0], rightX, rightY, d.fixSizePixels);
Screen('DrawDots',d.windowPtr, [0 0], d.fixSizePixels,[0 0 0],[xPosRight + d.fixDisparity d.fixY],1);

return