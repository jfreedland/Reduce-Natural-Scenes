% Function within retinalMetamers
% By J. Freedland, 2020
%
%%% Change units within retinalMetamers.
%
% Using user settings for "micronsPerPixel" (um/pix), we define a series of units:
%   arcmin:   arc minutes. also: units used in eye tracking studies, courtesy of the DOVES database
%   um:       microns (across the retina)
%   pix:      monitor pixels (output).
%
% micronsPerPixel:  number of microns each output monitor pixel spans.
%                   depends on experimental setup.
%%%

function B = changeUnits(A,micronsPerPixel,type)
            
    if strcmp(type,'um2pix')
        % um / (um/pix) = pix
        B = A ./ micronsPerPixel;

    elseif strcmp(type,'pix2um')
        % pix * (um/pix) = um
        B = A .* micronsPerPixel;

    elseif strcmp(type,'um2arcmin')
        % From DOVES database: 1 pixel = 1 arcmin.
        % um / (3.3 um/arcmin) = arcmin
        B = A ./ 3.3;

    elseif strcmp(type,'arcmin2um')
        % arcmin * (3.3 um/arcmin) = um
        B = A .* 3.3;

    elseif strcmp(type,'pix2arcmin')
        % (3.3 um/arcmin) / (um/pix) = pix/VH
        ratio = 3.3 ./ micronsPerPixel;

        % pix / (pix/VH) = VH
        B = A ./ ratio;

    elseif strcmp(type,'arcmin2pix')
        % (3.3 um/arcmin) / (um/pix) = pix/arcmin
        ratio = 3.3 ./ micronsPerPixel;

        % arcmin * (pix/arcmin) = pix
        B = A .* ratio;
    else
        error('incorrect unit conversion.')
    end
end