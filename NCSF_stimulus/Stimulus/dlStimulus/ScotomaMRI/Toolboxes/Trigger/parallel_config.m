%**********************************************************
%File: parallel_config.m
%Date: 08-25-09
%Parallel Port with MATLAB
%This routine uses the Matlab Data Aquisition Toolbox to
%configure a digital io object for use with the Parallel
%Port.  This is to be used at Waisman to read the 
%Parallel port trigger.
%The best curerent data I have is that the port address is
%&H379 and the Mask is &H02.
%**********************************************************

% Grab the PCI_DIO24 board.  In this case it's the 0 board while
% the USB device is the 1 board.
parallel_port = digitalio('parallel', 'LPT1') ;
bold_rep_trigger = addline(parallel_port,2,1,'In') ;
physio_trigger = addline(parallel_port,3,2,'Out');
