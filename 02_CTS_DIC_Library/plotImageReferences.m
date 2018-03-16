function plotImageReferences(handles,nerveCrop,nerveX,nerveY,boneCrop,...
    boneX,boneY)
%PLOTIMAGEREFERENCES Plots _
%   PLOTIMAGEREFERENCES(handles,x,y) for
%   
%   See also:
%==========================================================================

% Plot new rectangle location (and its center, if desired) on main axis.
rectangle('Position',nerveCrop,'EdgeColor','r','LineStyle',':');
rectangle('Position',boneCrop,'EdgeColor','r','LineStyle',':');
plot(nerveX,nerveY,'r*');
plot(boneX,boneY,'g*');

% Set specific children as visible.
imH	= imhandles(handles.axis_PlotUltrasoundImage);
delete(imH(2));                             % Remove previous image.
main_GUI('button_CurrentLocationDisplay_Callback',...
    handles.showCurrentLocation_Button,[],handles);
main_GUI('button_PreviousLocationsDisplay_Callback',...
    handles.showPreviousLocations_Button,[],handles);
main_GUI('button_BoundingBoxesDisplay_Callback',...
    handles.button_BoundingBoxesDisplay,[],handles);
