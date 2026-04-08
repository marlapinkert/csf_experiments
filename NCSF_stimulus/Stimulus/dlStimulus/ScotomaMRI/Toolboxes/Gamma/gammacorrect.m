%Luminance data from Waisman Center MRI stereoscope L & R eye screens
%Data collected w/ Konica Minolta LS-110 photometer on 10/6/11

al = mean([0.18 0.18 0.19]);
bl = mean([0.22 0.22 0.21]);
cl = mean([0.33 0.33 0.33]);
dl = mean([0.68 0.66 0.68]);
el = mean([1.29 1.42 1.43]);
fl = mean([2.92 2.95 2.86]);
gl = mean([4.53 4.75 4.57]);
hl = mean([7.56 6.73 5.9]);
il = mean([9.53 10.55 10.06]);
jl = mean([12.62 13.46 12.83]);
kl = mean([16.13 17.4 17.92]);
ll = mean([24.8 24.68 22.99]);
ml = mean([30.42 29.9 30.24]);
nl = mean([35.48 36.58 35.61]);
ol = mean([41.57 42.64 40.89]);
pl = mean([46.93 49.25 49.53]);
ql = mean([55.65 56.51 56.01]);

ar = mean([0.18 0.19 0.19]);
br = mean([0.19 0.22 0.22]);
cr = mean([0.29 0.31 0.31]);
dr = mean([0.6 0.67 0.64]);
er = mean([1.37 1.46 1.51]);
fr = mean([2.37 1.98 2.31]);
gr = mean([3.4  4.18 4.17]);
hr = mean([6.84 5.86 6.96]);
ir = mean([9.06 8.57 7.56]);
jr = mean([10.37 13.76 14.48]);
kr = mean([18.1 18.46 17.92]);
lr = mean([22.2 21.64 23.64]);
mr = mean([28.71 29.37 29.46]);
nr = mean([36.29 34.83 34.64]);
or = mean([40.05 39.54 38.38]);
pr = mean([35.62 44.78 46.01]);
qr = mean([52.27 55 55.6]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% COMPUTE A CORRECTED/LINEARIZED GAMMA TABLE %%%%
%%%% Adopted from Uki Kamitani 12-7-99
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%---- data, [col1 lum1;col2 lum2;...]
%---- col# steps can be calculated by: "x = 0:s:256" where "s" is the
%number of steps tested in photometercalibration function

dataL=[0 al;16 bl;32 cl;48 dl;64 el;80 fl;96 gl;112 hl;128 il;144 jl;160 kl;176 ll;192 ml;208 nl;224 ol;240 pl;256 ql];
%dataR=[0 ar;16 br;32 cr;48 dr;64 er;80 fr;96 gr;112 hr;128 ir;144 jr;160
%kr;176 lr;192 mr;208 nr;224 or;240 pr;256 qr];

%%%% LEFT EYE SCREEN ####
measL = dataL;
maxIndex = 255;
indexNormal = [0:0.001:1]';
maxLum = measL(size(measL,1),2);

%%%% SELECT A FITTING METHOD %%%%
[out1 params1 message1] = FitGamma(measL(:,1)/maxIndex, measL(:,2)/maxLum, indexNormal,1);

%%%% PLOT DATA POINTS WITH GAMMA FIT %%%%
figure(1);
plot(maxIndex*[0:0.001:1]',maxLum*out1);
hold on;
scatter(measL(:,1),measL(:,2));

%%%% CREATE A GAMMA-CORRECTED TABLE - INVERSE FUNCTION IS CALCULATED
%%%% NUMERICALLY INDEPENDENT OF FITTING CURVES
orgTableL = [maxIndex*indexNormal maxLum*out1];
correctedTableL = [];
for i = 0:255
    eqLum = i*maxLum/maxIndex;
    numTableL = max(find(orgTableL(:,2) <= eqLum));
    correctedTableL = [correctedTableL ; i round(orgTableL(numTableL,1))];
end

%%%% CONFIRM LINEARITY %%%%
figure(2);
linearTableL = [];
for i = 0:255
    numTableL = max(find(orgTableL(:,1) <= correctedTableL(i+1,2)));
    linearTableL = [linearTableL; i orgTableL(numTableL, 2)];
end
plot(linearTableL(:,1), linearTableL(:,2)');

%%%% CORRECTED GAMMA TABLE %%%%
correctedTableL

%%%% GAMMA VALUE %%%%
gammaValue = params1(1)

% this number corresponds to GAMMA in the equation:
% Luminance = constant(frame buffer value)^GAMMA

%%%% Correct color values based on the gamma calculated above. 
%    Desired linear color values (0-255) should be transformed by:
%    255*(<desired color value>/255)^(1/<gamma>) 
%    before color is assigned.

%%%% See help imadjust for how to use this gamma value to gamma correct
%%%% images