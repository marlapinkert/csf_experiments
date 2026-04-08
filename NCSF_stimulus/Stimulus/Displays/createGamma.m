% Create 10 bit gamma table
g = 0:(1/1023):1;
gamma = [g' g' g'];

t = 0:1:1023;
gammaTable = [t' t' t'];

save('gamma_10bit.mat', 'gamma', 'gammaTable')