    function y = sigmoid(p,x)
        %y = 1 ./ (1 + exp(-p(2).*(x-p(1))));

%         z = (x./p(1)).^p(2);
%         y = ( 1.0 - 0.5*exp( - z ) );
        
        %z = -( p(1).*x + p(2) );
        %y = 1./(1 + 10.^z);
        
        %y = 1 - (0.5 * exp(-(x ./ p(1)) .^p(2)));
        %y = 1 - exp(-(x ./ p(1)).^p(2));
        %y = 1 ./ (1 + exp(-(x ./ alpha).^beta));
        
        % Two parameter weibull
%         if x < 0
%             y = 0;
%         else
%             z = (x./p(1)).^p(2);
%             y = 1.0 - 0.5 * exp(-z) ;
%         end
        
        
        % As defined in:
        % Psychtoolbox' help ComputeWeibTAFC
        % pCorrect = ( 1.0 - 0.5*exp( - (x./alpha).^beta ) )
        % and
        % http://en.wikipedia.org/wiki/Weibull_distribution
        % Three parameter Weibull
        
        % p(3) is ceiling [.5:1]
        % p(4) is chance level
        
        if x < 0
            y = 0; %realmax; %0;
        elseif p(1) < 0
             y = 0;
        elseif p(3) > 1
            y = 0;
        elseif p(3) < .5
            y = 0;
%         elseif p(3) < .5
%              y = 0; %realmax; %0;
        else
            z = (x./p(1)).^p(2);
            % y = p(3) - ((p(3)-0.5) * exp(-z));
            y = 1 - ((1-0.5) * exp(-z));
        end