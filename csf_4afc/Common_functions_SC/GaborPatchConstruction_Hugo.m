function [feedbackRect] = GaborPatchConstruction_Hugo(Freq_cpd,Contrast,XYLoc_px,Parameters,w,ScreenRect,Gabor,SC)
%% Input check
if nargin<1 || isempty(Freq_cpd)
    Freq_cpd = 15;
    error('No frequency specified! Setting to default value: %1.2f', Freq_cpd)
end
    Freq_cpp = Freq_cpd/Parameters.pixperdeg;

if nargin<2 || isempty(Contrast)
    Contrast = 0.5;
    warning('No contrast specified! Setting to default value: %1.2f', Contrast)
end

if isempty(XYLoc_px)
    XYLoc_px = [ScreenRect(3)/2,ScreenRect(4)/2];
    warning('No xy location specified! Setting to default value: centre')
end

if XYLoc_px(1)>ScreenRect(3) || XYLoc_px(2)>ScreenRect(4)
    error('The input location is outside the visible display!')
end

if nargin < 8 
    SpaCst = Gabor.sc_px;
else
    SpaCst = Gabor.SCShuffle(SC);
end

%% Check what is the maximum cycles that can be displayed in 1 deg
% If 1 cycle = 2 black pixels + 2 white pixels = 4 pixels
% So, X pixels in one deg/4 will give use the max number of cycles that can be achieved in 1 deg
maxFreq_cpd = Parameters.pixperdeg/4;

% maximum frequency based on the pixel-size of the screen, and the distance of the observer
if Freq_cpd>maxFreq_cpd
    warning('Frequency is outside the acceptable range! Please enter Frequency<%2.2f',maxFreq_cpd);
else
    sprintf('Maximum number of cycles supported in 1 deg = %2.2f',maxFreq_cpd);
end

%% Initial Values
tilt = 0; %the optional orientation angle in degrees (0-360), default is zero degrees.
aspectratio = 1; %the aspect ratio of the hull of the gabor. This parameter is ignored if the 'nonSymmetric' flag hasn't been set to 1 when calling the CreateProceduralGabor() function.
disableNorm = 1;

%% Create the Gabor for a contrast of 100%
% Compute a gabor texture, with an orientation of Gabor.Orientation, and taking in
% account, the phase, the Michelson Contrast (Gabor.MC) and Frequency in radian per pixel (Gabor.FreqRadperPixel).
% Gabor.x and .y correspond to the mesh of the Gabor.
% Create the mesh grid (black/white)
WidthArray=[-ceil(Gabor.Size_px/2):-1 1:Gabor.Size_px/2];
[Gabor.x,Gabor.y] = meshgrid(WidthArray, WidthArray);

% Compute the grating image
gabor =  ones(Gabor.Size_px, Gabor.Size_px)*Parameters.Background(1); % Set to Background Luminance (0.5)
mc = disableNorm + (1.0 - disableNorm) * (1.0 / (sqrt(2*pi) * SpaCst));  % If disableNorm = 0, this will attenuate the contrast

for x = 1:length(Gabor.x)
    for y = 1:length(Gabor.y)
        % Stripe pattern
        phase = pi/2;
        constant = 0.5;
        gabor(x,y) = gabor(x,y)*(1+mc*cos(2*pi*Freq_cpp*Gabor.y(x,y)+phase)*exp(-constant*Gabor.y(x,y)^2/SpaCst^2)*exp(-constant*Gabor.x(x,y)^2/SpaCst^2));
    end
end

Stimulus = [];
Stimulus = gabor;
Stimulus = double(Stimulus);

% This step produces an achromatic Gabor at full 100% contrast (if disableNorm=1)
% figure('Position',[0 0 ScreenRect(3) ScreenRect(4)/3.5]);
set(gcf,'Color',[1 1 1]);
imagesc(Stimulus)
%% Adjust the color and luminance values respective to the contrast and colors needed
colStim = nan(size(Stimulus,1),size(Stimulus,1),3);  % X, Y, RGB

for i = 1:length(Parameters.Background) % For each RGB channel
        tmp = Stimulus;
        
        % Define which pixels tend towards white or black, or corresponds
        % to the background.
        pix1 = tmp(:,:) > Parameters.Background(i); % Tends toward white
        pix2 = tmp(:,:) < Parameters.Background(i); % Tends toward black
        pix3 = tmp(:,:) == Parameters.Background(i); % Grey
        
        % Contrast modulation: contrast is defined as amount of grey to
        % modulate the initial pixel colors with. For instance, if contrast =
        % 50%, we need to inject 50% of grey). This is done by computing
        % the difference between the pixel color value and the grey value,
        % and multiplying the difference by the amount of grey to inject.
        tmp(pix1) = Parameters.Background(i) + (Stimulus(pix1)-Parameters.Background(i))*Contrast; % for pixels going towards white
        tmp(pix2) = Parameters.Background(i) + (Stimulus(pix2)-Parameters.Background(i))*Contrast; % for pixels going towards black
        tmp(pix3) = Parameters.Background(i);
        colStim(:,:,i) = tmp;
end
% 
% figure('Position',[0 0 ScreenRect(3) ScreenRect(4)/3.5]);
% set(gcf,'Color',[1 1 1]);
% for i = 1:size(colStim,3)
%     subplot(1,size(colStim,3),i)
%     surf(colStim(:,:,i));
% %     contour(colStim(:,:,i),SpaCst)
%     xlabel('Position (pixel)'); ylabel('Position (pixel)'); zlabel('Luminance Value')
%     title(['Color Channel: ' num2str(i)])
% end
% colormap(gray);
% 
%% Create Texture and get local of texture
% textureIndex=Screen(‘MakeTexture’, WindowIndex, imageMatrix [, optimizeForDrawAngle=0] ...
% [, specialFlags=0] [, floatprecision] [, textureOrientation=0] [, textureShader=0]);
% floatprecision defines the precision with which the texture should be
% stored. A value of 2 asks for full 32 bit single precision float per color component. 
% Useful for complex computations and image processing, but slower, and takes up 
% twice as much video memory. If value of 1, texture gets stored in half-float fp16 format, 
% i.e. 16 bit per color component.
gaborid = Screen('MakeTexture', w, colStim,[],[],2);

% rect=Screen(‘Rect’, windowPointerOrScreenNumber [, realFBSize=0]); 
% If realFBSize = 1: returns the real size of the windows framebuffer.
gaborrect = Screen('Rect', gaborid);

%% Flipping the stimulus on the screen
phaseToDisplay = 1; 
x = XYLoc_px(1);
y = XYLoc_px(2);
dstRect = OffsetRect(gaborrect,x,y);
feedbackRect = CenterRect(gaborrect,[ScreenRect(3)/2-gaborrect(3)/2 ScreenRect(4)/2-gaborrect(3)/2 ScreenRect(3)/2+gaborrect(3)/2 ScreenRect(4)/2+gaborrect(3)/2]);
Screen('DrawTexture', w, gaborid, [], dstRect, 0+tilt, [], [], [], [], kPsychDontDoRotation, [180-phaseToDisplay, Freq_cpp, SpaCst, Contrast, aspectratio, 0, 0, 0]);

end