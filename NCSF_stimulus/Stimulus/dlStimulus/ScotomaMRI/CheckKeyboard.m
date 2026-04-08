function [kb,stop] = CheckKeyboard(kb)
% poll the keyboard for a response


%%% keys for velocity
% while getSecs < endT
%     [keyIsDown, secs, keyCode] = KbCheck;
%     if keyCode(params.towardsKey) % #1 key
%         resp = 1;
%     elseif keyCode(params.awayKey) % #2 key
%         resp = 0;
%     elseif keyCode(params.rivalryKey)
%         resp = NaN;
%     elseif keyCode(params.breakKey)
%         resp = -2;
%         stop = 1;
%     end
% 
% end

%%% keys for disparity
%kb.keyCode = -1; % Flush the keys
kb.keyIsDown = 0;
% if isfield(kb,'devInt')
%     %[kb.keyIsDown, kb.secs, kb.keyCode] = KbCheck(kb.devInt);
%     [kb.keyIsDown, kb.secs, kb.keyCode] = KbCheck(-1);
% end
% 
% if isfield(kb,'devExt') && ~kb.keyIsDown % Works?
%     %[kb.keyIsDown, kb.secs, kb.keyCode] = KbCheck(kb.devExt);
%     [kb.keyIsDown, kb.secs, kb.keyCode] = KbCheck(-1);
% end

[kb.keyIsDown, kb.secs, kb.keyCode] = KbCheck(kb.ID);

% % TODO: Response should now go from 1 to 5
% if kb.keyCode(kb.towardsKey) % #1 key
%     if (pa.phase1 > 0)
%         kb.resp = 1;
%     else
%         kb.resp = 0;
%     end
%     kb.rt = kb.secs-pa.fixT;
% elseif kb.keyCode(kb.awayKey) % #2 key
%     if (pa.phase1 > 0)
%         kb.resp = 0;
%     else
%         kb.resp = 1;
%     end
%     kb.rt = kb.secs-pa.fixT;
% elseif kb.keyCode(kb.rivalryKey)
%     kb.resp = NaN;
% end

stop = 0;

if kb.keyIsDown
    %kb.rt = kb.secs-fixT;
    % kb.rt = 0;
    
    if kb.keyCode(kb.movedLeft) || kb.keyCode(kb.downKey) % or towards / near
        kb.resp = 1;
    elseif kb.keyCode(kb.movedRight) || kb.keyCode(kb.upKey) % or away / far
        kb.resp = 2;    
    elseif kb.keyCode(kb.escKey) || kb.keyCode(kb.qKey) % esc/q key, quit
            stop =1;
    else
        kb.resp = NaN;
    end
    
end