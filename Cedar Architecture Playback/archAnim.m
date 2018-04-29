function archAnim

% load data
load('H:\disptmp\preprocessedData_dtrOnly_2ndtry.mat','nodes','fields1d','fields2d')
%load('H:\disptmp\preprocessedData_fullPairB_2ndtry.mat','nodes','fields1d','fields2d')

% ---- load architecture image (background)

%archImg = imread('H:\Disputation\cedar arch for disp temp 25 04\matlab stuff\architectureFINAL_dtrOnly_forVideo_deutsch.bmp');
%archImg = imread('S:\Disputation\cedar arch for disp temp 25 04\matlab stuff\architectureFINAL_fullPairB_forVideo_deutsch.bmp');
%archImg = imread('S:\Disputation\Bilder\architectureFINAL_dtrOnly_forVideo_deutsch_surf.bmp');
%archImg = imread('h:\dispTmp\Bilder\architectureFINAL_dtrOnly_forVideo_deutsch_surf.bmp');
archImg = imread('h:\dispTmp\Bilder\architectureFINAL_fullPairB_forVideo_deutsch_surf.bmp');


%% HACK

% --- !!!! Hack to shift field data along color dimension as it is set up in the figure  !!!
if ~exist('shiftDone','var')
    for i = 1:size(fields1d,2)
        warning('THERES A TEMPORARY ADJUSTMENT AT WORK THAT SHIFTS 1D DATA ALONG COLOR DIMENSION TO ACCORD TO AXIS IN FIGURE. SHOULD NOT BE USED FOR OTHER THAN THE SL MODEL DATA');
        fields1d(i).activation = circshift(fields1d(i).activation,13,2);
    end
    shiftDone = 1;
end
% HACK HACK HACK HACK !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!



%% Graphical settings

% 1 = use images, 2 = use surf
useImageOrSurf = 2;
% for surf: factor by which surf data is scaled to reduce peak height (does not apply to color data)
scaleSurfData = 0.2;
% for image: add contour lines to image maps to show suprathreshold?
addContour = 0;
contLineWidth = 1.6;
contLineStyle = ':';
contColor = 'r';

% color limits for field plots (may alternatively be set for each field individually below)
colorLimits = [-10, 5];

% node non-activcation color
nodeFaceColor = [.95 .95 .95 .85];
% range of node activation
nodeActLim = [-5 5];
% generate node base dots?
nodeBaseDots = 1;
baseDotScaleFactor = 1.25;
% node rings that indicate activation > 0
nodeRingColorEqualToBase = 0; % activation ring same color as base node or same for all nodes (then set below)
nodeRingColor = 'none'; % use 'none' to hide
nodeRingWidth = 1.6;
nodeRingScaleFactor = 1.5;
% darker colors for inactive nodes
darkenBy = 50;

% Reduce temporal resolution if animation does not run smoothly
% (reduces number of frames displayed per time below that possible based on data;
% it does not affect playback speed, except due to performance issues)
temporalResolutionMultiplier = 0.4;
% Multiplier for playback speed relative to original simulation speed
% (1 means equal to simulation speed based on data timestamps)
playbackSpeed = .25;



%% define plot properties and positions

% 2D fields

% name           visible        units          position                                     xlim                    ylim                    zlim                    CLim           img (1) or surf (2)

plots2d_properties = ...
    {'perc green',  'off',      'centimeters', [24.0540   16.8378   11.1250    4.8108],    [-1.7227,51.3020],      [0.1157,39.8843],       [-8.8026,17.7098],      colorLimits    1;...
    'perc red',    'off',      'centimeters',  [24.0540   14.8894   11.1250    4.8108],    [-1.7227,51.3020],      [0.1157,39.8843],       [-8.8026,17.7098],      colorLimits    1;...
    'perc blue',   'off',      'centimeters',  [24.0540   12.9411   11.1250    4.8108],    [-1.7227,51.3020],      [0.1157,39.8843],       [-8.8026,17.7098],      colorLimits    1;...
    'ref',         'off',      'centimeters',  [12.4961    8.0100   11.1250    4.8108],    [-1.7227,51.3020],      [0.1157,39.8843],       [-8.8026,17.7098],      colorLimits    2;...
    'ref ior',     'off',      'centimeters',  [12.4961    5.2799   11.1250    4.8108],    [-1.7227,51.3020],      [0.1157,39.8843],       [-8.8026,17.7098],      colorLimits    2;...
    'tgt cand',    'off',      'centimeters',  [24.0540    8.0100   11.1250    4.8108],    [-1.7227,51.3020],      [0.1157,39.8843],       [-8.8026,17.7098],      colorLimits    2;...
    'tgt resp',    'off',      'centimeters',  [24.0540    5.2799   11.1250    4.8108],    [-1.7227,51.3020],      [0.1157,39.8843],       [-8.8026,17.7098],      colorLimits    2;...
    'rel cos',     'off',      'centimeters',  [13.9754    1.4553   11.1250    4.8108],    [-1.7227,51.3020],      [0.1157,39.8843],       [-8.8026,17.7098],      colorLimits    2;...
    'rel cod',     'off',      'centimeters',  [22.6108    1.4553   11.1250    4.8108],    [-1.7227,51.3020],      [0.1157,39.8843],       [-8.8026,17.7098],      colorLimits    2};


% 1D fields

% name           visible      units           position                              xlim        XDir        YDir    XTick           YTick

plots1d_properties = ...
    {'col int',     'on',     'centimeters',  [16.4770 13.4245 1.7199 6.3743],      [-6,3],     'reverse',  'normal', [-6 -4 -2 0 2],   [];...
    'col cos',     'on',      'centimeters',  [18.6503 13.4245 1.7199 6.3743],      [-6,3],     'reverse',  'normal', [-6 -4 -2 0 2],   [];...
    'col cod',     'on',      'centimeters',  [20.8235 13.4245 1.7199 6.3743],      [-6,3],     'reverse',  'normal', [-6 -4 -2 0 2],  []};

% nodes

% name              visible units           position                                            basedotcolor_active

plots0d_properties = ...
    {'ref int',         'off',   'centimeters', [7.6251     20.7225    0.6615    0.6615],       [0 204 0];...
    'ref cos',         'off',   'centimeters',  [8.9276     20.7225    0.6615    0.6615],       [255 0 0];...
    'tgt int',         'off',   'centimeters',  [12.6885    20.7225    0.6615    0.6615],       [0 204 0];...
    'tgt cos',         'off',   'centimeters',  [13.9429    20.7225    0.6615    0.6615],       [255 0 0];...
    'tgt pre',         'off',   'centimeters',  [10.8243    21.4983    0.6615    0.6615],       [160 160 160];...
    'spt int',         'off',   'centimeters',  [2.5497     20.7225    0.6615    0.6615],       [0 204 0];...
    'spt cos',         'off',   'centimeters',  [3.8643     20.7225    0.6615    0.6615],       [255 0 0];...
    'mem spt a',       'off',   'centimeters',  [0.3368     8.5789     0.6615    0.6615],       [51 153 255];...
    'mem spt b',       'off',   'centimeters',  [0.3368     6.4080     0.6615    0.6615],       [51 153 255];...
    'mem spt l',       'off',   'centimeters',  [0.3368     4.2215     0.6615    0.6615],       [51 153 255];...
    'mem spt r',       'off',   'centimeters',  [0.3368     2.0530     0.6615    0.6615],       [51 153 255];...
    'pro spt a',       'off',   'centimeters',  [1.6417     8.5789     0.6615    0.6615],       [178 102 255];...
    'pro spt b',       'off',   'centimeters',  [1.6417     6.4080     0.6615    0.6615],       [178 102 255];...
    'pro spt l',       'off',   'centimeters',  [1.6417     4.2239     0.6615    0.6615],       [178 102 255];...
    'pro spt r',       'off',   'centimeters',  [1.6417     2.0530     0.6615    0.6615],       [178 102 255];...
    'mem ref r',       'off',   'centimeters',  [5.4654     16.1823    0.6615    0.6615],       [51 153 255];...
    'mem ref g',       'off',   'centimeters',  [5.4654     18.1908    0.6615    0.6615],       [51 153 255];...
    'mem ref b',       'off',   'centimeters',  [5.4654     14.1919    0.6615    0.6615]        [51 153 255];...
    'mem tgt r',       'off',   'centimeters',  [10.5519    16.1823    0.6615    0.6615],       [51 153 255];...
    'mem tgt g',       'off',   'centimeters',  [10.5519    18.1728    0.6615    0.6615],       [51 153 255];...
    'mem tgt b',       'off',   'centimeters',  [10.5519    14.1919    0.6615    0.6615],       [51 153 255];...
    'pro ref r',       'off',   'centimeters',  [6.7171     16.1823    0.6615    0.6615],       [178 102 255];...
    'pro ref g',       'off',   'centimeters',  [6.7171     18.1908    0.6615    0.6615],       [178 102 255];...
    'pro ref b',       'off',   'centimeters',  [6.7171     14.1919    0.6615    0.6615],       [178 102 255];...
    'pro tgt r',       'off',   'centimeters',  [11.7925    16.1823    0.6615    0.6615],       [178 102 255];...
    'pro tgt g',       'off',   'centimeters',  [11.7925    18.1728    0.6615    0.6615],       [178 102 255];...
    'pro tgt b',       'off',    'centimeters',  [11.7925   14.1919    0.6615    0.6615],       [178 102 255]};


% ...code from here on usually does not need to be adjusted...

%% Prepare figure etc.

% ---- prepare figure

bgSz = size(archImg);
bgSz = bgSz([1,2]);
bgAr = bgSz(2)/bgSz(1); % image aspect ratio

% figure size based on aspect ratio of background image
scrSz = get(0,'ScreenSize');

hFig = figure('Position',[0 0 bgSz(2) bgSz(1)]);
hFig.OuterPosition(1:2) = [0 scrSz(4)-hFig.OuterPosition(4)];

% hide the toolbar
set(hFig,'menubar','none')
% hide the title
set(hFig,'NumberTitle','off');

% control figure
hCtrlFig = figure('OuterPosition',[hFig.OuterPosition(1)+hFig.OuterPosition(3) hFig.OuterPosition(2) scrSz(3)*.1 scrSz(4)*.1], ...
    'menubar','none','NumberTitle','off');
hRunButton = uicontrol(hCtrlFig,'style','togglebutton','string','Run','callback',@runButton_callback);
hResetButton = uicontrol(hCtrlFig,'style','pushbutton','position', ...
    [hRunButton.Position(1) hRunButton.Position(2)+hRunButton.Position(4) hRunButton.Position(3) hRunButton.Position(4) ], ...
    'string','Restart','callback',@resetButton_callback,'userdata',0);
hStepField = uicontrol(hCtrlFig,'style','edit','string',1,'value',1,'position',...
    [hRunButton.Position(1)*2+hRunButton.Position(3) hRunButton.Position(2)+hRunButton.Position(4) hRunButton.Position(3) hRunButton.Position(4) ], ...
    'callback', @stepField_callback);

% background axes
ax_bg = axes(hFig);
ax_bg.Position = [0 0 1 1];

% add architecture image
img_bg = image(ax_bg,archImg);
%hFig.Color = [0.2 0.2 0.2];
ax_bg.Visible = 'off';

% extend node properties with column for darker colors showing inactivity
plots0d_properties(:,6) = cellfun(@(x)  max(x-darkenBy,[0 0 0]) , plots0d_properties(:,5),'uniformoutput',0);

% --- add plots to figure

tStep = 1;


%% add 2d field axes

% Make axes and images in axes (using time step 1)
if exist('fields2d','var')
    
    for curProps = plots2d_properties'
        whichDat = curProps{1};
        datNum = find(cellfun(@(curname) strcmp(curname,whichDat),{fields2d.name}));
        fields2d(datNum).ax = axes(hFig,'nextplot','add');
        if curProps{9} == 1
            fields2d(datNum).img = imagesc(fields2d(datNum).ax,flipud(squeeze(fields2d(datNum).activation(tStep,:,:))));
            if addContour
                [~, fields2d(datNum).cont] = contour([1 0; 0 0] ,1,'linestyle',contLineStyle,'lineColor',contColor,'lineWidth',contLineWidth);
                fields2d(datNum).cont.Visible = 'off';
            end
        elseif curProps{9} == 2
            fields2d(datNum).img = surf(fields2d(datNum).ax,(flipud(squeeze(fields2d(datNum).activation(tStep,:,:)))-min(flipud(squeeze(fields2d(datNum).activation(tStep,:,:)))))*scaleSurfData);
            fields2d(datNum).img.CData = flipud(squeeze(fields2d(datNum).activation(tStep,:,:)));
            fields2d(datNum).img.EdgeAlpha = .3;
            fields2d(datNum).img.EdgeColor = [.8 .8 .8];
            fields2d(datNum).img.LineWidth = 0.3;
        end
        fields2d(datNum).ax.Visible = curProps{2};
        fields2d(datNum).ax.Units = curProps{3};
        fields2d(datNum).ax.Position = curProps{4};
        warning('off','all')
        obliqueview(fields2d(datNum).ax,'xz',44)
        warning('on','all')
        fields2d(datNum).ax.ZLim = curProps{7};
        fields2d(datNum).ax.XLim = curProps{5};
        fields2d(datNum).ax.YLim = curProps{6};
        fields2d(datNum).ax.CLim = curProps{8};
    end
    
end

%% add 1d field axes

% Make axes and images in axes (using time step 1)
if exist('fields1d','var')
    
    for curProps = plots1d_properties'
        whichDat = curProps{1};
        datNum = find(cellfun(@(curname) strcmp(curname,whichDat),{fields1d.name}));
        fields1d(datNum).ax = axes(hFig,'nextplot','add');
        plot(fields1d(datNum).ax,zeros(1,fields1d(datNum).size(1)),1:fields1d(datNum).size(1),'color',[.3 .3 .3],'tag','zeroLine');
        fields1d(datNum).plot = plot(fields1d(datNum).ax,fields1d(datNum).activation(tStep,:),1:fields1d(datNum).size(1),'color','r','lineWidth',1.4,'tag','dataLine');
        fields1d(datNum).ax.Color = 'none';
        fields1d(datNum).ax.Visible = curProps{2};
        fields1d(datNum).ax.Box = 'off';
        fields1d(datNum).ax.XColor = [0 0 0 1];
        fields1d(datNum).ax.YColor = 'none';
        fields1d(datNum).ax.Units = curProps{3};
        fields1d(datNum).ax.Position = curProps{4};
        fields1d(datNum).ax.XLim = curProps{5};
        fields1d(datNum).ax.YLim = [1 fields1d(datNum).size(1)];
        fields1d(datNum).ax.XDir = curProps{6};
        fields1d(datNum).ax.YDir = curProps{7};
        fields1d(datNum).ax.XTick = curProps{8};
        fields1d(datNum).ax.YTick = curProps{9};
    end
    
end

%% add dot plots for nodes

% Make axes and transparent round rectangles
if exist('nodes','var')
    
    for curProps = plots0d_properties'
        whichDat = curProps{1};
        datNum = find(cellfun(@(curname) strcmp(curname,whichDat),{nodes.name}));
        
        % static node base dot
        if nodeBaseDots
            nodes(datNum).baseAx = axes(hFig);
            nodes(datNum).baseAx.Units = curProps{3};
            nodes(datNum).baseAx.Position = curProps{4};
            nodes(datNum).baseAx.Visible = 'off';
            nodes(datNum).baseDot = rectangle(nodes(datNum).baseAx,'Curvature',[1 1]);
            nodes(datNum).baseDot.EdgeColor = 'none';
            nodes(datNum).baseDot.FaceColor = curProps{5}/255;
            nodes(datNum).baseAx.Units = 'normalized';
            addSideLen_x = nodes(datNum).baseAx.Position(3)*baseDotScaleFactor-nodes(datNum).baseAx.Position(3);
            addSideLen_y = nodes(datNum).baseAx.Position(4)*baseDotScaleFactor-nodes(datNum).baseAx.Position(4);
            nodes(datNum).baseAx.Position = nodes(datNum).baseAx.Position + [-addSideLen_x/2 -addSideLen_y/2 addSideLen_x addSideLen_y];
        end
        
        % circle of changing size
        nodes(datNum).ax = axes(hFig);
        nodes(datNum).ax.Visible = curProps{2};
        nodes(datNum).ax.Units = curProps{3};
        nodes(datNum).ax.Position = curProps{4};
        nodes(datNum).dot = rectangle(nodes(datNum).ax,'Curvature',[1 1]);
        nodes(datNum).dot.EdgeColor = 'none';
        nodes(datNum).dot.FaceColor = nodeFaceColor;
        nodes(datNum).YLimBase = nodes(datNum).ax.YLim;
        nodes(datNum).ax.Units = 'normalized';
        nodes(datNum).axPosBase = nodes(datNum).ax.Position;
        
        % suprathreshold indicator circle
        nodes(datNum).outAx = copyobj(nodes(datNum).ax,hFig);
        nodes(datNum).outAx.Children.Visible = 'off';
        nodes(datNum).outAx.Children.FaceColor = 'none';
        if ~nodeRingColorEqualToBase
            nodes(datNum).outAx.Children.EdgeColor = nodeRingColor;
        elseif nodeRingColorEqualToBase
            nodes(datNum).outAx.Children.EdgeColor = curProps{5}/255;
        end
        nodes(datNum).outAx.Children.LineStyle = '-';
        nodes(datNum).outAx.Children.LineWidth = nodeRingWidth;
        nodes(datNum).outAx.Units = 'normalized';
        addSideLen_x = nodes(datNum).outAx.Position(3)*nodeRingScaleFactor-nodes(datNum).outAx.Position(3);
        addSideLen_y = nodes(datNum).outAx.Position(4)*nodeRingScaleFactor-nodes(datNum).outAx.Position(4);
        nodes(datNum).outAx.Position = nodes(datNum).outAx.Position + [-addSideLen_x/2 -addSideLen_y/2 addSideLen_x addSideLen_y];
        
    end
    
end



% Minor stuff
datNum = [];
% change everything to normalized units to enable figure resize
set(findobj(hFig,'type','axes'),'units','normalized');


%% Animation

if ~exist('nodes','var')     
    nodes.seconds = [];
    nodes.nFrames = 0;
    nNodes = 0;
else
    nNodes = size(nodes,2);
end
if ~exist('fields1d','var')     
    fields1d.seconds = [];
    fields1d.nFrames = 0;
    nFields1d = 0;
else
    nFields1d = size(fields1d,2);
end
if ~exist('fields2d','var')     
    fields2d.seconds = [];
    fields2d.nFrames = 0;
    nFields2d = 0;
else
    nFields2d = size(fields2d,2);
end


% Compute frames and frame times to allow smooth playback that accords
% with simulation time.
maxSecs = max(cell2mat(cat(1,{fields2d.seconds}',{fields1d.seconds}',{nodes.seconds}')));
minSecs = min(cell2mat(cat(1,{fields2d.seconds}',{fields1d.seconds}',{nodes.seconds}')));
totalTime = maxSecs-minSecs;
maxFrames = max([[fields2d.nFrames],[fields1d.nFrames],[nodes.nFrames]]);
finalDisplayFrameNumber = ceil(maxFrames*temporalResolutionMultiplier);
referenceTimes = linspace(minSecs,maxSecs,finalDisplayFrameNumber);
totalFrames = numel(referenceTimes);
baseFrameRate = totalFrames/totalTime;
pausePerStep = (totalTime/finalDisplayFrameNumber)*(1/playbackSpeed);

tic

curStep = 1;
doRun = 0;
stepRequest = 0;

while 1
    
    if doRun || curStep == 1 || stepRequest
        
        hStepField.String = [num2str(curStep),'/',num2str(finalDisplayFrameNumber)];
        stepRequest = 0;
        aroundTime = toc;
        currentFrameRate = 1/toc;
        effectivePlayback = currentFrameRate/baseFrameRate;
        disp(['Effective playback rate is ' num2str(effectivePlayback) '(desired: ' num2str(playbackSpeed) ')']);
        disp(['Step ' num2str(curStep)]);
        
        tic
        
        refTime = referenceTimes(curStep);
        
        % 2d fields
        for curField = 1:nFields2d
            [~,useStep] = min(abs(fields2d(curField).seconds - refTime)); useStep = useStep(1);
            if plots2d_properties{curField,9} == 1
                fields2d(curField).img.CData = flipud(squeeze(fields2d(curField).activation(useStep,:,:)));
                if addContour
                    fields2d(curField).cont.ZData = double(flipud(squeeze(fields2d(curField).activation(useStep,:,:)))>0);
                    fields2d(curField).cont.Visible = 'on';
                end
            elseif plots2d_properties{curField,9} == 2
                fields2d(curField).ax.Children.Children.ZData = (flipud(squeeze(fields2d(curField).activation(useStep,:,:))-min(squeeze(fields2d(curField).activation(useStep,:,:)))))*scaleSurfData;
                fields2d(curField).ax.Children.Children.CData = flipud(squeeze(fields2d(curField).activation(useStep,:,:)));
            end
        end
        
        % 1d fields
        for curField = 1:nFields1d
            [~,useStep] = min(abs(fields1d(curField).seconds - refTime)); useStep = useStep(1);
            hCurLine = findobj(fields1d(curField).ax.Children,'tag','dataLine');
            hCurLine.XData = fields1d(curField).activation(useStep,:);
        end
        
        % nodes
        for curNode = 1:nNodes
            
            [~,useStep] = min(abs(nodes(curNode).seconds - refTime)); useStep = useStep(1);
            
            % use filled area to indicate activation
            scaledActivation = (max(nodeActLim(1),min(nodeActLim(2),nodes(curNode).activation(useStep)))+5)/10;
            % move bottom of axes up
            moveAxBottomUp = nodes(curNode).axPosBase(4)*scaledActivation;
            nodes(curNode).ax.Position(2) = nodes(curNode).axPosBase(2)+moveAxBottomUp;
            nodes(curNode).ax.Position(4) = nodes(curNode).axPosBase(4)-moveAxBottomUp;
            % change YLim accordingly
            IncreaseLowerYLim = (nodes(curNode).YLimBase(2)-nodes(curNode).YLimBase(1))*scaledActivation;
            try
                nodes(curNode).ax.YLim(1) = nodes(curNode).YLimBase(1)+IncreaseLowerYLim;
                nodes(curNode).ax.Children.Visible = 'on';
            catch
                nodes(curNode).ax.Children.Visible = 'off';
            end
            
            if nodes(curNode).activation(useStep) > 0
                %nodes(curNode).baseDot.FaceColor(4) = 1;
                nodes(curNode).baseDot.FaceColor = [plots0d_properties{curNode,5}/255,1];
            elseif nodes(curNode).activation(useStep) <= 0
                %nodes(curNode).baseDot.FaceColor(4) = 0.1;
                nodes(curNode).baseDot.FaceColor = [plots0d_properties{curNode,6}/255,0.25];
            end
            
            % make outline if above threshold
            if nodes(curNode).activation(useStep) > 0
                nodes(curNode).outAx.Children.Visible = 'on';
            else
                nodes(curNode).outAx.Children.Visible = 'off';
            end
            
        end
        
        % Pause at each frame
        pause(pausePerStep);
        
        % increment counter or roll around
        if curStep < finalDisplayFrameNumber
            curStep = curStep+1;
        else
            pause(2)
            curStep = 1;
        end
        
    end
    
    drawnow
    
end


%% Callbacks

    function runButton_callback(hObj,~)
        if doRun == 1
            hObj.String = 'Run';
            doRun = 0;
        else
            hObj.String = 'Stop';
            doRun = 1;
        end
    end

    function resetButton_callback(~,~)
        curStep = 1;
    end

    function stepField_callback(hObj,~)
        curStep = str2num(hObj.String);
        stepRequest = 1;
    end

end
