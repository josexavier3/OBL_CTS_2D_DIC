function varargout = mainGUI(varargin)
%MAINGUI MATLAB code for mainGUI.fig
%	MAINGUI, by itself, creates a new MAINGUI or raises the existing
%	singleton*.
%
%	H = MAINGUI returns the handle to a new MAINGUI or the handle to the
% 	existing singleton*.
%
% 	MAINGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%	function named CALLBACK in MAINGUI.M with the given input arguments.
%
% 	MAINGUI('Property','Value',...) creates a new MAINGUI or raises the
%	existing singleton*.  Starting from the left, property value pairs are
%	applied to the GUI before mainGUI_OpeningFcn gets called. An
%	unrecognized property name or invalid value makes property application
% 	stop. All inputs are passed to mainGUI_OpeningFcn via varargin.
%
% 	*See GUI Options on GUIDE's Tools menu. Choose "GUI allows only one
% 	instance to run (singleton)".
%
%	See also: MAIN, GUIDE, GUIDATA, GUIHANDLES
%==========================================================================

%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
%-----------------Begin initialization code - DO NOT EDIT------------------
gui_Singleton = 1;
gui_State = struct('gui_Name',mfilename,...
    'gui_Singleton',gui_Singleton,...
    'gui_OpeningFcn',@mainGUI_OpeningFcn,...
    'gui_OutputFcn',@mainGUI_OutputFcn,...
    'gui_LayoutFcn',[],...
    'gui_Callback',[]);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
%------------------End initialization code - DO NOT EDIT-------------------
end

%% --------------------GUI Output and Initialization-----------------------
% --- Outputs from this function are returned to the command line.
function varargout = mainGUI_OutputFcn(hObject,~,handles) %#ok<*INUSL>
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

varargout{1}    = handles.output;

% Ask to show plots in seperate figure.
end

% --- Executes just before mainGUI is made visible.
function mainGUI_OpeningFcn(hObject,~,handles,varargin)
%	This function has no output args, see OutputFcn.
%	varargin	- command line arguments to mainGUI (see VARARGIN).

% Choose default command line output for mainGUI.
handles.output = hObject;
handles = orderfields(handles);

% Update handles structure.
guidata(hObject,handles);

% Open parallel pool for computation.
% parpool(2); delete(gcp);

% Should create a struct in userdata of handles.figure1 that contains all
% GUI button handles so that when you click the same button twice without
% finishing the previous attempt, it doesn't bug out and require a gui relaunch.

% Additionally, need to create something that makes all seceeding
% buttons/lists/panels/axis invisible in one go.

% Set figure properties, e.g. figure is full screen, named.
set(0,'DefaultFigureWindowStyle','normal');         % Do not try to dock GUI.
set(handles.figure1,'name','Carpal Tunnel Syndrome - Digital Image Correlation',...
    'units','normalized','innerposition',[0.1 0.1 0.85 0.85]);
set(handles.figure1,'UserData',struct('PathName',[],'FileName',[],...
    'OriginalImage',[],'ContrastMask',[],'AdjustedImage',[],'CurrentImage',[],...
    'FrameScaling',1/123,'MillimetersPerPixel',[],'CorrelationThreshold',0.50,...
    'NerveLabel',[],'NerveMask',[],'NerveCrop',[],...
    'NervePreviousLocations',[],'NerveCurrentLocation',@setNerveCurrentLocation,...
    'BoneLabel',[],'BoneMask',[],'BoneCrop',[],...
    'BonePreviousLocations',[],'BoneCurrentLocation',@setBoneCurrentLocation,...
    'DrawDecision',true,'OutputData',[]));
drawDecision = questdlg('Update plot in real-time?','Draw Decision','yes','no','yes');
if strcmpi(drawDecision,'yes')
    handles.figure1.UserData.DrawDecision	= 1;
else
    handles.figure1.UserData.DrawDecision	= 0;
end

    function handles = setNerveCurrentLocation(handles)
        handles.figure1.UserData.NerveCurrentLocation   =...
            handles.figure1.UserData.NervePreviousLocations(end);
    end
    function handles = setBoneCurrentLocation(handles)
        handles.figure1.UserData.setBoneCurrentLocation   =...
            handles.figure1.UserData.BonePreviousLocations(end);
    end
end

% -- Executes when called within mainGUI.
function setGUIVisibility(handles,progress)
%SETGUIVISIBILITY Set visibility of GUI axes, lists, panels, and buttons.
%   SETGUIVISIBILITY(handles,progress) will turn item(s)' visible property
%   to "off", depending on the input of progress.
%
%   See also: MAINGUI.
%==========================================================================

clc;                                               % Clear command window of annoying shit.
invisibleO = [];
deleteO	= [];
switch progress
    case 1	% Clear all plots.
        if ~isempty(handles.axis_PlotUltrasoundImage.Children)
            [invisibleO,deleteO] = resetToButton1;
        end
        
    case 2	% Clear all but original in main.
        if ~isempty(handles.axis_PlotCroppedImage.Children)
            [invisibleO,deleteO] = resetToButton2;
        end
        
    case 3  % Clear all of tertiary, reset secondary and main to case 2.
        if ~isempty(handles.axis_PlotTrackingData.Children)
            [invisibleO,deleteO] = resetToButton3;
        end
        
    case 4  % Clear/close external plots.
        errordlg('don''t have this visibility reset coded yet');
end

% Set off-visibile, delete specified handles.
try
    set(invisibleO,'visible','off');
catch
    % Nothing.
end
try
    delete(deleteO);
catch
    % Nothing.
end

    function [invisibleO,deleteO] = resetToButton1      % On push of Button 1.
        % Reset all.
        invisibleO = [handles.axis_PlotCroppedImage; handles.axis_PlotTrackingData;...
            handles.button_BeginDigitalImageCorrelation; handles.button_Compute2DNerveKinematics;...
            handles.button_Go; handles.button_IdentifyImageReferences;...
            handles.list_AdjustImageContrastOptions; handles.list_SelectTrackingData;...
            handles.panel_AdjustCorrelationThreshold; handles.panel_AdjustImageContrast;...
            handles.panel_DisplaySettings; handles.text_CroppingMechanism;...
            handles.text_Threshold; handles.text_TrackingData];
        deleteO = [handles.axis_PlotUltrasoundImage.Children(:);...
            handles.axis_PlotCroppedImage.Children(:);...
            handles.axis_PlotTrackingData.Children(:)
            handles.axis_PlotCroppedImage.Title];
    end

    function [invisibleO,deleteO] = resetToButton2      % On push of Button 2.
        % Reset to Button 3.
        [invisibleO,deleteO] = resetToButton3;
        
        % Reset main axis to Go button.
        deleteO  = [deleteO; handles.axis_PlotUltrasoundImage.Children(setdiff(...
            1:length(handles.axis_PlotUltrasoundImage.Children),1:3))];
        
        % Reinitialize secondary axis.
        deleteO  = [deleteO; handles.axis_PlotCroppedImage.Children(:);...
            handles.axis_PlotCroppedImage.Title];
        
        % Hide cropped image axis, button 3, Correlation Threshold Adjustment Panel.
        invisibleO  = [invisibleO; handles.axis_PlotCroppedImage;...
            handles.button_Compute2DNerveKinematics;...
            handles.panel_AdjustCorrelationThreshold];
    end

    function [invisibleO,deleteO] = resetToButton3      % On push of Button 3.
        % Reset primary, secondary axis to button 2.
        rec0    = findobj(handles.axis_PlotUltrasoundImage.Children,'type','rectangle');
        line0	= findobj(handles.axis_PlotUltrasoundImage.Children,'type','line');
        im0	= findobj(handles.axis_PlotUltrasoundImage.Children,'type','image');
        deleteO = [rec0(1:end-2); line0(:); im0(1:end-3);...
            handles.axis_PlotCroppedImage.Children(...
            setdiff(1:length(handles.axis_PlotCroppedImage.Children),1))];
        
        % Reinitialize tertiary axis, hide button 4.
        deleteO = [deleteO; handles.axis_PlotTrackingData.Children(:)];
        invisibleO	= [handles.axis_PlotTrackingData;...
            handles.list_SelectTrackingData; handles.text_TrackingData;...
            handles.panel_DisplaySettings;...
            handles.button_BeginDigitalImageCorrelation];
    end
end

%% ------------------------Do-Not-Edit Callbacks---------------------------
function FileMenu_Callback(hObject,~,handles)
% See comments regarding inputs in previous function comments.
end

function OpenMenuItem_Callback(hObject,~,handles)
% See comments regarding inputs in previous function comments.
file = uigetfile('*.fig');
if ~isequal(file, 0)
    open(file);
end
end

function PrintMenuItem_Callback(hObject,~,handles)
% See comments regarding inputs in previous function comments.
printdlg(handles.figure1)
end

function CloseMenuItem_Callback(hObject,~,handles)
% See comments regarding inputs in previous function comments.
selection = questdlg(['Close ' get(handles.figure1,'Name') '?'],...
    ['Close ' get(handles.figure1,'Name') '...'],...
    'Yes','No','Yes');
if strcmp(selection,'No')
    return;
end

delete(handles.figure1)
end

%% -----------------------1. Plot Ultrasound Image-------------------------
% --- Executes on button_PlotUltrasoundImage press.
function button_PlotUltrasoundImage_Callback(hObject,~,handles) %#ok<*DEFNU,*INUSD>
% See comments regarding inputs in previous function comments.

% Clear anything in mainGUI for seceeding buttons from previous iterations.
setGUIVisibility(handles,1);

% Retrieve, plot image.
plotUltrasoundImage(handles);                       %#ok<*ASGLU>
end

% --- Executes on button_Go press in Adjust Correlation Threshold.
function button_Go_Callback(hObject,~,handles)
% See comments regarding inputs in previous function comments.

% Cleanse plot of any extraneous images, masks, lines, points, etc.
setGUIVisibility(handles,2);
imshow(handles.figure1.UserData.OriginalImage);
delete(handles.axis_PlotUltrasoundImage.Children(2:end));
set(handles.button_IdentifyImageReferences,'visible','off');

% Depending on UI input, create a mask for cropping and/or contrast adjustment.
axes(handles.axis_PlotUltrasoundImage);

if handles.list_AdjustImageContrastOptions.Value==1	% "None": No adjustment.
    % Do not enhance image contrast, i.e. Don't remove static pixels.
    mask	= zeros(size(handles.figure1.UserData.OriginalImage));
    
else                                                % Manually/Auto select an ROI.
    % Depending on UI input from listbox, ROI is chosen manually or automatically.
    [mask,maskPlot]	= createTransducerMask(handles);
end

% Attempt to automatically compute the scale of the image (millimeters/pixel).
handles	= detectScaling(handles);

% Confirm automatic results.
advanceTo2  = 'No';
while strcmpi('No',advanceTo2)                      % Check automated functions' results.
    advanceTo2	= questdlg('Is the crop and scaling satisfactory?','Satisfactory automation','Yes','No','Yes');
    if isempty(advanceTo2)                          % Require a valid answer.
        continue;
    end
    if strcmpi('Yes',advanceTo2)                    % Advance to 2nd Button.
        break
    else                                            % Which must be redone?
        % Redo scaling and/or crop of original image.
        redoScaling	= questdlg('Manually redo the scaling?','Check Scaling','Yes','No','Yes');
        if strcmpi('Yes',redoScaling)               % Redo the scaling.
            delete(handles.axis_PlotUltrasoundImage.Children(1));
            handles	= detectScaling(handles,'manual');
            delete(handles.axis_PlotUltrasoundImage.Children(2));
        end
        redoCrop	= questdlg('Manually redo the cropping?','Check Crop','Yes','No','Yes');
        if strcmpi('Yes',redoCrop)                  % Redo the cropping.
            delete(handles.axis_PlotUltrasoundImage.Children(2:end-1));
            handles.list_AdjustImageContrastOptions.Value	= 2;
            [mask,maskPlot]	= createTransducerMask(handles); drawnow;
            handles.axis_PlotUltrasoundImage.Children = ...
                handles.axis_PlotUltrasoundImage.Children([2 1 3]);
        end
    end
end
handles.figure1.UserData.ContrastMask   = mask;

% Allow visibility and use of and Button #2.
set(handles.button_IdentifyImageReferences,'visible','on');
end

% --- Executes on "No" button press in Adjust Correlation Threshold.
function button_NoAdjustImageContrast_Callback(hObject,~,handles)
% See comments regarding inputs in previous function comments.

if hObject.Value == 1                               % Disable "yes" button.
    set(handles.button_YesAdjustImageContrast,'Value',0);
else                                                % Enable "yes" button.
    set(handles.button_YesAdjustImageContrast,'Value',1);
    set(handles.list_AdjustImageContrastOptions,'Value',3);
    set(handles.list_AdjustImageContrastOptions,'Enable','on');
end
end

% --- Executes on "Yes" button press in Adjust Correlation Threshold.
function button_YesAdjustImageContrast_Callback(hObject,~,handles)
% See comments regarding inputs in previous function comments.

if hObject.Value == 1                               % Disable "no" button.
    set(handles.button_NoAdjustImageContrast,'Value',0);
    set(handles.list_AdjustImageContrastOptions,'Value',3);
    set(handles.list_AdjustImageContrastOptions,'Enable','on');
else                                                % Enable "no" button.
    set(handles.button_NoAdjustImageContrast,'Value',1)
end
end

% --- Executes on selection change in Constrast Adjustment Options Listbox.
function list_AdjustImageContrastOptions_Callback(hObject,~,handles)
% See comments regarding inputs in previous function comments.

if hObject.Value == 1 && get(handles.button_YesAdjustImageContrast,'Value') == 1
    % Force default selection in list because you can't choose "yes" and also "none".
    hObject.Value   = 2;                            % Default to "automatic".
end

end

% --- Executes during object creation, after setting all properties.
function list_AdjustImageContrastOptions_CreateFcn(hObject,~,handles)
% See comments regarding inputs in previous function comments.

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

%% ---------------------2. Identify Image References-----------------------
% --- Executes on button_IdentifyImageReferences press.
function button_IdentifyImageReferences_Callback(hObject,~,handles)
% See comments regarding inputs in previous function comments.

% Clear anything in mainGUI for seceeding buttons from previous iterations.
setGUIVisibility(handles,2);

% Create new image from contrast adjustment applied to original image.
handles	= overlayMaskAdjustments(handles);

% Reset main axis with adjusted image after successful image contrast adjustment.
axes(handles.axis_PlotUltrasoundImage);             % Return to main axis.
delete(handles.axis_PlotUltrasoundImage.Children);  % Reset main axis to
imshow(handles.figure1.UserData.AdjustedImage); 	% adjusted image.

% Require UI to identify the median nerve and the carpal bone(s).
identifyImageReferences(handles);

% Allow visibility and use of the next UIs.
set(handles.panel_AdjustCorrelationThreshold,'visible','on');
set(handles.button_Compute2DNerveKinematics,'visible','on');
end

% --- No execution: contains buttons within.
function edit_CorrelationThreshold_Callback(hObject,~,handles)
% See comments regarding inputs in previous function comments.

handles.figure1.UserData.CorrelationThreshold	= str2double(get(hObject,'String'));
while isnan(handles.figure1.UserData.CorrelationThreshold)
    set(hObject, 'String', 0);
    errordlg('Input must be a number','Error');
end
end

% --- Executes during object creation, after setting all properties.
function edit_CorrelationThreshold_CreateFcn(hObject,~,handles)
% See comments regarding inputs in previous function comments.

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

% --- Executes on "Yes" button press in Adjust Correlation Threshold.
function button_YesAdjustCorrelationThreshold_Callback(hObject,~,handles)
% See comments regarding inputs in previous function comments.

if hObject.Value == 1                               % Disable "no" button.
    set(handles.button_NoAdjustCorrelationThreshold,'Value',0);
    set(handles.edit_CorrelationThreshold,'Enable','on');
else                                                % Enable "no" button.
    set(handles.button_NoAdjustCorrelationThreshold,'Value',1)
end
end

% --- Executes on "No" button press in Adjust Correlation Threshold.
function button_NoAdjustCorrelationThreshold_Callback(hObject,~,handles)
% See comments regarding inputs in previous function comments.

if hObject.Value == 1                               % Disable "yes" button and edit box.
    set(handles.button_YesAdjustCorrelationThreshold,'Value',0);
    set(handles.edit_CorrelationThreshold,'Enable','off');
else                                                % Enable "yes" button and edit box.
    set(handles.button_YesAdjustCorrelationThreshold,'Value',1);
    set(handles.edit_CorrelationThreshold,'Enable','on');
end
end

%% --------------------3. Perform 2D Nerve Kinematics----------------------
% --- Executes on computed2DNerveKinematics_Button_Callback press.
function button_Compute2DNerveKinematics_Callback(hObject,~,handles)
% See comments regarding inputs in previous function comments.

% Clear anything in mainGUI for seceeding buttons from previous iterations.
setGUIVisibility(handles,3);    drawnow;

% Reset display button preferences
visibility = {'off','on'};
handles.button_CurrentLocationDisplay.UserData  =...
    visibility{handles.button_CurrentLocationDisplay.Value+1};
handles.button_PreviousLocationsDisplay.UserData	=...
    visibility{handles.button_PreviousLocationsDisplay.Value+1};
handles.button_BoundingBoxDisplay.UserData  =...
    visibility{handles.button_BoundingBoxesDisplay.Value+1};
        
% Advance through image frames, track references.
compute2DNerveKinematics(handles);
set(handles.button_BeginDigitalImageCorrelation,'visible','on');
end

% --- Executes on button press in button_CurrentLocationDisplay.
function button_CurrentLocationDisplay_Callback(hObject,~,handles)
% See comments regarding inputs in previous function comments.

lineInPlot	= findobj(handles.axis_PlotUltrasoundImage.Children,'type','Line');
if hObject.Value == 1                               % Show 1st locations.
    set(lineInPlot(end-1:end),'visible','on');
    handles.button_CurrentLocationDisplay.UserData	= 'on';
    
else                                                % Don't show 1st locations.
    set(lineInPlot(end-1:end),'visible','off');
    handles.button_CurrentLocationDisplay.UserData	= 'off';
end

% Adjust visibility of older plots.
if handles.button_PreviousLocationsDisplay.Value == 1
    set(lineInPlot(1:end-2),'visible','on');
    handles.button_PreviousLocationsDisplay.UserData	= 'on';
else
    set(lineInPlot(1:end-2),'visible','off');
    handles.button_PreviousLocationsDisplay.UserData	= 'off';
end
button_BoundingBoxesDisplay_Callback(handles.button_BoundingBoxesDisplay,[],handles);
end

% --- Executes on button press in button_PreviousLocationsDisplay.
function button_PreviousLocationsDisplay_Callback(hObject,~,handles)
% See comments regarding inputs in previous function comments.

lineInPlot	= findobj(handles.axis_PlotUltrasoundImage.Children,'type','Line');
if hObject.Value == 1                               % Show all but 1st locations.
    set(lineInPlot(1:end-2),'visible','on');
    handles.button_PreviousLocationsDisplay.UserData	= 'on';
else                                                % Don't show  all but 1st locations.
    set(lineInPlot(1:end-2),'visible','off');
    handles.button_PreviousLocationsDisplay.UserData	= 'off';
end

% Adjust visibility of older plots.
if handles.button_CurrentLocationDisplay.Value == 1
    set(lineInPlot(end-1:end),'visible','on');
    handles.button_CurrentLocationDisplay.UserData	= 'on';
else
    set(lineInPlot(end-1:end),'visible','off');
    handles.button_CurrentLocationDisplay.UserData	= 'off';
end
button_BoundingBoxesDisplay_Callback(handles.button_BoundingBoxesDisplay,[],handles);
end

% --- Executes on button press in button_BoundingBoxesDisplay.
function button_BoundingBoxesDisplay_Callback(hObject,~,handles)
% See comments regarding inputs in previous function comments.

visibleO	= [];   invisibleO  = [];
boxInPlot   = findobj(handles.axis_PlotUltrasoundImage.Children,'type','rectangle');
if hObject.Value == 1                               % Yes show boxes.
    % Get all but last two rectangle objects.
    if handles.button_PreviousLocationsDisplay.Value == 1
        visibleO	= [visibleO; boxInPlot(1:end-2)];
    else
        invisibleO  = [invisibleO; boxInPlot(1:end-2)];
    end
    
    % Get last two rectangle objects.
    if handles.button_CurrentLocationDisplay.Value == 1
        visibleO  = [visibleO; boxInPlot(end-1:end)];
    else
        invisibleO  = [invisibleO; boxInPlot(end-1:end)];
    end
    set(visibleO,'visible','on');                   % Show selected boxes.
    set(invisibleO,'visible','off');
    handles.button_BoundingBoxDisplay.UserData	= 'on';
    
else                                                % Don't show any boxes.
    set(boxInPlot,'visible','off');
    handles.button_BoundingBoxDisplay.UserData	= 'off';
end
end

% --- Executes on selection change in list_SelectTrackingData.
function list_SelectTrackingData_Callback(hObject,~,handles)
% See comments regarding inputs in previous function comments.

if hObject.Value == 1                               % "None".
    set(handles.axis_PlotTrackingData,'visible','off');
    if ~isempty(handles.axis_PlotTrackingData.Children)
        set(get(handles.axis_PlotTrackingData,'Children'),'visible','off');
    end
    
elseif hObject.Value > 1 || isempty(hObject.Value)  % Turn on visiblity.
    set(handles.axis_PlotTrackingData,'visible','on');
    set(handles.axis_PlotTrackingData,'XGrid','on','YGrid','on','box','on');
    if ~isempty(handles.axis_PlotTrackingData.Children)
        set(handles.axis_PlotTrackingData.Children(hObject.Value-1),'visible','on');
        set(handles.axis_PlotTrackingData.Children(setdiff(1:3,hObject.Value-1)),'visible','off');
        
        % Set axis limits, title, labels.
        [xmin,xmax]	= bounds(handles.axis_PlotTrackingData.Children(hObject.Value-1).XData);
        xmin    = xmin - eps;                       % For 1st plotting iter.
        xmax	= xmax + eps;
        switch hObject.Value-1
            case 1                               	% "Position".
                titleString	= 'Spatial Position';
                xlabelString= 'X-Coordinate [mm]';
                ylabelString= 'Y-Coordinate [mm]';
                [ymin,ymax] = bounds(handles.axis_PlotTrackingData.Children(1).YData);
                ymin    = ymin - eps;   ymax	= ymax + eps;
                
            case 2                                  % "Velocity".
                titleString	= 'Velocity Magnitude';
                xlabelString= 'Time [sec]';
                ylabelString= 'Velocity [mm/sec]';
                [ymin,ymax] = bounds(handles.axis_PlotTrackingData.Children(2).YData);
                ymin    = ymin - eps;   ymax	= ymax + eps;
                
            case 3                                  % "Acceleration".
                titleString	= 'Acceleration Magnitude';
                xlabelString= 'Time [sec]';
                ylabelString= sprintf('Acceleration [mm/sec^2]');
                ymax    = max(handles.axis_PlotTrackingData.Children(3).YData);
                ymin    = -ymax;
                
            otherwise %...Nothing here.
        end
        set(handles.axis_PlotTrackingData.Title,'string',titleString,'FontSize',12);
        set(handles.axis_PlotTrackingData.XLabel,'string',xlabelString);
        set(handles.axis_PlotTrackingData.YLabel,'string',ylabelString);
        set(handles.axis_PlotTrackingData,'XLim',[xmin xmax],'YLim',[ymin ymax]);
    end
end
end
% 
% --- Executes during object creation, after setting all properties.
function list_SelectTrackingData_CreateFcn(hObject,~,handles)
% See comments regarding inputs in previous function comments.

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
end

%% ----------------------------4. Compute DIC------------------------------
% --- Executes on button_Compute2DNerveKinematics press.
function button_BeginDigitalImageCorrelation_Callback(hObject,~,handles)
% See comments regarding inputs in previous function comments.

end

%% -----------------------------New Features-------------------------------
%%% Things to add:
%-A marker/tracer for the bottom axis that when you click highlights that
%velocity node as well as a marker in the top axis for its
%corresponding location.
%-UI prompt asking if user want's a figure with motion path displayed.

% % Trace velocity values in graph -- see "gui graph marker that moves with a slider".
% % could have this marker concurrently highlight the point in the nerve on the
% % ultrasound as well as the previous and next marks with different colors.
% idx	= 1;
% for jdx	= 1:size(files,1)
%     filename	= files(jdx).name;
%     if strfind(filename,'.tif')>0
%         nextpic	= imread([pathName,filename]);
%         figure,
%         subplot(2,1,1),imshow(nextpic)
%         subplot(2,1,2),plot(xValues,velocities)
%         hold on, plot(xValues(idx),velocities(idx),'.r')
%
%         idx	= idx+1;
%         saveas(gcf,[strtok(filename,'.'),'_Velocity.tif'])
%         close
%     end
% end

%-Functionality that can exit unfinished functions like impoly that cause
%a windowsbuttondwnfcn error and requires relaunch of the GUI.
