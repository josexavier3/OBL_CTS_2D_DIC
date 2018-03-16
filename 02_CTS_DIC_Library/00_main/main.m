%==========================================================================
% Main: Carpal Tunnel Syndrome - Digital Image Correlation
%==========================================================================
%% Set Working Directory, Adjust Some Settings (temporary).
clearvars;  close all;  clc;
if ~exist('loadLocation','var')                     % For re-running main.
%     loadLocation	= '';                           % Insert path here, if needed; comment out others.
%     loadLocation	= '//Users/dominik/Downloads';	% Dom's mac.
%     loadLocation	= 'R:\Ortho-Biomechanics\Dominik\CTS_DIC_Working_Folder'; % R-drive location
    loadLocation	= 'H:\CTS_DIC_Working_Folder';	% Work Drive.
end
cd(loadLocation);   addpath(genpath(loadLocation));
if ~exist('saveLocation','var')                     % Location of saved files.
    saveFiles	= questdlg('Will you be saving any files?','Save in Folder:','Yes','No','No');
    if strcmp(saveFiles,'Yes')
        saveLocation    = uigetdir(loadLocation,'Select Folder for Saved Files:');
    end
end
% set(0,'DefaultFigureWindowStyle','docked');    	% Keep figs in-window.
format shortg;

%% Create New Image Sequence.
% Select Ultrasound, convert frames to .tif(s).
% parentDir   = [];

% numIter	= 11;                                   % Healthy,
% Healthy = cell(numIter,1);
numIter = 10;                                       % CTS.
CTS = cell(numIter,1);
for idx = 1:numIter

    parentDir   = uigetdir('select parent directory','get dir');
    idx_str  = strfind(parentDir,'2B');

    % createImageSequence(loadLocation,parentDir);
    clc;parentDir(end-6:end)

    %% Launch GUI.
    % clearvars -EXCEPT loadLocation saveLocation;    clc;
    clear outGUI
    % Retrieve output.
    outGUI	= mainGUI();                                % Launch.
    % outGUI = [];

    % Save results in larger variable.
%     Healthy	= outGUI;                                   % Update saved var.
%     guiSavePath = [saveLocation,'/Healthy_',parentDir(idx_str:end)];
%     save(guiSavePath,'Healthy');	savefig(outGUI,guiSavePath);
    CTS     = outGUI;
    guiSavePath = [saveLocation,'/CTS_',parentDir(idx_str:end)];
    save(guiSavePath,'CTS');	savefig(outGUI,guiSavePath);
    
    
end

%% Data Analysis.

clc;
% Grab results from all saved .mat files in folder.
savedFolder   = uigetdir('select parent directory','get dir');
cd(savedFolder);              
files	= dir('*.mat');                         	% All saved data files.
numFiles= size(files,1);

% Assess 2D Kinematic Results.
distTraveled	= cell(1,2);
distTraveled(1:2)	= {cell(numFiles,4),cell(numFiles,4)};
iCTS = 1;   iHealthy = 1;
for idx = 1:numFiles
    % Analyze data.
    dataFileName	= files(idx).name;
    load(dataFileName);                             % Load saved var.
    if contains(dataFileName,'CTS')                 % CTS data.
        try
            results	= analyze2DKinemetics(CTS);
        catch
            continue
        end
        distTraveled{1}{iCTS,1} = dataFileName(1:end-4);
        distTraveled{1}{iCTS,2} = results.XDistance;
        distTraveled{1}{iCTS,3} = results.YDistance;
        distTraveled{1}{iCTS,4} = results.DistanceTraveled;
        iCTS = iCTS + 1;
        clear CTS
    else                                            %  Healthy data.
        try
            results	= analyze2DKinemetics(Healthy);
        catch
            continue
        end
        distTraveled{2}{iHealthy,1} = dataFileName(1:end-4);
        distTraveled{2}{iHealthy,2} = results.XDistance;
        distTraveled{2}{iHealthy,3} = results.YDistance;
        distTraveled{2}{iHealthy,4} = results.DistanceTraveled;
        iHealthy = iHealthy + 1;
        clear Healthy
    end
end

% Compute mean, standard deviation.
stats   = cell(3,7);
stats(2:3)  = {'CTS','Healthy'};
stats(1,:)  = {' ',',Mean X','STD X','Mean Y','STD Y','Mean Dist.','STD Dist.'};
for idx = 2:3
    stats{idx,2}	= mean(cell2mat(distTraveled{idx-1}(:,2)));
    stats{idx,3}    = std(cell2mat(distTraveled{idx-1}(:,2)));
    stats{idx,4}	= mean(cell2mat(distTraveled{idx-1}(:,3)));
    stats{idx,5}    = std(cell2mat(distTraveled{idx-1}(:,3)));
    stats{idx,6}	= mean(cell2mat(distTraveled{idx-1}(:,4)));
    stats{idx,7}    = std(cell2mat(distTraveled{idx-1}(:,4)));
end

% Present data in figure.
figure;
subplot(2,1,1);
bX  = boxplot([cell2mat(distTraveled{1}(:,2)),cell2mat(distTraveled{2}(:,2))],...
    {'CTS Patients','Healthy Patients'},'notch','off','widths',.2);
title('Radial/Ulnar (X) Direction','FontSize',24);
ylabel('Excursion [mm]','FontSize',22);
set(gca,'YLim',[-2 10],'FontSize',22);

subplot(2,1,2);
bY  = boxplot([cell2mat(distTraveled{1}(:,3)),cell2mat(distTraveled{2}(:,3))],...
    {'CTS Patients','Healthy Patients'},'notch','off','widths',.2);
title('Palmal/Dorsal (Y) Direction','FontSize',24);
ylabel('Excursion [mm]','FontSize',22);
set(gca,'YLim',[-2 10],'FontSize',22);

% subplot(3,1,3);
% bT  = boxplot([cell2mat(distTraveled{1}(:,4)),cell2mat(distTraveled{2}(:,4))],...
%     {'CTS Patients','Healthy Patients'},'notch','off','widths',.2);
% title('Total (Euclidean) Direction','FontSize',16);
% ylabel('Excursion [mm]','FontSize',16);
% set(gca,'YLim',[-2 10],'FontSize',16);

set(findall(gcf,'type','axes'),'LineWidth',4,'FontWeight','bold');
set(gcf,'color',[1 1 1]);

