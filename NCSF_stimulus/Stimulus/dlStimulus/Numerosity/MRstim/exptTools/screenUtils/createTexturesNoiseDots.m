function stimulus = createTexturesNoiseDots(display);
%stimulus = createTextures(display, stimulus, [removeImages=1]);
%
%Replace images within stimulus (stimulus.image) with textures
%(stimulus.textures).
%
%Stimulus can be a 1xn array of stimuli.  It creates the textures
%(like loading in off-screen memory in OS9).
% If the removeImages flag is set to 1 [default value], the code
% destroys the original image field (freeing up the memory and speeding up
% pass-by-copy calls of stimulus). For stimuli with many images, this is
% strongly recommended; however, for a small number of images, the field
% may not slow things too much; setting the flag to 0 keeps the images.
%
%If you're trying to create an texture starting at something
%other than the first image, use addTextures.

%2005/06/09   SOD: ported from createImagePointers
%31102005    fwc:	changed display.screenNumber into display.windowPtr
if notDefined('removeImages'),      removeImages = 1;       end

%c = getReservedColor(display, 'background');
try,
	c = display.backColorIndex;
catch,
	c = display.backColorRgb;
end;
if ~isfield(display, 'Rect');
    tmp1=round((display.numPixels(1)-display.numPixels(2))/2);
    display.Rect=[tmp1; 0; tmp1+display.numPixels(2); display.numPixels(2)];    
    n=display.numPixels(2);
else
    n=display.Rect(4)-display.Rect(2);

end
rect=Screen('Rect', display.windowPtr);
% make textures
for imgNum = 1:10,
    NoiseImage=round(rand(rect(3)-rect(1), rect(4)-rect(2))).*255;
    
     stimulus.texturesBG(imgNum) = ...
        Screen('MakeTexture',display.windowPtr, double(NoiseImage));
end;



% call/load 'DrawTexture' prior to actual use (clears overhead)
% Screen('DrawTexture', display.windowPtr, stimulus(1).textures(1), ...
% 	stimulus(1).srcRect, stimulus(1).destRect);
% Screen('DrawTexture', display.windowPtr, stimulus(1).textures(end), ...
% 	stimulus(1).srcRect, stimulus(1).destRect);

return
