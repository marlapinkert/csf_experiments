% ret - program to start retinotopic mapping experiments (under OSX)
%       
%
% 06/2005 SOD Ported to OSX. If the mouse is invisible,
%             moving it to the Dock usually makes it reappear.
% 10/2005 SOD Several changes, including adding gui.

% clean up - it's good to clean up but mex files are extremely slow to be
% loaded for the first time in MacOSX, so I chose not to do this to speed
% things up.
%close all;close hidden;
%clear mex;clear all;
%pack;

% ask parameters with user interface
params = retMenu;
drawnow;

% % now set rest of the params
% params = setRetinotopyParams(params.experiment, params);

% set response device
% old way keep for compatibility
params.devices = getDevices(false);
if isempty(params.devices.keyInputExternal)
    params.devices.keyInputExternal = params.devices.keyInputInternal;
end
% new w
if strcmp(computer('arch'), 'maci64')
    params.use64 = 1;
else
    params.use64 = 0;
end
    
if params.use64    
   
    params.devices.UMCport = '/dev/cu.KeySerial1';
    
    params.devices.handle = []; % use this for testing with keyboard
    [junk, junk, params] = deviceUMC64('open',params);
else
    params.devices.UMCport = 2;%-1;%2;%-1;%2; % default = 2; set to -1 for testing without device
    fprintf('[%s]:Using port %d.\n',mfilename,params.devices.UMCport);
    deviceUMC('open',params.devices.UMCport);    
end


% go
oldLevel = Screen('Preference', 'Verbosity', 1);
doRetinotopyScan(params);
Screen('Preference', 'Verbosity', oldLevel);

% clean up
if params.use64 && ~isempty(params.devices.handle)
    %deviceUMC64('close');
    IOPort('CloseAll');
else
    deviceUMC('close',params.devices.UMCport);
end