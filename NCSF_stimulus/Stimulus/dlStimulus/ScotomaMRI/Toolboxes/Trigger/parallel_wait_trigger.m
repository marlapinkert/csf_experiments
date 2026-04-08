%**********************************************************
%File: parallel_wait_trigger.m
%Date: 08-25-09
%Parallel Port with MATLAB
%This routine uses the Matlab Data Aquisition Toolbox to
%wait for a parallel port trigger to come through the 
%status bits.  This is to be used at the fMRI and will
%require a bit of on-site tweaking.
%**********************************************************

% Get the initial value.  This assumes the trigger is off.
bold_rep_initial = getvalue(bold_rep_trigger); % No semi-colon yet to view initial state.

bStop = false ;

while (bStop == false) 
    
    % Read the trigger
    bold_rep_status = getvalue(bold_rep_trigger) ;
    
    % Compare status to pre_trigger.
    if (bold_rep_status ~= bold_rep_initial)
        
        bold_rep_status ;
        bStop = true ;
        
    end
    
end

clear bold_rep_initial ;
clear bold_rep_status ;
clear bStop ;