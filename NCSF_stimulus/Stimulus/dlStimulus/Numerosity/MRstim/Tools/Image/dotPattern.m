function img=dotPattern(sizeInPix,orientationInDeg,orientationBPinDeg, dotSpeedInPix, dotSpeedBPinPix, duration, ndots, reversalMin, reversalMax, dotLifeTime, coherence, window, maxSignalDotsList, stepNumber);

% input handling
if ~exist('sizeInPix','var') || isempty(sizeInPix) 
    sizeInPix = 600;
end
if ~exist('orientationBPinDeg','var') || isempty(orientationBPinDeg) 
    orientationBPinDeg = 0;
end
if ~exist('orientationInDeg','var') || isempty(orientationInDeg) 
    orientationInDeg = 0;
end
if ~exist('dotSpeedInPix','var') || isempty(dotSpeedInPix) 
    dotSpeedInPix=1;
end
if ~exist('dotSpeedBPinPix','var') || isempty(dotSpeedBPinPix) 
    dotSpeedBPinPix=0;
end
if ~exist('duration','var') || isempty(duration) 
    duration=40;
end
if ~exist('ndots','var') || isempty(ndots) 
    ndots=0;
end
if ~exist('reversalMin','var') || isempty(reversalMin) 
    reversalMin=duration;
end
if ~exist('reversalMax','var') || isempty(reversalMax) 
    reversalMax=duration;
end
if ~exist('coherence','var') || isempty(coherence) 
    coherence=100;
end


rx = sizeInPix * rand(ndots,1);
ry = sizeInPix * rand(ndots,1);

dotSpeeds=((rand(ndots,1)-0.5).*dotSpeedBPinPix)+dotSpeedInPix;
if orientationInDeg==999
    dotOrientations=rand(ndots,1).*360;
else
    if coherence==100
        dotOrientations=((rand(ndots,1)-0.5).*orientationBPinDeg)+orientationInDeg;
    else
        dotOrientations=((rand(round(ndots*coherence/100),1)-0.5).*orientationBPinDeg)+orientationInDeg;
        dotOrientations=vertcat(dotOrientations, rand(ndots-length(dotOrientations),1).*360);
        tmp=rand(ndots,1);
        [tmp, index]=sort(tmp);
        dotOrientations=dotOrientations(index);
    end
end
if dotLifeTime>0
    dotLifeTimes=round(rand(ndots,1)*dotLifeTime);
end

dxdy=[sind(dotOrientations) cosd(dotOrientations)].*repmat(dotSpeeds,[1 2]);

oppositeDirectionsFlag=0;
if oppositeDirectionsFlag==1
    dotSigns=sign(rand(ndots, 1)-0.5);
    dxdy=dxdy.*[dotSigns dotSigns];
end

xy=[rx ry];

rect=[0 0 sizeInPix sizeInPix]; 

if exist('window','var') && ~isempty(window)
    coherentDotCounts=[];
    incoherentDotCounts=[];
end
    
% [w rect] = Screen('OpenWindow', screenNumber, 128, rect, 32);
% center=[0 0];

img=[];
% %rect=[0 0 sizeInPix sizeInPix];

if reversalMin>=duration
    reversal=duration+1;
else
    reversal=reversalMin+round(rand*(reversalMax-reversalMin));
end
direction=1;

for ii=1:duration
    
    if ii==reversal
        direction=3-direction;
        reversal=reversal+reversalMin+round(rand*(reversalMax-reversalMin));
    end
%      [w rect] = Screen('OpenWindow', screenNumber, 128, rect, 32);
%     imgIndex=Screen('OpenOffScreenWindow', w, 128, rect);
%     Screen('DrawDots',imgIndex, transpose(xy), dotRadiusInPix, rc, center,1);
%     img(:,:,:,ii)=Screen('GetImage', imgIndex);

    if direction==1
        xy=xy+dxdy;
    else
        xy=xy-dxdy;
    end
    
    newx=xy(:,1);
    newy=xy(:,2);
    
    newx(newx>sizeInPix)=newx(newx>sizeInPix)-sizeInPix;
    newy(newy>sizeInPix)=newy(newy>sizeInPix)-sizeInPix;
    
    newx(newx<0)=newx(newx<0)+sizeInPix;
    newy(newy<0)=newy(newy<0)+sizeInPix;

    if dotLifeTime>0 
        replots=dotLifeTimes==0;
        rx = sizeInPix * rand(ndots,1);
        ry = sizeInPix * rand(ndots,1);
        rx = rx.*replots;
        ry = ry.*replots;
        newx(replots)=rx(replots);
        newy(replots)=ry(replots);
        
        dotLifeTimes=dotLifeTimes-1;
        dotLifeTimes(replots)=dotLifeTime;
    end

    xy=[newx newy];
    
    if ii>1
        if exist('window','var') && ~isempty(window)
            xyOut=uint16(xy);
            inLastFrame=inThisFrame;
            inThisFrame=ismember(xyOut, window, 'rows');
            coherentDots=inLastFrame&inThisFrame&~replots;
            coherentDotCount=sum(coherentDots);
            if exist('maxSignalDotsList','var') && ~isempty(maxSignalDotsList) && exist('stepNumber','var') && ~isempty(stepNumber)
                if coherentDotCount>maxSignalDotsList(stepNumber)
                    numberToReplace=coherentDotCount-maxSignalDotsList(stepNumber);
                    coherentDotIndices=find(coherentDots==1);
                    [tmp, index]=sort(rand(size(coherentDotIndices)));
                    coherentDotIndices=coherentDotIndices(index);
                    for jj=1:numberToReplace
                        xy(coherentDotIndices(jj), :)=single(window(ceil(rand(1)*length(window)),:))-0.5+[rand(1), rand(1)];
                        xyOut(coherentDotIndices(jj),:)=uint16(xy(coherentDotIndices(jj),:));
                        replots(coherentDotIndices(jj))=1;
                    end
                    coherentDots=inLastFrame&inThisFrame&~replots;
                    coherentDotCount=sum(coherentDots);
                end
            end
            coherentDotCounts=[coherentDotCounts coherentDotCount];
            incoherentDotCounts=[incoherentDotCounts sum(inThisFrame)-coherentDotCount];            
            xyOut(inThisFrame==0,:)=55555;
            img=cat(1, img, uint16(xyOut));
        else
            img=cat(1, img, uint16(xy));
        end 
    else
        if exist('window','var') && ~isempty(window)
            xyOut=uint16(xy);
            inThisFrame=ismember(xyOut, window, 'rows');
            xyOut(inThisFrame==0,:)=55555;
            img=cat(1, img, uint16(xyOut));
        else
            img=cat(1, img, uint16(xy));
        end 
    end
end

if exist('window','var') && ~isempty(window) && orientationInDeg==270
    signalMean=mean(coherentDotCounts);
    noiseMean=mean(incoherentDotCounts);
    percentage=100*signalMean/(signalMean+noiseMean);
    disp(sprintf('[%s]:Signal Dots= %d Noise Dots= %d Total Dots= %d. This is %.2f percent signal .',mfilename,round(signalMean),round(noiseMean), round(signalMean + noiseMean),percentage));
end


%Screen('CloseAll');


