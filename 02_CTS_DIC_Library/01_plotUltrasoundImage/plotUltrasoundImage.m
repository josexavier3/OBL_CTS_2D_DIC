function handles	= plotUltrasoundImage(handles)
%PLOTULTRASOUNDIMAGE Identifies and plots ultrasound image in mainGUI.
%   handles = PLOTULTRASOUNDIMAGE(handles) returns all handles of mainGUI
%   following the input of an initial ultrasound image for analysis.
%   
%   See also: MAINGUI, IDENTIFYIMAGEREFERENCES, COMPUTE2DNERVEKINEMATICS,
%   BEGINDIGITALIMAGECORRELATION.
%==========================================================================

% Retrieve file for first frame of ultrasound movie; Make sure file exists.
[FN,PN]	= uigetfile('*.tif','Select 1st ultrasound movie frame (.tif)');
cd(PN);                                             % Quicker file search.
attempt	= 1;
while (isequal(FN,0) || isequal(PN,0)) && attempt < 3
    uiwait(warndlg('File not found; Select a new image.','File Not Found'));
    [FN,PN]	= uigetfile('*.tif','Select 1st ultrasound movie frame');
    attempt	= attempt + 1;                          % Terminate after 3 attempts.
end

% Plot Carpal Tunnel Ultrasound, give title.
I0	= imread([PN,FN]);
imshow(I0,'parent',handles.axis_PlotUltrasoundImage);
set(get(gca,'children'),'tag','Initial Ultrasound Image');
set(handles.axis_PlotUltrasoundImage.Title,'Interpreter','None',...
    'string',['Carpal Tunnel Ultrasound: ',FN(1:end-4)],...
    'FontWeight','bold','FontName','Open Sans','FontSize',14);
set(handles.axis_PlotUltrasoundImage,'visible','off','NextPlot','add');

% Assign data to Figure 1's UserData.
handles.figure1.UserData.OriginalImage	= I0;
handles.figure1.UserData.FileName	= FN;
handles.figure1.UserData.PathName   = PN;

% Allow visibility and use of the image contrast option.
set(handles.panel_AdjustImageContrast,'visible','on');
set(handles.text_CroppingMechanism,'visible','on');
set(handles.list_AdjustImageContrastOptions,'visible','on');
set(handles.button_Go,'visible','on');
