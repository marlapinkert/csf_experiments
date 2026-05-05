% this show how to use Quest+ for a 3 parameters psy functions

clear all; 
close all;
clc;
% settings
n_trial = 200; % number of trials
use_sweet = 1; % whether you want to present stimuli at sweetpoints instead of boundaries

%% true parameters
mu = 0; 
sigma = 4/100;
lambda = 0.01;

%% initialize quest
range_mu = [-5, 5]/100;
range_sigma = [4 10]/100;
gridsize = 30;
lambdas_ = linspace(0.01,0.1,10);
qp = set_unif_p_table(range_mu, range_sigma, gridsize,lambdas_); % this set the uniform prior

%% define stimuli range
stim_range = [-100, 100]/100;
stim_n = 300;
limitnear0 = 0.1/100;
stim_x = logspace(log10(limitnear0),log10(stim_range(2)),stim_n/2);
stim_x = [-flip(stim_x), stim_x];

% CatchTrials
CatchTrials = randi([50,100],1,n_trial/10)/100;
CatchTrials = Shuffle([-flip(CatchTrials),CatchTrials]);
TrialToCatch = sort(randperm(n_trial,length(CatchTrials)));
CatchIdx = NaN(n_trial,1);

%% initialize remaining parts of quest+ structure
qp.x_values = stim_x; % stimuli needs to be also in the quest+ structure
qp.x_n = stim_n;
qp.x_range = stim_range;
qp.EH_x = NaN(stim_n,1); % initialize vector of expected entropies

% preallocate
x = NaN(n_trial,1);
r = NaN(n_trial,1);
nCash = 0;

x(1) = mean(range_mu)+rand*stim_range(2) - stim_range(2)/2; % random intensity for the first trial

%% run
for t = 1:n_trial
    
    if ismember(t,TrialToCatch)
        nCash = nCash+1;
        x(t) = CatchTrials(nCash);
        CatchIdx(t) = 1;
    else
        CatchIdx(t) = 0;
    end
    % generate response
    Pr_x(t) = p_r1_cond(x(t),mu,sigma, lambda); % p(r|params,x)
    r(t) = binornd(1, Pr_x(t));
    
    % update posterior probability over parameters
    qp.p = p_m_uncond(x(t), qp, r(t));
    
    % this is needed only if you want to compute the sweetpoints
    if use_sweet
        qp.x = x(1:t); qp.rr = r(1:t);
    end
        
    % find the stimulus associated with the smallest expected entropy
    if t<n_trial
        x(t+1) = QuestNext(qp, use_sweet);
    end
    
end

%% use MLE to obtain final estimates
[mu_hat, sigma_hat, lambda_hat, L] = fit_p_r(x, r);

fprintf('\n\nEstimates: mu=%.2f%%  sigma=%.2f%% lambda=%.2f \n',[mu_hat*100, sigma_hat*100, lambda_hat]);
fprintf('\nThe true values were: mu=%.2f%%  sigma=%.2f%% lambda=%.2f.\n',[mu*100, sigma*100, lambda]);

% Determine contrast threshold based on performance threshold
PerfThre = 0.8; % (1/2)^(1/2); %70.71%
Thre = sqrt(2)*sigma_hat*erfinv(2*PerfThre-1)*100; % in log10(%)
fprintf('\nEstimated contrast to achieve %.2f%% performance = %.2f%% \n',[PerfThre*100,Thre]);

%% plot stimuli placements
figure('Color','w', 'Position',[0 50 500 220]); 
subplot(1,2,1)
plot(x,'o','Color','k'); hold on
t_i = 1:t;
plot(t_i(r(1:t)==1), x(r(1:t)==1),'o','Color','k', 'MarkerFaceColor', 'k'); hold off
ylim(stim_range)
xlim([-2 n_trial+3])
xlabel('Trial')
ylabel('Signed Contrast (normalised unit)')
title('Stimuli placements & responses')
drawnow

%% Plot function with maximum likelihood fit - Watson style
subplot(1,2,2)
hold on
stim = unique(x);
nTrials = NaN(size(stim));
pCorrect = NaN(size(stim));
for cc = 1:length(stim)
    nTrials(cc) = sum(x==stim(cc));
    pCorrect(cc) = mean(r(x==stim(cc)));
end
stimFine = linspace(stim_range(1),stim_range(2),100)';
plotProportionsFit = p_r1_cond(stimFine,mu_hat, sigma_hat, lambda_hat);

for cc = 1:length(stim)
    h = scatter(stim(cc),pCorrect(cc),100,'o','MarkerEdgeColor',[0 0 1],'MarkerFaceColor',[0 0 1],...
        'MarkerFaceAlpha',nTrials(cc)/max(nTrials),'MarkerEdgeAlpha',nTrials(cc)/max(nTrials));
end
plot(stimFine,plotProportionsFit,'-','Color',[1 0.2 0.0],'LineWidth',3);
plot(stimFine,ones(1,length(stimFine))*0.5,'k--','LineWidth',1);
plot(zeros(1,length([0:0.1:1])),[0:0.1:1],'k--','LineWidth',1);

xlabel('Signed Contrast (normalised unit)');
ylabel('Proportion of choosing 2nd interval');
xlim(stim_range); ylim([0 1]);
title({sprintf('mu=%.2f  sigma=%.2f lambda=%.2f',[mu_hat, sigma_hat, lambda_hat]), ''});
hold off
