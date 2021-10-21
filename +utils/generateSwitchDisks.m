% Function within retinalMetamers
% By J. Freedland, 2020
%
% Generates a "switchDisk" trajectory. These types of disks use saccades to
% define when to switch between bright and dark regions (relative to the
% average light intensity).
%%%
function traj = generateSwitchDisks(obj)

    % Downsample trajectory
    saccades = unique(round(obj.saccades.index / (200 / obj.monitorFrameRate)));
    
    % Remove single frames (too much flashing)
    for iter = 1:10
        elim = find(diff(saccades) > 1 & diff(saccades) < 10) + 1;
        saccades(elim) = [];
    end
    saccadeSwitch = [1 saccades(diff([1 saccades]) > 1) length(obj.xTraj)];

    % We want to hold flashes for fixations after a saccade
    saccadeTraj = false(1,length(obj.xTraj));
    for a = 1:2:length(saccadeSwitch)-1
        saccadeTraj(saccadeSwitch(a):saccadeSwitch(a+1)) = true;
    end

    % Identify intensity over time
    contrast = obj.backgroundIntensity .* obj.switchContrast;
    traj = zeros(1,length(obj.xTraj));
    traj(saccadeTraj) = obj.backgroundIntensity - contrast;
    traj(~saccadeTraj) = obj.backgroundIntensity + contrast;
end