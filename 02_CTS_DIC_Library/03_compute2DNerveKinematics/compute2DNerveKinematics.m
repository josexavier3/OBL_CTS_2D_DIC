function handles	= compute2DNerveKinematics(handles)
%COMPUTE2DNERVEKINEMATICS Tracks path of cropped image.
%   handles = COMPUTE2DNERVEKINEMATICS(handles) returns all handles of
%   mainGUI as the reference points (median nerve and carpal bone) are
%   tracked and their kinematic data plotted.
%
%   See also: MAINGUI, PLOTULTRASOUNDIMAGE, IDENTIFYIMAGEREFERENCES,
%   BEGINDIGITALIMAGECORRELATION.
%==========================================================================

% Enable visibility of buttons.
set([handles.list_SelectTrackingData; handles.axis_PlotTrackingData;...
    handles.panel_DisplaySettings; handles.text_TrackingData],'visible','on');

%% Compute locations of masks, crops.
% Conventional for loop.
results	= conventionalComputation(handles);

% Parallelized loop.
% results	= parallelComputation(handles);

%% Plot and parse results.
