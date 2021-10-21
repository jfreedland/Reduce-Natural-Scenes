% Function within retinalMetamers
% By J. Freedland, 2020
%
%%% Applies Gaussian smoothing along edges of image. 

function movieOutput = applySmoothing(movieInput,masks)

    % Identify edges of masks
    kernel = [-1 -1 -1;-1 8 -1;-1 -1 -1];
    smoothingMask = zeros(size(movieInput,1),size(movieInput,2));
    for a = 1:size(masks,3)
        smoothingMask = smoothingMask + abs(imfilter(masks(:,:,a), kernel, 'same'));
    end
    smoothingMask(smoothingMask > 0) = 1;

    movieOutput = zeros(size(movieInput));
    for b = 1:size(movieInput,5) % Each movie
        for c = 1:size(movieInput,4) % Each frame

            % Blur relevant frame
            regionBlur = imgaussfilt(movieInput(:,:,:,c,b),2);
            regionBlur = regionBlur .* smoothingMask; % Only take specific region

            % Remove region from movie
            movieOutput(:,:,:,c,b) = movieInput(:,:,:,c,b) .* double(smoothingMask == 0); % Remove region
            
            % Add in blurred region
            movieOutput(:,:,:,c,b) = movieOutput(:,:,:,c,b) + regionBlur; % re-add frame

        end
    end
end

