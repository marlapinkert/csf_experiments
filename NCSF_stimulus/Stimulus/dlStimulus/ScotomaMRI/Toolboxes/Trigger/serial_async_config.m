    % This file configures the serial port for asynchronous reads.
s = serial('COM1') ;            % Self evident
set (s, 'BaudRate', 57600) ;    % Baud rate as set by Waisman
set (s, 'ReadAsyncMode', 'manual') ;
set(s, 'BytesAvailableFcnMode', 'byte') ;

% If BytesAvailableFcnMode is byte, the bytes-available event executes the 
% callback function specified for the BytesAvailableFcn property every time 
% the number of bytes specified by BytesAvailableFcnCount is stored in the 
% input buffer. If BytesAvailableFcnMode is terminator, the callback function 
% executes every time the character specified by the Terminator property is 
% read.

set (s, 'InputBufferSize', 1) ;
