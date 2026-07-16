function runVisualScalebarCheck()
%RUNVISUALSCALEBARCHECK Display scale bars in every location for visual review.
%
%   Creates a test image and adds horizontal and vertical scale bars in all
%   supported locations, inside (white) and outside (red) the axes. Inspect
%   the figure manually to confirm placement and appearance.

    repositoryRoot = fileparts(fileparts(mfilename('fullpath')));
    addpath(fullfile(repositoryRoot, 'src', 'scalebar'))

    hFigure = figure();
    hAxes = axes(hFigure);
    imagesc(hAxes, peaks(256))
    colormap(hAxes, gray)
    axis(hAxes, 'image')

    axisOptions = {'x', 'y'};
    locations = {'northeast', 'northwest', 'southeast', 'southwest'};

    for i = 1:numel(axisOptions)
        for j = 1:numel(locations)
            for k = 1:2
                location = locations{j};
                color = 'w';
                if k == 2
                    location = strcat(location, 'outside');
                    color = 'r';
                end
                scalebar(hAxes, axisOptions{i}, 50, 'pixels', ...
                    'ConversionFactor', 1, 'Location', location, ...
                    'Color', color, 'LineWidth', 2)
            end
        end
    end
end
