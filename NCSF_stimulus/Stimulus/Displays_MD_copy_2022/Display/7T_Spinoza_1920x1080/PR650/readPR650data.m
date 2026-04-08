function readPR650data(filenames,nMeasurements)
% arrange files in red-green-blue order

intensity = zeros( 101, length(filenames) );

for i = 1:length(filenames)
    [lambda intensityTemp] = readPR650file(filenames{i});
    intensity(:,i) = intensityTemp';
end

if length(filenames) == 3
    out = intensity;
else
    intensityTemp = reshape(intensity,size(intensity,1),3,nMeasurements);
    out = mean(intensityTemp,3);
end

figure(1);clf;
plot(lambda',out(:,1) / max(out(:,2)),'--r'); hold on
plot(lambda',out(:,2) / max(out(:,2)),'--g'); hold on
plot(lambda',out(:,3) / max(out(:,2)),'--b'); hold on

%d = xlsread('Utrecht-color-calib_final_1.xls')

%plot( d(:,1),d(:,[4 3 2]) / max(d(:,3)) );


% interpolate data
monitorSpectra = [];
for n=1:3
    monitorSpectra(:,n) = interpPR650( [ lambda' out(:,n) ] );
end
monitorSpectra(:,4) = sum(monitorSpectra(:,[1:3]),2);


%save data
save('spectra','monitorSpectra')



function [lambda intensity] = readPR650file(filename)

fid = fopen(filename);

tline = fgetl(fid);
outLine = [];
while ischar(tline)    
    tline = fgetl(fid);
    if strfind(tline,'Corrected Spectral Radiance')
        while ischar(tline)
            tline = fgetl(fid);
            outLine = [ outLine, tline ];
            
        end
    end
end

fclose(fid);

outLine = str2num(outLine);
indexLambda = 1:2:length(outLine);
indexIntensity = indexLambda + 1;
lambda = outLine( indexLambda );
intensity = outLine( indexIntensity );

[lambda, indx] = sort(lambda);
intensity = intensity(indx);

end

end
