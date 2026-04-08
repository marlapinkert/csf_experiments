function [stimulus, params]=createWindowPositions(stimulus, params)
windowPositions = size(stimulus.seq, 3);
stimFrame       = 1./params.temporal.frequency./params.temporal.motionSteps;
framesPerPosition=params.tr/stimFrame;
reversalMin=0.50; %in seconds
reversalMax=0.75;
reversalMin=round(reversalMin/stimFrame);
reversalMax=round(reversalMax/stimFrame);

if params.stimFlicker>0
    flickerTime=1./params.stimFlicker;
    flickerTime=flickerTime:flickerTime:params.tr*windowPositions;
    flickerTimeIndex=1;
end
    

n=size(stimulus.seq,1);
ppd=n./(params.radius*2);
fRate=1/stimFrame;
speedPixPerFrame = params.stimSpeed * ppd / fRate;

stimulus.images=stimulus.images{1};
% cornerPositionX=(rand(1)*(size(stimulus.images,1)-n));
% cornerPositionY=(rand(1)*(size(stimulus.images,1)-n));
% if speedPixPerFrame==0;
%     cornerPositionX=1;
%     cornerPositionY=1;
% end

reversalCounter=0;
reversalTime=reversalMin+round(rand(1)*(reversalMax-reversalMin));

params.cornerPositions=zeros(windowPositions, framesPerPosition, 2);

for winPos = 1:windowPositions
    
    if params.stimFlicker==0 || winPos==1
        cornerPositionX=0;
        cornerPositionY=0;
        while round(cornerPositionX)<=0 ||  round(cornerPositionY)<=0
            cornerPositionX=(rand(1)*(size(stimulus.images,1)-n));
            cornerPositionY=(rand(1)*(size(stimulus.images,1)-n));
        end
    end

    for frame=1:framesPerPosition;
        
        cornerPositionX=(cornerPositionX+(sind(stimulus.orientations(winPos))*speedPixPerFrame));
        cornerPositionY=(cornerPositionY+(cosd(stimulus.orientations(winPos))*speedPixPerFrame));
        
        if round(cornerPositionX)+n-1>size(stimulus.images,1) || round(cornerPositionY)+n-1>size(stimulus.images,1) || round(cornerPositionX)<=0 || round(cornerPositionY)<=0|| reversalCounter==reversalTime;
            speedPixPerFrame=0-speedPixPerFrame;
            cornerPositionX=(cornerPositionX+(sind(stimulus.orientations(winPos))*speedPixPerFrame*2));
            cornerPositionY=(cornerPositionY+(cosd(stimulus.orientations(winPos))*speedPixPerFrame*2));
            reversalCounter=0;
            reversalTime=reversalMin+round(rand(1)*(reversalMax-reversalMin));
        else
            reversalCounter=reversalCounter+1;
        end
        
        if params.stimFlicker>0
            if flickerTime(flickerTimeIndex)<(((winPos-1)*framesPerPosition)+frame)*stimFrame
                cornerPositionX=0;
                while round(cornerPositionX)<=0 ||  round(cornerPositionY)<=0
                    cornerPositionX=(rand(1)*(size(stimulus.images,1)-n));
                    cornerPositionY=(rand(1)*(size(stimulus.images,1)-n));
                end
                flickerTimeIndex=flickerTimeIndex+1;
            end
        end
        
        params.cornerPositions(winPos, frame, 1)= cornerPositionX;
        params.cornerPositions(winPos, frame, 2)= cornerPositionY;
        
    end
end
return

