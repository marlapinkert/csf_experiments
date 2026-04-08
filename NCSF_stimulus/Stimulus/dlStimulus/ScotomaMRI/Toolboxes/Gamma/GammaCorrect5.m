% Luminance data from Waisman Center MRI stereoscope L & R eye screens
% Data collected w/ Konica Minolta LS-110 photometer on 10/6/11
% Using CalibrateMonitorPhotometer(17)
% Repeated measurement (in cd/m^2) 3 times at each luminance level
clear all

rightEyeMeasurements = [0.18 0.19 0.19, ...
						0.19 0.22 0.22, ...
						0.29 0.31 0.31, ...
						0.6 0.67 0.64, ...
						1.37 1.46 1.51, ...
						2.37 1.98 2.31, ...
						3.4  4.18 4.17, ...
						6.84 5.86 6.96, ...
						9.06 8.57 7.56, ...
						10.37 13.76 14.48, ...
						18.1 18.46 17.92, ...
						22.2 21.64 23.64, ...
						28.71 29.37 29.46, ...
						36.29 34.83 34.64, ...
						40.05 39.54 38.38, ...
						35.62 44.78 46.01, ...
						52.27 55 55.6]'; 

leftEyeMeasurements = [0.18 0.18 0.19 ...
                      0.22 0.22 0.21 ...
                      0.33 0.33 0.33 ...
					  0.68 0.66 0.68 ...
					  1.29 1.42 1.43 ...
					  2.92 2.95 2.86 ...
					  4.53 4.75 4.57 ...
					  7.56 6.73 5.9 ...
					  9.53 10.55 10.06 ...
					  12.62 13.46 12.83 ...
					  16.13 17.4 17.92 ...
					  24.8 24.68 22.99 ...
					  30.42 29.9 30.24 ...
					  35.48 36.58 35.61 ...
					  41.57 42.64 40.89 ...
                      46.93 49.25 49.53 ...
					  55.65 56.51 56.01]';					  					  

% Normalize the data
maxLeftEye = mean(leftEyeMeasurements(end-2:end));
maxRightEye = mean(rightEyeMeasurements(end-2:end));
maxBothEye = (maxLeftEye + maxRightEye) / 2;

% reMeasNormal = rightEyeMeasurements/max(rightEyeMeasurements);
% leftEyeNormal = leftEyeMeasurements/mean(leftEyeMeasurements(end-2:end));                  
bothEyeNormal = [leftEyeMeasurements; rightEyeMeasurements] ./ maxBothEye;
% bothEyeNormal = [rightEyeMeasurements; rightEyeMeasurements] ./ maxBothEye;

% Define RGB values tested in 17-step calibration
rgb = [];
for ii = 0:16:256
    rgb = [rgb; ii; ii; ii];
end
rgb(end-2:end) = [255; 255; 255];
rgb = [rgb; rgb];

% Normalize the RGB values
rgbNormal = rgb/max(rgb);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%% FIT GAMMA & PLOT DATA %%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%% SIMPLE GAMMA POWER FUNCTION FIT %%%%
% Plot the data
figure; clf; hold on
plot(rgbNormal,bothEyeNormal,'+');
%plot(rgbNormal,reMeasNormal,'+');

% Fit simple gamma power function
output = linspace(0,1,256)'; % Specify how many interpolated values wanted in the fit (for 8 bit, commonly 256)
[simpleFit,simpleX] = FitGamma(rgbNormal,bothEyeNormal,output,1);
%[simpleFit,simpleX] = FitGamma(rgbNormal,reMeasNormal,output,1);
plot(output,simpleFit,'r');
fprintf(1,'Found exponent %g\n\n',simpleX(1));                    

% %%%% Alternative: EXTENDED GAMMA POWER FUNCTION FIT %%%%
% % % Fit extended gamma power function.
% % % Here the fit is the same as for the simple function.
% [extendedFit,extendedX] = FitGamma(rgbNormal,bothEyeNormal,output,2);
% %[extendedFit,extendedX] = FitGamma(rgbNormal,reMeasNormal,output,2);
% plot(output,extendedFit,'g');
% fprintf(1,'Found exponent %g, offset %g\n\n',extendedX(1),extendedX(2));

%%%% INVERT GAMMA FUNCTION %%%%
% Use the parameters from the extended fit to invert the gamma function.
% See GammaFitDemo for an analysis of the limitations of this particular
% approach to inverse gamma fitting. (in short, errors decrease the
% accuracy of the line estimate)
maxInput = max(rgb);
% invertedInput = InvertGammaExtP(extendedX,maxInput,leMeasNormal);
invertedInput = InvertGammaExtP([simpleX; 0],maxInput,bothEyeNormal);
% invertedInput = InvertGammaExtP(extendedX,maxInput,bothEyeNormal);

figure; clf; hold on
plot(rgb,invertedInput,'r+');
axis('square');
axis([0 maxInput 0 maxInput]);
plot([0 maxInput],[0 maxInput],'r');

% create the gamma table
gamma = [simpleFit simpleFit simpleFit];
invertedGamma = round(255.*(output.^(1/simpleX)));
gammaTable = [invertedGamma invertedGamma invertedGamma];
save('gamma','gamma','gammaTable');

% TO DO: Figure out what the format for the gammaTable variable is

