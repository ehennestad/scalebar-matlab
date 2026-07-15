classdef ExampleTest < matlab.unittest.TestCase

    methods (Test)
        function testPlotExampleCreatesTwoScalebars(testCase)
            repositoryRoot = fileparts(fileparts(mfilename("fullpath")));
            addpath(fullfile(repositoryRoot, "src", "examples"))

            hFigure = createPlotExample("off");
            testCase.addTeardown(@() close(hFigure))

            hScalebarLines = findobj(hFigure, "Tag", "Scalebar Line");
            testCase.verifyTrue(isgraphics(hFigure))
            testCase.verifyNumElements(hScalebarLines, 2)
        end

        function testImageExampleHandlesToolboxAvailability(testCase)
            repositoryRoot = fileparts(fileparts(mfilename("fullpath")));
            addpath(fullfile(repositoryRoot, "src", "examples"))

            hasImageProcessingSupport = ...
                exist("cell.tif", "file") == 2 && ...
                exist("imgaussfilt", "file") == 2 && ...
                exist("adapthisteq", "file") == 2 && ...
                exist("imadjust", "file") == 2 && ...
                exist("mat2gray", "file") == 2 && ...
                exist("stretchlim", "file") == 2;

            if ~hasImageProcessingSupport
                testCase.verifyError(@() createImageExample("off"), ...
                    "scalebar:ImageExampleRequiresImageProcessingToolbox")
                return
            end

            hFigure = createImageExample("off");
            testCase.addTeardown(@() close(hFigure))

            hScalebarLines = findobj(hFigure, "Tag", "Scalebar Line");
            testCase.verifyTrue(isgraphics(hFigure))
            testCase.verifyNumElements(hScalebarLines, 1)
        end
    end
end
