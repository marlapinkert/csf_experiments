function [pa] = UpdateDotPositions(pa,ds)

for ii = 1:pa.numberOfDots
    
    % Check whether the dot has reached its 'kill time' based on screen flips
    if pa.dotKillTime(ii) < ds.vbl
        pa = NewDots(ds,pa,ii); % reset the dot with a new kill time and a new random x and y, but wrap in z
    end
    

        if pa.dots(ii,4)==-1 % if moving towards
            pa.dots(ii,3) = pa.dots(ii,3) - pa.xoffset;
        else % if moving away
            pa.dots(ii,3) = pa.dots(ii,3) + pa.xoffset;
        end    
    
end

end






