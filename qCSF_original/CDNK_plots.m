%% Plot test
figure(1)

% Left 
load('H:\DumoulinLab\Marco\qCSF_Spinoza\Data\MZ\MZ_L_qCSF_2023_1_26_9_11.mat')
L_mean = mean(qcsf.data.estSensitivity);
plot(L_mean)


%%
figure(2)

% Left 
load('H:\DumoulinLab\Carlien\qCSF_Spinoza\Data\MZ\MZ_L_qCSF_2023_1_26_9_11.mat')

plot(log10(qcsf.stimuli.frequency),qcsf.data.estSensitivity(qcsf.data.trial,:))
axis([log10(qcsf.stimuli.frequency([1 end]))' -log10(qcsf.stimuli.contrast([end 1]))'])
set(gca,'Yaxislocation','left','Xtick',log10([.5 1 2 5 10 20]),'XtickLabel',([.5 1 2 5 10 20]),'Ytick',log10([2 10 50 200 500 1000]),'Yticklabel',([2 10 50 200 500 1000]))
xlabel('spatial frequency')
ylabel('sensitivity')

grid on

%%
figure(3)

% Left 
load('H:\DumoulinLab\Carlien\qCSF_Spinoza\Data\MZ\MZ_L_qCSF_2023_1_26_9_11.mat')
L_mean = mean(qcsf.data.estSensitivity);
plot(log10(L_mean))

%% Analysis
load('H:\DumoulinLab\Carlien\qCSF_Spinoza\Data\NK\NK_L_08_qCSF_2020_11_2_17_57.mat')
plot(log10(qcsf.stimuli.frequency),qcsf.data.estSensitivity(qcsf.data.trial,:))
axis([log10(qcsf.stimuli.frequency([1 end]))' -log10(qcsf.stimuli.contrast([end 1]))'])
set(gca,'Yaxislocation','left','Xtick',log10([.5 1 2 5 10 20]),'XtickLabel',([.5 1 2 5 10 20]),'Ytick',log10([2 10 50 200 500 1000]),'Yticklabel',([2 10 50 200 500 1000]))
xlabel('spatial frequency')
ylabel('sensitivity')

hold on

load('H:\DumoulinLab\Carlien\qCSF_Spinoza\Data\S1\S1_L_BF08_qCSF_2020_10_21_10_19.mat')
plot(log10(qcsf.stimuli.frequency),qcsf.data.estSensitivity(qcsf.data.trial,:))
axis([log10(qcsf.stimuli.frequency([1 end]))' -log10(qcsf.stimuli.contrast([end 1]))'])
set(gca,'Yaxislocation','left','Xtick',log10([.5 1 2 5 10 20]),'XtickLabel',([.5 1 2 5 10 20]),'Ytick',log10([2 10 50 200 500 1000]),'Yticklabel',([2 10 50 200 500 1000]))
xlabel('spatial frequency')
ylabel('sensitivity')
