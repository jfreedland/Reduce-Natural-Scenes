% This demo serves as a guide to building low-dimensional representations for naturalistic
% stimuli on a neuron-by-neuron basis.
% By J. Freedland, 2020.
%% 8-D center-only naturalistic projection: a simple introduction.
clc
clear
% First, measure a neuron's receptive field using a standard
% difference-of-Gaussians.
centerSigma     = 70;  % in um.
surroundSigma   = 170; % in um.

% Load generic settings
obj = demoUtils.riekeLabSettings(centerSigma,surroundSigma);

% Choose image to reduce/build metamer for;
obj.imageNo = 5; % Courtesy of the DOVES database--choose value from 1-101.

% Information for reducing movie (see loadSettings for more).
obj.diskRegions = obj.diskRadii([1 3]); % Place one disk between regions [1] and [3]
                                        %%% Note: obj.diskRadii([3]) = radius of receptive-field center
obj.meanDisks   = 1;                    % Make disk a linear-equivalent projection
obj.slices      = 8;                    % Split disk into 8 regions
obj.sliceDisks  = 1;                    % Apply slicing to our single disk

% Builds a reduced represenation
output = generateProjection(obj,'sample');
implay(uint8([output.raw output.projection]))

% For further analysis
spatialRegions  = output.masks;  % View each spatial region ( i.e imshow(spatialRegions(:,:,1)) )
luminanceValues = output.values; % Each spatial region's 8-bit luminance (1st dim) in each movie frame (2nd dim)

%% A more complex projection.
clc
clear
centerSigma     = 70;
surroundSigma   = 170;
obj             = demoUtils.riekeLabSettings(centerSigma,surroundSigma);
obj.imageNo     = 5;

% Projection information (see loadSettings for more).
obj.diskRegions     = obj.diskRadii([1 3 5]); % Place TWO disks: 1 bounded by [1,3] and a second bounded by [3,5]
obj.naturalDisks    = 1;                      % Make the centermost disk a naturalistic movie
obj.meanDisks       = 2;                      % Make the second centermost disk a linear-equivalent projection
obj.slices          = 5;                      % Split disks into 5 regions
obj.sliceDisks      = 2;                      % Only apply to second center-most disk. Set to [1 2] to slice both disks.
obj.sliceRotation   = 35;                     % Rotate by 35 degrees.
obj.smoothing       = true;                   % Smooth edges

output = generateProjection(obj,'sample');
implay(uint8([output.raw output.projection]))

% For further analysis
spatialRegions  = output.masks;
luminanceValues = output.values;

%% 8-D center-only naturalistic metamer
% Note: metamer generation reduces a large library of images.
% This can result in slow generation times (typically < 1 min)
clc
clear
centerSigma      = 70;
surroundSigma    = 170;
obj              = demoUtils.riekeLabSettings(centerSigma,surroundSigma);
obj.imageNo      = 5;
obj.diskRegions  = obj.diskRadii([1 3]); % Place one disk between regions [1] and [3]
obj.metamerDisks = 1;                    % Replace region with metamer(s)
obj.slices       = 8;                    % Split disk into 8 regions
obj.sliceDisks   = 1;                    % Apply slicing to our single disk

% Metamer information
output = generateMetamer(obj,'sample');
implay(uint8([output.raw output.metamerProjection output.metamer]))