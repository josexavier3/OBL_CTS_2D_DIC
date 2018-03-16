function handles = showCropLabels(handles)
%SHOWCROPLABELS Display labels of nerve, bone crops in main axis.
%
%   See also: IDENTIFYIMAGEREFERENCES, COMPUTE2DNERVEKINEMATICS.
%==========================================================================

% Delete old objects. Note: there's gotta be a way to avoid deleting and
% recreating these text graphics options and instead bring them to the
% front of the axis display...
delete(findobj(handles.axis_PlotUltrasoundImage.Children,'type','text'));

% Recreate text objects.
handles.figure1.UserData.NerveLabel	= text('Position',[5 10 0],...
    'String','Median Nerve','FontSize',15,'Color','r','FontWeight','bold');
handles.figure1.UserData.BoneLabel	= text('Position',[5 30 0],...
    'String','Carpal Bone','FontSize',15,'Color','g','FontWeight','bold');