function images=loadProcessedImages(path, dimension)

if ~exist('path', 'var') 
    path=pwd;
end

files=dir(path);

filesbcounter=0;
for j=1:length(files)
    if length(files(j).name)>4
        filesbcounter=filesbcounter+1;
        filesb(filesbcounter, 1)=files(j);
    end
end

files=filesb;

secondImageContrast=0.8;

for i=1:length(files)
    images(i).filename=strcat(path, '/', files(i).name);
    readimage=imread(images(i).filename);
    images(i).filename=files(i).name;
    images(i).circleimage1=imresize(readimage, [dimension dimension]);
    images(i).circleimage2=(images(i).circleimage1-128)*secondImageContrast+128;
end
return