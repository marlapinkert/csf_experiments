function varargout = retMenu(varargin)
% retMenu - gui for retinotopic mapping program parameters.
%
% SOD 10/2005: created it, consolidating several existing gui's.

% RETMENU M-file for retMenu.fig
%      RETMENU, by itself, creates a new RETMENU or raises the existing
%      singleton*.
%
%      H = RETMENU returns the handle to a new RETMENU or the handle to
%      the existing singleton*.
%
%      RETMENU('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in RETMENU.M with the given input arguments.
%
%      RETMENU('Property','Value',...) creates a new RETMENU or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before retMenu_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to retMenu_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help retMenu

% Last Modified by GUIDE v2.5 27-Oct-2005 22:38:25

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @retMenu_OpeningFcn, ...
                   'gui_OutputFcn',  @retMenu_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

%----------------------------------------------------------
% --- Executes just before retMenu is made visible.
%----------------------------------------------------------
function retMenu_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to retMenu (see VARARGIN)


% Choose default menu params for retMenu
set(handles.experiment,     'String',setRetinotopyParams);
fixString  = {'disk', 'disk and markers', 'small cross +','double disk','large cross','large cross x+','left disk','right disk', 'left disk double', 'right disk double', 'mid disk double', 'left disk 0.5deg', 'right disk 0.5deg', 'none'};
set(handles.fixation(1),       'String',fixString);
set(handles.savestimparams, 'Value',1); 
set(handles.repetitions,    'String','1');    %#
set(handles.runPriority,    'String','7');    %#
set(handles.skipCycleFrames,'String','0');    %#
set(handles.prescanDuration,'String','12');   %seconds
set(handles.period,         'String','24');   %seconds
set(handles.numCycles,      'String','6');    %#
set(handles.interleaves,    'String','N/A');    %#
set(handles.tr,             'String','1.5');  %seconds
% all .mat files where retMenu lives are considered potentials
tmpdir = which(mfilename);
tmpdir = fileparts(tmpdir);
tmp    = dir([tmpdir filesep '*.mat']);
if ~isempty(tmp),
    tmp2{1}   = 'None'; 
    for n=1:length(tmp),
        tmp2{n+1} = tmp(n).name;
    end;
    set(handles.loadMatrix,     'String',tmp2);  
else,
    set(handles.loadMatrix,     'String','None');
end;
set(handles.saveMatrix,     'String','');  
% all directories in matlabroot displays are considered 
% calibration directories
try,
    mydir{1} = 'None';
    tmpdir = dir(getDisplayPath);
    count = 2;
    for n=1:length(tmpdir), % stupid loop
        if tmpdir(n).isdir & ~strcmp(tmpdir(n).name(1),'.'),
            mydir{count} = tmpdir(n).name;
            count = count+1;
        end;
    end;
    set(handles.calibration,'String',mydir);
catch,
    set(handles.calibration,'String','None');
end;
set(handles.stimSize,      'String','max');

% default command line output for retMenu = menuparams
tmp      = get(handles.experiment,'String');
data.experiment      = tmp(get(handles.experiment,'Value'));      
tmp      = get(handles.fixation(1),'String');
data.fixation      = tmp(get(handles.fixation(1),'Value'));      
data.savestimparams  = get(handles.savestimparams,'Value');;
data.repetitions     = str2double(get(handles.repetitions,'String'));
data.runPriority     = str2double(get(handles.runPriority,'String'));
data.skipCycleFrames = str2double(get(handles.skipCycleFrames,'String'));
data.prescanDuration = str2double(get(handles.prescanDuration,'String'));
data.period          = str2double(get(handles.period,'String'));
data.numCycles       = str2double(get(handles.numCycles,'String'));
data.interleaves     = str2double(get(handles.interleaves,'String'));
data.tr              = str2double(get(handles.tr,'String'));
data.loadMatrix      = 'None';
data.saveMatrix      = [];
data.calibration     = 'None';
data.stimSize        = str2double(get(handles.stimSize,'String'));
if isnan(data.stimSize),
    data.stimSize    = 'max';
end;

% store in handles structure
handles.data = data;

% Update handles structure
guidata(hObject, handles);


% UIWAIT makes retMenu wait for user response (see UIRESUME)
uiwait(handles.figure1);
return;

%----------------------------------------------------------
% --- Outputs from this function are returned to the command line.
%----------------------------------------------------------
function varargout = retMenu_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);

% we want strings from these not cells
if iscell(handles.data.experiment),
    handles.data.experiment = handles.data.experiment{1};
end;
if iscell(handles.data.fixation),
    handles.data.fixation = handles.data.fixation{1};
end;
if iscell(handles.data.loadMatrix),
    handles.data.loadMatrix = handles.data.loadMatrix{1};
end;
if iscell(handles.data.calibration),
    handles.data.calibration = handles.data.calibration{1};
end;

% directory this file lives in
tmpdir = which(mfilename);
tmpdir = fileparts(tmpdir);
tmpdir = [tmpdir filesep];

% if we save the image matrix we put it in the directory this file lives in
if ~isempty(handles.data.saveMatrix),
    handles.data.saveMatrix = ['~/Documents/MATLAB/matfiles/images', handles.data.saveMatrix];
end;

% if no image matrix are found to be loaded -> empty
if strcmp(lower(handles.data.loadMatrix),'none')
    handles.data.loadMatrix = [];
else,
    handles.data.loadMatrix = [tmpdir handles.data.loadMatrix];
end;

if strcmp(lower(handles.data.calibration),'none'),
    handles.data.calibration = [];
end;
    
% output
varargout{1} = handles.data;


% quit
delete(handles.figure1);
return;

%----------------------------------------------------------
% --- These are only executed when changed by user
%----------------------------------------------------------
function experiment_Callback(hObject, eventdata, handles)
% returns experiment contents as cell array
contents = get(hObject,'String');
% returns selected item from experiment
handles.data.experiment = contents{get(hObject,'Value')};
% Set default options for some experiments
% This is convenient (for me) but may be tricky if you are not aware other
% settings are changing as well! So print a warning message at least.
switch handles.data.experiment,
    case {'8 bars','8 bars with blanks','8 bars with blanks (attn)'},
        handles.data.numCycles = 1;
        set(handles.numCycles,      'String','1');    %#
        handles.data.period    = 192;
        set(handles.period,         'String','192');   %seconds

        disp(sprintf('[%s]:WARNING: when setting experiment to %s, num Cycles (%d) and period (%d) have been changed as well!',...
            mfilename,handles.data.experiment,handles.data.numCycles,handles.data.period));
    case {'8 bars with blanks (lr)'},
        handles.data.numCycles = 1;
        set(handles.numCycles,      'String','1');    %#
        handles.data.period    = 272;
        set(handles.period,         'String','272');   %seconds

        disp(sprintf('[%s]:WARNING: when setting experiment to %s, num Cycles (%d) and period (%d) have been changed as well!',...
            mfilename,handles.data.experiment,handles.data.numCycles,handles.data.period));
    
%     case {'8 bars with blanks (lr 2)'},
%         handles.data.numCycles = 1;
%         set(handles.numCycles,      'String','1');    %#
%         handles.data.period    = 240;
%         set(handles.period,         'String','240');   %seconds
% 
%         disp(sprintf('[%s]:WARNING: when setting experiment to %s, num Cycles (%d) and period (%d) have been changed as well!',...
%             mfilename,handles.data.experiment,handles.data.numCycles,handles.data.period));
        
    case {'8 bars with blanks (ecc scaled)'},
        handles.data.fixation       = 'small cross +';
        set(handles.fixation(1),'Value',2); 
        handles.data.numCycles = 1;
        set(handles.numCycles,      'String','1');    %#
        handles.data.period    = 720;
        set(handles.period,         'String','720');   %seconds
        handles.data.stimSize  = 6.25;
        set(handles.stimSize,       'String','6.25');
        
        

        disp(sprintf('[%s]:WARNING: when setting experiment to %s, num Cycles (%d) and period (%d) have been changed as well!',...
            mfilename,handles.data.experiment,handles.data.numCycles,handles.data.period));
        
    case {'8 bars (sinewave)','8 bars (LMS)'},
        handles.data.numCycles = 1;
        set(handles.numCycles,      'String','1');    %#
        handles.data.period    = 288;
        set(handles.period,         'String','288');   %seconds
        disp(sprintf('[%s]:WARNING: when setting experiment to %s, num Cycles (%d) and period (%d) have been changed as well!',...
            mfilename,handles.data.experiment,handles.data.numCycles,handles.data.period));
        
    case {'8 bars (LMS) with blanks'},
        handles.data.fixation       = 'double disk';
        set(handles.fixation(1),'Value',4);      
        handles.data.savestimparams = 1;
        set(handles.savestimparams, 'Value',1); 
        handles.data.repetitions    =10 ;    %#
        set(handles.repetitions,    'String','10');    %#

        handles.data.numCycles = 1;
        set(handles.numCycles, 'String','1');    %#
        handles.data.period    = 288;
        set(handles.period,    'String','288');   %seconds
        disp(sprintf('[%s]:WARNING: when setting experiment to %s, num Cycles (%d) and period (%d) and others have been changed as well!',...
            mfilename,handles.data.experiment,handles.data.numCycles,handles.data.period));
        
    case {'8 bars with blanks contours','8 bars with blanks contours (0)','8 bars with blanks contours (90)','8 bars with blanks contours (-45)','8 bars with blanks contours (+45)','8 bars with blanks contours (random)','8 bars with blanks contours (r0)','8 bars with blanks contours (r90)','8 bars with blanks contours (b0)','8 bars with blanks contours (b90)'},
        handles.data.savestimparams = 1;
        set(handles.savestimparams, 'Value',1); 
        handles.data.numCycles = 1;
        set(handles.numCycles, 'String','1');    %#
        handles.data.period    = 240;
        set(handles.period,    'String','240');   %seconds
        handles.data.prescanDuration = 9;
        set(handles.prescanDuration,    'String','9');   %seconds
        handles.data.stimSize  = 3;
        set(handles.stimSize,  'String','3');
        handles.data.calibration       = '3T_projector_UMC_800x600';
        set(handles.calibration(1),'Value',2);
        handles.data.saveMatrix    = datestr(now,30);
        set(handles.saveMatrix,    'String',datestr(now,30)); 
        
        disp(sprintf('[%s]:WARNING: when setting experiment to %s, num Cycles (%d) and period (%d) and others have been changed as well!',...
            mfilename,handles.data.experiment,handles.data.numCycles,handles.data.period));
        
    case {'radial checkerboard fast', 'radial checkerboard slow temporal', 'radial checkerboard slow spatial'},
        handles.data.savestimparams = 1;
        set(handles.savestimparams, 'Value',1); 
        handles.data.numCycles = 1;
        set(handles.numCycles, 'String','1');    %#
        handles.data.period    = 262.5;
        set(handles.period,    'String','262.5');   %seconds
        handles.data.prescanDuration = 0;
        set(handles.prescanDuration,    'String','0');   %seconds
        %handles.data.calibration       = '3T_lcd_UMC_1920x1200';
        %set(handles.calibration(1),'Value',2);
        handles.data.calibration       = '7T_UMC_1024x768';
        set(handles.calibration(1),'Value',5); 
        handles.data.saveMatrix    = datestr(now,30);
        set(handles.saveMatrix,    'String',datestr(now,30)); 
        handles.data.tr = 1;
        set(handles.tr, 'String','1');
        handles.data.fixation       = 'double disk';
        set(handles.fixation(1),'Value',4); 
        handles.data.tr = 0.5;
        set(handles.tr, 'String','0.5');  
        
        disp(sprintf('[%s]:WARNING: when setting experiment to %s, num Cycles (%d) and period (%d) and others have been changed as well!',...
            mfilename,handles.data.experiment,handles.data.numCycles,handles.data.period));
    case {'radial checkerboard localizer left-still-right-still'},
        handles.data.savestimparams = 1;
        set(handles.savestimparams, 'Value',1); 
        handles.data.numCycles = 2;
        set(handles.numCycles, 'String','2');    %#
        handles.data.period    = 180;
        set(handles.period,    'String','180');   %seconds
        handles.data.prescanDuration = 0;
        set(handles.prescanDuration,    'String','0');   %seconds
        %handles.data.calibration       = '3T_lcd_UMC_1920x1200';
        %set(handles.calibration(1),'Value',2);
        handles.data.calibration       = '7T_UMC_1024x768';
        set(handles.calibration(1),'Value',5); 
        handles.data.saveMatrix    = datestr(now,30);
        set(handles.saveMatrix,    'String',datestr(now,30)); 
        handles.data.tr = 1;
        set(handles.tr, 'String','1');
        handles.data.fixation       = 'double disk';
        set(handles.fixation(1),'Value',4);     
        
        disp(sprintf('[%s]:WARNING: when setting experiment to %s, num Cycles (%d) and period (%d) and others have been changed as well!',...
            mfilename,handles.data.experiment,handles.data.numCycles,handles.data.period));
        
     case {'8 bars with blanks RDK (0)', '8 bars with blanks RDK (90)', '8 bars with blanks RDK (-45)', '8 bars with blanks RDK (+45)', '8 bars with blanks RDK (random)', '8 bars with blanks RDK (90) Fast', '8 bars with blanks RDK (90) Medium', '8 bars with blanks RDK (90) Slow','8 bars with blanks RDK (0) Fast', '8 bars with blanks RDK (0) Medium', '8 bars with blanks RDK (0) Slow'},
        handles.data.savestimparams = 1;
        set(handles.savestimparams, 'Value',1); 
        
        %Overall, period=TR*8*NumberOfSteps + 120 (4*30 seconds for long
        %blanks)
        
%         %Values for TR=2 seconds
%         handles.data.tr = 2;
%         set(handles.tr, 'String','2');
%         handles.data.period    = 440;
%         set(handles.period,    'String','440');   %seconds
%         
        %Values for TR=1.5 seconds
        handles.data.tr = 1.5;
        set(handles.tr, 'String','1.5');
        handles.data.period    = 360;
        set(handles.period,    'String','360');        
          
        handles.data.numCycles = 1;
        set(handles.numCycles, 'String','1');    %#
        handles.data.prescanDuration = 12;
        set(handles.prescanDuration,    'String','12');   %seconds
        handles.data.calibration       = '7T_UMC_1024x768';
        set(handles.calibration(1),'Value',5); 
        handles.data.fixation       = 'double disk';
        set(handles.fixation(1),'Value',4); 

        
        disp(sprintf('[%s]:WARNING: when setting experiment to %s, num Cycles (%d) and period (%d) and others have been changed as well!',...
            mfilename,handles.data.experiment,handles.data.numCycles,handles.data.period));
        
        
    case {'Natural Images 10 Flashes', 'Natural Images 7 Flashes', 'Natural Images 4 Flashes','Natural Images 3 Fades','Natural Images 2 Fades','Natural Images Masks Short', 'Natural Images Masks Long'},
        handles.data.savestimparams = 1;
        set(handles.savestimparams, 'Value',1); 
        handles.data.tr = 2;
        set(handles.tr, 'String','2');
        handles.data.numCycles = 3;
        set(handles.numCycles, 'String','3');    %#
        handles.data.period    = 84;
        set(handles.period,    'String','84');   %seconds
        handles.data.calibration       = '7T_UMC_1024x768';
        set(handles.calibration(1),'Value',5); 
        handles.data.saveMatrix    = datestr(now,30);
        set(handles.saveMatrix,    'String',datestr(now,30)); 

        
        disp(sprintf('[%s]:WARNING: when setting experiment to %s, num Cycles (%d) and period (%d) and others have been changed as well!',...
            mfilename,handles.data.experiment,handles.data.numCycles,handles.data.period));    
    
    case {'Natural Images 3 Flashes','Natural Images Grid 3 Flashes', 'Natural Images Grid 3 Flashes_set2', 'Natural Images Grid 3 Flashes_set3', 'Natural Images 3 Flashes_set1','Natural Images 3 Flashes_set2','Natural Images 3 Flashes_set3'}
        handles.data.savestimparams = 1;
        set(handles.savestimparams, 'Value',1); 
        handles.data.tr = 1.5;
        set(handles.tr, 'String','1.5');
        handles.data.period    = 420;
        set(handles.period,    'String','420');   %seconds
        handles.data.calibration       = '7T_UMC_1024x768';
        set(handles.calibration(1),'Value',5); 
        handles.data.saveMatrix    = datestr(now,30);
        set(handles.saveMatrix,    'String',datestr(now,30)); 
        handles.data.numCycles = 1;
        set(handles.numCycles, 'String','1');  

        
        disp(sprintf('[%s]:WARNING: when setting experiment to %s, num Cycles (%d) and period (%d) and others have been changed as well!',...
            mfilename,handles.data.experiment,handles.data.numCycles,handles.data.period)); 
     case {'Natural Images 3 Flashes_set4','Natural Images 3 Flashes_set5','Natural Images 3 Flashes_set6'}
        handles.data.savestimparams = 1;
        set(handles.savestimparams, 'Value',1); 
        handles.data.tr = 1.5;
        set(handles.tr, 'String','1.5');
        handles.data.period    = 420;
        set(handles.period,    'String','420');   %seconds
        handles.data.calibration       = '7T_DLP_1600x900';
        set(handles.calibration(1),'Value',4); 
        handles.data.saveMatrix    = datestr(now,30);
        set(handles.saveMatrix,    'String',datestr(now,30)); 
        handles.data.numCycles = 1;
        set(handles.numCycles, 'String','1');  

        
        disp(sprintf('[%s]:WARNING: when setting experiment to %s, num Cycles (%d) and period (%d) and others have been changed as well!',...
            mfilename,handles.data.experiment,handles.data.numCycles,handles.data.period)); 
        
    case {'Full-field full'},
        handles.data.savestimparams = 0;
        set(handles.savestimparams, 'Value',0); 
        handles.data.numCycles = 1;
        set(handles.numCycles, 'String','1');    %#
        handles.data.period    = 360;
        set(handles.period,    'String','360');   %seconds
        handles.data.prescanDuration = 12;
        set(handles.prescanDuration,    'String','12');   %seconds
        handles.data.calibration       = '7T_UMC_1024x768';
        set(handles.calibration(1),'Value',5); 
        handles.data.fixation       = 'large cross';
        set(handles.fixation(1),'Value',5); 

        
        disp(sprintf('[%s]:WARNING: when setting experiment to %s, num Cycles (%d) and period (%d) and others have been changed as well!',...
            mfilename,handles.data.experiment,handles.data.numCycles,handles.data.period));  
%         handles.data.fixation       = 'mid disk double';
%         set(handles.fixation(1),'Value',11); 
%         handles.data.savestimparams = 0;
%         set(handles.savestimparams, 'Value',0); 
%         handles.data.numCycles = 5;
%         set(handles.numCycles, 'String','5');    %#
%         handles.data.period    = 6;
%         set(handles.period,    'String','6');   %seconds
%         handles.data.prescanDuration = 0;
%         set(handles.prescanDuration,    'String','0');   %seconds
%         handles.data.calibration       = '7T_UMC_1024x768';
%         set(handles.calibration(1),'Value',4); 
% 
%         
%         disp(sprintf('[%s]:WARNING: when setting experiment to %s, num Cycles (%d) and period (%d) and others have been changed as well!',...
%             mfilename,handles.data.experiment,handles.data.numCycles,handles.data.period));  
        
     case {'Retinotopy Images'},
        handles.data.savestimparams = 1;
        set(handles.savestimparams, 'Value',1); 
        handles.data.tr = 1.5;
        set(handles.tr, 'String','1.5');  
        handles.data.numCycles = 1;
        set(handles.numCycles, 'String','1');    %#
        handles.data.period    = 240;
        set(handles.period,    'String','240');   %seconds
        handles.data.prescanDuration = 12;
        set(handles.prescanDuration,    'String','12');   %seconds
        handles.data.calibration       = '7T_UMC_1024x768';
        set(handles.calibration(1),'Value',5); 
        handles.data.saveMatrix    = datestr(now,30);
        set(handles.saveMatrix,    'String',datestr(now,30)); 
        
        disp(sprintf('[%s]:WARNING: when setting experiment to %s, num Cycles (%d) and period (%d) and others have been changed as well!',...
            mfilename,handles.data.experiment,handles.data.numCycles,handles.data.period));
      
     case {'8 bars with blanks (lr 2)'},
        handles.data.savestimparams = 1;
        set(handles.savestimparams, 'Value',1); 
        handles.data.tr = 1.5;
        set(handles.tr, 'String','1.5');  
        handles.data.numCycles = 1;
        set(handles.numCycles, 'String','1');    %#
        handles.data.period    = 240;
        set(handles.period,    'String','240');   %seconds
        handles.data.prescanDuration = 12;
        set(handles.prescanDuration,    'String','12');   %seconds
        handles.data.calibration       = '7T_UMC_1024x768';
        set(handles.calibration(1),'Value',5); 
        
        disp(sprintf('[%s]:WARNING: when setting experiment to %s, num Cycles (%d) and period (%d) and others have been changed as well!',...
            mfilename,handles.data.experiment,handles.data.numCycles,handles.data.period));
     
    case {'8 bars with blanks (lr 3)'},
        handles.data.savestimparams = 1;
        set(handles.savestimparams, 'Value',1); 
        handles.data.tr = 1.5;
        set(handles.tr, 'String','1.5');
        handles.data.numCycles = 1;
        set(handles.numCycles, 'String','1');    %#
        handles.data.period    = 360;
        set(handles.period,    'String','360');   %seconds
        handles.data.prescanDuration = 12;
        set(handles.prescanDuration,    'String','12');   %seconds
        handles.data.calibration       = '7T_UMC_1024x768';
        set(handles.calibration(1),'Value',5); 
        
        disp(sprintf('[%s]:WARNING: when setting experiment to %s, num Cycles (%d) and period (%d) and others have been changed as well!',...
            mfilename,handles.data.experiment,handles.data.numCycles,handles.data.period));

   case {'pRF bars simultaneous 2h/3v', 'pRF bars simultaneous 3h/4v'},
        handles.data.savestimparams = 1;
        set(handles.savestimparams, 'Value',1); 
        handles.data.tr = 1.5;
        set(handles.tr, 'String','1.5');
        handles.data.numCycles = 1;
        set(handles.numCycles, 'String','1');    %#
        handles.data.period    = 348;
        set(handles.period,    'String','348');   %seconds
        handles.data.prescanDuration = 12;
        set(handles.prescanDuration,    'String','12');   %seconds
        handles.data.calibration       = '7T_UMC_1024x768';
        set(handles.calibration(1),'Value',5); 
        
        disp(sprintf('[%s]:WARNING: when setting experiment to %s, num Cycles (%d) and period (%d) and others have been changed as well!',...
            mfilename,handles.data.experiment,handles.data.numCycles,handles.data.period));
    case {'pRF bars simultaneous 3h/4v (TR 2.1)'},
        handles.data.savestimparams = 1;
        set(handles.savestimparams, 'Value',1); 
        handles.data.tr = 2.1;
        set(handles.tr, 'String','2.1');
        handles.data.numCycles = 1;
        set(handles.numCycles, 'String','1');    %#
        handles.data.period    = 365.4;
        set(handles.period,    'String','365.4');   %seconds
        handles.data.prescanDuration = 12.6;
        set(handles.prescanDuration,    'String','12.6');   %seconds
        handles.data.calibration       = '7T_DLP_1600x900';
        set(handles.calibration(1),'Value',4); 
        
        disp(sprintf('[%s]:WARNING: when setting experiment to %s, num Cycles (%d) and period (%d) and others have been changed as well!',...
            mfilename,handles.data.experiment,handles.data.numCycles,handles.data.period));
   
    case {'Retinotopy Images Cow (lr 3)', 'Retinotopy Images Natural (lr 3)'},
        handles.data.savestimparams = 1;
        set(handles.savestimparams, 'Value',1); 
        handles.data.tr = 1.5;
        set(handles.tr, 'String','1.5');
        handles.data.numCycles = 1;
        set(handles.numCycles, 'String','1');    %#
        handles.data.period    = 360;
        set(handles.period,    'String','360');   %seconds
        handles.data.prescanDuration = 12;
        set(handles.prescanDuration,    'String','12');   %seconds
%         handles.data.calibration       = '7T_UMC_1024x768';
%         set(handles.calibration(1),'Value',5); 
        handles.data.calibration       = '7T_DLP_1600x900';
        set(handles.calibration(1),'Value',4); 
        disp(sprintf('[%s]:WARNING: when setting experiment to %s, num Cycles (%d) and period (%d) and others have been changed as well!',...
            mfilename,handles.data.experiment,handles.data.numCycles,handles.data.period));
        
        
    case {'8 bars with blanks Cow (0) Slow','8 bars with blanks Cow (0) Medium','8 bars with blanks Cow (0) Fast','8 bars with blanks Cow (90) Slow', '8 bars with blanks Cow (90) Medium','8 bars with blanks Cow (90) Fast','8 bars with blanks Cow (Flicker) Slow','8 bars with blanks Cow (Flicker) Fast', '8 bars with blanks Checks Counter (90) 2.5d/s', '8 bars with blanks Checks Counter (90) 5d/s', '8 bars with blanks Checks Together (90) 2.5d/s','8 bars with blanks Checks Together (90) 5d/s', '8 bars with blanks Sine (90) 1.5d/s', '8 bars with blanks Sine (90) 2.5d/s', '8 bars with blanks Sine (90) 3.75d/s', '8 bars with blanks Sine (90) 5d/s', '8 bars with blanks Sine (90) 7.5d/s','8 bars with blanks Sine (0) 2.5d/s', '8 bars with blanks Sine (0) 5d/s', '8 bars with blanks Sine (90) 1.5d/s 20%','8 bars with blanks Sine (90) 2.5d/s 20%','8 bars with blanks Sine (90) 3.75d/s 20%', '8 bars with blanks Sine (90) 5d/s 20%','8 bars with blanks Sine (90) 7.5d/s 20%'},        
        %Overall, period=TR*8*NumberOfSteps + 120 (4*30 seconds for long
        %blanks)
        
%         %Values for TR=2 seconds
%         handles.data.tr = 2;
%         set(handles.tr, 'String','2');
%         handles.data.period    = 440;
%         set(handles.period,    'String','440');   %seconds
%         
        %Values for TR=1.5 seconds
        handles.data.tr = 1.5;
        set(handles.tr, 'String','1.5');
        handles.data.period    = 360;
        set(handles.period,    'String','360');        
          
        handles.data.numCycles = 1;
        set(handles.numCycles, 'String','1');    %#
        handles.data.prescanDuration = 12;
        set(handles.prescanDuration,    'String','12');   %seconds
        handles.data.calibration       = '7T_UMC_1024x768';
        set(handles.calibration(1),'Value',5); 
        handles.data.fixation       = 'double disk';
        set(handles.fixation(1),'Value',4); 
        handles.data.saveMatrix    = datestr(now,30);
        set(handles.saveMatrix,    'String',datestr(now,30)); 
        
        disp(sprintf('[%s]:WARNING: when setting experiment to %s, num Cycles (%d) and period (%d) and others have been changed as well!',...
            mfilename,handles.data.experiment,handles.data.numCycles,handles.data.period));
    case {'Sine motion psychophysics(90)'},        
        %Overall, period=TR*8*NumberOfSteps + 120 (4*30 seconds for long
        %blanks)
        
%         %Values for TR=2 seconds
%         handles.data.tr = 2;
%         set(handles.tr, 'String','2');
%         handles.data.period    = 440;
%         set(handles.period,    'String','440');   %seconds
%         
        %Values for TR=1.5 seconds
        handles.data.tr = 1.5;
        set(handles.tr, 'String','1.5');
        handles.data.period    = 360;
        set(handles.period,    'String','360');        
          
        handles.data.numCycles = 1;
        set(handles.numCycles, 'String','1');    %#
        handles.data.prescanDuration = 12;
        set(handles.prescanDuration,    'String','12');   %seconds
        handles.data.calibration       = 'Desktop_Monitor_1024x768';
        set(handles.calibration(1),'Value',7); 
        handles.data.fixation       = 'double disk';
        set(handles.fixation(1),'Value',4); 
        handles.data.saveMatrix    = datestr(now,30);
        set(handles.saveMatrix,    'String',datestr(now,30)); 
        
        disp(sprintf('[%s]:WARNING: when setting experiment to %s, num Cycles (%d) and period (%d) and others have been changed as well!',...
            mfilename,handles.data.experiment,handles.data.numCycles,handles.data.period));    
    case {'8 bars with blanks (magno)', '8 bars with blanks (parvo)'},
                handles.data.tr = 1.5;
        set(handles.tr, 'String','1.5');
        handles.data.period    = 360;
        set(handles.period,    'String','360');        
          
        handles.data.numCycles = 1;
        set(handles.numCycles, 'String','1');    %#
        handles.data.prescanDuration = 12;
        set(handles.prescanDuration,    'String','12');   %seconds
        handles.data.calibration       = '7T_UMC_1024x768';
        set(handles.calibration(1),'Value',5); 
        handles.data.fixation       = 'disk';
        set(handles.fixation(1),'Value',1); 
        handles.data.saveMatrix    = datestr(now,30);
        set(handles.saveMatrix,    'String',datestr(now,30)); 
        
        disp(sprintf('[%s]:WARNING: when setting experiment to %s, num Cycles (%d) and period (%d) and others have been changed as well!',...
            mfilename,handles.data.experiment,handles.data.numCycles,handles.data.period));
    case {'8 bars with blanks (attention)', '8 bars with blanks (attention checkerboard)'},%, '8 bars with blanks (attention bar psychophysics)', '8 bars with blanks (attention fixation psychophysics)'},
                handles.data.tr = 1.5;
        set(handles.tr, 'String','1.5');
        handles.data.period    = 360;
        set(handles.period,    'String','360');        
          
        handles.data.numCycles = 1;
        set(handles.numCycles, 'String','1');    %#
        handles.data.prescanDuration = 12;
        set(handles.prescanDuration,    'String','12');   %seconds
        handles.data.calibration       = '7T_UMC_1024x768';
        set(handles.calibration(1),'Value',5); 
        handles.data.fixation       = 'largecross';
        set(handles.fixation(1),'Value',5);   
        handles.data.saveMatrix    = datestr(now,30);
        set(handles.saveMatrix,    'String',datestr(now,30)); 
        
        disp(sprintf('[%s]:WARNING: when setting experiment to %s, num Cycles (%d) and period (%d) and others have been changed as well!',...
            mfilename,handles.data.experiment,handles.data.numCycles,handles.data.period));
    case {'8 bars with blanks (attention bar psychophysics)', '8 bars with blanks (attention fixation psychophysics)'},
                handles.data.tr = 1.5;
        set(handles.tr, 'String','1.5');
        handles.data.period    = 360;
        set(handles.period,    'String','360');        
          
        handles.data.numCycles = 1;
        set(handles.numCycles, 'String','1');    %#
        handles.data.prescanDuration = 12;
        set(handles.prescanDuration,    'String','12');   %seconds
        handles.data.calibration       = '7T_UMC_1024x768';
        set(handles.calibration(1),'Value',5); 
        handles.data.fixation       = 'largecross';
        set(handles.fixation(1),'Value',5);   
        handles.data.saveMatrix    = datestr(now,30);
        set(handles.saveMatrix,    'String',datestr(now,30)); 
        
        disp(sprintf('[%s]:WARNING: when setting experiment to %s, num Cycles (%d) and period (%d) and others have been changed as well!',...
            mfilename,handles.data.experiment,handles.data.numCycles,handles.data.period));
      case {'Cow Full Fast', 'Cow Full Medium','Cow Full Slow','Cow Full Still'},        
        handles.data.tr = 1.5;
        set(handles.tr, 'String','1.5');
        handles.data.period    = 60;
        set(handles.period,    'String','60');        
          
        handles.data.numCycles = 1;
        set(handles.numCycles, 'String','1');    %#
        handles.data.prescanDuration = 0;
        set(handles.prescanDuration,    'String','0');   %seconds
        handles.data.calibration       = 'Desktop_Monitor_1024x768';
        set(handles.calibration(1),'Value',7); 
        handles.data.fixation       = 'disk';
        set(handles.fixation(1),'Value',1); 

        
        disp(sprintf('[%s]:WARNING: when setting experiment to %s, num Cycles (%d) and period (%d) and others have been changed as well!',...
            mfilename,handles.data.experiment,handles.data.numCycles,handles.data.period));
    case {'full-field, flicker (sin)','full-field, flicker (check)', 'rotating wedge (90deg duty)', 'rotating wedge (90deg duty) BH'},        
        handles.data.tr = 2.6;
        set(handles.tr, 'String','2.6');
        handles.data.period    = 26;
        set(handles.period,    'String','26');        
          
        handles.data.numCycles = 8;
        set(handles.numCycles, 'String','8');    %#
        handles.data.prescanDuration = 0;
        set(handles.prescanDuration,    'String','0');  
        handles.data.calibration       = '7T_UMC_1024x768';
        set(handles.calibration(1),'Value',5); 
        handles.data.fixation       = 'disk';
        set(handles.fixation(1),'Value',1); 

        
        disp(sprintf('[%s]:WARNING: when setting experiment to %s, num Cycles (%d) and period (%d) and others have been changed as well!',...
            mfilename,handles.data.experiment,handles.data.numCycles,handles.data.period));
case {'left vs right vs blank'},        
        handles.data.tr = 12;
        set(handles.tr, 'String','12');
        handles.data.period    = 24;
        set(handles.period,    'String','24');        
          
        handles.data.numCycles = 12;
        set(handles.numCycles, 'String','24');    %#
        handles.data.prescanDuration = 0;
        set(handles.prescanDuration,    'String','0');  
        handles.data.calibration       = '7T_UMC_1024x768';
        set(handles.calibration(1),'Value',5); 
        handles.data.fixation       = 'disk';
        set(handles.fixation(1),'Value',1); 

        
        disp(sprintf('[%s]:WARNING: when setting experiment to %s, num Cycles (%d) and period (%d) and others have been changed as well!',...
            mfilename,handles.data.experiment,handles.data.numCycles,handles.data.period));

  case {'full-field, flicker (check), stereo', 'rotating wedge (90deg duty) stereo'},        
        handles.data.tr = 3.0;
        set(handles.tr, 'String','3.0');
        handles.data.period    = 48;
        set(handles.period,    'String','48');    
        handles.data.numCycles = 25;
        set(handles.numCycles, 'String','25');    %#
        handles.data.prescanDuration = 0;
        set(handles.prescanDuration,    'String','0');  
        handles.data.calibration       = 'Stereo_7T_UMC_1024x768';
        set(handles.calibration(1),'Value',13); 
        handles.data.fixation       = 'disk';
        set(handles.fixation(1),'Value',1); 

        
        disp(sprintf('[%s]:WARNING: when setting experiment to %s, num Cycles (%d) and period (%d) and others have been changed as well!',...
            mfilename,handles.data.experiment,handles.data.numCycles,handles.data.period));
    case {'8 bars with blanks (Grid)'},
         
        handles.data.tr = 1;
        set(handles.tr, 'String','1');
        handles.data.period    = 180;
        set(handles.period,    'String','180');        
          
        handles.data.numCycles = 1;
        set(handles.numCycles, 'String','1');    %#
        handles.data.prescanDuration = 3;
        set(handles.prescanDuration,    'String','3');   %seconds
%          handles.data.calibration       = '7T_UMC_1024x768';
%          set(handles.calibration(1),'Value',4);
        handles.data.calibration       = 'Grid_IEMU_Display';
        set(handles.calibration(1),'Value',12); 
        
        disp(sprintf('[%s]:WARNING: when setting experiment to %s, num Cycles (%d) and period (%d) and others have been changed as well!',...
            mfilename,handles.data.experiment,handles.data.numCycles,handles.data.period));
      case {'Numbers and Dots Scaled', 'Numbers and Dots Unscaled','Numbers Only', 'Dots Unscaled', 'Dots Scaled', 'Dots Scaled Reverse', 'Dots Attention'},        
        handles.data.tr = 3;
        set(handles.tr, 'String','3');
        handles.data.period    = 36;
        set(handles.period,    'String','36');        
          
        handles.data.numCycles = 6;
        set(handles.numCycles, 'String','6');    %#
        handles.data.prescanDuration = 0;
        set(handles.prescanDuration,    'String','0');   %seconds
        handles.data.calibration       = '7T_UMC_1024x768';
        set(handles.calibration(1),'Value',5); 
%         handles.data.fixation       = 'none';
%         set(handles.fixation(1),'Value',12); 
        handles.data.fixation       = 'large cross';
        set(handles.fixation(1),'Value',5); 
        handles.data.stimSize  = 2;
        set(handles.stimSize,  'String','2');

        
        disp(sprintf('[%s]:WARNING: when setting experiment to %s, num Cycles (%d) and period (%d) and others have been changed as well!',...
            mfilename,handles.data.experiment,handles.data.numCycles,handles.data.period));
        
      case {'Dots Small'},        
        handles.data.tr = 3;
        set(handles.tr, 'String','3');
        handles.data.period    = 36;
        set(handles.period,    'String','36');        
          
        handles.data.numCycles = 6;
        set(handles.numCycles, 'String','6');    %#
        handles.data.prescanDuration = 0;
        set(handles.prescanDuration,    'String','0');   %seconds
        handles.data.calibration       = '7T_UMC_1024x768';
        set(handles.calibration(1),'Value',5); 
        handles.data.fixation       = 'none';
        set(handles.fixation(1),'Value',12); 
        handles.data.stimSize  = 0.25;
        set(handles.stimSize,  'String','0.25');
%         handles.data.fixation       = 'large cross';
%         set(handles.fixation(1),'Value',5); 

        
        disp(sprintf('[%s]:WARNING: when setting experiment to %s, num Cycles (%d) and period (%d) and others have been changed as well!',...
            mfilename,handles.data.experiment,handles.data.numCycles,handles.data.period));
        
      case {'Dots Scaled pRF', 'Dots Scaled pRF full blanks'},        
        handles.data.tr = 3;
        set(handles.tr, 'String','3');
        handles.data.period    = 138;
        set(handles.period,    'String','138');        
          
        handles.data.numCycles = 3;
        set(handles.numCycles, 'String','3');    %#
        handles.data.prescanDuration = 12;
        set(handles.prescanDuration,    'String','12');   %seconds
        handles.data.calibration       = '7T_UMC_1024x768';
        set(handles.calibration(1),'Value',5); 
        handles.data.fixation       = 'large cross';
        set(handles.fixation(1),'Value',5); 
        handles.data.stimSize  = 0.5;
        set(handles.stimSize,  'String','0.5');

        
        disp(sprintf('[%s]:WARNING: when setting experiment to %s, num Cycles (%d) and period (%d) and others have been changed as well!',...
            mfilename,handles.data.experiment,handles.data.numCycles,handles.data.period));
        
     case {'Dots Scaled pRF short', 'Dots Scaled pRF full blanks short'},        
        handles.data.tr = 1.5;
        set(handles.tr, 'String','1.5');
        handles.data.period    = 72;
        set(handles.period,    'String','72');        
          
        handles.data.numCycles = 4;
        set(handles.numCycles, 'String','4');    %#
        handles.data.prescanDuration = 12;
        set(handles.prescanDuration,    'String','12');   %seconds
        handles.data.calibration       = '7T_UMC_1024x768';
        set(handles.calibration(1),'Value',5); 
        handles.data.fixation       = 'large cross';
        set(handles.fixation(1),'Value',5); 
        handles.data.stimSize  = 0.75;
        set(handles.stimSize,  'String','0.75');

        
        disp(sprintf('[%s]:WARNING: when setting experiment to %s, num Cycles (%d) and period (%d) and others have been changed as well!',...
            mfilename,handles.data.experiment,handles.data.numCycles,handles.data.period));
        
        
     case {'Dots Area pRF full blanks TR=1.5, nTRs=3', 'Dots Size pRF full blanks TR=1.5, nTRs=3', 'Numbers Size pRF full blanks TR=1.5, nTRs=3', 'Dots Shapes pRF full blanks TR=1.5, nTRs=3', 'Dots Circumference pRF full blanks TR=1.5, nTRs=3','Dots Dense pRF full blanks TR=1.5, nTRs=3','Dots In Noise pRF full blanks TR=1.5, nTRs=3', 'One Dot Sizes pRF full blanks TR=1.5, nTRs=3'},        
        handles.data.tr = 1.5;
        set(handles.tr, 'String','1.5');
        handles.data.period    = 90;
        set(handles.period,    'String','90');        
          
        handles.data.numCycles = 4;
        set(handles.numCycles, 'String','4');    %#
        handles.data.prescanDuration = 12;
        set(handles.prescanDuration,    'String','12');   %seconds
        handles.data.calibration       = '7T_UMC_1024x768';
        set(handles.calibration(1),'Value',5); 
        handles.data.fixation       = 'large cross';
        set(handles.fixation(1),'Value',5); 
        handles.data.stimSize  = 0.75;
        set(handles.stimSize,  'String','0.75');
        
     case {'Dots HRF'},        
        handles.data.tr = 1.5;
        set(handles.tr, 'String','1.5');
        handles.data.period    = 30;
        set(handles.period,    'String','30');        
          
        handles.data.numCycles = 12;
        set(handles.numCycles, 'String','12');    %#
        handles.data.prescanDuration = 12;
        set(handles.prescanDuration,    'String','12');   %seconds
        handles.data.calibration       = '7T_UMC_1024x768';
        set(handles.calibration(1),'Value',5); 
        handles.data.fixation       = 'large cross';
        set(handles.fixation(1),'Value',5); 
        handles.data.stimSize  = 0.75;
        set(handles.stimSize,  'String','0.75');
        
    case {'Dots psychophysics'},        
        handles.data.tr = 1.5;
        set(handles.tr, 'String','1.5');
        handles.data.period    = 90;
        set(handles.period,    'String','90');        
          
        handles.data.numCycles = 4;
        set(handles.numCycles, 'String','4');    %#
        handles.data.prescanDuration = 12;
        set(handles.prescanDuration,    'String','12');   %seconds
        handles.data.calibration       = '7T_UMC_1024x768';
        set(handles.calibration(1),'Value',5); 
        handles.data.fixation       = 'large cross';
        set(handles.fixation(1),'Value',5); 
        handles.data.stimSize  = 0.75;
        set(handles.stimSize,  'String','0.75');
        
    case {'Dots Size pRF full blanks ECoG TR=1.5, nTRs=3'},        
        handles.data.tr = 1.5;
        set(handles.tr, 'String','1.5');
        handles.data.period    = 72;
        set(handles.period,    'String','72');        
          
        handles.data.numCycles = 1;
        set(handles.numCycles, 'String','1');    %#
        handles.data.prescanDuration = 3;
        set(handles.prescanDuration,    'String','3');   %seconds
        handles.data.calibration       = 'Grid_IEMU_Display';
        set(handles.calibration(1),'Value',10); 
        handles.data.fixation       = 'large cross';
        set(handles.fixation(1),'Value',5); 
        handles.data.stimSize  = 0.75;
        set(handles.stimSize,  'String','0.75');
        
     case {'Dots Size pRF ECoG long random order'},        
        handles.data.tr = 3;
        set(handles.tr, 'String','3');
        handles.data.period    = 135;
        set(handles.period,    'String','144');        
          
        handles.data.numCycles = 1;
        set(handles.numCycles, 'String','1');    %#
        handles.data.prescanDuration = 0;
        set(handles.prescanDuration,    'String','0');   %seconds
        handles.data.calibration       = 'Grid_IEMU_Display';
        set(handles.calibration(1),'Value',10); 
        handles.data.fixation       = 'large cross';
        set(handles.fixation(1),'Value',5); 
        handles.data.stimSize  = 0.75;
        set(handles.stimSize,  'String','0.75');
        
     case {'Dots Area pRF full blanks TR=2.1, nTRs=2','Dots Size pRF full blanks TR=2.1, nTRs=2','Dots Circumference pRF full blanks TR=2.1, nTRs=2','Dots Shapes pRF full blanks TR=2.1, nTRs=2','Dots Dense pRF full blanks TR=2.1, nTRs=2', 'One Dot Sizes pRF full blanks TR=2.1, nTRs=2', 'One Dot Sizes Constant Step pRF full blanks TR=2.1, nTRs=2', 'One Line Size Random Orientation pRF full blanks TR=2.1, nTRs=2', 'One Dot Luminance pRF full blanks TR=2.1, nTRs=2'},        
        handles.data.tr = 2.1;
        set(handles.tr, 'String','2.1');
        handles.data.period    = 92.4;
        set(handles.period,    'String','92.4');        
          
        handles.data.numCycles = 4;
        set(handles.numCycles, 'String','4');    %#
        handles.data.prescanDuration = 12.6;
        set(handles.prescanDuration,    'String','12.6');   %seconds
        handles.data.calibration       = '7T_DLP_1600x900';
        set(handles.calibration(1),'Value',4); 
        handles.data.fixation       = 'large cross';
        set(handles.fixation(1),'Value',5); 
         handles.data.stimSize  = 0.75;
         set(handles.stimSize,  'String','0.75');
%         handles.data.stimSize  = 1.5;
%         set(handles.stimSize,  'String','1.5');
    case {'Dots Area pRF full blanks 4degree low numbers TR=1.95, nTRs=2', 'Dots Area pRF full blanks 4degree high numbers TR=1.95, nTRs=2'}
         handles.data.tr = 1.95;
        set(handles.tr, 'String','1.95');
        handles.data.period    = 85.8;
        set(handles.period,    'String','85.8');        
        handles.data.numCycles = 4;
        set(handles.numCycles, 'String','4');    %#
        handles.data.prescanDuration = 11.7;
        set(handles.prescanDuration,    'String','11.7');   %seconds
        handles.data.calibration       = '7T_Spinoza_1920x1080';
        set(handles.calibration(1),'Value',5); 
        handles.data.fixation       = 'large cross';
        set(handles.fixation(1),'Value',5); 
        % Size of area in degress were stimulus is presented
        handles.data.stimSize  = 2;
        set(handles.stimSize,  'String','2'); 
        
    case {'Timing pRF TR=2.1, Constant Event Number', 'Timing pRF TR=2.1, Duration Constant Frequency','Timing pRF TR=2.1, Constant Event Duration', 'Timing pRF TR=2.1, Event Number Constant Frequency', 'Timing pRF TR=2.1, Constant Set Duration'} 
        handles.data.tr = 2.1;
        set(handles.tr, 'String','2.1');
        handles.data.period    = 117.6;
        set(handles.period,    'String','117.6');        
          
        handles.data.numCycles = 3;
        set(handles.numCycles, 'String','3');    %#
        handles.data.prescanDuration = 12.6;
        set(handles.prescanDuration,    'String','12.6');   %seconds
        handles.data.calibration       = '7T_DLP_1600x900';
        set(handles.calibration(1),'Value',4); 
        handles.data.fixation       = 'large cross';
        set(handles.fixation(1),'Value',5); 
         handles.data.stimSize  = 0.75;
         set(handles.stimSize,  'String','0.75');
        
     case {'One Dot Double Sizes pRF full blanks TR=2.1, nTRs=2'},        
        handles.data.tr = 2.1;
        set(handles.tr, 'String','2.1');
        handles.data.period    = 92.4;
        set(handles.period,    'String','92.4');        
          
        handles.data.numCycles = 4;
        set(handles.numCycles, 'String','4');    %#
        handles.data.prescanDuration = 12.6;
        set(handles.prescanDuration,    'String','12.6');   %seconds
        handles.data.calibration       = '7T_DLP_1600x900';
        set(handles.calibration(1),'Value',4); 
        handles.data.fixation       = 'large cross';
        set(handles.fixation(1),'Value',5); 
         handles.data.stimSize  = 1.5;
         set(handles.stimSize,  'String','1.5');

    case {'Number Symbols pRF full blanks TR=2.1, nTRs=2'},        
        handles.data.tr = 2.1;
        set(handles.tr, 'String','2.1');
        handles.data.period    = 117.6;
        set(handles.period,    'String','117.6');        
          
        handles.data.numCycles = 3;
        set(handles.numCycles, 'String','3');    %#
        handles.data.prescanDuration = 16.8;
        set(handles.prescanDuration,    'String','16.8');   %seconds
        handles.data.calibration       = '7T_DLP_1600x900';
        set(handles.calibration(1),'Value',4); 
        handles.data.fixation       = 'large cross';
        set(handles.fixation(1),'Value',5); 
        handles.data.stimSize  = 0.75;
        set(handles.stimSize,  'String','0.75');
        
     case {'8 bars with blanks (TR 2.1)'},
        handles.data.savestimparams = 1;
        set(handles.savestimparams, 'Value',1); 
        handles.data.tr = 2.1;
        set(handles.tr, 'String','2.1');
        handles.data.numCycles = 1;
        set(handles.numCycles, 'String','1');    %#
        handles.data.period    = 369.6;
        set(handles.period,    'String','369.6');   %seconds
        handles.data.prescanDuration = 12.6;
        set(handles.prescanDuration,    'String','12.6');   %seconds
        handles.data.calibration       = '7T_DLP_1600x900';
        set(handles.calibration(1),'Value',4); 
        handles.data.fixation       = 'large cross';
        set(handles.fixation(1),'Value',5); 
        
        disp(sprintf('[%s]:WARNING: when setting experiment to %s, num Cycles (%d) and period (%d) and others have been changed as well!',...
            mfilename,handles.data.experiment,handles.data.numCycles,handles.data.period));
      case {'8 bars with blanks (TR 1.8)'},
        handles.data.savestimparams = 1;
        set(handles.savestimparams, 'Value',1); 
        handles.data.tr = 1.8;
        set(handles.tr, 'String','1.8');
        handles.data.numCycles = 1;
        set(handles.numCycles, 'String','1');    %#
        handles.data.period    = 360;
        set(handles.period,    'String','360');   %seconds
        handles.data.prescanDuration = 12.6;
        set(handles.prescanDuration,    'String','12.6');   %seconds
        handles.data.calibration       = '7T_DLP_1600x900';
        set(handles.calibration(1),'Value',4); 
%         handles.data.fixation       = 'large cross';
%         set(handles.fixation(1),'Value',5); 
        
        disp(sprintf('[%s]:WARNING: when setting experiment to %s, num Cycles (%d) and period (%d) and others have been changed as well!',...
            mfilename,handles.data.experiment,handles.data.numCycles,handles.data.period));
          
      case {'Dots Gaussian'},        
        handles.data.tr = 3;
        set(handles.tr, 'String','3');
        handles.data.period    = 36;
        set(handles.period,    'String','36');        
          
        handles.data.numCycles = 6;
        set(handles.numCycles, 'String','6');    %#
        handles.data.prescanDuration = 0;
        set(handles.prescanDuration,    'String','0');   %seconds
        handles.data.calibration       = '7T_UMC_1024x768';
        set(handles.calibration(1),'Value',5); 
        handles.data.fixation       = 'none';
        set(handles.fixation(1),'Value',12); 
        handles.data.stimSize  = 1;
        set(handles.stimSize,  'String','1');
        handles.data.fixation       = 'large cross';
        set(handles.fixation(1),'Value',5); 

        
        disp(sprintf('[%s]:WARNING: when setting experiment to %s, num Cycles (%d) and period (%d) and others have been changed as well!',...
            mfilename,handles.data.experiment,handles.data.numCycles,handles.data.period));    
    case {'8 bars with blanks (tr 3)'},
        handles.data.savestimparams = 1;
        set(handles.savestimparams, 'Value',1); 
        handles.data.tr = 3.0;
        set(handles.tr, 'String','3.0');
        handles.data.numCycles = 1;
        set(handles.numCycles, 'String','1');    %#
        handles.data.period    = 384;
        set(handles.period,    'String','384');   %seconds
        handles.data.prescanDuration = 12;
        set(handles.prescanDuration,    'String','12');   %seconds
        handles.data.calibration       = '7T_UMC_1024x768';
        set(handles.calibration(1),'Value',5); 
        handles.data.stimSize  = 6;
        set(handles.stimSize,  'String','6');
        
        disp(sprintf('[%s]:WARNING: when setting experiment to %s, num Cycles (%d) and period (%d) and others have been changed as well!',...
            mfilename,handles.data.experiment,handles.data.numCycles,handles.data.period));
    otherwise,
        % do nothing
end;

guidata(hObject,handles);
return;

function experiment_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
return;


%----------------------------------------------------------
function tr_Callback(hObject, eventdata, handles)
handles.data.tr = str2double(get(hObject,'String'));
guidata(hObject,handles);
return;

function tr_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
return;

%----------------------------------------------------------
function interleaves_Callback(hObject, eventdata, handles)
handles.data.interleaves = str2double(get(hObject,'String'));
guidata(hObject,handles);
return;

function interleaves_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
return;

%----------------------------------------------------------
function numCycles_Callback(hObject, eventdata, handles)
handles.data.numCycles = str2double(get(hObject,'String'));
guidata(hObject,handles);
return;

function numCycles_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
return;

%----------------------------------------------------------
function period_Callback(hObject, eventdata, handles)
handles.data.period=str2double(get(hObject,'String'));
guidata(hObject,handles);
return;

function period_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
return;

%----------------------------------------------------------
function prescanDuration_Callback(hObject, eventdata, handles)
handles.data.prescanDuration = str2double(get(hObject,'String'));
guidata(hObject,handles);
return;

function prescanDuration_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
return;

%----------------------------------------------------------
function skipCycleFrames_Callback(hObject, eventdata, handles)
handles.data.skipCycleFrames = str2double(get(hObject,'String'));
guidata(hObject,handles);
return;

function skipCycleFrames_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
return;

%----------------------------------------------------------
function repetitions_Callback(hObject, eventdata, handles)
handles.data.repetitions = str2double(get(hObject,'String'));
guidata(hObject,handles);
return;

function repetitions_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
return;

%----------------------------------------------------------
function runPriority_Callback(hObject, eventdata, handles)
handles.data.runPriority=str2double(get(hObject,'String'));
guidata(hObject,handles);
return;

function runPriority_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
return;

%----------------------------------------------------------
function fixation_Callback(hObject, eventdata, handles)
contents = get(hObject,'String');
handles.data.fixation=contents{get(hObject,'Value')};
guidata(hObject,handles);
return;

function fixation_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
return;

%----------------------------------------------------------
% --- Executes on button press in go.
function go_Callback(hObject, eventdata, handles)
% now continue and finish
uiresume(handles.figure1);
return;

%----------------------------------------------------------
function Untitled_1_Callback(hObject, eventdata, handles)
return;


%----------------------------------------------------------
function saveMatrix_Callback(hObject, eventdata, handles)
handles.data.saveMatrix=get(hObject,'String');
guidata(hObject,handles);
return;

function saveMatrix_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
return;

%----------------------------------------------------------
% not sure what this one does - i should remove it at some point
function popupmenu4_Callback(hObject, eventdata, handles)
% Hints: contents = get(hObject,'String') returns popupmenu4 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu4
return;

function popupmenu4_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
return

%----------------------------------------------------------
function loadMatrix_Callback(hObject, eventdata, handles)
contents = get(hObject,'String');
if iscell(contents),
    handles.data.loadMatrix=contents{get(hObject,'Value')};
else,
    handles.data.loadMatrix=contents;
end;
guidata(hObject,handles);
return

function loadMatrix_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
return;


%----------------------------------------------------------
function calibration_Callback(hObject, eventdata, handles)
contents = get(hObject,'String');
if iscell(contents),
    handles.data.calibration=contents{get(hObject,'Value')};
else,
    handles.data.calibration=contents;
end;
guidata(hObject,handles);
return

function calibration_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
return;


%----------------------------------------------------------
function stimSize_Callback(hObject, eventdata, handles)
handles.data.stimSize=str2double(get(hObject,'String'));
if isnan(handles.data.stimSize),
    handles.data.stimSize = 'max';
end;
guidata(hObject,handles);
return;


function stimSize_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
return;


%----------------------------------------------------------
function savestimparams_Callback(hObject, eventdata, handles)
handles.data.savestimparams = get(hObject,'Value');
guidata(hObject,handles);
return;


