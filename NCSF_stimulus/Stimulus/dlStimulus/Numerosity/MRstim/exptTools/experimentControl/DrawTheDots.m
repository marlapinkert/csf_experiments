triggerKey=KbName('t');
for frame=1:framesPerPosition;
%     if strcmp(params.experiment,'One Dot Sizes Constant Step pRF full blanks TR=2.1, nTRs=2')
%         if frame==1
%             dotGroup=[];
%         end
%     end

% if strcmp(params.calibration, '7T_UMC_1024x768')
%     Screen('FillRect', display.windowPtr, [0 0 0], [0 0 1024 768]);
%     Screen('FillRect', display.windowPtr, [128 128 128], [171 0 1024-171 512]);
% elseif strcmp(params.calibration, '7T_DLP_1600x900')
%     Screen('FillRect', display.windowPtr, [0 0 0], [0 0 1600 900]);
%     %Screen('FillRect', display.windowPtr, [128 128 128], [800-296 0 800+296 444]);
%     Screen('FillRect', display.windowPtr, [128 128 128], [800-344 0 800+344 516]);
% else
%     Screen('FillRect', display.windowPtr, [128 128 128], rect );
% end
    %ndots=ceil(rand(1)*6);
    
    switch lower(params.whichStim)
        case {'dotsandnumbers'}
            
            if uint8(mod(frame,framesPerPattern))==1;
                dotGroup=newDotPattern(params, ndots,n, dotSize, 2);
                fontNumberOld=fontNumber;
                while fontNumberOld==fontNumber;
                    fontNumber=ceil(length(fontList)*rand(1));
                end
                Screen('DrawDots',display.windowPtr, double(dotGroup'), double(dotSize), double(dotColors), [display.Rect(1) display.Rect(2)],1);
            elseif mod(frame,framesPerPattern) <= framesPerPattern - grayFrames && mod(frame,framesPerPattern)> 0;
                Screen('DrawDots',display.windowPtr, double(dotGroup'), double(dotSize), double(dotColors), [display.Rect(1) display.Rect(2)],1);
            else
                Screen('DrawText', display.windowPtr, num2str(ndots), display.Rect(1)+(display.Rect(3)-display.Rect(1))/2-charWidth, display.Rect(2)+(display.Rect(4)-display.Rect(2))/2-charHeight, double(dotColors));
            end
            
        case 'dots'
            if ndots>0 || strcmp(params.experiment,'Number Symbols pRF full blanks TR=2.1, nTRs=2')
                if strcmp(params.experiment, 'Dots Attention') %These trials are complicated because of the attentional task
                    if uint8(mod(frame,framesPerPattern))==1;
                        dotGroup=newDotPattern(params, 7,n, dotSize, 2);
                        currentStim=currentStim+1;
                        if blackStims(currentStim)==1
                            Screen('DrawDots',display.windowPtr, double(dotGroup(1:ndots,:)'), double(dotSize), double([0 0 0]), [display.Rect(1) display.Rect(2)],1);
                        else
                            Screen('DrawDots',display.windowPtr, double(dotGroup(1:ndots,:)'), double(dotSize), double([blackContrastChange blackContrastChange blackContrastChange]), [display.Rect(1) display.Rect(2)],1);
                        end
                        if whiteStims(currentStim)==1
                            Screen('DrawDots',display.windowPtr, double(dotGroup(ndots+1:end,:)'), double(dotSize), double([255 255 255]), [display.Rect(1) display.Rect(2)],1);
                        else
                            Screen('DrawDots',display.windowPtr, double(dotGroup(ndots+1:end,:)'), double(dotSize), double([255-whiteContrastChange 255-whiteContrastChange 255-whiteContrastChange]), [display.Rect(1) display.Rect(2)],1);
                        end
                    elseif uint8(mod(frame,framesPerPattern))==uint8(eachStimFrames+isiFrames+1);
                        dotGroup=newDotPattern(params, 7,n, dotSize, 2);
                        currentResponse=currentResponse+1;  %Allows response to previous trial until both stimuli in next trial are shown
                        if blackStims(currentStim)==2
                            Screen('DrawDots',display.windowPtr, double(dotGroup(1:ndots,:)'), double(dotSize), double([0 0 0]), [display.Rect(1) display.Rect(2)],1);
                        else
                            Screen('DrawDots',display.windowPtr, double(dotGroup(1:ndots,:)'), double(dotSize), double([blackContrastChange blackContrastChange blackContrastChange]), [display.Rect(1) display.Rect(2)],1);
                        end
                        if whiteStims(currentStim)==2
                            Screen('DrawDots',display.windowPtr, double(dotGroup(ndots+1:end,:)'), double(dotSize), double([255 255 255]), [display.Rect(1) display.Rect(2)],1);
                        else
                            Screen('DrawDots',display.windowPtr, double(dotGroup(ndots+1:end,:)'), double(dotSize), double([255-whiteContrastChange 255-whiteContrastChange 255-whiteContrastChange]), [display.Rect(1) display.Rect(2)],1);
                        end
                    elseif mod(frame,framesPerPattern)<eachStimFrames+1 && mod(frame,framesPerPattern)> 0;%keep current frame
                        if blackStims(currentStim)==1
                            Screen('DrawDots',display.windowPtr, double(dotGroup(1:ndots,:)'), double(dotSize), double([0 0 0]), [display.Rect(1) display.Rect(2)],1);
                        else
                            Screen('DrawDots',display.windowPtr, double(dotGroup(1:ndots,:)'), double(dotSize), double([blackContrastChange blackContrastChange blackContrastChange]), [display.Rect(1) display.Rect(2)],1);
                        end
                        if whiteStims(currentStim)==1
                            Screen('DrawDots',display.windowPtr, double(dotGroup(ndots+1:end,:)'), double(dotSize), double([255 255 255]), [display.Rect(1) display.Rect(2)],1);
                        else
                            Screen('DrawDots',display.windowPtr, double(dotGroup(ndots+1:end,:)'), double(dotSize), double([255-whiteContrastChange 255-whiteContrastChange 255-whiteContrastChange]), [display.Rect(1) display.Rect(2)],1);
                        end
                    elseif mod(frame,framesPerPattern)>eachStimFrames+isiFrames+1 && mod(frame,framesPerPattern)<eachStimFrames*2+isiFrames+1
                        if blackStims(currentStim)==2
                            Screen('DrawDots',display.windowPtr, double(dotGroup(1:ndots,:)'), double(dotSize), double([0 0 0]), [display.Rect(1) display.Rect(2)],1);
                        else
                            Screen('DrawDots',display.windowPtr, double(dotGroup(1:ndots,:)'), double(dotSize), double([blackContrastChange blackContrastChange blackContrastChange]), [display.Rect(1) display.Rect(2)],1);
                        end
                        if whiteStims(currentStim)==2
                            Screen('DrawDots',display.windowPtr, double(dotGroup(ndots+1:end,:)'), double(dotSize), double([255 255 255]), [display.Rect(1) display.Rect(2)],1);
                        else
                            Screen('DrawDots',display.windowPtr, double(dotGroup(ndots+1:end,:)'), double(dotSize), double([255-whiteContrastChange 255-whiteContrastChange 255-whiteContrastChange]), [display.Rect(1) display.Rect(2)],1);
                        end
                    end
                elseif strcmp(params.experiment, 'Dots Gaussian')
                    fixSeqCounter=fixSeqCounter+1;
                    if uint8(mod(frame,framesPerPattern))==1;
                        dotGroup=newDotPattern(params, ndots,n, dotSize, 1);%sqrt(2));
                        randTmp=rand(1);
                        if randTmp<oneBackFrequency
                            fixSeqAdder=3-fixSeqAdder;
                        end
                        DrawGaussians(display, double(dotGroup'), [display.Rect(1) display.Rect(2)], loGaussian, textureIndex(fixSeqAdder));
                    elseif uint8(mod(frame,framesPerPattern)) <= framesPerPattern - grayFrames && mod(frame,framesPerPattern)> 0;
                        DrawGaussians(display, double(dotGroup'), [display.Rect(1) display.Rect(2)], loGaussian, textureIndex(fixSeqAdder));
                    end
                    stimulus.fixSeq(fixSeqCounter)=fixSeqAdder;
                else
                    %fixSeqCounter=fixSeqCounter+1;
                    if uint8(mod(frame,framesPerPattern))==1;
                        fixSeqCounter=fixSeqCounter+1;
                        if params.equalArea==3
                            dotGroup=newDotPatternDense(ndots,n, dotSize, recheckDist);
                        elseif strcmp(params.experiment,'Numbers Size pRF full blanks TR=1.5, nTRs=3') || strcmp(params.experiment,'Number Symbols pRF full blanks TR=2.1, nTRs=2')
                            center=rand(1,2)*n;
                            while sqrt((center(1)-0.5*n)^2+(center(2)-0.5*n)^2)>0.5*n-dotSize/2
                                center = rand(1,2)*n;
                            end
                        elseif strcmp(params.experiment,'One Dot Sizes Constant Step pRF full blanks TR=2.1, nTRs=2')
                            distance=5.5;
                            dotGroup=newDotPatternConstantStep(params, ndots,n, dotSize, dotGroup, distance);
                        else
                            %dotGroup=[37 5; 37 15; 37 25; 37 35; 37 45; 37 55; 37 65];
                            dotGroup=newDotPattern(params, ndots,n, dotSize, recheckDist);%2);
                            lineDirection=rand(1)*2*pi;
                        end
                        response.dotPositions{(winPos-1)*(params.tr./dotRefresh)+uint16(frame)/uint16(framesPerPattern)+1}=dotGroup;
                        randTmp=rand(1);
                        if randTmp<oneBackFrequency && fixSeqAdder==1
                            fixSeqAdder=2;%3-fixSeqAdder;
                            %stimulus.fixSeq(fixSeqCounter)=fixSeqAdder;
                            colorEvents=[colorEvents GetSecs-t0];
                        else
                            fixSeqAdder=1;
                        end
                        if strcmp(params.experiment,'Dots Shapes pRF full blanks TR=1.5, nTRs=3') || strcmp(params.experiment,'Dots Shapes pRF full blanks TR=2.1, nTRs=2')
                            %ndots=7; %For testing
                            if ndots<8
                                [unicodes, index]=shuffle(unicodesIn);
                                unicodesSizes=unicodesSizesIn(index);
                                uniXoffset=uniXoffsetIn(index);
                                uniYoffset=uniYoffsetIn(index);
                                
                                %                             unicodes=unicodesIn;
                                %                             unicodesSizes=unicodesSizesIn;
                                %                             uniXoffset=uniXoffsetIn;
                                %                             uniYoffset=uniYoffsetIn;
                                
                            else
                                [unicodes, index]=shuffle([unicodesIn unicodesIn unicodesIn]);
                                tmp=[unicodesSizesIn unicodesSizesIn unicodesSizesIn];
                                unicodesSizes=tmp(index);
                                tmp=[uniXoffsetIn uniXoffsetIn uniXoffsetIn];
                                uniXoffset=tmp(index);
                                tmp=[uniYoffsetIn uniYoffsetIn uniYoffsetIn];
                                uniYoffset=tmp(index);
                            end
                            uniAngles=floor(rand(ndots,1).*4).*90;     %ones(ndots,1).*45; %
                            for shapeCounter=1:ndots
                                Screen('glTranslate', display.windowPtr, dotGroup(shapeCounter,1)+display.Rect(1), dotGroup(shapeCounter,2)+display.Rect(2));
                                Screen('glRotate', display.windowPtr, uniAngles(shapeCounter));
                                Screen('TextSize', display.windowPtr, unicodesSizes(shapeCounter));
                                Screen('DrawText', display.windowPtr, unicodes(shapeCounter), -uniXoffset(shapeCounter), -uniYoffset(shapeCounter), double(dotColors(fixSeqAdder,:)));
                                Screen('glRotate', display.windowPtr, 0-uniAngles(shapeCounter));
                                Screen('glTranslate', display.windowPtr, -(dotGroup(shapeCounter,1)+display.Rect(1)), -(dotGroup(shapeCounter,2)+display.Rect(2)));
                            end
                            %Screen('DrawDots',display.windowPtr, double(dotGroup'), 8, [255 255 255], [display.Rect(1) display.Rect(2)],1);
                        elseif strcmp(params.experiment,'Numbers Size pRF full blanks TR=1.5, nTRs=3') 
                            %Screen('DrawDots',display.windowPtr, double(center'), double(dotSize), 255-double(dotColors(fixSeqAdder,:)), [display.Rect(1) display.Rect(2)],1);
                            if ndots>10
                                Screen('DrawText', display.windowPtr, num2str(ndots), double(center(1)+display.Rect(1)-dotSize*.8), double(center(2)+display.Rect(2)-dotSize*1.05), double(dotColors(fixSeqAdder,:)));
                            else
                                Screen('DrawText', display.windowPtr, num2str(ndots), double(center(1)+display.Rect(1)-dotSize*.4), double(center(2)+display.Rect(2)-dotSize*1.05), double(dotColors(fixSeqAdder,:)));
                            end
                        elseif strcmp(params.experiment,'Number Symbols pRF full blanks TR=2.1, nTRs=2')
                            if uint8(mod(winPos, 2))==1 && frame==1
                                oldLetterIndex=letterIndex;
                                while letterIndex==oldLetterIndex;
                                    letterIndex=ceil(rand*length(letterList));
                                end
                            end
                            if ndots<10
                                Screen('DrawText', display.windowPtr, num2str(ndots), double(center(1)+display.Rect(1)-dotSize*.4), double(center(2)+display.Rect(2)-dotSize*1.05), double(dotColors(fixSeqAdder,:)));
                            else
                                stimulus.letterSeq(fixSeqCounter)=letterIndex;
                                Screen('DrawText', display.windowPtr, letterList{letterIndex}, double(center(1)+display.Rect(1)-dotSize*.4), double(center(2)+display.Rect(2)-dotSize*1.05), double(dotColors(fixSeqAdder,:)));
                            end
                        elseif strcmp(params.experiment,'One Line Size Random Orientation pRF full blanks TR=2.1, nTRs=2')
                            Screen('DrawLines',display.windowPtr, [double(dotGroup')+[sin(lineDirection); cos(lineDirection)].*(dotSize/2) double(dotGroup')-[sin(lineDirection); cos(lineDirection)].*(dotSize/2)], double(3), double(dotColors(fixSeqAdder,:)), [display.Rect(1) display.Rect(2)],1);
                        else
                            if dotSize<=62
                                Screen('DrawDots',display.windowPtr, double(dotGroup'), double(dotSize), double(dotColors(fixSeqAdder,:)), [display.Rect(1) display.Rect(2)],1);
                            else
                                Screen('FillOval', display.windowPtr, double(dotColors(fixSeqAdder,:)), [display.Rect(1)+double(dotGroup(:,1)')-dotSize/2 display.Rect(2)+double(dotGroup(:,2)')-dotSize/2 display.Rect(1)+double(dotGroup(:,1)')+dotSize/2 display.Rect(2)+double(dotGroup(:,2)')+dotSize/2]);
                            end
                        end
                    elseif uint8(mod(frame,framesPerPattern)) <= framesPerPattern - grayFrames && mod(frame,framesPerPattern)> 0;
                        if strcmp(params.experiment,'Dots Shapes pRF full blanks TR=1.5, nTRs=3') || strcmp(params.experiment,'Dots Shapes pRF full blanks TR=2.1, nTRs=2')
                            %Screen('DrawDots',display.windowPtr, double(dotGroup'), 8, [255 255 255], [display.Rect(1) display.Rect(2)],1);
                            for shapeCounter=1:ndots
                                Screen('glTranslate', display.windowPtr, dotGroup(shapeCounter,1)+display.Rect(1), dotGroup(shapeCounter,2)+display.Rect(2));
                                Screen('glRotate', display.windowPtr, uniAngles(shapeCounter));
                                Screen('TextSize', display.windowPtr, unicodesSizes(shapeCounter));
                                Screen('DrawText', display.windowPtr, unicodes(shapeCounter), -uniXoffset(shapeCounter), -uniYoffset(shapeCounter), double(dotColors(fixSeqAdder,:)));
                                Screen('glRotate', display.windowPtr, 0-uniAngles(shapeCounter));
                                Screen('glTranslate', display.windowPtr, -(dotGroup(shapeCounter,1)+display.Rect(1)), -(dotGroup(shapeCounter,2)+display.Rect(2)));
                            end
                        elseif strcmp(params.experiment,'Numbers Size pRF full blanks TR=1.5, nTRs=3')
                            %Screen('DrawDots',display.windowPtr, double(center'), double(dotSize), 255-double(dotColors(fixSeqAdder,:)), [display.Rect(1) display.Rect(2)],1);
                            if ndots>10
                                Screen('DrawText', display.windowPtr, num2str(ndots), double(center(1)+display.Rect(1)-dotSize*.8), double(center(2)+display.Rect(2)-dotSize*1.05), double(dotColors(fixSeqAdder,:)));
                            else
                                Screen('DrawText', display.windowPtr, num2str(ndots), double(center(1)+display.Rect(1)-dotSize*.4), double(center(2)+display.Rect(2)-dotSize*1.05), double(dotColors(fixSeqAdder,:)));
                            end
                        elseif strcmp(params.experiment,'Number Symbols pRF full blanks TR=2.1, nTRs=2')
                            if ndots<10
                                Screen('DrawText', display.windowPtr, num2str(ndots), double(center(1)+display.Rect(1)-dotSize*.4), double(center(2)+display.Rect(2)-dotSize*1.05), double(dotColors(fixSeqAdder,:)));
                            else
                                Screen('DrawText', display.windowPtr, letterList{letterIndex}, double(center(1)+display.Rect(1)-dotSize*.4), double(center(2)+display.Rect(2)-dotSize*1.05), double(dotColors(fixSeqAdder,:)));
                            end
                        elseif strcmp(params.experiment,'One Line Size Random Orientation pRF full blanks TR=2.1, nTRs=2')
                            Screen('DrawLines',display.windowPtr, [double(dotGroup')+[sin(lineDirection); cos(lineDirection)].*(dotSize/2) double(dotGroup')-[sin(lineDirection); cos(lineDirection)].*(dotSize/2)], double(3), double(dotColors(fixSeqAdder,:)), [display.Rect(1) display.Rect(2)],1);
                        else
                            if dotSize<=62
                                Screen('DrawDots',display.windowPtr, double(dotGroup'), double(dotSize), double(dotColors(fixSeqAdder,:)), [display.Rect(1) display.Rect(2)],1);
                            else
                                Screen('FillOval', display.windowPtr, double(dotColors(fixSeqAdder,:)), [display.Rect(1)+double(dotGroup(:,1)')-dotSize/2 display.Rect(2)+double(dotGroup(:,2)')-dotSize/2 display.Rect(1)+double(dotGroup(:,1)')+dotSize/2 display.Rect(2)+double(dotGroup(:,2)')+dotSize/2]);
                            end
                        end
                    end
                    %stimulus.fixSeq(fixSeqCounter)=fixSeqAdder;
                end
            else
                if uint8(mod(frame,framesPerPattern))==1;
                    %fixSeqCounter=fixSeqCounter+1;
                    randTmp=rand(1);
                    if randTmp<oneBackFrequency && fixSeqAdder==1
                        fixSeqAdder=2;%3-fixSeqAdder;
                        %stimulus.fixSeq(fixSeqCounter)=fixSeqAdder;
                        colorEvents=[colorEvents GetSecs-t0];
                    else
                        fixSeqAdder=1;
                    end
                end
                if uint8(mod(frame,framesPerPattern)) <= framesPerPattern - grayFrames && mod(frame,framesPerPattern)> 0 && params.equalArea ==4;
                    Screen('FillRect', display.windowPtr, double(dotColors(fixSeqAdder,:)), rect );
                end
                %fixSeqCounter=fixSeqCounter+1;
                
                
                
                
                
                
                %                         if mod(frame,framesPerPattern)==1;
                %                             if strcmp(params.experiment, 'Dots Attention')
                %                                 dotGroup=newDotPattern(params, 7,n, dotSize, 2);
                %                                 Screen('DrawDots',display.windowPtr, double(dotGroup(1:ndots,:)'), double(dotSize), double([0 0 0]), [display.Rect(1) display.Rect(2)],1);
                %                                 Screen('DrawDots',display.windowPtr, double(dotGroup(ndots+1:end,:)'), double(dotSize), double([255 255 255]), [display.Rect(1) display.Rect(2)],1);
                %                             else
                %                                 dotGroup=newDotPattern(params, ndots,n, dotSize, 2);
                %                                 Screen('DrawDots',display.windowPtr, double(dotGroup'), double(dotSize), double(dotColors), [display.Rect(1) display.Rect(2)],1);
                %
                %                             end
                %                         elseif mod(frame,framesPerPattern) <= framesPerPattern - grayFrames && mod(frame,framesPerPattern)> 0;
                %                             if strcmp(params.experiment, 'Dots Attention')
                %                                 Screen('DrawDots',display.windowPtr, double(dotGroup(1:ndots,:)'), double(dotSize), double([0 0 0]), [display.Rect(1) display.Rect(2)],1);
                %                                 Screen('DrawDots',display.windowPtr, double(dotGroup(ndots+1:end,:)'), double(dotSize), double([255 255 255]), [display.Rect(1) display.Rect(2)],1);
                %                             else
                %                                 Screen('DrawDots',display.windowPtr, double(dotGroup'), double(dotSize), double(dotColors), [display.Rect(1) display.Rect(2)],1);
                %
                %                             end
                %                         else
                %                             %Screen('DrawDots',display.windowPtr, double(dotGroup'), double(dotSize), double(dotColors), [display.Rect(1) display.Rect(2)],1);
                %                             %Screen('DrawText', display.windowPtr, num2str(ndots), display.Rect(1)+(display.Rect(3)-display.Rect(1))/2-charWidth, display.Rect(2)+(display.Rect(4)-display.Rect(2))/2-charHeight, double(dotColors));
                %                         end
            end
            
        case 'numbers'
            fixSeqCounter=fixSeqCounter+1;
            if mod(frame,framesPerPattern)==1;
                fontNumberOld=fontNumber;
                randTmp=rand(1);
                if frame==1 || randTmp>oneBackFrequency
                    while fontNumberOld==fontNumber;
                        fontNumber=ceil(length(fontList)*rand(1));
                    end
                elseif randTmp<oneBackFrequency
                    fixSeqAdder=3-fixSeqAdder;
                end
                oldFontName=Screen('TextFont', display.windowPtr, fontList{fontNumber});
                Screen('DrawText', display.windowPtr, num2str(ndots), display.Rect(1)+(display.Rect(3)-display.Rect(1))/2-charWidth, display.Rect(2)+(display.Rect(4)-display.Rect(2))/2-charHeight, double(dotColors));
            elseif mod(frame,framesPerPattern) <= framesPerPattern - grayFrames && mod(frame,framesPerPattern)> 0;
                %                Screen('DrawDots',display.windowPtr, double(dotGroup'), double(dotSize), double(dotColors), [display.Rect(1) display.Rect(2)],1);
                Screen('DrawText', display.windowPtr, num2str(ndots), display.Rect(1)+(display.Rect(3)-display.Rect(1))/2-charWidth, display.Rect(2)+(display.Rect(4)-display.Rect(2))/2-charHeight, double(dotColors));
            else
                %Screen('DrawText', display.windowPtr, num2str(ndots), display.Rect(1)+(display.Rect(3)-display.Rect(1))/2-charWidth, display.Rect(2)+(display.Rect(4)-display.Rect(2))/2-charHeight, double(dotColors));
            end
            stimulus.fixSeq(fixSeqCounter)=fixSeqAdder;
            
        otherwise
            error('unknown option');
            %end
    end
    
    %Screen('DrawTexture', display.windowPtr, stimulus.textures(imgNum), stimulus.srcRect, stimulus.destRect);
    
    
    drawFixation(display,1);
    
    %CONTINUES WAITING UNTIL THE NEXT FRAME WHILE LOOKING FOR RESPONSES
    %AND OTHER INPUTS
    %waitTime =
    %(GetSecs-t0)-(stimulus.seqtiming(winPos)+(stimFrame*frame));
    waitTime = (GetSecs-t0)-(seqTiming(winPos+((cycle-1)*windowPositions))+(stimFrame*frame));
    %--- get inputs (subject or experimentor)
    if waitTime>0
        waitTime
    end
    while(waitTime<0),
        % Scan the UMC device for subject response
        [ssKeyCode,ssSecs] = deviceUMC('response_and_trigger',display.devices.UMCport);
        if ssKeyCode(1)==65 || ssKeyCode(1)==66 || ssKeyCode(1)==67 || ssKeyCode(1)==68
            %stimulus.fixResponse(fixSeqCounter)=2;
            responses=[responses GetSecs-t0];
        end;
        % scan the keyboard for experimentor input
        [exKeyIsDown exSecs exKeyCode] = KbCheck(display.devices.keyInputInternal);
        if(exKeyIsDown)
            if(exKeyCode(quitProgKey)),
                quitProg = 1;
                break;% out of while loop
            elseif(~exKeyCode(triggerKey))
%               elseif(exKeyIsDown)
                %stimulus.fixResponse(fixSeqCounter)=2;
                responses=[responses GetSecs-t0];
            end;
        end;
        
        % if there is time release cpu
        if(waitTime<-0.02),
            WaitSecs(0.01);
        end;
        
        % timing
        waitTime = (GetSecs-t0)-(seqTiming(winPos+((cycle-1)*windowPositions))+(stimFrame*frame));
    end;
    
    %--- stop?
    if quitProg,
        disp(sprintf('[%s]:Quit signal recieved.',mfilename));
        break;
    end;
    
    %DRAWS CONTENTS OF THE FRAME BUFFER TO THE DISPLAY
    Screen('Flip',display.windowPtr);
    
    %
    if isfield(stimulus, 'makeMovie') && stimulus.makeMovie==1 && ((winPos-1)*framesPerPosition)+frame<=recordingFrames;
%         if isfield(display, 'Rect')
%             imageArray=Screen('GetImage', display.windowPtr, display.Rect);
%         else
            imageArray=Screen('GetImage', display.windowPtr);
%        end
        writeVideo(aviobj,imageArray);
        if ((winPos-1)*framesPerPosition)+frame==recordingFrames
            close(aviobj);
        end
        
    end
end

function dotGroup=newDotPattern(params, ndots,n, dotSize, recheckDistance)
if ndots >0;
    recheckCounter=1000;
    while recheckCounter==1000
    for rdots = 1:ndots;
        tempDotPattern = rand(1,2)*n;
        if strcmp(params.experiment, 'Dots Gaussian')
            while sqrt((tempDotPattern(1,1)-0.5*n)^2+(tempDotPattern(1,2)-0.5*n)^2)>0.5*n-dotSize/2 || sqrt((tempDotPattern(1,1)-0.5*n)^2+(tempDotPattern(1,2)-0.5*n)^2)<0.125*n+dotSize/2
                tempDotPattern = rand(1,2)*n;
            end
        elseif dotSize>=n
            while sqrt((tempDotPattern(1,1)-0.5*n)^2+(tempDotPattern(1,2)-0.5*n)^2)>0.5*n
                tempDotPattern = rand(1,2)*n;
            end            
        else
            while sqrt((tempDotPattern(1,1)-0.5*n)^2+(tempDotPattern(1,2)-0.5*n)^2)>0.5*n-dotSize/2
                tempDotPattern = rand(1,2)*n;
            end
        end
        A = tempDotPattern(1,1);
        B = tempDotPattern(1,2);


        if rdots == 1;
            dotGroup = tempDotPattern;
            recheckCounter=1;
        else
            recheck = 1;
            recheckCounter=1;
            while recheck == 1;
                recheck = 0;
                for storedDots = 1:size(dotGroup,1);
                    if recheck == 0;
                        xDist = dotGroup(storedDots,1)-A;
                        yDist = dotGroup(storedDots,2)-B;
                        totalDist = sqrt(xDist^2 + yDist^2);
                        if totalDist < (dotSize * recheckDistance);
                            recheck = 1;
                        end
                    end
                end


                if recheck == 0;

                    dotGroup(rdots,1) = A;
                    dotGroup(rdots,2) = B;
                else
                    tempDotPattern = rand(1,2)*n;
                    if strcmp(params.experiment, 'Dots Gaussian')
                        while sqrt((tempDotPattern(1,1)-0.5*n)^2+(tempDotPattern(1,2)-0.5*n)^2)>0.5*n-dotSize/2 || sqrt((tempDotPattern(1,1)-0.5*n)^2+(tempDotPattern(1,2)-0.5*n)^2)<0.125*n+dotSize/2
                            tempDotPattern = rand(1,2)*n;
                        end
                    else
                        while sqrt((tempDotPattern(1,1)-0.5*n)^2+(tempDotPattern(1,2)-0.5*n)^2)>0.5*n-dotSize/2
                            tempDotPattern = rand(1,2)*n;
                        end

                    end
                    A = tempDotPattern(1,1);
                    B = tempDotPattern(1,2);
                    recheckCounter=recheckCounter+1;
                    if recheckCounter==1000
                        dotGroup(rdots,:)=dotGroup(rdots-1,:);
                        % Check whether there is an incorretc number of dots drawn
                        if params.devices.UMCport == -1
                            incorrectNumberDots(ndots, numel(dotGroup(:,1)));
                        end
                        break;
                    end
                end
            end
        end
    end
    end
else dotGroup = [];
end

end
