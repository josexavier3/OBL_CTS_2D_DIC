function handles	= computeScaling(handles,x,y)
%COMPUTESCALING Detects points in image for scaling.
%   handles = COMPUTESCALING(handles,x,y) returns ...
%   
%   See also: DETECTSCALING, MAINGUI.
%==========================================================================

% Compute the scaling, vis a vis mm/pixel.
pixpermm	= sqrt((x(1)-x(2))^2+(y(1)-y(2))^2)/10;
handles.figure1.UserData.MillimetersPerPixel	= 1/pixpermm;