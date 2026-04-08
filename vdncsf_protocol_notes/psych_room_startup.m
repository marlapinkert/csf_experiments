% Scanner room startup script
% Your MATLAB script

disp([' Matlab startup script for PSYCH ROOM '])
disp('say yes to replacing all the paths')
disp('then press enter till you get to the end')
disp('press enter to continue')
input('');  
% add stimulus files
CSF10_bit_path = '/data1/projects/dumoulinlab/Lab_members/Marcus/programs/Experiments/vdncsf_protocol/CSF10_bit';
addpath(genpath(CSF10_bit_path))
qCSF_path = '/data1/projects/dumoulinlab/Lab_members/Marcus/programs/Experiments/vdncsf_protocol/qCSF_original';
addpath(genpath(qCSF_path))

CSF10_bit_ptb_path = '/packages/matlab/toolbox/psychtoolbox/3.0.17';
% add psychtoolbox 
addpath(genpath(CSF10_bit_ptb_path));
cd(CSF10_bit_ptb_path);
SetupPsychtoolbox;
cd(qCSF_path);
pause(3);

disp('Now the setting up the screen for CSF...')
disp('press b when asked to input a letter.')    
disp('Then press s,  Esc, y, Enter to save and confirm the screen settings ')
disp('press enter to continue')  
input('');  
Screen('Preference', 'SkipSyncTests', 1); % ADDED BY MARCUS - TESTING
BitsPlusImagingPipelineTest(0)
BitsPlusIdentityClutTest(0, 0)
