% sc_deg: Spatial constant of the gaussian hull function of the gabor,
% ie.the "sigma" value in the exponential function.
if sum(isnan(Gabor.SpacialConstant_Deg)) == 1 % If the SC size is NaN
    heightStimDeg = 2*rad2deg(atan(Parameters.ScreenCM(2)/(2*Parameters.ViewingDistance)));
    Gabor.SpacialConstant_Deg(isnan(Gabor.SpacialConstant_Deg)) = heightStimDeg;
end
Gabor.sigmapx = round(Gabor.SpacialConstant_Deg*Parameters.pixperdeg);

% Gabor Size in pixel
if isnan(Gabor.PatchSize)
    Gabor.Size_px = ScreenRect(4); % Height of the screen
else
    Gabor.Size_px = Gabor.PatchSize*Parameters.pixperdeg;
end

% Centre of screen: the center of screen translated this way because of the way CreateProceduralGabor works
XYCentre_px_gabor = [ScreenRect(3)/2-(Gabor.Size_px./2),ScreenRect(4)/2-(Gabor.Size_px./2)];
XYLoc_px_gabor = [XYCentre_px_gabor(1),XYCentre_px_gabor(2)];

% Create the Gabor patch at 100% contrast for each condition combination
% Create the mesh grid (black/white)
WidthArray=single([-Gabor.Size_px/2:0 1:Gabor.Size_px/2-1]);
[Gabor.meshx,Gabor.meshy] = meshgrid(WidthArray, WidthArray);
[~, R] = cart2pol(Gabor.meshx, Gabor.meshy);

% Set disable normalisation (default = 1) and define phase
disableNorm = 1;
if Gabor.TF > 0
    phase = [pi/2 pi+pi/2];
else
    phase = 0; % Stationary stimulus
end

% Create the Gabor stimuli
Stimulus = NaN(length(Gabor.SFcpd),length(Gabor.meshx),length(Gabor.meshy),length(Gabor.sigmapx),length(phase));

for f = 1:length(Gabor.SFcpd)
    Gabor.SFcpp = Gabor.SFcpd(f)/Parameters.pixperdeg;
    for i = 1:length(Gabor.sigmapx)
        for r = 1:numel(phase)
            SpaCst = Gabor.sigmapx(i);
            StimTemp = GratingPatch(ScreenRect,Parameters,Gabor,SpaCst,disableNorm,phase(r));
            StimTemp(R > Gabor.sigmapx(i)*3) = Parameters.Background(1);
            % For all points more than 3 standard deviations (Gabor.sigmapx) from
            % the center, pixel value is set to 0.5. Therefore, the size of the Gabor patches:
            % - radius = 3*SD of Gaussian envelope
            % - radius = height of the screen
            Stimulus(f,:,:,i,r) = StimTemp;
        end
    end
end

clear WidthArray StimTemp f i r SpaCst heightStimDeg disableNorm