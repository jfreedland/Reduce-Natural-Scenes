% Function within retinalMetamers
% By J. Freedland, 2020
%
% After calculating a neuron's receptive field (RF), a difference of gaussian
% (DoG) filter is created. This is used to normalize values in the
% naturalistic image's projection.
%
% INPUTS:   obj: structure from retinalMetamers
%               must contain:   obj.rfSigmaCenter (in microns)
%                               obj.rfSigmaSurround (in microns)
%                               obj.micronsPerPixel
%                               obj.videoSize (desired video size, in ARCMIN) 
%
% OUTPUTS:  RFFilter: receptive field filter
%           info: select calculations (in ARCMIN)
%%%

function [RFFilter,info] = calculateFilter(obj)

    % Convert neuron's RF to DOVES VH units.
    centerSigma = utils.changeUnits(obj.rfSigmaCenter,obj.micronsPerPixel,'um2arcmin');
    surroundSigma = utils.changeUnits(obj.rfSigmaSurround,obj.micronsPerPixel,'um2arcmin');

    % Generate 2D gaussians
    centerGaus = fspecial('gaussian',[obj.videoSize(1) obj.videoSize(2)],centerSigma);
    surroundGaus = fspecial('gaussian',[obj.videoSize(1) obj.videoSize(2)],surroundSigma);

    % Calculate difference of gaussians
    diffGaussian = centerGaus - surroundGaus;
    RFFilter = diffGaussian ./ max(diffGaussian(:)); % Normalize filter

    %%% Extract RF information
    % Take 2D slice of half-gaussian.
    slice       = RFFilter(round(obj.videoSize(1)/2),round(obj.videoSize(2)/2):end); 
    curvature   = diff(slice);        % Derivative
    tot         = cumsum(slice);    
    tot         = tot ./ max(tot(:)); % Normalized integral
    
    %%% Extract RF information
    % Location with largest inhibitory response.
    [~,info.maximallyInhibitory] = min(slice);

    % Location where excitatory response switches to inhibitory.
    [~,info.zeroPt] = min(abs(slice(1:info.maximallyInhibitory)));

    [~,info.maxExcitatoryCurvature] = min(curvature); % Excitatory curvature
    [~,info.maxInhibitoryCurvature] = max(curvature); % Inhibitory curvature

    % Location where total excitation = total inhibition
    [~,info.excInhBalancePoint] = min(abs(tot(1:info.zeroPt) - tot(end)));
    
    % Radius that captures % of total excitation/inhibition
    inhibitoryRegion = (1 - tot(info.zeroPt:end)) / (1-tot(end));
    percentages = 5:5:95; % Percentages to calculate
    locationsExc = zeros(1,length(percentages));
    locationsInh = zeros(1,length(percentages));
    for a = 1:length(percentages)
        % Excitatory
        [~,locationsExc(a)] = min(abs(tot(1:info.zeroPt) - percentages(a)/100));
        
        % Inhibitory
        [~,locationsInh(a)] = min(abs(inhibitoryRegion - percentages(a)/100));
        locationsInh(a) = locationsInh(a) + info.zeroPt;
    end
    info.percentExcitation = [percentages; locationsExc];
    info.percentInhibition = [percentages; locationsInh];
    
    % Total amount of inhibition by cell
    info.totalInhibition = 1 - tot(end);
    
    % To visualize this region, uncomment:
%     figure(1)
%     plot(slice)
%     title('2D slice of receptive field')
%     ylabel('integration weight')
%     xlabel('space (arcmin)')
%     hold on
%     plot(info.zeroPt,slice(info.zeroPt),'ro','LineWidth',2)
%     plot(info.maximallyInhibitory,slice(info.maximallyInhibitory),'bo','LineWidth',2)
%     exc50 = info.percentExcitation(2,info.percentExcitation(1,:)==50); % 50% excitation
%     inh50 = info.percentInhibition(2,info.percentInhibition(1,:)==50); % 50% inhibition
%     plot(exc50,slice(exc50),'kx')
%     plot(inh50,slice(inh50),'kx')
%     hold off
%     keyboard

end