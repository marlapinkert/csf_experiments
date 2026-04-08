function getNumberOfTriggers(params,response)
% geNumberOfTriggers - check whether all triggers have been recieved
%
% 2010/04 SOD: wrote it.

if ~exist('response','var')  || isempty(response)
    error('Need response variable');
end

if ~exist('params','var')  || isempty(params)
    error('Need params variable');
end

if size(response.keyCode,2)<2
    fprintf('[%s]:keyCodes are not stored, cannot proceed.',mfilename);
    return;
end

trig = response.keyCode(:,2)~=0;

ntriggers = sum(trig)+1; % +1 because we don't count the trigger trigger
trig_expected = (params.startScan+params.prescanDuration+params.period.*params.numCycles)/params.framePeriod;
fprintf(1,'[%s]:Got %d triggers (should be %d).\n',mfilename,ntriggers,trig_expected);
        
if ntriggers~=trig_expected
    fprintf('[%s]:WARNING:Missed triggers (%d)!\n',mfilename,trig_expected-ntriggers);
    trigtime = response.secs(trig);
    d_trigtime = diff(trigtime);
    d_trigtime_norm = round(d_trigtime ./ median(d_trigtime));
    missed_triggers = sum(d_trigtime_norm>1);
    if ntriggers+missed_triggers == trig_expected
        fprintf(1,'[%s]:But all missed triggers are in the middle of the scan.\n',mfilename);
        fprintf(1,'[%s]:So NO syncing issues expected.\n',mfilename,trig_expected-(ntriggers+missed_triggers));
    else
        fprintf(1,'[%s]:Number of missed triggers in the middle of the scan (%d).\n',mfilename,missed_triggers);
        fprintf(1,'[%s]:WARNING:Not all triggers are accounted for (%d)!\n',mfilename,trig_expected-(ntriggers+missed_triggers));
        fprintf(1,'[%s]:        --->SYNCING ISSUES EXPECTED!!!<---\n',mfilename);
    end
end

return

