% do nothing until the spacebar is pressed
function [] = waituntillspacepress
while 1
    [keyIsDown,secs,keyCode] = KbCheck;
    if keyIsDown
        responsekey = find(keyCode);
        if ~isempty(responsekey)
            if responsekey== KbName('space')
                break; 
            end
        end 
    end
end

