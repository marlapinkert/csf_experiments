function [mu, sigma, lambda, L] = fit_p_r(x,r, mu0, sigma0, lambda0)
%
% fit cumulative Gaussian with symmetric asymptotes (lambda and 1-lambda)
%

% initial parameters
if nargin < 5; lambda0 = 0; end
if nargin < 4; sigma0 = mean(abs(x)); end
if nargin < 3; mu0 = 0; end
par0 = [mu0, sigma0, lambda0];

% options
options = optimset('Display', 'off') ;

% Set boundaries
lb = [-1, 0, 0]; % mu, sigma, lambda (-3*sigma0,sigma0/4,0])
ub = [1, 1, 1]; % mu, sigma, lambda ([3*sigma0,4*sigma0,0.2])
% mu is the bias, and takes values between -1 and 1 (i.e., -100% and 100%)
% sigma is the slope, and takes values between 0 and 1 (i.e., 0% and 100%)
% lambda is the lapse-rate, and takes values between 0 and 1 (i.e., 0% and 100%)
% This can make or brake everything!! Depending on the boundaries that we
% set up, it can create huge variations in the results

% do optimization
fun = @(par) -L_r(x, r, par(1), par(2), par(3));
[par, L] = fmincon(fun, par0, [],[],[],[], lb, ub,[],options);

% output parameters & loglikelihood
mu = par(1); 
sigma = par(2);
lambda = par(3);
L = -L;
