function resultantI	= maskPixelDataTransformation(handles,currentI,mask3)
%MASKPIXELDATATRANSFORMATION Equalize histogram of pixels in mask wrt. image.
%   resultantI = MASKPIXELDATATRANSFORMATION(currentI,handles) returns an
%   resultant image burned with pixels within the inputted mask who's
%   pixel values have been fitted to a more-normal distribution. The data
%   transformation (square root of pixel values) is intended to remove
%   skewness of non-black pixels and to force a more uniform DIST.
%   
%   See also: OVERLAYMASKADJUSTMENTS, PLOTULTRASOUNDIMAGE,
%   COMPUTE2DNERVEKINEMATICS.
%==========================================================================

if nargin == 2                                      % Get last mask.
    % Accomodate mask indices for 3-dim ultrasound image.
    mask3	= repmat(handles.figure1.UserData.ContrastMask,1,1,3);
end

% Burn new image into current image, convert to grayscale.
maskBurnedIntoI	= currentI;
maskBurnedIntoI = rgb2gray(maskBurnedIntoI);

% Compute a data transformation on pixels in burned mask.
pix	= double(maskBurnedIntoI(handles.figure1.UserData.ContrastMask));
pixTransformed	= sqrt(pix);                        % Fit pixels to normal dist.
pixTransformed	= (pixTransformed./max(pixTransformed)).*max(pix);
% Divide everything by largest pixel value. Maybe don't take the square
% root first.


% Burn transformed pixels into mask of I.
maskBurnedIntoI(handles.figure1.UserData.ContrastMask)	= pixTransformed;
newI	= repmat(maskBurnedIntoI,1,1,3);
resultantI  = currentI;
resultantI(mask3)	= newI(mask3);

