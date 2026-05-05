function [inside ] = CheckFixRad(x, y, fixXY, fixRad)
%CheckFixRad
%function to check fication is within pre-specified boundary
if sqrt((x-fixXY(1,1))^2+(y-fixXY(1,2))^2) < fixRad
    inside = 1;

else
    inside = 0;
end

end

