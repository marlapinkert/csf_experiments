% Correct versus Wrong response
% Plot figures, define contrast for next trial, and determine
% whether reversal or not
tmpData(TrialCounter,3) = 0;

subplot(1,2,1)
hold on
plot(tmpData(:,1)*100,'k','LineWidth',2)
xlabel('Trial Number'); ylabel('Contrast %')

if strcmp(reply,AllowedKey{Expect_Resp(TrialCounter)})
    % Play sound for correct answer
    [yCorr,FsCorr] = audioread('CorrectAnswer.wav');
    sound(yCorr,FsCorr);
    
    % Scatter plot
    scatter(TrialCounter,tmpData(TrialCounter,1)*100,50,'go','filled','MarkerEdgeColor','k','Linewidth',1)
    
    % Add to counter
    correctInRow = correctInRow+1;
    wrongInRow = 0; % Reset as it is the first correct in row after a series of wrong
    
    if correctInRow == 2 && reversalCount ~= 0
        if tmpData(TrialCounter-2,2) ~= Expect_Resp(TrialCounter-2) % The n-2 trial was an uncorrect trial - This is a new reversal
            reversalCount = reversalCount+1;
            scatter(TrialCounter,tmpData(TrialCounter,1)*100,75,'go','filled','MarkerEdgeColor','b','Linewidth',1)
            tmpData(TrialCounter,3) = 1;
        end
    end
            
else
    % Play sound for wrong answer
    [yWrong,FsWrong] = audioread('WrongAnswer.wav');
    sound(yWrong,FsWrong);
    
    % Scatter plot
    scatter(TrialCounter,tmpData(TrialCounter,1)*100,50,'ro','filled','MarkerEdgeColor','k','Linewidth',1)
    
    % Add to counter
    wrongInRow = wrongInRow+1;
    correctInRow = 0; % Reset because we are incorrect
    
    if wrongInRow == 1 && TrialCounter > 1 % If not the first trial and wrong response
        % This is a reversal (1st incorrect after a correct response
        scatter(TrialCounter,tmpData(TrialCounter,1)*100,75,'ro','filled','MarkerEdgeColor','b','Linewidth',1)
        reversalCount = reversalCount+1;
        tmpData(TrialCounter,3) = 1;
    end
end

% Plot Reversals
subplot(1,2,2)
if sum(tmpData(:,3)) >= 1
    hold on
    idxRevs = find(tmpData(:,3) == 1);
    plot(tmpData(idxRevs,1)*100,'k','LineWidth',2)
    scatter(1:length(idxRevs),tmpData(idxRevs,1)*100,50,'k','filled','LineWidth',1)
    xlabel('Reversal number'); ylabel('Contrast %')
end
drawnow;
figure(idxfig);

%% Staircase
% Reversals:
% - if 2 correct responses after 1 or a series of uncorrect
% responses
% - if 1 wrong response after a correct response

if Parameters.PsychMethod == 1
    if strcmp(reply,AllowedKey{Expect_Resp(TrialCounter)}) % correct trial (go down)
        if correctInRow == 2 && reversalCount ~= 0
            % If 2 correct responses in a row, contrast will go down
            NewContrast = targContrast*(1-stepSize(1)); % Step Size is relative to the targContrast level
            correctInRow = 0; % Reset variable after 2 following correct responses
        elseif reversalCount == 0 % i.e., at the beginning
            NewContrast = targContrast*(1-stepSize(1)); % Step Size is relative to the targContrast level
        end
        
    else % Wrong trials
        % Contrast will go up
        NewContrast = targContrast*(1+stepSize(2));
    end
    if NewContrast <= 0
        NewContrast = 0;
    end
    if NewContrast > 1
        NewContrast = 1;
    end
end

%% Quest+
if Parameters.PsychMethod == 2
    % Translate participant's response from 1-or-2 scale to a 0-or-1 scale
    resp(TrialCounter) = tmpData(TrialCounter,2)-1;
    
    % Update posterior probability over parameters: p(params)
    qp.p = p_m_uncond(logContrast(TrialCounter), qp, resp(TrialCounter));
    
    % This is needed only if you want to compute the sweetpoints
    if use_sweet
        qp.x = logContrast(1:TrialCounter); qp.rr = resp(1:TrialCounter);
    end
    
    % Find the stimulus associated with the smallest expected entropy (E[H(x)])
    if TrialCounter ~= n_trial && nansum(tmpData(:,3)) < StopRunRevs
        logContrast(TrialCounter+1) = QuestNext(qp, use_sweet);
        NewContrast = 10^(abs(logContrast(TrialCounter+1)))/100;
    end
end