function [outputImg] = contrastScale(inputImg)
meanDif=0.5-mean(inputImg(:));
inputImg=inputImg+meanDif;

tmp=inputImg-0.5;
factor=max(abs(tmp(:)));

tmp=tmp./factor.*0.5;
outputImg=tmp+0.5;

end

