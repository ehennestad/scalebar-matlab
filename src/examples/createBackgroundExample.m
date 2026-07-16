function hFigure = createBackgroundExample(visibility)
%CREATEBACKGROUNDEXAMPLE Demonstrate a semi-transparent scalebar background.
%
%   createBackgroundExample() displays a simulated fluorescence image with
%   a readable scale bar over a visually busy region. Adjust the
%   ShowBackground, BackgroundColor, BackgroundAlpha, and
%   BackgroundPadding name-value arguments below to explore the feature.

    if nargin < 1
        visibility = "on";
    end

    sourceRoot = fileparts(fileparts(mfilename("fullpath")));
    addpath(fullfile(sourceRoot, "scalebar"), "-begin")

    [x, y] = meshgrid(linspace(-3.5, 3.5, 360));
    imageData = 0.18 * sin(5*x - 1.4*y) + 0.12 * cos(7*y);
    sourceCenters = [-1.7 -1.2 0.75; -0.4 0.8 0.48; ...
                     0.9 -0.4 0.62; 1.8 1.4 0.55; 2.3 -1.8 0.38];
    for iSource = 1:size(sourceCenters, 1)
        center = sourceCenters(iSource, :);
        imageData = imageData + exp(-((x-center(1)).^2 + ...
            (y-center(2)).^2) / center(3)^2);
    end

    hFigure = figure("Color", "k", "Units", "pixels", ...
        "Position", [100 100 900 720], "Visible", visibility);
    hAxes = axes(hFigure, "Position", [0 0 1 1]);
    imagesc(hAxes, imageData)
    colormap(hAxes, turbo)
    axis(hAxes, "image", "off")

    hScalebar = scalebar(hAxes, 25, "µm", ...
        ConversionFactor=1.8, Location="southeast", Color="w", ...
        LineWidth=3.2, FontName="Helvetica Neue", FontSize=16, ...
        Margin=[18 16], TextSpacing=6, ShowBackground=true, ...
        BackgroundColor=[0.02 0.03 0.08], BackgroundAlpha=0.68, ...
        BackgroundPadding=8);
    setappdata(hFigure, "ExampleScalebar", hScalebar)
end
