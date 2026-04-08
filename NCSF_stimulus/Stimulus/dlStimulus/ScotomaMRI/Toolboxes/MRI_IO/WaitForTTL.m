function goTime = WaitForTTL(io)
% Function will output different values:
%
% goTime: 0 = no trigger received (should never get this out though..)
%         1 = trigger receiver, let's go!
%        -1 = monitored key was pressed before trigger received
%

    % Read out the 'base' value of the port
    base_state = io64(io.LPT.ioObj, io.LPT.address);
    
    % Monitor port for a change in the value (aka GO TIME!)
    goTime = 0;
    while ~goTime
        status = io64(io.LPT.ioObj, io.LPT.address);
        
        if status ~= base_state
            goTime = 1;
        end
        
        if io.keyboard.monitor
            [keyIsDown, junk, keyCode] = KbCheck(io.keyboard.ID);
            
            if keyIsDown && keyCode(io.keyboard.monitorKey)
                goTime = -1;
            end
        end
    end

end