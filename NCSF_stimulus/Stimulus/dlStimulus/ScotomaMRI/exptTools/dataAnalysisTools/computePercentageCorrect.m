% Compute detection rate and discrimination (percent correct) for scanning sessions
function [pCorrect, pHit, pMiss] = computePercentageCorrect(stimulus,response)

subject_resp = [65 68];

responseT = [0.01 1];

resp = unique(response.keyCode);% responses

pCorrect = NaN; pHit = NaN; pMiss = NaN;

if numel(resp)>2
    % From mrStim code
    stim     = diff(stimulus.fixSeq);
    target   = find(stim>0);                       % change in stimulus
    resps    = diff(response.keyCode);
    resp     = find(resps>0);     % any response?
    resptime = response.secs(resp+1);   % + 1 to correct for diff operation
    
    count = 0; rnd_count = 0;
    correct_resps = [];
    % loop over stimulus changes
    for n=1:numel(target),
        tmp=find(resptime >= stimulus.seqtiming(target(n)) + responseT(1) & ... %file.params.fix.responseTime(1) & ...
            resptime <= stimulus.seqtiming(target(n)) + responseT(2)); %file.params.fix.responseTime(2));
        if ~isempty(tmp),
            count = count+1;
            
            %tmp = tmp+1;
            
            if numel(tmp)>1
                %extra_resps = [extra_resps resp(tmp(1:end-1))'];
                tmp = tmp(end); % just keep last one
            end
            
            if (stimulus.fixSeq(target(n))==1 && resps(resp(tmp))==subject_resp(1)) || ...
                    (stimulus.fixSeq(target(n))==2 && resps(resp(tmp))==subject_resp(2))
                correct_resps = [correct_resps resp(tmp)];
            end
        else
            rnd_count = rnd_count + 1;
            
            
        end
    end
    
    
    % calculate percent correct
    pMiss = rnd_count/length(target);
    pHit = count/length(target);
    
    pCorrect = length(correct_resps)/count;    
    
    
end
