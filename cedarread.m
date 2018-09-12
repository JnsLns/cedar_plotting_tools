    
function simdata = cedarread(paths,files,names,remDblFrames)
% CEDARREAD Read data files recorded in CEDAR.
% 
%   simdata = CEDARREAD(paths,files) loads *.csv files that contain Cedar simulation
%   data. File names must be supplied as strings in a 1d cell array
%   (files), as well as the corresponding paths (paths). If only one file
%   is imported, both of these arguments may be strings. If the path is 
%   identical for all files, only one path may be provided which is then
%   used for all files.
%
%   The output (simdata) is an array of structs, with each struct therein
%   containing multiple data fields. Each data field holds the properties
%   of the simulation data from one of the imported files (struct order in the
%   array corresponds to supplied order of file and path names). 
%
%   simdata = CEDARREAD(paths,files,names) adds the strings supplied in 1d cell
%   array names to the output structs' name field (order accords with file list).
%   May be a string if only one field is loaded. If omitted or if it is an empty
%   cell array, file names are used as names in the data structs.
%
%   simdata = CEDARREAD(paths,files,names,remDblFrames) allows to specify
%   whether simulation frames with identical time stamps are discarded
%   (remDblFrames == 1) or not (remDblFrames ~= 1). The first frame with that
%   time stamp is retained. Argument is optional, default is 0. This is
%   normally not needed but is a fix for an older recording bug in portable
%   Windows versions of Cedar.
% 
%   Output simdata is an array of structs. Each struct in the array contains
%   all data extracted from one of the input files and has the following fields:
%
%      name        String obtained from input argument names (or file name, if
%                  argument was not supplied or empty).
%      activation  Numeric array of variable dimensionality. First dimension
%                  spans time steps, remaining dimensions represent dimensions
%                  of the input element.
%      seconds     Simulation time stamps in seconds.
%      size        Data size along each dimension.
%      nDims       Number of dimensions of input data, not counting time
%                  (e.g., 3 for a 3D field).
%      nFrames     Number of time steps in the final output data.
%      nDiscarded  Number of time steps deleted from data due to duplicate
%                  time stamps (NaN if remDblFrames~=1).
   

if nargin < 4
    remDblFrames = 0;
end

if nargin < 3 || isempty(names)            
     names = files;
end

% if files, paths, or names not supplied in cell arrays, try converting,
% assuming they are strings.
if ~iscell(files)
    files = {files};
end
if ~iscell(paths)
    paths = {paths};
end
if ~iscell(names)
    names = {names};
end

nFiles = numel(files);

% if only one path is given, use it for all file names
if nFiles > 1 && numel(paths) == 1
    paths = repmat(paths,1,nFiles);
end

% go through files and extract data
for curFile = 1:nFiles
   
    % Get size            
    fid = fopen([paths{curFile} files{curFile}]);
    first_line = fgetl(fid);
    matProps = textscan(first_line ,'%s', 'Delimiter', ',');    
    sz = cellfun(@(x) str2double(x),matProps{1}(3:end))';     
    % Get timestamps (note: textscan continues at line 2)                    
    secCol = textscan(fid,'%s %*[^\n]','Delimiter',{','});                        
    timestamps = str2double(strrep(secCol{1},' s',''));                       
    
    % Read activation data from file (each row is activation at one time step)             
    totalLen = cumprod(sz);
    totalLen = totalLen(end);
    frewind(fid);    
    actTemp = cell2mat(textscan(fid,['%*s' repmat(' %f ',1,totalLen)],'Delimiter',',','HeaderLines',1));    
    fclose(fid);      
    
    % Remove frames with identical time stamps        
    if remDblFrames == 1                
        keepRows = logical([diff(timestamps);1]);
        actTemp = actTemp(keepRows,:);
        timestamps = timestamps(keepRows);                     
        nDiscarded = sum(~keepRows);   
    else
        nDiscarded = NaN;
    end       
    
    % Name
    simdata(curFile).name = names{curFile};  
    
    % Reshape activation into multidimensional array such that first dimension
    % is time steps and remaining dimensions are those of the input data structure
    simdata(curFile).activation = reshape(actTemp,[size(actTemp,1),sz]);                          
    
    % other output 
    simdata(curFile).seconds = timestamps;
    simdata(curFile).size = sz;    
    simdata(curFile).nDims = sum(sz~=1);    
    simdata(curFile).nFrames = size(actTemp,1);                      
    simdata(curFile).nDiscarded = nDiscarded;
    
end