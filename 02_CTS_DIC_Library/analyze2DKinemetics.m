function results	= analyze2DKinemetics(dataGUI)
    %ANALYZE2DKINEMATICS Quantifies ultrasound 2D Kinematic results.
    %   varargout = ANALYZE2DKINEMATICS(data_2DKinematics) returns a struct
    %   results_2dKinematics containing the total distance traveled, the
    %   (net) linear displacement from beginning to end, min/max/mean for
    %   velocity and acceleration.
    %   
    %   See also: PLOT2DKINEMATICS, MAIN, MAIN_GUI.
    %======================================================================
    
    % Initialize output structure.
    results    = struct('XDistance',[],'YDistance',[],...
        'DistanceTraveled',[]);
    
    % Adjust inputs.
    format shortg
    data = dataGUI.UserData.OutputData;
    data.RelativeXY	= (data.NerveXY-data.BoneXY)+1000; % Add 1000. Cumulative coords are trivial.
    
    % Perform computations to fill output structure.
    diffX   = diff(data.RelativeXY(:,1)).*dataGUI.UserData.MillimetersPerPixel;
    diffY   = diff(data.RelativeXY(:,2)).*dataGUI.UserData.MillimetersPerPixel;
    results.XDistance   = sum(abs(diffX));
    results.YDistance   = sum(abs(diffY));
    results.DistanceTraveled    = sum(hypot(diffX,diffY));