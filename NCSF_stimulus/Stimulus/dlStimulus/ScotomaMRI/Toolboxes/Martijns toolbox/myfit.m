function sse=myfit(params,Input,Actual_Output)

alpha=params(1);
beta=params(2);
gamma=params(3);
% delta=params(4);

% Logistic (sigmoid) curve
Fitted_Curve = sigmoid([alpha, beta, gamma],Input);

Error_Vector=Fitted_Curve - Actual_Output;
% When curvefitting, a typical quantity to
% minimize is the sum of squares error
sse=sum(Error_Vector.^2);
% You could also write sse as
% sse=Error_Vector(:)'*Error_Vector(:);

% % Using log-likelihood
% y = Fitted_Curve;
% y = y*.999+.0005;
% results.response = Actual_Output;
% 
% logLikelihood = sum(results.response.*log(y) + (1-results.response).*log(1-y));
% sse = -logLikelihood;

end