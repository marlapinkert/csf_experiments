clear all;

addpath(genpath([pwd '/Toolboxes']));    

config_io;
    global cogent;
    address = hex2dec('3011');%hex2dec('378');
    %ioObj = io64();
    
    base_status = io64(cogent.io.ioObj,address)    
    
    % Wait for LPT-1 trigger
    goTime = 0;
    tStart = GetSecs;
    while ~goTime && (GetSecs-tStart)<30
        status = io64(cogent.io.ioObj,address)
        if status ~= base_status
            goTime = 1;
        end        
    end
    
    clear io64
    disp('Scanner started');
