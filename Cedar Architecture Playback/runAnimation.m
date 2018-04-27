%% Animation
tic
pause(3)

curStep = 1;
while 1
    
    aroundTime = toc;
    currentFrameRate = 1/toc;
    effectivePlayback = currentFrameRate/baseFrameRate;
    disp(['Effective playback rate is ' num2str(effectivePlayback) '(desired: ' num2str(playbackSpeed) ')']);        
    
    tic
    
    refTime = referenceTimes(curStep);
    
    % 2d fields
    for curField = 1:size(fields2d,2)
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
    for curField = 1:size(fields1d,2)
        [~,useStep] = min(abs(fields1d(curField).seconds - refTime)); useStep = useStep(1);
        hCurLine = findobj(fields1d(curField).ax.Children,'tag','dataLine');
        hCurLine.XData = fields1d(curField).activation(useStep,:);
    end
    
    % nodes
    for curNode = 1:size(nodes,2)
        
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
    
    % Pause at each frame and check whether the desired pause length can be realized by Matlab
    pause(pausePerStep);
       
    % increment counter or roll around
    if curStep < finalDisplayFrameNumber
        curStep = curStep+1;
    else
        pause(2)
        curStep = 1;
    end
    
end