 
% Cedar Output Beautification :)
% Jonas Lins 2017
 
% _____What's this?_____

% This allows to load recorded time series data recorded in cedar (*.csv),
% plots it in an interface that allows playing back the evolution over time
% and selecting time steps for final output. It then generates/exports a more
% or less publication ready pdf-figure.
 
% Requires export_fig (Available on MATLABcentral.com)
 
% _____HOW TO_____
 
% Take a look at SETTINGS below. Put in the display names for the fields
% you will provide as csv files into fieldNames (or other 2d data). At
% least one field must be specified.
 
% Do the same for nodes and nodeNames. (You can leave nodeNames empty, but
% an empty node plot will still be generated).
 
% The only other mandatory thing to adjust is assignNodeAxes (most simply,
% put 1 in there for each node in nodeNames, e.g. [1 1 1] for three nodes).
 
% Run the script. It will ask you to select the files corresponding to the
% field/node names you have entered before (title of load dialog specifies
% which field/node for each file).
 
% Some processing will be done. This might take a few minutes. Then the
% interface pops up.
 
% Select some snapshots ("+Snapshot"). Setting start/end is optional. Press
% plot. Then export.

% _____NOTES_____
 
% This was with the heisse Nadel gestrickt and is somewhat messy, sure
% has bugs, and is not completely versatile.
 
% Currently only handles 2D fields and 0D nodes. (Code for 1D should be
% straightforward though).



% SETTINGS ---------------------------------------------------------------

% load filenames, paths and filenames for nodes and fields? (overrides
% names below and skips file selection step; i.e., only the one file needs to be selected)
doLoad = 1;

% Provide the field names and node names here. 
% Use sprintf('Blabla\nbla') for multiline names and other formatting.
nodeNames = ...
    {'ref int',...
    'ref cos',...
    'tgt int',...
    'tgt cos',...
    'tgt pre',...
    'spt int',...
    'spt cos',...
    'mem spt a',...
    'mem spt b',...
    'mem spt l',...
    'mem spt r',...
    'pro spt a',...
    'pro spt b',...
    'pro spt l',...
    'pro spt r',...
    'mem ref r',...
    'mem ref g',...
    'mem ref b',...
    'mem tgt r',...
    'mem tgt g',...
    'mem tgt b',...
    'pro ref r',...
    'pro ref g',...
    'pro ref b',...
    'pro tgt r',...
    'pro tgt g',...
    'pro tgt b'};
fieldNames1d = ...
    {'col int', ...
    'col cos', ...
    'col cod'};
fieldNames2d = ...
    {'perc red', ...
    'perc green', ...
    'perc blue', ...
    'ref', ...
    'ref ior', ...
    'tgt cand', ...
    'tgt resp', ...
    'rel cos', ...
    'rel cod', ...
    'visScene'};

nodePlotYLims = [-15 15;-15 15]; % Ylimits for node plots; one row per plot (in order defined above)
colorLimits = [-10, 5]; % color limits for field plots

%actAxLabel = 'Activation';
%xTickStep = .5; % distance btw x ticks on node axis (seconds)
%showZeroLine = true; % for node plots
%zeroLineColor = [.8 .8 .8];
%useFontSize = 10; % for output figure
%useFont = 'Palatino Linotype'; % for output figure
useColorMap = parula;
%nodePlotLineWidth = 1; % for node activation
%nodeAxStylize = true; 
%nodeAxBgColor = [.95 .95 .95]; % only effective if nodeAxStylize==1

% Lines marking snapshot times in node plots
%snapshotMarker.color = [.65 .65 .65];
%snapshotMarker.style = ':';
%snapshotMarker.width = 1;

% Iteration settings (does not need to be touched usually)
stepsPerSimSecond = 100; % Loop iterations per second total simulation time in input time stamps
pausePerStep = 1/stepsPerSimSecond; % seconds per iteration

% Discard timesteps (may be required when dealing with certain cedar recording
% quirks :) should not hurt in any case
removeFramesSharingTimestamp = true;

% END OF SETTINGS --------------------------------------------------------



%% Get files

if doLoad
    [file_preprocessed, path_preprocessed] = uigetfile('*.mat');
    load([path_preprocessed, file_preprocessed]);
else
    
    nNodes =  numel(nodeNames);
    nFields1d = numel(fieldNames1d);
    nFields2d = numel(fieldNames2d);
    % will be filled in callback
    
    % Get node and field files (from cedar)
    
    % Get node data files
    nodeFiles = cell(size(nodeNames));
    nodePaths = cell(size(nodeNames));
    startDir = '';
    for curNode = 1:nNodes
        try
            startDir =  nodePaths{curNode-1};
        end
        curNodeName = nodeNames{curNode};
        [nodeFiles{curNode} nodePaths{curNode}] = uigetfile('*.csv',['Select file for node ' curNodeName '.'],startDir);
    end
    
    % Get 1D field data files
    fieldFiles1d = cell(size(fieldNames1d));
    fieldPaths1d = cell(size(fieldNames1d));
    for curField = 1:nFields1d
        try
            startDir =  fieldPaths1d{curField-1};
        end
        curFieldName = fieldNames1d{curField};
        [fieldFiles1d{curField} fieldPaths1d{curField}] = uigetfile('*.csv',['Select file for field ' curFieldName '.'],startDir);
    end
    
    % Get 2D field data files
    fieldFiles2d = cell(size(fieldNames2d));
    fieldPaths2d = cell(size(fieldNames2d));
    for curField = 1:nFields2d
        try
            startDir =  fieldPaths2d{curField-1};
        end
        curFieldName = fieldNames2d{curField};
        [fieldFiles2d{curField} fieldPaths2d{curField}] = uigetfile('*.csv',['Select file for field ' curFieldName '.'],startDir);
    end
    
end

%% Process / reshape input data

disp('Processing input data. This might take a while...');

for curNode = 1:nNodes
    % Get field size
    fid = fopen([nodePaths{curNode} nodeFiles{curNode}]);
    first_line = fgetl(fid);
    matProps = textscan(first_line ,'%s', 'Delimiter', ',');
    nodes(curNode).width = str2double(matProps{1}{3});
    nodes(curNode).height = str2double(matProps{1}{4});
    fclose(fid);
    % Get timestamps
    data = readtable([nodePaths{curNode} nodeFiles{curNode}]);
    nodes(curNode).seconds = str2double(strrep(data{:,1},' s',''));
    % Get node data
    nodes(curNode).activation = csvread([nodePaths{curNode} nodeFiles{curNode}],1,1);
    % Remove frames with identical time stamps
    if removeFramesSharingTimestamp
        disp(['Discarding ' num2str(sum(diff(nodes(curNode).seconds)==0)) ' frames with identical time stamps for node ' nodeNames{curNode} '.']);
        nodes(curNode).activation = nodes(curNode).activation(logical([diff(nodes(curNode).seconds);1]));
        nodes(curNode).seconds = nodes(curNode).seconds(logical([diff(nodes(curNode).seconds);1]));
    end
    % Get number of frames for this node
    nodes(curNode).nFrames = numel(nodes(curNode).activation);
    % Node name
    nodes(curNode).name = nodeNames{curNode};
end

for curField = 1:nFields1d
    % Get field size
    fid = fopen([fieldPaths1d{curField} fieldFiles1d{curField}]);
    first_line = fgetl(fid);
    matProps = textscan(first_line ,'%s', 'Delimiter', ',');
    fields1d(curField).width = str2double(matProps{1}{3});
    fields1d(curField).height = str2double(matProps{1}{4});
    fclose(fid);
    % Get timestamps
    data = readtable([fieldPaths1d{curField} fieldFiles1d{curField}]);
    fields1d(curField).seconds = str2double(strrep(data{:,1},' s',''));
    % Get field data and reshape into 3d % TODO TODO TODO adjust to 1d
    ftmp = csvread([fieldPaths1d{curField} fieldFiles1d{curField}],1,1);
    fields1d(curField).activation = reshape(ftmp',fields1d(curField).width,fields1d(curField).height,size(ftmp,1));
    % Remove frames with identical time stamps
    if removeFramesSharingTimestamp
        disp(['Discarding ' num2str(sum(diff(fields1d(curField).seconds)==0)) ' frames with identical time stamps for field ' fieldNames1d{curField} '.']);
        fields1d(curField).activation = fields1d(curField).activation(:,:,logical([diff(fields1d(curField).seconds);1]));
        fields1d(curField).seconds = fields1d(curField).seconds(logical([diff(fields1d(curField).seconds);1]));
    end
    % Get number of frames for this field
    fields1d(curField).nFrames = size(fields1d(curField).activation,3);
    % Field name
    fields1d(curField).name = fieldNames1d{curField};
end

for curField = 1:nFields2d
    % Get field size
    fid = fopen([fieldPaths2d{curField} fieldFiles2d{curField}]);
    first_line = fgetl(fid);
    matProps = textscan(first_line ,'%s', 'Delimiter', ',');
    fields2d(curField).width = str2double(matProps{1}{3});
    fields2d(curField).height = str2double(matProps{1}{4});
    fclose(fid);
    % Get timestamps
    data = readtable([fieldPaths2d{curField} fieldFiles2d{curField}]);
    fields2d(curField).seconds = str2double(strrep(data{:,1},' s',''));
    % Get field data and reshape into 3d
    ftmp = csvread([fieldPaths2d{curField} fieldFiles2d{curField}],1,1);
    fields2d(curField).activation = reshape(ftmp',fields2d(curField).width,fields2d(curField).height,size(ftmp,1));
    % Remove frames with identical time stamps
    if removeFramesSharingTimestamp
        disp(['Discarding ' num2str(sum(diff(fields2d(curField).seconds)==0)) ' frames with identical time stamps for field ' fieldNames2d{curField} '.']);
        fields2d(curField).activation = fields2d(curField).activation(:,:,logical([diff(fields2d(curField).seconds);1]));
        fields2d(curField).seconds = fields2d(curField).seconds(logical([diff(fields2d(curField).seconds);1]));
    end
    % Get number of frames for this field
    fields2d(curField).nFrames = size(fields2d(curField).activation,3);
    % Field name
    fields2d(curField).name = fieldNames2d{curField};
end

% assumed frame number is maximum number found in any of the recorded data
[nFrames, maxFrameInd] = max([[fields2d.nFrames],[fields1d.nFrames],[nodes.nFrames]]);
% note: some data may have less timestamps, but each covers the same time
% span; therefore, when iterating over time steps later, 1:nFrames is used,
% and the second values from the data with the max nFrame, while all other
% data is selected by nearest neighbor method (timewise).
tmp = cat(2,{fields2d.seconds},{fields1d.seconds},{nodes.seconds});
referenceTimeStamps = tmp{maxFrameInd}';
clearvars tmp














