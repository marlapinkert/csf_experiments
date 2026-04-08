function dispPath = getDisplayPath()
% getDisplayPath - path where screen information resides
%
% dispPath = getDisplayPath
%
dispPath = '/data1/projects/dumoulinlab/Lab_members/Marcus/programs/Experiments/vdncsf_protocol/CSF_10bit/Stimulus/Displays';
if ~exist(dispPath,'dir')
    warning(sprintf('[%s]: display path does not exist (%s)\n',mfilename,dispPath));
end

return;