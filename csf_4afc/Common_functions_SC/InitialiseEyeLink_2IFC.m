% InitialiseEyeLink_2IFC
% Goal of the function :
% Initializes eyeLink-connection, creates edf-file
% and writes experimental parameters to edf-file
% ----------------------------------------------------------------------
% Input(s) :
% wPtr : window pointer.
% elparam : struct containing many constant configuration.
% ----------------------------------------------------------------------
% Output(s):
% el : eye-link structure.
% elparam : struct containing edfFileName
% ----------------------------------------------------------------------
% Function created by Martin SZINTE (martin.szinte@gmail.com)
% Last update : 15 / 11 / 2011
% Project : CrowdedSac
% Version : 2.0
% ----------------------------------------------------------------------

%% Define EDF file name :
tmpname = strcat(Parameters.Subj_ID,'.edf');
elparam.edffilename = tmpname;

%% Modify different defaults settings :
el=EyelinkInitDefaults(w);

el.backgroundcolour = 0.5;
el.msgfontcolour    = 0; %from LandoltAcuityInitialise code
el.imgtitlecolour   = 0;
el.targetbeep       = 1;
el.calibrationtargetcolour= 1;
%el.calibrationtargetsize= 5;
%el.calibrationtargetwidth=0.5;
el.displayCalResults = 1;
el.eyeimgsize=50;
% el.backgroundcolour = elparam.colBG;		
% el.foregroundcolour = wPtr.white;       
el.calibrationtargetsize=elparam.CalTarRadVal;         % radius (pix) of calibration target (used in my modified version of EyelinkDrawCalTarget)
el.calibrationtargetwidth=elparam.CalTarWidthVal;      % radius (pix) of inside bull's eye of calibration target (used in my modified version of EyelinkDrawCalTarget)
el.txtCol = 80; % Betweem 0-255
el.bgCol  = 0; 
el.targetbeep = 1;              % put 0 if no sound desired

EyelinkUpdateDefaults(el);

%% Initialization of the connection with the Eyelink Gazetracker. 
dummymode = elparam.TEST; %whether or not to use dummymode

if ~EyelinkInit(dummymode)
    fprintf('Eyelink Init aborted.\n');
    Eyelink('Shutdown');
    Screen('CloseAll');
    return;
end

%% open file to record data to
res = Eyelink('Openfile', elparam.edffilename);
if res~=0
    fprintf('Cannot create EDF file ''%s'' ', elparam.edffilename);
    Eyelink('Shutdown');
    Screen('CloseAll');
    return;
end

% Describe general information on the experiment :
Eyelink('command', 'add_file_preamble_text ''CSF_2IFC''');

% make sure we're still connected.
if Eyelink('IsConnected')~=1 && ~dummymode
    fprintf('Not connected. exiting');
    Eyelink('Shutdown');
    Screen('CloseAll');
    return;
end

%% Set up tracker personal configuration :

angle = 0:pi/2:3*(pi/2); %0,90,180,270 deg

centX = round(ScreenRect(3)/2);
centY = round(ScreenRect(4)/2);

% compute calibration target locations
[cx1,cy1] = pol2cart(angle,0.5);
[cx2,cy2] = pol2cart(angle,0.5);

cx = round(centX + centX*[0 cx1 cx2]);
cy = round(centY + centY*[0 cy1 cy2]);

% start at center, select randomly, end at center
crp = randperm(4)+1;
c(1:2:12) = [cx(1) cx(crp) cx(1)];
c(2:2:12) = [cy(1) cy(crp) cy(1)];

% compute validation target locations (calibration targets smaller radius)
[vx1,vy1] = pol2cart(angle,0.5);
[vx2,vy2] = pol2cart(angle,0.5);

vx = round(centX + centX*[0 vx1 vx2]);
vy = round(centY + centY*[0 vy1 vy2]);

% start at center, select randomly, end at center
vrp = randperm(4)+1;
v(1:2:12) = [vx(1) vx(vrp) vx(1)];
v(2:2:12) = [vy(1) vy(vrp) vy(1)];

Eyelink('command','screen_pixel_coords = %ld %ld %ld %ld', 0, 0, ScreenRect(3)-1, ScreenRect(4)-1);
Eyelink('message', 'DISPLAY_COORDS %ld %ld %ld %ld', 0, 0, ScreenRect(3)-1, ScreenRect(4)-1);

Eyelink('command', 'screen_distance %ld %ld', double(Parameters.ViewingDistance*10), double(Parameters.ViewingDistance*10)); %specify distance as mm_to_top and mm_to_bottom of monitor
Eyelink('message', 'SCREEN_DISTANCE %ld %ld',double(Parameters.ViewingDistance*10),double(Parameters.ViewingDistance*10));

Eyelink('command', 'recording_parse_type = GAZE'); %set to gaze rather than HREF or pupil coordinates

Eyelink('command', 'calibration_type = HV5');
Eyelink('command', 'generate_default_targets = NO');

Eyelink('command', 'randomize_calibration_order 0');
Eyelink('command', 'randomize_validation_order 0');
Eyelink('command', 'cal_repeat_first_target 0');
Eyelink('command', 'val_repeat_first_target 0');

Eyelink('command', 'calibration_samples=6');
Eyelink('command', 'calibration_sequence=0, 1, 2, 3, 4, 5'); %, 6, 7, 8, 9, 10, 11, 12, 13');
Eyelink('command', sprintf('calibration_targets = %i,%i %i,%i %i,%i %i,%i %i,%i %i,%i',c)); %i %i,%i %i,%i %i,%i %i,%i %i,%i %i,%i %i,%i %i,%i %i,%i %i,%i %i,%i',c));

Eyelink('command', 'validation_samples=6');
Eyelink('command', 'validation_sequence=0, 1, 2, 3, 4, 5');
Eyelink('command', sprintf('validation_targets = %i,%i %i,%i %i,%i %i,%i %i,%i %i,%i',v));

clear centX centY crp cx* cy* v vrp vx* vy* 

%% Set parser
%Sets up columns of eyelink file
%Eyelink('command', 'saccade_velocity_threshold = 35');
%Eyelink('command', 'saccade_acceleration_threshold = 9500');

Eyelink('command', 'file_event_filter = LEFT,RIGHT,FIXATION,SACCADE,BLINK,MESSAGE,BUTTON');
Eyelink('command', 'file_sample_data  = LEFT,RIGHT,GAZE,AREA');
Eyelink('command', 'link_event_filter = LEFT,RIGHT,FIXATION,SACCADE,BLINK,MESSAGE,BUTTON');
Eyelink('command', 'link_sample_data  = LEFT,RIGHT,GAZE,AREA');

Eyelink('command', 'heuristic_filter = 1 1');

%% Set pupil Tracking model in camera setup screen  (no = centroid. yes = ellipse)
Eyelink('command', 'use_ellipse_fitter =  NO');

%% set sample rate in camera setup screen
Eyelink('command', 'sample_rate = %d',1000);

%% Experiment descriptions into the edf-file :
Eyelink('message', 'START OF DESCRIPTIONS');
Eyelink('message', '%s', SaveName);
Eyelink('message', '**CSF2IFC**');
Eyelink('message', 'Experiment measuring contrast sensitivity acroos visual field'); 
Eyelink('message', 'END OF DESCRIPTIONS');

% Test mode of eyelink connection :
status = Eyelink('IsConnected');
switch status
    case -1
        fprintf(1, '\tEyelink in dummymode.\n\n');
    case  0
        fprintf(1, '\tEyelink not connected.\n\n');
    case  1
        fprintf(1, '\tEyelink connected.\n\n');
end

% make sure we're still connected.
if Eyelink('IsConnected')~=1 && ~dummymode
    fprintf('Not connected. exiting');
    Eyelink('Shutdown');
    Screen('CloseAll');
    return;
end

