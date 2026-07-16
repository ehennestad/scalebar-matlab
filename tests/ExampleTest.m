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

        function testBackgroundExampleCreatesScalebarBackground(testCase)
            repositoryRoot = fileparts(fileparts(mfilename("fullpath")));
            addpath(fullfile(repositoryRoot, "src", "examples"))

            hFigure = createBackgroundExample("off");
            testCase.addTeardown(@() close(hFigure))

            hBackground = findobj(hFigure, "Tag", "Scalebar Background");
            hScalebarLine = findobj(hFigure, "Tag", "Scalebar Line");
            hScalebarText = findobj(hFigure, "Tag", "Scalebar Text");
            hImage = findobj(hFigure, "Type", "image");
            hChildren = hBackground.Parent.Children;

            testCase.verifyNumElements(hBackground, 1)
            testCase.verifyEqual(hBackground.FaceAlpha, 0.68)
            testCase.verifyLessThan(find(hChildren == hBackground), ...
                find(hChildren == hImage))
            testCase.verifyGreaterThan(find(hChildren == hBackground), ...
                find(hChildren == hScalebarLine))
            testCase.verifyGreaterThan(find(hChildren == hBackground), ...
                find(hChildren == hScalebarText))
        end
    end
end
