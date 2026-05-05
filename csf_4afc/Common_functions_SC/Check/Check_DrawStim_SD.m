% 2IFC - Method of Constant Stimuli
clc; clear all; close all;

% Initialisation
addpath('../resources_SC');
addpath('../Common_functions_SC');
format longG % Display numbers in full digits, not with scientific notation

% Define experimental parameters
DateToday = datetime(floor(now),'ConvertFrom','datenum','Format','dd-MMM-yy');

prompt = {'SUBJECT ID (001)','DOB (DD-MMM-YYYY)','SCAN DATE (DD-MMM-YYYY)',...
    'PATIENT (0/1)?','CHILD (0/1)?', ...
    'VIEWING DISTANCE (cm)','DEBUG MODE (0/1)?','PROJECTOR (0/1)?'};
definput = {'Test','01-Jan-2000',datestr(DateToday),...
    '0','0',...
    '107','0','0'};
answer = inputdlg(prompt,'Experimental parameters',[1 85],definput);
Parameters.Subj_ID = answer{1};
Parameters.Subj_DOB = answer{2};
Parameters.Subj_ScanDate = answer{3};
Parameters.Subj_Patient = str2double(answer{4});
Parameters.Subj_AgeGroup = str2double(answer{5});
Parameters.ViewingDistance = str2double(answer{6});
Parameters.DebuggingMode = str2double(answer{7});
Parameters.Projector = str2double(answer{8});
clear answer prompt definput DateToday

% Create participant's folder
FolderName = sprintf('../data/%s',Parameters.Subj_ID);
if ~exist(FolderName,'dir')
    mkdir(FolderName);
end

% Choose calibration file and type of calibration
disp('Choose calibration file to apply...')
[file,path] = uigetfile('*.mat');
load(fullfile(path,file),'inCorrected_Spline');
answer = questdlg('WHICH METHOD?', ...
    'GAMMA CORRECTION', ...
    'SPLINE-FIT','POWER-FIT','SPLINE-FIT');
% Handle response
switch answer
    case 'SPLINE-FIT'
        gammaTable = inCorrected_Spline;
    case 'POWER-FIT'
        gammaTable = Cal_Power{1,1}.gammaTable';
end
clear answer inCorrected_Spline LuminanceData LuminanceData2 LumMeasures Cal_Power file path;

% Define some of the Gabor parameters
prompt = {'RUN NUMBER','SPATIAL FREQ. TO TEST (cpd)',...
    'STIM CONDITION: full-field, peripheral vision, central vision (1/2/3)',...
    'SD GAUSSIAN HULL (deg: NaN if full-field)',...
    'TEMPORAL FREQ. (Hz)','ECCENTRICITY (deg)',...
    'ORIENTATION (deg; default: horizontal)'};
definput = {'1','0.5,1,3,6,12,20','1','1,NaN','2','0','0'};
answer = inputdlg(prompt,'Experimental parameters',[1 85],definput);

run = str2num(answer{1});
Gabor.SFcpd = str2num(answer{2});
Gabor.StimCondition = str2num(answer{3});
Gabor.StimConditionLabels = {'FullField','PeriVision','CentreVision'};
disp(['Selected condition: ' Gabor.StimConditionLabels{Gabor.StimCondition}])
if Gabor.StimCondition == 1
    Gabor.SpacialConstant_Deg = NaN;
elseif Gabor.StimCondition == 2 % Peripheral vision = cover the centre
    Gabor.SpacialConstant_Deg = NaN;
    answer_scotoma = inputdlg('CENTRAL SCOTOMA (deg radius)','CENTRAL SCOTOMA',[1 85],{'1'});
    Gabor.CentralScotoma_deg = str2num(answer_scotoma{1});
    clear answer_scotoma
elseif Gabor.StimCondition == 3 % Central vision = cover the periphery
    Gabor.SpacialConstant_Deg = str2num(answer{4});
end
Gabor.TF = str2double(answer{5});
Gabor.Ecc_Deg = str2double(answer{6});
Gabor.Orientation = str2double(answer{7});

clear answer answer_scotoma prompt

%% Initialise screen, Sounddriver & keyboard
SetUpDisplay
SetUpSound

% Keyboard
KeyBoardIdx = GetKeyboardIndices(); % idx 1 = external keyboard, idx 2 = Mac keyboard
if length(KeyBoardIdx) < 2
    AllowedKey = {'1!','2@'};
else
    AllowedKey = {'1','2'};
end

% Set random seed
rSeed = RandStream('mt19937ar','Seed','shuffle');
RandStream.setGlobalStream(rSeed); %To reproduce the same RandStream::: rSeed rSeed.NormalTransform = 'Ziggurat'; reset(rSeed,1757208590); RandStream.setGlobalStream(rSeed);

%% Initialise Gabor patch and Noise patch
Gabor_Initialisation
NoisePatch_Initialisation

if Gabor.StimCondition == 2 % Central scotoma
    Gabor.CentralScotoma_pix = Gabor.CentralScotoma_deg*Parameters.pixperdeg;
    DrawCentralScotoma_Pix = [ScreenRect(3)/2-Gabor.CentralScotoma_pix ScreenRect(4)/2-Gabor.CentralScotoma_pix ScreenRect(3)/2+Gabor.CentralScotoma_pix ScreenRect(4)/2+Gabor.CentralScotoma_pix];
end

%% Shuffle Freq and Gaussian Hull size
Freq = Gabor.SFcpd; % Frequency(ies) to test
[Freq,idxFreq] = Shuffle(Freq);
[Gabor.SCShuffle,idxSCSize]= Shuffle(Gabor.sigmapx);

%%
% Define target contrast
targContrast = 0; % Normalised contrast value
SC = 1; FF = 1;
r = 1; % reversal

% Define the stimulus texture (before each trial)
[gaborid,dstRect] = MakeGaborContrast(Stimulus,targContrast,XYLoc_px_gabor,Parameters,w,ScreenRect,idxFreq,FF,idxSCSize,SC); %Gabor patch presentation
Screen('DrawTexture', w, gaborid(r), [], dstRect(r,:), 0+Gabor.Orientation, [], [], [], [], []);
Screen('Flip', w);

imagearray=Screen('GetImage',w,ScreenRect,[],1,1);

%% Plot stimulus to look at intensity spikes 

figure('Position',[ScreenRect])
set(gcf,'Color',[1 1 1])
hold on
plot(imagearray(:,:,1))
middleplot = ScreenRect(4)/2+0.5;
FWHH_factor = 2*sqrt(2*log(2)); % log function = ln (if log10 -> log base 10)

plot(ones(6,1)*middleplot,[0:0.2:1],'k-','LineWidth',2)
plot(linspace(middleplot-FWHH_factor*Gabor.sigmapx(idxSCSize(SC)),middleplot+FWHH_factor*Gabor.sigmapx(idxSCSize(SC)),6),0.75*ones(6,1),'k--','LineWidth',2)

a = plot(ones(6,1)*(middleplot+Gabor.sigmapx(idxSCSize(SC))),[0:0.2:1],'r--','LineWidth',2);
plot(ones(6,1)*(middleplot-Gabor.sigmapx(idxSCSize(SC))),[0:0.2:1],'r--','LineWidth',2);
b = plot(ones(6,1)*(middleplot+FWHH_factor*Gabor.sigmapx(idxSCSize(SC))),[0:0.2:1],'b--','LineWidth',2);
plot(ones(6,1)*(middleplot-FWHH_factor*Gabor.sigmapx(idxSCSize(SC))),[0:0.2:1],'b--','LineWidth',2);
l = legend([a b],{'±1 SD','FWHH'},'FontSize',18);
title(l,{['Gaussian Enveloppe:'],['SD=' num2str(Gabor.SpacialConstant_Deg(idxSCSize(SC))) 'deg']})
set(gca,'LineWidth',2,'FontSize',18)
axis([1 ScreenRect(4) 0 1]);
