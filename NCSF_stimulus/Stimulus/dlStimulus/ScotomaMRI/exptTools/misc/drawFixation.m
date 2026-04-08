function drawFixation(d, colIndex, eye)
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
    eye = 0;
    d.disparityOffset = 0;
    colIndex = 3;%1;
end;

switch(lower(d.fixType))
    case {'none'}
        %do nothing
 
    case {'dot'}
        Screen('glPoint', d.windowPtr, d.fixColorRgb(colIndex,:), d.fixX, d.fixY, d.fixSizePixels);
    
    case {'lateraldot'}
        % Hack: use colIndex to control both color and fixation location
        col = ceil(colIndex/3); 
        loc = mod(colIndex, 3); if loc == 0, loc = 3; end
        %so for colIndex vals [1:6], col= [1 1 1 2 2 2], loc = [1 2 3 1 2 3];
        Screen('glPoint', d.windowPtr, d.fixColorRgb(col,:), ...
            d.fixStim(loc), d.fixY, d.fixSizePixels);
    
    case {'disk','left disk','right disk'} % Used for the stereo experiments
        % Screen('gluDisk', d.windowPtr, d.fixColorRgb(colIndex,:), d.fixX, d.fixY, d.fixSizePixels);
        
        if colIndex==1 %d.fixColorRgb(colIndex,1) % red
            d.fixDisparity = 2; %.75; % ! pixel angle2pix(d,d.disparity/40) % Disparity of fixation, stimulus disparity == d.disparity/2 in each eye
        elseif colIndex==2 %d.fixColorRgb(colIndex,2) % green
            d.fixDisparity = -2; % pixel(s)
        else % blue
            d.fixDisparity = 0;
        end
        %d.fixDisparity = 0;
        
        if length(colIndex) < 3
            colIndex = [0 0 0];
        end
        
        if eye
            % Screen('gluDisk', d.windowPtr, d.fixColorRgb(colIndex,:), d.fixX+d.fixDisparity, d.fixY, d.fixSizePixels);
            Screen('gluDisk', d.windowPtr, colIndex, d.fixRightX+d.fixDisparity, d.fixY, d.fixSizePixels);
        else
            Screen('gluDisk', d.windowPtr, colIndex, d.fixLeftX-d.fixDisparity, d.fixY, d.fixSizePixels);
        end
      
    case {'disk and markers'}
        Screen('gluDisk', d.windowPtr, d.fixColorRgb(colIndex,:), d.fixX, d.fixY, d.fixSizePixels);
        Screen('FillRect', d.windowPtr, d.markerColor, [d.markerX(1) d.markerY(1) d.markerX(2) d.markerY(2)]);
        Screen('FillRect', d.windowPtr, d.markerColor, [d.markerX(1) d.markerY(3) d.markerX(2) d.markerY(4)]);
        Screen('FillRect', d.windowPtr, d.markerColor, [d.markerX(4) d.markerY(1) d.markerX(3) d.markerY(2)]);
        Screen('FillRect', d.windowPtr, d.markerColor, [d.markerX(4) d.markerY(3) d.markerX(3) d.markerY(4)]);
        
    case {'double disk','left double disk'}
        % draw mean luminance 'edge' big one first
        Screen('gluDisk', d.windowPtr, [128 128 128], d.fixX, d.fixY, d.fixSizePixels.*3);
        Screen('gluDisk', d.windowPtr, d.fixColorRgb(colIndex,:), d.fixX, d.fixY, d.fixSizePixels);
    
    case {'left disk double','right disk double', 'mid disk double'}
        % draw double disk left or right, with high contrast between disk colors
        Screen('gluDisk', d.windowPtr, d.fixColorRgb(3-colIndex,:), d.fixX, d.fixY, d.fixSizePixels.*2);
        Screen('gluDisk', d.windowPtr, d.fixColorRgb(colIndex,:), d.fixX, d.fixY, d.fixSizePixels);        
        
    case {'small cross +'}
		Screen('FillRect', d.windowPtr, d.fixColorRgb(colIndex,:), [d.fixX-d.fixSizePixels/2 d.fixY-1 d.fixX+d.fixSizePixels/2 d.fixY+1]);
        Screen('FillRect', d.windowPtr, d.fixColorRgb(colIndex,:), [d.fixX-1 d.fixY-d.fixSizePixels/2 d.fixX+1 d.fixY+d.fixSizePixels/2]);

    case {'large cross' , 'largecross','large cross x+','largecrossx+'},
		if numel(d.fixCoords) > 1, colIndex2=colIndex; else, colIndex2 = 1; end;
        Screen('DrawDots', d.windowPtr, d.fixCoords{colIndex2}, d.fixSizePixels(colIndex2), d.fixColorRgb(colIndex,:));
    
    case {'double large cross' , 'doublelargecross'},
        Screen('DrawDots', d.windowPtr, d.fixCoords, d.fixSizePixels, d.fixColorRgb(1,:));
        Screen('DrawDots', d.windowPtr, d.fixCoords, ceil(d.fixSizePixels./2), d.fixColorRgb(end,:));
    
	case {'simon task'}
		Screen('LoadNormalizedGammaTable', display.windowPtr, stimulus.cmap(:,:,colIndex));
		
    otherwise,
        error('Unknown fixationType!');
end


return