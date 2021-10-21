% Function within retinalMetamers
% By J. Freedland, 2020
%
%%% Exports stimulus as movie intended for neuron testing.

function exportMovie(obj,specificMovie,filename)
    
    % Convert to monitor frames
    preFrameNumb = round(obj.preTime/(1000/obj.monitorFrameRate));
    stimFrameNumb = round(obj.stimTime/(1000/obj.monitorFrameRate));
    postFrameNumb = round(obj.tailTime/(1000/obj.monitorFrameRate));
    
    % Build background frames for pre and post time
    preFrames = zeros(size(specificMovie,1),size(specificMovie,2),...
        1,preFrameNumb) + obj.backgroundIntensity;
    postFrames = zeros(size(specificMovie,1),size(specificMovie,2),...
    1,postFrameNumb) + obj.backgroundIntensity;

    frames = size(specificMovie,4);
    
    if frames < stimFrameNumb % Too few frames, repeat last fame
        lastFrame = repmat(specificMovie(:,:,1,end),1,1,1,stimFrameNumb - frames);
        preparedMovie = uint8(cat(4,preFrames,specificMovie,lastFrame,postFrames));
    else
        preparedMovie = uint8(cat(4,preFrames,specificMovie(:,:,1,1:stimFrameNumb),postFrames));
    end

    % Export as MPEG-4. 
    directory = '';
    v = VideoWriter(strcat(directory,filename),'MPEG-4');
    v.FrameRate = obj.monitorFrameRate;

    open(v)
    for b = 1:size(preparedMovie,4)
        writeVideo(v,preparedMovie(:,:,:,b))
    end
    close(v)
end

