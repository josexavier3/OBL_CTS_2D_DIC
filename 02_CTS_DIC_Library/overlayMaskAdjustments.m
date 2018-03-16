function [handles,resultantI]	= overlayMaskAdjustments(handles,currentI)
%OVERLAYMASKADJUSTMENTS Crops image and adjusts contrasts of mask.
%   handles	= OVERLAYMASKADJUSTMENTS(handles) returns handles of the GUI
%   with updates to the original ultrasound image in the main axis. This
%   image - depending on UI input - is either unedited or has all static
%   pixels removed. In the latter case, the pixels located within the
%   binary mask created in CREATETRANSDUCERMASK will be adjusted to a
%   more-uniform distribtuion, i.e. higher contrast wrt unmasked pixels.
%   
%   See also: CREATETRANSDUCERMASK, MASKPIXELDATATRANSFORMATION,
%   PLOTULTRASOUNDIMAGE, COMPUTE2DNERVEKINEMATICS.
%==========================================================================

if handles.list_AdjustImageContrastOptions.Value==1 % Don't remove static pixels.
    % Do nothing.
    
else	% Cropping is desired; Remove the static pixels of ultrasound.
    % Accomodate mask indices for 3-dim ultrasound image.
    mask3	= repmat(handles.figure1.UserData.ContrastMask,1,1,3);
    
    % Burn mask into original ultrasound image.
    if nargin == 1
        resultantI  = handles.figure1.UserData.OriginalImage;
    else
        resultantI  = currentI;
    end
    resultantI(~mask3)  = 0;                        % Remove nonmasked pix.
    
    if handles.button_NoAdjustImageContrast.Value == 1
        % No contrast adjustment desired; Do nothing.
        
    else    % Constrast adjustment is desired; Perform data transformation.
        resultantI	= maskPixelDataTransformation(handles,resultantI,mask3);
    end
    
    % Show updated graphics object in primary axis.
    if nargout == 1
        handles.figure1.UserData.AdjustedImage	= resultantI;
    else
        % Do nothing to handles. Only output resultantI.
    end
end

