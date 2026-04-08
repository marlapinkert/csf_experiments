function plotqCSF(subj,allSens_AO,allSens_KC,sfList)

figure('Color','white');
set(gca,'Fontname','Arial','FontSize',24)
rgb = ([0 0 .5;.9 0 0]);
hold on

mSens_AO     = mean(allSens_AO); 
mSens_KC     = mean(allSens_KC);
errSens_AO   = std(allSens_AO)./sqrt(size(allSens_AO,1));
errSens_KC   = std(allSens_KC)./sqrt(size(allSens_KC,1));

h1=errorbar(log10(sfList),mSens_AO,errSens_AO,'color',rgb(1,:),'Linewidth',2); hold on
removeErrorBarEnds(h1)
plot(log10(sfList),mSens_AO,'o-','color',rgb(1,:),'lineWidth',3,'MarkerSize',10,'MarkerFaceColor',[1 1 1])

h2=errorbar(log10(sfList),mSens_KC,errSens_KC,'color',rgb(2,:),'Linewidth',2);
plot(log10(sfList),mSens_KC,'s-','color',rgb(2,:),'lineWidth',3,'MarkerSize',12,'MarkerFaceColor',[1 1 1])
removeErrorBarEnds(h2)

set(gca,'Yaxislocation','left','Xtick',log10([.5 1 2 5 10 20]),'XtickLabel',{'0.5','1','2','5','10','20'},'Ytick',log10([2 10 100 200]),'Yticklabel',({'2','10','100','200'}))
xlabel('Spatial frequency (cycle/deg)')
ylabel('Contrast sensitivity')
ylim([0 200])
% p(1)=plot(log10(50),0,'-','color',rgb(1,:),'lineWidth',4);
% p(2)=plot(log10(50),0,'-','color',rgb(2,:),'lineWidth',4);

hold off

% leg1=legend(p,'AO','KC');
% set(leg1,'Fontsize',16);
ylim([0 2.30103])
xlim(log10([0.2 35]))
set(gca,'Layer','top','Linewidth',3,'Box','off','PlotBoxAspectRatio',[1,1,1],'TickDir','out','TickLength',[1,1]*0.02/max(1,1));
axis square

