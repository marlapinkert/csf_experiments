function [x,y,t] = CheckEyePos(w,elparam)
%%CheckEyePos
% Input(s) :
% w = window pointer
% const = struct containing  const.TEST and const.DOMEYE;
% ----------------------------------------------------------------------
% Output(s):
% x : X eye/mouse coordinate (horizontal)
% y : Y eye/mouse coordinate (vertical)
% t : machine time
% ----------------------------------------------------------------------
% Function created by Martin SZINTE (martin.szinte@gmail.com)
% Last update : 30 / 10 / 2010
% Project : CrowdedSac
% Version : 1.0
% ----------------------------------------------------------------------

if elparam.TEST
    [x,y]=GetMouse(w); % gaze position simulate by mouse position
    t = GetSecs;
else
    evt = Eyelink('newestfloatsample'); %pulls current EyeLink estimate
    x = evt.gx(elparam.EyeTest);
    y = evt.gy(elparam.EyeTest);
    t = evt.time;
    if evt.gx(elparam.EyeTest) == -32768 || evt.gy(elparam.EyeTest) == -32768
        x = 0;
        y = 0;
    end
end

end
