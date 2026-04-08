% loc - UPDATE MARCUS
% If there are mex problems - you can fix this with the 
% clean up - it's good to clean up but mex files are extremely slow to be
% loaded for the first time in MacOSX, so I chose not to do this to speed
% things up. `
% close all;close hidden;
% clear mex;clear all;

% **** FOR MARCUS SCANNING TODAY ***
% RUN LOC
% enter run number 
% select calibration (10bits)
% "waiting for scanner screen"
% proceed on scanner...
% 

close('all'); clc;
clear all;
qcsf_dir = '/data1/projects/dumoulinlab/Lab_members/Marcus/programs/Experiments/vdncsf_protocol/qCSF_original';
ncsf_dir = '/data1/projects/dumoulinlab/Lab_members/Marcus/programs/Experiments/vdncsf_protocol/CSF_10bit';
peri_dir = '/data1/projects/dumoulinlab/Lab_members/Marcus/programs/Experiments/vdncsf_protocol/Perimetry';
cd(ncsf_dir);
addpath(genpath(ncsf_dir))
rmpath(genpath(qcsf_dir))
rmpath(genpath(peri_dir))

% INFO 
initials = 'amb02';
sesNum = 'scanLE';
runNum      = input('Please enter run number: ', 's');
eyeViewing = 'L'; % L/R
sesFileName = ['sub-' initials '_ses-' sesNum '_run-' runNum '_eye-' eyeViewing];
disp(sesFileName)
doEyeTracking = 0;
location = 'psych'; % psych/scanner
fix_size_pixels = 80; % 5=default, amb02=80

%
Screen('Preference', 'SkipSyncTests', 1); 
CSF10_bit_path = '/data1/projects/dumoulinlab/Lab_members/Marcus/programs/Experiments/vdncsf_protocol/CSF_10bit';
addpath(genpath(CSF10_bit_path))

commandwindow
% pack; 

% ask parameters with user interface
params = locMenu;
drawnow;

% now set rest of the params
params = setLocParams(params.experiment, params);
params.sesFileName = sesFileName;
params.doEyelink = doEyeTracking;
params.eyeViewing = eyeViewing;
params.output_folder = [CSF10_bit_path '/Output'];
params.display.fixSizePixels = fix_size_pixels;
params.x_location = location;
% Get the current date and time
currentDateTime = datetime('now');
dateTimeString = datestr(currentDateTime);
params.x_date_time_string = dateTimeString;

% set response device
params.devices = getDevices(false);

if isempty(params.devices.keyInputExternal)
    params.devices.keyInputExternal = params.devices.keyInputInternal;
end
fprintf('[%s]:Getting subjects responses from device #%d\n',mfilename,params.devices.keyInputExternal);
fprintf('[%s]:Getting experimentor''s responses from device #%d\n',mfilename,params.devices.keyInputInternal);

% go
doLocScan(params);
sca;

