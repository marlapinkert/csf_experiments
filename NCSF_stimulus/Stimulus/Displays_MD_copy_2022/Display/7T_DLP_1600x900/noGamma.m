gamma = repmat([0:1:255],3,1)'./255;
gammaTable = repmat([0:255],3,1)';
save('gamma.mat','gamma','gammaTable');
