function results20100205_3tprojector;

x = round([0:8]'./8*255);

y = [1.1  1.1 1.1 1.1;...
    1.39 3.19 1.25 2.84;...
    2.46 12 1.84 11.4;...
    4.29 26.9 3.08 25.6;...
    6.6 51.9 4.7 45.3;...
    10 86.9 6.0 75.8;...
    12.5 103 6.45 108;...
    15.5 130 6.9 127;...
    15.7 139 7.7 161];

normfac = y(end,:);

y = y - (ones(size(y,1),1)*y(1,:));
y2 = y ./ (ones(size(y,1),1)*normfac);
x2 = x./max(x);

gamma = zeros(4,1); % 4th = mean
for n=1:3,
    gamma(n) = fminsearch(@(f) myfit(f,x2,y2(:,n)),2);
end;
gamma(4) = fminsearch(@(f) myfit(f,x2,mean(y2,2)),2);
gamma
    
figure(1);clf;
X = [0:255]'./255;
subplot(2,1,1);
plot(x2,y2,'o');hold on;
plot(x2,mean(y2,2),'kx','MarkerSize',20);hold on;
plot(X,X.^(1./gamma(4)),'r-');
subplot(2,1,2);
plot(x2,y2,'o');hold on;
plot(x2,mean(y2,2),'kx','MarkerSize',20);hold on;
plot(X,[X.^(1./gamma(1)) X.^(1./gamma(2)) X.^(1./gamma(3)) ],'-');

% save gamma
g     = gamma(1:3); % mean gamma
gamma = ([0:255]'./255) * [1 1 1];
gamma = gamma.^(ones(size(gamma,1),1)*g');
gammaTable = round(gamma.*255);
save('gamma.mat','gamma','gammaTable');

% 
% for n=1:3,
%     gamma = fminsearch(@(f) ComputeGammaExtP(f,y2(:,n)),[2; 0])
% end;
% gamma(4) = fminsearch(@(f) myfit(f,x2,mean(y2,2)),2);
% gamma
%     
% figure(1);clf;
% subplot(2,1,1);plot(x2,y2,'o',x2,x2.^(1./gamma(4)),'r-');
% subplot(2,1,2);plot(x2,y2,'o');
% hold on;
% plot(x2,[x2.^(1./gamma(1)) x2.^(1./gamma(2)) x2.^(1./gamma(3)) ],'-');
% 



% pval = 4;
% for n=1:3,
%     p(n,:)=polyfit(x2,y2(:,n),pval);
% end;
% p(4,:)=polyfit(x2,mean(y2,2),pval);
% 
% 
% pval = 3;
% for n=1:3,
%     pinv(n,:)=polyfit(y2(:,n),x2,pval);
% end;
% pinv
% p=pinv
% 
% figure(2);clf;
% xall = [0:255]./255;
% %subplot(2,1,1);plot(x2,y2,'o',xall,polyval(p(4,:),xall),'r-');
% plot(y2,x2,'o');
% hold on;
% plot(xall,[polyval(p(1,:),xall)' polyval(p(2,:),xall)' polyval(p(3,:),xall)'],'-');
% 
% pval = 4;
% for n=1:3,
%     pinv(n,:)=polyfit(y2(:,n),x2,pval);
% end;
% pinv
% 




%-------
function e=myfit(g,x,y);


w=sin(x*pi)*.9+.1;
e=sqrt(mean(w.*((x - (y.^g)).^2)));