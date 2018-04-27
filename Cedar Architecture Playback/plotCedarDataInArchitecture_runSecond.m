
%% RUN THIS SECTION FIRST (to generate figure and all plots; then run next section for animation)





    % --- !!!! Hack to shift field data along color dimension as it is set up in the figure  !!!
    if ~exist('shiftDone','var')
        for i = 1:size(fields1d,2)
            warning('THERES A TEMPORARY ADJUSTMENT AT WORK THAT SHIFTS 1D DATA ALONG COLOR DIMENSION TO ACCORD TO AXIS IN FIGURE. SHOULD NOT BE USED FOR OTHER THAN THE SL MODEL DATA');
            fields1d(i).activation = circshift(fields1d(i).activation,13,2);
        end
        shiftDone = 1;
    end
    % HACL HACK HACK HACK !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    
    
    
           
    % --- Some graphical settings
      
    % 1 = use images, 2 = use surf
    useImageOrSurf = 1;
    % for surf: factor by which surf data is scaled to reduce peak height (does not apply to color data)
    scaleSurfData = 0.3;
    % for image: add contour lines to image maps to show suprathreshold?
    addContour = 0;
    contLineWidth = 1.4;
    contLineStyle = ':';
    contColor = 'r';
    
    % color limits for field plots (may alternatively be set for each field individually below)
    colorLimits = [-10, 5]; 
    
    % node visuals
    nodeFaceColor = [.95 .95 .95 1];
    % node rings that indicate activation > 0
    nodeRingColor = 'r'; % use 'none' to hide
    nodeRingWidth = 1.5;
    nodeRingScaleFactor = 1.45;
        
    % Reduce temporal resolution if animation does not run smoothly
    % (reduces number of frames displayed per time below that possible based on data;
    % it does not affect playback speed)
    temporalResolutionMultiplier = 0.1;
    % Multiplier for playback speed relative to original simulation speed
    % (1 means equal to simulation speed based on data timestamps)
    playbackSpeed = 1; 
    
    % ---- load architecture image (background)
    
    %archImg = imread('H:\Disputation\cedar arch for disp temp 25 04\matlab stuff\architectureFINAL_dtrOnly_forVideo_deutsch.bmp');
    %archImg = imread('S:\Disputation\cedar arch for disp temp 25 04\matlab stuff\architectureFINAL_fullPairB_forVideo_deutsch.bmp');
    archImg = imread('S:\Disputation\Bilder\architectureFINAL_dtrOnly_forVideo_deutsch.bmp');    
    bgSz = size(archImg);
    bgSz = bgSz([1,2]);
    bgAr = bgSz(2)/bgSz(1); % image aspect ratio
        
    % ---- prepare figure 
    
    % figure size based on aspect ratio of background image
    fBaseSz = 2;
    fig = figure('Position',[50 50 (fBaseSz*400)*bgAr fBaseSz*400]);
    
    % hide the toolbar
    set(fig,'menubar','none')    
    % hide the title
    set(fig,'NumberTitle','off');
    
    % use this code to later rescale figure while retaining aspect ratio
    % may not work anymore... didnt test
    % figSz = fig.Position
    % scaleFactor = 1.2;
    % fig.Position = [figSz(1:2), figSz(3:4)*scaleFactor = 1.2;];
    
    % background axes
    ax_bg = axes;
    ax_bg.Position = [0 0 1 1];
    
    % add architecture image
    img_bg = image(ax_bg,archImg);
    ax_bg.Visible = 'off';
    
    hold on
    
    tStep = 300;
    
    % --- define plot properties and positions
    
    % 2D fields
    
    % name           visible     units          position                xlim                    ylim                    zlim
    plots2d_properties = ...
        {'perc green',  'off',      'centimeters',  [20 14 9.25 4],         [-1.7227,51.3020],      [0.1157,39.8843],       [-8.8026,17.7098],      colorLimits;...
        'perc red',    'off',      'centimeters',  [20 12.38 9.25 4],      [-1.7227,51.3020],      [0.1157,39.8843],       [-8.8026,17.7098],      colorLimits;...
        'perc blue',   'off',      'centimeters',  [20 10.76 9.25 4],      [-1.7227,51.3020],      [0.1157,39.8843],       [-8.8026,17.7098],      colorLimits;...
        'ref',         'off',      'centimeters',  [10.39 6.66 9.25 4],    [-1.7227,51.3020],      [0.1157,39.8843],       [-8.8026,17.7098],      colorLimits;...
        'ref ior',     'off',      'centimeters',  [10.39 4.39 9.25 4],    [-1.7227,51.3020],      [0.1157,39.8843],       [-8.8026,17.7098],      colorLimits;...
        'tgt cand',    'off',      'centimeters',  [20 6.66 9.25 4],       [-1.7227,51.3020],      [0.1157,39.8843],       [-8.8026,17.7098],      colorLimits;...
        'tgt resp',    'off',      'centimeters',  [20 4.39 9.25 4],       [-1.7227,51.3020],      [0.1157,39.8843],       [-8.8026,17.7098],      colorLimits;...
        'rel cos',     'off',      'centimeters',  [11.62 1.21 9.25 4],    [-1.7227,51.3020],      [0.1157,39.8843],       [-8.8026,17.7098],      colorLimits;...
        'rel cod',     'off',      'centimeters',  [18.8 1.21 9.25 4],     [-1.7227,51.3020],      [0.1157,39.8843],       [-8.8026,17.7098],      colorLimits};
    
    % 1D fields
    
    % name           visible     units          position                    xlim        XDir        YDir    XTick           YTick
    plots1d_properties = ...
        {'col int',     'on',      'centimeters',  [13.7 11.162 1.43 5.3],     [-6,3],     'reverse'  'normal' [-6 -4 -2 0 2]   [];...
        'col cos',     'on',      'centimeters',  [15.507 11.162 1.43 5.3],   [-6,3],     'reverse'  'normal' [-6 -4 -2 0 2]   [];...
        'col cod',     'on',      'centimeters',  [17.314 11.162 1.43 5.3],   [-6,3],     'reverse'  'normal' [-6 -4 -2 0 2]   []};
    
    % nodes        
    
    % name              visible units           position
    plots0d_properties = ...
        {'ref int',         'off',   'centimeters',  [6.3300+0.01   17.2300    0.5500    0.5500] ;...
        'ref cos',         'off',   'centimeters',  [7.4230   17.2300    0.5500    0.5500] ;...
        'tgt int',         'off',   'centimeters',  [10.5500  17.2300    0.5500    0.5500] ;...
        'tgt cos',         'off',   'centimeters',  [11.5930  17.2300    0.5500    0.5500] ;...
        'tgt pre',         'off',   'centimeters',  [9.0000   17.8700+0.005    0.5500    0.5500] ;...
        'spt int',         'off',   'centimeters',  [2.1200   17.2300    0.5500    0.5500] ;...
        'spt cos',         'off',   'centimeters',  [3.2130   17.2300    0.5500    0.5500] ;...
        'mem spt a',       'off',   'centimeters',  [0.2800    7.1150+0.018    0.5500    0.5500] ;...
        'mem spt b',       'off',   'centimeters',  [0.2800    5.3100+0.018    0.5500    0.5500] ;...
        'mem spt l',       'off',   'centimeters',  [0.2800    3.5050+0.005    0.5500    0.5500] ;...
        'mem spt r',       'off',   'centimeters',  [0.2800    1.7000+0.007    0.5500    0.5500] ;...
        'pro spt a',       'off',   'centimeters',  [1.3650    7.1150+0.018    0.5500    0.5500] ;...
        'pro spt b',       'off',   'centimeters',  [1.3650    5.3100+0.018    0.5500    0.5500] ;...
        'pro spt l',       'off',   'centimeters',  [1.3650    3.5050+0.007    0.5500    0.5500] ;...
        'pro spt r',       'off',   'centimeters',  [1.3650    1.7000+0.007    0.5500    0.5500] ;...
        'mem ref r',       'off',   'centimeters',  [4.5243+.02   13.4550    0.5500    0.5500] ;...
        'mem ref g',       'off',   'centimeters',  [4.5243+.02   15.1100+0.015    0.5500    0.5500] ;...
        'mem ref b',       'off',   'centimeters',  [4.5243+.02   11.8000    0.5500    0.5500] ;...
        'mem tgt r',       'off',   'centimeters',  [8.7685+0.005   13.4550    0.5500    0.5500] ;...
        'mem tgt g',       'off',   'centimeters',  [8.7685+0.005   15.1100    0.5500    0.5500] ;...
        'mem tgt b',       'off',   'centimeters',  [8.7685+0.005   11.8000    0.5500    0.5500] ;...
        'pro ref r',       'off',   'centimeters',  [5.5850   13.4550    0.5500    0.5500] ;...
        'pro ref g',       'off',   'centimeters',  [5.5850   15.1100+0.015    0.5500    0.5500] ;...
        'pro ref b',       'off',   'centimeters',  [5.5850   11.8000    0.5500    0.5500] ;...
        'pro tgt r',       'off',   'centimeters',  [9.8050   13.4550    0.5500    0.5500] ;...
        'pro tgt g',       'off',   'centimeters',  [9.8050   15.1100    0.5500    0.5500] ;...
        'pro tgt b',       'off',    'centimeters',  [9.8050   11.8000    0.5500    0.5500]};
       
    
    
    
    % ...code from here on usually does not need to be adjusted...
    
    
    % Compute frames and frame times to allow smooth playback that accords
    % with simulation time.
    maxSecs = max(cell2mat(cat(1,{fields2d.seconds}',{fields1d.seconds}',{nodes.seconds}')));
    minSecs = min(cell2mat(cat(1,{fields2d.seconds}',{fields1d.seconds}',{nodes.seconds}')));
    totalTime = maxSecs-minSecs;
    maxFrames = max([[fields2d.nFrames],[fields1d.nFrames],[nodes.nFrames]]);    
    finalDisplayFrameNumber = ceil(maxFrames*temporalResolutionMultiplier);
    referenceTimes = linspace(minSecs,maxSecs,finalDisplayFrameNumber);        
    pausePerStep = (totalTime/finalDisplayFrameNumber)*(1/playbackSpeed);        
    
    
    % --- add plots to figure
    
    % add 2d field axes
            
    % Make axes and images in axes (using time step 1)
    for curProps = plots2d_properties'
        whichDat = curProps{1};
        datNum = find(cellfun(@(curname) strcmp(curname,whichDat),{fields2d.name}));
        fields2d(datNum).ax = axes;
        if useImageOrSurf == 1
            %fields2d(datNum).img = imagesc(fields2d(datNum).ax,flipud(fields2d(datNum).activation(:,:,tStep)));
            fields2d(datNum).img = imagesc(fields2d(datNum).ax,flipud(squeeze(fields2d(datNum).activation(tStep,:,:))));
            hold on;
            if addContour
                [~, fields2d(datNum).cont] = contour([1 0; 0 0] ,1,'linestyle',contLineStyle,'lineColor',contColor,'lineWidth',contLineWidth);
                fields2d(datNum).cont.Visible = 'off';
            end
        elseif useImageOrSurf ==2
            fields2d(datNum).img = surf(fields2d(datNum).ax,(flipud(squeeze(fields2d(datNum).activation(tStep,:,:)))-min(flipud(squeeze(fields2d(datNum).activation(tStep,:,:)))))*scaleSurfData);
            fields2d(datNum).img.CData = squeeze(fields2d(datNum).activation(tStep,:,:));
            %fields2d(datNum).img.EdgeAlpha = .8;
            %fields2d(datNum).img.EdgeColor = [0 0 0];
            %fields2d(datNum).img.LineWidth = 0.25;
        end
        fields2d(datNum).ax.Visible = curProps{2};
        fields2d(datNum).ax.Units = curProps{3};
        fields2d(datNum).ax.Position = curProps{4};        
        warning('off','all')
        obliqueview('xz',44)
        warning('on','all')
        fields2d(datNum).ax.ZLim = curProps{7};
        fields2d(datNum).ax.XLim = curProps{5};
        fields2d(datNum).ax.YLim = curProps{6};
        fields2d(datNum).ax.CLim = curProps{8};       
    end
    
    
    % add 1d field axes        
    
    % Make axes and images in axes (using time step 1)
    for curProps = plots1d_properties'
        whichDat = curProps{1};
        datNum = find(cellfun(@(curname) strcmp(curname,whichDat),{fields1d.name}));
        fields1d(datNum).ax = axes;
        plot(fields1d(datNum).ax,zeros(1,fields1d(datNum).size(1)),1:fields1d(datNum).size(1),'color',[.3 .3 .3],'tag','zeroLine');
        hold on;
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
    
    
    % add dot plots for nodes
        
    % Make axes and transparent round rectangles
    for curProps = plots0d_properties'
        whichDat = curProps{1};
        datNum = find(cellfun(@(curname) strcmp(curname,whichDat),{nodes.name}));
        nodes(datNum).ax = axes;
        nodes(datNum).ax.Visible = curProps{2};
        nodes(datNum).ax.Units = curProps{3};
        nodes(datNum).ax.Position = curProps{4};
        nodes(datNum).dot = rectangle(nodes(datNum).ax,'Curvature',[1 1]);
        nodes(datNum).dot.EdgeColor = 'none';
        nodes(datNum).dot.FaceColor = nodeFaceColor;
        nodes(datNum).axPosBase = nodes(datNum).ax.Position;
        nodes(datNum).YLimBase = nodes(datNum).ax.YLim;
        
        nodes(datNum).outAx = copyobj(nodes(datNum).ax,fig);
        nodes(datNum).outAx.Children.Visible = 'off';
        nodes(datNum).outAx.Children.FaceColor = 'none';
        nodes(datNum).outAx.Children.EdgeColor = nodeRingColor;
        nodes(datNum).outAx.Children.LineStyle = '-';
        nodes(datNum).outAx.Children.LineWidth = nodeRingWidth;
        nodes(datNum).outAx.Units = 'normalized';
        addSideLen_x = nodes(datNum).outAx.Position(3)*nodeRingScaleFactor-nodes(datNum).outAx.Position(3);
        addSideLen_y = nodes(datNum).outAx.Position(4)*nodeRingScaleFactor-nodes(datNum).outAx.Position(4);
        nodes(datNum).outAx.Position = nodes(datNum).outAx.Position + [-addSideLen_x/2 -addSideLen_y/2 addSideLen_x addSideLen_y];
    end
    
    datNum = [];
    
   

%% RUN THIS SECOND (to run animation in figure)

frameRateWarned = 0;
pause(3)

curStep = 1;
while 1        
        
        refTime = referenceTimes(curStep);
        
        % 2d fields
        for curField = 1:size(fields2d,2)
            [~,useStep] = min(abs(fields2d(curField).seconds - refTime)); useStep = useStep(1);
            if useImageOrSurf == 1
                fields2d(curField).img.CData = flipud(squeeze(fields2d(curField).activation(useStep,:,:)));
                if addContour
                    fields2d(curField).cont.ZData = double(squeeze(fields2d(curField).activation(useStep,:,:))>0);
                    fields2d(curField).cont.Visible = 'on';
                end
            elseif useImageOrSurf == 2
                fields2d(curField).ax.Children.Children.ZData = (flipud(squeeze(fields2d(curField).activation(useStep,:,:))-min(squeeze(fields2d(curField).activation(useStep,:,:)))))*scaleSurfData;
                fields2d(curField).ax.Children.Children.CData = flipud(squeeze(fields2d(curField).activation(useStep,:,:)));
            end
        end
        
        % 1d fields
        for curField = 1:size(fields1d,2)
            [~,useStep] = min(abs(fields1d(curField).seconds - refTime)); useStep = useStep(1);
            hCurLine = findobj(fields1d(curField).ax.Children,'tag','dataLine');
            hCurLine.XData = fields1d(curField).activation(useStep,:);
        end
        
        % nodes
        for curNode = 1:size(nodes,2)
            [~,useStep] = min(abs(nodes(curNode).seconds - refTime)); useStep = useStep(1);
            % Compute alpha based on node activation
            lowerBound = -5;
            upperBound = 5;
            
            % use filled area to indicate activation
            scaledActivation = (max(lowerBound,min(upperBound,nodes(curNode).activation(useStep)))+5)/10;
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
            
            % use facecolor to indicate activation (should work if uncommented)
            %curAlpha = 1-(max(lowerBound,min(upperBound,nodes(curNode).activation(useStep)))+5)/10;
            %nodes(curNode).dot.FaceColor = [.1 .1 .1 curAlpha];
            
            % make outline if above threshold
            if nodes(curNode).activation(useStep) > 0
                nodes(curNode).outAx.Children.Visible = 'on';
            else
                nodes(curNode).outAx.Children.Visible = 'off';
            end
            
        end
        
        % Pause at each frame and check whether the desired pause length can be realized by Matlab
        tic
        pause(pausePerStep);           
        tTmp = toc;
        if tTmp > pausePerStep*2 && frameRateWarned==0
            warning('Desired frame rate cannot be achieved, possibly making playback speed unstable. Adjust temporalResolutionMultiplier.')
            frameRateWarned = 1;
        end        
        
    % increment counter or roll around
    if curStep < finalDisplayFrameNumber
        curStep = curStep+1;
    else
        pause(2)
        curStep = 1;
    end
    
end




