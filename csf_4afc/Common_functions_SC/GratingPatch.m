function [Stimulus] = GratingPatch(ScreenRect,Parameters,Gabor,SpaCst,disableNorm,phase)
%% Create the Gabor for a contrast of 100%
% Compute a gabor texture, with an orientation of Gabor.Orientation, and taking in
% account, the phase, the Michelson Contrast (Gabor.MC) and Frequency in radian per pixel (Gabor.FreqRadperPixel).
% Gabor.x and .y correspond to the mesh of the Gabor.
% Create the mesh grid (black/white)

% Compute the grating image
mc = disableNorm + (1.0 - disableNorm) * (1.0 / (sqrt(2*pi) * SpaCst));  % If disableNorm = 0, this will attenuate the contrast

gabor =  ones(length(Gabor.meshx),length(Gabor.meshy))*Parameters.Background(1); % Set to Background Luminance (0.5)
for x = 1:length(Gabor.meshx)
    for y = 1:length(Gabor.meshy)
        % Formulae are based on two papers: Chen & Foley, 2003, Vision
        % Research; Federiken et al., 1997, JOSA.
        % Stripe pattern: Configuration 1
        constant = 0.5;
        gabor(x,y) = gabor(x,y)*(1+mc*cos(2*pi*Gabor.SFcpp*Gabor.meshy(x,y)+phase)*exp(-constant*Gabor.meshy(x,y)^2/SpaCst^2)*exp(-constant*Gabor.meshx(x,y)^2/SpaCst^2));
    end
end
[~, R] = cart2pol(Gabor.meshx, Gabor.meshy);
circap =  ones(length(Gabor.meshx),length(Gabor.meshy));
circap(R>length(Gabor.meshx)/2) = 0.5;
gabor(circap == 0.5) = 0.5;
Stimulus(:,:) = gabor;
Stimulus = double(Stimulus);
% % This step produces an achromatic Gabor at full 100% contrast (if disableNorm=1)
% figure('Position',[0 0 ScreenRect(3) ScreenRect(4)/3.5]);
% set(gcf,'Color',[1 1 1]);
% imagesc(Stimulus(:,:,1));
end