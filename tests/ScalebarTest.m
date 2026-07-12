classdef ScalebarTest < matlab.unittest.TestCase

    properties (Access = private)
        Figure
        Axes
        AlternateFont string
    end

    methods (TestMethodSetup)
        function createAxes(testCase)
            repositoryRoot = fileparts(fileparts(mfilename('fullpath')));
            addpath(fullfile(repositoryRoot, 'src', 'scalebar'))

            testCase.Figure = figure('Visible', 'off');
            testCase.Axes = axes(testCase.Figure);
            plot(testCase.Axes, [0, 10], [0, 10])
            testCase.Axes.XLim = [0, 10];
            testCase.Axes.YLim = [0, 10];

            hText = text(testCase.Axes, 0, 0, '');
            defaultFont = string(hText.FontName);
            delete(hText)
            availableFonts = string(listfonts);
            testCase.AlternateFont = availableFonts( ...
                find(availableFonts ~= defaultFont, 1));

            testCase.addTeardown(@() close(testCase.Figure))
        end
    end

    methods (Test)
        function testConstructorAcceptsStringNameValueArguments(testCase)
            hScalebar = testCase.createScalebar( ...
                "x", 2, "mm", "Location", "northwest");

            testCase.verifyEqual(hScalebar.Location, 'northwest')
            testCase.verifyEqual(hScalebar.UnitLabel, 'mm')
        end

        function testConstructorPreservesCharacterVectorInputs(testCase)
            hScalebar = testCase.createScalebar( ...
                'x', 2, 'mm', 'Location', 'northwest');

            testCase.verifyEqual(hScalebar.Location, 'northwest')
            testCase.verifyEqual(hScalebar.UnitLabel, 'mm')
        end

        function testConstructorAppliesVisibleAndFontName(testCase)
            requestedFont = testCase.AlternateFont;
            hScalebar = testCase.createScalebar( ...
                "Visible", "off", "FontName", requestedFont);

            hLine = findobj(testCase.Axes, 'Tag', 'Scalebar Line');
            hText = findobj(testCase.Axes, 'Tag', 'Scalebar Text');
            testCase.verifyEqual(hScalebar.Visible, matlab.lang.OnOffSwitchState.off)
            testCase.verifyEqual(hLine.Visible, matlab.lang.OnOffSwitchState.off)
            testCase.verifyEqual(hText.Visible, matlab.lang.OnOffSwitchState.off)
            testCase.verifyEqual(string(hText.FontName), requestedFont)
        end

        function testConstructorRejectsUnknownOption(testCase)
            testCase.verifyError( ...
                @() scalebar(testCase.Axes, "x", 2, "mm", "NotAnOption", 1), ...
                'scalebar:UnknownOption')
        end

        function testConstructorRejectsNonpositiveLength(testCase)
            testCase.verifyError( ...
                @() scalebar(testCase.Axes, "x", 0, "mm"), ...
                'scalebar:InvalidScalebarLength')
        end

        function testPropertyChangesUpdateGraphics(testCase)
            hScalebar = testCase.createScalebar("x", 2, "mm");
            hLine = findobj(testCase.Axes, 'Tag', 'Scalebar Line');
            hText = findobj(testCase.Axes, 'Tag', 'Scalebar Text');

            initialTextPosition = hText.Position;
            hScalebar.TextSpacing = 20;
            testCase.verifyNotEqual(hText.Position, initialTextPosition)

            hScalebar.Axis = "y";
            testCase.verifyEqual(range(hLine.XData), 0)
            testCase.verifyEqual(range(hLine.YData), hScalebar.ScalebarLength)
            testCase.verifyEqual(hText.Rotation, 90)
        end

        function testEnablingAutomaticLengthUpdatesScalebar(testCase)
            hScalebar = testCase.createScalebar("x", 1, "mm");

            hScalebar.AutoAdjustScalebarLength = true;

            testCase.verifyEqual(hScalebar.ScalebarLength, 2)
        end

        function testReversedXAxisUsesVisualLocation(testCase)
            testCase.Axes.XDir = 'reverse';
            testCase.createScalebar( ...
                "x", 2, "mm", "Location", "southeast");
            hLine = findobj(testCase.Axes, 'Tag', 'Scalebar Line');

            testCase.verifyLessThan(mean(hLine.XData), mean(testCase.Axes.XLim))
        end
    end

    methods (Access = private)
        function hScalebar = createScalebar(testCase, varargin)
            hScalebar = scalebar(testCase.Axes, varargin{:});
            testCase.addTeardown(@() delete(hScalebar))
        end
    end
end
