function handles	= detectScaling(handles,method)
%DETECTSCALING Detects points in image for scaling.
%   handles = DETECTSCALING(handles) returns ...
%
%   See also: COMPUTESCALING, PLOTULTRASOUNDIMAGE, MAINGUI.
%==========================================================================

% Check I/O.
if nargin == 1
    method	= 'auto';
end

% Perform main automated computation.
if strcmpi(method,'manual')                         % Manual selection.
    [x,y,~]	= impixel(handles.figure1.UserData.OriginalImage);
    
else                                                % Automate process.
    try
    % Create mask - ad hoc method assumes the approximate region of image.
    sizeI   = size(handles.figure1.UserData.OriginalImage);
    mask	= false(sizeI(1),sizeI(2));
    mask(61:end,701:751)	= true;
    
    % Burn mask into original ultrasound image.
    burnedMaskIntoI	= rgb2gray(handles.figure1.UserData.OriginalImage);
    burnedMaskIntoI(~mask)  = 0;
    
    % Perform Optical Character Recognition; try to find y-location of "1".
    bwburnedMaskIntoI   = imbinarize(burnedMaskIntoI);
    dilate_bwburnedMaskIntoI = imdilate(bwburnedMaskIntoI,strel('disk',6));
    s   = regionprops(dilate_bwburnedMaskIntoI,'BoundingBox');
    bboxes  = vertcat(s(:).BoundingBox);
    [~,ord] = sort(bboxes(:,2));                    % Sort boxes by image height.
    bboxes  = bboxes(ord,:);
    bwburnedMaskIntoI   = imdilate(bwburnedMaskIntoI,strel('disk',1));
    ocrResults  = ocr(bwburnedMaskIntoI,bboxes,'CharacterSet','012','TextLayout','word');
    numbers	= {ocrResults(:).Words}';
    found012	= cell(3,1);
    for idx = 1:length(numbers)
        if ~isempty(numbers{idx})
            if str2double(numbers{idx}{1}) == 0
                found012{1}	= [found012{1}; idx];
                
            elseif str2double(numbers{idx}{1}) == 1
                found012{2} = [found012{2}; idx];
                
            elseif str2double(numbers{idx}{1}) == 2
                found012{3} = [found012{3}; idx];
            end
        end
    end
    
    % Find x,y-coordinates of a 0-1 or 1-2 or 0-2 pairing.
    boundingBoxes   = {ocrResults(:).WordBoundingBoxes}';
    if ~isempty(found012{1}) && ~isempty(found012{2})
        % Find x,y-coordinates of 0 and 1 then compute distance between them.
        p1	= boundingBoxes{found012{1}(1)};        % Position: 0 is the 1st.
        p2	= boundingBoxes{found012{2}(1)};        % Position: 1 is the 2nd.
        x	= [mean([p1(1); p1(1)+p1(3)]); mean([p2(1); p2(1)+p2(3)])];
        y	= [mean([p1(2); p1(2)+p1(4)]); mean([p2(2); p2(2)+p2(4)])];
        
    elseif ~isempty(found012{2}) && ~isempty(found012{3})
        % Find x,y-coordinates of 1 and 2 then compute distance between them.
        p2	= boundingBoxes{found012{2}(1)};        % 1 is the 2nd.
        p3	= boundingBoxes{found012{3}(1)};        % 2 is the 3rd.
        x	= [mean([p2(1); p2(1)+p2(3)]); mean([p3(1); p3(1)+p3(3)])];
        y	= [mean([p2(2); p2(2)+p2(4)]); mean([p3(2); p3(2)+p3(4)])];
        
    elseif ~isempty(found012{1}) && ~isempty(found012{3})
        % Find x,y-coordinates of 0 and 2 then compute distance/2 (for y) between them.
        p1	= boundingBoxes{found012{1}(1)};        % 0 is the 1st.
        p3	= boundingBoxes{found012{3}(1)};        % 2 is the 3rd.
        x	= [mean([p1(1); p1(1)+p1(3)]); mean([p3(1); p3(1)+p3(3)])];
        y	= [mean([p1(2); p1(2)+p1(4)]); mean([p3(2); p3(2)+p3(4)])];
        
    else
        % Not enough numbers detected; Must use impixel.
        uiwait(msgbox('Must manually select scaling.','Can''t Auto-Detect Scaling','modal'));
        [x,y,~]	= impixel(handles.figure1.UserData.OriginalImage);
    end
    
    catch
        [x,y,~]	= impixel(handles.figure1.UserData.OriginalImage);
    end
end

% Compute scaling of pixels in image wrt millimeters in wrist.
handles	= computeScaling(handles,x,y);

% Plot x,y-coordinates to show result.
hold on;    plot(x,y,'r*','MarkerSize',9);

