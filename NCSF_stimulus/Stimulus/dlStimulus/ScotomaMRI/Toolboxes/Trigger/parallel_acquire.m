%**********************************************************
%File: parallel_acquire.m
%Date: 03-23-10
%Parallel Port with MATLAB
%This routine uses the Matlab Data Aquisition Toolbox to
%configure a digital io object for use with the Parallel
%Port.  This is to be used at Waisman to read the 
%Parallel port trigger.
%The best curerent data I have is that the port address is
%&H379 and the Mask is &H10.
%**********************************************************

% Start timing
tic ;

% Turn on acquisition pulse
putvalue(physio_trigger, 1) ;

% Wait 50 ms
while (toc < 0.050) end
    
% Turn off acquisition pulse
putvalue(physio_trigger, 0) ;