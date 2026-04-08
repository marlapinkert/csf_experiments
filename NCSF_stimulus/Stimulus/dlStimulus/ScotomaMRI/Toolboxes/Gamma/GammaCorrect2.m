%Luminance data from Waisman Center MRI stereoscope L & R eye screens
%Data collected w/ Konica Minolta LS-110 photometer on 10/6/11

leftEyeMeasurements = [0.18 0.18 0.19;
                      0.22 0.22 0.21;
                      0.33 0.33 0.33;
					  0.68 0.66 0.68;
					  1.29 1.42 1.43;
					  2.92 2.95 2.86;
					  4.53 4.75 4.57;
					  7.56 6.73 5.9;
					  9.53 10.55 10.06;
					  12.62 13.46 12.83;
					  16.13 17.4 17.92;
					  24.8 24.68 22.99;
					  30.42 29.9 30.24;
					  35.48 36.58 35.61;
					  41.57 42.64 40.89;
					  46.93 49.25 49.53;
					  55.65 56.51 56.01];					  					  

rightEyeMeasurements = [0.18 0.19 0.19;
						0.19 0.22 0.22;
						0.29 0.31 0.31;
						0.6 0.67 0.64;
						1.37 1.46 1.51;
						2.37 1.98 2.31;
						3.4  4.18 4.17;
						6.84 5.86 6.96;
						9.06 8.57 7.56;
						10.37 13.76 14.48;
						18.1 18.46 17.92;
						22.2 21.64 23.64;
						28.71 29.37 29.46;
						36.29 34.83 34.64;
						40.05 39.54 38.38;
						35.62 44.78 46.01;
						52.27 55 55.6];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% COMPUTE A CORRECTED/LINEARIZED GAMMA TABLE %%%%
%%%% Adopted from Uki Kamitani 12-7-99
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% TODO: Compare to CalibrateFitGamma function

%---- data, [col1 lum1;col2 lum2;...]
%---- col# steps can be calculated by: "x = 0:s:255"."s" is the
%interval size (255/nSteps). nSteps is the number of steps tested in photometercalibration function (in this case 17)

%dataL=[0 al;16 bl;32 cl;48 dl;64 el;80 fl;96 gl;112 hl;128 il;144 jl;160 kl;176 ll;192 ml;208 nl;224 ol;240 pl;256 ql];
%dataR=[0 ar;16 br;32 cr;48 dr;64 er;80 fr;96 gr;112 hr;128 ir;144 jr;160 kr;176 lr;192 mr;208 nr;224 or;240 pr;256 qr];

rgb = [0:15:255];
%plot(leftEyeMeasurements,RGB)
%plot(rightEyeMeasurements,RGB)

%%%% LEFT EYE SCREEN %%%%
measL = leftEyeMeasurements;
maxIndex = max(rgb); %255;
indexNormal = [0:0.001:1]';
maxLum = measL(size(measL,1),2);

measL(:,:)


%%%% SELECT A FITTING METHOD %%%%
[out1 params1 message1] = FitGamma(measL(:,:)/maxIndex, RGB/maxLum, indexNormal,1);

%%%% PLOT DATA POINTS WITH GAMMA FIT %%%%
figure(1);
plot(maxIndex*[0:0.001:1]',maxLum*out1);
hold on;
plot(measL(:,:),RGB);
% 
% %%%% CREATE A GAMMA-CORRECTED TABLE - INVERSE FUNCTION IS CALCULATED
% %%%% NUMERICALLY INDEPENDENT OF FITTING CURVES
% orgTableL = [maxIndex*indexNormal maxLum*out1];
% correctedTableL = [];
% for i = 0:255
%     eqLum = i*maxLum/maxIndex;
%     numTableL = max(find(orgTableL(:,2) <= eqLum));
%     correctedTableL = [correctedTableL ; i round(orgTableL(numTableL,1))];
% end
% 
% %%%% CONFIRM LINEARITY %%%%
% figure(2);
% linearTableL = [];
% for i = 0:255
%     numTableL = max(find(orgTableL(:,1) <= correctedTableL(i+1,2)));
%     linearTableL = [linearTableL; i orgTableL(numTableL, 2)];
% end
% plot(linearTableL(:,1), linearTableL(:,2)');
% 
% %%%% CORRECTED GAMMA TABLE %%%%
% correctedTableL
% 
% %%%% GAMMA VALUE %%%%
% gammaValue = params1(1)
% 
% % this number corresponds to GAMMA in the equation:
% % Luminance = constant(frame buffer value)^GAMMA
% 
% %%%% Correct color values based on the gamma calculated above. 
% %    Desired linear color values (0-255) should be transformed by:
% %    255*(<desired color value>/255)^(1/<gamma>) 
% %    before color is assigned.
