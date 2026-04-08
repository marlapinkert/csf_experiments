function images=displayFolderImages(path)

if ~exist('path', 'var') 
    path=pwd;
end

files=dir(path);

circlemask=makecircle(190, 321, 32);

for i=3:length(files)
    images(i-2).filename=strcat(path, '/', files(i).name);
    images(i-2).image=imread(images(i-2).filename);
    dimensions=size(images(i-2).image);
    %resize image to fit circle matrix
    if dimensions(2)>dimensions(1) %images in lanscape aspect
        if dimensions(1)~= 321
            images(i-2).image=imresize(images(i-2).image, [321 NaN]);
        end
    else
        if dimensions(2)~=321
            images(i-2).image=imresize(images(i-2).image, [NaN 321]);
        end
    end
    images(i-2).grayscale=single(rgb2gray(images(i-2).image)); 
    dimensions=size(images(i-2).image);
    segline=zeros(dimensions(1), dimensions(2));
    
    segname=files(i).name(1:length(files(i).name)-4);
    segnameb=strcat('/home/benharvey/matlab/Ben/Berkeley Segmentation/Segmentations/gray/AllGray1/', segname, '.seg');
    segpresent=fopen(segnameb);

    
    if segpresent>0
        for k=1:5
            %Determine file name and check file exits (fifth segmentation does
            %not exist for a few images
            segfile=strcat('/home/benharvey/matlab/Ben/Berkeley Segmentation/Segmentations/gray/AllGray', int2str(k),'/', segname, '.seg');
            fid=fopen(segfile);
            seg=dlmread(segfile, ' ', 11, 0);
            if fid==-1
                break
            end
            fclose(fid);
            %Initialize output image array and filith different colours for
            %each segment
            segview=zeros(max(seg(:,2))+1,max(seg(:,4))+1, 'single');
            l=length(seg);
            segmultiplier=single(255/max(seg(:,1)));
            for j=1:l;
                if seg(j,2)==0;
                    seg(j,2)=1;
                end
                if seg(j,3)==0;
                    seg(j,3)=1;
                end
                segview(seg(j,2),seg(j,3):seg(j,4))=single(segmultiplier*seg(j,1));
            end
            
            %Find bordersbetween segmetns and colour white  in a new black
            %image (segline). Sum lines for each human segmentation
            for x=1:max(seg(:,2))-1;
                for y=1:max(seg(:,4))-1;
                    if segview(x,y)~=segview(x,y+1);
                        segline(x,y)=single(segline(x,y)+1);
                    elseif segview(x,y)~=segview(x+1,y);
                        segline(x,y)=single(segline(x,y)+1);
                    end
                end
            end
        end
        images(i-2).inputseg=segline.*51;
    else
        [mean, segline, avesd]=LocalStat(images(i-2).grayscale, 1);
        images(i-2).inputseg=(segline./max(max(segline))).*255;
    end
    
    segtmp=images(i-2).inputseg./510;
    
    segsum=0;
    segsumindex=0;
    
    if dimensions(2)>dimensions(1);
        for j=0:dimensions(2)-dimensions(1)
            %calculate circle image * segmentation sd image
            circlemaskrect=horzcat(zeros(321,j, 'single'), circlemask, zeros(321,160-j, 'single'));
            tmp=segtmp.*circlemaskrect;
            %if this circle position has the highest contrast yet (highest
            %level of segmented image features), save it and the position
            %of the circle centre
            if sum(sum(tmp+0.5))>segsum
                segsum=sum(sum(tmp+0.5));
                segsumindex=j+161;
                bestcirclemask=circlemaskrect;
                circimage=tmp+0.5;
            end
        end
        
        bii=bestcirclemask==1;
        centrex=single(segsumindex);
        centrey=single(161);
        meaner=images(i-2).grayscale(bii);
        meaner=sum(meaner)/length(meaner);
        circleimage=single((((1-images(i-2).grayscale).*(0.5/(1-meaner)))-0.5).*bestcirclemask+0.5);
        images(i-2).circleimage=circleimage(:, centrex-160:centrex+160).*256;
    elseif dimensions(1)>dimensions(2);
        for j=0:dimensions(1)-dimensions(2)
            %calculate circle image * segmentation sd image
            circlemaskrect=vertcat(zeros(j,321, 'single'), circlemask, zeros(160-j,321, 'single'));
            tmp=segtmp.*circlemaskrect;
            %if this circle position has the highest contrast yet (highest
            %level of segmented image features), save it and the position
            %of the circle centre

            if sum(sum(tmp+0.5))>segsum
                segsum=sum(sum(tmp+0.5));
                segsumindex=j+161;
                bestcirclemask=circlemaskrect;
                circimage=tmp+0.5;
            end
        end
        
        bii=bestcirclemask==1;
        centrex=single(161);
        centrey=single(segsumindex);
        meaner=images(i-2).grayscale(bii);
        meaner=sum(meaner)/length(meaner);
        circleimage=single((((1-images(i-2).grayscale).*(0.5/(1-meaner)))-0.5).*bestcirclemask+0.5);
        images(i-2).circleimage=circleimage(centrey-160:centrey+160, :).*256;
    elseif dimensions(2)==dimensions(1)
        bii=circlemask==1;
        meaner=images(i-2).grayscale(bii);
        meaner=sum(meaner)/length(meaner);
        circleimage=single((((1-images(i-2).grayscale).*(0.5/(1-meaner)))-0.5).*circlemask+0.5);
        images(i-2).circleimage=circleimage(centrey-160:centrey+160, :).*256;
        
    end 
    imwrite(images(i-2).circleimage, gray(256), strcat(path, '/X', files(i).name), 'jpg', 'Bitdepth', 8);
    
end
return

