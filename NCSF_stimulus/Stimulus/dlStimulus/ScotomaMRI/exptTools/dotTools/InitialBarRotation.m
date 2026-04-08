function pa = InitialBarRotation(pa,step,idot)

if ~exist('idot','var') || isempty(idot)
    idot = 1:pa.numberofdots;
end

for d=1:length(idot)
    pa.dots(idot(d),1) = (pa.dots(idot(d),1)) .* cos(pa.orientation) - (pa.dots(idot(d),2)) .* sin(pa.orientation);
    pa.dots(idot(d),2) = (pa.dots(idot(d),1)) .* sin(pa.orientation) + (pa.dots(idot(d),2)) .* cos(pa.orientation);
end

end