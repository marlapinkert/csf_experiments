function [chosenCols] = MichelsonContrast(MCcontrast, white, black, grey, nMC)

if nargin < 5
    nMC = [];
end

chosenCols=[];
MC = [];

% Define white, black, grey  values, and range of percentage of grey.
% The Michelson contrast will be defined relative to the percentage of grey
% added to the initial white and black values. 
% For percgrey = 0, the resulting MC will be 100% (Lmax = 255, Lmin = 0)
% For percgrey = 0.5, the resulting MC will be 50% (Lmax = 191.25, Lmin = 63.75)
% For percgrey = 1, the resulting MC will be 0% (Lmax = 127.5, Lmin = 127.5)
percgrey = 1-MCcontrast;

for perc = 1:length(percgrey)
    Lmax = white-grey*percgrey(perc);
    Lmin = black+grey*percgrey(perc);
    MC(perc,1) = (Lmax-Lmin)./(Lmax+Lmin);
    MC(perc,2) = Lmax;
    MC(perc,3) = Lmin;
end

if ~isempty(nMC)
    [IMC, idxMC] = intersect(round(MC(:,1),4),MCcontrast(nMC));
    chosenCols = [ones(1,3).*MC(idxMC,2);ones(1,3).*MC(idxMC,3)];
else
    chosenCols = [ones(1,3).*MC(2);ones(1,3).*MC(3)];
end
end