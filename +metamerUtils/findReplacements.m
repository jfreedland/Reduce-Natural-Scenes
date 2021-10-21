% Function within retinalMetamers
% By J. Freedland, 2020
%
% Builds metamers based on a library of similarly projected regions.
%
% OUTPUT:   stimulus.metamer:   collection of metamer movies
%                               a 5D matrix. Each movie spans the first 4
%                               dimensions (i.e.
%                               stimulus.metamer(:,:,:,:,1) is one
%                               generated movie.
%
%                               note: the first movie, stimulus.metamer(:,:,:,:,1),
%                               is always the best fit.
%
%           stimulus.metamerProjection: low-dimensional projection of each
%                                       metamer.
%
%           stimulus.error:     difference (in percent contrast) between
%                               the natural image projection and metamer
%                               projection.
%
%           stimulus.metamerValues: light intensity of each projected disk.
%           
%%%

function stimulus = findReplacements(obj,stimulus,databaseValues,databaseTraj)

    stimulus.metamer = zeros(obj.videoSize(1),obj.videoSize(2),1,size(stimulus.values,2),obj.numberOfMetamerMovies);
    stimulus.metamerProjection = zeros(obj.videoSize(1),obj.videoSize(2),1,size(stimulus.values,2),obj.numberOfMetamerMovies);
    stimulus.error = zeros(obj.numberOfMetamerMovies,size(stimulus.values,2));
    stimulus.metamerValues = zeros(size(stimulus.values,1),size(stimulus.values,2),obj.numberOfMetamerMovies);
    
    for a = 1:size(stimulus.values,2)

        % Find best replacement for each disk
        A = stimulus.values(:,a,:);
        B = abs(A - databaseValues);
        [C,i] = sort(B,2);

        % Build best movies
        for c = 1:obj.numberOfMetamerMovies % Find collections of good frames
            stimulus.error(c,a) = nanmean(C(:,c)) ./ obj.backgroundIntensity * 100; % Calculated as percent contrast
            for b = 1:size(C,1)
                if sum(isnan(C(b,:))) == 0
                    stimulus.metamer(:,:,1,a,c) = stimulus.metamer(:,:,1,a,c) + (databaseTraj(:,:,i(b,c)) .* stimulus.masks(:,:,b));
                    stimulus.metamerProjection(:,:,1,a,c) = stimulus.metamerProjection(:,:,1,a,c) + (databaseValues(b,i(b,c)) .* stimulus.masks(:,:,b));
                    stimulus.metamerValues(b,a,c) = databaseValues(b,i(b,c));
                else
                    stimulus.metamer(:,:,1,a,c) = stimulus.metamer(:,:,1,a,c) + stimulus.raw(:,:,1,a) .* stimulus.masks(:,:,b);
                    stimulus.metamerProjection(:,:,1,a,c) = NaN;
                    stimulus.metamerValues(b,a,c) = NaN;
                end
            end
        end
    end

    surroundMask = (sum(stimulus.masks,3) == 0);
    stimulus.metamer = stimulus.metamer + surroundMask .* obj.backgroundIntensity;
    stimulus.metamerProjection = stimulus.metamerProjection + surroundMask .* obj.backgroundIntensity;
end