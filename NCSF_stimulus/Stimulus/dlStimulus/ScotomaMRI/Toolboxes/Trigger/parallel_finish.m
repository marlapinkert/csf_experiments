%**********************************************************
%File: parallel_finish.m
%Date: 08-25-09
%Parallel Port with MATLAB
%This routine uses the Matlab Data Aquisition Toolbox to
%finish using the parallel port.
%**********************************************************

parallel_port = digitalio('parallel', 'LPT1') ;
fMRI_trigger = addline(parallel_port,0:3,1,'In') ;

delete(parallel_port) ;
clear parallel_port ;

delete(bold_rep_trigger) ;
