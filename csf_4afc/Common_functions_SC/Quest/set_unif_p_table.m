function p_table = set_unif_p_table(R_mu, R_sigma, gridsize, lambdas)
% R_mu, R_sigma are both vector of length two
% defining the range
% 
% this function build a uniform prior over the parameter space
% for the 3-parameters psy function

% uniform prior
p = zeros(gridsize, gridsize, length(lambdas)) + 1/(length(lambdas)*gridsize^2);
p_table.p = p;

% specificy all the possible values of the parameters
p_table.mu_i = linspace(R_mu(1),R_mu(2),gridsize);
p_table.sigma_i = linspace(R_sigma(1),R_sigma(2),gridsize);
p_table.lambda_i = lambdas;
p_table.gridsize = gridsize;

% vectorizarion: this is necessary to have a much faster computation of the 
% expected entropy later
% vectors of parameters values, matched with reshape(p_table.p, numel(p_table.p),1)
p_table.mu_v = repmat(repmat(p_table.mu_i', length(p_table.sigma_i),1),length(p_table.lambda_i),1);
p_table.sigma_v = repmat(sort(repmat(p_table.sigma_i', length(p_table.mu_i),1)),length(p_table.lambda_i),1);
p_table.lambda_v = sort(repmat(p_table.lambda_i', length(p_table.mu_i)*length(p_table.sigma_i),1 ));