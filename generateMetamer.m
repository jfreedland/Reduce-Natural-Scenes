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
%               values:         each region's corresponding light value.
%               metamer values: each metamer's corresponding light value
%               masks:      masks identifying each isolated region
%               metamer:    metamer movie
%               metamerProjection: metamer's low-D representation
%               error:      error between projection and metamer 
%                           (as percent contrast)
%%%

function [stimulus,filenames] = generateMetamer(obj, filename, varargin)
    
    ip = inputParser();
    ip.addParameter('exportRawMovie', false);
    ip.addParameter('exportProjection',false);
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
    
    disp('Pulling metamer library...')
    % This is a lengthy script (several seconds): pulls 1860 individual
    % fixation frames from the DOVES database.
    databaseTraj = metamerUtils.pullLibrary(obj);
    weightedDatabaseTraj = databaseTraj .* RFFilter; % Convolve filter with database
    
    disp('Calculating low-dimensional projection...')

    % Calculate disks
    [stimulus.projection, stimulus.values, stimulus.masks] = utils.linearEquivalency(obj, weightedTraj, RFFilter, stimulus.raw);
    [~, databaseValues] = utils.linearEquivalency(obj, weightedDatabaseTraj, RFFilter, databaseTraj);

    disp('Building metamer(s)...')
    % Build replacements
    stimulus = metamerUtils.findReplacements(obj,stimulus,databaseValues,databaseTraj);

    if obj.smoothing == true
        disp('Smoothing movies...')
        stimulus.projection = utils.applySmoothing(stimulus.projection,stimulus.masks);
        stimulus.metamerProjection = utils.applySmoothing(stimulus.metamerProjection,stimulus.masks);
        stimulus.metamer = utils.applySmoothing(stimulus.metamer,stimulus.masks);
    end

    disp('Exporting movies...')
    if ip.Results.exportRawMovie == true
        filename_adj = strcat('img',string(obj.imageNo),'_raw');
        utils.exportMovie(obj,stimulus.raw,filename_adj)
    end

    filenames = [];
    if ip.Results.exportProjection == true
        filename_adj = strcat(filename,'_projection');
        filenames = [filenames;{filename_adj}];
        utils.exportMovie(obj,stimulus.projection,filename_adj)
    end

    if ~isequal(filename,0)
        for a = 1:size(stimulus.metamer,5)
            filename_adj = strcat(filename,'_metamer-',string(a));
            filenames = [filenames;{filename_adj}];
            utils.exportMovie(obj,stimulus.metamer(:,:,:,:,a),filename_adj)
        end
    end
    disp('Complete.')
    
end