function [mask,maskPlot] = createTransducerMask(handles)
%CREATETRANSDUCERMASK Identify mask for ultrasound image contrast adjustment.
%   mask = CREATETRANSDUCERMASK(handles) returns a binary image that masks
%   the output of the ultrasound transducer of the original image.
%   Depending on the GUI input, the mask is generated manually via IMPOLY
%   function or automatically via bxconvhull analysis.
%   
%   [mask,maskPlot] = CREATETRANSDUCERMASK(handles) also returns the
%   graphics object that outlines mask and is overlayed in the main axis.
%   
%   Note: All images are assumed to be .tif files. Cannot accomodate other
%   image files.
%
%   See also: OVERLAYMASKADJUSTMENTS, PLOTULTRASOUNDIMAGE.
%==========================================================================

% Create a mask (polygon) over ultrasound image.
hold(handles.axis_PlotUltrasoundImage);
if handles.list_AdjustImageContrastOptions.Value==2 % Manually-generated ROI.
    % Custom drawn polygon to create mask.
    impolyHandle	= impoly(handles.axis_PlotUltrasoundImage);
    setColor(impolyHandle,[1 0 0]);                 % Set color as red.
    setVerticesDraggable(impolyHandle,true);        % Let user drag verts.
    mask    = createMask(impolyHandle);             % Create binary mask.
    xy	= getPosition(impolyHandle);                % Get x-y coordinates.
    xy  = [xy; xy(1,:)];                            % Close poly.
    maskPlot	= line('XData',xy(:,1),'YData',xy(:,2),'color','r','linewidth',2);
    delete(impolyHandle);
    
else % Value == 3                                 	% Auto-generated ROI.
    % Get original ultrasound image and its filename.
    I   = handles.figure1.UserData.OriginalImage;
    IFileName	= handles.figure1.UserData.FileName(1:end-4);
    
    % Identify frames for iteration.
    N   = dir([handles.figure1.UserData.PathName '/*.tif']);
    nFrames = size(N,1);                            % # of images in folder.
    interval	= 5;                            	% # of frames skipped.
    viewFrames	= 1:interval:nFrames-1; 
    if ~ismember(nFrames-1,viewFrames)              % Make sure last frame
        viewFrames	= [viewFrames,nFrames-1];       % is included.
    end
    
    % Initialize a binary image for identifying pixels that capture movement.
    pix	= zeros(size(I));
    
    % Loop through until the N-th frame, creating all-encompassing mask.
    findFrameNum    = strfind(IFileName,IFileName(end-2));
    wb  = waitbar(0,'Computing Convex Hull...');
    for idx	= viewFrames(1:end)
        % Get next frame.
        nextFrameNum	= num2str(str2double(IFileName(findFrameNum:end)) + idx);
        switch length(nextFrameNum)
            case 1                                  % Less than 10th Frame.
                nextFrameNum	= ['00',nextFrameNum]; 	%#ok<AGROW>
            case 2                                  % Less than 100th Frame.
                nextFrameNum	= ['0',nextFrameNum]; 	%#ok<AGROW>
            otherwise
                
        end
        imFileNameNextFrame     = IFileName;   	% Filename of next frame.
        imFileNameNextFrame(findFrameNum:end)	= nextFrameNum;
        INext   = imread([imFileNameNextFrame,'.tif']);
        
        % Compare (nonbinary) the previous frame with nextFrameNum.
        dynamicPixels	= INext ~= I;
        pix(dynamicPixels)  = 1;
        
        % I becomes INext because we are comparing consecutive frames.
        I  = INext;
        waitbar(idx/nFrames,wb);
    end
    delete(wb);
    
    % Compute convex hull of pix to bound all changing-pixels.
    mask	= bwconvhull(imbinarize(rgb2gray(pix),'adaptive','Sensitivity',1),'union');
    
    % Plot outline of the mask
    bb  = regionprops(mask,'boundingbox');
    bb.BoundingBox = bb.BoundingBox - 0.50;
    % [minC minR width height]
    rows    = [bb.BoundingBox(2),bb.BoundingBox(2) + bb.BoundingBox(4)];
    cols	= [bb.BoundingBox(1),bb.BoundingBox(1) + bb.BoundingBox(3)];
    mask(rows(1):rows(2),cols(1):cols(2)) = 1;
    maskPlot    = rectangle('position',bb.BoundingBox,'edgecolor','r','linewidth',2);
end
drawnow;
