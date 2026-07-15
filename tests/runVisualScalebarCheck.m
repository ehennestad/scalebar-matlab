function runVisualScalebarCheck()
    figure;
    ax = axes;
    imshow(imread('cameraman.tif'))
    
    axis = {'x', 'y'};
    locs = {'northeast', 'northwest', 'southeast', 'southwest'};
    
    for i = 1:2
        for j = 1:4
            for k = 1:2
                loc = locs{j};
                c = 'w';
                if k == 2
                    loc = strcat(loc, 'outside');
                    c = 'r';
                end
                scalebar(ax, axis{i}, 50, 'pixels', 'ConversionFactor', 1, 'Location', loc, 'Color', c, 'LineWidth', 2)
            end
        end
    end
end
