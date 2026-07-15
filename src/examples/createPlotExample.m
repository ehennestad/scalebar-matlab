function hFigure = createPlotExample(visibility)
%CREATEPLOTEXAMPLE Create a publication-style membrane-potential trace.
%
%   createPlotExample() displays a simulated recording with horizontal and
%   vertical scale bars. The example uses only MATLAB base functionality.

    if nargin < 1
        visibility = "on";
    end

    sourceRoot = fileparts(fileparts(mfilename("fullpath")));
    addpath(fullfile(sourceRoot, "scalebar"), "-begin")

    rng(28, "twister")
    sampleRate = 10000;
    time = 0:1/sampleRate:2.45;
    voltage = -68 + 0.45*movmean(randn(size(time)), 7) + ...
        0.7*sin(2*pi*1.2*time) + 0.25*sin(2*pi*8*time);

    burstWindows = [0.26 0.62; 1.00 1.39; 1.78 2.25];
    for iBurst = 1:size(burstWindows, 1)
        onset = burstWindows(iBurst, 1);
        offset = burstWindows(iBurst, 2);
        voltage = voltage + 5.5 .* (...
            1./(1+exp(-(time-onset)/0.012)) - ...
            1./(1+exp(-(time-offset)/0.030)));
    end

    spikeTimes = [0.30 0.36 0.43 0.51 0.59, ...
                  1.05 1.12 1.20 1.29 1.37, ...
                  1.83 1.90 1.98 2.07 2.17 2.24];
    for spikeTime = spikeTimes
        elapsed = time-spikeTime;
        actionPotential = 101*exp(-0.5*(elapsed/0.00058).^2);
        afterhyperpolarization = -10.5 .* ...
            (1-exp(-max(elapsed, 0)/0.0018)) .* ...
            exp(-max(elapsed, 0)/0.018);
        afterhyperpolarization(elapsed < 0) = 0;
        voltage = voltage + actionPotential + afterhyperpolarization;
    end

    backgroundColor = [0.985 0.985 0.978];
    hFigure = figure("Color", backgroundColor, "Units", "pixels", ...
        "Position", [100 100 1320 520], "Visible", visibility);
    hAxes = axes(hFigure, "Position", [0.025 0.055 0.95 0.90], ...
        "Color", backgroundColor);
    hold(hAxes, "on")
    plot(hAxes, time, voltage, "Color", [0.72 0.88 0.90], "LineWidth", 5.2)
    plot(hAxes, time, voltage, "Color", [0.02 0.34 0.45], "LineWidth", 1.75)
    hold(hAxes, "off")
    hAxes.XLim = [0 3.2];
    hAxes.YLim = [-90 46];
    axis(hAxes, "off")

    scaleColor = [0.13 0.16 0.19];
    scaleBarMargin = [42 32];
    hTimeScalebar = scalebar(hAxes, 500, "ms", ...
        Axis="x", ConversionFactor=0.001, Location="southeast", ...
        Color=scaleColor, LineWidth=3.2, FontName="Helvetica Neue", ...
        FontSize=15, Margin=scaleBarMargin, TextSpacing=7);
    hVoltageScalebar = scalebar(hAxes, 50, "mV", ...
        Axis="y", Location="southeast", Color=scaleColor, ...
        LineWidth=3.2, FontName="Helvetica Neue", FontSize=15, ...
        Margin=scaleBarMargin, TextSpacing=7);
    setappdata(hFigure, "ExampleScalebars", ...
        [hTimeScalebar hVoltageScalebar])
end
