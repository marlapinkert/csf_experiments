function buttonPress = CheckButtonPress(io, purgePort)
% Reads out serial port and reports state back as 'response'
%
% For a 4-button box this will report either:
%   0: nothing was pressed
%   1: button 1
%   2: button 2
%   4: button 3
%   8: button 4
%
%   Different values can occur if someone presses multiple buttons
%   simultaneously (will be sum of button values), so e.g. value of 3 will
%   mean that the subject pressed buttons 1 and 2 together (bad subject!)
%
%   purgePort can be set to 0 if you don't want to clear out the serial
%   port after every read-out

    if ~exist('purgePort','var') || isempty(purgePort)
        purgePort = 1;
    end

    % read out serial port
    evt = CMUBox('Event',io.serial.handle);
    
    % store state ('response')
    buttonPress = evt.state;
    
    % clear buffer
    if purgePort
        IOPort('Purge',0);
    end

end