 
% Cedar Output Beautification :)
% Jonas Lins 2017
 
% Requires export_fig (Available on MATLABcentral.com)
% Requires cedarread (should be packaged with this file, else contact me)

% _____What's this?_____

% This allows to load time series data recorded in cedar (*.csv),
% plots it in an interface that allows playing back the evolution over time
% and selecting time steps for final output. It then generates/exports a more
% or less publication ready pdf-figure.
 
% _____HOW TO_____
 
% Take a look at SETTINGS below. In fieldNames, enter a name for each 2D
% field you will import; do the same for each node you will import, inputting
% names into nodeNames; these names will be plotted in the figure. Note that
% at least one field must be specified.
 
% Do the same for nodes and nodeNames. If you leave nodeNames empty, an
% empty node plot will still be generated.
 
% The only other mandatory thing to adjust is assignNodeAxes (most simply,
% put 1 in there for each node in nodeNames, e.g. [1 1 1] for three nodes).

% Run the script. It will ask you to select the files corresponding to the
% field/node names you have entered before (title of load dialog specifies
% which field/node for each file).
 
% Some processing will be done. This might take a few minutes. Then the
% interface pops up.
 
% Select some snapshots ("+Snapshot"). Setting start/end is optional. Press
% "plot" and then "export".

% _____NOTES_____
 
% This was implemented quick and dirty, primarily for my own specific 
% purposes. It sure has bugs and is not very versatile. For instance, it
% currently only handles 2D fields and 0D nodes; code for 1D should be
% straightforward to add, though.



function cedarOutputBeautification

% SETTINGS ---------------------------------------------------------------

% Provide the field names and node names here. 
% Use sprintf('Blabla\nbla') for multiline names and other formatting.
fieldNames = ...
    {'Some 2D field', ...
    sprintf('another\n2D field')};
nodeNames = ...
    {'Some node', ...
    'some other node'};

% Which of the nodes named above get their own axes?
% (elements of this vector correspond to nodeNames in order; using the same
% numeric value in each element will cause all nodes to be plotted in
% one axes; introducing more numbers results in a additional node axes.
assignNodeAxes = [1 2];   

nodePlotYLims = [-15 15;-15 15]; % Ylimits for node plots; one row per plot (in order defined above)
colorLimits = [-10, 5]; % color limits for field plots

timeAxLabel = 'Time [s]';
actAxLabel = 'Activation';
xTickStep = .5; % distance btw x ticks on node axis (seconds)
showZeroLine = true; % for node plots
zeroLineColor = [.8 .8 .8];
useFontSize = 10; % for output figure
useFont = 'Palatino Linotype'; % for output figure
useColorMap = parula;
nodePlotLineWidth = 1; % for node activation
nodeAxStylize = true; 
nodeAxBgColor = [.95 .95 .95]; % only effective if nodeAxStylize==1

% Lines marking snapshot times in node plots
snapshotMarker.color = [.65 .65 .65];
snapshotMarker.style = ':';
snapshotMarker.width = 1;

% Snapshot times above field plot columns
showSnapTime = true; % Show snapshot time above each field column?
snapTimeVertPos = .4; % vertical position of time above upper border of topmost field axes (not plots!) [cm]

% Annotation lines from bottom node plot to field column
showAnnoLines = true;
annoLineColor = [.65 .65 .65];
annoLineStyle = ':';
annoLineWidth = 1;
endAnnoLineY = 0.2;

% Place field names relative to leftmost field plot
fieldLabelRotation = 60; % Rotation of field labels around left text onset [degrees]
horzFieldLabelPosition = 1.25; % horz distance of left text onset from left border of leftmost field axes [cm]
vertFieldLabelPosition = .25; % vert distance of left text onset from bottom border of leftmost field axes [cm]
% (note that rotation likely requires moving this up a little)

% define figure size depending on number plots in it (values 3,3,2.5 are good)
outFig_widthBase = 5; % baseWidth for margins etc [cm]
outFig_widthPerSnap = 3.5; % width per snapshot [cm]
outFig_heightPerSubplot = 4; % height per subplot [cm] (one subplot vertically for each node plot, field, and one for time values)

% This can be used to increase size of the field plots without changing
% arrangement of things in the output figure (the value is the proportion
% of the previous size added to the previous size)
scaleFactorFieldPlots = 0.25;

% activation colorbar. If this overlaps with plots adjust plot positions or
% simply correct with matlab plot tools.
showColorBar = false;

% When using export function, save not only pdf but also fig (same dir as that chosen for pdf)?
exportAlsoSavesFigFile = true;

% Iteration settings (does not need to be touched usually)
stepsPerSimSecond = 100; % Loop iterations per second total simulation time in input time stamps
pausePerStep = 1/stepsPerSimSecond; % seconds per iteration

% Discard timesteps (may be required when dealing with certain cedar recording
% quirks :) should not hurt in any case
removeFramesSharingTimestamp = true;

% END OF SETTINGS --------------------------------------------------------



%% Get files

nNodes =  numel(nodeNames);
nFields = numel(fieldNames);
tSnaps = []; % time steps that will be plotted in figure (one column for each in subplot)
% will be filled in callback

% Get node and field files (from cedar)
% Get field data files
fieldFiles = cell(size(fieldNames));
fieldPaths = cell(size(fieldNames));
startDir = '';
for curField = 1:nFields
    try
        startDir =  fieldPaths{curField-1};
    end
    curFieldName = fieldNames{curField};
    [fieldFiles{curField} fieldPaths{curField}] = uigetfile('*.csv',['Select file for field ' curFieldName '.'],startDir);
end
% Get node data files
nodeFiles = cell(size(nodeNames));
nodePaths = cell(size(nodeNames));
for curNode = 1:nNodes
    try
        startDir =  nodePaths{curNode-1};
    end
    curNodeName = nodeNames{curNode};
    [nodeFiles{curNode} nodePaths{curNode}] = uigetfile('*.csv',['Select file for node ' curNodeName '.'],startDir);
end

%% Process / reshape input data

disp('Processing input data. This might take a while...');

fields = cedarread(fieldPaths,fieldFiles,fieldNames,removeFramesSharingTimestamp);
nodes = cedarread(nodePaths,nodeFiles,nodeNames,removeFramesSharingTimestamp);
for curNode = 1:nNodes
    nodes(curNode).axNum = assignNodeAxes(curNode);
end

% if no nodes specified
if isempty(nodeNames)
    nNodes = 1;
    assignNodeAxes = 1;
    nodes(1).name = 'Dummy';
    nodes(1).size = [1 1];    
    nodes(1).seconds = 0;
    nodes(1).nFrames = 1;
    nodes(1).axNum = 1;
    nodes(1).axNum = 1;
    nodes(1).activation = 0;
end

nFrames = fields(1).nFrames;
nNodeAxes = numel(unique(assignNodeAxes));
tMin = 0;
tMax = max([arrayfun(@(ns) max(ns.seconds), nodes), arrayfun(@(fs) max(fs.seconds), fields)]);
allOutFigs = [];


%% Show figure with time slider and plots to select time steps for final output

hSelectFig_fields = figure('color','w','position',[807    43   246   965]);
hSelectFig_nodes = figure('color','w','position',[10   722   784   285]);

nPlotSteps = round((tMax-tMin)*stepsPerSimSecond); % Total number of plot steps

% Prepare axes

% Create field axes
fieldAxes_sel = [];
for curField = 1:nFields
    fieldAxes_sel(curField) = subplot(nFields,1, curField,'parent',hSelectFig_fields);
end
% Create node axes
nodeAxes_sel = [];
for curNodeAx = 1:nNodeAxes
    nodeAxes_sel(curNodeAx) = subplot(nNodeAxes+1,1,curNodeAx,'parent',hSelectFig_nodes);
end

% UI elements

butMargin = 2;
hRunButton = uicontrol('style','togglebutton','string','Run','Min',0,'max',1,'interruptible','off');
firstButPos = hRunButton.Position;
hSetStartButton = uicontrol('style','pushbutton','position',firstButPos+[firstButPos(3)*1+butMargin 0 0 0],'string','Set start','Min',0,'max',1,'interruptible','off','callback',@setStartButtonCallback,'tooltipstring', sprintf('Define start of time period that will be shown in node plots of final figure.'));
hSetEndButton = uicontrol('style','pushbutton','position',firstButPos+[firstButPos(3)*2+butMargin 0 0 0],'string','Set end','Min',0,'max',1,'interruptible','off','callback',@setEndButtonCallback,'tooltipstring', sprintf('Define end of time period that will be shown in node plots of final figure.'));
hSnapButton = uicontrol('style','pushbutton','position',firstButPos+[firstButPos(3)*3+butMargin 0 0 0],'string','+Snapshot','Min',0,'max',1,'interruptible','off','callback',@snapButtonCallback,'tooltipstring', sprintf('Add snapshot at this time point.\n (final output will show fields for this time step)'));
hUnsnapButton = uicontrol('style','pushbutton','position',firstButPos+[firstButPos(3)*4+butMargin 0 0 0],'string','-Snapshot','Min',0,'max',1,'interruptible','off','callback',@unsnapButtonCallback,'tooltipstring', sprintf('Remove snapshot before current time point.'));
hPlotButton = uicontrol('style','pushbutton','position',firstButPos+[firstButPos(3)*5+butMargin 0 0 0],'string','Plot','Min',0,'max',1,'interruptible','off','callback',@plotButtonCallback,'tooltipstring', sprintf('Generate output figure (you still need to export it after that).'));
hExportButton = uicontrol('style','pushbutton','position',firstButPos+[firstButPos(3)*6+butMargin 0 0 0],'string','Export','Min',0,'max',1,'interruptible','off','callback',@exportButtonCallback,'tooltipstring', sprintf('Save most recently generated output figure to pdf (also saves *.fig to same dir if enabled).'));
hQuitButton = uicontrol('style','pushbutton','position',firstButPos+[firstButPos(3)*7+butMargin 0 0 0],'string','Quit','Min',0,'max',1,'interruptible','off','callback',@quitButtonCallback,'tooltipstring', sprintf('Quit (you will be able to keep output figure open).'));
sliderPos = get(nodeAxes_sel(end),'position'); % bottom node plot pos
sliderPos([2 4]) = [0.225 0.05];
sliderPos([1 3]) = sliderPos([1 3])+[-0.019 0.019*2];
hTimeSlider = uicontrol(hSelectFig_nodes,'style','slider','units','normalized','Value',1,'sliderstep',[1/nPlotSteps 100/nPlotSteps]);
hTimeSlider.Position = sliderPos;
hTimeSlider.Min = 1;
hTimeSlider.Max = nPlotSteps;
addlistener(hTimeSlider, 'Value','PostSet',@sliderCallback);


% Prepare field plots

fieldPlots_sel = [];
for curField = 1:nFields
    fieldPlots_sel(curField) = imagesc(zeros(fields(curField).size(2),fields(curField).size(1)),'parent',fieldAxes_sel(curField));
    set(get(fieldAxes_sel(curField),'title'),'String',strrep(fields(curField).name,sprintf('\n'),' '),'FontSize',10,'FontWeight','normal');
end


% Do node plots

nodePlots_sel = [];
set(nodeAxes_sel,'nextplot','add')
for curNode = 1:nNodes
    nodePlots_sel(curNode) = plot(nodeAxes_sel(nodes(curNode).axNum),nodes(curNode).seconds,nodes(curNode).activation,'lineWidth',nodePlotLineWidth);
    set(nodePlots_sel(curNode),'displayname',nodes(curNode).name,'tag','nodeLine')
end


% Axes cosmetics

set(nodeAxes_sel,'XLim',[tMin tMax])
set(nodeAxes_sel,'XTick',tMin:xTickStep:tMax)
tmpNax = get(nodeAxes_sel(end),'XLabel');
tmpNax.String = timeAxLabel;
for cnp = 1:numel(nodeAxes_sel)
    set(nodeAxes_sel(cnp),'ylim',[-10 10])
    set(get(nodeAxes_sel(cnp),'ylabel'),'string',actAxLabel)
    legend(nodeAxes_sel(cnp),'show','autoupdate','off');
    if showZeroLine
        plot(nodeAxes_sel(cnp) ,[tMin tMax],[0 0],'color',zeroLineColor);
    end
end
arrayfun(@(hAx) hold(hAx,'on'), nodeAxes_sel);
set(fieldAxes_sel,'visible','on','ydir','reverse','DataAspectRatio',[1 1 1])
set(fieldAxes_sel,'XTick',[],'YTick',[]);
set(fieldAxes_sel,'CLim',colorLimits);
colormap(useColorMap);


% Iterate and update field plots

% Number of time points to iterate through (for each of these the data
% point closest in time will be plotted)
plotTimes = linspace(tMin,tMax,nPlotSteps);
% Start and end timesteps for output figure (can be modified by buttons)
outputStart = 1; outputEnd = nPlotSteps;

doneSelecting = 0;
curStep = 0;
updatePlots = 0;
doPlot = 0;
doQuit = 0;
while ~doQuit
    
    doGo = hRunButton.Value;
    if doGo
        % increment or roll around
        if curStep == nPlotSteps
            curStep = 1;
        else
            curStep = curStep + 1;
        end
        updatePlots = 1;
    end
    
    if updatePlots
        % get time point to plot
        plotTime = plotTimes(curStep);
        
        % Update fields
        for curField = 1:nFields
            % find time stamp closest to current plotTime
            [~,mind] = min(abs(fields(curField).seconds-plotTime));            
            set(fieldPlots_sel(curField),'CData',squeeze(fields(curField).activation(mind,:,:)));            
        end
        
        % Draw line marking current time in each node plot
        if isempty(findobj(hSelectFig_nodes,'tag','tLine'))
            for curNodeAx = 1:nNodeAxes
                line([plotTime,plotTime],nodePlotYLims(curNodeAx,:),'tag','tLine','parent',nodeAxes_sel(curNodeAx));
            end
        else
            set(findobj(hSelectFig_nodes,'tag','tLine'),'xdata',[plotTime plotTime]);
        end
        
        hTimeSlider.Value = curStep;
        
        drawnow;
        pause(pausePerStep);
        updatePlots = 0;
    end
    
    drawnow;
    
    
    % use only snapshots btw start and end for plotting final output
    tSnaps_tmp = tSnaps(tSnaps>=outputStart&tSnaps<=outputEnd);
    
    
    % ------ Plot final output ----------------------
    
    if doPlot && ~isempty(tSnaps_tmp)
        
        doPlot = 0;
        
        tSnaps_tmp = sort(tSnaps_tmp);
        nSnaps = numel(tSnaps_tmp);
        hSnapFig = figure('color','w');
        set(hSnapFig,'units','centimeters','position',[0 0 outFig_widthBase+outFig_widthPerSnap*nSnaps outFig_heightPerSubplot*(nNodes+nFields+1)])
        allOutFigs(end+1) = hSnapFig;
        
        % Prepare axes
        
        % Create field axes
        fieldAxes = [];
        for curField = 1:nFields
            for curSnap = 1:nSnaps
                fieldAxes(curField,curSnap) = subplot(nFields+nNodeAxes+1,nSnaps, (nNodeAxes*nSnaps)+ (nSnaps)*(curField) +curSnap,'tag','outputFieldAxes');
            end
        end
        % Create node axes
        nodeAxes = [];
        for curNodeAx = 1:nNodeAxes
            nodeAxes(curNodeAx) = subplot(nFields+nNodeAxes+1,nSnaps,nSnaps*(curNodeAx-1)+1:nSnaps*(curNodeAx-1)+nSnaps);
        end
        
        
        % Prepare field plots
        
        fieldPlots = [];
        for curField = 1:nFields
            for curSnap = 1:nSnaps
                fieldPlots(curField,curSnap) = imagesc(zeros(fields(curField).size(2),fields(curField).size(1)),'parent',fieldAxes(curField,curSnap));
            end
        end
        
        % node plots
        
        nodePlots = [];
        set(nodeAxes,'nextplot','add')
        for curNode = 1:nNodes
            [~,ind_start] = min(abs(nodes(curNode).seconds-plotTimes(outputStart)));
            [~,ind_end] = min(abs(nodes(curNode).seconds-plotTimes(outputEnd)));
            nodePlots(curNode) = plot(nodeAxes(nodes(curNode).axNum),nodes(curNode).seconds(ind_start:ind_end),nodes(curNode).activation(ind_start:ind_end),'lineWidth',nodePlotLineWidth);
            set(nodePlots(curNode),'displayname',nodes(curNode).name)
        end
        
        % axes cosmetics
        
        set(nodeAxes,'XLim',[plotTimes(outputStart) plotTimes(outputEnd)])
        set(nodeAxes,'XTick',plotTimes(outputStart):xTickStep:plotTimes(outputEnd));
        if numel(nodeAxes)>1
            set(nodeAxes(1:end-1),'XTick',[]);
        end
        plottedDuration = plotTimes(outputEnd)-plotTimes(outputStart);
        set(nodeAxes,'XTickLabels',0:xTickStep:plottedDuration);
        tmpNax = get(nodeAxes(end),'XLabel');
        tmpNax.String = 'Time [s]';
        for cnp = 1:numel(nodeAxes)
            set(nodeAxes(cnp),'ylim',nodePlotYLims(cnp,:))
            set(get(nodeAxes(cnp),'ylabel'),'string',actAxLabel)
            legend(nodeAxes(cnp),'show','autoupdate','off');
            if showZeroLine
                plot(nodeAxes(cnp) ,[plotTimes(outputStart) plotTimes(outputEnd)],[0 0],'color',zeroLineColor)
            end
        end
        arrayfun(@(hAx) hold(hAx,'on'), nodeAxes);
        set(fieldAxes,'visible','off','ydir','reverse','DataAspectRatio',[1 1 1])
        set(fieldAxes,'XTick',[],'YTick',[]);
        set(fieldAxes,'CLim',colorLimits);
        colormap(useColorMap);
        
        % plot field data
        
        for curSnap = 1:nSnaps
            plotTime = plotTimes(tSnaps_tmp(curSnap));
            % Plot fields
            for curField = 1:nFields
                % find time stamp closest to current step
                [~,mind] = min(abs(fields(curField).seconds-plotTime));
                set(fieldPlots(curField,curSnap),'CData',squeeze(fields(curField).activation(mind,:,:)));
            end
            % Draw line in each node plot (first delete if already exists)
            for curNodeAx = 1:nNodeAxes
                line([plotTime,plotTime],nodePlotYLims(curNodeAx,:),'tag','tLine','parent',nodeAxes(curNodeAx),'linestyle',snapshotMarker.style,'color',snapshotMarker.color,'linewidth',snapshotMarker.width);
            end
            drawnow;
        end
        
        % Scale field plots
        
        for curField = 1:nFields
            for curSnap = 1:nSnaps
                curAxTmp  = fieldAxes(curField,curSnap);
                curPosTmp = get(curAxTmp,'position');
                set(curAxTmp,'position',curPosTmp+[-(scaleFactorFieldPlots*curPosTmp(3))/2 -(scaleFactorFieldPlots*curPosTmp(4))/2 scaleFactorFieldPlots*curPosTmp(3) scaleFactorFieldPlots*curPosTmp(4)])
            end
        end
        
        % adjust node plot width to fit field plots
        
        for curNodeAx = 1:nNodeAxes
            tmpFieldAx = get(fieldAxes(1,1));
            lft = tmpFieldAx.Position(1);
            lft = lft(1);
            tmpFieldAx = get(fieldAxes(1,end));
            rgt = tmpFieldAx.Position(1)+tmpFieldAx.Position(3);
            newPos = get(nodeAxes(curNodeAx));
            newPos = newPos.Position;
            newPos(1) = lft; newPos(3) = rgt-lft;
            set(nodeAxes(curNodeAx),'position',newPos);
        end
        
        % Create title axes with time text
        
        if showSnapTime
            titleAxes = [];
            for curSnap = 1:nSnaps
                titleAxes(curSnap) = subplot(nFields+nNodeAxes+1,nSnaps, (nNodeAxes*nSnaps)+curSnap);
                tmpPosCurAx = get(titleAxes(1,curSnap),'position');
                tmpPosBlwAx = get(fieldAxes(1,curSnap),'position');
                vrttop = tmpPosBlwAx(2)+tmpPosBlwAx(4);
                set(titleAxes(curSnap),'position',[tmpPosBlwAx(1) vrttop tmpPosBlwAx(3) tmpPosCurAx(4)]);
                curSeconds = plotTimes(tSnaps(curSnap))-plotTimes(outputStart);
                tmpTx = text(.5,0,[num2str(round(curSeconds,2)),' s'],'HorizontalAlignment','center');
                tmpTx.Units = 'centimeters';
                tmpTx.Position(2) = snapTimeVertPos;
                set(titleAxes(curSnap),'visible','off');
            end
        end
        
        % Scale node plot if there's only one
        
        if nNodeAxes == 1
            for curNodeAx = 1:nNodeAxes
                curAxTmp  = nodeAxes(curNodeAx);
                curPosTmp = get(curAxTmp,'position');
                scaleFactorNodePlots = 1.175;
                set(curAxTmp,'position',curPosTmp+[0 -(scaleFactorNodePlots*curPosTmp(4))/2 0 scaleFactorNodePlots*curPosTmp(4)])
            end
        end
        
        % node axes optional cosmetics
        
        if nodeAxStylize
            for curNodeAx = 1:nNodeAxes
                curAxTmp  = nodeAxes(curNodeAx);
                set(curAxTmp,'color',nodeAxBgColor);
                overlayAxNodes(curNodeAx) = axes('position',get(curAxTmp,'position'));
                overlayAxNodes(curNodeAx).Color = 'none';
                overlayAxNodes(curNodeAx).XTick = [];
                overlayAxNodes(curNodeAx).YTick = [];
                overlayAxNodes(curNodeAx).Box = 'on';
                overlayAxNodes(curNodeAx).XAxis.Color = 'w';
                overlayAxNodes(curNodeAx).YAxis.Color = 'w';
            end
        end
        
        % Add field names on the left
        
        for curField = 1:nFields
            curPosTmp = get(fieldAxes(curField,1),'position');
            newAxTmp = axes(hSnapFig,'position',[0 curPosTmp(2) curPosTmp(1) curPosTmp(4)],'visible','off','units','centimeters');
            fieldLabelTxt(curField) = text(newAxTmp,0,0,fields(curField).name,'units','centimeters');
            fieldLabelTxt(curField).Rotation = fieldLabelRotation;
            fieldLabelTxt(curField).Position(1) = newAxTmp.Position(3)-horzFieldLabelPosition;
            fieldLabelTxt(curField).Position(2) = vertFieldLabelPosition;
        end
        
        % Add color bar
        
        if showColorBar
            
            fs = getpixelposition(hSnapFig);
            fcntr = fs(3)/2;
            cb = colorbar(fieldAxes(end,1),'horiz');
            cbHeight = 25; cbWidth = 200;
            set(cb,'units','pixels');
            set(cb,'position',[fcntr-cbWidth/2 70 cbWidth cbHeight])
            cb.TickLength = 0.03;
            cb.Label.String = 'Activation';
            % overlay black border of cb with white axes
            brdAx = axes('units','pixels');
            brdAx.Position = get(cb,'position');
            brdAx.Color = 'none';
            brdAx.XTick = []; brdAx.YTick = [];
            brdAx.Box = 'on';
            brdAx.XAxis.Color = 'w';
            brdAx.YAxis.Color = 'w';
            uistack(brdAx,'top')
        
        end
        
        % Change fontsize and font of all text
        
        set(findall(hSnapFig,'-property','FontSize'),'FontSize',useFontSize);
        set(findall(hSnapFig,'-property','FontName'),'FontName',useFont);
        
        % Do some stuff to legends (change edgle color and move around)
        
        set(findobj(hSnapFig,'type','legend'),'edgecolor',[1 1 1]);
        for curNodeAx = 1:nNodeAxes
            axTmp = nodeAxes(curNodeAx);
            legTmp = legend(axTmp);
            legTmp.Units = 'centimeters';
            set(axTmp,'units','centimeters');
            axPos = get(axTmp,'position');
            legPos = legTmp.Position;
            axRgt = axPos(1)+axPos(3);
            axTop = axPos(2)+axPos(4);
            legMargin = .2;
            legx = axRgt-legPos(3)-legMargin;
            legy = axTop-legPos(4)-legMargin;
            legTmp.Position = [legx legy legTmp.Position(3) legTmp.Position(4)];
        end
        
        % add annotation lines
        
        if showAnnoLines
            tLines = flipud(findobj(nodeAxes(end),'tag','tLine'));
            set(nodeAxes(end),'units','centimeters');
            naxPos = get(nodeAxes(end),'position');
            naxXLims = get(nodeAxes(end),'XLim');
            naxXSpan = naxXLims(2)-naxXLims(1);
            for curLine = 1:numel(tLines)
                % start pos
                tln = tLines(curLine);
                start_x = naxPos(1)+ ((tln.XData(1)-naxXLims(1))/naxXSpan)*naxPos(3);
                start_y = naxPos(2);
                % end pos
                set(titleAxes(curLine),'units','centimeters');
                ttlAxPos = get(titleAxes(curLine),'position');
                end_x = ttlAxPos(1)+ttlAxPos(3)/2;
                %end_y = ttlAxPos(2)+ttlAxPos(4)/4;
                end_y = ttlAxPos(2)+snapTimeVertPos+endAnnoLineY;
                % annotation line
                tmpAn = annotation('line',[0 0],[0 0],'color',annoLineColor,'linestyle',annoLineStyle,'lineWidth',annoLineWidth);
                tmpAn.Units = 'centimeters';
                tmpAn.X = [start_x end_x];
                tmpAn.Y = [start_y end_y];
            end
        end
        
        set(findall(hSnapFig,'-property','units'),'units','pixels');
        
    elseif doPlot
        msgbox('No snapshots between start and end position.')
        doPlot = 0;
    end
    
end

close(hSelectFig_nodes);
close(hSelectFig_fields);
if ~isempty(allOutFigs)
    if strcmp(questdlg('Close output figures as well?','Close output','Yes','No','No'),'Yes')
        try
            close(allOutFigs);
        end
    end
end

%% Callbacks

    function sliderCallback(hObj,event)
        curStep = round(get(event.AffectedObject,'Value'));
        updatePlots = 1;
    end

    function snapButtonCallback(~,~)
        tSnaps(end+1) = curStep;
        for curNodeAx = 1:nNodeAxes
            line([plotTimes(curStep),plotTimes(curStep)],nodePlotYLims(curNodeAx,:),'tag','markSnapLine','linestyle',':','linewidth',1,'color','k','parent',nodeAxes_sel(curNodeAx));
        end
    end

    function unsnapButtonCallback(~,~)
        try
            cur = hTimeSlider.Value;
            [~,prevSnapInd] = min(cur-tSnaps(tSnaps<=cur));
            delete(findobj(hSelectFig_nodes,'tag','markSnapLine','xdata',[plotTimes(tSnaps(prevSnapInd)),plotTimes(tSnaps(prevSnapInd))]));
            tSnaps(prevSnapInd) = [];
        end
    end

    function plotButtonCallback(~,~)
        doPlot = 1;
        doGo = 0;
    end

    function setStartButtonCallback(~,~)
        if curStep < outputEnd
            outputStart = curStep;
            plotTime = plotTimes(outputStart);
            try
                delete(findobj(hSelectFig_nodes,'tag','outputStartLine'));
            end
            for curNodeAx = 1:nNodeAxes
                line([plotTimes(outputStart),plotTimes(outputStart)],nodePlotYLims(curNodeAx,:),'tag','outputStartLine','linestyle','-','linewidth',1.5,'color','r','parent',nodeAxes_sel(curNodeAx));
            end
        else
            msgbox('Set the start before the end. That''s how it was meant to be.')
        end
    end

    function setEndButtonCallback(~,~)
        if curStep > outputStart
            outputEnd = curStep;
            plotTime = plotTimes(outputEnd);
            try
                delete(findobj(hSelectFig_nodes,'tag','outputEndLine'));
            end
            for curNodeAx = 1:nNodeAxes
                line([plotTimes(outputEnd),plotTimes(outputEnd)],nodePlotYLims(curNodeAx,:),'tag','outputEndLine','linestyle','-','linewidth',1.5,'color','r','parent',nodeAxes_sel(curNodeAx));
            end
        else
            msgbox('Set the end after the start. That''s how it was meant to be.')
        end
    end

    function quitButtonCallback(~,~)
        if strcmp(questdlg('Really quit?','Quit','Yes','No','No'),'Yes')
            doQuit = 1;
        end
    end

    function exportButtonCallback(~,~)
        [putFile, putPath] = uiputfile('*.pdf');
        try
            export_fig(hSnapFig,[putPath putFile]);
        catch
            errordlg('Pdf export failed. Maybe you are missing export_fig? Get it from MATLABcentral or change code to use another export function.','PDF export failed.')
        end
        if exportAlsoSavesFigFile
            savefig(hSnapFig,strrep([putPath putFile],'.pdf','.fig'));
        end
    end

end












