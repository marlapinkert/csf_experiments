function [pa] = UpdateDotPositions(pa,vbl)

for ii = 1:pa.numberofdots
    
    % Check whether the dot has reached its 'kill time' based on screen flips
    %if pa.dotKillTime(ii) < vbl
    %    pa = NewDotBarUpdated(pa,vbl,ii); % reset the dot with a new kill time and a new random x and y, but wrap in z
    %    %pa = InitialBarRotation(pa,step,ii);
    %end
    

        if pa.dots(ii,4)==-1 % if moving towards
            pa.dots(ii,3) = pa.dots(ii,3) - pa.xoffset(ii);
        else % if moving away
            pa.dots(ii,3) = pa.dots(ii,3) + pa.xoffset(ii);
        end    
    
end

end