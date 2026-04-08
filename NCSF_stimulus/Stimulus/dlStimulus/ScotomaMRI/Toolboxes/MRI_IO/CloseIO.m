function CloseIO(io)
% Close up shop and clean up
%
% As with the opening this takes some time so the display will stay on a
% bit longer than the actual scan (~5-10 seconds).

    CMUBox('Close',io.serial.handle);
    
    clear io64
end