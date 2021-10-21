% Transforms eye trajectory from DOVES database into a naturalistic movie
% convolved with the neuron's receptive field.
%
% By J. Freedland, 2019.
%%%

function [weightedMovie, rawMovie] = weightedTrajectory(obj, img, RFFilter)

    % Pixels on each side of the trajectory.
    xLength = floor(obj.videoSize(2) / 2);
    yLength = floor(obj.videoSize(1) / 2);

    % Calculate movie frames with DOVES eye trajectories
    xRange = zeros(length(obj.xTraj),xLength*2+1);
    yRange = zeros(length(obj.yTraj),yLength*2+1);
    for a = 1:length(obj.xTraj)
        xRange(a,:) = round(obj.xTraj(a) - xLength : obj.xTraj(a) + xLength);
        yRange(a,:) = round(obj.yTraj(a) - yLength : obj.yTraj(a) + yLength);
    end

    % Make movies
    rawMovie = zeros(size(yRange,2),size(xRange,2),1,length(obj.xTraj));
    weightedMovie = zeros(size(yRange,2),size(xRange,2),1,length(obj.xTraj));
    for a = 1:length(obj.xTraj)
        rawMovie(:,:,1,a) = img(yRange(a,:),xRange(a,:)); % raw movie
        weightedMovie(:,:,1,a) = rawMovie(:,:,1,a) .* RFFilter;% convolved movie
    end
end