if Parameters.ConnectET == 1
    ETSampleNo = 10;
    leftEyeAll = [];
    rightEyeAll = [];
    timeStampAll = [];
    
    addpath('~/Dropbox/Experiments/CSF/tobii-analytics-sdk-3.0.37-win-Win32/Matlab/EyeTrackingSample/functions');
    addpath('~/Dropbox/Experiments/CSF/tobii-analytics-sdk-3.0.37-win-Win32/Matlab/tetio');
    
    disp('Initializing tetio...');
    tetio_init();
    
    % Set to tracker ID to the product ID of the tracker you want to connect to.
    trackerId = 'TX120-301-22300547.local.';
    trackerId = regexp(trackerId,'(.*?)(?=\.|$)','match','once');
    
    if (strcmp(trackerId, 'NOTSET'))
        warning('tetio_matlab:EyeTracking', 'Variable trackerId has not been set.');
        disp('Browsing for trackers...');
        
        trackerinfo = tetio_getTrackers();
        for i = 1:size(trackerinfo,2)
            disp(trackerinfo(i).ProductId);
        end
        
        tetio_cleanUp();
        error('Error: the variable trackerId has not been set. Edit the EyeTrackingSample.m script and replace "NOTSET" with your tracker id (should be in the list above) before running this script again.');
    end
    
    fprintf('Connecting to tracker "%s"...\n', trackerId);
    tetio_connectTracker(trackerId)
    
    currentFrameRate = tetio_getFrameRate;
    fprintf('Frame rate: %d Hz.\n', currentFrameRate);
    
    % Calibration of the eye-tracker
    SetCalibParams;
    
    disp('Starting TrackStatus');
    % Display the track status window showing the participant's eyes (to position the participant).
    TrackStatus; % Track status window will stay open until user key press.
    disp('TrackStatus stopped');
    
    disp('Starting Calibration workflow');
    % Perform calibration
    HandleCalibWorkflow(Calib);
    disp('Calibration workflow stopped');
end