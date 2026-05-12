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
nParticipants   = 20;        % number of virtual observers to simulate
nTrialsPerRun   = 150;       % trials per location (match Gabor.nTrials in main script)
nRuns           = 1;         % 1 = single run, 2 = two runs with prior restriction on run 2
restrictedPriorSD = 10;      % dB SD for run 2 prior (matches main script)

% True threshold range across simulated participants (dB, 20*log10(contrast))
% -60 = 0.001 contrast (very sensitive), -10 = 0.3162 contrast (poor)
trueThresholdRange_dB = [-60, -10];  % i think this covers most of the plausible human range? I can get around -50, 

% Fixed psychometric function parameters - must match main script
gamma  = 0.25;   % guess rate (1/4 for 4AFC)
lambda = 0.01;   % lapse rate
beta   = 3.5;    % fixed slope
actual_lapse_rate = 0.01; % vary to make participants make more errors

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

pThreshold = gamma^gamma;  % ~70.7% correct — same criterion as main script

trueThresholds_dB      = linspace(trueThresholdRange_dB(1), trueThresholdRange_dB(2), nParticipants);
estimatedThresholds_dB = zeros(nRuns, nParticipants);   % final MAP per run
thresholdTraces        = zeros(nRuns, nParticipants, nTrialsPerRun);

fprintf('Simulating %d participants, %d runs, %d trials each...\n', nParticipants, nRuns, nTrialsPerRun);

for iPart = 1:nParticipants
    trueThresh_dB = trueThresholds_dB(iPart);
    run1ThreshDb  = [];   % filled after run 1, used to set run 2 prior
    run1PropCorr  = [];

    for iRun = 1:nRuns

        %% Set prior for this run
        if iRun == 1
            % Run 1: broad Gaussian prior (matches main script run 1 path)
            priorMu = thresholdPriorMu;
            priorSD = thresholdPriorSD;
        else
            % Run 2: narrow prior centred on run 1 MAP if run 1 was above chance,
            % otherwise fall back to conservative default — mirrors main script
            if run1PropCorr >= pThreshold
                priorMu = run1ThreshDb;
            else
                priorMu = 20*log10(0.5);  % conservative fallback
            end
            priorSD = restrictedPriorSD;
        end

        %% Initialise QuestPlus
        q = qpInitialize( ...
            'stimParamsDomainList', {contrastDomainLog}, ...
            'psiParamsDomainList',  {thresholdGridFull, beta, gamma, lambda}, ...
            'qpPF',      @qpPFWeibull, ...
            'nOutcomes', 2);

        nPsi       = q.nPsiParamsDomain;
        gaussPrior = zeros(nPsi, 1);
        for iPsi = 1:nPsi
            tDb = q.psiParamsDomain(iPsi, 1);
            gaussPrior(iPsi) = normpdf(tDb, priorMu, priorSD);
        end
        q.posterior = qpUnitizeArray(gaussPrior);
        q.expectedNextEntropiesByStim = qpUpdateExpectedNextEntropiesByStim(q);

        fprintf('  P%02d Run%d: prior centred at %.1f dB (SD=%.0f dB)\n', ...
            iPart, iRun, priorMu, priorSD);

        %% Trial loop
        trialLog  = zeros(nTrialsPerRun, 2);
        nCorrect  = 0;

        for iTrial = 1:nTrialsPerRun
            stim      = qpQuery(q);
            stimDb    = stim(1);

            isCorrect = simulateResponse(trueThresh_dB, stimDb);
            outcome   = isCorrect + 1;

            q = qpUpdate(q, stimDb, outcome);

            psiIdx = qpListMaxArg(q.posterior);
            thresholdTraces(iRun, iPart, iTrial) = q.psiParamsDomain(psiIdx, 1);

            trialLog(iTrial, :) = [stimDb, isCorrect];
            nCorrect = nCorrect + isCorrect;
        end

        %% Final MAP estimate for this run
        psiParamsIdx = qpListMaxArg(q.posterior);
        estimatedThresholds_dB(iRun, iPart) = q.psiParamsDomain(psiParamsIdx, 1);

        propCorr = nCorrect / nTrialsPerRun;

        fprintf('    -> estimated = %5.1f dB (true = %5.1f dB, error = %+.1f dB, %.0f%% correct)\n', ...
            estimatedThresholds_dB(iRun, iPart), trueThresh_dB, ...
            estimatedThresholds_dB(iRun, iPart) - trueThresh_dB, propCorr*100);

        % Save CSV
        runCol             = repmat(iRun, nTrialsPerRun, 1);
        stimContrastCol    = 10.^(trialLog(:,1) ./ 20);
        trueThreshDbCol    = repmat(trueThresh_dB, nTrialsPerRun, 1);
        trueThreshContrastCol = repmat(10^(trueThresh_dB/20), nTrialsPerRun, 1);
        csvData = array2table([runCol, trialLog(:,1), stimContrastCol, trialLog(:,2), trueThreshDbCol, trueThreshContrastCol], ...
            'VariableNames', {'run', 'stimulus_dB', 'stimulus_contrast', 'correct', 'true_threshold_dB', 'true_threshold_contrast'});
        writetable(csvData, sprintf('sim_data/participant_%02d_run%d_trials.csv', iPart, iRun));

        % Store for run 2 prior
        run1ThreshDb = estimatedThresholds_dB(iRun, iPart);
        run1PropCorr = propCorr;
    end
end

%% Convert dB to linear contrast
db2contrast = @(x) 10.^(x ./ 20);

trueThresholds_contrast      = db2contrast(trueThresholds_dB);
estimatedThresholds_contrast = db2contrast(estimatedThresholds_dB);
thresholdTraces_contrast     = db2contrast(thresholdTraces);

%% Summary statistics (in dB, since error is additive there)
refLim_dB       = [trueThresholdRange_dB(1)-5, trueThresholdRange_dB(2)+5];
refLim_contrast = db2contrast(refLim_dB);
runColors       = [0.2 0.5 0.8; 0.8 0.3 0.2];  % blue = run 1, red = run 2

fprintf('\n');
for iRun = 1:nRuns
    errors = estimatedThresholds_dB(iRun,:) - trueThresholds_dB;
    bias   = mean(errors);
    rmse   = sqrt(mean(errors.^2));
    fprintf('Run %d — Bias: %.2f dB,  RMSE: %.2f dB\n', iRun, bias, rmse);
end

%% Figure 1: True vs Estimated threshold (linear contrast)
figure('Color','white','Position',[100 100 500*nRuns 500]);
for iRun = 1:nRuns
    errors = estimatedThresholds_dB(iRun,:) - trueThresholds_dB;
    bias   = mean(errors);
    rmse   = sqrt(mean(errors.^2));

    subplot(1, nRuns, iRun); hold on;
    scatter(trueThresholds_contrast, estimatedThresholds_contrast(iRun,:), 60, 'filled', ...
        'MarkerFaceColor', runColors(iRun,:), 'MarkerEdgeColor', 'none');
    plot(refLim_contrast, refLim_contrast, 'k--', 'LineWidth', 1.2);
    xlabel('True threshold (contrast)', 'FontSize', 13);
    ylabel('Estimated threshold (contrast)', 'FontSize', 13);
    title(sprintf('Run %d — %d trials\nBias = %.2f dB, RMSE = %.2f dB', ...
        iRun, nTrialsPerRun, bias, rmse), 'FontSize', 12);
    set(gca, 'XScale', 'log', 'YScale', 'log');
    axis square; xlim(refLim_contrast); ylim(refLim_contrast);
    box on; grid on;
end

%% Figure 2: Estimation error vs true threshold (dB error, contrast x-axis)
figure('Color','white','Position',[100 620 500*nRuns 400]);
for iRun = 1:nRuns
    errors = estimatedThresholds_dB(iRun,:) - trueThresholds_dB;

    subplot(1, nRuns, iRun); hold on;
    plot(refLim_contrast, [0 0], 'k--', 'LineWidth', 1);
    scatter(trueThresholds_contrast, errors, 60, 'filled', ...
        'MarkerFaceColor', runColors(iRun,:), 'MarkerEdgeColor', 'none');
    set(gca, 'XScale', 'log');
    xlabel('True threshold (contrast)', 'FontSize', 13);
    ylabel('Error: estimated − true (dB)', 'FontSize', 13);
    title(sprintf('Run %d — estimation error', iRun), 'FontSize', 12);
    ylim([-20 20]); xlim(refLim_contrast);
    box on; grid on;
end

%% Figure 3: Trial-by-trial threshold traces (linear contrast)
cmap = parula(nParticipants);
figure('Color','white','Position',[100 100 900*nRuns 400]);
for iRun = 1:nRuns
    subplot(1, nRuns, iRun); hold on;
    for iPart = 1:nParticipants
        plot(1:nTrialsPerRun, squeeze(thresholdTraces_contrast(iRun, iPart, :)), ...
            'Color', cmap(iPart,:), 'LineWidth', 1.2);
    end
    yline(trueThresholds_contrast(1),   '--k', 'LineWidth', 0.8);
    yline(trueThresholds_contrast(end), '--k', 'LineWidth', 0.8);
    set(gca, 'YScale', 'log');
    colormap(parula);
    cb = colorbar; cb.Label.String = 'True threshold (contrast)';
    clim([trueThresholdRange_dB(1), trueThresholdRange_dB(2)]);
    xlabel('Trial number', 'FontSize', 13);
    ylabel('MAP threshold estimate (contrast)', 'FontSize', 13);
    title(sprintf('Run %d — convergence', iRun), 'FontSize', 12);
    xlim([1 nTrialsPerRun]);
    box on; grid on;
end
