function results = conventionalComputation(handles)
%CONVENTIONALCOMPUTATION Computes 2D nerve kinematics with a for-loop.
%   handles = CONVENTIONALCOMPUTATION(handles)
%
%   See also: PARALLELCOMPUTATION, COMPUTE2DNERVEKINEMATICS.
%==========================================================================

% Assign variables from saved data for readability.
Ia  = handles.figure1.UserData.AdjustedImage;       % Image following button #2.
mmPerPix    = handles.figure1.UserData.MillimetersPerPixel;
scaling     = handles.figure1.UserData.FrameScaling;
nerveCrop	= handles.figure1.UserData.NerveCrop; 	% Original pos of box in nerve.
nerveMask	= handles.figure1.UserData.NerveMask;  	% Image data of ^.
boneCrop	= handles.figure1.UserData.BoneCrop;
boneMask	= handles.figure1.UserData.BoneMask;
correlationThreshold	= handles.edit_CorrelationThreshold.Value;
tic;

% Compute initial correlation matching between original and rounded crop.
corrScoreMN	= corrMatching(Ia,nerveMask,correlationThreshold);
corrScoreB	= corrMatching(Ia,boneMask,correlationThreshold);

% Find, plot the 1st location of centroid;
[nerveY0,nerveX0]	= find(corrScoreMN == max(corrScoreMN(:)));
[datumY0,datumX0]	= find(corrScoreB == max(corrScoreB(:)));
nerveX  = nerveX0;  nerveY  = nerveY0;              % Initial locations.
boneX	= datumX0;	boneY	= datumY0;
nerveXYshift= [nerveX nerveY]-nerveCrop(1:2);
boneXYshift	= [boneX boneY]-boneCrop(1:2);

% Ensure all frames of the ultrasound are in the same folder.
cd(handles.figure1.UserData.PathName);              % Original file location.
files	= dir('*.tif');                         	% All ultrasound frames.
numFiles= size(files,1);

% Initialize data variables for computation.
initData= zeros(numFiles,2);
data    = struct('NerveXY',initData,'BoneXY',initData,'RelativeXY',initData,...
    'MotionPath',initData,...                       % ^ in X-T coordinates.
    'AxialDisplacement',initData(1:end-1,:),...     % X,Y distances between centers.
    'LinearDistance',initData(1:end-1,1),...        % Pythagorean theorem of ^.
    'Velocity',[0; initData(1:end-1,1)],...         % Begin with zero velocity.
    'Acceleration',[0; initData(1:end-1,1)],...   	% Begin with zero accel.
    'XValues',(0:1:size(files,1)).*scaling);        % Graph x-values; [s/frame]*[frames] = [s]

% Seed tertiary axis for plotting velocity.
visibility = {'off','on'};
visibility = visibility{handles.figure1.UserData.DrawDecision+1};
set(handles.axis_PlotTrackingData,'visible',visibility);
plot(nerveX0-datumX0,nerveY0-datumY0,...
    'bo-','MarkerSize',2,'Parent',handles.axis_PlotTrackingData,'visible',visibility);
plot(0,0,'go-','MarkerSize',2,'Parent',handles.axis_PlotTrackingData,'visible',visibility);
handles.axis_PlotTrackingData.Children(2).XData(1)	= 0;
handles.axis_PlotTrackingData.Children(2).YData(1)  = 0;
plot(0,0,'ro-','MarkerSize',2,'Parent',handles.axis_PlotTrackingData,'visible',visibility);
handles.axis_PlotTrackingData.Children(3).XData(1)  = eps;
handles.axis_PlotTrackingData.Children(3).YData(1)  = eps;
set(handles.axis_PlotTrackingData.Children(1),'visible','on');
set(handles.axis_PlotTrackingData.Children(2:3),'visible','off');

% Compute new location and velocity between correlated position across frames.
jdx	= 1;                                            % Index for if-statement.
% wb  = waitbar(0,'Computing 2D Kinematic Data (0%)...');
for idx	= 1:numFiles
    nextFrameName	= files(idx).name;             	% Retrieve next frame.
    if strfind(nextFrameName,'.tif') > 0         	% All but original frame.
        % Plot next ultrasound frame on main axis.
        Inext	= imread([handles.figure1.UserData.PathName,nextFrameName]);
        [handles,Inext]	= overlayMaskAdjustments(handles,Inext);
        
        % Compute new location of each mask for nerve and bone, respectively.
        corrScoreMN	= corrMatching(Inext,nerveMask,correlationThreshold);
        corrScoreB	= corrMatching(Inext,boneMask,correlationThreshold);
        [nerveY,nerveX]	= find(corrScoreMN == max(corrScoreMN(:)));
        [boneY,boneX]	= find(corrScoreB == max(corrScoreB(:)));
        
        % Calculate x-y coordinate shift from previous bounding box of masks.
        nerveCrop(1:2)	= [nerveX-nerveXYshift(1), nerveY-nerveXYshift(2)];
        boneCrop(1:2)	= [boneX-boneXYshift(1), boneY-boneXYshift(2)];
        
        % Compute location, displacement, velocity, and acceleration.
        data.NerveXY(jdx,:)	= [nerveX,nerveY];
        data.BoneXY(jdx,:)	= [boneX,boneY];
        
        % Fix this
        data.RelativeXY(jdx,:)	= (data.NerveXY(jdx,:)-[datumX0 datumY0]);
        %         data.RelativeXY(jdx,:)	= data.NerveXY(jdx,:);
        
        
        
        
        
        
        data.MotionPath(jdx,:)	= data.RelativeXY(jdx,:).*mmPerPix;
        if idx > 1	% Can't compute without 2 data points.
            data.AxialDisplacement(idx-1,:)	= diff(data.MotionPath(idx-1:idx,:));
            data.LinearDistance(idx-1)  = hypot(data.AxialDisplacement(idx-1,1),...
                data.AxialDisplacement(idx-1,2));
            data.Velocity(idx)      = data.LinearDistance(idx-1)*scaling;
            data.Acceleration(idx)	= diff(data.Velocity(idx-1:idx));
        end
        
        % Update plots.
        handles = Plot2DNerveKinematics(handles,Inext,data,idx,...
            nerveX,nerveY,boneX,boneY,nerveMask,nerveCrop,boneMask,boneCrop);
        
        % Update cropped image, waitbar, loop-indexing.
        nerveMask	= imcrop(Inext,nerveCrop);   	% New mask of nerve.
        boneMask	= imcrop(Inext,boneCrop);   	% New mask of bone.
        %         waitbar(jdx/numFiles,wb);
        %         set(wb,'message',...
        %             ['Computing 2D Kinematic Data (',num2str(jdx*100/numFiles),'%)...']);
        jdx	= jdx + 1;                              % Update idx.
    end
end
toc
% delete(wb);

% Output total distances traveled in x,y planes.
results	= data;
end

%%% Seperate function for plotting results in real-time.
function handles = Plot2DNerveKinematics(handles,Inext,data,idx,...
        nerveX,nerveY,datumX,datumY,nerveMask,nerveCrop,boneMask,boneCrop)
%PLOT2DNERVEKINEMATICS updates gui plots of 2D kinementics and tracking.
%
%
%   See also: CONVENTIONALCOMPUTATION, COMPUTE2DNERVEKINEMATICS.
%==========================================================================

% Plot next ultrasound frame on main axis.
imshow(Inext,'Parent',handles.axis_PlotUltrasoundImage);
set(handles.axis_PlotUltrasoundImage.Title,'Interpreter','None',...
    'string',['Carpal Tunnel Ultrasound: ',...
    handles.figure1.UserData.FileName(1:end-4),' Frame #',num2str(idx)],...
    'FontWeight','bold','FontName','Open Sans','FontSize',12);

% Bring text labels to front of axis children.
% uistack(findobj(handles.axis_PlotUltrasoundImage,'type','text'),'bottom');
handles	= showCropLabels(handles);


% Update plot values second (bottom) axis.
if idx == 1                                         % Position X,Y data.
    handles.axis_PlotTrackingData.Children(1).XData	= data.MotionPath(idx,1);
    handles.axis_PlotTrackingData.Children(1).YData = data.MotionPath(idx,2);
else
    handles.axis_PlotTrackingData.Children(1).XData =...
        [handles.axis_PlotTrackingData.Children(1).XData, data.MotionPath(idx,1)];
    handles.axis_PlotTrackingData.Children(1).YData =...
        [handles.axis_PlotTrackingData.Children(1).YData, data.MotionPath(idx,2)];
end
handles.axis_PlotTrackingData.Children(2).XData	=...% Velocity X data.
    [handles.axis_PlotTrackingData.Children(2).XData, data.XValues(idx)];
handles.axis_PlotTrackingData.Children(2).YData =...% Velocity Y data.
    [handles.axis_PlotTrackingData.Children(2).YData, data.Velocity(idx)];
handles.axis_PlotTrackingData.Children(3).XData =...% Accel. X data.
    [handles.axis_PlotTrackingData.Children(3).XData, data.XValues(idx)];
handles.axis_PlotTrackingData.Children(3).YData =...% Accel. Y data.
    [handles.axis_PlotTrackingData.Children(3).YData, data.Acceleration(idx)];
if handles.figure1.UserData.DrawDecision == 1
    drawnow;
end

% Plot new location of nerve and bone crops.
iterStr = num2str(idx);
rectangle('Parent',handles.axis_PlotUltrasoundImage,...
    'Position',nerveCrop,'EdgeColor','r',...
    'LineStyle',':','tag',['Nerve Box, iter: ',iterStr],...
    'visible',handles.button_BoundingBoxDisplay.UserData);
rectangle('Parent',handles.axis_PlotUltrasoundImage,...
    'Position',boneCrop,'EdgeColor','g',...
    'LineStyle',':','tag',['Bone Box, iter: ',iterStr],...
    'visible',handles.button_BoundingBoxDisplay.UserData);
plot(nerveX,nerveY,'r*',...
    'visible',handles.button_CurrentLocationDisplay.UserData);
plot(datumX,datumY,'g*',...
    'visible',handles.button_CurrentLocationDisplay.UserData);
if strcmpi(handles.button_PreviousLocationsDisplay.UserData,'off')
    lineInPlot  = findobj(handles.axis_PlotUltrasoundImage,'type','line');
    recInPlot	= findobj(handles.axis_PlotUltrasoundImage,'type','rectangle');
    set([lineInPlot(1:end-2); recInPlot(1:end-2)],'visible','off');
end
if handles.figure1.UserData.DrawDecision == 1
    drawnow;
end

% Update cropped image.
imshow(nerveMask,'Parent',handles.axis_PlotCroppedImage);
set(handles.axis_PlotCroppedImage.Title,'Interpreter','None','string',...
    'Mask of Median Nerve','FontWeight','bold','FontName','Open Sans','FontSize',12);
end

