function [gaborid,dstRect] = MakeGaborContrast(Stimulus,Contrast,XYLoc_px,Parameters,w,ScreenRect,idxFreq,FF,idxSCSize,SC)
%% Adjust the color and luminance values respective to the contrast and colors needed
nColorChan = 3;
colStim = squeeze(nan(size(Stimulus,2),size(Stimulus,3),nColorChan,size(Stimulus,5)));  % X, Y, RGB,  Reversal configuration

for r = 1:size(Stimulus,5)
    for i = 1:nColorChan % For each RGB channel
        tmpcolStim = []; tmpcolStim = squeeze(Stimulus(idxFreq(FF),:,:,idxSCSize(SC),r));
        tmpStim = tmpcolStim;
        % Define which pixels tend towards white or black, or corresponds
        % to the background.
        pix1 = tmpcolStim(:,:) > Parameters.Background(i); % Tends toward white
        pix2 = tmpcolStim(:,:) < Parameters.Background(i); % Tends toward black
        pix3 = tmpcolStim(:,:) == Parameters.Background(i); % Grey
        
        % Contrast modulation: contrast is defined as amount of grey to
        % modulate the initial pixel colors with. For instance, if contrast =
        % 50%, we need to inject 50% of grey). This is done by computing
        % the difference between the pixel color value and the grey value,
        % and multiplying the difference by the amount of grey to inject.
        tmpcolStim(pix1) = Parameters.Background(i) + (tmpStim(pix1)-Parameters.Background(i))*Contrast; % for pixels going towards white
        tmpcolStim(pix2) = Parameters.Background(i) + (tmpStim(pix2)-Parameters.Background(i))*Contrast; % for pixels going towards black
        tmpcolStim(pix3) = Parameters.Background(i);
        colStim(:,:,i,r) = tmpcolStim;
    end
end

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
% textureIndex=Screen('MakeTexture', WindowIndex, imageMatrix [, optimizeForDrawAngle=0] ...
% [, specialFlags=0] [, floatprecision] [, textureOrientation=0] [, textureShader=0]);
% floatprecision defines the precision with which the texture should be
% stored. A value of 2 asks for full 32 bit single precision float per color component. 
% Useful for complex computations and image processing, but slower, and takes up 
% twice as much video memory. If value of 1, texture gets stored in half-float fp16 format, 
% i.e. 16 bit per color component.
% colStim = squeeze(Stimulus(idxFreq(FF),:,:,idxSCSize(SC)));
% gaborid = Screen('MakeTexture', w, colStim,[],[],2,[90]);
for r = 1:size(Stimulus,5)
    gaborid(r) = Screen('MakeTexture', w, squeeze(colStim(:,:,:,r)),[],[],2);
    
    % rect=Screen('Rect', windowPointerOrScreenNumber [, realFBSize=0]);
    % If realFBSize = 1: returns the real size of the windows framebuffer.
    gaborrect(r,:) = Screen('Rect', gaborid(r));
    
    x = XYLoc_px(1);
    y = XYLoc_px(2);
    dstRect(r,:) = OffsetRect(gaborrect(r,:),x,y);
    feedbackRect(r,:) = CenterRect(gaborrect(r,:),[ScreenRect(3)/2-gaborrect(3)/2 ScreenRect(4)/2-gaborrect(3)/2 ScreenRect(3)/2+gaborrect(3)/2 ScreenRect(4)/2+gaborrect(3)/2]);
end

end