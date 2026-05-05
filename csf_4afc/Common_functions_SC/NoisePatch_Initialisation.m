%% WhiteNoise patch creation
Noise.Bkg = single(Parameters.Background(1)); % Grey
Noise.LimCol = single([0.45 0.55]);
Noise.nbPattern = single(5); % Will generate 10 different noise patterns
WhiteNoise = NaN(length(Gabor.x),length(Gabor.y),length(Gabor.sigmapx),Noise.nbPattern);

for i = 1:length(Gabor.sigmapx)
    for j = 1:Noise.nbPattern
        WhiteNoisetmp = [];
        WhiteNoisetmp = Noise.Bkg+(Noise.LimCol(2)-Noise.LimCol(1)).*randn(length(Gabor.x),length(Gabor.y));
        WhiteNoisetmp(R > ScreenRect(4)/2) = Noise.Bkg; % Create a circular aperture
        WhiteNoisetmp(R > Gabor.sigmapx(i)*3) = Noise.Bkg; % Noise patch will cover the visible part of Gabor patch
        WhiteNoise(:,:,i,j) = WhiteNoisetmp;
    end
end

clear WhiteNoisetmp R i j 