function varargout = createImageSequence(loadLocation,workingDir)
    %CREATEIMAGESEQUENCE Create, save sequence of images from ultrasound.
    %   varargout = CREATEIMAGESEQUENCE(loadLocation)
    %   
    %   See also: MAIN.
    %======================================================================
    
    % Identify parent folder holding .avi file.
    if nargin == 1 || isempty(workingDir)
        workingDir	= uigetdir(loadLocation,...
            'Select folder where movie is located.');
    end
    mkdir(workingDir);
    cd(workingDir);
    
    % Identify file for conversion.
    [aviFileName,~]	= uigetfile('.avi','Select .avi video for conversion.');
    
    % Make folder to store image sequence.
    mkdir(workingDir,aviFileName(1:end-4));
    
    % Create a VideoReader to use for reading frames from the file.
    ultrasoundVideo = VideoReader(aviFileName);
    numberOfFrames	= ultrasoundVideo.Duration*ultrasoundVideo.FrameRate;
    
    % Create the image sequence.
    idx = 1;
    wb  = waitbar(0,'Writing frames to .TIF files...');
    while hasFrame(ultrasoundVideo)
        img	= readFrame(ultrasoundVideo);
        filename = [sprintf('%03d',idx),'.tif'];
        fullname = fullfile(workingDir,aviFileName(1:end-4),filename);
        imwrite(img,fullname);
        waitbar(idx/numberOfFrames,wb);
        idx	= idx + 1;
    end
    delete(wb);
    
    % Reset directory.
    cd(loadLocation);
    mkdir(loadLocation);