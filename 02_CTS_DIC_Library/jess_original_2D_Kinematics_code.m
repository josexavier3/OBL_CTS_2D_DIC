clear, close all

rate=123;       %Frame rate in Hz
scaling=1/123;  %seconds/frame


[FileName,PathName] = uigetfile('*.tif','Open the FIRST ultrasound movie frame');
if isequal(FileName,0)|isequal(PathName,0)          %Make sure the file exists
    disp('File not found')
end
% mov=aviread([PathName,FileName]);


pic=imread([PathName,FileName]);
figure, imshow(pic),title('Select a region in the nerve')
[im,rect]=imcrop;
title('Click 2 points a 1cm apart')
[x,y,c]=impixel;
pixpermm=sqrt((x(1)-x(2))^2+(y(1)-y(2))^2)/10;
mmperpix=1/pixpermm;

rect=round(rect);
mask=imcrop(pic,rect);
hold on, rectangle('Position', rect,'EdgeColor','r')
[corrScore, boundingBox] = corrMatching(pic, mask, .5);
[foundr,foundc]=find(corrScore==max(max(corrScore)));
plot(foundc,foundr,'*y')
offsetr=foundr-rect(2);
offsetc=foundc-rect(1);
close

cd(PathName)
files=dir;
cd('..')

counter=1;
for zz=1:size(files,1)
    filename=files(zz).name;
    if strfind(filename,'.tif')>0
        nextpic=imread([PathName,filename]);
%         nextpic=rgb2gray(nextpic);
        h=figure; 
        imshow(nextpic)

        [corrScore, boundingBox] = corrMatching(nextpic, mask, .5);
        [cent_matchr(counter),cent_matchc(counter)]=find(corrScore==max(max(corrScore)));
        hold on, plot(cent_matchc,cent_matchr,'*y')
        rect=[cent_matchc(counter)-offsetc,cent_matchr(counter)-offsetr,rect(3),rect(4)];
        hold on,rectangle('Position', rect,'EdgeColor','r')
        mask=imcrop(nextpic,rect);
        counter=counter+1;
        saveas(gcf,[strtok(filename,'.'),'_Tracked.tif'])
        close
    end
end
cent_matchc=cent_matchc*mmperpix;
cent_matchr=cent_matchr*mmperpix;
figure, plot(cent_matchc,cent_matchr), axis equal
title('xy Motion Path')

motionpath=[cent_matchc',cent_matchr'];


distprev=diff(motionpath);
dists=sqrt(distprev(:,1).^2+distprev(:,2).^2);
velocity=dists*scaling;
xvals=scaling*(1:size(velocity,1));
figure, plot(xvals,velocity)
title('Velocity Magnitude')
xlabel('Time (sec)')
ylabel('Velocity (mm/sec)')


counter=1;
for zz=1:size(files,1)
    filename=files(zz).name;
    if strfind(filename,'.tif')>0
        nextpic=imread([PathName,filename]);
        figure,
        subplot(2,1,1),imshow(nextpic)
        subplot(2,1,2),plot(xvals,velocity)
        hold on, plot(xvals(counter),velocity(counter),'.r')

        counter=counter+1;
        saveas(gcf,[strtok(filename,'.'),'_Velocity.tif'])
        close
    end
end




