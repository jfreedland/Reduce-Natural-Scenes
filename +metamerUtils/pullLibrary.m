% Function within retinalMetamers
% By J. Freedland, 2020
%
% Pulls the frame of every fixation from the DOVES database.
%%%

function imageFrames = pullLibrary(obj)

    load('+images/fixationDatabase.mat')
    obj.frameNumber = frameNumber;
    obj.imageNumber = imageNumber;
    
    % Pixels on each side of the trajectory.
    xLength = floor(obj.videoSize(2) / 2);
    yLength = floor(obj.videoSize(1) / 2);

    % Identify images to load
    A = unique(obj.imageNumber);
    A(A == obj.imageNo) = []; % Don't include original image

    imageFrames = zeros(yLength.*2+1,xLength.*2+1,1,length(obj.imageNumber)); % Collection of images
    counter = 1;

    for a = 1:length(A)
        tempImage = A(a);
        [path,img,~] = utils.pathDOVES(tempImage, 1); % Pull image number
        
        % Scale pixels in image to monitor
        img = (img./max(max(img)));
        img = img.*255;

        % Identify number of fixations
        frames = obj.frameNumber(obj.imageNumber == A(a));

        for b = 1:length(frames)

            % Pull frame #
            x = path.x(frames(b));
            y = path.y(frames(b));

            % Pull image
            imageFrames(:,:,1,counter) = img(y-yLength:y+yLength,...
                x-xLength:x+xLength); 
            counter = counter + 1;
        end
    end
end