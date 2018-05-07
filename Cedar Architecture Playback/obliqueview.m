function hOut = obliqueview(varargin)
% View an axes using an oblique projection
%
% SYNTAX
%
%   OBLIQUEVIEW
%   OBLIQUEVIEW(VPLANE)
%   OBLIQUEVIEW(VPLANE,THETA)
%   OBLIQUEVIEW(VPLANE,THETA,RATIO)
%   OBLIQUEVIEW(VPLANE,THETA,RATIO,OAXESLOCATION)
%   OBLIQUEVIEW off
%   OBLIQUEVIEW clear
%   OBLIQUEVIEW('off')
%   OBLIQUEVIEW('clear')
%   OBLIQUEVIEW(H,...)
%   HT = OBLIQUEVIEW(...)
%
% DESCRIPTION
%
% OBLIQUEVIEW   Transform the current axes to an oblique projection using
% the xy plane, an angle of 30 degrees and a ratio of 0.5.
%
% OBLIQUEVIEW(VPLANE)  Use the plane specified by VPLANE as the viewing
% plane for the oblique projection.  Valid viewing planes are 'xy', 'xz',
% 'yx', 'yz','zx', and 'zy'.
%
% OBLIQUEVIEW(VPLANE,THETA)  Use the angle THETA as the projection angle.
% THETA should be specified in degrees.  THETA is defined as increasing
% counterclockwise from the negative horizontal axis to the out-of-page
% axis.
%
% OBLIQUEVIEW(VPLANE,THETA,RATIO)  Use the value in RATIO to scale the
% projection in the receding axis.  The default value of 0.5 results in
% the 'cabinet' projection.  A value of 1.0 for RATIO results in the
% 'cavalier' projection.
%
% OBLIQUEVIEW(VPLANE,THETA,RATIO,OAXESLOCATION)  Use the value in
% OAXESLOCATION as the origin for an oaxes central axis.  Displaying an
% oaxes object requires the File Exchange submission 'oaxes', version 2.0
% or later.  If oaxes is not installed, or OAXESLOCATION is set to 'none',
% no oaxes will be displayed.
%
% In addition to 'none', valid values of OAXESLOCATION are 'BottomLeft'
% (the default), 'BottomRight', 'TopLeft', 'TopRight', 'Center', or a 1x3
% vector specifying an origin point.  OBLIQUEVIEW will place the oaxes
% origin at the position determined by the value of OAXESLOCATION, and
% determine the proper axes limits to display the plot data and the oaxes
% object.
%
% OBLIQUEVIEW off
% OBLIQUEVIEW clear
% OBLIQUEVIEW('off')
% OBLIQUEVIEW('clear')   Undo the oblique projection and restore the axes
% and plot objects to their prior state.
%
% OBLIQUEVIEW(H,...)   Use the axes specified by H instead of the current
% axes.
%
% HT = OBLIQUEVIEW(...)   Return the handle of the hgtransform in HT.
%
% Note: Passing the empty matrix, [], as an input will cause OBLIQUEVIEW to
% use the default value for that input parameter.
%
% REMARKS
%
% OBLIQUEVIEW creates an hgtransform object in the specified axes, places
% all plot objects into the hgtransform, and sets the transform's 'Matrix'
% property to a shear transformation matrix, resulting in an oblique 
% projection.
%
% The axes view is set to a 2D view, determined by the selected viewing
% plane.  Viewing the results of OBLIQUEVIEW from another viewing angle
% will give distorted results.
%
% OBLIQUEVIEW is designed to be used with oaxes, a central axis display.
% oaxes is available through the MATLAB File Exchange at
% http://www.mathworks.com/matlabcentral/fileexchange/30018 . If oaxes is
% not installed, OBLIQUEVIEW will still run, but with reduced
% functionality.
%
% The current implementation of OBLIQUEVIEW is static - adding new plot
% objects to the axes will result in a mixture of oblique and orthographic
% projections.  The workaround is to set any new plot objects' 'Parent'
% property to HT, the handle of the OBLIQUEVIEW hgtransform.  You may have
% to adjust axes limits and oaxes settings manually after adding new
% objects to the axes.
%
% REFERENCES
% 
% http://en.wikipedia.org/wiki/Oblique_projection
% http://en.wikipedia.org/wiki/Projection_(linear_algebra)
% http://en.wikipedia.org/wiki/Orthographic_projection
% 
% Download oaxes at:
% http://www.mathworks.com/matlabcentral/fileexchange/30018
%
% EXAMPLE
%
% Draw some boxes:
% figure
% view(20,20)
% grid on
% box on
% set(gca,'DataAspectRatio',[1 1 1])
% line(0,0,0,'marker','o','color','k','markerFaceColor','k')
% x = [0  1  1  0  0  0  1  1  0  0  1  1  1  1  0  0];
% y = [0  0  1  1  0  0  0  1  1  0  0  0  1  1  1  1];
% z = [0  0  0  0  0  1  1  1  1  1  1  0  0  1  1  0];
% line(x,y,z,'color','k','linewidth',1)
% line(x+1,y,z,'color','b')
% line(x,y+1,z,'color','g')
% line(x,y,z+1,'color','r')
% v = [1 0 0; 1 0 1; 1 1 1; 1 1 0];
% f = [1 2 3 4];
% patch('vertices',v,'faces',f,'facecolor',[0 0 .5],'facealpha',.3)
% v(:,1) = 2;
% patch('vertices',v,'faces',f,'facecolor',[0 0 .5],'facealpha',1)
% v(:,1) = 0;
% patch('vertices',v,'faces',f,'facecolor','b','facealpha',1)
% v = [0 1 0; 0 1 1; 1 1 1; 1 1 0];
% f = [1 2 3 4];
% patch('vertices',v,'faces',f,'facecolor',[0 .5 0],'facealpha',.3)
% v(:,2) = 2;
% patch('vertices',v,'faces',f,'facecolor',[0 .5 0],'facealpha',1)
% v(:,2) = 0;
% patch('vertices',v,'faces',f,'facecolor',[0 .5 0],'facealpha',1)
% v = [0 0 1; 0 1 1; 1 1 1; 1 0 1];
% f = [1 2 3 4];
% patch('vertices',v,'faces',f,'facecolor',[.5 0 0],'facealpha',.3)
% v(:,3) = 2;
% patch('vertices',v,'faces',f,'facecolor',[.5 0 0],'facealpha',1)        
% v(:,3) = 0;
% patch('vertices',v,'faces',f,'facecolor','r','facealpha',1)   
% 
% % Transform the axes to an oblique projection in the x-z plane, with an
% % angle of 40 degrees:
% obliqueview('xz',40)
% 
% % View in the x-y plane, with an angle of 150 degrees and a 
% % foreshortening ratio of 1:
% obliqueview('xy',150,1,'bottomright')
%
% See also AXES OAXES
%

% $$FileInfo
% $Filename: obliqueview.m
% $Path: $toolboxroot/
% $Product Name: obliqueview
% $Product Release: 1.0
% $Revision: 1.0.55
% $Toolbox Name: Custom Plots Toolbox
% $$
%
% Copyright (c) 2010-2011 John Barber.
%
% Release History:
% v 1.0 : 2011-Mar-29
%       - Initial release
%

%% Default values
vPlane = 'xy';
theta = 30;
ratio = 0.5;
O = [0 0 0];
oaxesLoc = 'BottomLeft';

vpList = {'xy','xz','yx','yz','zx','zy','off','clear'};
locList = {'none','BottomLeft','BottomRight','center','TopLeft',...
    'TopRight'};
%% Parse inputs

% Check for axes handle
if nargin > 0 && isscalar(varargin{1}) && ishandle(varargin{1}) 
    if strcmp(get(varargin{1},'Type'),'axes')
        hAx = varargin{1};
        varargin(1) = [];
    else
        % Error here
    end
else
    hAx = gca;
end

% Assign and validate inputs
nargs = length(varargin);

% Get view plane
if nargs > 0 && ~isempty(varargin{1})
    vPlane = lower(varargin{1});
    if ~any(strcmp(vPlane,vpList))
        eID = [mfilename ':InvalidVPlane'];
        commas = [repmat({', '},length(vpList)-1,1); '.'];
        list = [vpList' commas]';
        list = list(:)';
        eStr = ['Invalid argument.  VPlane must be one of: ' list{:}];
        error(eID,eStr)
    end
end

% Get theta
if nargs > 1 && ~isempty(varargin{2})
    theta = varargin{2};
    
    if ~isnumeric(theta) || ~isreal(theta) || ~isscalar(theta)
        eID = [mfilename ':InvalidTheta'];
        eStr = 'Theta must be a real scalar.';
        error(eID,eStr)
    end
    
    % Restrict theta to [0 360]
    while theta < 0
        theta = theta + 360;
    end
    while theta > 360
        theta  = theta - 360;
    end
end

% Get ratio
if nargs > 2 && ~isempty(varargin{3})
    ratio = varargin{3};
    if ~isnumeric(ratio) || ~isreal(ratio) || ~isscalar(ratio) || ...
            ratio <= 0
        eID = [mfilename ':InvalidRatio'];
        eStr = 'Ratio must be a real, positive scalar.';
        error(eID,eStr)
    end
end

% Get oaxes location
if nargs > 3
    oaxesLoc = varargin{4};
    if isnumeric(oaxesLoc)
        O = oaxesLoc;
        oaxesLoc = 'origin';
    else
        if ~any(strcmpi(oaxesLoc,locList))
            eID = [mfilename ':InvalidOAxesLocation'];
            commas = [repmat({', '},length(locList)-1,1); '.'];
            list = [locList' commas]';
            list = list(:)';
            eStr = ['OAxesLocation must be one of: ' list{:}];
            error(eID,eStr)
        end
    end
end

% List of axes and oaxes properties to set/restore
axesPropList = {'View';
                'CameraUpVector';
                'DataAspectRatio';
                'DataAspectRatioMode';
                'Projection';
                'XDir'; 'YDir'; 'ZDir';
                'XScale'; 'YScale'; 'ZScale';
                'XLim'; 'YLim'; 'ZLim';
                'XLimMode'; 'YLimMode'; 'ZLimMode'
                }';
oaxesPropList = {'Origin';
                 'OriginMode';
                 'Force3D';
                 'ListenersEnabled';
                 'HideParentAxes';
                 'HideParentAxesMode';
                 'TickOrientation';
                 'XLim'; 'YLim'; 'ZLim';
                 'XLimMode'; 'YLimMode'; 'ZLimMode';
                 'XTick'; 'YTick'; 'ZTick';
                 'XTickLabel'; 'YTickLabel'; 'ZTickLabel';
                 'XTickMode'; 'YTickMode'; 'ZTickMode';
                 'XTickLabelMode'; 'YTickLabelMode'; 'ZTickLabelMode';
                 }';
             
% Handle 'off'/'clear'
if any(strcmp(vPlane,{'off','clear'}))
    hT = findobj(hAx,'Tag','ObliqueView');
    if isempty(hT)
        return
    end
    set(get(hT,'Children'),'Parent',hAx)
    % Resore previous axes state
    if isappdata(hT,'AxesPreviousState')
        set(hAx,axesPropList,getappdata(hT,'AxesPreviousState'))
    end
    if isappdata(hT,'OAxesPreviousState')
        % Restore previous oaxes state
        OA = findobj(hAx,'Tag','oaxes','-and','Type','hggroup');
        if ~isempty(OA)
            % Turn off listeners
            enableState = get(OA,'ListenersEnabled');
            set(OA,'ListenersEnabled','off');
            
            % Restore oaxes state
            set(OA,oaxesPropList,getappdata(hT,'OAxesPreviousState'))
            
            % Restore listener state
            set(OA,'ListenersEnabled',enableState);
        end
    end
    delete(hT)
    return
end

% Check for oaxes existence, and get oaxes handle or create oaxes
if exist('oaxes.m','file') == 2 && ~any(strcmpi(oaxesLoc,{'none','off'}))
    hasOAxes = true;
    % Find existing oaxes or create a new one
    OA = oaxes(hAx);
    
    % Get current oaxes state to restore later
    OAState = get(OA,oaxesPropList);
    OAEnabled = get(OA,'ListenersEnabled');
    
    % Freeze the oaxes for now
    OA.freeze;
else
    hasOAxes = false;
    
    % If user requested oaxes, issue a warning
    if ~strcmpi(oaxesLoc,'none')
        wID = [mfilename ':OAxesNotFound'];
        wStr = 'Could not find oaxes.m - oaxes will not be drawn.';
        warning(wID,wStr)
    end
end

% Get settings based on vPlane
switch lower(vPlane)
    case 'xy'
        I = 1;
        J = 2;
        K = 3;
        IName = 'X';
        JName = 'Y';
        KName = 'Z';
        az = 0;
        el = 90;
        camUp = [0 1 0];
        sgn = -1;
        tickOrientation = {'zxx','yxy'};
    case 'xz'
        I = 1;
        J = 3;
        K = 2;
        IName = 'X';
        JName = 'Z';
        KName = 'Y';
        az = 0;
        el = 0;
        camUp = [0 0 1];
        sgn = 1;
        tickOrientation = {'yxx','zzx'};
    case 'yx'
        I = 2;
        J = 1;
        K = 3;
        IName = 'Y';
        JName = 'X';
        KName = 'Z';
        az = 90;
        el = -90;
        camUp = [1 0 0];
        sgn = 1;
        tickOrientation = {'yzy','yxx'};
    case 'yz'
        I = 2;
        J = 3;
        K = 1;
        IName = 'Y';
        JName = 'Z';
        KName = 'X';
        az = 90;
        el = 0;
        camUp = [0 0 1];
        sgn = -1;
        tickOrientation = {'yxy','zzy'};
    case 'zx'
        I = 3;
        J = 1;
        K = 2;
        IName = 'Z';
        JName = 'X';
        KName = 'Y';
        az = 180;
        el = 0;
        camUp = [1 0 0];
        sgn = -1;
        tickOrientation = {'zzy','zxx'};
    case 'zy'
        I = 3;
        J = 2;
        K = 1;
        IName = 'Z';
        JName = 'Y';
        KName = 'X';
        az = 270;
        el = 0;
        camUp = [0 1 0];
        sgn = 1;
        tickOrientation = {'zzx','yzy'};
end

% Get current axes state to restore later
curState = get(hAx,axesPropList);

% Set axes properties
view(hAx,az,el)
set(hAx,'CameraUpVector',camUp)
set(hAx,'DataAspectRatio',[1 1 1])
set(hAx,'Projection','orthographic')
set(hAx,'XDir','normal','YDir','normal','ZDir','normal')
set(hAx,'XScale','linear','YScale','linear','ZScale','linear')
set(hAx,'XLimMode','auto','YLimMode','auto','ZLimMode','auto')

%% Do oblique transform

% Create transform matrix
T = eye(4);
T(I,K) = sgn*ratio*cosd(theta);
T(J,K) = sgn*ratio*sind(theta);

% Look for an exisiting obliqueview hgtransform.  If not found, create a 
% new one.
hT = findobj(hAx,'Type','hgtransform','-and','Tag','ObliqueView');
if isempty(hT)
    hT = hgtransform('Matrix',T,'Parent',hAx,'Tag','ObliqueView');
else
    set(hT,'Matrix',T)
end

% Set output argument
if nargout == 1
    hOut = hT;
end

% Put axes children into the hgtransform
hC = get(hAx,'Children');
hC(hC == hT) = [];
set(hC,'Parent',hT)
drawnow

% Store axes state
setappdata(hT,'AxesPreviousState',curState)

if ~hasOAxes
    % Expand limits and exit
    axLims = [get(hAx,'XLim')' get(hAx,'YLim')' get(hAx,'ZLim')'];
    set(hAx,'XLim',getNiceLims(axLims(:,1)'))
    set(hAx,'YLim',getNiceLims(axLims(:,2)'))
    set(hAx,'ZLim',getNiceLims(axLims(:,3)'))
    
    return
end

%% Get initial limits for oaxes calculations

% Get axis limits
axLims = [get(hAx,'XLim')' get(hAx,'YLim')' get(hAx,'ZLim')'];

% Get bounding box of the plot objects in hAx
objLims = objbounds(hAx);
if isempty(objLims)
    objLims = axLims;
end

% Split into un-transformed I,J,K limits
objILims = objLims(2*(I-1)+[1 2]);
objJLims = objLims(2*(J-1)+[1 2]);
objKLims = objLims(2*(K-1)+[1 2]);

% Apply the transform to the bounding box to get a transformed bounding box
bBox = [objLims(1) objLims(3) objLims(5) 1;
        objLims(1) objLims(4) objLims(5) 1;
        objLims(1) objLims(3) objLims(6) 1;
        objLims(1) objLims(4) objLims(6) 1;
        objLims(2) objLims(3) objLims(5) 1;
        objLims(2) objLims(4) objLims(5) 1;
        objLims(2) objLims(3) objLims(6) 1;
        objLims(2) objLims(4) objLims(6) 1]';
    
tBox = T*bBox;
tLims = [min(tBox(1,:)) max(tBox(1,:)) ...
         min(tBox(2,:)) max(tBox(2,:)) ...
         min(tBox(3,:)) max(tBox(3,:))];

% Get transformed K bounds
objKLimsT = tLims(2*(K-1)+[1 2]);

%% Calculate limits and origin for oaxes

% Initial limits
ILims = getNiceLims(axLims(:,I)');
JLims = getNiceLims(axLims(:,J)');
KLims = objKLimsT;

% Get origin and modify I,J limits if needed
switch lower(oaxesLoc)
    case 'center'
        % Origin is centered to limits
        O(I) = mean(ILims);
        O(J) = mean(JLims);
        O(K) = mean(KLims);
        
    case 'origin'
        % Already have an origin from user input
        
        % Expand I,J limits to include origin
        if ILims(1) > O(I)
            ILims(1) = O(I);
        end
        
        if ILims(2) < O(I)
            ILims(2) = O(I);
        end
        
        if JLims(1) > O(J)
            JLims(1) = O(J);
        end
        
        if JLims(2) < O(J)
            JLims(2) = O(J);
        end           
               
    otherwise
        
        % Get I origin
        if any(strcmpi(oaxesLoc,{'TopLeft','BottomLeft'}))
            O(I) = objILims(1);
        else
            O(I) = objILims(2); 
        end
        
        % Get J origin
        if any(strcmpi(oaxesLoc,{'Bottomleft','BottomRight'}))
            O(J) = objJLims(1);
        else
            O(J) = objJLims(2);
        end
        
        % Get K origin
        O(K) = objKLims(1 + double(sgn==1));
end

% Determine K limits by extending out from O to intersect I and J limits
KI1 = (ILims(1) - O(I))/T(I,K);
KI2 = (ILims(2) - O(I))/T(I,K);
KJ1 = (JLims(1) - O(J))/T(J,K);
KJ2 = (JLims(2) - O(J))/T(J,K);

% Set up vector of test points
testPoints = zeros(4,4);
testPoints(I,:) = O(I)*[1 1 1 1];
testPoints(J,:) = O(J)*[1 1 1 1];

if (90 < theta && theta < 180) || (270 < theta && theta < 360)
    testPoints(K,:) = [KI1 KJ2 KI2 KJ1];
    a = 2;
    b = 1;
    sgnJK = -1;
else
    testPoints(K,:) = [KI1 KJ1 KI2 KJ2];
    a = 1;
    b = 2;
    sgnJK = 1;
end

% Apply transform to test points
testProj = T*testPoints;

% Find K limit for left side
if sgnJK*testProj(J,1) > sgnJK*(JLims(a) + 100*eps(JLims(a)))
    KLims(1) = testProj(K,1);
else
    KLims(1) = testProj(K,2);
end

% Find K limit for right side
if sgnJK*testProj(J,3) < sgnJK*(JLims(b) - 100*eps(JLims(b)))
    KLims(2) = testProj(K,3);
else
    KLims(2) = testProj(K,4);
end

% Ensure K limits are in correct order
KLims = sort(KLims);
oaxesKLims = KLims;

if strcmpi(oaxesLoc,'origin')
    % Make sure KLims include the origin and object data
    KLims(1) = min(min(O(K),objKLimsT(1)),KLims(1));
    KLims(2) = max(max(O(K),objKLimsT(2)),KLims(2));
end

% Set limits
set(hAx,[IName 'Lim'],ILims)
set(hAx,[JName 'Lim'],JLims)
set(hAx,[KName 'Lim'],KLims)

% Store axis info
ObliqueViewInfo.I = I;
ObliqueViewInfo.J = J;
ObliqueViewInfo.K = K;
ObliqueViewInfo.O = O;

setappdata(hT,'ObliqueViewInfo',ObliqueViewInfo)

%% Set oaxes properties

% Store current oaxes state to restore later
setappdata(hT,'OAxesPreviousState',OAState);

% Set origin if necessary
if ~strcmpi(oaxesLoc,'center')
    OA.Origin = O;
end  

% Hide parent axes since it is not useful with obliqueview
OA.HideParentAxes = 'on';

% Force display of K axis
OA.Force3D = 'on';

% Set tick orientation
if theta < 30 || (150 < theta && theta < 210) || theta > 330
    idx = 2;
else
    idx = 1;
end
OA.TickOrientation = tickOrientation{idx};

% Set X/Y/ZLim
XYZLims = zeros(2,3);
XYZLims(:,I) = ILims';
XYZLims(:,J) = JLims';
XYZLims(:,K) = oaxesKLims';
OA.XLim = XYZLims(:,1)';
OA.YLim = XYZLims(:,2)';
OA.ZLim = XYZLims(:,3)';

% Set X/Y/ZTickMode to 'auto'
OA.XTickMode = 'auto';
OA.YTickMode = 'auto';
OA.ZTickMode = 'auto';

% Force a redraw of the oaxes
OA.ListenersEnabled = 'on';
drawnow

% Reset listener state
OA.ListenersEnabled = OAEnabled;

end % End of obliqueview
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function niceLims = getNiceLims(lims)
% Expand limits to 'nice' values outside of original limits.

%% Constants
% Minimum expansion amount (% of full scale, per side)
minExp = 0.15;

% Expansion goal (% of full scale, per side)
tgtExp = minExp*1.25;

%% Get expanded limits
% If limits are negative, flip them around to do the calculation
if lims(2) == 0 || abs(lims(2)) < abs(lims(1))
    lims = -fliplr(lims);
    allNeg = true;
else
    allNeg = false;
end

range = lims(2) - lims(1);
decRange = log10(abs(range));
decMax = floor(log10(max(abs(lims))));

if lims(1) <= 0
    decRange = 1;
end

expLims = lims + range*[-tgtExp tgtExp];
minLims = lims + range*[-minExp minExp];

% Get upper limit
if decRange > 0.4
    vec = [2 3 4 5 6 7 8 9 10 11 12 13 14 15]*10^decMax;
elseif decRange >= 0
    vec = [.1 .2 .3 .4 .5 .6 .7 .8 .9 1 1.1 1.2] + ...
        floor(lims(2)*10^(-decMax+1))/10^(-decMax+1);
else
    dec = floor(decRange-1);
    vec = [0 1 2 3 4 5 6 7 8 9 10 11 12 15 20 30 40 50]*10^(dec) + ...
        floor(lims(2)*10^(-dec))/10^(-dec);
end

d = abs(expLims(2) - vec);
d(vec < minLims(2)) = 100*d(vec < minLims(2));
[dMin,idx] = min(d); %#ok<ASGLU>
ULim = vec(idx);

% Get lower limit
if decRange > 0.4
    if idx == 1
        vec = [-2 -1 -0.5 -0.2 -0.1 0 0.1 0.2 0.5 1];
    elseif idx == 2
        vec = [-3 -2 -1 0.5 0 0.5 1 2];
    elseif idx == 3
        vec = -4:3;
    elseif idx == 4
        vec = -5:4;
    elseif idx == 5
        vec = -6:5; 
    elseif idx == 6
        vec = -7:6;
    elseif idx == 7
        vec = [-8 -6 -4 -2 -1 0 1 2 3 4 5 6 7];
    else
        vec = -idx-1:(idx);
    end
    vec = vec*10^decMax;
    
elseif decRange >= 0
    vec = -[.1 .2 .3 .4 .5 .6 .7 .8 .9 1 1.1 1.2] + ...
        floor(lims(1)*10^(-decMax+1))/10^(-decMax+1);
else
    vec = -[0 1 2 3 4 5 6 7 8 9 10 11 12 15 20 30 40 50]*10^(dec) + ...
        floor(lims(1)*10^(-dec))/10^(-dec);
end

d = abs(expLims(1) - vec);
d(vec > minLims(1)) = 100*d(vec > minLims(1));
[dMin,idx] = min(d);  %#ok<ASGLU>
LLim = vec(idx);

if ~allNeg
    niceLims = [LLim ULim];
else
    niceLims = -[ULim LLim];
end

end % End of obliqueview/niceLims
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
