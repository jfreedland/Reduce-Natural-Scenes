% Function within retinalMetamers
% By J. Freedland, 2020
%
%%% Pulls information from DOVES database.

function [path, im, saccades, fixations] = pathDOVES(imageNo, observerNo) 

    % Load DOVES information from directory
    imageString = num2str(imageNo);
    directory = '+images/';
    while size(imageString,2) < 3
        imageString = strcat('0',imageString);
    end
    load(strcat(directory,'img',imageString,'.mat'))

    % Pull relevant information
    observer = eye_data{1,observerNo};
    path.x = observer(1,:); % x coordinate data
    path.y = observer(2,:); % y coordinate data
        
    % Isolate eye movement
    movement = diff(path.x).^2 + diff(path.y).^2; % eye velocity (pixels/200Hz)
    movement = movement ./ 60;                    % in degrees: 1 px = 1 arcmin = 1/60 deg
    movement = movement .* 200;                   % in degrees/sec

    saccadeIndex  = find(movement >= 2) + 1;    % saccades > 2 deg/sec
    fixationIndex = find(movement <= 0.5) + 1;  % fixations < 0.5 deg/sec

    % Cluster fixations
    fixationCutoff = fixationIndex((diff(path.x(fixationIndex)).^2 + diff(path.y(fixationIndex)).^2 * 200 / 60) > 3);
    fixationData = cell2struct(cell(3,length(path.x)),{'x','y','fixation_time_ms'});
    minimumFixationLength = 50; % in milliseconds
    counter = 1;
    for a = 1:length(fixationCutoff)-1
        A = fixationIndex(fixationIndex > fixationCutoff(a) & fixationIndex < fixationCutoff(a+1));
        if length(A) > minimumFixationLength .* 200/1000 % Must fixation for >X frames
            fixationData(counter).x = nanmean(path.x(A));
            fixationData(counter).y = nanmean(path.y(A));
            fixationData(counter).fixation_time_ms = length(A) .* 1000/200;
            counter = counter+1;
        end
    end
    fixationData = fixationData(1:counter-1);

    % Mirror image to prevent clipping
    im = [flip(flip(picture,2)) flip(picture) flip(flip(picture,2));
    flip(picture,2) picture flip(picture,2);
    flip(flip(picture,2)) flip(picture) flip(flip(picture,2))];
    path.x = round(path.x + size(picture,2));
    path.y = round(path.y + size(picture,1));
    
    saccades.path = [path.x(saccadeIndex)', path.y(saccadeIndex)'];
    saccades.index = saccadeIndex;

    for a = 1:size(fixationData,1)
        fixationData(a).x = fixationData(a).x + size(picture,2);
        fixationData(a).y = fixationData(a).y + size(picture,1);
    end
    fixations.path = fixationData;
    fixations.index = fixationIndex;
end