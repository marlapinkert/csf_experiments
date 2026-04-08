function stimulus = makeRetinotopyStimulus_naturalImages(params)
% makeRetinotopyStimulus - make various retinotopy stimuli
%
% stimulus = makeRetinotopyStimulus_bars(params)
%
% Matlab code to generate various retinotopy stimuli
% Generates one full cycle, as well as the sequence for the entire scan.
%
% 99.09.15 RFD: I fixed the sequence generation algorithm so that
%   timing is now frame-accurate.  The algorithm now keeps track
%   of timing error that accumulates due to rounding to the nearest
%   frame and corrects for that error when it gets to be more than 
%   half a frame.  
%   The algorithm also randomely reverses the drift direction, rather
%   than reversing every half-an image duration.
% 2005.06.15 SOD: changed for OSX - stimulus presentation will now be 
%                 time-based rather than frame based. Because of bugs
%                 with framerate estimations.

% 2009.09.27 BMH: Set up for contour integration stimuli

%Contour stimulus parameters
%contourOrientation=params.contour.contourOrientation; %Contour orientation relative to bars. 0 is parrallel to bars
%contourSF=1/3; %Contour spatial frequence, in degrees (1/3=3 cycles per degree)
%contourBandpass=params.contour.contourBandpass; %Contour orientation bandpass, in degrees

if isfield(params.naturalimage, 'TRsOn') %Block design
    pauseDurationMin=8;%In TRs
    pauseDurationMax=8;%In TRs
else %Event design
    pauseDurationMin=6;%In TRs
    pauseDurationMax=10;%In TRs
end
    
differentImages=params.naturalimage.differentImages;

flipUpDown=0; %Flip images up-down to compensate for scanner projector


%10 short onsets
% imageOff=0.1;   %Time between image presentations in the same TR
% imageOn=0.1;
% fadeLength=0;
% imageShows=10;

% %5 onsets, short off
% imageOff=0.2;   %Time between image presentations in the same TR
% imageOn=0.2;
% fadeLength=0;
% imageShows=5;
% 
% %4 onsets, short off
% imageOff=0.1;   %Time between image presentations in the same TR
% imageOn=0.4;
% fadeLength=0;
% imageShows=4;
% 
%3 onsets, short fade
% imageOff=0.1;   %Time between image presentations in the same TR
% imageOn=0.3;
% fadeLength=0.15;
% imageShows=3;
% 
% %2 onsets, long fade
% imageOff=0.2;   %Time between image presentations in the same TR
% imageOn=0.3;
% fadeLength=0.3;
% imageShows=2;

imageOff=params.naturalimage.imageOff;   %Time between image presentations in the same TR
imageOn=params.naturalimage.imageOn;
fadeLength=params.naturalimage.fadeLength;
imageShows=params.naturalimage.imageShows;

cycleTotal=params.tr+imageOff;
switch params.experiment
    case {'Natural Images Masks Short', 'Natural Images Masks Long'}
        onOffTotal=single(imageOn+imageOff+fadeLength);
    otherwise
        onOffTotal=single(imageOn+imageOff+fadeLength*2);
end
if onOffTotal*imageShows~=single(cycleTotal)
    if onOffTotal*imageShows==single(params.tr)
        fprintf('WARNING: TIMING ENDS IN OFF PERIOD OF CYCLE.\n');
    else
        fprintf('WARNING: TIMING PARAMETERS DO NOT ADD UP.\n');
    end
end

% load('/Users/student/Documents/Martijn/retintopimg.mat','-mat');
% 
% disp(sprintf('[%s]:resizing images to 768x768.',mfilename));
% for i = 1:length(naturalimg)
%     naturalimg(i).image = imresize(mat2gray(naturalimg(i).image,[0 255]),[768 768]);
% end
% 
% save('/Users/student/Documents/Martijn/retintopimg(768).mat','naturalimg'
% );

%if (naturalimg)
    disp(sprintf('[%s]: loading natural images.',mfilename));
    load(params.naturalimage.imageFileName,'-mat');
%end


% various time measurements:
duration.stimframe          = 1./params.temporal.frequency./params.temporal.motionSteps;
duration.scan.seconds       = params.ncycles*params.period;
duration.scan.stimframes    = params.ncycles*params.period./duration.stimframe;
duration.cycle.seconds      = params.period;
duration.cycle.stimframes   = params.period./duration.stimframe;
duration.prescan.seconds    = params.prescanDuration;
duration.prescan.stimframes = params.prescanDuration./duration.stimframe;


% load matrix or make it
if ~isempty(params.loadMatrix),
    % we should really put some checks that the matrix loaded is
    % appropriate etc.
    load(params.loadMatrix);
    halfNumImages = params.numImages./2;
    disp(sprintf('[%s]:loading images from %s.',mfilename,params.loadMatrix));
%    disp(sprintf('[%s]:size stimulus: %dx%d pixels.',mfilename,n,m));
else
    outerRad = params.radius;
    innerRad = params.innerRad;


    halfNumImages = params.numImages;


    %%% Set check colormap indices %%%
    %bk = findName(params.display.reservedColor,'background');
    %minCmapVal = max([params.display.reservedColor(:).fbVal])+1;
    %maxCmapVal = params.display.numColors-1;
    bk = params.display.backColorIndex;
    
    
    minCmapVal = min([params.display.stimRgbRange]);
    maxCmapVal = max([params.display.stimRgbRange]);


    %%% Initialize image template %%%
    m=angle2pix(params.display,2*outerRad); 
    n=angle2pix(params.display,2*outerRad);

    % Loop that creates the final images
    %images=zeros(m,n,length(naturalimg)+1,'uint8');
    
    %Randomize image presentation order
    if isfield(params.naturalimage, 'TRsOn')
        presentationsPerImage=duration.scan.seconds/((params.tr*params.naturalimage.TRsOn)+params.tr*mean([pauseDurationMin pauseDurationMax]))/differentImages;
    else
        presentationsPerImage=duration.scan.seconds/(params.tr+params.tr*mean([pauseDurationMin pauseDurationMax]))/differentImages;
    end
    if uint8(presentationsPerImage)~=presentationsPerImage;
        fprintf('WARNING: UNEVEN NUMBER OF PRESENTAITONS PER IMAGES. STIMULUS DURATION SHOULD BE PRESCAN+14*IMAGES*REPETITIONS.\n');
    end
    
    imageShowOrder=[];
    for ii=1:presentationsPerImage
        imageShowCycle=1:differentImages;
        tmp=rand(1,length(imageShowCycle));
        [tmp index]=sort(tmp);
        imageShowCycle=imageShowCycle(index);
        imageShowOrder=[imageShowOrder imageShowCycle];        
    end    

    if isfield(params.naturalimage, 'TRsOn')
        waitPeriodOrder=zeros(1,differentImages*presentationsPerImage)+pauseDurationMin;
    else
        waitPeriodOrder=1:5;
        reps=differentImages*presentationsPerImage/5;
        repInt=floor(reps);
        repRemainder=(reps-repInt)*5;
        waitPeriodOrder=repmat(waitPeriodOrder, 1,repInt);
        if repRemainder>0
            waitPeriodOrder=[waitPeriodOrder 3.*ones(1,uint8(repRemainder))];
        end
        temp=rand(1,length(waitPeriodOrder));
        [temp waitIndex]=sort(temp);
        waitPeriodOrder=waitPeriodOrder(waitIndex);
        waitPeriodOrder=waitPeriodOrder+(pauseDurationMin-1);
    end
    
    fprintf('Image display order:');
    params.imageShowOrder=imageShowOrder;
    imageShowOrder
    fprintf('Pause interval order (in TRs):');
    params.waitPeriodOrder=waitPeriodOrder;
    waitPeriodOrder
   
    %imageShowOrder=ones(size(imageShowOrder)).*5;
    switch params.experiment
        case('Natural Images Grid 3 Flashes')
            for ii=1:differentImages
                randomGridOrder=1:10;
                tmp=rand(1,length(randomGridOrder));
                [tmp index]=sort(tmp);
                randomGridOrder=randomGridOrder(index);
                if flipUpDown==1
                    images(:,:,ii)=flipud(naturalimg((ii-1)*10+randomGridOrder(1)).image);
                    images(:,:,ii+differentImages)=flipud(naturalimg((ii-1)*10+randomGridOrder(2)).image);
                    images(:,:,ii+(2*differentImages))=flipud(naturalimg((ii-1)*10+randomGridOrder(3)).image);
                else
                    images(:,:,ii)=naturalimg((ii-1)*10+randomGridOrder(1)).image;
                    images(:,:,ii+differentImages)=naturalimg((ii-1)*10+randomGridOrder(2)).image;
                    images(:,:,ii+(2*differentImages))=naturalimg((ii-1)*10+randomGridOrder(3)).image;
                end
            end
        otherwise
            for ii=1:differentImages
                if flipUpDown==1
                    images(:,:,ii)=flipud(naturalimg(ii).image);
%                     min(min(images(:,:,ii)))
%                     max(max(images(:,:,ii)))
%                     mean(mean(images(:,:,ii)))
                else
                    images(:,:,ii)=naturalimg(ii).image;
                end
            end
    end
    fadeLength=uint8(fadeLength/duration.stimframe);
    if fadeLength>0
        switch params.experiment
            case {'Natural Images 2 Fades', 'Natural Images 3 Fades'}
                fadeStrength=linspace(0,1,fadeLength+2);
                
                for ff=1:fadeLength
                    for ii=1:differentImages
                        if flipUpDown==1
                            tmp=double(flipud(naturalimg(ii).image));
                            
                        else
                            tmp=double(naturalimg(ii).image);
                        end
                        tmp=tmp-128;
                        tmp=tmp*fadeStrength(ff+1);
                        tmp=tmp+128;
                        images(:,:,ii+ff*differentImages)=uint8(tmp);
                    end
                end
%             case {'Natural Images Masks Short', 'Natural Images Masks Long'}
%                 for ii=37:66
%                     if flipUpDown==1
%                         images(:,:,ii)=flipud(naturalimg(ii).image);
%                     else
%                         images(:,:,ii)=naturalimg(ii).image;
%                     end
%                 end
                
%                     for ii=1:differentImages
%                          if flipUpDown==1
%                             tmp=double(255*round(bandpassimage(rand(538), [64 128],1)));
%                             
%                         else
%                             tmp=double(255*round(bandpassimage(rand(538), [64 128],1)));
%                         end
%                         tmp=tmp-128;
%                         tmp=tmp*0.5;
%                         tmp=tmp+128;
%                         images(:,:,ii+differentImages)=uint8(tmp);
%                     end
        end
    end
    
    images(:,:,size(images,3)+1)=bk*ones(size(images(:,:,1)));



    fprintf('Done.\n');
end;
imageOn=uint8(imageOn/duration.stimframe);
imageOff=uint8(imageOff/duration.stimframe);


%imageOff=imageOff/duration.stimframe;
%imageOn=onPeriod/imageShows-imageOff;
sequence=[];


for ii=1:length(imageShowOrder)
    cycleSequence=[];
    for imageShowsCounter=1:imageShows
        if fadeLength>0
            switch params.experiment
                case {'Natural Images 2 Fades', 'Natural Images 3 Fades'}
                    for ff=1:fadeLength
                        cycleSequence=[cycleSequence (differentImages*(ff))+imageShowOrder(ii)];
                    end
                case {'Natural Images Masks Short', 'Natural Images Masks Long'}
                    cycleSequence=[cycleSequence repmat(((differentImages*ceil(rand*5))+30+imageShowOrder(ii)), 1, fadeLength)];
            end
        end
        
        for ff=1:imageOn
            switch params.experiment
                case('Natural Images Grid 3 Flashes')
                    cycleSequence=[cycleSequence (differentImages*(imageShowsCounter-1))+imageShowOrder(ii)];
                case('Natural Images 3 Flashes')
                    cycleSequence=[cycleSequence imageShowOrder(ii)];
                otherwise
                    if imageShowsCounter<7
                        cycleSequence=[cycleSequence (differentImages*imageShowsCounter)+imageShowOrder(ii)];
                    elseif imageShowsCounter<13
                        cycleSequence=[cycleSequence (differentImages*(imageShowsCounter-6))+imageShowOrder(ii)];
                    elseif imageShowsCounter<19
                        cycleSequence=[cycleSequence (differentImages*(imageShowsCounter-12))+imageShowOrder(ii)];
                    elseif imageShowsCounter<25
                        cycleSequence=[cycleSequence (differentImages*(imageShowsCounter-18))+imageShowOrder(ii)];
                    end
            end
        end
        %cycleSequence=[cycleSequence size(images,3)];
        
        if fadeLength>0
            switch params.experiment
                case {'Natural Images Masks Short', 'Natural Images Masks Long'}
                    %do nothing
                otherwise
                    for ff=1:fadeLength
                        cycleSequence=[cycleSequence (differentImages*(fadeLength-(ff-1)))+imageShowOrder(ii)];
                    end
            end
        end
        
        if imageOff>0
            switch params.experiment
                case {'Natural Images Masks Short', 'Natural Images Masks Long'}
                    cycleSequence=[cycleSequence repmat(((differentImages*ceil(rand*5))+30+imageShowOrder(ii)), 1, imageOff)];
                otherwise
                    for ff=1:imageOff
                        cycleSequence=[cycleSequence size(images,3)];
                    end
            end
        end
    end
    %cycleSequence=repmat(cycleSequence, 1,imageShows);
    cycleSequence=cycleSequence(1:params.tr/duration.stimframe);
    
    if isfield(params.naturalimage, 'TRsOn')
       cycleSequence=repmat(cycleSequence, 1, params.naturalimage.TRsOn); 
    end
    
    for ff=1:waitPeriodOrder(ii)*(params.tr/duration.stimframe)
        cycleSequence=[cycleSequence size(images,3)];
    end
%     for jj=1:imageShows
%         startFrame=1+((jj-1)*(imageOn+imageOff));
%         cycleSequence(startFrame:startFrame+imageOn)=ii;
%         cycleSequence(startFrame+imageOn+1:startFrame+imageOn+imageOff)=length(naturalimg)+1;
%     end
%     offFrame=startFrame+imageOn+imageOff+1;
%     cycleSequence(offFrame:offFrame+offPeriod)=length(naturalimg)+1;
    sequence=[sequence cycleSequence];
end
    

% fixation dot sequence
% change on the fastest every 6 seconds
minsec = 1.8./duration.stimframe;
fixSeq = ones(minsec,1)*round(rand(1,ceil(length(sequence)/minsec)));
fixSeq = fixSeq(:)+1;
fixSeq = fixSeq(1:length(sequence));
% % force binary
fixSeq(fixSeq>2)=2; 
fixSeq(fixSeq<1)=1;


% Insert the preappend images by copying some images from the
% end of the seq and tacking them on at the beginning
fprintf('First image blank.\n');
sequence = [ones(1,duration.prescan.stimframes).*size(images,3) sequence];
timing   = [0:length(sequence)-1]'.*duration.stimframe;
cmap     = params.display.gammaTable;
fixSeq   = [fixSeq(length(fixSeq)+1-duration.prescan.stimframes:end); fixSeq];


% make stimulus structure for output
stimulus = createStimulusStruct(images,cmap,sequence,[],timing,fixSeq);

% save matrix if requested
if ~isempty(params.saveMatrix),
    save(params.saveMatrix,'images');
end;

