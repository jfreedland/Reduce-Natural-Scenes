% Load generic settings for movies in the Rieke lab.
function obj = riekeLabSettings(centerSigma,surroundSigma)

    % Cell information
    obj.rfSigmaCenter       = centerSigma;   % in microns
    obj.rfSigmaSurround     = surroundSigma; % in microns
    
    % Pixel information
    obj.micronsPerPixel     = 1.65;      % How many microns each pixel spans
    obj.monitorSize         = [600 800]; % Size of monitor [height, width]
    obj.monitorFrameRate    = 60;        % Hz
    obj.videoSize = utils.changeUnits(obj.monitorSize,obj.micronsPerPixel,'pix2arcmin');
    if mod(obj.videoSize,2) == 0
        obj.videoSize = obj.videoSize + 1; % Ensure is odd (s.t. central pixel exists)
    end

    % Calculate the location of disks
    [~,info] = rfUtils.calculateFilter(obj);
    obj.diskRadii = [0,...                                                % At center of monitor
        info.percentExcitation(2,(info.percentExcitation(1,:) == 50)),... % At 50% excitation
        info.zeroPt,...                                                   % Where excitatory inputs -> inhibitory
        info.percentInhibition(2,(info.percentInhibition(1,:) == 50)),... % At 50% inhibition
        max(obj.videoSize/2)];                                            % At edge of monitor
    obj.diskRegionUnits = 'arcmin';

    % Stimulus timing
    obj.preTime     = 250;  % (in ms). Presents blank background.
    obj.stimTime    = 5500; % (in ms). Presents main stimulus.
    obj.tailTime    = 250;  % (in ms). Presents blank background.
    
    %%% All settings
    % DOVES information
    obj.imageNo     = 5; % Individual image to show. (#1 - 101)
    obj.observerNo  = 1; % Individual observer for eye tracking. (#1 - 19)
    
    % List of all key variables
    obj.experimentName      = 'test';  % ID for corresponding movie (string)
    obj.diskRegions         = []; % Specific radii for placing disks
    
    % Different types of disks (see EXAMPLES below)
    % Here, we identify each disk from center outwards as #s 1,2,3,...
    obj.meanDisks           = []; % Replace disk #s with linear equivalent disk.
    obj.backgroundDisks     = []; % Replace disk #s with static disk (average intensity of image) 
    obj.naturalDisks        = []; % Replace disk #s with original image
    obj.switchDisks         = []; % Replace disk #s with flashing region (after each saccade)
        obj.switchContrast  = []; % Intensity of flashing region (0 - 1)
    obj.metamerDisks        = []; % Replace disk #s with another naturalistic image.

    %%% EXAMPLES
    %   - Make the center-most disk a linear equivalent disk: 
    %       obj.meanDisks = 1;
    %   - Make the two center-most disks a natural image: 
    %       obj.naturalDisks = [1 2];
    %   - Make the central disk a metamer and second disk switch brightness periodically.
    %       obj.metamerDisks = 1;
    %       obj.switchDisks = 2;
    %       obj.switchContrast = 0.5; % 50% contrast
    %%%
    
    % Slice disks into pie-shaped regions
    obj.slices              = 1;    % How many pie-shaped regions?
        obj.sliceDisks      = [];   % Which disk #s recieve slices?
        obj.sliceRotation   = 0;    % Where to place disks rotationally? (degrees)
        
    %%% EXAMPLES
    %   - Split center disk into 7 slices
    %       obj.slices = 7;
    %       obj.sliceDisks = 1;
    %   - Split second-most center disk into 3 slices rotated 30 deg.
    %       obj.slices = 3;
    %       obj.sliceDisks = 2;
    %       obj.sliceRotation = 30;
    %%%

    obj.smoothing           = false; % Whether to smooth edges on final movies 
    obj.numberOfMetamerMovies = 1;   % Number of unique metamers to make
    
end