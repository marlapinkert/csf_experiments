function io = SetupIO(portAddress, monitorKeyboard, monitorKey, kbID)
% Function to setup all the IO stuff needed to work with the 
% MRI scanner at the Waisman center in Madison, Wisconsin (but might work
% elsewhere too...)
%
% Note that it takes some time to install/open all of these so you might
% want to put something on the screen to assure the subject (or yourself)
% that Matlab has not stopped working but is just busy :-)

    if ~exist('portAddress','var') || isempty(portAddress)
        % default to last known value for Waisman (might stop working at
        % some point so please always supply known value!)
        portAddress = '3011';
        
        disp('WARNING: defaulting to last known LPT port address for Waisman (3011). This might stop working at some point so please always supply this value!)');
    end
    
    if isnumeric(portAddress)
        portAddress = num2str(portAddress);
    end

    % Install LPT port driver and open handle

    % create IO64 interface object
    io.LPT.ioObj = io64();

    % install the inpoutx64.dll driver
    % status = 0 if installation successful
    io.LPT.status = io64(io.LPT.ioObj);
    if(io.LPT.status ~= 0)
        disp('inp/outp installation failed!')
    end    

    % store port addres for later use
    io.LPT.address = hex2dec(portAddress);
    
    % Open handle for serial port
    io.serial.handle = CMUBox('Open','pst','COM1');

    % Monitor keyboard for special key (which will quit the WaitForTTL function)
    if exist('monitorKeyboard','var') && monitorKeyboard && exist('kbID','var') && ~isempty(kbID) && exist('monitorKey','var') && ~isempty(monitorKey) 
        io.keyboard.monitor = 1;
        io.keyboard.ID = kbID;
        io.keyboard.monitorKey = monitorKey;
    end
    
end