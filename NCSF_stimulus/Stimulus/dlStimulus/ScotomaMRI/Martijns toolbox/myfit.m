function sse=myfit(params,Input,Actual_Output)

alpha=params(1);
beta=params(2);
gamma=params(3);

% Logistic (sigmoid) curve
Fitted_Curve = sigmoid([alpha, beta, gamma],Input);

Error_Vector=Fitted_Curve - Actual_Output;
% When curvefitting, a typical quantity to
% minimize is the sum of squares error
sse=sum(Error_Vector.^2);
% You could also write sse as
% sse=Error_Vector(:)'*Error_Vector(:);

end