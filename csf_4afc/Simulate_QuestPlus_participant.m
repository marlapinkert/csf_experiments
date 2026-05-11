%% Simulate_QuestPlus_participant.m
%
% Simulates virtual observers with different contrast sensitivity profiles
% and tests how well the QuestPlus routine recovers their true thresholds.
%
% Each virtual participant has a true threshold (in dB) that QuestPlus tries
% to estimate. The psychometric function and QuestPlus settings match those
% used in CSF_4IFC_QuestPlus_20260506.m exactly.
%
% Outputs:
%   - Per-participant scatter plot: true vs estimated threshold
%   - Bias and RMSE across the simulated population
%   - Per-participant trial-by-trial threshold trace

%% Parameters
nParticipants   = 20;       % number of virtual observers to simulate
nTrialsPerRun   = 100;       % trials per location (match Gabor.nTrials in main script)

% True threshold range across simulated participants (dB, 20*log10(contrast))
% -60 = 0.0001 contrast (very sensitive), 0 = 1.0 contrast (very poor)
trueThresholdRange_dB = [-60, -5];  % covers most of the plausible human range

% Fixed psychometric function parameters — must match main script
gamma  = 0.25;   % guess rate (1/4 for 4AFC)
lambda = 0.05;   % lapse rate
beta   = 3.5;    % fixed slope
actual_lapse_rate = 0.075; % vary to make participants make more errors

% QuestPlus domains — must match main script
contrastDomainLog  = linspace(-60, 0, 5000);  % stimulus domain in dB
thresholdGridFull  = linspace(-60, 0, 200);   % parameter domain (threshold only)

% Default prior — must match main script (run 1 / no prior restriction)
thresholdPriorMu = 20*log10(0.5);  % ~ -6 dB
thresholdPriorSD = 20;             % dB

%% Pre-compute: Weibull probability for every (stimulus, threshold) pair
% p(correct | stim_dB, thresh_dB) = Weibull 4AFC psychometric function
% This mirrors qpPFWeibull used in the main script.
% p = lambda*gamma + (1-lambda)*(1 - (1-gamma)*exp(-10^(beta*(stim_dB - thresh_dB)/20)))
% (division by 20 because inputs are 20*log10(contrast))
stimGrid   = contrastDomainLog;                  % 1 x 5000
threshGrid = thresholdGridFull;                  % 1 x 200

pCorrect_lookup = zeros(length(stimGrid), length(threshGrid));
for iT = 1:length(threshGrid)
    x = beta .* (stimGrid - threshGrid(iT)) ./ 20;  % log contrast difference
    pCorrect_lookup(:, iT) = lambda*gamma + (1-lambda) .* (1 - (1-gamma)*exp(-10.^(x)));
end

%% Helper: simulate one virtual observer response
% Uses actual_lapse_rate (not lambda) so the true observer behaviour can
% differ from the lapse rate QuestPlus assumes when fitting.
% trueThresh_dB: true threshold in dB
% stimDb:        stimulus contrast in dB presented this trial
simulateResponse = @(trueThresh_dB, stimDb) ...
    (rand() < (actual_lapse_rate*gamma + (1-actual_lapse_rate)*(1-(1-gamma)*exp(-10^(beta*(stimDb - trueThresh_dB)/20)))));

%% Run simulation
rng(42);  % reproducibility

trueThresholds_dB = linspace(trueThresholdRange_dB(1), trueThresholdRange_dB(2), nParticipants);
estimatedThresholds_dB = zeros(1, nParticipants);
thresholdTraces        = zeros(nParticipants, nTrialsPerRun);  % MAP after each trial

fprintf('Simulating %d participants, %d trials each...\n', nParticipants, nTrialsPerRun);

for iPart = 1:nParticipants
    trueThresh_dB = trueThresholds_dB(iPart);

    %% Initialise QuestPlus (mirrors main script, run 1 path)
    q = qpInitialize( ...
        'stimParamsDomainList', {contrastDomainLog}, ...
        'psiParamsDomainList',  {thresholdGridFull, beta, gamma, lambda}, ...
        'qpPF',      @qpPFWeibull, ...
        'nOutcomes', 2);

    % Replace uniform posterior with Gaussian prior over threshold
    nPsi      = q.nPsiParamsDomain;
    gaussPrior = zeros(nPsi, 1);
    for iPsi = 1:nPsi
        tDb = q.psiParamsDomain(iPsi, 1);
        gaussPrior(iPsi) = normpdf(tDb, thresholdPriorMu, thresholdPriorSD);
    end
    
    q.posterior = qpUnitizeArray(gaussPrior);
    q.expectedNextEntropiesByStim = qpUpdateExpectedNextEntropiesByStim(q);

    fprintf('Prior MAP: %.1f dB\n', q.psiParamsDomain(qpListMaxArg(q.posterior), 1));

    %% Trial loop
    trialLog = zeros(nTrialsPerRun, 2);  % col 1: stimulus (dB), col 2: correct (0/1)

    for iTrial = 1:nTrialsPerRun
        % Quest+ selects best stimulus
        stim       = qpQuery(q);
        stimDb     = stim(1);

        % Virtual observer responds
        isCorrect  = simulateResponse(trueThresh_dB, stimDb);
        outcome    = isCorrect + 1;  % 1 = wrong, 2 = correct (matches main script)

        % Update posterior
        q = qpUpdate(q, stimDb, outcome);

        % Record current MAP estimate
        psiIdx = qpListMaxArg(q.posterior);
        thresholdTraces(iPart, iTrial) = q.psiParamsDomain(psiIdx, 1);

        trialLog(iTrial, :) = [stimDb, isCorrect];
    end

    % Save per-participant CSV
    csvData = array2table(trialLog, 'VariableNames', {'stimulus_dB', 'correct'});
    writetable(csvData, sprintf('sim_data/participant_%02d_trials.csv', iPart));

    % Final MAP threshold estimate
    psiParamsIdx = qpListMaxArg(q.posterior);
    estimatedThresholds_dB(iPart) = q.psiParamsDomain(psiParamsIdx, 1);

    fprintf('  P%02d: true = %5.1f dB, estimated = %5.1f dB, error = %+.1f dB\n', ...
        iPart, trueThresh_dB, estimatedThresholds_dB(iPart), ...
        estimatedThresholds_dB(iPart) - trueThresh_dB);
end

%% Summary statistics
errors   = estimatedThresholds_dB - trueThresholds_dB;
bias     = mean(errors);
rmse     = sqrt(mean(errors.^2));
fprintf('\nBias: %.2f dB,  RMSE: %.2f dB\n', bias, rmse);

%% Figure 1: True vs Estimated threshold
figure('Color','white','Position',[100 100 500 500]);
hold on;

scatter(trueThresholds_dB, estimatedThresholds_dB, 60, 'filled', ...
    'MarkerFaceColor', [0.2 0.5 0.8], 'MarkerEdgeColor','none');

refLim = [trueThresholdRange_dB(1)-5, trueThresholdRange_dB(2)+5];
plot(refLim, refLim, 'k--', 'LineWidth', 1.2);

xlabel('True threshold (dB)', 'FontSize', 13);
ylabel('Estimated threshold (dB)', 'FontSize', 13);
title(sprintf('QuestPlus recovery — %d trials per participant\nBias = %.2f dB, RMSE = %.2f dB', ...
    nTrialsPerRun, bias, rmse), 'FontSize', 12);
axis square;
xlim(refLim); ylim(refLim);
box on; grid on;

%% Figure 2: Estimation error vs true threshold
figure('Color','white','Position',[620 100 500 400]);
hold on;
plot(refLim, [0 0], 'k--', 'LineWidth', 1);
scatter(trueThresholds_dB, errors, 60, 'filled', ...
    'MarkerFaceColor', [0.8 0.3 0.2], 'MarkerEdgeColor','none');

xlabel('True threshold (dB)', 'FontSize', 13);
ylabel('Error: estimated − true (dB)', 'FontSize', 13);
title('Estimation error vs true threshold', 'FontSize', 12);
ylim([-20 20]);
box on; grid on;

%% Figure 3: Trial-by-trial threshold traces for all participants
figure('Color','white','Position',[100 620 900 400]);
hold on;

cmap = parula(nParticipants);
for iPart = 1:nParticipants
    plot(1:nTrialsPerRun, thresholdTraces(iPart,:), 'Color', cmap(iPart,:), 'LineWidth', 1.2);
end
yline([trueThresholds_dB(1), trueThresholds_dB(end)], '--k', 'LineWidth', 0.8);

colormap(parula);
cb = colorbar; cb.Label.String = 'True threshold (dB)';
clim([trueThresholdRange_dB(1), trueThresholdRange_dB(2)]);

xlabel('Trial number', 'FontSize', 13);
ylabel('MAP threshold estimate (dB)', 'FontSize', 13);
title('Quest+ threshold convergence across participants', 'FontSize', 12);
xlim([1 nTrialsPerRun]);
box on; grid on;
