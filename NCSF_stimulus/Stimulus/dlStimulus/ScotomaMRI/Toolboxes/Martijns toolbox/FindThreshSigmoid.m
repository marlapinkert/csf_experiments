function x = FindThreshSigmoid(p,y)
% Return inverted sigmoid value for y

% Sometimes the function does not reach treshold (y)
if p(3) < y
    x = NaN;
else
    x = p(1) .* ( -1.0*log(2.0 .* (p(3)-y))) .^(1.0./p(2));
end

end