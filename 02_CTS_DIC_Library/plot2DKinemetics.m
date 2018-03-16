function varargout = plot2DKinemetics(data_2DKinematics,results_2DKinematics)
    %PLOT2DKINEMATICS Plots ultrasound's 2D Kinematic results.
    %   varargout = PLOT2DKINEMATICS(data_2DKinematics,results_2DKinematics)
    %   returns the resulting figure.
    %   
    %   See also: ANALYZE2DKINEMATICS, MAIN, MAIN_GUI.
    %======================================================================
    
    % Seperate figure for position, velocity, and acceleration.
    figureWithData	= questdlg('Show All Quantitative Data?',...
        'Quantitative Data','Yes','No','Yes');
    if strcmp(figureWithData,'Yes')
        figure;     set(gcf,'color','1 1 1');
        subplot(3,4,1:2);    hold on;
        plot(data_2DKinematics.Children(1).XData,...
            data_2DKinematics.Children(1).YData,...
            'r.-','LineWidth',1,'MarkerSize',10);
        plot(data_2DKinematics.Children(1).XData(1),...
            data_2DKinematics.Children(1).YData(1),...
            'ro','Markersize',4,'MarkerFaceColor','r');
        plot(data_2DKinematics.Children(1).XData(end),...
            data_2DKinematics.Children(1).YData(end),...
            'rx','LineWidth',2.5,'Markersize',10);
        %****This should eventually be the exact spatial
        % dimensions as the ultrasound.
        pax  = gca;	pax.LineWidth	= 2;	box on;	grid on;
        axis([round(pax.XLim(1),2) round(pax.XLim(2),2)...
            round(pax.YLim(1),2) round(pax.YLim(2),2)]);
        title('Spatial Position','FontSize',15,'FontWeight','bold');
        xlabel('X-Coordinate [mm], In-Frame'); ylabel('Y-Coordinate [mm], In-Frame');
        legend('Motion Path by Frame','1st Frame','Last Frame','Location','Best');
        
        % Copy velocity plot from GUI.
        subplot(3,4,5:6);    hold on;
        plot(data_2DKinematics.Children(2).XData,...
            data_2DKinematics.Children(2).YData,'g.-','MarkerSize',10);
        plot(0,data_2DKinematics.Children(2).YData(1),...
            'go','Markersize',4,'MarkerFaceColor','g');
        plot(data_2DKinematics.Children(2).XData(end),...
            data_2DKinematics.Children(2).YData(end),...
            'gx','LineWidth',2.5,'Markersize',10);
        vax  = gca;	vax.LineWidth	= 2;   box on;	grid on;	axis auto;
        title('Velocity Magnitude','FontSize',15,'FontWeight','bold');
        xlabel('Time [sec]'); ylabel('Velocity [mm/sec]');
        legend('Velocity by Frame','1st Frame','Last Frame','Location','Best');
        
        % Create acceleration plot from GUI.
        subplot(3,4,9:10);	hold on;
        plot(data_2DKinematics.Children(3).XData,...
            data_2DKinematics.Children(3).YData,'b.-','MarkerSize',10);
        plot(0,data_2DKinematics.Children(3).YData(1),...
            'bo','Markersize',4,'MarkerFaceColor','b');
        plot(data_2DKinematics.Children(3).XData(end),...
            data_2DKinematics.Children(3).YData(end),...
            'bx','LineWidth',2.5,'Markersize',10);
        aax  = gca;	aax.LineWidth	= 2;   box on;	grid on;	axis auto;
        title('Acceleration Magnitude','FontSize',15,'FontWeight','bold');
        xlabel('Time [sec]'); ylabel(sprintf('Acceleration [mm/sec^2]'));
        legend('Acceleration by Frame','1st Frame','Last Frame','Location','Best');
        
        % 3D plot with [X,Time,Y] being the axes; highlight the end points.
        subplot(3,4,[3:4,7:8]); hold on;
        plot3(data_2DKinematics.Children(1).XData,...
            data_2DKinematics.Children(2).XData(2:end),...
            data_2DKinematics.Children(1).YData,...
            'r.-','LineWidth',1,'MarkerSize',10);
        plot3(data_2DKinematics.Children(1).XData(1),...
            data_2DKinematics.Children(2).XData(2),...
            data_2DKinematics.Children(1).YData(1),...
            'ro','Markersize',4,'MarkerFaceColor','r');
        plot3(data_2DKinematics.Children(1).XData(end),...
            data_2DKinematics.Children(2).XData(end),...
            data_2DKinematics.Children(1).YData(end),...
            'rx','LineWidth',2.5,'Markersize',10);
        tdax  = gca;	tdax.LineWidth	= 2;   box on;	grid on;	axis auto;
        title('Time-Spatial Position','FontSize',15,'FontWeight','bold');
        xlabel('X-Coordinate [mm], In-Frame');	ylabel('Time [sec], In-Frame');
        zlabel('Y-Coordinate [mm], In-Frame');  view(3);
        legend('Motion Path by Frame','1st Frame','Last Frame','Location','Best');
        
        % Set all text as bold weight.
        set(findall(gcf,'-property','fontweight'),'fontweight','bold');
        
        % Table with statistics.
        subplot(3,4,11:12);
%         t = uitable(gcf,
        
        % Output results.
        varargout	= {gcf};
    else
        varargout	= {'No Plots Created'};
    end
