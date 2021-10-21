% Function within retinalMetamers
% By J. Freedland, 2020
%
% The head honcho. Calculates weighted averages (using a natural image
% movie convolved with the neuron's RF) for each pre-specifed region.
%
% OUTPUT:   newTraj: projected naturalistic image.
%           diskValues: light intensity of each disk
%           masks: shape of each mask
%%%
function [newTraj, diskValues, masks] = linearEquivalency(obj, weightedTrajectory, RFFilter, unweightedTrajectory)   

    [r,th] = rfUtils.generateRadialSpace(obj);
    
    % Identify user-specific radii
    if strcmp(obj.diskRegionUnits,'pix')
        obj.radii = round(utils.changeUnits(obj.diskRegions,obj.micronsPerPixel,'pix2arcmin'));
    elseif strcmp(obj.diskRegionUnits,'um')
        obj.radii = round(utils.changeUnits(obj.diskRegions,obj.micronsPerPixel,'um2arcmin'));
    elseif strcmp(obj.diskRegionUnits,'deg')
        obj.radii = obj.radii / 60; % DOVES units are in arcmin
    elseif strcmp(obj.diskRegionUnits,'arcmin')
        obj.radii = obj.diskRegions;
    else
        error('Please identify correct diskRegionUnit: "pix", "um", "deg", or "arcmin"')
    end
    
    obj.slices(obj.slices == 0) = 1;
    obj.theta = 0:360/obj.slices:360;
    
    % Generate switchDisk values, used to measure impact of surround.
    if sum(obj.switchDisks) > 0
        obj.switchTraj = utils.generateSwitchDisks(obj);
    end

    newTraj = zeros(size(weightedTrajectory));
    diskValues = zeros((length(obj.radii)-1).*(length(obj.theta)-1),size(weightedTrajectory,4));
    masks = zeros(size(weightedTrajectory,1),size(weightedTrajectory,2),(length(obj.radii)-1).*(length(obj.theta)-1));

    % Calculate statistics
    counter = 1;
    for a = 1:length(obj.radii) - 1
        radiusFilt = r >= obj.radii(a) & r <= obj.radii(a+1); % Radial filter (r)
        for b = 1:length(obj.theta) - 1
            angFilt = th >= obj.theta(b) & th < obj.theta(b+1); % Angular filter (theta)
            ignoreDisk = false;
            
            % Whether to ignore angular filter
            if ~ismember(a,obj.sliceDisks)
                angFilt = ones(size(angFilt));
                if b > 1
                    ignoreDisk = true;
                end
            end  

            filt = radiusFilt .* angFilt;
            tempMask = zeros(size(weightedTrajectory));
            
            % For linear equivalent regions
            if ignoreDisk == false
                masks(:,:,counter) = filt;
                if ismember(a,obj.meanDisks)
                    
                    % Normalizing value
                    T = sum(RFFilter .* filt,[1 2]);

                    % Apply across trajectory
                    for c = 1:size(weightedTrajectory,4)
                        S = weightedTrajectory(:,:,1,c) .* filt;
                        diskValues(counter,c) = sum(S(:)) / T;
                        tempMask(:,:,1,c) = diskValues(counter,c) .* filt;
                    end
                elseif ismember(a,obj.backgroundDisks)
                    
                    % Apply across trajectory
                    for c = 1:size(diskValues,2)
                        tempMask(:,:,1,c) = obj.backgroundIntensity .* filt;
                        diskValues(counter,c,:) = obj.backgroundIntensity;
                    end
                elseif ismember(a,obj.naturalDisks)
                    
                    % Apply original image to region
                    for c = 1:size(diskValues,2)
                        tempMask(:,:,1,c) = unweightedTrajectory(:,:,1,c) .* filt;
                        diskValues(counter,c,:) = NaN;
                    end

                elseif ismember(a,obj.switchDisks)
                    % Apply specific intensity to region
                    for c = 1:size(diskValues,2)
                        tempMask(:,:,1,c) = obj.switchTraj(c) .* filt;
                        diskValues(counter,c,:) = obj.switchTraj(c);
                    end
                    
                elseif ismember(a,obj.metamerDisks)

                    % Normalizing disk
                    F = filt;
                    F(F == false) = NaN;
                    T = RFFilter .* F;

                    % Apply across trajectory
                    for c = 1:size(weightedTrajectory,4)
                        S = weightedTrajectory(:,:,1,c) .* F;
                        diskValues(counter,c) = nanmean(S,[1,2]) / nanmean(T,[1,2]);
                        tempMask(:,:,1,c) = diskValues(counter,c) .* filt;
                    end  
                else
                    error(strcat('please specify disk type for disk #',num2str(a)))
                end
                newTraj = newTraj + tempMask;
            end
            counter = counter + 1;
        end
    end

    % Add surrounding mask
    surroundMask = (sum(masks,3) == 0);
    newTraj = newTraj + surroundMask .* obj.backgroundIntensity;

    % Remove excess values
    rm = find(sum(masks,[1,2]) == 0);
    diskValues(rm,:,:) = [];
    masks(:,:,rm) = [];
end