%%% Messing around w image stuff.


% F = getframe(gca);
% image = frame2im(F);
% imwrite(image,'ultrasound_frame.png');

% Read image.
imLibrary = 'R:\Ortho-Biomechanics\Dominik\CTS_DIC_Working_Folder\00_Test_Case_Ultrasounds';
% imStr   = [imLibrary,'\02_Specific_Aim_2_Healthy Patients\2B_01\Right_03_FCA\050'];
imStr	= [imLibrary,'\02_Specific_Aim_2_Healthy Patients\2B_10_MC\Right_03_FCA\237'];
[I,cmap]	= imread([imStr,'.tif']);
I2D	= rgb2gray(I);
bw  = imbinarize(I2D);

%% Find borders of ultrasound image via empirically-based heuristics.
figure(1);  imshow(I2D);
bw  = imbinarize(I2D);                              % Binary image.
dim	= size(bw);
middleCol   = ceil(dim(2)/2);

% Find the rows containing the upper (blue) band of the frame.
rBlue	= find(bw(:,1) == 0,1,'first');             % End of band.

% Find the top line of the transducer output.
[rTO,~]	= find(bw(rBlue:end,middleCol) == 1,1,'first');
rTop    = rBlue + rTO - 1;

% Empirically determined that the left corner extends -
Ia  = imadjust(I2D);
bwIa= imbinarize(Ia);
Is  = imsharpen(Ia);
bwIs= imbinarize(Is);


%% Active contour stuff.
mask = ones(size(I2D));
% mask(57:end-20,10:end-10) = 1;
figure(1); imshow(I);
bw  = activecontour(I2D,mask,1000,'edge');
hold on;visboundaries(bw,'color','r');


%% Adjust image intensity values/colormap.
close all; figure(2);
subplot(1,2,1);imshow(I);
subplot(1,2,2);imshow(Ia); % Enhances the actual ultrasound and removes top line?

%% Sharpen image.
Is  = imsharpen(I);
close all; figure(2);

subplot(1,2,1);imshow(I);
subplot(1,2,2);imshow(Is); % Does nothing but removes top line?

%% Boundaries in image.
Ibin	= imbinarize(I2D);
dim	= size(Ibin);
col	= round(dim(2)/2 - 90);
row = min(find(Ibin(:,col)));
boundary    = bwtraceboundary(Ibin,[row,col],'N');  % N specifies "North".
[B,L]   = bwboundaries(Ibin);
colors  = {'r',[1 0 1],'y','g','c','b','m'};
figure(3);
imshow(I);  hold on;
ch =bwconvhull(Ibin);
figure; subplot(1,2,1);imshow(Ibin);subplot(1,2,2);imshow(ch);
color_idx	= 1;
for idx = 1:length(B)
    boundary = B{idx};
    plot(boundary(:,2),boundary(:,1),'color',colors{color_idx},'linewidth',3);
    color_idx = color_idx + 1;
    if color_idx > length(colors)
        color_idx	= 1;
    end
end

%% Edges of image.
[e1,threshold1]	= edge(I2D,'prewitt');
% [e2,threshold2]	= edge(I2D,'canny');
close all; figure(3);
% subplot(1,2,1);
imshow(e1,[]),title('prewitt');
% subplot(1,2,2);
% imshow(e2,[]),title('canny');

% Find [x,y] of edge with the most common x-coordinates (this should be the top line)?
[y,x]	= find(e1);                                	% [x,y] coords of edge.
[m,f]	= mode(y);                              	% Most common y-coord.
ix	= find(ismember(y,m));                          % Index m to x (and y).
% subplot(1,2,1);
hold on;
plot(x(ix),repmat(m,f),'r*');                       % Prove it.

% Looks like I need to find the most-left and most-right x-coords of points
% that are all within the most-common-distance of each other.
xdist   = diff(x(ix));                              % Dist between x-coords.
changeDist  = find(diff(xdist))+1;
[~,ilongestConsec]   = max(diff(changeDist));
longestConsec	= changeDist(ilongestConsec:ilongestConsec+1);
hold on;
plot(x(ix(longestConsec(1))),m,'g*');               % Plot left-most x-coord of line.
plot(x(ix(longestConsec(2))),m,'b*');               % Plot rght-most x-coord of line.
xyTopLeft	= [x(ix(longestConsec(1))),m];          % Top left of image is (0,0).
xyTopRight  = [x(ix(longestConsec(2))),m];
xyBottomLeft	= [x(ix(longestConsec(1))),m+1];
xyBottomRight	= [x(ix(longestConsec(2))),m+1];
pos	= [xyBottomLeft(1) xyBottomLeft(2) xyBottomRight(1)-xyBottomLeft(1) 425];
figure(3);  cla;    imshow(e1,[]),title('prewitt'); imshow(I);
R = rectangle('position',pos,'EdgeColor','r');
Icrop   = imcrop(I,pos);
Iadj    = histeq(Icrop);
figure(3);  cla;
subplot(1,2,1); orig	= imshow(I);  title('original');   hold on;
subplot(1,2,2);	crop    = imshow(Icrop);  title('cropped');
pause
subplot(1,2,1); overlay	= imshow(Iadj,'XData',[pos(1) pos(1)+pos(3)],'YData',[pos(2) pos(2)+pos(4)]);

%% Manual impoly cropping.
%%% Checkout impoly for cropping an image.
pCrop   = impoly(gca);                              % Draw polygon.
position    = wat(pCrop);                          % Wait for ^.
pos	= getPosition(pCrop);                           % [X,Y] of verts.
BW  = createMask(pCrop);
figure;imshow(BW);


%% Histogram of pixels
counts = imhist(I2D,100);
close all;  figure(4);imshow(counts);

%% Gradient of pixels.
[Bx,Gy]	= imgradientxy(I2D);
[Gmag, Gdir] = imgradient(I2D,'prewitt');
close all;  figure(5);
subplot(1,2,1); imshow(Gmag, []), title('Gradient magnitude')
subplot(1,2,2); imshow(Gdir, []), title('Gradient direction')
    
%% 
% Detect corners in image.
% Icorners	= detectHarrisFeatures(I2D);
% Icorners	= detectBRISKFeatures(I2D);
% Icorners	= detectFASTFeatures(I2D);
% Icorners	= detectMinEigenFeatures(I2D);
Icorners	= detectSURFFeatures(I2D);      % Probably the best one
 
bestCorners = Icorners.selectStrongest(50);
 
% Show results.
figure;
subplot(1,2,1); imshow(I);
subplot(1,2,2); imshow(I);  hold on;    plot(bestCorners); 
Icorners    = detectMSERFeatures(I2D);
 plot(Icorners, 'showPixelList', true, 'showEllipses', false)
