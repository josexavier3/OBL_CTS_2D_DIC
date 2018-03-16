function handles	= identifyImageReferences(handles)
%IDENTIFYIMAGEREFERENCES Identify, crop section of median nerve.
%   handle] = IDENTIFYIMAGEREFERENCES(handles) returns all handles of
%   mainGUI following the identification of the median nerve and a carpal
%   bone.
%
%   See also: MAINGUI, PLOTULTRASOUNDIMAGE, COMPUTE2DNERVEKINEMATICS,
%   BEGINDIGITALIMAGECORRELATION.
%==========================================================================

% Prompt dialog for cropping a box within the median nerve.
msg1	= sprintf('Box a region within the median nerve.\n           Double-click to confirm.');
uiwait(msgbox(msg1,'Crop Nerve','modal'));
[~,nerveCrop]	= imcrop(handles.figure1.UserData.AdjustedImage);

% Overlay original crop with a red box and it's centroid.
handles.figure1.UserData.NerveCrop	= round(nerveCrop);
handles.figure1.UserData.NerveMask	= imcrop(...    % Mask of Nerve box.
    handles.figure1.UserData.AdjustedImage,handles.figure1.UserData.NerveCrop);
hold on;
handles.figure1.UserData.NerveLabel	= text('Position',[5 10 0],...
    'String','Median Nerve','FontSize',15,'Color','r','FontWeight','bold');
handles.figure1.UserData.NervePreviousLocations	=...
    [handles.figure1.UserData.NervePreviousLocations;...
    rectangle('Position',handles.figure1.UserData.NerveCrop,...
    'EdgeColor','r','LineStyle',':','tag','Original Nerve Box')];

% Show cropped nerve region in secondary axis.
set(handles.axis_PlotCroppedImage,'visible','on');  % Show 2ndary axis.
imshow(handles.figure1.UserData.NerveMask,'Parent',handles.axis_PlotCroppedImage);
set(handles.axis_PlotCroppedImage.Title,'Interpreter','None','string',...
    'Mask of Median Nerve','FontWeight','bold','FontName','Open Sans','FontSize',14);

% Prompt dialog for identifying a carpal bone.
msg2    = sprintf('Box a region completely around the carpal bone.\n           Double-click to confirm.');
uiwait(msgbox(msg2,'Crop Bone','modal'));
[~,boneCrop]	= imcrop(handles.figure1.UserData.AdjustedImage);
handles.figure1.UserData.BoneCrop	= round(boneCrop);
handles.figure1.UserData.BoneMask	= imcrop(...    % Mask of Bone box.
    handles.figure1.UserData.AdjustedImage,boneCrop);
handles.figure1.UserData.BoneLabel	= text('Position',[5 30 0],...
    'String','Carpal Bone','FontSize',15,'Color','g','FontWeight','bold');
handles.figure1.UserData.BonePreviousLocations	=...
    [handles.figure1.UserData.BonePreviousLocations;...
    rectangle('Position',handles.figure1.UserData.BoneCrop,...
    'EdgeColor','g','LineStyle',':','tag','Original Bone Box');];

