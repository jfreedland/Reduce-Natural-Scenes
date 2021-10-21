% Function within retinalMetamers
% By J. Freedland, 2020
%
%%% Project a naturalistic retinal movie into a low-dimensional
%%% representation. 
%
% Input:    obj: see DEMO
%           filename: name of exported MPG. Set to 0 to prevent exporting
%
% Output:   stimulus: structure with fields:
%               raw:        naturalistic movie
%               projection: low-dimensional representation
%               values:     each region's corresponding light value.
%               masks:      masks identifying each isolated region
%%%

function [stimulus,filename_adj] = generateProjection(obj, filename, varargin)

    ip = inputParser();
    ip.addParameter('exportRawMovie', false);
    ip.parse(varargin{:});

    disp('Building basic trajectory...')

    % Pull base trajectories and image information.
    [path,img,obj.saccades] = utils.pathDOVES(obj.imageNo, obj.observerNo);
                
    % Normalize image to monitor
    img = (img./max(max(img)));
    img = img.*255;
    obj.imageMatrix = uint8(img);
    
    % Mean light intensity for retinal adaptation.
    obj.backgroundIntensity = mean(img(:));

    % Eye movement patterns from DOVES database.
    DOVES_trajectory    = 1/200:1/200:(length(path.x)/200); % 200 Hz
    monitorTrajectory   = 1/obj.monitorFrameRate:1/obj.monitorFrameRate:(length(path.x)/200);
    obj.xTraj = interp1(DOVES_trajectory,path.x,monitorTrajectory);
    obj.yTraj = interp1(DOVES_trajectory,path.y,monitorTrajectory);

    % Calculate individual neuron's receptive field (RF).
    [RFFilter,obj.rfSizing] = rfUtils.calculateFilter(obj);

    % Convolve filter with trajectory
    [weightedTraj, stimulus.raw] = utils.weightedTrajectory(obj, img, RFFilter);
    disp('Calculating low-dimensional projection...')

    % Calculate disks
    [stimulus.projection, stimulus.values, stimulus.masks] = utils.linearEquivalency(obj, weightedTraj, RFFilter, stimulus.raw);
    
    if obj.smoothing == true
        disp('Smoothing movies...')
        stimulus.projection = utils.applySmoothing(stimulus.projection,stimulus.masks);
    end
    
    disp('Exporting movies...')
    if ip.Results.exportRawMovie == true
        filename_adj = strcat('img',string(obj.imageNo),'_raw');
        utils.exportMovie(obj,stimulus.raw,filename_adj)
    end
    
    if ~isequal(filename,0)
        filename_adj = strcat(filename,'_projection');
        utils.exportMovie(obj,stimulus.projection,filename_adj)
    else
        filename_adj = [];
    end
    
    disp('Complete.')
end