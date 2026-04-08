%% Setup 16 bit screen, eyetracker room
%{
I've already done this - so don't need to do it:
* Connect Display++ to computer (usb)
* Find the COM port number for D++ (see Device Manager)
* Run PsychtoolboxConfigDir to find out where PTB puts the configuration
information
* In that folder put a plain text file called "BitsSharpConfig.txt" and
just write the name of the COM port (e.g., COM4)
* Then run in matlab:
BitsPlusIdentityClutTest(2) % (screen 2)
* lots of text produced in MATLAB window, check that the D++ serial number
is produced.
* If what is shown on Display++ screen matches the description on the
screen then this is good! Press "s" then "esc" then "y" and "enter", as
instructed to save the settings. 
* Otherwise cycle through (basically follow instructions - press space 
until the screen matches the description)

*** THIS HAS ALL BEEN DONE *** 
%}

% To check that it is all working do this:
% press 'b' when asked to input a letter.
BitsPlusImagingPipelineTest(2) % screen number 2
