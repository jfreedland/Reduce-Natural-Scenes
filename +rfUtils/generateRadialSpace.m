function [r,th] = generateRadialSpace(obj)

    % Define space as polar coordinates (r = radial, th = theta)
    [xx,yy] = meshgrid(1:obj.videoSize(2),1:obj.videoSize(1));
    r = sqrt((xx - obj.videoSize(2)/2).^2 + (yy - obj.videoSize(1)/2).^2); 
    th = atan((xx - obj.videoSize(2)/2) ./ (yy - obj.videoSize(1)/2));
    th = abs(th-pi/2);              
    
    % Adjust theta space for strange monitors
    nonsmooth = find(diff(th) > pi/2,1);
    th(1:nonsmooth,:) = th(1:nonsmooth,:) + pi;
    th = rad2deg(th);
    th = mod(th + obj.sliceRotation,360); % Rotate as required
end

