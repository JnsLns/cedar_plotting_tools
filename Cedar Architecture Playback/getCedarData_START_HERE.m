% Jonas Lins, 2018

% Requires obliqueview by John Barber (available on MATLAB Central).
% Requires cedarread (should be packaged with this file).

% This script loads files recorded in Cedar (nodes, 1D fields, 2D fields).
% and stores them in a usable format, namely in the structs nodes,
% fields1d, and fields2d. E.g. fields1d.name gives the field name,
% fields1d.activation gives that field's activation history,
% fields1d.seconds the corresponding time stamps etc.

% The script will first ask to select a file for each node or field
% specified in the list below (first section after settings) and then
% gather and reshape the data from those files (second section after
% settings).

% The variables containing the preprocessed data, that is, 'nodes',
% 'fields1d', and 'fields2d', must then (manually) be saved in a mat
% file and loaded in the function archAnim to be animated.

% SETTINGS ---------------------------------------------------------------

% load filenames, paths and filenames for nodes and fields?
% If 1, this skips most of the next section where files are loaded; can be
% used if the result of that section, i.e., lists of file names and paths has
% been saved (manually) before and removes the need to select files by hand
% each time.
doLoad = 1;

% Provide the field names and node names (replace examples with your own):

nodeNames = ...
    {'ref int',...
    'ref cos',...
    'tgt int',...
    'tgt cos'};

fieldNames1d = ...
    {'col int', ...
    'col cos', ...
    'col cod'};

fieldNames2d = ...
    {'perc red', ...
    'perc green', ...
    'perc blue'};


% Discard timesteps (may be required when dealing with certain cedar recording
% quirks in some older versions :) Should not hurt in any case. Discards
% frames from the data that have the same time stamp, keeping only the
% first one with that stamp.
removeFramesSharingTimestamp = true;


% END OF SETTINGS --------------------------------------------------------



%% Get files

if doLoad
    [file_preprocessed, path_preprocessed] = uigetfile('*.mat');
    load([path_preprocessed, file_preprocessed]);
end
    
    nNodes =  numel(nodeNames);
    nFields1d = numel(fieldNames1d);
    nFields2d = numel(fieldNames2d);
    
if ~doLoad        
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
        [nodeFiles{curNode}, nodePaths{curNode}] = uigetfile('*.csv',['Select file for node ' curNodeName '.'],startDir);
    end
    
    % Get 1D field data files
    fieldFiles1d = cell(size(fieldNames1d));
    fieldPaths1d = cell(size(fieldNames1d));
    for curField = 1:nFields1d
        try
            startDir =  fieldPaths1d{curField-1};
        end
        curFieldName = fieldNames1d{curField};
        [fieldFiles1d{curField}, fieldPaths1d{curField}] = uigetfile('*.csv',['Select file for field ' curFieldName '.'],startDir);
    end
    
    % Get 2D field data files
    fieldFiles2d = cell(size(fieldNames2d));
    fieldPaths2d = cell(size(fieldNames2d));
    for curField = 1:nFields2d
        try
            startDir =  fieldPaths2d{curField-1};
        end
        curFieldName = fieldNames2d{curField};
        [fieldFiles2d{curField}, fieldPaths2d{curField}] = uigetfile('*.csv',['Select file for field ' curFieldName '.'],startDir);
    end           
    
end

%% Process / reshape input data

disp('Processing input data. This might take a (long) while...');

% Load and process cedar data
nodes = cedarread(nodePaths,nodeFiles,nodeNames,removeFramesSharingTimestamp);
fields1d = cedarread(fieldPaths1d,fieldFiles1d,fieldNames1d,removeFramesSharingTimestamp);
fields2d = cedarread(fieldPaths2d,fieldFiles2d,fieldNames2d,removeFramesSharingTimestamp);















