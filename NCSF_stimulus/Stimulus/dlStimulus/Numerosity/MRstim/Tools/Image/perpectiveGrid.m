function [x,y] = perpectiveGrid(startY, stopY, stepsY, stepsX, depth)

%Adds a perpective transformation to meshgrid to correct for perspective
%caused by close display positions in Utrecht's 7T scanner display, where
%the bottom of the display is closer to the viewer than the top

%Measurements of distance from the display here should be based on the
%distance to the fixation point from the subject's point of view, 
depth=depth/100;%stepsY;

y=linspace(startY, stopY, stepsY);
normaldif=diff(y);
normaldif=normaldif(1);
n=1:length(y);
% ndif=n-length(y)/2;

adder=n.^2.*depth;

if mod(length(y), 2)==0
    midpoint=length(y)/2;
else
    midpoint=floor(length(y)/2);
end

%scaling=(adder(midpoint)-adder(midpoint+1))+(y(2)-y(1))/normaldif;

y=y+(adder-adder(midpoint));

%y=Scale(y);
%y=startY+y*(stopY-startY);
difY=diff(y);
scaler=normaldif/difY(midpoint);
y=y.*scaler;
%scaling=difY(midpoint)/normaldif;
%figure; plot(difY);
y=repmat(y', 1, stepsX);

difY=([difY(1) difY]+[difY difY(end)])./2;
x=zeros(stepsY, stepsX);
for n=1:stepsY
    x(n,:)=(-difY(n)*((stepsX-1)/2)):difY(n):(difY(n)*((stepsX-1)/2));
end

end

