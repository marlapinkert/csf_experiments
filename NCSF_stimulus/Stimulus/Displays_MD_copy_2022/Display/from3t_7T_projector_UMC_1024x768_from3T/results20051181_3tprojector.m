function results20051118_3Tprojector;

mm_x = round([0:8]'./8*255);

mm_y = [0.36   .4      .36;...
    .38     .5      .36;...
    .67     1.39    .55;...
    1.53    4.35    0.74;...
    3.07    10.06   1.59;...
    5.12    18.17   2.25;...
    8.12    30.12   3.41;...
    11.68   43      5.18;...
    15.24   59.29   5.34];

mm_x2 = [0 85 123 152 177 199 219 238 255]';
mm_y2 = [0       0       0.3;...
        2.83    8.27    .89;...
        4.57    16.93   2.1;...
        6.47    30.65   3.17;...
        7.72    15.26   5.20;...
        8.51    31.15   3.79;...
        9.74    43.73   4.60;...
        7.42    49.64   5;... % latter one originally was 27.46
        13.57   54.77   7.81];

x = [mm_x; mm_x2];
y = [mm_y; mm_y2];
normfac = mean([mm_y(end,:); mm_y2(end,:)]);

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
g     = gamma(4); % mean gamma
gamma = ([0:255]'./255) * [1 1 1];
gamma = gamma.^g;
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