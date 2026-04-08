% function analyse_qCSF

subj = 'MZ';
cond = {'L'};
% cond = {'LEFT','p2D'};

ntrial = [150]% 150 300];
rgb    = [.6 .6 .6; 1 .2 .2; 0 0 0];
lineStyle = {'-','-','--'}
disp(['analyzing subject: ', subj]);
rootDir  = pwd;
figure('color','white','units','normalized','outerposition',[0 0 .75 .75])

for cc=1:length(cond)
    dataDir  = [rootDir,'\','Data\' subj ];
    resfiles = dir([dataDir]);
    qcsf_param=[];
    for ii=1:length(resfiles)
        if (ii~="..") && (ii~=".")        
            cd(dataDir)
            resfiles(ii).name
            fprintf('%d of %d\n',ii,length(resfiles))
            dat = load(resfiles(ii).name);
            qcsf_param  = dat.qcsf.data.estCSF;
        end
    end
    cd(rootDir)
    SF = dat.qcsf.stimuli.frequency;
    maxSF     = 60; % for fit
    SFsmooth  =  logspace(log10(min(SF)),log10(maxSF),1e4);
    %plot
    % grp average vs ind subject
    subplot(1,length(cond),cc)
    for nt=1:length(ntrial)
        qCSFparam_ntrial = qcsf_param(ntrial(nt),:);
        qCSFfit    = findQCSF(log10(SFsmooth),qCSFparam_ntrial(1),qCSFparam_ntrial(2),qCSFparam_ntrial(3),qCSFparam_ntrial(ii,4));
        semilogx(SFsmooth,qCSFfit,lineStyle{nt},'color',rgb(nt,:),'Linewidth',nt,'MarkerSize',15);
        set(gca,'Yaxislocation','left','XScale','log','Xtick',([.5 1 2 5 10 20]),'XtickLabel',([.5 1 2 5 10 20]),'Ytick',log10([2 10 50 200]),'Yticklabel',([2 10 50 200]))
        xlabel('Spatial frequency (cycle/deg)')
        ylabel('Sensitivity')
        title(subj)
        p(1)=plot(log10(50),0,'-','color','k','lineWidth',4);
        
        % hold off
        
        % leg1=legend(p,'AO','KC',2);
        % set(leg1,'Fontsize',16);
        ylim([0 3])
        % xlim(log10([0.2 35]))
        axis square
        hold on
        
    end
end
