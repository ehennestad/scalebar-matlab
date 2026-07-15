function generateReadmeImages()
%GENERATEREADMEIMAGES Export the README example figures as PNG files.

    repositoryRoot = fileparts(fileparts(mfilename("fullpath")));
    outputFolder = fullfile(repositoryRoot, "docs", "images");
    if ~isfolder(outputFolder)
        mkdir(outputFolder)
    end

    addpath(fullfile(repositoryRoot, "src", "examples"), "-begin")

    hFigure = createImageExample("off");
    exportgraphics(hFigure, ...
        fullfile(outputFolder, "scalebar-image-example.png"), ...
        "Resolution", 150, "BackgroundColor", "current")
    close(hFigure)

    hFigure = createPlotExample("off");
    exportgraphics(hFigure, ...
        fullfile(outputFolder, "scalebar-plot-example.png"), ...
        "Resolution", 150, "BackgroundColor", "current")
    close(hFigure)
end
