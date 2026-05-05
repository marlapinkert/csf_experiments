function p = p_r1_cond(x,mu,sigma, lambda)
% Likelihood function (p(r1|params,x)): probability of getting the response
% r1 given the stimulus x, for each combination of parameters.
% This is also known as conditional probability.
% 
% Success = psychometric function, Failure = 1 - psychometric function
% The psychometric function involves a cumulative Gaussian function.
%
% Units: normalised between 0-1

% Cumulative distribution function (CDF) of the normal, or Gaussian,
% distribution with standard deviation sigma and mean mu
% https://www.mathworks.com/help/matlab/ref/erf.html#bup2mn8-5

% 1) (Matteo's example) Probability of choosing "+" for a cumulative 
% Gaussian with symmetric asymptote 
p = lambda + (1-2*lambda).*(1/2).*(1 + erf((x-mu)./(sqrt(2)*sigma)) );

% 2) Normal cumulative distribution function, with parameters: mu, sigma,
% lambda and gamma
% See Jones, 2018, Journal of Open Research Software for formula
% p = gamma + (1-lambda-gamma).*PsychFunc;